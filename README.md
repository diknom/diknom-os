# DikNom OS

Distro Linux yang **disusun** oleh Dikki Nomiarki di atas Debian — cara kerja
yang sama dengan Ubuntu terhadap Debian, atau Kali dan Parrot terhadap Debian.
Kernel, desktop, dan seluruh paket sistem adalah perangkat lunak yang sudah ada;
DikNom OS memilih, mengonfigurasi, memberi identitas, dan membangun ISO-nya.

## Pilihan desktop

Satu build menghasilkan satu ISO per desktop. Angka RAM di bawah adalah
kebutuhan **desktop itu sendiri**; sistem lengkap dengan kernel dan cache
biasanya perlu lebih.

| Desktop | RAM desktop | Basis | ISO |
|---|---|---|---|
| LXDE | 100-300 MB | Debian 13 (amd64) / 12 (i386) | `diknom-os-lxde-<ver>-<arch>.iso` |
| LXQt | 150-350 MB | Debian 13 | `diknom-os-lxqt-<ver>-<arch>.iso` |
| XFCE | 200-500 MB | Debian 13 / 12 (i386) | `diknom-os-xfce-<ver>-<arch>.iso` |
| MATE | 200-450 MB | Debian 13 | `diknom-os-mate-<ver>-<arch>.iso` |
| KDE Plasma | 300-800 MB | Debian 13 | `diknom-os-kde-<ver>-<arch>.iso` |
| GNOME | 350-700 MB | Debian 13 | `diknom-os-gnome-<ver>-<arch>.iso` |

Delapan ISO per build: enam desktop di amd64, plus XFCE dan LXDE di i386.

Kernel dan desktop versi terbaru: amd64 memakai **Debian 13 (trixie)** — kernel
6.12, GNOME 48, KDE Plasma 6, XFCE 4.20, LXQt 2. i386 tetap di **Debian 12
(bookworm)** karena Debian 13 tidak lagi menerbitkan kernel dan userspace i386.

## Isi khas DikNom OS

- `pkg` — pembungkus `apt` (`pkg update`, `pkg install`, `pkg upgrade`,
  `pkg search`, `pkg doctor`). `apt` tetap tersedia langsung; mesinnya tetap apt.
- `dnfetch` — ringkasan sistem.
- `help` — bantuan bertopik.
- `diknom-about` — menu Tentang yang menyebut penyusun dan menyatakan terus
  terang bahwa fondasinya Debian.
- Autologin user `diknom` (password `diknom`), root password `diknom`.
- Logo DikNom OS di splash boot, layar login (GDM/SDDM/LightDM), dan wallpaper.
- `os-release` bermerek dengan `ID=debian` supaya apt dan alat sistem tetap
  mendeteksi basisnya dengan benar.

## Build

    Actions -> workflow "build" -> matrix 8 (desktop x arch)
      -> live-build (iso-hybrid BIOS+UEFI)
      -> smoke test QEMU: boot, login, pkg update, pkg install jq, jq --version
      -> artifact + Release saat tag v*

## Struktur

    auto/config                 distro & desktop dipilih di sini
    config/package-lists/       satu daftar paket per desktop
    config/hooks/normal/        user, autologin per display manager, branding
    config/includes.chroot/     os-release, motd, pkg, dnfetch, help, about, wallpaper
    config/bootloaders/         splash boot (isolinux)
    branding/                   logo dan splash asli
    tools/smoke-test.py         uji boot: login lewat serial lalu jalankan perintah
    docs/buildroot-arsip.md     rekaman versi "dari source" (Buildroot)

## Riwayat

- **v0.1** — versi Buildroot (dari source), empat ISO, terbukti boot termasuk
  `pkg` dengan repo sendiri. Diarsipkan di branch `buildroot-arsip`,
  tag `buildroot-akhir`, dan `docs/buildroot-arsip.md`.
- **v0.3** — pindah ke fondasi Debian, enam pilihan desktop, `pkg` di atas apt.

## Lisensi

Kode build dan konfigurasi: MIT. Debian dan paket pihak ketiga mengikuti
lisensi masing-masing.
