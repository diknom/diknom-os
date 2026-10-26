# DikNom OS - mulai sesi grafis otomatis di layar fisik (tty1)
#
# Hanya di tty1 dan hanya kalau belum ada sesi X, supaya login lewat serial
# (ttyS0) atau tty2 tetap konsol teks dan tidak menyalakan X dua kali.
if [ -z "$DISPLAY" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    if [ -x /usr/bin/startx ]; then
        LOG=/var/log/diknom-x.log
        echo "=== sesi X mulai $(date) ===" > "$LOG"
        ls -l /dev/dri >> "$LOG" 2>&1
        ls -l /dev/fb* >> "$LOG" 2>&1
        ls -l /dev/ptmx /dev/pts >> "$LOG" 2>&1
        startx -- -keeptty >> "$LOG" 2>&1
        echo "=== sesi X selesai $(date) ===" >> "$LOG"

        # tampilkan ringkasan di layar supaya tidak pernah "layar kosong tanpa sebab"
        echo ""
        echo "=== Diagnosa sesi X (juga di $LOG) ==="
        grep -E "Failed|error|Error|EE|ttydev|No such|no screens" "$LOG" 2>/dev/null | tail -15
        echo "======================================="
        echo ""
    fi
fi
