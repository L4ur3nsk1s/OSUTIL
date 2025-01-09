#!/usr/bin/env bash

# Function to prompt for username and password
prompt_for_user_credentials() {
    read -r -p "Select a username: " username </dev/tty
    read -r -s -p "Enter password for $username: " password </dev/tty
    echo
}

# Function to set up Ubuntu
setup_ubuntu() {
    echo "Setting up Ubuntu..."
    
    # Change Termux repository
    termux-change-repo || { echo "Failed to change Termux repository."; exit 1; }
    
    # Install necessary repositories and tools
    yes | pkg install x11-repo proot-distro || { echo "Failed to install x11-repo or proot-distro."; exit 1; }
    yes | pkg update || { echo "Failed to update packages."; exit 1; }
    termux-setup-storage || { echo "Failed to set up Termux storage."; exit 1; }
    
    # Install required packages
    pkg install dbus pulseaudio virglrenderer-android pavucontrol-qt -y || { echo "Failed to install required packages."; exit 1; }
    
    # Install Ubuntu
    yes | pd install ubuntu || { echo "Failed to install Ubuntu."; exit 1; }
    
    # Update Ubuntu packages
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt update || { echo "Failed to update Ubuntu packages."; exit 1; }
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt upgrade -y || { echo "Failed to upgrade Ubuntu packages."; exit 1; }
    # Set timezone
    timezone=$(getprop persist.sys.timezone)
    pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime
    pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$timezone /etc/localtime
    
    # Install XFCE and utilities
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt install sudo xfce4 xfce4-terminal xfce4-goodies dbus-x11 evince thunar-archive-plugin xarchiver -y || { echo "Failed to install XFCE."; exit 1; }
    
    # Remove xterm and set xfce4-terminal as default
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt remove xterm -y || { echo "Failed to remove xterm."; exit 1; }
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/xfce4-terminal 50 || { echo "Failed to set XFCE terminal as default."; exit 1; }
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal || { echo "Failed to finalize XFCE terminal setup."; exit 1; }
    
    # Install themes and fonts
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt install fonts-roboto fonts-noto -y || { echo "Failed to install fonts."; exit 1; }
    
    # Create user and set password
    if [ -z "$username" ] || [ -z "$password" ]; then
        echo "Error: Username or password is not set."
        exit 1
    fi
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 groupadd -f storage || true
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 groupadd -f wheel || true
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username" || { echo "Failed to create user."; exit 1; }
    echo "$username:$password" | pd login ubuntu --shared-tmp -- chpasswd || { echo "Failed to set user password."; exit 1; }
    
    # Configure sudoers file
    sudoers_path="$HOME/../usr/var/lib/proot-distro/installed-rootfs/ubuntu/etc/sudoers"
    chmod u+rw "$sudoers_path"
    echo "$username ALL=(ALL) ALL" | tee -a "$sudoers_path" > /dev/null
    chmod u-w "$sudoers_path"
    
    echo "Ubuntu setup completed successfully."
}

# Function to set up PulseAudio
setup_pulseaudio() {
    echo "Setting up PulseAudio..."
    
    # Check if .sound file exists
    if [ ! -f "$HOME/.sound" ]; then
        cat > "$HOME/.sound" <<EOF
pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
EOF
        echo "Created $HOME/.sound with PulseAudio configuration."
    else
        echo "$HOME/.sound already exists. Skipping creation."
    fi
    
    # Add source command to .bashrc if not already present
    if ! grep -q "source .sound" "$HOME/.bashrc"; then
        echo "source .sound" >> "$HOME/.bashrc"
        echo "Added 'source .sound' to $HOME/.bashrc."
    else
        echo "'source .sound' is already present in $HOME/.bashrc."
    fi
    
    # Install Termux X11 nightly
    yes | pkg install termux-x11-nightly || { echo "Failed to install Termux X11 nightly."; exit 1; }
    
    # Modify termux.properties
    if grep -q "allow-external-apps = true" "$HOME/.termux/termux.properties"; then
        sed -i 's/allow-external-apps = true/allow-external-apps = false/' "$HOME/.termux/termux.properties"
        echo "Updated 'allow-external-apps' to false in termux.properties."
    else
        echo "'allow-external-apps = true' not found. No changes made to termux.properties."
    fi
}

# Function to launch the XFCE desktop environment
launch_xfce() {
    echo "Launching XFCE desktop environment..."
    kill -9 $(pgrep -f "termux.x11") 2>/dev/null || true
    pulseaudio --start --exit-idle-time=-1 --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"
    
    export XDG_RUNTIME_DIR=${TMPDIR}
    termux-x11 :1 >/dev/null &
    sleep 3
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
    sleep 2
}

# Main function
main() {
    prompt_for_user_credentials
    setup_ubuntu
    setup_pulseaudio
    launch_xfce
    echo "Setup complete!"
}

main
exit 0
