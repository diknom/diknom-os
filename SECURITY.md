# Keamanan

## Prinsip

Repo ini publik. Aturan keras:

1. **Tidak ada kredensial di repo.** Tidak ada token, password, SSH key,
   API key, atau sertifikat. `.env` dilarang (lihat `.gitignore`).
2. **Kredensial CI hanya lewat GitHub Secrets**, tidak pernah ditulis ke file,
   tidak pernah di-echo ke log.
3. **`.env.example` hanya berisi nama variabel kosong**, tanpa nilai asli.
4. Build memakai `GITHUB_TOKEN` bawaan Actions. Tidak ada secret tambahan yang
   dibutuhkan untuk membangun ISO.

## Default v0.1 (live ISO)

| Hal | Nilai | Alasan |
|---|---|---|
| Autologin | **root** | ISO live harus langsung bisa dipakai; ganti dengan `passwd` |
| Password root | `root1234` | standar live ISO; hanya konsol lokal, tidak ada layanan jaringan |
| Layanan jaringan | tidak ada (sshd mati) | permukaan serangan nol |
| SSH | tidak diinstal | ditambahkan nanti sebagai paket opsional |

Hanya ada akun `root` (password `root1234`) dengan autologin. Ini pilihan sadar
untuk ISO live: tidak ada layanan jaringan, tidak ada ssh, dan seluruh sesi
berjalan lokal. Karena desktop berjalan sebagai root, beberapa aplikasi
GNOME/KDE dapat menampilkan peringatan — itu wajar dan tidak merusak sistem.
Untuk build berikutnya default ini akan dibuat bisa diubah saat boot.

## Melaporkan masalah

Buka issue di repo ini. Untuk temuan sensitif, jangan tulis detail exploit di
issue publik — kirim ringkasannya dulu, detail menyusul lewat kanal privat.

## Cakupan

Dalam cakupan: konfigurasi build, init script, `pkg`, `dnfetch`, kebijakan
default ISO. Di luar cakupan: kerentanan di upstream kernel/Buildroot/paket
pihak ketiga — laporkan ke upstream masing-masing.
