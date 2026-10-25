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
| Autologin | user `diknom` di tty1 | ISO live harus langsung bisa dipakai |
| Password root | `diknom` | hanya untuk konsol lokal, tidak ada layanan jaringan |
| Layanan jaringan | tidak ada (sshd mati) | permukaan serangan nol |
| SSH | tidak diinstal | ditambahkan nanti sebagai paket opsional |

`diknom` tidak punya sudo dan tidak bisa jadi root tanpa password root.
Untuk build berikutnya default ini akan dibuat bisa diubah saat boot.

## Melaporkan masalah

Buka issue di repo ini. Untuk temuan sensitif, jangan tulis detail exploit di
issue publik — kirim ringkasannya dulu, detail menyusul lewat kanal privat.

## Cakupan

Dalam cakupan: konfigurasi build, init script, `pkg`, `dnfetch`, kebijakan
default ISO. Di luar cakupan: kerentanan di upstream kernel/Buildroot/paket
pihak ketiga — laporkan ke upstream masing-masing.
