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
| 0.2 | X11 + window manager (fluxbox/twm), sesi desktop otomatis, input lewat udev+libinput |
| 0.3 | Rasa `work`: gcc/make/git/python/pip/node/ssh/tmux + terminal nyaman |
| 0.4 | Repo paket `.dnp` sendiri (index di GitHub Releases) + `pkg install` dari repo |
| 1.0 | Installer ke disk, dua rasa rilis stabil, uji boot di perangkat nyata |

## Repo paket (mulai v0.2)

`pkg` punya repo online sendiri di `repo/index.tab` dalam repo ini.

    pkg update              unduh index
    pkg search <kata>       cari paket
    pkg install <nama>      pasang dari repo
    pkg upgrade             perbarui paket terpasang

Isi repo adalah **biner statis** (tanpa interpreter dinamis, tanpa referensi
glibc), jadi satu paket jalan di Lite (musl) maupun di DikNom OS normal
(glibc). Setiap unduhan diverifikasi sha256; kalau hash tidak cocok, paket
ditolak. Verifikasi ini yang jadi jaminan integritas, bukan sertifikat TLS.

Kenapa bukan apt/apk: keduanya terikat basis distro masing-masing. Paket
`.deb` butuh dpkg + glibc Debian, `.apk` butuh apk-tools + repo Alpine. Untuk
OS yang dibangun dari source, satu-satunya jalan jujur adalah repo sendiri.

Cakupan paket saat ini kecil dan tidak saya lebihkan: `jq`, `fzf`, `rg`.
Untuk i686 hanya `jq`, karena fzf dan ripgrep tidak lagi menerbitkan biner
32-bit. Menambah paket = menambah baris index + sha256 yang sudah diverifikasi.

## Sesi grafis (mulai v0.2)

Login di tty1 langsung menyalakan X lewat `/etc/profile.d/diknom-gui.sh`.
Window manager dipilih saat runtime: `fluxbox` kalau ada (DikNom OS normal),
`twm` kalau tidak (Lite). Kalau X gagal, konsol tetap hidup di tty2 dan ttyS0 —
kegagalan grafis tidak boleh mengunci mesin.

## Baseline CPU

Semua ISO dibangun untuk instruksi paling dasar: x86-64 baseline (SSE2) untuk
64-bit dan i686 untuk 32-bit. Alasannya bukan kerapian — versi sebelumnya
dibangun dengan `-march=corei7` dan `init` langsung mati SIGILL di CPU tanpa
SSE4.2. Konsekuensinya: beberapa persen performa ditinggal di meja CPU modern,
ditukar dengan jaminan boot di mesin lama.

## Batas nyata

- 256 MB cukup untuk ISO live + GUI ringan + aplikasi inti. LibreOffice,
  Chromium, GIMP tidak akan jalan di 256 MB — itu batas fisik, bukan pilihan.
- i686 (32-bit): Chromium/Firefox tidak lagi punya binary 32-bit. Versi 32-bit
  memakai Netsurf/Dillo/Links2.
- v0.1 belum punya GUI. GUI masuk di 0.2 supaya tiap langkah bisa diverifikasi.

## Lisensi

Kode build dan konfigurasi: MIT. Kernel dan paket pihak ketiga mengikuti
lisensi masing-masing.
