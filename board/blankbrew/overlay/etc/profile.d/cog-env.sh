#!/bin/sh

# Set base cog parameters. I fucking hope these work.
export COG_PLATFORM_NAME=drm
export EGL_PLATFORM=drm # need to explicitly tell EGL to use drm... dumb.

# Create runtime directory with proper permissions
export XDG_RUNTIME_DIR=/run/user/0
mkdir -p "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"

# Ensure proper device permissions
chmod 666 /dev/dri/card0 2>/dev/null || true
chmod 666 /dev/dri/renderD128 2>/dev/null || true
chmod 666 /dev/input/* 2>/dev/null || true
