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

# Set proper permissions for init scripts
chmod +x ${TARGET_DIR}/etc/init.d/S*

# Add SSH authorized_keys
mkdir -p "${TARGET_DIR}/root/.ssh"
chmod 700 "${TARGET_DIR}/root"
chmod 700 "${TARGET_DIR}/root/.ssh"
cp "board/blankbrew/authorized_keys" "${TARGET_DIR}/root/.ssh/authorized_keys"
chmod 600 "${TARGET_DIR}/root/.ssh/authorized_keys"

# Move app files to where they need to be
mkdir -p "${TARGET_DIR}/www"
cp -r board/blankbrew/overlay/www/* "${TARGET_DIR}/www/"

# Create OpenGL symlinks for compatibility
echo "Creating OpenGL compatibility symlinks..."

# For libGL.so.1 (Using GLESv2 as the implementation)
if [ -f "${TARGET_DIR}/usr/lib/libGLESv2.so" ] && [ ! -f "${TARGET_DIR}/usr/lib/libGL.so.1" ]; then
    ln -sf libGLESv2.so ${TARGET_DIR}/usr/lib/libGL.so.1
    ln -sf libGLESv2.so ${TARGET_DIR}/usr/lib/libGL.so
    echo "Created libGL.so.1 -> libGLESv2.so symlink"
fi

# For libOpenGL.so.0 (Using EGL as the implementation)
if [ -f "${TARGET_DIR}/usr/lib/libEGL.so" ] && [ ! -f "${TARGET_DIR}/usr/lib/libOpenGL.so.0" ]; then
    ln -sf libEGL.so ${TARGET_DIR}/usr/lib/libOpenGL.so.0
    ln -sf libEGL.so ${TARGET_DIR}/usr/lib/libOpenGL.so
    echo "Created libOpenGL.so.0 -> libEGL.so symlink"
fi

# Make sure cog can run
chmod +x "${TARGET_DIR}/etc/profile.d/cog-env.sh"
