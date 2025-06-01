#!/usr/bin/env bash

# Prompt for username and password
prompt_for_user_credentials() {
    read -r -p "Select a username: " username </dev/tty
    read -r -s -p "Enter password for $username: " password </dev/tty
    echo
}

# Setup Ubuntu
setup_ubuntu() {
    echo "Setting up Ubuntu..."

    termux-change-repo || { echo "Failed to change Termux repository."; exit 1; }
    yes | pkg install x11-repo proot-distro || { echo "Failed to install required repos."; exit 1; }
    yes | pkg update || { echo "Failed to update Termux packages."; exit 1; }
    termux-setup-storage || { echo "Failed to set up Termux storage."; exit 1; }
    pkg install dbus pulseaudio virglrenderer-android pavucontrol-qt -y || { echo "Failed to install packages."; exit 1; }

    if ! pd list installed | grep -q ubuntu; then
        yes | pd install ubuntu || { echo "Failed to install Ubuntu."; exit 1; }
    fi

    timezone=$(getprop persist.sys.timezone)

    # Update Ubuntu and install nala
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 bash -c "
        apt update &&
        apt install -y nala &&
        ln -sf /usr/share/zoneinfo/$timezone /etc/localtime &&
        nala upgrade -y
    " || { echo "Failed to set up nala or system time."; exit 1; }

    # Install XFCE and other packages using nala
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 nala install -y sudo xfce4 xfce4-terminal xfce4-goodies dbus-x11 evince thunar-archive-plugin xarchiver fonts-roboto fonts-noto || {
        echo "Failed to install desktop packages.";
        exit 1;
    }

    pd login ubuntu --shared-tmp -- env DISPLAY=:1 nala remove -y xterm || { echo "Failed to remove xterm."; exit 1; }
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/xfce4-terminal 50
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal

    # Create user
    if [[ -z "$username" || -z "$password" ]]; then
        echo "Error: Username or password not set."
        exit 1
    fi

    pd login ubuntu --shared-tmp -- env DISPLAY=:1 groupadd -f storage || true
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 groupadd -f wheel || true
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username" || { echo "User creation failed."; exit 1; }
    echo "$username:$password" | pd login ubuntu --shared-tmp -- env DISPLAY=:1 chpasswd || { echo "Failed to set password."; exit 1; }

    pd login ubuntu --shared-tmp -- env DISPLAY=:1 bash -c "
        echo '$username ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$username && chmod 440 /etc/sudoers.d/$username
    " || { echo "Failed to add sudoers entry."; exit 1; }

    echo "Ubuntu setup complete."
}

# Setup PulseAudio
setup_pulseaudio() {
    echo "Setting up PulseAudio..."

    if [ -f "$HOME/.sound" ]; then
        cp "$HOME/.sound" "$HOME/.sound.bak"
        echo "Backed up existing .sound"
    fi

    cat > "$HOME/.sound" <<EOF
pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
EOF

    if ! grep -q "source .sound" "$HOME/.bashrc"; then
        echo "source .sound" >> "$HOME/.bashrc"
    fi

    yes | pkg install termux-x11-nightly || { echo "Failed to install termux-x11-nightly."; exit 1; }

    mkdir -p "$HOME/.termux"
    touch "$HOME/.termux/termux.properties"

    if grep -q "allow-external-apps = true" "$HOME/.termux/termux.properties"; then
        sed -i 's/allow-external-apps = true/allow-external-apps = false/' "$HOME/.termux/termux.properties"
    fi
}

# Launch XFCE
launch_xfce() {
    echo "Launching XFCE desktop..."
    pkill -f "termux.x11" 2>/dev/null || true
    pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"

    export XDG_RUNTIME_DIR=${TMPDIR}
    termux-x11 :1 >/dev/null &
    sleep 3
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
    sleep 2
}

# Main
main() {
    prompt_for_user_credentials
    setup_ubuntu
    setup_pulseaudio
    launch_xfce
    echo "Setup complete!"
    echo "To launch later: source ~/.sound && termux-x11 :1 &"
}

main
exit 0
