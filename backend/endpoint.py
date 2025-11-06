from fileinput import filename
from flask import Blueprint, jsonify, request, current_app
import pymysql
from werkzeug.utils import secure_filename
from connetion import get_db_connection
from extensions import bcrypt
import os
import time
from config import Base_URL
from datetime import datetime
import locale

api_bp = Blueprint("api", __name__)

# Health check
@api_bp.route("/status")
def health_check():
    try:
        db_conn = get_db_connection()
        if db_conn:
            db_conn.close()
            return jsonify({"status": "ok", "db": "connected"}), 200
        return jsonify({"status": "error", "db": "failed to connect"}), 500
    except Exception as e:
        return jsonify({"status": "error", "db": str(e)}), 500

# Hello
@api_bp.route("/hello")
def hello():
    return jsonify({"message": "Hello from Flask!"})

# Login
@api_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    nama = data.get('nama')
    password_input = data.get('password')

    if not nama or not password_input:
        return jsonify({"error": "Nama dan password wajib diisi"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM user WHERE nama=%s", (nama,))
    user = cursor.fetchone()
    conn.close()

    if not user or not bcrypt.check_password_hash(user['password'], password_input):
        return jsonify({"error": "Username atau password salah"}), 401

    return jsonify({
        "message": "Login berhasil",
        "user": {
            "id": user['id'],
            "nama": user['nama'],
            "email": user['email']
        }
    }), 200

# Input barang
@api_bp.route('/input', methods=['POST'])
def tambah_barang_masuk():
    try:
        data = request.form
        file = request.files.get("foto_barang")

        required_fields = [
            "id_pemesanan", "no_bmn", "tanggal_barang_datang",
            "spesifikasi", "nama_barang", "jumlah_satuan",
            "nama_ruangan", "lantai", "B", "RR", "RB", "no_barcode", "kategori"
        ]
        if not all([data.get(f) for f in required_fields]) or not file or file.filename == '':
            return jsonify({"error": "Semua field harus diisi dan foto barang harus diupload!"}), 400

        # Validasi file
        def allowed_file(filename):
            return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg'}

        if not allowed_file(file.filename):
            return jsonify({"error": "Format file tidak didukung! (Gunakan .jpg, .jpeg, .png)"}), 400

        # Simpan foto
        upload_folder = os.path.join(current_app.config['UPLOAD_FOLDER'], 'barang')
        os.makedirs(upload_folder, exist_ok=True)
        filename = secure_filename(file.filename)
        unique_filename = f"{int(time.time())}_{filename}"
        save_path = os.path.join(upload_folder, unique_filename)
        file.save(save_path)

        # Insert ke barang_masuk
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO barang_masuk (
                id_pemesanan, no_bmn, tanggal_barang_datang, spesifikasi, nama_barang,
                jumlah_satuan, nama_ruangan, lantai, B, RR, RB, no_barcode, foto_barang, kategori
            ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            data["id_pemesanan"], data["no_bmn"], data["tanggal_barang_datang"], data["spesifikasi"],
            data["nama_barang"], data["jumlah_satuan"], data["nama_ruangan"], data["lantai"],
            data["B"], data["RR"], data["RB"], data["no_barcode"], unique_filename, data["kategori"]
        ))

        # Update status pemesanan jadi complete
        cursor.execute("""
            UPDATE pemesanan
            SET status = 'complete'
            WHERE id = %s AND status = 'pending'
        """, (data["id_pemesanan"],))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"message": "Data barang berhasil ditambahkan dan status pemesanan diperbarui!"}), 201

    except Exception as e:
        print("❌ ERROR:", e)
        return jsonify({"error": str(e)}), 500


@api_bp.route('/lantai', methods=['GET'])
def get_lantai():
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT DISTINCT lantai FROM barang_masuk")
        lantai_list = cursor.fetchall()
        return jsonify(lantai_list), 200
    except Exception as e:
        print("Error:", e)
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

