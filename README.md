# 🐧 DIKNOM OS

Distro Linux ringan buatan Dikki Nomiarki untuk laptop RAM 1GB ke bawah.

v6 — Berbasis v4 yang terbukti boot, ditambah user fix + autologin.

## Cara Update (PUSH, jangan Re-run!)

cd ~
cp /sdcard/Download/diknom-os-v6.zip ~/
unzip -o diknom-os-v6.zip
cp -rf diknom-os-v6/. diknom-os/
cd diknom-os
head -6 build.sh
git add .
git commit -m "v6 - User fix + autologin"
git push

## Yang Baru di v6 (vs v4)

- Tetap pakai lightdm + components (yang bikin v4 berhasil boot)
- TAMBAH: user diknom dibuat saat build (password PASTI jalan)
- TAMBAH: autologin lightdm ke diknom
- Perubahan minimal dari v4 = risiko kecil

## Login

- Autologin ke desktop, atau manual:
- User: diknom  Password: diknom
- Root: root  Password: diknom

## Riwayat

- v4 — boot ke login screen (X jalan) tapi password gagal
- v5 — ganti startx, malah blank (terlalu banyak perubahan)
- v6 — balik ke v4 + cuma fix user/login

## Author
Dikki Nomiarki (DikNom)
