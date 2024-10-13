#!/bin/bash

# Function to prompt for username and password
prompt_for_user_credentials() {
    read -r -p "Select a username: " username </dev/tty
    read -r -s -p "Enter password for $username: " password </dev/tty
    echo
}

# Function to install necessary packages and set up Ubuntu
setup_ubuntu() {
    termux-change-repo
    yes | pkg install x11-repo
    yes | pkg update
    termux-setup-storage
    
    # Install necessary packages
    pkg install dbus proot-distro pulseaudio virglrenderer-android pavucontrol-qt -y
    
    # Install Ubuntu
    yes | pd install ubuntu
    
    # Update Ubuntu packages
    yes | pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt update
    yes | pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt upgrade -y
    
    # Set timezone
    timezone=$(getprop persist.sys.timezone)
    pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime
    pd login ubuntu --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$timezone /etc/localtime
    
    # Install XFCE and additional utilities
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt install sudo xfce4 xfce4-terminal xfce4-goodies dbus-x11 evince thunar-archive-plugin xarchiver -y
    
    # Remove xterm and set xfce4-terminal as the default terminal
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt remove xterm -y
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/xfce4-terminal 50
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal
    
    # Install themes and fonts
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 apt install elementary-icon-theme arc-theme fonts-roboto fonts-noto -y
    
    # Create user and set password
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 groupadd storage
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 groupadd wheel
    pd login ubuntu --shared-tmp -- env DISPLAY=:1 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"
    echo "$username:$password" | pd login ubuntu --shared-tmp -- chpasswd
    
    # Configure sudoers file
    chmod u+rw $HOME/../usr/var/lib/proot-distro/installed-rootfs/ubuntu/etc/sudoers
    echo "$username ALL=(ALL) ALL" | tee -a $HOME/../usr/var/lib/proot-distro/installed-rootfs/ubuntu/etc/sudoers > /dev/null
    chmod u-w $HOME/../usr/var/lib/proot-distro/installed-rootfs/ubuntu/etc/sudoers
}

# Function to set up PulseAudio
setup_pulseaudio() {
    echo "
pulseaudio --start --exit-idle-time=-1
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
" > $HOME/.sound

    echo "
source .sound" >> $HOME/.bashrc
    
    yes | pkg install termux-x11-nightly
    echo "allow-external-apps = true" >> ~/.termux/termux.properties
}

# Function to launch the XFCE desktop environment
launch_xfce() {
    kill -9 $(pgrep -f "termux.x11") 2>/dev/null
    pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
    
    export XDG_RUNTIME_DIR=${TMPDIR}
    termux-x11 :1 >/dev/null &
    
    sleep 3
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
    sleep 2

    echo "alias ubuntu='am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1 && sleep 1 && GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=4.0 proot-distro login ubuntu --shared-tmp -- /bin/bash -c \"export PULSE_SERVER=127.0.0.1 && export XDG_RUNTIME_DIR=\\\\\${TMPDIR} && su - $username -c \\\"sh -c \\\\\\\"termux-x11 :1 -xstartup \\\\\\\\\\\\\\\"dbus-launch --exit-with-session xfce4-session\\\\\\\\\\\\\\\" && env DISPLAY=:1 startxfce4\\\\\\\"\\\"\"'" >> $HOME/.bashrc
    
    echo "alias ubuntuconsole='proot-distro login ubuntu --shared-tmp -- /bin/bash -c \"export PULSE_SERVER=127.0.0.1 && su - $username -c \\\"bash\\\"\"'" >> $HOME/.bashrc
    
    source ~/.bashrc
    
    GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=4.0 proot-distro login ubuntu --shared-tmp -- /bin/bash -c "export PULSE_SERVER=127.0.0.1 && export XDG_RUNTIME_DIR=\${TMPDIR} && su - $username -c \"termux-x11 :1 -xstartup \\\"dbus-launch --exit-with-session xfce4-session\\\" && env DISPLAY=:1 startxfce4\""
}

# Main function to orchestrate the setup
main() {
    prompt_for_user_credentials
    setup_ubuntu
    setup_pulseaudio
    launch_xfce
    echo "Setup complete!"
}

# Run the main function
main
exit 0
