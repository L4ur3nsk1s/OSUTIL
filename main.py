#!/usr/bin/env python3
from unixtil.runner import CommandRunner
from unixtil.file_manager import FileManager
from unixtil.bash_manager import BashScriptManager
from unixtil.system_manager import SystemManager
from unixtil import CustomPrinter  
import os

# Initialize components
file_manager = FileManager()
system_manager = SystemManager()
bash_manager = BashScriptManager()
printer = CustomPrinter() 

username = 'laurenskis'



CommandRunner.run("termux-change-repo")
CommandRunner.run("pkg update -y -o Dpkg::Options::='--force-confold'")
CommandRunner.run("pkg upgrade -y -o Dpkg::Options::='--force-confold'")
CommandRunner.run("sed -i '12s/^#//' $HOME/.termux/termux.properties")
CommandRunner.run("termux-setup-storage")

pkgs = ['wget', 'python', 'ncurses-utils', 'dbus', 'proot-distro', 'x11-repo', 'tur-repo', 'pulseaudio']

CommandRunner.run("pkg uninstall dbus -y")
CommandRunner.run("pkg update")
CommandRunner.run(f"pkg install {' '.join(pkgs)} -y -o Dpkg::Options::='--force-confold'")

# Create default directories
os.makedirs("Desktop", exist_ok=True)
os.makedirs("Downloads", exist_ok=True)


CommandRunner.run("wget -N https://github.com/L4ur3nsk1s/Termux-XFCE-Custom/raw/main/xfce.py")
CommandRunner.run("wget -N https://github.com/L4ur3nsk1s/Termux-XFCE-Custom/raw/main/proot.py")
CommandRunner.run("wget -N https://github.com/L4ur3nsk1s/Termux-XFCE-Custom/raw/main/utils.py")
CommandRunner.run("chmod +x *.py")

CommandRunner.run(f"./xfce.py {username}")
CommandRunner.run(f"./proot.py {username}")
CommandRunner.run("./utils.py")