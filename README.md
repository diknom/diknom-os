# 🐧 DIKNOM OS

**DIKNOM OS** adalah distro Linux ringan buatan **Dikki Nomiarki**,
dirancang untuk laptop RAM 1GB ke bawah.

**v2** - Sekarang berbasis Debian Bookworm Minimal + live-boot
(fix: blank screen saat boot di VirtualBox/QEMU)

---

## ✨ Fitur

- Live boot berfungsi penuh ✅
- Package manager sendiri: **dnpkg**
- Command `help` Bahasa Indonesia
- Desktop Openbox (ringan & cepat)
- RAM idle ~200–250MB

---

## 🚀 Build via GitHub Actions

Setiap push ke `main` → ISO otomatis dibuild.

```
Actions → build terbaru → Artifacts → diknom-os-iso → download
```

---

## 💿 Test di VirtualBox

```
New → Linux → Other Linux 64-bit → RAM 512MB
Storage → pilih diknom-os-1.0-x86_64.iso
Start ▶️
```

Login: `diknom` / `diknom`

---

## 📦 dnpkg

```bash
dnpkg install firefox
dnpkg remove firefox
dnpkg update
dnpkg search browser
dnpkg doctor
dnpkg help
```

---

## 👤 Author

**Dikki Nomiarki (DikNom)**
Nahdlatul Ulama Blitar University
