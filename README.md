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

## Kernel

| Arsitektur | Basis | Kernel |
|---|---|---|
| amd64 | Debian 13 (trixie) | `linux-image-amd64` → seri **6.12 LTS** |
| i386 | Debian 12 (bookworm) | `linux-image-686-pae` → seri **6.1 LTS** |

Versi patch yang benar-benar terpasang **tidak dikarang di dokumen ini** — ia
dicatat saat build dan bisa dibaca dari sistem:

    cat /etc/diknom-build      # DIKNOM_KERNEL=<paket> <versi>
    dnfetch                    # baris "Kernel" dan "Paket krn"
    uname -r

i386 tetap di Debian 12 karena Debian 13 tidak lagi menerbitkan kernel dan
userspace i386; itu batas Debian, bukan pilihan kita.

Desktop: amd64 memakai versi terbaru dari trixie (GNOME 48, KDE Plasma 6,
XFCE 4.20, LXQt 2, MATE 1.26, LXDE 0.10).

## Isi khas DikNom OS

- `pkg` — pembungkus `apt` (`pkg update`, `pkg install`, `pkg upgrade`,
  `pkg search`, `pkg doctor`). `apt` tetap tersedia langsung; mesinnya tetap apt.
- `dnfetch` — ringkasan sistem.
- `help` — bantuan bertopik.
- `diknom-about` — menu Tentang yang menyebut penyusun dan menyatakan terus
  terang bahwa fondasinya Debian.
- **Satu-satunya akun di ISO ini: `root` dengan password `root1234`**, dan
  autologin langsung sebagai root. Tidak ada user lain sebelum instalasi.
  Setelah dipasang ke disk, pemilik mesin bebas membuat user sendiri lewat
  Settings atau `useradd`/`passwd` di terminal.
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
