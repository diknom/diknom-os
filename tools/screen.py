"""Ambil screenshot framebuffer QEMU lewat monitor socket.

Dipakai saat smoke test: kalau serial bisu, satu-satunya cara tahu apa yang
terjadi adalah melihat layar (SeaBIOS / syslinux / panic).
"""
import socket
import sys
import time

sock_path, out = sys.argv[1], sys.argv[2]

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(10)
s.connect(sock_path)
time.sleep(0.5)
try:
    s.recv(4096)
except OSError:
    pass

s.sendall(("screendump %s\n" % out).encode())
time.sleep(1.0)
try:
    reply = s.recv(4096).decode("utf-8", "replace").strip()
    print("monitor: " + reply)
except OSError:
    print("monitor: (tanpa balasan)")
