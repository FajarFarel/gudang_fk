@echo off
echo ====================================
echo Membuka XAMPP Control Panel...
echo ====================================

:: 1️⃣ Buka XAMPP Control Panel GUI
start "" "C:\xampp\xampp-control.exe"

:: Tunggu 10 detik biar XAMPP sempat nyala dulu
echo Menunggu XAMPP siap (10 detik)...
timeout /t 10 >nul


echo ====================================
echo Menjalankan Backend Python...
echo ====================================

:: 2️⃣ Jalankan backend di CMD baru
start cmd /k python run.py

timeout /t 2 >nul

echo ====================================
echo SEMUA SUDAH BERJALAN.
echo ====================================
pause
