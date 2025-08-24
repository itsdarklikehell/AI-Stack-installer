#!/bin/bash
export UV_LINK_MODE=copy
cd /media/"$USER"/RAIDSTATION/AI-Stack-installer || exit 1

if [ ! -d SwarmUI ]; then
    install-SwarmUI-linux.sh
fi
if [ -d SwarmUI ]; then
    if [ -d SwarmUI/dlbackend/ComfyUI ]; then
        cd SwarmUI/dlbackend/ComfyUI || exit 1
        if [ ! -d venv ]; then
            python3 -m venv venv
        fi

        source venv/bin/activate

        pip install -r requirements.txt >/dev/null 2>&1
        pip install --upgrade pip >/dev/null 2>&1
        pip install --upgrade comfy-cli >/dev/null 2>&1

        # Install ComfyUI-Manager if not present
        if [ ! -d custom_nodes/ComfyUI-Manager ]; then
            cd custom_nodes || exit 1
            git clone --recursive https://github.com/Comfy-Org/ComfyUI-Manager
            cd ComfyUI-Manager || exit 1
            pip install -r requirements.txt >/dev/null 2>&1
        fi

        comfy --install-completion
        # comfy install --restore

        cd /media/"$USER"/RAIDSTATION/AI-Stack-installer/SwarmUI/dlbackend/ComfyUI || exit 1
        # comfy launch -- --listen 0.0.0.0 --preview-method auto
        python3 main.py --listen 0.0.0.0 --preview-method auto
    fi
fi