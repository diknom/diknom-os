"""Kirim tombol ke QEMU lewat monitor socket.

Boot menu syslinux/live-build menunggu Enter (menu tampil di VGA, bukan di
serial), jadi tes otomatis harus menekannya lewat monitor QEMU.
"""
import socket
import sys
import time

sock_path = sys.argv[1]
keys = sys.argv[2:] or ["ret"]

s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(10)
s.connect(sock_path)
time.sleep(0.5)
try:
    s.recv(4096)
except OSError:
    pass

for k in keys:
    s.sendall(("sendkey %s\n" % k).encode())
    print("kirim: " + k)
    time.sleep(0.7)
