# DikNom OS - mulai sesi grafis otomatis di layar fisik (tty1)
#
# Hanya di tty1 dan hanya kalau belum ada sesi X, supaya login lewat serial
# (ttyS0) atau tty2 tetap konsol teks dan tidak menyalakan X dua kali.
if [ -z "$DISPLAY" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    if [ -x /usr/bin/startx ]; then
        startx -- -keeptty
        # Kalau sampai di sini, sesi X berakhir atau gagal: tampilkan bukti.
        echo ""
        echo "=== Diagnosa sesi X ==="
        echo "-- perangkat grafis --"
        ls -l /dev/dri 2>&1 | sed 's/^/   /'
        ls -l /dev/fb* 2>&1 | sed 's/^/   /'
        echo "-- driver kernel --"
        grep -iE "drm|fb0|vboxvideo|vmwgfx|i915" /proc/modules 2>/dev/null | cut -d' ' -f1 | sed 's/^/   /'
        echo "-- baris penting Xorg.0.log --"
        grep -E "Loading|Failed to load|modesetting|card0|ScreenInit|no screens|EE" /var/log/Xorg.0.log 2>/dev/null | tail -20 | sed 's/^/   /'
        echo "======================="
        echo ""
    fi
fi
