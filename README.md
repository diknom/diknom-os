# DikNom OS

Distro Linux yang **disusun** oleh Dikki Nomiarki di atas fondasi Debian 12
(bookworm) — cara kerja yang sama dengan Ubuntu terhadap Debian, atau Kali dan
Parrot terhadap Debian. Kernel, XFCE/LXDE, dan seluruh paket sistem adalah
perangkat lunak yang sudah ada; DikNom OS memilih, mengonfigurasi, memberi
identitas, dan membangun ISO-nya.

## Dua produk, empat ISO

| Produk | Desktop | RAM | Nama ISO |
|---|---|---|---|
| DikNom OS | GNOME | 4 GB (nyaman) / 2 GB minimal | `diknom-os-<ver>-<arch>.iso` |
| DikNom OS Lite | XFCE | 1 GB (nyaman) / 512 MB minimal | `diknom-os-lite-<ver>-<arch>.iso` |

`<arch>` = `amd64` atau `i386`.

Kenapa GNOME hanya di versi normal: GNOME 43 di Debian 12 butuh memori dan
akselerasi grafis yang layak (minimal 2 GB, nyaman 4 GB). Di VM tanpa 3D ia
turun ke llvmpipe (software) — jalan, tapi lambat. Lite memakai XFCE supaya
masih wajar di 1 GB. Kalau mesinmu kuat, GNOME di laptop Intel seperti i3-6006U
berjalan normal dengan driver i915.

## Isi khas DikNom OS

- `pkg` — pembungkus `apt` dengan keluaran seragam (`pkg update`, `pkg install`,
  `pkg upgrade`, `pkg search`, `pkg doctor`). `apt` tetap tersedia langsung.
- `dnfetch` — ringkasan sistem bergaya DikNom.
- `help` — bantuan bertopik (paket, jaringan, tampilan).
- `diknom-about` — menu "Tentang DikNom OS" yang menyebut penyusunnya dan
  menyatakan terus terang bahwa fondasinya Debian.
- Autologin user `diknom` (password `diknom`), root password `diknom`.
- Wallpaper, motd, issue, dan `os-release` bermerek DikNom OS.
- GRUB bertema logo DikNom OS (lihat `branding/`).

## Build

Semua build di GitHub Actions, bukan di laptop.

    Actions -> workflow "build" -> matrix [normal|lite] x [amd64|i386]
      -> live-build (Debian 12 bookworm, iso-hybrid BIOS+UEFI)
      -> diknom-os[-lite]-<ver>-<arch>.iso
      -> smoke test QEMU: boot, login, `pkg update`, `pkg install jq`, `jq --version`
      -> artifact + Release saat tag v*

Tag `v*` menerbitkan Release berisi keempat ISO dengan tautan permanen.

## Struktur

    auto/config                     konfigurasi live-build (rasa & arsitektur)
    config/package-lists/           daftar paket per rasa
    config/hooks/normal/            user, autologin, branding, versi
    config/includes.chroot/         os-release, motd, pkg, dnfetch, help, about
    branding/                       logo dan splash untuk GRUB
    tools/smoke-test.py             uji boot: login lewat serial lalu jalankan perintah
    docs/buildroot-arsip.md         rekaman versi "dari source" (Buildroot)

## Riwayat

- **v0.1** — DikNom OS versi Buildroot (dari source). Empat ISO terbit dan
  terbukti boot, termasuk `pkg` dengan repo sendiri. Diarsipkan, tidak dihapus:
  lihat `docs/buildroot-arsip.md` dan branch `buildroot-arsip`.
- **v0.2/v0.3** — pindah ke fondasi Debian, desktop XFCE/LXDE, `pkg` di atas apt.

## Lisensi

Kode build dan konfigurasi: MIT. Debian dan seluruh paket pihak ketiga
mengikuti lisensi masing-masing.
