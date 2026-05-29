# 🐧 DIKNOM OS

Distro Linux ringan buatan Dikki Nomiarki untuk laptop RAM 1GB ke bawah.

v7 — Desktop LENGKAP pakai LXDE (ada start menu, taskbar, icon, wallpaper).

## Cara Update (PUSH, jangan Re-run!)

cd ~
cp /sdcard/Download/diknom-os-v7.zip ~/
unzip -o diknom-os-v7.zip
cp -rf diknom-os-v7/. diknom-os/
cd diknom-os
head -6 build.sh
git add .
git commit -m "v7 - Desktop LXDE lengkap"
git push

## Yang Baru di v7

- Ganti Openbox polos -> LXDE (desktop lengkap out-of-the-box)
- Ada start menu, taskbar, system tray, jam, file manager
- Wallpaper biru DIKNOM (bukan hitam kosong)
- Autologin ke desktop LXDE
- Tetap ringan untuk RAM 1GB (idle ~220MB)

## Login

- Autologin ke desktop, atau manual:
- User: diknom  Password: diknom

## Riwayat

- v6 — Openbox jalan tapi terlalu polos (cuma panel kosong)
- v7 — LXDE, desktop lengkap dengan menu & icon

## Author
Dikki Nomiarki (DikNom)
