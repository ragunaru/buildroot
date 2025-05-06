#!/bin/sh
export XDG_RUNTIME_DIR=/run/user/0
export COG_PLATFORM=drm
export WPE_BACKEND=libWPEBackend-drm.so
export LD_LIBRARY_PATH=/usr/lib
export COG_PLATFORM_DRM_RENDERER=gl
export LIBGL_DEBUG=verbose

# Create runtime directory with proper permissions
mkdir -p "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"

# Ensure proper device permissions
chmod 666 /dev/dri/card0 2>/dev/null || true
chmod 666 /dev/dri/renderD128 2>/dev/null || true
