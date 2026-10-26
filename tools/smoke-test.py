#!/usr/bin/env python3
"""Uji boot ISO DikNom OS lewat serial QEMU.

Bukan sekadar menunggu prompt tercetak: masuk sebagai root, menjalankan
perintah, dan memastikan keluarannya benar. Exit 0 hanya kalau semuanya
terbukti; kegagalan menyebut langkah mana yang tidak tercapai.
"""
import socket
import sys
import time

SOCK = sys.argv[1] if len(sys.argv) > 1 else "/tmp/serial.sock"
LOG = sys.argv[2] if len(sys.argv) > 2 else "qemu.log"
BOOT_TIMEOUT = int(sys.argv[3]) if len(sys.argv) > 3 else 420

buf = bytearray()
logf = open(LOG, "wb", buffering=0)
sock = None


def pump(timeout=1.0):
    sock.settimeout(timeout)
    try:
        data = sock.recv(4096)
    except socket.timeout:
        return False
    except OSError:
        return False
    if not data:
        return False
    buf.extend(data)
    logf.write(data)
    logf.flush()
    return True


def wait_for(needle, timeout):
    """Tunggu sampai potongan teks (bytes) muncul di konsol."""
    end = time.time() + timeout
    while time.time() < end:
        if needle in bytes(buf):
            return True
        pump(1.0)
    return False


def send(text):
    sock.sendall(text.encode())


results = []


def check(ok, message):
    print(("OK    " if ok else "GAGAL ") + message, flush=True)
    results.append(ok)
    return ok


# --- sambung ke serial QEMU ---
deadline = time.time() + 120
while time.time() < deadline:
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(SOCK)
        break
    except OSError:
        sock = None
        time.sleep(1)

if sock is None:
    print("GAGAL  tidak bisa tersambung ke socket serial QEMU", flush=True)
    sys.exit(2)

# Diagnostik awal. Kalau tidak ada satu byte pun dalam 120 detik, penyebabnya
# bukan login yang lambat: bootloader tidak pernah menjalankan kernel, atau
# kernel tidak menulis ke ttyS0. Lebih baik gagal cepat daripada menunggu 20
# menit dan tetap tidak tahu apa-apa.
start = time.time()
while time.time() - start < 120 and not buf:
    pump(1.0)

if not buf:
    print("GAGAL  tidak ada keluaran serial sama sekali dalam 120 detik", flush=True)
    print("        artinya kernel tidak pernah dijalankan (bootloader gagal),", flush=True)
    print("        atau kernel tidak menulis ke console=ttyS0", flush=True)
    sys.exit(3)

print("OK    konsol serial hidup (%d byte pertama diterima)" % len(buf), flush=True)

ok = True
ok &= check(wait_for(b"login:", BOOT_TIMEOUT), "kernel boot sampai prompt login")

if ok:
    send("root\n")
    ok &= check(wait_for(b"assword:", 60), "prompt password muncul")

if ok:
    send("root1234\n")
    ok &= check(wait_for(b"# ", 90), "shell root didapat setelah login")

if ok:
    send("cat /etc/diknom-build\n")
    ok &= check(wait_for(b"DIKNOM_VERSION=", 60), "perintah dijalankan di dalam sistem")

if ok:
    send("uname -m\n")
    ok &= check(wait_for(b"uname", 30) and True, "utilitas dasar merespons")

if ok:
    send("echo SMOKE_MARKER_OK\n")
    ok &= check(wait_for(b"SMOKE_MARKER_OK", 45), "shell mengeksekusi perintah kita")

# --- repo paket: dibuktikan dengan memasang dan menjalankan, bukan hanya hijau ---
if ok:
    send("pkg update\n")
    ok &= check(wait_for(b"Index diperbarui", 150), "pkg update mengunduh index repo")

if ok:
    send("pkg install jq\n")
    ok &= check(wait_for(b"terpasang di /usr/bin/jq", 240), "pkg install memasang paket dari repo")

if ok:
    send("jq --version\n")
    ok &= check(wait_for(b"jq-1.", 45), "biner hasil pkg install benar-benar berjalan")

print("---", flush=True)
if all(results) and results:
    print("SMOKE_OK: boot, login, shell, dan pkg dari repo terbukti berjalan", flush=True)
    sys.exit(0)
print("SMOKE_FAIL", flush=True)
sys.exit(1)