@api_bp.route('/isitabel/<int:lantai>', methods=['GET'])
def get_barang_by_lantai(lantai):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        # Gunakan locale Indonesia
        try:
            locale.setlocale(locale.LC_TIME, 'id_ID.UTF-8')
        except:
            locale.setlocale(locale.LC_TIME, 'id_ID')  # fallback

        cursor = conn.cursor(pymysql.cursors.DictCursor)

        # Ambil kategori dari query param (misal ?kategori=gudang)
        kategori = request.args.get("kategori")

        if kategori:
            cursor.execute("""
                SELECT 
                    id, no_bmn, tanggal_barang_datang, spesifikasi,
                    nama_barang, jumlah_satuan, nama_ruangan,
                    lantai, B, RR, RB, no_barcode, foto_barang, kategori
                FROM barang_masuk
                WHERE lantai = %s AND kategori = %s
                ORDER BY id ASC
            """, (lantai, kategori))
        else:
            # fallback kalau nggak dikasih kategori
            cursor.execute("""
                SELECT 
                    id, no_bmn, tanggal_barang_datang, spesifikasi,
                    nama_barang, jumlah_satuan, nama_ruangan,
                    lantai, B, RR, RB, no_barcode, foto_barang, kategori
                FROM barang_masuk
                WHERE lantai = %s
                ORDER BY id ASC
            """, (lantai,))

        rows = cursor.fetchall()

        if not rows:
            return jsonify({"message": f"Tidak ada data di lantai {lantai}"}), 200

        for row in rows:
            # Format tanggal ke Bahasa Indonesia
            tgl = row.get("tanggal_barang_datang")
            if isinstance(tgl, (datetime, str)):
                if isinstance(tgl, str):
                    try:
                        tgl = datetime.fromisoformat(tgl)
                    except:
                        pass
                row["tanggal_barang_datang"] = tgl.strftime("%A, %d %B %Y")  # Kamis, 23 Oktober 2025

            # Ganti nama kolom foto menjadi URL lengkap
            foto_filename = row.get("foto_barang")
            if foto_filename:
                row["foto_barang"] = f"{Base_URL}/uploads/barang/{foto_filename}"

        return jsonify(rows), 200

    except Exception as e:
        print("❌ ERROR:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()



@api_bp.route('/cari/barcode', methods=['GET'])
def cari_barang_berdasarkan_barcode():
    barcode = request.args.get('barcode')

    if not barcode:
        return jsonify({"error": "Barcode tidak boleh kosong"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(pymysql.cursors.DictCursor)

    query = """
        SELECT id, no_bmn, nama_barang, tanggal_barang_datang, lantai, jumlah_satuan,
               B, RR, RB, foto_barang, no_barcode
        FROM barang_masuk
        WHERE no_barcode = %s
    """
    cursor.execute(query, (barcode,))
    result = cursor.fetchone()

    cursor.close()
    conn.close()

    if result:
        if result.get("foto_barang"):
            result["foto_barang"] = f"{Base_URL}/uploads/barang/{result['foto_barang']}"
        return jsonify({"status": "success", "data": result}), 200
    else:
        return jsonify({"status": "not_found", "message": "Barang tidak ditemukan"}), 404


@api_bp.route('/cari/nobmn', methods=['GET'])
def cari_barang_berdasarkan_nobmn():
    nobmn = request.args.get('nobmn')

    if not nobmn:
        return jsonify({"error": "No BMN tidak boleh kosong"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(pymysql.cursors.DictCursor)

    query = """
        SELECT id, no_bmn, nama_barang, tanggal_barang_datang, lantai, jumlah_satuan,
               B, RR, RB, foto_barang, no_barcode
        FROM barang_masuk
        WHERE no_bmn = %s
    """
    cursor.execute(query, (nobmn,))
    result = cursor.fetchone()

    cursor.close()
    conn.close()

    if result:
        if result.get("foto_barang"):
            result["foto_barang"] = f"{Base_URL}/uploads/barang/{result['foto_barang']}"
        return jsonify({"status": "success", "data": result}), 200
    else:
        return jsonify({"status": "not_found", "message": "Barang tidak ditemukan"}), 404


@api_bp.route('/cari/lantai', methods=['GET'])
def cari_barang_berdasarkan_lantai():
    lantai = request.args.get('lantai')

    if not lantai:
        return jsonify({"error": "Lantai tidak boleh kosong"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(pymysql.cursors.DictCursor)

    query = """
        SELECT id, no_bmn, nama_barang, tanggal_barang_datang, lantai, jumlah_satuan,
               B, RR, RB, foto_barang, no_barcode
        FROM barang_masuk
        WHERE lantai = %s
    """
    cursor.execute(query, (lantai,))
    result = cursor.fetchone()

    cursor.close()
    conn.close()

    if result:
        if result.get("foto_barang"):
            result["foto_barang"] = f"{Base_URL}/uploads/barang/{result['foto_barang']}"
        return jsonify({"status": "success", "data": result}), 200
    else:
        return jsonify({"status": "not_found", "message": "Barang tidak ditemukan"}), 404
    
@api_bp.route('/pemesanan', methods=['POST'])
def tambah_pemesanan():
    try:
        data = request.form
        file = request.files.get("foto")

        print("📦 Data form:", dict(data))
        print("📷 File:", file)
        print("📷 Filename:", file.filename if file else None)

        # Semua field wajib sesuai tabel
        required_fields = [
            "nama_pemesan", "nama_barang", "jumlah", "nama_ruangan",
            "harga", "link_pembelian", "satuan", "spesifikasi", "kategori"
        ]
        if not all(data.get(f) for f in required_fields) or not file or file.filename == '':
            return jsonify({"error": "Semua field harus diisi dan foto barang harus diupload!"}), 400

        # Validasi file
        def allowed_file(filename):
            return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg'}
        if not allowed_file(file.filename):
            return jsonify({"error": "Format file tidak didukung! (Gunakan .jpg, .jpeg, .png)"}), 400

        # Simpan foto
        upload_folder = os.path.join(current_app.config['UPLOAD_FOLDER'], 'pemesanan')
        os.makedirs(upload_folder, exist_ok=True)
        filename = secure_filename(file.filename)
        unique_filename = f"{int(time.time())}_{filename}"
        save_path = os.path.join(upload_folder, unique_filename)
        file.save(save_path)

        tanggal_pemesanan = datetime.now()

        # Simpan data ke database (tambah kolom kategori)
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO pemesanan (
                        nama_pemesan, jumlah, foto, tanggal_pemesanan,
                        nama_barang, nama_ruangan, harga, link_pembelian,
                        satuan, spesifikasi, kategori
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    data["nama_pemesan"], data["jumlah"], unique_filename, tanggal_pemesanan,
                    data["nama_barang"], data["nama_ruangan"],
                    data["harga"], data["link_pembelian"],
                    data["satuan"], data["spesifikasi"], data["kategori"]
                ))
                conn.commit()
                new_id = cursor.lastrowid

        return jsonify({
            "message": "Data pemesanan berhasil ditambahkan!",
            "id": new_id
        }), 201

    except Exception as e:
        print("❌ ERROR:", e)
        return jsonify({"error": str(e)}), 500


@api_bp.route('/pemesanan', defaults={'id': None}, methods=['GET'])
@api_bp.route('/pemesanan/<int:id>', methods=['GET'])
def get_pemesanan(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        # Locale Indonesia
        try:
            locale.setlocale(locale.LC_TIME, 'id_ID.UTF-8')
        except:
            locale.setlocale(locale.LC_TIME, 'id_ID')

        cursor = conn.cursor(pymysql.cursors.DictCursor)

        kategori = request.args.get('kategori')  # ✅ ambil query param kategori (opsional)

        if id is not None:
            # ✅ Kalau ada ID → ambil 1 data
            cursor.execute("""
                SELECT 
                    id, nama_pemesan, nama_barang, jumlah, nama_ruangan, harga,
                    link_pembelian, tanggal_pemesanan, foto, satuan, spesifikasi, kategori,
                    status
                FROM pemesanan
                WHERE id = %s
            """, (id,))
        else:
            # ✅ Kalau gak ada ID → ambil semua, tapi bisa difilter kategori
            if kategori:
                cursor.execute("""
                    SELECT 
                        id, nama_pemesan, nama_barang, jumlah, nama_ruangan, harga,
                        link_pembelian, tanggal_pemesanan, foto, satuan, spesifikasi, kategori,
                        status
                    FROM pemesanan
                    WHERE kategori = %s
                    ORDER BY tanggal_pemesanan DESC
                """, (kategori,))
            else:
                cursor.execute("""
                    SELECT 
                        id, nama_pemesan, nama_barang, jumlah, nama_ruangan, harga,
                        link_pembelian, tanggal_pemesanan, foto, satuan, spesifikasi, kategori,
                        status
                    FROM pemesanan
                    ORDER BY tanggal_pemesanan DESC
                """)

        rows = cursor.fetchall()

        if not rows:
            return jsonify([]), 200

        # Format tanggal & foto URL
        for row in rows:
            tgl = row.get("tanggal_pemesanan")
            if tgl:
                if isinstance(tgl, str):
                    try:
                        tgl = datetime.strptime(tgl, "%a, %d %b %Y %H:%M:%S %Z")
                    except ValueError:
                        tgl = datetime.fromisoformat(tgl.replace("Z", "+00:00"))
                row["tanggal_pemesanan"] = tgl.strftime("%A, %d %B %Y").capitalize()

            foto_filename = row.get("foto")
            if foto_filename:
                row["foto_url"] = f"{Base_URL}/uploads/pemesanan/{foto_filename}"

        # Kalau cuma 1 data, balikin object
        if id is not None and len(rows) == 1:
            return jsonify(rows[0]), 200
        else:
            return jsonify(rows), 200

    except Exception as e:
        print("❌ ERROR (GET /pemesanan):", e)
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()


@api_bp.route('/pemesanan/pending', methods=['GET'])
def get_pending_pemesanan():
    kategori = request.args.get('kategori')  # ambil kategori dari query param (opsional)

    conn = get_db_connection()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    if kategori:
        cursor.execute("""
            SELECT id, nama_barang, nama_pemesan, tanggal_pemesanan, jumlah
            FROM pemesanan
            WHERE status = 'pending' AND kategori = %s
            ORDER BY tanggal_pemesanan ASC
        """, (kategori,))
    else:
        cursor.execute("""
            SELECT id, nama_barang, nama_pemesan, tanggal_pemesanan, jumlah
            FROM pemesanan
            WHERE status = 'pending'
            ORDER BY tanggal_pemesanan ASC
        """)

    data = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(data), 200
