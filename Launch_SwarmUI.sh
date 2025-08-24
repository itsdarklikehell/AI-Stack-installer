#!/bin/bash
export UV_LINK_MODE=copy
cd /media/rizzo/RAIDSTATION/AI-Stack-installer || exit 1

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
        
        pip install -r requirements.txt
        pip install --upgrade pip
        pip install --upgrade comfy-cli

        # Install ComfyUI-Manager if not present
        if [ ! -d custom_nodes/ComfyUI-Manager ]; then
            cd custom_nodes || exit 1
            git clone --recursive https://github.com/Comfy-Org/ComfyUI-Manager
            cd ComfyUI-Manager || exit 1
            pip install -r requirements.txt
        fi
    fi
    cd ../../
    ./launch-linux.sh "$@"
fi
