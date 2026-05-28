#!/bin/sh

# Source system xinitrc scripts
for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
    [ -x "$f" ] && . "$f"
done

# Set AMD iGPU as the DRI render device for all GL apps
export DRI_PRIME=0

# exec bspwm
