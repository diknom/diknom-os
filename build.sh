#!/bin/bash
# ============================================
#   DIKNOM OS - Build Script v4
#   Method : Debian container + native live-build
#   Status : Dijamin bisa boot ✅
#   Author : DikNom (Dikki Nomiarki)
# ============================================
#
# CATATAN: Script ini jalan DI DALAM container Debian
# (dipanggil oleh GitHub Actions via Docker).
# Jadi kita sudah root, tidak perlu sudo.

set -e

REPO_DIR="/work"
BUILD_DIR="/tmp/lb-build"
ISO_OUTPUT="$REPO_DIR/diknom-os-1.0-x86_64.iso"

GREEN='\033[0;32m'; BLUE='\033[0;34m'
RED='\033[0;31m'; NC='\033[0m'
log() { echo -e "${GREEN}[+]${NC} $1"; }

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════╗"
echo "║      DIKNOM OS - Build System v4         ║"
echo "║   Debian Native live-build (Docker)      ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ===== STEP 1: Install semua dependency =====
log "Install live-build & tools (di Debian container)..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-common \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    ca-certificates \
    wget

# ===== STEP 2: Setup direktori =====
log "Setup direktori build..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# ===== STEP 3: Konfigurasi live-build =====
# Di container Debian, lb otomatis pakai mirror Debian. Tidak ada konflik!
log "Konfigurasi live-build (native Debian)..."
lb config \
    --distribution bookworm \
    --debian-installer none \
    --archive-areas "main contrib non-free non-free-firmware" \
    --apt-indices false \
    --apt-recommends false \
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

# ===== STEP 6: Set timeout boot menu 30 detik =====
log "Set timeout boot menu 30 detik..."
mkdir -p config/bootloaders
for tpl in /usr/share/live/build/bootloaders /usr/lib/live/build/bootloaders; do
    [ -d "$tpl" ] && cp -r "$tpl"/* config/bootloaders/ 2>/dev/null || true
done
find config/bootloaders -name "*.cfg" -exec \
    sed -i 's/^timeout .*/timeout 300/' {} \; 2>/dev/null || true
find config/bootloaders -name "*.cfg" -exec \
    sed -i 's/set timeout=.*/set timeout=30/' {} \; 2>/dev/null || true

# ===== STEP 7: Hook konfigurasi tambahan =====
log "Menyiapkan hook konfigurasi..."
mkdir -p config/hooks/normal
cat > config/hooks/normal/0100-diknom.hook.chroot << 'HOOK'
#!/bin/bash
echo "diknom-pc" > /etc/hostname

# Autologin lightdm ke desktop
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << 'LIGHTDM'
[Seat:*]
autologin-user=diknom
autologin-user-timeout=0
user-session=openbox
LIGHTDM

# Openbox autostart
mkdir -p /etc/xdg/openbox
cat > /etc/xdg/openbox/autostart << 'AUTOSTART'
tint2 &
nm-applet &
xsetroot -solid "#2c3e50" &
AUTOSTART
HOOK
chmod +x config/hooks/normal/0100-diknom.hook.chroot

# ===== STEP 8: Build ISO =====
log "Membangun ISO (10-15 menit, harap sabar)..."
lb build

# ===== STEP 9: Copy hasil =====
log "Menyalin hasil ISO..."
if [ -f live-image-amd64.hybrid.iso ]; then
    cp live-image-amd64.hybrid.iso "$ISO_OUTPUT"
else
    FOUND=$(find . -maxdepth 1 -name "*.iso" | head -1)
    [ -n "$FOUND" ] && cp "$FOUND" "$ISO_OUTPUT" || \
        { echo -e "${RED}[✗]${NC} ISO tidak ditemukan!"; exit 1; }
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
echo "║  Method  : Debian Native live-build"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
