#!/usr/bin/env bash
# DikNom OS - sentuhan akhir rootfs sebelum diimage.
set -euo pipefail

TARGET_DIR="$1"
[ -d "$TARGET_DIR" ] || { echo "post-build: TARGET_DIR tidak ada: $TARGET_DIR" >&2; exit 1; }

# --- user diknom (uid 1000) ---
grep -q '^diknom:' "$TARGET_DIR/etc/passwd" || \
    echo 'diknom:x:1000:1000:DikNom User:/home/diknom:/bin/sh' >> "$TARGET_DIR/etc/passwd"
grep -q '^diknom:' "$TARGET_DIR/etc/group" || \
    echo 'diknom:x:1000:' >> "$TARGET_DIR/etc/group"
if ! grep -q '^diknom:' "$TARGET_DIR/etc/shadow"; then
    HASH=$(openssl passwd -6 diknom)
    echo "diknom:${HASH}:19000:0:99999:7:::" >> "$TARGET_DIR/etc/shadow"
fi

# Runner CI bukan root, jadi chown di sini akan gagal ('Operation not permitted').
# Kepemilikan home diatur saat boot oleh /etc/init.d/S00diknom yang jalan sebagai root.
mkdir -p "$TARGET_DIR/home/diknom"
chmod 0755 "$TARGET_DIR/home/diknom"


# --- direktori kerja sistem live ---
mkdir -p "$TARGET_DIR/var/lib/dnpkg/installed" \
         "$TARGET_DIR/var/log" \
         "$TARGET_DIR/var/tmp" \
         "$TARGET_DIR/tmp" \
         "$TARGET_DIR/run"
chmod 1777 "$TARGET_DIR/tmp" "$TARGET_DIR/var/tmp"

# --- permission skrip kita ---
chmod 0755 "$TARGET_DIR/usr/bin/pkg" 2>/dev/null || true
chmod 0755 "$TARGET_DIR/usr/bin/dnpkg" 2>/dev/null || true
chmod 0755 "$TARGET_DIR/usr/bin/dnfetch" 2>/dev/null || true
chmod 0755 "$TARGET_DIR/usr/bin/help" 2>/dev/null || true
chmod 0755 "$TARGET_DIR/usr/bin/dnmode" 2>/dev/null || true
for s in "$TARGET_DIR"/etc/init.d/S[0-9]*; do
    [ -e "$s" ] && chmod 0755 "$s"
done

# --- buang dokumentasi berat (target 256 MB) ---
rm -rf "$TARGET_DIR/usr/share/man" "$TARGET_DIR/usr/share/doc" "$TARGET_DIR/usr/share/info"

# --- sesi grafis: xinitrc untuk user diknom ---
if [ -f "$TARGET_DIR/etc/diknom/xinitrc" ]; then
    cp "$TARGET_DIR/etc/diknom/xinitrc" "$TARGET_DIR/home/diknom/.xinitrc"
    chmod 0755 "$TARGET_DIR/home/diknom/.xinitrc"
fi

# --- Xorg: setuid supaya user biasa bisa menyalakan sesi X (tanpa systemd/logind) ---
if [ -f "$TARGET_DIR/usr/bin/Xorg" ]; then
    chmod 4755 "$TARGET_DIR/usr/bin/Xorg"
    echo "post-build: Xorg setuid disetel"
fi

# --- identitas visual ke dalam sistem (wallpaper & logo, dipakai GUI nanti) ---
HERE_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$TARGET_DIR/usr/share/diknom"
if [ -f "$HERE_DIR/boot/logo.png" ]; then
    cp "$HERE_DIR/boot/logo.png" "$TARGET_DIR/usr/share/diknom/logo.png"
fi

# --- catat versi build ---
VER="${DIKNOM_VERSION:-$(cat "$(dirname "$0")/../../../VERSION" 2>/dev/null || echo 0.1)}"
ARCH="${DIKNOM_ARCH:-unknown}"

# ganti placeholder versi di identitas sistem
for f in "$TARGET_DIR/etc/os-release" "$TARGET_DIR/etc/issue" "$TARGET_DIR/etc/motd"; do
    [ -f "$f" ] && sed -i "s/@VERSION@/${VER}/g" "$f"
done
BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat > "$TARGET_DIR/etc/diknom-build" <<EOF
DIKNOM_VERSION=$VER
DIKNOM_ARCH=$ARCH
DIKNOM_BUILD_DATE=$BUILD_DATE
DIKNOM_BUILD_SYSTEM=buildroot
EOF

echo "post-build: ok (versi $VER, arch $ARCH)"
