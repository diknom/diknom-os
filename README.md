# 🐧 DIKNOM OS

Distro Linux ringan buatan **Dikki Nomiarki** untuk laptop RAM 1GB ke bawah.

**v4** — Pakai Docker container Debian + live-build native. Dijamin bisa boot.

---

## 🔑 PENTING: Cara Update yang Benar

⚠️ JANGAN klik "Re-run" di GitHub — itu pakai kode lama!
✅ Harus PUSH kode baru biar build.sh terbaru yang jalan.

```bash
cd ~
rm -rf diknom-os-v4
unzip -o diknom-os-v4.zip
cp -rf diknom-os-v4/. diknom-os/
cd diknom-os

# WAJIB cek build.sh sudah versi v4:
head -8 build.sh
# Harus muncul tulisan "Build System v4"

git add .
git commit -m "v4 - Debian container build"
git push
```

Setelah push, buka Actions → harus ada run BARU (bukan re-run lama).

---

## ✨ Yang Baru di v4

- ✅ Docker Debian container → live-build native (mirror Debian otomatis)
- ✅ Tidak ada konflik Ubuntu/Debian lagi
- ✅ Timeout menu boot 30 detik
- ✅ Autologin ke desktop
- ✅ Package manager `dnpkg`

---

## 💿 Test di VirtualBox

```
New → Linux → Debian 64-bit → RAM 512MB
Storage → pilih diknom-os-1.0-x86_64.iso
System → Enable EFI: JANGAN dicentang
Start ▶️
```

Login: `diknom` / `live` (atau autologin)

---

## 📝 Riwayat Versi

- **v1** — Alpine Docker ❌ (tidak ada live-boot)
- **v2** — Debian manual ❌ (initramfs bermasalah)
- **v3** — live-build Ubuntu ❌ (mirror Ubuntu ≠ bookworm)
- **v4** — Docker Debian native ✅ (semua benar)

---

## 👤 Author

**Dikki Nomiarki (DikNom)** — Nahdlatul Ulama Blitar University
