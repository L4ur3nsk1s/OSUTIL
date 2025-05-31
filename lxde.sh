#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "📥 Installing dependencies..."
pkg update -y && pkg upgrade -y
pkg install -y proot-distro x11-repo termux-x11 pulseaudio

echo "📦 Installing Ubuntu Proot Distro..."
proot-distro install ubuntu

# Prompt for username
read -p "👤 Enter a username for the new user: " NEWUSER

echo "🔧 Configuring Ubuntu environment for user: $NEWUSER"
proot-distro login ubuntu -- bash -c "
  apt update -y && apt upgrade -y
  DEBIAN_FRONTEND=noninteractive apt install -y sudo  lxde lxde-core lxterminal dbus-x11 x11-utils  fonts-dejavu lxappearance

  # Create user
  useradd -m -s /bin/bash $NEWUSER
  echo '$NEWUSER ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

  # Set up user environment
  su - $NEWUSER -c '
    mkdir -p ~/.config/lxsession/LXDE/
    echo \"@lxpanel\" > ~/.config/lxsession/LXDE/autostart
    echo \"@openbox --config-file ~/.config/openbox/lxde-rc.xml\" >> ~/.config/lxsession/LXDE/autostart
    echo \"@lxterminal\" >> ~/.config/lxsession/LXDE/autostart

    mkdir -p ~/.config/openbox
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

    mkdir -p ~/.config/gtk-3.0
    echo \"[Settings]\" > ~/.config/gtk-3.0/settings.ini
    echo \"gtk-theme-name=Clearlooks\" >> ~/.config/gtk-3.0/settings.ini

    echo 'export DISPLAY=:0' >> ~/.bashrc
    echo 'export PULSE_SERVER=127.0.0.1' >> ~/.bashrc
  '
"

echo "🚀 Creating launcher script: start-lxde.sh"
cat > start-lxde.sh <<EOF
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
termux-x11 :0 &
sleep 2
proot-distro login ubuntu -- su - $NEWUSER -c startlxde
EOF

chmod +x start-lxde.sh

echo "✅ LXDE setup complete!"
echo "👉 To launch LXDE as '$NEWUSER', run: ./start-lxde.sh"
echo "📲 Don't forget to start the Termux-X11 app first!"
