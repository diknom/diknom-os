# DikNom OS - mulai sesi grafis otomatis di layar fisik (tty1)
#
# Hanya di tty1 dan hanya kalau belum ada sesi X, supaya login lewat serial
# (ttyS0) atau tty2 tetap konsol teks dan tidak menyalakan X dua kali.
if [ -z "$DISPLAY" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    [ -x /usr/bin/startx ] || return 0

    LOG=/var/log/diknom-x.log

    # xauth gagal membuat ~/.serverauth.* kalau home tidak bisa ditulis
    # (kepemilikan home diatur saat build oleh user non-root). Simpan cookie
    # di /tmp yang selalu writable, dan pakai /tmp sebagai HOME kalau perlu.
    export XAUTHORITY=/tmp/.diknom-xauth
    : > "$XAUTHORITY" 2>/dev/null && chmod 600 "$XAUTHORITY" 2>/dev/null
    if [ ! -w "${HOME:-/nonexistent}" ]; then
        HOME=/tmp
        export HOME
    fi

    {
        echo "=== sesi X mulai $(date) ==="
        echo "user=$(id -un) home=$HOME xauth=$XAUTHORITY tty=$(tty 2>/dev/null)"
        ls -l /dev/dri /dev/fb* /dev/ptmx 2>&1
        ls -ld "$HOME" 2>&1
    } > "$LOG" 2>&1

    startx -- -keeptty >> "$LOG" 2>&1
    echo "=== sesi X selesai $(date) ===" >> "$LOG"

    echo ""
    echo "=== Diagnosa sesi X (juga di $LOG) ==="
    grep -E "Failed|error|Error|EE|ttydev|No such|no screens|xauth" "$LOG" 2>/dev/null | tail -15
    echo "======================================="
    echo ""
fi
