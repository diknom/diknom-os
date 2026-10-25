#!/usr/bin/env bash
# DikNom OS - pastikan defconfig kita tidak diam-diam dibuang kconfig.
# Pemakaian: tools/verify-config.sh <defconfig> <.config>
set -uo pipefail

DEFCONFIG="$1"
CONFIG="$2"
MISSING=0
CHECKED=0

while IFS= read -r line; do
    case "$line" in
        ''|'#'*) continue ;;
    esac
    KEY="${line%%=*}"
    CHECKED=$((CHECKED + 1))
    if ! grep -qxF -- "$line" "$CONFIG"; then
        # nilai bisa dinormalisasi kconfig (mis. BR2_TARGET_GENERIC_ROOT_PASSWD)
        if grep -q "^${KEY}=" "$CONFIG"; then
            echo "BEDA  $line   (di .config: $(grep "^${KEY}=" "$CONFIG" | head -1))"
        else
            echo "HILANG $line"
        fi
        MISSING=$((MISSING + 1))
    fi
done < "$DEFCONFIG"

echo "diperiksa: $CHECKED opsi, bermasalah: $MISSING"
if [ "$MISSING" -ne 0 ]; then
    echo "GAGAL: ada opsi yang tidak diterima Buildroot. Perbaiki sebelum build."
    exit 1
fi
echo "OK: semua opsi defconfig diterima"
