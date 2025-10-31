# Flask Hosting App

## Overview
Aplikasi Flask yang sudah dikonfigurasi untuk hosting di Replit. Proyek ini menyediakan struktur dasar untuk hosting aplikasi Flask dengan konfigurasi production-ready menggunakan Gunicorn sebagai WSGI server.

## Recent Changes
- **31 Oktober 2025**: Setup awal aplikasi Flask dengan:
  - Struktur proyek Flask lengkap (main.py, templates, static files)
  - Dependencies production (Flask 3.0.0, Gunicorn 21.2.0)
  - Workflow configuration untuk development dan production
  - Deployment configuration untuk Replit hosting
  - Template HTML dan styling dasar

## Project Architecture

### Struktur File
```
.
├── main.py              # Entry point aplikasi Flask
├── requirements.txt     # Dependencies Python
├── templates/           # Template HTML
│   └── index.html      # Homepage
├── static/             # File statis
│   ├── css/
│   │   └── style.css   # Styling
│   └── js/
│       └── script.js   # JavaScript
└── .gitignore          # Git ignore file
```

### Technology Stack
- **Framework**: Flask 3.0.0
- **WSGI Server**: Gunicorn 21.2.0
- **Python**: 3.11
- **Environment**: Replit NixOS

### Key Features
- Production-ready WSGI server (Gunicorn)
- Health check API endpoint (`/api/health`)
- Info API endpoint (`/api/info`)
- Responsive web interface
- Environment variable support
- Secret management dengan SESSION_SECRET

## Running the Application

### Development Mode
Aplikasi akan otomatis berjalan melalui workflow Replit dengan Gunicorn.

### Production Deployment
1. Klik tombol "Publish" di Replit
2. Aplikasi akan di-deploy menggunakan konfigurasi autoscale
3. URL public akan tersedia untuk akses

## API Endpoints

- **GET /** - Homepage
- **GET /api/health** - Health check endpoint
- **GET /api/info** - Application information

## Environment Variables

- `SESSION_SECRET` - Secret key untuk Flask sessions (sudah dikonfigurasi di Replit)
- `PORT` - Port untuk aplikasi (default: 5000)
- `FLASK_ENV` - Environment mode

## Customization Guide

### Mengganti Aplikasi dengan Kode Anda
1. Ganti isi `main.py` dengan aplikasi Flask Anda
2. Update `requirements.txt` jika ada dependencies tambahan
3. Jalankan `pip install -r requirements.txt`
4. Restart workflow

### Menambah Routes
Edit `main.py` dan tambahkan route baru:
```python
@app.route('/your-route')
def your_function():
    return 'Your response'
```

### Menambah Template
Buat file HTML baru di folder `templates/` dan render dengan:
```python
return render_template('your-template.html')
```

## User Preferences
- Bahasa: Indonesia
- Framework: Flask
- Server: Gunicorn (production-ready)
- Deployment: Replit autoscale

## Notes
- Port 5000 digunakan untuk web preview di Replit
- Gunicorn dengan 2 workers untuk handle concurrent requests
- Timeout 120 detik untuk long-running requests
- Host binding ke 0.0.0.0 untuk accessibility dari Replit proxy
