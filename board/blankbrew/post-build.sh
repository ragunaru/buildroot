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

# Add SSH authorized_keys
mkdir -p "${TARGET_DIR}/root/.ssh"
chmod 700 "${TARGET_DIR}/root"
chmod 700 "${TARGET_DIR}/root/.ssh"
cp "board/blankbrew/authorized_keys" "${TARGET_DIR}/root/.ssh/authorized_keys"
chmod 600 "${TARGET_DIR}/root/.ssh/authorized_keys"

# Move app files to where they need to be
mkdir -p "${TARGET_DIR}/www"
cp -r board/blankbrew/overlay/www/* "${TARGET_DIR}/www/"

# Make sure cog can run
chmod +x "${TARGET_DIR}/etc/profile.d/cog-env.sh"
