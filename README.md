# 🐧 DIKNOM OS

Distro Linux buatan Dikki Nomiarki, berbasis Debian + LXDE.

v9 — Fix tombol window (minimize/maximize/close) yang sebelumnya hilang.

## Cara Update (PUSH, jangan Re-run!)

cd ~
cp /sdcard/Download/diknom-os-v9.zip ~/
unzip -o diknom-os-v9.zip
cp -rf diknom-os-v9/. diknom-os/
cd diknom-os
head -6 build.sh
git add .
git commit -m "v9 - Fix tombol window"
git push

## Yang Diperbaiki di v9

- Tombol minimize, maximize, close SEKARANG MUNCUL di semua window
- Konfigurasi Openbox lengkap (titleLayout NLIMC + tema Arc-Dark)
- Tambahan shortcut keyboard:
  - Alt+F4 = tutup window
  - Alt+Tab = ganti window
  - Win+E = file manager
  - Win+T = terminal
  - Ctrl+Alt+Kiri/Kanan = pindah desktop
- Klik kanan di desktop = menu aplikasi

## Semua App dari v8 Tetap Ada

Chromium, LibreOffice, GIMP, VLC, Python, Wine, Game (chess/sudoku),
kalkulator, notepad, MS fonts, installer Calamares, dll.

## Login

- Autologin ke desktop, atau:
- User: diknom  Password: diknom

## Author
Dikki Nomiarki (DikNom) - Nahdlatul Ulama Blitar University
