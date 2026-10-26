# DikNom OS - mulai sesi grafis otomatis di layar fisik (tty1)
#
# Hanya di tty1 dan hanya kalau belum ada sesi X, supaya login lewat serial
# (ttyS0) atau tty2 tetap konsol teks dan tidak menyalakan X dua kali.
if [ -z "$DISPLAY" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    if [ -x /usr/bin/startx ]; then
        startx -- -keeptty
    fi
fi
