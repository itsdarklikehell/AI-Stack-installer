#!/usr/bin/env bash
export UV_LINK_MODE=copy

sudo systemctl stop SwarmUI
sudo systemctl stop ComfyUI
if [ -f /etc/systemd/system/SwarmUI.service ]; then
    sudo rm /etc/systemd/system/SwarmUI.service
fi
if [ -f /etc/systemd/system/ComfyUI.service ]; then
    sudo rm /etc/systemd/system/ComfyUI.service
fi

if [ ! -d ~/bin ]; then
    echo "Created ~/bin directory"
    mkdir ~/bin
fi

# Ensure correct local path.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR" || exit 1

# Accidental run prevention
if [ -d "SwarmUI" ]; then
    echo "SwarmUI already exists in this directory. Do you want to move it to a backup location? (y/n)"
    read -r answer
    if [ "$answer" == "y" ]; then
        mv SwarmUI SwarmUI-OLD-"$(date +%s)"
    else
        exit 1
    fi
fi
if [ -f "SwarmUI.sln" ]; then
    echo "SwarmUI already exists in this directory. Do you want to move it to a backup location? (y/n)"
    read -r answer
    if [ "$answer" == "y" ]; then
        mv SwarmUI.sln SwarmUI-OLD-"$(date +%s)".sln
    else
        exit 1
    fi
fi

# Download swarm
git clone --recursive https://github.com/mcmonkeyprojects/SwarmUI
cd SwarmUI || exit 1

# install dotnet
cd launchtools || exit 1
rm dotnet-install.sh
# https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual#scripted-install
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
chmod +x dotnet-install.sh
cd ..

# Note: manual installers that want to avoid home dir, add to both of the below lines: --install-dir $SCRIPT_DIR/.dotnet
./launchtools/dotnet-install.sh --channel 8.0 --runtime aspnetcore >/dev/null 2>&1
./launchtools/dotnet-install.sh --channel 8.0 >/dev/null 2>&1

# Launch
# ./launch-linux.sh "$@"

# Setup systemd services
cat << EOF | sudo tee /etc/systemd/system/SwarmUI.service >/dev/null 2>&1
[Unit]
Description=SwarmUI Service
After=network.target

[Service]
Restart=on-failure
RestartSec=5s
Type=simple
User=$USER
Group=$USER
WorkingDirectory=$SCRIPT_DIR/SwarmUI
ExecStart=$SCRIPT_DIR/Launch_SwarmUI.sh

[Install]
WantedBy=multi-user.target
EOF

cat << EOF | sudo tee /etc/systemd/system/ComfyUI.service >/dev/null 2>&1
[Unit]
Description=ComfyUI Service
After=network.target

[Service]
Restart=on-failure
RestartSec=5s
Type=simple
User=$USER
Group=$USER
WorkingDirectory=$SCRIPT_DIR/ComfyUI
ExecStart=$SCRIPT_DIR/Launch_ComfyUI.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
if [ -f /etc/systemd/system/SwarmUI.service ]; then
    sudo systemctl start SwarmUI
fi

if [ -f /etc/systemd/system/ComfyUI.service ]; then
    sudo systemctl start ComfyUI
fi
xdg-open http://localhost:7801 >/dev/null 2>&1 &

# watch sudo systemctl status SwarmUI ComfyUI