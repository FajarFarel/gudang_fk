from fileinput import filename
from flask import Blueprint, jsonify, request, current_app
import pymysql.cursors
from werkzeug.utils import secure_filename
from connetion import get_db_connection
from extensions import bcrypt
import os
import time
from config import Base_URL
from datetime import datetime
from dateutil.relativedelta import relativedelta
import locale
from fuzzy import match_to_canon


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
    role = data.get('role')

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
            "email": user['email'],
            "role": user['role']
        }
    }), 200

# Input barang
@api_bp.route('/input', methods=['POST'])
def tambah_barang_masuk():
    try:
        data = request.form
        file = request.files.get("foto_barang")

        required_fields = [
            "no_bmn", "tanggal_barang_datang",
            "spesifikasi", "nama_barang", "jumlah","satuan",
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
                no_bmn, tanggal_barang_datang, spesifikasi, nama_barang,
                jumlah, satuan, nama_ruangan, lantai, B, RR, RB, no_barcode, foto_barang, kategori
            ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            data["no_bmn"], data["tanggal_barang_datang"], data["spesifikasi"],
            data["nama_barang"], data["jumlah"], data["satuan"], data["nama_ruangan"], data["lantai"],
            data["B"], data["RR"], data["RB"], data["no_barcode"], unique_filename, data["kategori"]
        ))

        # Update status pemesanan jadi complete

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"message": "Data barang berhasil ditambahkan dan status pemesanan diperbarui!"}), 201

    except Exception as e:
        print("❌ ERROR:", e)
        return jsonify({"error": str(e)}), 500
    

