# 🐧 DIKNOM OS

Distro Linux buatan Dikki Nomiarki, berbasis Debian + LXDE.

v8 — Desktop dipercantik + banyak aplikasi + installer ke disk.

## CATATAN UKURAN

- RAM tetap ringan (idle ~250MB) - app cuma makan RAM saat dibuka
- ISO jadi BESAR (~2-2.5GB) karena banyak app dibundel
- Build ~20-30 menit (download banyak paket)

## Cara Update (PUSH, jangan Re-run!)

cd ~
cp /sdcard/Download/diknom-os-v8.zip ~/
unzip -o diknom-os-v8.zip
cp -rf diknom-os-v8/. diknom-os/
cd diknom-os
head -6 build.sh
git add .
git commit -m "v8 - Banyak app + installer"
git push

## Aplikasi yang Disertakan

Browser: Chromium
Office: LibreOffice (Writer, Calc, Impress)
Grafis: GIMP
Media: VLC
Programming: Python 3 + IDLE
Editor: Mousepad (notepad)
Kalkulator: Galculator
Game: Chess, Sudoku
Windows apps: Wine
Font: Microsoft Core Fonts
System: Task Manager (lxtask), System Monitor
Settings: lxappearance (tema), Synaptic (package manager)
About: Tentang DIKNOM OS

## Tema

- Arc-Dark (tema gelap modern)
- Papirus-Dark (icon set bagus)

## Installer ke Disk

- Calamares (installer grafis)
- Ada di menu, untuk install DIKNOM OS permanen ke hardisk

## Login

- Autologin ke desktop, atau:
- User: diknom  Password: diknom

## Author
Dikki Nomiarki (DikNom) - Nahdlatul Ulama Blitar University
