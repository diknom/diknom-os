# DikNom OS - mulai sesi grafis otomatis di layar fisik (tty1)
#
# Hanya di tty1 dan hanya kalau belum ada sesi X, supaya login lewat serial
# (ttyS0) atau tty2 tetap konsol teks dan tidak menyalakan X dua kali.
if [ -z "$DISPLAY" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    if [ -x /usr/bin/startx ]; then
        startx -- -keeptty
        # Kalau sampai sini berarti sesi X berakhir/gagal; tampilkan sebabnya.
        echo ""
        echo "Sesi X berakhir. Kalau gagal start, 20 baris terakhir log:"
        tail -n 20 /var/log/Xorg.0.log 2>/dev/null || echo "  (/var/log/Xorg.0.log tidak ada)"
        echo ""
    fi
fi
