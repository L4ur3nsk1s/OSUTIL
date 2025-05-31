#!/data/data/com.termux/files/usr/bin/bash

set -euo pipefail
trap 'echo "❌ An error occurred. Installation aborted."; exit 1' ERR

FAST=0
UNINSTALL=0

# Parse flags
for arg in "$@"; do
  case "$arg" in
    --fast) FAST=1 ;;
    --uninstall) UNINSTALL=1 ;;
    *) echo "❗ Unknown argument: $arg"; exit 1 ;;
  esac
done

# Uninstall logic
if [[ $UNINSTALL -eq 1 ]]; then
  echo "🗑️ Uninstalling Ubuntu Proot-Distro..."
  if proot-distro list | grep -q "ubuntu"; then
    proot-distro remove ubuntu
    echo "✅ Removed Ubuntu distro."
  else
    echo "⚠️ Ubuntu distro not found."
  fi
  rm -f start-lxde.sh
  echo "🧹 Cleaned up launcher script."
  exit 0
fi

echo "📥 Installing dependencies..."
pkg update -y && pkg upgrade -y
pkg install -y proot-distro x11-repo termux-x11 pulseaudio

# Install Ubuntu if not present
if proot-distro list | grep -q "ubuntu.*installed"; then
  echo "✅ Ubuntu Proot-Distro already installed, skipping."
else
  echo "📦 Installing Ubuntu Proot-Distro..."
  proot-distro install ubuntu
fi

# Prompt for username
read -rp "👤 Enter a username for the new user: " NEWUSER

echo "🔧 Configuring Ubuntu environment for user: $NEWUSER"
proot-distro login ubuntu -- bash -c "
  set -euo pipefail

  apt update -y
  [[ $FAST -eq 0 ]] && apt upgrade -y

  DEBIAN_FRONTEND=noninteractive apt install -y sudo lxde-core lxterminal dbus-x11 x11-utils leafpad fonts-dejavu lxappearance desktop-file-utils

  # Create user if not exists
  if ! id -u \"$NEWUSER\" &>/dev/null; then
    useradd -m -s /bin/bash \"$NEWUSER\"
    echo \"$NEWUSER ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers.d/$NEWUSER
    chmod 0440 /etc/sudoers.d/$NEWUSER
  fi

  # Improve sudo compatibility in proot
  echo \"Defaults !requiretty\" >> /etc/sudoers
  echo \"Defaults env_keep += \\\"DISPLAY PULSE_SERVER\\\"\" >> /etc/sudoers

  # User environment setup
  su - \"$NEWUSER\" -c '
    mkdir -p ~/.config/lxsession/LXDE/ ~/.config/openbox ~/.config/gtk-3.0 ~/.local/share/applications

    # Autostart LXTerminal
    cat > ~/.config/lxsession/LXDE/autostart <<EOF
@lxpanel
@openbox --config-file ~/.config/openbox/lxde-rc.xml
@lxterminal
EOF

    # Openbox config
    cat > ~/.config/openbox/lxde-rc.xml <<EOF
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<openbox_config>
  <theme>
    <name>Clearlooks</name>
    <titleLayout>NLIMC</titleLayout>
  </theme>
  <desktops>
    <number>1</number>
    <firstdesk>1</firstdesk>
  </desktops>
  <resize>
    <drawContents>no</drawContents>
  </resize>
</openbox_config>
EOF

    # GTK Theme
    echo \"[Settings]\" > ~/.config/gtk-3.0/settings.ini
    echo \"gtk-theme-name=Clearlooks\" >> ~/.config/gtk-3.0/settings.ini

    # Safe export in .bashrc
    grep -qxF \"export DISPLAY=:0\" ~/.bashrc || echo \"export DISPLAY=:0\" >> ~/.bashrc
    grep -qxF \"export PULSE_SERVER=127.0.0.1\" ~/.bashrc || echo \"export PULSE_SERVER=127.0.0.1\" >> ~/.bashrc

    # Desktop shortcuts
    cat > ~/.local/share/applications/lxterminal.desktop <<EOL
[Desktop Entry]
Name=LXTerminal
Comment=Terminal emulator
Exec=lxterminal
Icon=utilities-terminal
Type=Application
Categories=Utility;TerminalEmulator;
EOL

    cat > ~/.local/share/applications/leafpad.desktop <<EOL
[Desktop Entry]
Name=Leafpad
Comment=Simple Text Editor
Exec=leafpad
Icon=accessories-text-editor
Type=Application
Categories=Utility;TextEditor;
EOL
  '
"

echo "🚀 Creating launcher script: start-lxde.sh"
cat > start-lxde.sh <<EOF
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
termux-x11 :0 &
sleep 5
proot-distro login ubuntu -- su - $NEWUSER -c startlxde
EOF

chmod +x start-lxde.sh

echo "✅ LXDE setup complete!"
echo "👉 To launch LXDE as '$NEWUSER', run: ./start-lxde.sh"
echo "📲 Be sure Termux-X11 is started and visible on your Android device."
