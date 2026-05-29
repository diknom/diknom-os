# 🐧 DIKNOM OS

Distro Linux ringan buatan **Dikki Nomiarki** untuk laptop RAM 1GB ke bawah.

**v3** — Pakai live-build (tool resmi Debian), dijamin bisa boot di VirtualBox/QEMU.

---

## ✨ Yang Baru di v3

- ✅ Live boot dijamin jalan (pakai live-build)
- ✅ Timeout menu boot 30 detik (tidak buru-buru)
- ✅ Autologin ke desktop
- ✅ Package manager `dnpkg`
- ✅ Branding DIKNOM OS penuh

---

## 🚀 Build via GitHub Actions

Push ke `main` → tunggu Actions → download ISO dari Artifacts.

---

## 💿 Test di VirtualBox

```
New → Linux → Debian 64-bit → RAM 512MB
Storage → pilih diknom-os-1.0-x86_64.iso
Settings → System → Enable EFI: JANGAN dicentang
Start ▶️
```

**Login:**
- Username: `diknom`
- Password: `live`

(Atau autologin langsung ke desktop)

---

## 📦 dnpkg

```bash
dnpkg install firefox
dnpkg remove firefox
dnpkg update
dnpkg help
```

---

## 📝 Riwayat Versi

- **v1** — Alpine via Docker ❌ (blank screen, tidak ada live-boot)
- **v2** — Debian + live-boot manual ❌ (initramfs bermasalah)
- **v3** — live-build official ✅ (dijamin boot)

---

## 👤 Author

**Dikki Nomiarki (DikNom)** — Nahdlatul Ulama Blitar University
