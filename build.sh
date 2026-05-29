#!/bin/bash
# ============================================
#   DIKNOM OS - Build Script v3
#   Tool   : live-build (official Debian)
#   Status : Dijamin bisa boot
#   Author : DikNom (Dikki Nomiarki)
# ============================================

set -e

REPO_DIR="$(pwd)"
BUILD_DIR="/tmp/lb-build"
ISO_OUTPUT="$REPO_DIR/diknom-os-1.0-x86_64.iso"

GREEN='\033[0;32m'; BLUE='\033[0;34m'
RED='\033[0;31m'; NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║      DIKNOM OS - Build System v3         ║"
echo "║   live-build - Dijamin Bisa Boot ✅      ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ===== STEP 1: Install live-build =====
log "Install live-build..."
sudo apt-get update -qq
sudo apt-get install -y live-build

# ===== STEP 2: Setup direktori =====
log "Setup direktori build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# ===== STEP 3: Konfigurasi live-build =====
log "Konfigurasi live-build..."
lb config \
    --distribution bookworm \
    --debian-installer none \
    --archive-areas "main contrib non-free non-free-firmware" \
    --bootappend-live "boot=live components username=diknom hostname=diknom-pc quiet" \
    --iso-application "DIKNOM OS" \
    --iso-publisher "DikNom" \
    --iso-volume "DIKNOM_OS" \
    --memtest none

# ===== STEP 4: Daftar paket desktop =====
log "Menyiapkan daftar paket..."
mkdir -p config/package-lists
cat > config/package-lists/diknom.list.chroot << 'PKGLIST'
xserver-xorg-core
xserver-xorg-video-vesa
xserver-xorg-video-fbdev
xserver-xorg-input-libinput
xinit
openbox
obconf
tint2
feh
lightdm
lightdm-gtk-greeter
pcmanfm
mousepad
xterm
nano
htop
neofetch
network-manager
network-manager-gnome
fonts-dejavu-core
sudo
bash-completion
PKGLIST

# ===== STEP 5: Tambah file kustom DIKNOM OS =====
log "Menambahkan file DIKNOM OS..."
mkdir -p config/includes.chroot/usr/bin
mkdir -p config/includes.chroot/etc/profile.d

cp "$REPO_DIR/rootfs/usr/bin/dnpkg"     config/includes.chroot/usr/bin/
cp "$REPO_DIR/rootfs/usr/bin/dnfetch"   config/includes.chroot/usr/bin/
cp "$REPO_DIR/rootfs/usr/bin/dn-update" config/includes.chroot/usr/bin/
cp "$REPO_DIR/rootfs/usr/bin/help"      config/includes.chroot/usr/bin/
cp "$REPO_DIR/rootfs/etc/profile.d/diknom-alias.sh"  config/includes.chroot/etc/profile.d/
cp "$REPO_DIR/rootfs/etc/profile.d/diknom-helper.sh" config/includes.chroot/etc/profile.d/
cp "$REPO_DIR/rootfs/etc/os-release" config/includes.chroot/etc/os-release
cp "$REPO_DIR/rootfs/etc/motd"       config/includes.chroot/etc/motd
cp "$REPO_DIR/rootfs/etc/issue"      config/includes.chroot/etc/issue

chmod +x config/includes.chroot/usr/bin/*

# ===== STEP 6: Set timeout boot menu jadi 30 detik =====
log "Set timeout boot menu 30 detik..."
mkdir -p config/bootloaders

# Copy template bootloader (lokasi bisa beda antar versi)
for tpl in /usr/share/live/build/bootloaders /usr/lib/live/build/bootloaders; do
    [ -d "$tpl" ] && cp -r "$tpl"/* config/bootloaders/ 2>/dev/null || true
done

# Set timeout isolinux (satuan 1/10 detik → 300 = 30 detik)
find config/bootloaders -name "*.cfg" -exec \
    sed -i 's/^timeout .*/timeout 300/' {} \; 2>/dev/null || true

# Set timeout grub (satuan detik)
find config/bootloaders -name "*.cfg" -exec \
    sed -i 's/set timeout=.*/set timeout=30/' {} \; 2>/dev/null || true

# ===== STEP 7: Hook setup tambahan =====
log "Menyiapkan hook konfigurasi..."
mkdir -p config/hooks/normal
cat > config/hooks/normal/0100-diknom.hook.chroot << 'HOOK'
#!/bin/bash
# Set hostname
echo "diknom-pc" > /etc/hostname

# Autologin lightdm ke user diknom
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << 'LIGHTDM'
[Seat:*]
autologin-user=diknom
autologin-user-timeout=0
user-session=openbox
LIGHTDM

# Setup openbox autostart - jalankan tint2 & wallpaper
mkdir -p /etc/xdg/openbox
cat > /etc/xdg/openbox/autostart << 'AUTOSTART'
tint2 &
nm-applet &
feh --bg-fill /usr/share/diknom/wallpaper.jpg 2>/dev/null || xsetroot -solid "#2c3e50" &
AUTOSTART
HOOK
chmod +x config/hooks/normal/0100-diknom.hook.chroot

# ===== STEP 8: Build ISO =====
log "Membangun ISO (10-15 menit, harap sabar)..."
sudo lb build

# ===== STEP 9: Copy hasil =====
log "Menyalin hasil ISO..."
if [ -f live-image-amd64.hybrid.iso ]; then
    cp live-image-amd64.hybrid.iso "$ISO_OUTPUT"
else
    # Cari file ISO apapun yang dihasilkan
    FOUND=$(find . -maxdepth 1 -name "*.iso" | head -1)
    [ -n "$FOUND" ] && cp "$FOUND" "$ISO_OUTPUT"
fi

# ===== SELESAI =====
SIZE=$(du -sh "$ISO_OUTPUT" | cut -f1)
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║           BUILD BERHASIL! 🎉             ║"
echo "╠══════════════════════════════════════════╣"
echo "║  File    : diknom-os-1.0-x86_64.iso"
echo "║  Ukuran  : $SIZE"
echo "║  Login   : diknom / live"
echo "║  Timeout : 30 detik"
echo "║  Tool    : live-build (Debian official)"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
