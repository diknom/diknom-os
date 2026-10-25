# DikNom OS

Distro Linux yang dibangun **dari source**, bukan turunan Debian/Alpine/Ubuntu.
Tidak ada satu pun paket `.deb`/`.apk` di dalam ISO. Semua binary dikompilasi
dari source oleh pipeline kita sendiri.

- Basis build : Buildroot (build system, bukan distro) — pinned branch `2024.02.x` (LTS)
- libc        : musl (bukan glibc)
- Kernel      : Linux 6.6.x, config + fragment milik kita
- init        : BusyBox init + script `/etc/init.d/S*` milik kita
- Paket manager: `pkg` (format `.dnp`), bukan apt/apk
- Arsitektur  : x86_64 dan i686 (32-bit)
- Target RAM  : 256 MB untuk sistem + GUI ringan

## Kenapa Buildroot dan bukan LFS

LFS (Linux From Scratch) adalah cara paling "murni", tapi menulis ulang
toolchain + Xorg + toolkit GUI dari nol tidak muat dalam batas 6 jam per job
GitHub Actions. Buildroot melakukan hal yang sama secara disiplin: setiap
binary dibangun dari source, dengan resep yang bisa diaudit di dalam repo.
Yang tetap milik kita: kernel config, fragment, init, branding, GUI session,
dan paket manager.

Kernel Linux tetap kernel Linux. Tidak ada distro yang menulis kernel dari nol
— Debian dan Ubuntu juga tidak. Yang membedakan distro adalah konfigurasi,
patch, userspace, dan kebijakan.

## Struktur

    board/diknom/
      x86_64/diknom_x86_64_defconfig   konfigurasi build 64-bit
      i686/diknom_i686_defconfig       konfigurasi build 32-bit
      common/kernel-live.fragment      opsi kernel tambahan untuk live ISO
      common/post-build.sh             sentuhan akhir rootfs
      common/post-image.sh             pembuat ISO hybrid BIOS+UEFI
      common/grub.cfg                  menu boot
      common/rootfs-overlay/           seluruh identitas DikNom OS
        etc/                           os-release, motd, inittab, init.d
        usr/bin/                       pkg, dnfetch, help

## Build

Build terjadi di GitHub Actions, tidak di laptop:

    Actions -> workflow "build" -> matrix [x86_64, i686]
      -> clone Buildroot 2024.02.x
      -> make diknom_<arch>_defconfig
      -> make  (toolchain + kernel + rootfs dari source)
      -> post-image.sh -> diknom-os-<ver>-<arch>.iso  (BIOS + UEFI)
      -> smoke test QEMU -m 256  (harus sampai prompt login)
      -> artifact + Release

Setiap tag `v*` menerbitkan Release berisi kedua ISO, jadi tautannya permanen
(tidak ikut kedaluwarsa seperti artifact 30 hari).

## Dua produk, empat ISO

| Produk | libc | RAM | Sasaran | Nama ISO |
|---|---|---|---|---|
| DikNom OS Lite | musl | di bawah 256 MB | komputer tua, prosesor generasi awal | `diknom-os-lite-<ver>-<arch>.iso` |
| DikNom OS | glibc | minimum 2 GB | mesin kerja harian, programmer | `diknom-os-<ver>-<arch>.iso` |

`<arch>` = `x86_64` atau `i686`. Semua dari pohon source yang sama.

Kenapa dua libc: Lite butuh sekecil mungkin, dan musl memberi itu. DikNom OS
normal butuh tool dev yang sudah jadi — Node.js resmi, banyak Python wheel,
dan binary Rust pra-kompilasi semuanya menargetkan glibc; dengan musl semuanya
harus dikompilasi sendiri.

## Roadmap

| Versi | Isi |
|---|---|
| 0.1 | ISO boot di 256 MB, init sendiri, shell, dnfetch/help/pkg lokal, gerbang verifikasi config |
| 0.2 | X11 + window manager ringan, sesi desktop otomatis, wifi (rasa work) |
| 0.3 | Rasa `work`: gcc/make/git/python/pip/node/ssh/tmux + terminal nyaman |
| 0.4 | Repo paket `.dnp` sendiri (index di GitHub Releases) + `pkg install` dari repo |
| 1.0 | Installer ke disk, dua rasa rilis stabil, uji boot di perangkat nyata |

## Batas nyata

- 256 MB cukup untuk ISO live + GUI ringan + aplikasi inti. LibreOffice,
  Chromium, GIMP tidak akan jalan di 256 MB — itu batas fisik, bukan pilihan.
- i686 (32-bit): Chromium/Firefox tidak lagi punya binary 32-bit. Versi 32-bit
  memakai Netsurf/Dillo/Links2.
- v0.1 belum punya GUI. GUI masuk di 0.2 supaya tiap langkah bisa diverifikasi.

## Lisensi

Kode build dan konfigurasi: MIT. Kernel dan paket pihak ketiga mengikuti
lisensi masing-masing.
