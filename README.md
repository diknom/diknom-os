# 🐧 DIKNOM OS

**DIKNOM OS** adalah distro Linux ringan berbasis Alpine Linux,
dibuat oleh **Dikki Nomiarki** — dirancang untuk laptop dengan RAM 1GB ke bawah.

---

## ✨ Fitur

- Ringan — RAM idle sekitar 150–200MB
- Package manager sendiri: **dnpkg**
- Command help interaktif dalam Bahasa Indonesia
- Command not found handler yang ramah pengguna
- Desktop: Openbox (minimal & cepat)
- Berbasis Alpine Linux (musl libc, bukan systemd)

---

## 🚀 Cara Build ISO

Build otomatis lewat **GitHub Actions** setiap kali ada push ke branch `main`.

### Langkah:
1. Fork / clone repo ini
2. Push ke branch `main`
3. Buka tab **Actions** di GitHub
4. Tunggu build selesai (~10–15 menit)
5. Download ISO dari bagian **Artifacts**

### Build manual (butuh Linux):
```bash
chmod +x build.sh
sudo bash build.sh
```

---

## 💿 Cara Pakai ISO

**Login:**
- Username : `diknom`
- Password : `diknom`

**Test di QEMU (tanpa hardware fisik):**
```bash
qemu-system-x86_64 \
    -m 512M \
    -cdrom diknom-os-1.0-x86_64.iso \
    -boot d \
    -enable-kvm
```

---

## 📦 dnpkg — Package Manager

```bash
dnpkg install firefox     # install aplikasi
dnpkg remove firefox      # hapus aplikasi
dnpkg update              # update semua paket
dnpkg search browser      # cari aplikasi
dnpkg list                # lihat semua yang terinstall
dnpkg doctor              # cek kesehatan sistem
dnpkg store               # buka toko aplikasi
dnpkg help                # bantuan lengkap
```

---

## 🛠️ Struktur Proyek

```
diknom-os/
├── .github/workflows/
│   └── build.yml          ← GitHub Actions otomatis
├── rootfs/
│   ├── etc/
│   │   ├── os-release     ← identitas OS
│   │   ├── hostname       ← nama komputer
│   │   ├── motd           ← pesan setelah login
│   │   ├── issue          ← pesan sebelum login
│   │   └── profile.d/
│   │       ├── diknom-alias.sh    ← alias bawaan
│   │       └── diknom-helper.sh   ← command not found handler
│   └── usr/bin/
│       ├── dnpkg          ← package manager
│       ├── dnfetch        ← info sistem
│       ├── dn-update      ← update sistem
│       └── help           ← pusat bantuan
├── configs/
│   └── packages.list      ← daftar paket default
├── build.sh               ← script build ISO
└── README.md
```

---

## 🧰 Kustomisasi

### Ganti nama/versi OS:
Edit file `rootfs/etc/os-release`

### Tambah aplikasi default:
Edit file `configs/packages.list`

### Ganti wallpaper:
Taruh file gambar di `rootfs/usr/share/diknom/wallpaper.jpg`

### Tambah command baru:
Buat script di `rootfs/usr/bin/` lalu chmod +x

---

## 📋 Requirements Build

- Docker (untuk build rootfs Alpine)
- squashfs-tools
- xorriso
- grub-pc-bin, grub-efi-amd64-bin

Semua sudah otomatis diinstall oleh GitHub Actions.

---

## 👤 Author

**Dikki Nomiarki (DikNom)**
- Nahdlatul Ulama Blitar University
- SMKS Brantas Karangkates
- GitHub: [@diknomiarki](https://github.com/diknomiarki)

---

## 📄 Lisensi

MIT License — bebas digunakan dan dimodifikasi.
