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
else
    PRODUCT="diknom-os"
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

sed "s/@VERSION@/$VER/; s/@ARCH@/$ARCH/; s/@FLAVOR@/$FLAVOR/" "$HERE/grub.cfg" > "$ISOROOT/boot/grub/grub.cfg"

grub-mkrescue -o "$BINARIES_DIR/$ISO_NAME" "$ISOROOT" \
    -- -volid DIKNOM_OS -application "DikNom OS $VER" >/dev/null

ls -lh "$BINARIES_DIR/$ISO_NAME"
echo "post-image: $ISO_NAME selesai"
