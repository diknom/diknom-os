#!/bin/bash
# ============================================
#   DIKNOM OS - Build Script
#   Versi  : 1.0
#   Author : DikNom (Dikki Nomiarki)
# ============================================

set -e

# ===== KONFIGURASI =====
OS_NAME="DIKNOM OS"
OS_VERSION="1.0"
ALPINE_VERSION="3.19"
ISO_OUTPUT="diknom-os-1.0-x86_64.iso"
BUILD_DIR="/tmp/diknom-build"
LIVE_USER="diknom"
LIVE_PASS="diknom"

# ===== WARNA =====
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
err()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# ===== BANNER =====
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║        DIKNOM OS - Build System          ║"
echo "║         Versi 1.0 - Blitar Edition       ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ===== STEP 1: Siapkan direktori =====
log "Menyiapkan direktori build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{rootfs,iso/{boot/grub,live}}

# ===== STEP 2: Buat Dockerfile Alpine =====
log "Membuat Dockerfile Alpine..."
cat > "$BUILD_DIR/Dockerfile" << 'DOCKERFILE'
FROM alpine:3.19

# Setup repository
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.19/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.19/community" >> /etc/apk/repositories && \
    apk update && apk upgrade

# Install paket inti sistem
RUN apk add --no-cache \
    bash bash-completion \
    openrc \
    shadow sudo doas \
    util-linux e2fsprogs

# Install desktop
RUN apk add --no-cache \
    xorg-server \
    xf86-video-vesa xf86-video-fbdev \
    xf86-input-libinput \
    xinit \
    openbox tint2 feh \
    lightdm lightdm-gtk-greeter

# Install aplikasi
RUN apk add --no-cache \
    pcmanfm mousepad \
    xterm \
    nano htop neofetch \
    wget curl \
    networkmanager \
    ttf-dejavu ttf-liberation

# Install kernel
RUN apk add --no-cache linux-lts

# Setup service otomatis
RUN rc-update add lightdm default && \
    rc-update add networkmanager default

# Buat live user (diknom/diknom)
RUN adduser -D -s /bin/bash -g "DIKNOM User" diknom && \
    echo "diknom:diknom" | chpasswd && \
    adduser diknom wheel && \
    adduser diknom video && \
    adduser diknom audio && \
    adduser diknom input && \
    adduser diknom netdev && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

DOCKERFILE

# ===== STEP 3: Build Docker image =====
log "Membangun rootfs via Docker (mungkin agak lama)..."
docker build -t diknom-builder "$BUILD_DIR/"

# ===== STEP 4: Export rootfs =====
log "Mengekspor rootfs..."
docker create --name diknom-instance diknom-builder
docker export diknom-instance -o "$BUILD_DIR/rootfs.tar"
docker rm diknom-instance

# ===== STEP 5: Ekstrak rootfs =====
log "Mengekstrak rootfs..."
sudo tar xf "$BUILD_DIR/rootfs.tar" -C "$BUILD_DIR/rootfs/"

# ===== STEP 6: Copy kustomisasi DIKNOM OS =====
log "Menerapkan kustomisasi DIKNOM OS..."
if [ -d "rootfs" ]; then
    sudo cp -r rootfs/. "$BUILD_DIR/rootfs/"
fi

# Set permission script
for bin in dnpkg dnfetch dn-update help; do
    [ -f "$BUILD_DIR/rootfs/usr/bin/$bin" ] && \
        sudo chmod +x "$BUILD_DIR/rootfs/usr/bin/$bin"
done

# ===== STEP 7: Copy kernel & initramfs =====
log "Menyiapkan boot files..."
KERNEL=$(sudo find "$BUILD_DIR/rootfs/boot" -name "vmlinuz*" | sort | tail -1)
INITRAMFS=$(sudo find "$BUILD_DIR/rootfs/boot" -name "initramfs*" | sort | tail -1)

[ -z "$KERNEL" ] && err "Kernel tidak ditemukan! Cek instalasi linux-lts."

sudo cp "$KERNEL" "$BUILD_DIR/iso/boot/vmlinuz"
sudo cp "$INITRAMFS" "$BUILD_DIR/iso/boot/initramfs.img"

log "Kernel: $KERNEL"
log "Initramfs: $INITRAMFS"

# ===== STEP 8: Buat squashfs =====
log "Membuat squashfs (ini butuh waktu)..."
sudo mksquashfs "$BUILD_DIR/rootfs" \
    "$BUILD_DIR/iso/live/filesystem.squashfs" \
    -comp xz -Xbcj x86 -b 1M -noappend \
    -e boot proc sys dev run tmp

# ===== STEP 9: Konfigurasi GRUB =====
log "Membuat konfigurasi GRUB..."
cat > "$BUILD_DIR/iso/boot/grub/grub.cfg" << 'GRUBCFG'
set default=0
set timeout=5
set timeout_style=menu

set color_normal=white/black
set color_highlight=black/white

menuentry "DIKNOM OS 1.0 - Live" {
    linux  /boot/vmlinuz root=/dev/ram0 \
           modules=loop,squashfs,sd-mod,usb-storage \
           quiet loglevel=0
    initrd /boot/initramfs.img
}

menuentry "DIKNOM OS 1.0 - Safe Mode" {
    linux  /boot/vmlinuz root=/dev/ram0 \
           modules=loop,squashfs,sd-mod,usb-storage \
           nomodeset
    initrd /boot/initramfs.img
}

menuentry "Reboot" {
    reboot
}

menuentry "Matikan (Shutdown)" {
    halt
}
GRUBCFG

# ===== STEP 10: Buat ISO =====
log "Membuat file ISO..."
sudo grub-mkrescue \
    -o "$ISO_OUTPUT" \
    "$BUILD_DIR/iso" \
    -- -volid "DIKNOM_OS_10"

# ===== SELESAI =====
ISO_SIZE=$(du -sh "$ISO_OUTPUT" | cut -f1)
echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║           BUILD BERHASIL! 🎉             ║"
echo "╠══════════════════════════════════════════╣"
echo "║  File    : $ISO_OUTPUT"
echo "║  Ukuran  : $ISO_SIZE"
echo "║  User    : diknom"
echo "║  Password: diknom"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
