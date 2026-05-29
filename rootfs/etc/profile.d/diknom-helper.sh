#!/bin/sh
# ============================================
#   DIKNOM OS - Command Not Found Handler
# ============================================

command_not_found_handler() {
    CMD="$1"
    ARG="$2"

    case "$CMD" in
        # Kalau ketik h, ?, bantuan, tolong
        h|--h|-h|bantuan|tolong|"?")
            help
            ;;

        # Kalau pakai package manager distro lain
        apt|apt-get)
            echo ""
            echo "  💡 Di DIKNOM OS, gunakan: dnpkg"
            echo "     Contoh: dnpkg $ARG $3"
            echo ""
            ;;
        apk)
            echo ""
            echo "  💡 Di DIKNOM OS, gunakan: dnpkg"
            echo "     Contoh: dnpkg $ARG $3"
            echo ""
            ;;
        pacman|yum|dnf|zypper|pkg)
            echo ""
            echo "  💡 Di DIKNOM OS, gunakan: dnpkg"
            echo "     Contoh: dnpkg $ARG $3"
            echo ""
            ;;

        # Kalau ketik install/remove tanpa dnpkg
        install|remove)
            echo ""
            echo "  💡 Maksud kamu: dnpkg $CMD $ARG ?"
            echo "     Jalankan: dnpkg $CMD $ARG"
            echo ""
            ;;

        # Kalau update doang
        upgrade|update)
            echo ""
            echo "  💡 Untuk update sistem: dnpkg update"
            echo ""
            ;;

        # Default: command tidak dikenal
        *)
            echo ""
            echo "  ❌ Command '$CMD' tidak ditemukan."
            echo "     Ketik 'help' untuk daftar perintah."
            echo "     Atau: dnpkg search $CMD"
            echo ""
            ;;
    esac

    return 127
}
