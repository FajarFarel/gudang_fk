from flask import Flask
from flask_cors import CORS
from endpoint import api_bp
from connetion import get_db_connection
from extensions import bcrypt  # import dari extensions
import os
from flask import Flask, send_from_directory

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploads'
bcrypt.init_app(app)  # inisialisasi bcrypt
CORS(app, resources={r"/*": {"origins": "*"}})

app.register_blueprint(api_bp, url_prefix="/api")


@app.route('/uploads/barang/<path:filename>')
def get_barang_file(filename):
    return send_from_directory(os.path.join(app.config['UPLOAD_FOLDER'], 'barang'), filename)

@app.route('/')
def home():
    return {"message": "Server running with DB connection!"}

if __name__ == '__main__':
    db_conn = get_db_connection()
    if db_conn:
        print("✅ Database connection established.")
        db_conn.close()
        print("🔌 Database connection closed.")
        print("🚀 Starting Flask server...")
        app.run(host="0.0.0.0", port=5000, debug=True)
    else:
        print("❌ Server tidak dijalankan karena koneksi gagal.")
