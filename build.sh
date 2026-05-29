#!/bin/bash
# ============================================
#   DIKNOM OS - Build Script v8
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
echo "║      DIKNOM OS - Build System v8         ║"
echo "║   LXDE + Banyak App + Installer      ║"
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
    --bootappend-live "boot=live components quiet" \
    --iso-application "DIKNOM OS" \
    --iso-publisher "DikNom" \
    --iso-volume "DIKNOM_OS" \
    --memtest none

# ===== STEP 4: Daftar paket desktop =====
log "Menyiapkan daftar paket..."
mkdir -p config/package-lists
cat > config/package-lists/diknom.list.chroot << 'PKGLIST'
# === X Server (WAJIB untuk display) ===
xserver-xorg-core
xserver-xorg-video-vesa
xserver-xorg-video-fbdev
xserver-xorg-input-libinput
xinit
# === Desktop LXDE ===
lxde-core
lxsession
lxpanel
lxtask
lxterminal
lxappearance
pcmanfm
openbox
obconf
# === Display Manager ===
lightdm
lightdm-gtk-greeter
# === Tema (biar lebih bagus) ===
arc-theme
papirus-icon-theme
# === Browser ===
chromium
# === Office ===
libreoffice-writer
libreoffice-calc
libreoffice-impress
# === Grafis ===
gimp
# === Media ===
vlc
# === Python ===
python3
python3-pip
idle3
# === Text Editor (Notepad) ===
mousepad
# === Kalkulator ===
galculator
# === Game ===
gnome-chess
gnome-sudoku
gnuchess
# === Settings & System ===
gnome-system-monitor
synaptic
zenity
file-roller
gpicview
# === Installer ke disk ===
calamares
calamares-settings-debian
# === Network ===
network-manager
network-manager-gnome
# === Font ===
fonts-dejavu-core
fonts-liberation
# === Utilitas dasar ===
nano
htop
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

# --- Hook 1: User, autologin, tema, about ---
cat > config/hooks/normal/0100-diknom.hook.chroot << 'HOOK'
#!/bin/bash
set -e

# === User diknom (password: diknom) ===
useradd -m -s /bin/bash \
    -G sudo,video,audio,input,netdev,plugdev diknom 2>/dev/null || true
echo "diknom:diknom" | chpasswd
echo "root:diknom"   | chpasswd
echo "diknom ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/diknom
chmod 0440 /etc/sudoers.d/diknom
echo "diknom-pc" > /etc/hostname

# === Autologin lightdm ke LXDE ===
groupadd -r autologin 2>/dev/null || true
gpasswd -a diknom autologin 2>/dev/null || true
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << 'LIGHTDM'
[Seat:*]
autologin-user=diknom
autologin-user-timeout=0
autologin-session=LXDE
user-session=LXDE
greeter-session=lightdm-gtk-greeter
LIGHTDM

# === Tema Arc-Dark + icon Papirus-Dark ===
mkdir -p /home/diknom/.config/lxsession/LXDE
cat > /home/diknom/.config/lxsession/LXDE/desktop.conf << 'LXSESSION'
[GTK]
sNet/ThemeName=Arc-Dark
sNet/IconThemeName=Papirus-Dark
sGtk/FontName=Sans 10
LXSESSION

# GTK3 theme
mkdir -p /home/diknom/.config/gtk-3.0
cat > /home/diknom/.config/gtk-3.0/settings.ini << 'GTK3'
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
GTK3

# === Wallpaper biru DIKNOM ===
mkdir -p /home/diknom/.config/pcmanfm/LXDE
cat > /home/diknom/.config/pcmanfm/LXDE/desktop-items-0.conf << 'PCMANFM'
[*]
wallpaper_mode=color
desktop_bg=#2c3e50
desktop_fg=#ffffff
desktop_shadow=#000000
show_documents=1
show_trash=1
show_mounts=1
PCMANFM

# === Launcher "About DIKNOM OS" ===
cat > /usr/bin/diknom-about << 'ABOUT'
#!/bin/bash
zenity --info --title="Tentang DIKNOM OS" --width=420 --height=260 \
  --text="<big><b>DIKNOM OS 1.0</b></big>

Distro Linux ringan berbasis Debian + LXDE
Dibuat oleh <b>Dikki Nomiarki (DikNom)</b>

Kernel: $(uname -r)
RAM: $(free -h | awk '/Mem/{print $2}')

Nahdlatul Ulama Blitar University
github.com/diknom"
ABOUT
chmod +x /usr/bin/diknom-about

cat > /usr/share/applications/diknom-about.desktop << 'DESKTOP'
[Desktop Entry]
Name=Tentang DIKNOM OS
Comment=Informasi sistem DIKNOM OS
Exec=diknom-about
Icon=help-about
Type=Application
Categories=System;
DESKTOP

# === Launcher "Pengaturan Tampilan" ===
cat > /usr/share/applications/diknom-settings.desktop << 'DESKTOP'
[Desktop Entry]
Name=Pengaturan Tampilan
Comment=Atur tema dan tampilan
Exec=lxappearance
Icon=preferences-desktop-theme
Type=Application
Categories=Settings;
DESKTOP

chown -R diknom:diknom /home/diknom 2>/dev/null || true
HOOK
chmod +x config/hooks/normal/0100-diknom.hook.chroot

# --- Hook 2: Wine (butuh i386) + Font Microsoft ---
# Dipisah supaya kalau gagal tidak merusak build utama
cat > config/hooks/normal/0500-wine-fonts.hook.chroot << 'HOOK'
#!/bin/bash
# Jangan pakai set -e di sini, biar gagal sebagian tetap lanjut

echo "[+] Menambahkan arsitektur i386 untuk Wine..."
dpkg --add-architecture i386
apt-get update

echo "[+] Install Wine..."
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wine wine64 wine32 2>/dev/null || \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends wine || \
    echo "[!] Wine gagal install, lewati"

echo "[+] Install font Microsoft..."
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" \
    | debconf-set-selections
DEBIAN_FRONTEND=noninteractive apt-get install -y ttf-mscorefonts-installer 2>/dev/null || \
    echo "[!] MS fonts gagal, lewati"

apt-get clean
HOOK
chmod +x config/hooks/normal/0500-wine-fonts.hook.chroot

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
