# Arsip: DikNom OS versi Buildroot (dari source)

Dokumen ini menyimpan pekerjaan **dari source** yang kita bangun sebelum pindah
ke basis Debian. Jangan dihapus: isinya rekaman kesalahan yang sudah dibayar
mahal dengan build 40-80 menit per iterasi.

- Branch kode : `buildroot-arsip`
- Tag puncak  : `buildroot-akhir`  (commit `a3190ed`)
- Rilis ISO   : https://github.com/diknom/diknom-os/releases/tag/v0.1
- Mulai       : 2026-10-25, berakhir 2026-10-26

## Apa yang sudah terbukti bekerja

Keempat varian (Lite musl / normal glibc, x86_64 / i686) lulus uji CI yang
benar-benar masuk ke sistem:

- boot ISO di QEMU sampai prompt login (Lite di 256 MB, normal di 2048 MB)
- login root lewat serial, dapat shell, menjalankan perintah
- `pkg update` mengunduh index repo, `pkg install jq` memasang, `jq-1.8.2` jalan
- ISO terbentuk hibrida BIOS+UEFI lewat grub-mkrescue, El Torito terverifikasi
- menu GRUB bertema logo DikNom OS (VirtualBox, tanpa pesan error)
- X server menyala dengan `modesetting` + DRM `vboxvideo`, latar desktop terpasang
- `devpts` diperbaiki ke `ptmxmode=0666`

Ukuran ISO saat itu: Lite 50 MB (x86_64) / 46 MB (i686), normal 127 MB / 125 MB.

## Yang belum selesai saat diarsipkan

Sesi desktop penuh: `xauth` gagal membuat berkas otorisasi
(`xauth: file /home/diknom/.serverauth.NNN does not exist`) sehingga `startx`
berhenti sebelum window manager muncul. Dugaan terkuat: kepemilikan
`/home/diknom` tertinggal milik root karena `chown` dijalankan di CI non-root
lalu `chmod 0700` sebagai root. Perbaikan yang belum diuji: pindahkan
`XAUTHORITY` ke `/tmp` (sudah ditulis di commit terakhir) dan pastikan
kepemilikan home.

## Semua jebakan yang sudah ditemukan (jangan diulang)

### Buildroot / kconfig
1. `BR2_LINUX_KERNEL_DEFCONFIG` menerima nama **tanpa** akhiran: `x86_64`,
   `i386`. Buildroot menambahkan `_defconfig` sendiri; menulis
   `x86_64_defconfig` menghasilkan `x86_64_defconfig_defconfig` dan gagal.
2. Paket yang juga disediakan BusyBox (vim, less, tar, gzip, wget, procps-ng)
   tidak terlihat sebelum `BR2_PACKAGE_BUSYBOX_SHOW_OTHERS=y`.
3. `BR2_PACKAGE_CURL` tidak ada; gunakan `BR2_PACKAGE_LIBCURL` +
   `BR2_PACKAGE_LIBCURL_CURL`. `BR2_PACKAGE_LIBXCRYPT` sudah hilang di 2024.02.
4. `linux-firmware` tidak punya simbol wifi generik — per perangkat
   (`..._IWLWIFI_7265D`, `_9XXX`, `_6E`, `_QUZ`, ...).
5. Beberapa simbol dideklarasikan `menuconfig`, bukan `config`
   (contoh `BR2_PACKAGE_UTIL_LINUX`); regex pemeriksa harus
   `^\s*(?:menu)?config\s+NAMA\b`.
6. Gerbang `tools/verify-config.sh` membandingkan tiap baris defconfig dengan
   `.config`; ini menangkap opsi yang dibuang kconfig secara diam-diam.

### CPU dan kernel
7. `BR2_x86_corei7` membuat userspace memakai SSE4.2 → `init` mati SIGILL
   (`pcmpistri`, `Attempted to kill init! exitcode=4`) di CPU tanpa SSE4.2,
   termasuk QEMU default. Gunakan `BR2_x86_x86_64` (baseline SSE2) dan
   `BR2_x86_i686` untuk 32-bit.
