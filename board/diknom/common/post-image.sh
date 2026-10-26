#!/usr/bin/env bash
# DikNom OS - membuat ISO hybrid (BIOS + UEFI) dari kernel + initramfs.
set -euo pipefail

BINARIES_DIR="$1"
ARCH="${DIKNOM_ARCH:-x86_64}"
VER="${DIKNOM_VERSION:-0.1}"
FLAVOR="${DIKNOM_FLAVOR:-normal}"
HERE="$(cd "$(dirname "$0")" && pwd)"
if [ "$FLAVOR" = "lite" ]; then
    PRODUCT="diknom-os-lite"
    LABEL=" Lite"
else
    PRODUCT="diknom-os"
    LABEL=""
fi
ISO_NAME="${PRODUCT}-${VER}-${ARCH}.iso"

command -v grub-mkrescue >/dev/null || {
    echo "post-image: grub-mkrescue tidak ada. Pasang grub-pc-bin grub-efi-amd64-bin grub-efi-ia32-bin xorriso mtools" >&2
    exit 1
}
[ -f "$BINARIES_DIR/bzImage" ] || { echo "post-image: bzImage tidak ada" >&2; exit 1; }

ISOROOT="$(mktemp -d)"
trap 'rm -rf "$ISOROOT"' EXIT
mkdir -p "$ISOROOT/boot/grub/theme"
cp "$BINARIES_DIR/bzImage" "$ISOROOT/boot/vmlinuz"

# identitas boot: splash + tema menu
if [ -f "$HERE/boot/splash.png" ]; then
    cp "$HERE/boot/splash.png" "$ISOROOT/boot/grub/theme/splash.png"
else
    echo "post-image: splash.png tidak ada, menu tampil tanpa latar" >&2
fi
[ -f "$HERE/boot/theme/theme.txt" ] && cp "$HERE/boot/theme/theme.txt" "$ISOROOT/boot/grub/theme/theme.txt"

if [ -f "$BINARIES_DIR/rootfs.cpio.gz" ]; then
    cp "$BINARIES_DIR/rootfs.cpio.gz" "$ISOROOT/boot/initrd.img"
elif [ -f "$BINARIES_DIR/rootfs.cpio" ]; then
    gzip -9 -c "$BINARIES_DIR/rootfs.cpio" > "$ISOROOT/boot/initrd.img"
else
    echo "post-image: initramfs tidak ditemukan" >&2; exit 1
fi

sed "s/@VERSION@/$VER/; s/@ARCH@/$ARCH/; s/@LABEL@/$LABEL/" "$HERE/grub.cfg" > "$ISOROOT/boot/grub/grub.cfg"

GRUB_LOG="$(mktemp)"
# Tanpa opsi tambahan: argumen setelah '--' diteruskan ke xorriso dan itu yang
# membuat pemanggilan gagal di runner. Volume ID default sudah cukup.
if ! grub-mkrescue -o "$BINARIES_DIR/$ISO_NAME" "$ISOROOT" >"$GRUB_LOG" 2>&1; then
    echo "post-image: grub-mkrescue GAGAL" >&2
    tail -n 40 "$GRUB_LOG" >&2
    echo "--- isi ISOROOT ---" >&2
    find "$ISOROOT" -maxdepth 3 >&2
    exit 1
fi
rm -f "$GRUB_LOG"

# ISO tanpa catatan El Torito tidak akan bisa boot; gagalkan di sini, bukan di QEMU.
if command -v xorriso >/dev/null; then
    if xorriso -indev "$BINARIES_DIR/$ISO_NAME" -report_el_torito plain 2>/dev/null \
            | grep -q "El Torito"; then
        echo "post-image: El Torito terverifikasi (BIOS/UEFI boot record ada)"
    else
        echo "post-image: PERINGATAN tidak menemukan catatan El Torito di ISO" >&2
    fi
fi

ls -lh "$BINARIES_DIR/$ISO_NAME"
echo "post-image: $ISO_NAME selesai"
