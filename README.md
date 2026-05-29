# 🐧 DIKNOM OS

Distro Linux ringan buatan **Dikki Nomiarki** untuk laptop RAM 1GB ke bawah.

**v5** — Autologin langsung ke desktop, tanpa password ribet.

---

## 🔑 Cara Update (PUSH, jangan Re-run!)

```bash
cd ~
cp /sdcard/Download/diknom-os-v5.zip ~/
unzip -o diknom-os-v5.zip
cp -rf diknom-os-v5/. diknom-os/
cd diknom-os

# Cek build.sh sudah v5:
head -8 build.sh

git add .
git commit -m "v5 - Autologin desktop tanpa password"
git push
```

---

## Yang Baru di v5

- Autologin langsung ke desktop Openbox (tidak ada login screen)
- Tidak perlu password saat boot
- Lebih ringan (lightdm dihapus, pakai startx)
- User dibuat saat build, password PASTI jalan

## Login (kalau perlu manual)

- User: diknom  Password: diknom
- Root: root  Password: diknom

## Author

Dikki Nomiarki (DikNom) - Nahdlatul Ulama Blitar University