@api_bp.route('/edit_gudang/<int:id>', methods=['GET', 'PUT'])
def edit_data_gudang(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:

            if request.method == 'GET':
                # Ambil data existing untuk prefill
                cursor.execute("""
                    SELECT B, RR, RB
                    FROM barang_masuk
                    WHERE id = %s AND kategori = 'gudang'
                """, (id,))
                result = cursor.fetchone()

                if not result:
                    return jsonify({"error": "Data tidak ditemukan"}), 404

                return jsonify(result), 200

            # ======================
            # Method PUT (UPDATE)
            # ======================
            data = request.form
            B = data.get("B")
            RR = data.get("RR")
            RB = data.get("RB")

            cursor.execute("""
                UPDATE barang_masuk
                SET B = %s, RR = %s, RB = %s
                WHERE id = %s AND kategori = 'gudang'
            """, (B, RR, RB, id))

            conn.commit()

            return jsonify({"message": "Data berhasil diupdate"}), 200

    except Exception as e:
        print("Error:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        conn.close()

@api_bp.route('/edit_pemesanan/<int:id>', methods=['GET', 'PUT'])
def edit_pemesanan(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:

            # ====================================
            # GET -> Ambil data lama untuk popup UI
            # ====================================
            if request.method == 'GET':
                cursor.execute("""
                    SELECT nama_pemesan, nama_barang, jumlah, tanggal_pemesanan,
                        satuan, spesifikasi, harga, link_pembelian, foto
                    FROM pemesanan
                    WHERE id = %s
                """, (id,))
                result = cursor.fetchone()

                if not result:
                    return jsonify({"error": "Data tidak ditemukan"}), 404

                # Parse string GMT ke datetime
                raw_date = result["tanggal_pemesanan"]
                if isinstance(raw_date, str):
                    try:
                        raw_date = datetime.strptime(raw_date, "%a, %d %b %Y %H:%M:%S %Z")
                    except:
                        raw_date = datetime.strptime(raw_date, "%Y-%m-%d")

                # Format sesuai kebutuhan
                result["tanggal_pemesanan"] = raw_date.strftime("%d-%m-%Y")  # 🔥 ini format baru

                return jsonify(result), 200



            # ====================================
            # PUT -> Update data + foto opsional
            # ====================================
            data = request.form
            file = request.files.get("foto")

            nama_pemesan = data.get("nama_pemesan")
            nama_barang = data.get("nama_barang")
            jumlah = data.get("jumlah")
            tanggal_pemesanan = data.get("tanggal_pemesanan")
            satuan = data.get("satuan")
            spesifikasi = data.get("spesifikasi")
            harga = data.get("harga")
            link_pembelian = data.get("link_pembelian")

            # Ambil nama foto lama dulu buat delete
            cursor.execute("SELECT foto FROM pemesanan WHERE id = %s", (id,))
            old = cursor.fetchone()
            old_foto = old["foto"] if old else None

            # Ada upload foto baru?
            if file:
                filename = f"pemesanan_{id}_{file.filename}"
                save_path = os.path.join("uploads/pemesanan", filename)
                file.save(save_path)

                # Hapus foto lama jika ada
                if old_foto:
                    old_path = os.path.join("uploads/pemesanan", old_foto)
                    if os.path.exists(old_path):
                        os.remove(old_path)
                        print("Foto lama dihapus")

                cursor.execute("""
                    UPDATE pemesanan
                    SET nama_pemesan = %s, nama_barang = %s, jumlah = %s, tanggal_pemesanan = %s,
                        satuan = %s, spesifikasi = %s, harga = %s, link_pembelian = %s, foto = %s
                    WHERE id = %s
                """, (nama_pemesan, nama_barang, jumlah, tanggal_pemesanan, satuan,
                      spesifikasi, harga, link_pembelian, filename, id))

            else:
                # Foto tidak diubah
                cursor.execute("""
                    UPDATE pemesanan
                    SET nama_pemesan = %s, nama_barang = %s, jumlah = %s, tanggal_pemesanan = %s,
                        satuan = %s, spesifikasi = %s, harga = %s, link_pembelian = %s
                    WHERE id = %s
                """, (nama_pemesan, nama_barang, jumlah, tanggal_pemesanan, satuan,
                      spesifikasi, harga, link_pembelian, id))

            conn.commit()
            return jsonify({"message": "Data pemesanan berhasil diupdate"}), 200

    except Exception as e:
        print("❌ Error:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        conn.close()

@api_bp.route('/hapus_gudang/<int:id>', methods=['DELETE'])
def hapus_data_gudang(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:

            # 1️⃣ Ambil nama file foto dulu
            cursor.execute("""
                SELECT foto_barang 
                FROM barang_masuk 
                WHERE id = %s AND kategori = 'gudang'
            """, (id,))
            data = cursor.fetchone()

            if not data:
                return jsonify({"message": f"Barang dengan id {id} tidak ditemukan di gudang"}), 404

            foto_filename = data["foto_barang"]

            # 2️⃣ Hapus row di database
            cursor.execute("""
                DELETE FROM barang_masuk 
                WHERE id = %s AND kategori = 'gudang'
            """, (id,))
            conn.commit()

            # 3️⃣ Hapus file foto (kalau ada)
            if foto_filename:
                file_path = os.path.join("uploads/gudang", foto_filename)

                # Cek dulu file-nya ada
                if os.path.exists(file_path):
                    os.remove(file_path)
                    print(f"File {file_path} dihapus.")
                else:
                    print(f"File {file_path} tidak ditemukan, skip delete.")

            return jsonify({
                "message": f"Barang dengan id {id} dan file fotonya berhasil dihapus"
            }), 200

    except Exception as e:
        print("❌ Error:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        conn.close()

@api_bp.route('/hapus_pemesanan_gudang/<int:id>', methods=['DELETE'])
def hapus_pemesanan_data_gudang(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:

            # 1️⃣ Ambil nama file foto dulu
            cursor.execute("""
                SELECT foto
                FROM pemesanan
                WHERE id = %s AND kategori = 'gudang'
            """, (id,))
            data = cursor.fetchone()

            if not data:
                return jsonify({"message": f"Barang dengan id {id} tidak ditemukan di gudang"}), 404

            foto_filename = data["foto"]

            # 2️⃣ Hapus row di database
            cursor.execute("""
                DELETE FROM pemesanan 
                WHERE id = %s AND kategori = 'gudang'
            """, (id,))
            conn.commit()

            # 3️⃣ Hapus file foto (kalau ada)
            if foto_filename:
                file_path = os.path.join("uploads/pemesanan", foto_filename)

                # Cek dulu file-nya ada
                if os.path.exists(file_path):
                    os.remove(file_path)
                    print(f"File {file_path} dihapus.")
                else:
                    print(f"File {file_path} tidak ditemukan, skip delete.")

            return jsonify({
                "message": f"Barang dengan id {id} dan file fotonya berhasil dihapus"
            }), 200

    except Exception as e:
        print("❌ Error:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        conn.close()


@api_bp.route('/lantai', methods=['GET'])
def get_lantai():
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT DISTINCT lantai 
            FROM barang_masuk 
            WHERE kategori = 'gudang'
            ORDER BY lantai DESC
        """)
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
                    nama_barang, jumlah, satuan, nama_ruangan,
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
                    nama_barang, jumlah, satuan, nama_ruangan,
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
        SELECT id, no_bmn, nama_barang, tanggal_barang_datang, lantai, jumlah, satuan,
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
        SELECT id, no_bmn, nama_barang, tanggal_barang_datang, lantai, jumlah, satuan,
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
        SELECT id, no_bmn, nama_barang, tanggal_barang_datang, lantai, jumlah, satuan,
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
        # ================================
        # 1. CEK STATUS SWITCH
        # ================================
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT value FROM settings WHERE name = 'input_status'")
        status = cursor.fetchone()

        if status and status['value'] == 0:
            conn.close()
            return jsonify({
                "error": "Input sedang dimatikan oleh admin!"
            }), 403

        # ================================
        # 2. LANJUTKAN PROSES NORMAL
        # ================================
        data = request.form
        tanggal_pemesanan = datetime.now()
        tanggal_next_year = tanggal_pemesanan + relativedelta(years=1)

        file = request.files.get("foto")

        print("📦 Data form:", dict(data))
        print("📷 File:", file)
        print("📷 Filename:", file.filename if file else None)

        required_fields = [
            "nama_pemesan", "nama_barang", "jumlah", "nama_ruangan",
            "harga", "link_pembelian", "satuan", "spesifikasi", "kategori"
        ]

        if not all(data.get(f) for f in required_fields) or not file or file.filename == '':
            return jsonify({"error": "Semua field harus diisi dan foto barang harus diupload!"}), 400

        def allowed_file(filename):
            return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg'}
        if not allowed_file(file.filename):
            return jsonify({"error": "Format file tidak didukung!"}), 400

        upload_folder = os.path.join(current_app.config['UPLOAD_FOLDER'], 'pemesanan')
        os.makedirs(upload_folder, exist_ok=True)
        filename = secure_filename(file.filename)
        unique_filename = f"{int(time.time())}_{filename}"
        save_path = os.path.join(upload_folder, unique_filename)
        file.save(save_path)

        with conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO pemesanan (
                        nama_pemesan, jumlah, foto, tanggal_pemesanan, 
                        pemesanan_berakhir, nama_barang, nama_ruangan,
                        harga, link_pembelian, satuan, spesifikasi, kategori
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    data["nama_pemesan"], data["jumlah"], unique_filename,
                    tanggal_pemesanan.strftime("%Y-%m-%d"),
                    tanggal_next_year.strftime("%Y-%m-%d"),
                    data["nama_barang"], data["nama_ruangan"],
                    data["harga"], data["link_pembelian"],
                    data["satuan"], data["spesifikasi"], data["kategori"]
                ))

                new_id = cursor.lastrowid

        return jsonify({
            "message": "Data pemesanan berhasil ditambahkan!",
            "id": new_id
        }), 201

    except Exception as e:
        print("❌ ERROR:", e)
        return jsonify({"error": str(e)}), 500

@api_bp.route('/lihat/pemesanan/status/<int:id>', methods=['GET'])
def get_pemesanan_status(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cur = conn.cursor()
        cur.execute("SELECT is_open FROM pemesanan_status WHERE id = %s;", (id,))
        result = cur.fetchone()

        print("🔥 DB RESULT:", result)

        if not result:
            return jsonify({"is_open": True})

        # FIX: akses langsung key dict
        is_open = bool(result["is_open"])
        return jsonify({"id": id, "is_open": is_open})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    finally:
        cur.close()
        conn.close()

@api_bp.route('/pemesanan/status/<int:id>', methods=['PUT'])
def update_pemesanan_status(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        data = request.get_json()
        status = data.get("is_open", True)

        cur = conn.cursor()  # <-- FIX

        cur.execute("UPDATE pemesanan_status SET is_open = %s WHERE id = %s", (status, id))
        conn.commit()

        return jsonify({"message": "Status updated", "id": id, "is_open": status})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()
        conn.close()


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
    # Kalau ada ID → ambil 1 data
            cursor.execute("""
                SELECT 
                    id, nama_pemesan, nama_barang, jumlah, nama_ruangan, harga,
                    link_pembelian, tanggal_pemesanan, foto, satuan, spesifikasi, kategori
                FROM pemesanan
                WHERE id = %s
            """, (id,))
        else:
            # Ambil kategori dari query param
            kategori = request.args.get('kategori')

            # Wajib ada kategori
            if not kategori:
                return jsonify({
                    "error": "Kategori wajib diisi. Contoh: /pemesanan?kategori=atk"
                }), 400

            # Ambil data berdasarkan kategori
            cursor.execute("""
                SELECT 
                    id, nama_pemesan, nama_barang, jumlah, nama_ruangan, harga,
                    link_pembelian, tanggal_pemesanan, foto, satuan, spesifikasi, kategori
                FROM pemesanan
                WHERE kategori = %s
                ORDER BY tanggal_pemesanan DESC
            """, (kategori,))


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

@api_bp.route('/atkmasuk', methods=['POST'])
def tambah_atk_masuk():
    try:
        data = request.form
        file = request.files.get("foto_barang")

        required_fields = [
            "no_bmn", "tanggal_barang_datang",
            "spesifikasi", "nama_barang", "jumlah",
            "B", "RR", "RB", "no_barcode", "kategori","satuan"
        ]

        # Validasi input wajib
        if not all([data.get(f) for f in required_fields]) or not file or file.filename == '':
            return jsonify({"error": "Semua field harus diisi dan foto barang harus diupload!"}), 400

        # Validasi file
        def allowed_file(filename):
            return '.' in filename and filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg'}

        if not allowed_file(file.filename):
            return jsonify({"error": "Format file tidak didukung! (Gunakan .jpg, .jpeg, .png)"}), 400

        input_name = data["nama_barang"]
        nama_corrected = match_to_canon(input_name)
        # kalau mau score, tinggal: match_to_canon(nama_input, return_score=True)

        upload_folder = os.path.join(current_app.config['UPLOAD_FOLDER'], 'atk')
        os.makedirs(upload_folder, exist_ok=True)
        filename = secure_filename(file.filename)
        unique_filename = f"{int(time.time())}_{filename}"
        save_path = os.path.join(upload_folder, unique_filename)
        file.save(save_path)


        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(""" INSERT INTO barang_masuk 
            ( no_bmn, tanggal_barang_datang, spesifikasi, 
            nama_barang, jumlah, B, RR, RB, no_barcode, foto_barang, 
            kategori, satuan ) 
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) """, 
        ( 
            data["no_bmn"],
            data["tanggal_barang_datang"], 
            data["spesifikasi"], nama_corrected, # ⬅️ SIMPAN NAMA SUDAH DIBENERIN 
            data["jumlah"], 
            data["B"], 
            data["RR"], 
            data["RB"], 
            data["no_barcode"], 
            unique_filename, 
            data["kategori"], 
            data["satuan"] 
            ))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            "message": "✅ Data ATK berhasil ditambahkan!",
            "nama_asli": input_name,
            "nama_disimpan": nama_corrected
        }), 201

    except Exception as e:
        print("❌ ERROR:", e)
        return jsonify({"error": str(e)}), 500

    
@api_bp.route('/pemesananatk', methods=['POST'])
def tambah_pemesanan_atk():
    try:
        data = request.form
        # Convert string tanggal jadi datetime, lalu tambah 1 tahun
        tanggal_awal = datetime.now()
        tanggal_next_year = tanggal_awal + relativedelta(years=1)

        file = request.files.get("foto")

        print("📦 Data form:", dict(data))
        print("📷 File:", file)
        print("📷 Filename:", file.filename if file else None)

        # Semua field wajib sesuai tabel
        required_fields = [
            "nama_pemesan", "nama_barang", "jumlah",
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
                    pemesanan_berakhir,
                    nama_barang, harga, link_pembelian,
                    satuan, spesifikasi, kategori
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                data["nama_pemesan"],
                data["jumlah"],
                unique_filename,
                tanggal_pemesanan.strftime("%Y-%m-%d"),
                tanggal_next_year.strftime("%Y-%m-%d"),  # 🎯 ini pemesanan_berakhir
                data["nama_barang"],
                data["harga"],
                data["link_pembelian"],
                data["satuan"],
                data["spesifikasi"],
                data["kategori"]
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
    

@api_bp.route('/lihat/pemesananatk/status/<int:id>', methods=['GET'])
def get_pemesananatk_status(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cur = conn.cursor()
        cur.execute("SELECT is_open FROM pemesanan_status WHERE id = %s;", (id,))
        result = cur.fetchone()

        print("🔥 DB RESULT:", result)

        if not result:
            return jsonify({"is_open": True})

        # FIX: akses langsung key dict
        is_open = bool(result["is_open"])
        return jsonify({"id": id, "is_open": is_open})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    finally:
        cur.close()
        conn.close()

@api_bp.route('/pemesananatk/status/<int:id>', methods=['PUT'])
def update_pemesananatk_status(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        data = request.get_json()
        status = data.get("is_open", True)

        cur = conn.cursor()  # <-- FIX

        cur.execute("UPDATE pemesanan_status SET is_open = %s WHERE id = %s", (status, id))
        conn.commit()

        return jsonify({"message": "Status updated", "id": id, "is_open": status})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cur.close()
        conn.close()



@api_bp.route('/stok', methods=['GET'])
def get_stok():
    try:
        kategori = request.args.get("kategori")  # bisa None
        conn = get_db_connection()
        if conn is None:
            return jsonify({"error": "Gagal konek ke database"}), 500

        with conn.cursor(pymysql.cursors.DictCursor) as cursor:

            # Query fleksibel tergantung kategori
            if kategori:
                cursor.execute("""
                    SELECT nama_barang, jumlah, satuan, kategori
                    FROM barang_masuk
                    WHERE kategori = %s
                """, (kategori,))
            else:
                cursor.execute("""
                    SELECT nama_barang, jumlah, satuan, kategori
                    FROM barang_masuk
                """)

            data = cursor.fetchall()

        stok = {}

        for item in data:
            corrected = match_to_canon(item['nama_barang'])
            qty = int(item['jumlah'])

            # kalau kategori belum ada → buat
            if corrected not in stok:
                stok[corrected] = {
                    "total": 0,
                    "kategori": item["kategori"]  # ambil kategori asli
                }

            stok[corrected]["total"] += qty

        return jsonify(stok), 200

    except Exception as e:
        print("❌ ERROR get_stok:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        if conn:
            conn.close()

@api_bp.route('/atk/keluar', methods=['POST'])
def atk_keluar():
    try:
        data = request.form
        file = request.files.get("foto")  # opsional

        nama_pengambil = data.get("nama")
        nama_input = data.get("nama_barang")
        jumlah_keluar = data.get("jumlah")

        if not nama_pengambil or not nama_input or not jumlah_keluar:
            return jsonify({"error": "Field nama, nama_barang, dan jumlah wajib diisi"}), 400

        jumlah_keluar = int(jumlah_keluar)

        # fuzzy name
        nama_corrected = match_to_canon(nama_input)

        conn = get_db_connection()
        cursor = conn.cursor(pymysql.cursors.DictCursor)

        # cek stok barang
        cursor.execute("""
            SELECT id, nama_barang, jumlah, satuan
            FROM barang_masuk
            WHERE nama_barang = %s
            ORDER BY id ASC
        """, (nama_corrected,))

        rows = cursor.fetchall()

        if not rows:
            return jsonify({"error": f"Barang '{nama_corrected}' tidak ditemukan"}), 404

        total_stok = sum(int(r["jumlah"]) for r in rows)

        if total_stok < jumlah_keluar:
            return jsonify({
                "error": "Stok tidak cukup!",
                "stok_tersedia": total_stok
            }), 400

        foto_filename = None

        if file and file.filename != "":
            upload_folder = os.path.join(current_app.config['UPLOAD_FOLDER'], 'atk_keluar')
            os.makedirs(upload_folder, exist_ok=True)
            safe_name = secure_filename(file.filename)
            foto_filename = f"{int(time.time())}_{safe_name}"
            save_path = os.path.join(upload_folder, foto_filename)
            file.save(save_path)


        sisa = jumlah_keluar

        for row in rows:
            if sisa <= 0:
                break

            stok = int(row["jumlah"])

            if stok <= sisa:
                cursor.execute("UPDATE barang_masuk SET jumlah = 0 WHERE id = %s", (row["id"],))
                sisa -= stok
            else:
                cursor.execute(
                    "UPDATE barang_masuk SET jumlah = %s WHERE id = %s",
                    (stok - sisa, row["id"])
                )
                sisa = 0

        cursor.execute("""
            INSERT INTO atk_keluar (nama, nama_barang, jumlah, foto)
            VALUES (%s, %s, %s, %s)
        """, (
            nama_pengambil,
            nama_corrected,
            jumlah_keluar,
            foto_filename
        ))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            "message": "Stok berhasil dikurangi & dicatat",
            "nama_pengambil": nama_pengambil,
            "nama_barang": nama_corrected,
            "jumlah_keluar": jumlah_keluar,
            "stok_sisa": total_stok - jumlah_keluar
        }), 200

    except Exception as e:
        print("❌ ERROR ATK KELUAR:", e)
        return jsonify({"error": str(e)}), 500

@api_bp.route('/cari/atk/nobmn', methods=['GET'])
def cari_atk_berdasarkan_nobmn():
    nobmn = request.args.get('nobmn')

    if not nobmn:
        return jsonify({"error": "No BMN tidak boleh kosong"}), 400

    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(pymysql.cursors.DictCursor)

    query = """
        SELECT id, no_bmn, nama_barang, tanggal_barang_datang, lantai, jumlah, satuan,
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
            result["foto_barang"] = f"{Base_URL}/uploads/atk/{result['foto_barang']}"
        return jsonify({"status": "success", "data": result}), 200
    else:
        return jsonify({"status": "not_found", "message": "Barang tidak ditemukan"}), 404


@api_bp.route('/isitabelatk', methods=['GET'])
def get_atk_by_kategori():
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database con  nection failed"}), 500

    try:
        # Atur locale Indonesia
        try:
            locale.setlocale(locale.LC_TIME, 'id_ID.UTF-8')
        except:
            locale.setlocale(locale.LC_TIME, 'id_ID')

        cursor = conn.cursor(pymysql.cursors.DictCursor)

        kategori = request.args.get("kategori")

        if not kategori:
            return jsonify({"error": "Parameter 'kategori' wajib diisi"}), 400

        cursor.execute("""
            SELECT 
                id, no_bmn, tanggal_barang_datang, spesifikasi,
                nama_barang, jumlah, satuan, B, RR, RB, no_barcode, foto_barang, kategori
            FROM barang_masuk
            WHERE kategori = %s
            ORDER BY id ASC
        """, (kategori,))

        rows = cursor.fetchall()

        # Return list kosong biar Flutter ga error
        if not rows:
            return jsonify([]), 200

        for row in rows:
            tgl = row.get("tanggal_barang_datang")
            if isinstance(tgl, (datetime, str)):
                if isinstance(tgl, str):
                    try:
                        tgl = datetime.fromisoformat(tgl)
                    except:
                        pass
                row["tanggal_barang_datang"] = tgl.strftime("%A, %d %B %Y")

            foto_filename = row.get("foto_barang")
            if foto_filename:
                row["foto_barang"] = f"{Base_URL}/uploads/atk/{foto_filename}"

        return jsonify(rows), 200

    except Exception as e:
        print("❌ ERROR:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()

@api_bp.route('/edit_atk/<int:id>', methods=['GET', 'PUT'])
def edit_data_atk(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:

            if request.method == 'GET':
                # Ambil data existing untuk prefill
                cursor.execute("""
                    SELECT B, RR, RB
                    FROM barang_masuk
                    WHERE id = %s AND kategori = 'atk'
                """, (id,))
                result = cursor.fetchone()

                if not result:
                    return jsonify({"error": "Data tidak ditemukan"}), 404

                return jsonify(result), 200

            # ======================
            # Method PUT (UPDATE)
            # ======================
            data = request.form
            B = data.get("B")
            RR = data.get("RR")
            RB = data.get("RB")

            cursor.execute("""
                UPDATE barang_masuk
                SET B = %s, RR = %s, RB = %s
                WHERE id = %s AND kategori = 'atk'
            """, (B, RR, RB, id))

            conn.commit()

            return jsonify({"message": "Data berhasil diupdate"}), 200

    except Exception as e:
        print("Error:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        conn.close()

@api_bp.route('/edit_pemesanan_atk/<int:id>', methods=['GET', 'PUT'])
def edit_pemesanan_atk(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:

            # ====================================
            # GET -> Ambil data lama untuk popup UI
            # ====================================
            if request.method == 'GET':
                cursor.execute("""
                    SELECT nama_pemesan, nama_barang, jumlah, tanggal_pemesanan,
                        satuan, spesifikasi, harga, link_pembelian, foto
                    FROM pemesanan
                    WHERE id = %s
                """, (id,))
                result = cursor.fetchone()

                if not result:
                    return jsonify({"error": "Data tidak ditemukan"}), 404

                # Format tanggal ke dd/MM/yyyy
                raw_date = result["tanggal_pemesanan"]
                result["tanggal_pemesanan"] = raw_date.strftime("%d/%m/%Y") if raw_date else None

                return jsonify(result), 200
            # ====================================
            # PUT -> Update data + foto opsional
            # ====================================
            data = request.form
            file = request.files.get("foto")

            nama_pemesan = data.get("nama_pemesan")
            nama_barang = data.get("nama_barang")
            jumlah = data.get("jumlah")
            tanggal_pemesanan = data.get("tanggal_pemesanan")
            satuan = data.get("satuan")
            spesifikasi = data.get("spesifikasi")
            harga = data.get("harga")
            link_pembelian = data.get("link_pembelian")

            # Ambil nama foto lama dulu buat delete
            cursor.execute("SELECT foto FROM pemesanan WHERE id = %s", (id,))
            old = cursor.fetchone()
            old_foto = old["foto"] if old else None

            # Ada upload foto baru?
            if file:
                filename = f"pemesanan_{id}_{file.filename}"
                save_path = os.path.join("uploads/pemesanan", filename)
                file.save(save_path)

                # Hapus foto lama jika ada
                if old_foto:
                    old_path = os.path.join("uploads/pemesanan", old_foto)
                    if os.path.exists(old_path):
                        os.remove(old_path)
                        print("Foto lama dihapus")

                cursor.execute("""
                    UPDATE pemesanan
                    SET nama_pemesan = %s, nama_barang = %s, jumlah = %s, tanggal_pemesanan = %s,
                        satuan = %s, spesifikasi = %s, harga = %s, link_pembelian = %s, foto = %s
                    WHERE id = %s
                """, (nama_pemesan, nama_barang, jumlah, tanggal_pemesanan, satuan,
                      spesifikasi, harga, link_pembelian, filename, id))

            else:
                # Foto tidak diubah
                cursor.execute("""
                    UPDATE pemesanan
                    SET nama_pemesan = %s, nama_barang = %s, jumlah = %s, tanggal_pemesanan = %s,
                        satuan = %s, spesifikasi = %s, harga = %s, link_pembelian = %s
                    WHERE id = %s
                """, (nama_pemesan, nama_barang, jumlah, tanggal_pemesanan, satuan,
                      spesifikasi, harga, link_pembelian, id))

            conn.commit()
            return jsonify({"message": "Data pemesanan berhasil diupdate"}), 200

    except Exception as e:
        print("❌ Error:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        conn.close()


@api_bp.route('/hapus_pemesanan_atk/<int:id>', methods=['DELETE'])
def hapus_pemesanan_atk(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:

            # 1️⃣ Ambil nama file foto dulu
            cursor.execute("""
                SELECT foto 
                FROM pemesanan 
                WHERE id = %s AND kategori = 'atk'
            """, (id,)) 
            data = cursor.fetchone()

            if not data:
                return jsonify({"message": f"Barang dengan id {id} tidak ditemukan di atk"}), 404

            foto_filename = data["foto"]

            # 2️⃣ Hapus row di database
            cursor.execute("""
                DELETE FROM pemesanan 
                WHERE id = %s AND kategori = 'atk'
            """, (id,))
            conn.commit()

            # 3️⃣ Hapus file foto (kalau ada)
            if foto_filename:
                file_path = os.path.join("uploads/pemesanan", foto_filename)

                # Cek dulu file-nya ada
                if os.path.exists(file_path):
                    os.remove(file_path)
                    print(f"File {file_path} dihapus.")
                else:
                    print(f"File {file_path} tidak ditemukan, skip delete.")

            return jsonify({
                "message": f"Barang dengan id {id} dan file fotonya berhasil dihapus"
            }), 200

    except Exception as e:
        print("❌ Error:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        conn.close()

@api_bp.route('/hapus_atk/<int:id>', methods=['DELETE'])
def hapus_barang_atk(id):
    conn = get_db_connection()
    if conn is None:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        with conn.cursor(pymysql.cursors.DictCursor) as cursor:

            # 1️⃣ Ambil nama file foto dulu
            cursor.execute("""
                SELECT foto_barang
                FROM barang_masuk 
                WHERE id = %s AND kategori = 'atk'
            """, (id,)) 
            data = cursor.fetchone()

            if not data:
                return jsonify({"message": f"Barang dengan id {id} tidak ditemukan di atk"}), 404

            foto_filename = data["foto_barang"]

            # 2️⃣ Hapus row di database
            cursor.execute("""
                DELETE FROM barang_masuk 
                WHERE id = %s AND kategori = 'atk'
            """, (id,))
            conn.commit()

            # 3️⃣ Hapus file foto (kalau ada)
            if foto_filename:
                file_path = os.path.join("uploads/atk", foto_filename)

                # Cek dulu file-nya ada
                if os.path.exists(file_path):
                    os.remove(file_path)
                    print(f"File {file_path} dihapus.")
                else:
                    print(f"File {file_path} tidak ditemukan, skip delete.")

            return jsonify({
                "message": f"Barang dengan id {id} dan file fotonya berhasil dihapus"
            }), 200

    except Exception as e:
        print("❌ Error:", e)
        return jsonify({"error": str(e)}), 500

    finally:
        conn.close()