8. Initramfs tidak punya modprobe: driver NIC dan DRM harus `=y`, bukan modul.
9. Tanpa driver DRM tidak ada `/dev/dri/card0`, dan `modesetting` mati dengan
   "no screens found". Driver yang dipakai: `vboxvideo`, `vmwgfx`, `bochs`,
   `virtio-gpu`, `i915`, `simpledrm`.
10. `vmwgfx` menolak VirtualBox ("unsupported hypervisor"); di VirtualBox pakai
    controller `VBoxVGA` (driver `vboxvideo`), bukan VMSVGA.

### X11
11. `xf86-video-fbdev` 0.5.0 tidak kompatibel dengan Xorg 21.1+ (fbdevhw dihapus
    dari server) → "Error relocating ... symbol not found".
12. Buildroot memasang `/etc/init.d/S40xorg` yang menyalakan X telanjang saat
    boot; hasilnya layar hitam tanpa WM. Hapus di post-build kalau sesi
    dikelola sendiri.
13. BusyBox init tidak membaca `/etc/hostname` → prompt menjadi `(none) login:`.
    Jalankan `hostname -F /etc/hostname` dari init script.
14. Autologin harus lewat `getty -n -l <skrip>`, bukan redirect `</dev/tty1`,
    supaya tty menjadi controlling terminal (kalau tidak: "can't access tty;
    job control turned off" dan X/xauth gagal).
15. udev me-mount `/dev/pts` dengan `ptmxmode=000` → `/dev/ptmx` tidak bisa
    dibuka user biasa dan `xterm` mengulang `open ttydev: I/O error`.
    Remount: `mount -o remount,gid=5,mode=0620,ptmxmode=0666 devpts /dev/pts`.
16. Xorg butuh setuid (`chmod 4755 /usr/bin/Xorg`) untuk dinyalakan user biasa
    tanpa systemd/logind.

### CI / GitHub Actions
17. Windows tidak menyimpan bit executable. Skrip ter-commit 644 dan build mati
    di `target-finalize` dengan `Permission denied`/`Error 126`. Rekam mode di
    index (`git update-index --chmod=+x`) dan `chmod +x` di CI.
18. `chown` di post-build gagal (`Operation not permitted`) karena runner bukan
    root. Atur kepemilikan saat boot dari init script.
19. `actions/cache` tidak menyimpan cache dari job yang gagal; tambahkan
    `actions/cache/save` dengan `if: always()` supaya iterasi berikutnya cepat.
20. `grub-mkrescue` hanya mencetak `error: xorriso invocation failed`; opsi
    setelah `--` masuk ke mode mkisofs (di sana `-application` tidak valid,
    padahal `-A`). Jangan buang outputnya ke `/dev/null`.
21. Uji boot jangan pakai grep prompt: stdio QEMU ke berkas bersifat
    block-buffered dan baris getty bisa diawali CR. Pakai socket serial dan
    benar-benar login lalu jalankan perintah (`tools/smoke-test.py`).
22. Di bawah `concurrency` dengan `cancel-in-progress: false`, setiap push
    menggantikan run yang *pending*; tiga push cepat = tiga pembatalan dan satu
    build. Kumpulkan perbaikan dalam satu commit.

## Cara melanjutkan kalau nanti mau diteruskan

```sh
git fetch --all
git checkout buildroot-arsip     # atau: git checkout buildroot-akhir
# pipeline: .github/workflows/build.yml, dua produk x dua arsitektur
# konfigurasi: board/diknom/{lite,normal}/{x86_64,i686}/*_defconfig
# gerbang:     tools/verify-config.sh
# uji boot:    tools/smoke-test.py
```

Titik lanjut yang paling dekat: perbaiki kepemilikan `/home/diknom` saat boot
lalu buktikan sesi X dengan fluxbox di VirtualBox (controller `VBoxVGA`).

## Kenapa akhirnya pindah ke Debian

Buildroot tidak menyediakan XFCE, GNOME, maupun GTK3 sebagai desktop
environment, dan `apt` tidak mungkin ada. Untuk OS yang dipakai kerja dan harus
bisa "install apapun lewat terminal", jalur menyusun di atas Debian 12 jauh
lebih realistis — sama seperti Ubuntu terhadap Debian. Karya Buildroot ini
disimpan sebagai bukti dan sebagai varian "dari source" yang bisa dilanjutkan.
