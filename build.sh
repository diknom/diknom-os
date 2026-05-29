#!/bin/bash
# ============================================
#   DIKNOM OS - Build Script v2
#   Base   : Debian Bookworm Minimal
#   Fix    : Live boot support (live-boot pkg)
#   Author : DikNom (Dikki Nomiarki)
# ============================================

set -e

ISO_OUTPUT="diknom-os-1.0-x86_64.iso"
BUILD_DIR="/tmp/diknom-build"

# Warna
GREEN='\033[0;32m'; BLUE='\033[0;34m'
RED='\033[0;31m'; NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }
err() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║      DIKNOM OS - Build System v2         ║"
echo "║      Debian Live Base - Fixed Boot       ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ===== STEP 1: Install tools =====
log "Install build tools..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    debootstrap squashfs-tools xorriso \
    grub-pc-bin grub-efi-amd64-bin mtools wget

# ===== STEP 2: Setup direktori =====
log "Setup direktori build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{rootfs,iso/{boot/grub,live}}

# ===== STEP 3: Debian minimal base =====
log "Membangun Debian Bookworm minimal base..."
log "(Ini butuh ~5 menit, harap tunggu)"
sudo debootstrap \
    --arch=amd64 \
    --variant=minbase \
    --include=systemd-sysv,apt,bash,locales \
    bookworm \
    "$BUILD_DIR/rootfs/" \
    http://deb.debian.org/debian/

# ===== STEP 4: Setup chroot =====
log "Menyiapkan chroot environment..."
sudo cp /etc/resolv.conf "$BUILD_DIR/rootfs/etc/resolv.conf"

for fs in proc sys dev dev/pts; do
    sudo mount --bind /$fs "$BUILD_DIR/rootfs/$fs"
done

cleanup() {
    for fs in dev/pts dev sys proc; do
        sudo umount -lf "$BUILD_DIR/rootfs/$fs" 2>/dev/null || true
    done
}
trap cleanup EXIT

# ===== STEP 5: Install paket =====
log "Install kernel, live-boot, dan desktop..."
sudo chroot "$BUILD_DIR/rootfs" /bin/bash << 'CHROOT'
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq

# WAJIB: kernel + live boot support
apt-get install -y --no-install-recommends \
    linux-image-amd64 \
    live-boot \
    live-config \
    live-config-systemd \
    initramfs-tools

# Desktop minimal
apt-get install -y --no-install-recommends \
    xorg \
    xserver-xorg-video-vesa \
    xserver-xorg-video-fbdev \
    openbox \
    tint2 \
    feh \
    lightdm \
    lightdm-gtk-greeter \
    pcmanfm \
    mousepad \
    xterm \
    nano \
    htop \
    network-manager \
    fonts-dejavu-core \
    sudo \
    bash-completion

# Buat user diknom
useradd -m -s /bin/bash -G sudo,video,audio,input,netdev diknom
echo "diknom:diknom" | chpasswd
echo "diknom ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Hostname
echo "diknom-pc" > /etc/hostname

# Bersihkan cache
apt-get clean
rm -rf /var/lib/apt/lists/*
CHROOT

# ===== STEP 6: Apply kustomisasi DIKNOM OS =====
log "Menerapkan kustomisasi DIKNOM OS..."
sudo cp -r rootfs/. "$BUILD_DIR/rootfs/"
for f in dnpkg dnfetch dn-update help; do
    [ -f "$BUILD_DIR/rootfs/usr/bin/$f" ] && \
        sudo chmod +x "$BUILD_DIR/rootfs/usr/bin/$f"
done

# ===== STEP 7: Copy kernel & initrd =====
# Debian live-boot pakai folder /live/ bukan /boot/
log "Copy boot files ke /live/..."
sudo cp "$BUILD_DIR/rootfs/boot/vmlinuz-"* \
    "$BUILD_DIR/iso/live/vmlinuz"
sudo cp "$BUILD_DIR/rootfs/boot/initrd.img-"* \
    "$BUILD_DIR/iso/live/initrd"

# ===== STEP 8: Buat squashfs =====
log "Membuat squashfs filesystem..."
log "(Ini butuh beberapa menit)"
sudo mksquashfs "$BUILD_DIR/rootfs" \
    "$BUILD_DIR/iso/live/filesystem.squashfs" \
    -comp xz -noappend \
    -e boot proc sys dev run tmp

# ===== STEP 9: GRUB config =====
# Kunci: "boot=live" adalah trigger untuk Debian live-boot
log "Membuat GRUB config..."
cat > "$BUILD_DIR/iso/boot/grub/grub.cfg" << 'GRUBCFG'
set default=0
set timeout=5
set color_normal=white/black
set color_highlight=black/white

menuentry "DIKNOM OS 1.0 - Live Boot" {
    linux  /live/vmlinuz boot=live quiet splash
    initrd /live/initrd
}

menuentry "DIKNOM OS 1.0 - Safe Mode" {
    linux  /live/vmlinuz boot=live nomodeset
    initrd /live/initrd
}

menuentry "Reboot" { reboot }
menuentry "Shutdown" { halt }
GRUBCFG

# ===== STEP 10: Build ISO =====
log "Membuat file ISO..."
sudo grub-mkrescue \
    -o "$ISO_OUTPUT" \
    "$BUILD_DIR/iso" \
    -- -volid "DIKNOM_OS_10"

# ===== SELESAI =====
SIZE=$(du -sh "$ISO_OUTPUT" | cut -f1)
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║           BUILD BERHASIL! 🎉             ║"
echo "╠══════════════════════════════════════════╣"
echo "║  File    : $ISO_OUTPUT"
echo "║  Ukuran  : $SIZE"
echo "║  Login   : diknom / diknom"
echo "║  Base    : Debian Bookworm Minimal"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
