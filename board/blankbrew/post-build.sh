#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
        sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
# systemd doesn't use /etc/inittab, enable getty.tty1.service instead
elif [ -d ${TARGET_DIR}/etc/systemd ]; then
    mkdir -p "${TARGET_DIR}/etc/systemd/system/getty.target.wants"
    ln -sf /lib/systemd/system/getty@.service \
       "${TARGET_DIR}/etc/systemd/system/getty.target.wants/getty@tty1.service"
fi

# Set up wpa_supplicant for wifi access
mkdir -p "${TARGET_DIR}/etc/init.d"

cat > "${TARGET_DIR}/etc/init.d/S10wpa_supplicant" << 'EOF'
#!/bin/sh

echo "Starting Wi-Fi"
/usr/sbin/wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
EOF

chmod +x "${TARGET_DIR}/etc/init.d/S10wpa_supplicant"

# Make udhcpc run in the background
cp board/blankbrew/S30udhcpc-background "${TARGET_DIR}/etc/init.d/"
chmod +x "${TARGET_DIR}/etc/init.d/S30udhcpc-background"


# Add SSH authorized_keys
mkdir -p "${TARGET_DIR}/root/.ssh"
cp "board/blankbrew/authorized_keys" "${TARGET_DIR}/root/.ssh/authorized_keys"
chmod 700 "${TARGET_DIR}/root/.ssh"
chmod 600 "${TARGET_DIR}/root/.ssh/authorized_keys"

# Move app files to where they need to be
mkdir -p "${TARGET_DIR}/www"
cp -r board/blankbrew/overlay/www/* "${TARGET_DIR}/www/"

# Ensure lighttpd can actually log errors
mkdir -p "${TARGET_DIR}/var/log/lighttpd/"
chmod +x "${TARGET_DIR}/var/log/lighttpd/"

# Install Cog autostart script
mkdir -p "${TARGET_DIR}/etc/rcS.d"
cp board/blankbrew/S51cog "${TARGET_DIR}/etc/init.d/"
chmod +x "${TARGET_DIR}/etc/init.d/S51cog"
ln -sf ../init.d/S51cog "${TARGET_DIR}/etc/rcS.d/S51cog"

# Make sure cog can run
chmod +x "${TARGET_DIR}/etc/profile.d/cog-env.sh"
