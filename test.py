import subprocess
import sys
import os
import shutil

def run_command(command):
    """Run a command and handle errors."""
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Command '{command}' failed with error: {e}")
        sys.exit(1)

def reset_color():
    """Reset terminal colors."""
    print('\033[37m')

def banner():
    """Display the banner."""
    os.system('clear')
    print(f"""\033[31m┌──────────────────────────────────────────────────────────┐
\033[31m│\033[32m░░░▀█▀░█▀▀░█▀▄░█▄█░█░█░█░█░░░█▀▄░█▀▀░█▀▀░█░█░▀█▀░█▀█░█▀█░░\033[31m│
\033[31m│\033[32m░░░░█░░█▀▀░█▀▄░█░█░█░█░▄▀▄░░░█░█░█▀▀░▀▀█░█▀▄░░█░░█░█░█▀▀░░\033[31m│
\033[31m│\033[32m░░░░▀░░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀░░░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀░░░░\033[31m│
\033[31m└──────────────────────────────────────────────────────────┘
\033[34mBy : Aditya Shakya // @adi1090x""")
    
def usage():
    """Display usage information."""
    banner()
    print("\033[33m\nInstall GUI (Openbox Desktop) on Termux")
    print(f"\033[33mUsages : {os.path.basename(sys.argv[0])} --install | --uninstall \n")

def setup_base():
    """Setup the base packages and update the system."""
    packages = [
        'bc', 'bmon', 'calc', 'calcurse', 'curl', 'dbus', 'desktop-file-utils', 
        'elinks', 'feh', 'fontconfig-utils', 'fsmon', 'geany', 'git', 'gtk2', 
        'gtk3', 'htop', 'imagemagick', 'jq', 'leafpad', 'man', 'mpc', 'mpd', 
        'mutt', 'ncmpcpp', 'ncurses-utils', 'neofetch', 'netsurf', 'obconf', 
        'openbox', 'openssl-tool', 'polybar', 'ranger', 'rofi', 'startup-notification', 
        'termux-api', 'thunar', 'tigervnc', 'vim', 'wget', 'xarchiver', 
        'xbitmaps', 'xcompmgr', 'xfce4-settings', 'xfce4-terminal', 
        'xmlstarlet', 'xorg-font-util', 'xorg-xrdb', 'zsh'
    ]

    print("\033[31m\n[*] Installing Termux Desktop...")
    print("\033[36m\n[*] Updating Termux Base... \n")
    reset_color()
    run_command("pkg autoclean")
    run_command("pkg update -y")
    run_command("pkg upgrade -y")

    print("\033[36m\n[*] Enabling Termux X11-repo... \n")
    reset_color()
    run_command("pkg install -y x11-repo")

    print("\033[36m\n[*] Installing required programs... \n")
    for package in packages:
        reset_color()
        run_command(f"pkg install -y {package}")
        installed_pkg = subprocess.getoutput(f"pkg list-installed {package}").split('\n')[-1].split('/')[0]
        if installed_pkg == package:
            print(f"\033[32m\n[*] Package {package} installed successfully.\n")
        else:
            print(f"\033[35m\n[!] Error installing {package}, Terminating...\n")
            reset_color()
            sys.exit(1)
    reset_color()

def setup_omz():
    """Setup Oh My Zsh and configure Termux."""
    print("\033[31m[*] Setting up OMZ and termux configs...")
    omz_files = ['.oh-my-zsh', '.termux', '.zshrc']
    for file in omz_files:
        print(f"\033[36m\n[*] Backing up {file}...")
        reset_color()
        if os.path.exists(os.path.join(os.getenv("HOME"), file)):
            shutil.move(os.path.join(os.getenv("HOME"), file), os.path.join(os.getenv("HOME"), file + '.old'))
        else:
            print(f"\033[35m\n[!] {file} Doesn't Exist.")
    
    print("\033[36m\n[*] Installing Oh-my-zsh... \n")
    reset_color()
    run_command(f"git clone https://github.com/robbyrussell/oh-my-zsh.git --depth 1 {os.getenv('HOME')}/.oh-my-zsh")
    shutil.copy(os.path.join(os.getenv("HOME"), ".oh-my-zsh/templates/zshrc.zsh-template"), os.path.join(os.getenv("HOME"), ".zshrc"))

    with open(os.path.join(os.getenv("HOME"), ".zshrc"), 'r+') as zshrc:
        content = zshrc.read()
        content = content.replace('ZSH_THEME="robbyrussell"', 'ZSH_THEME="aditya"')
        zshrc.seek(0)
        zshrc.write(content)
        zshrc.truncate()

    with open(os.path.join(os.getenv("HOME"), ".oh-my-zsh/custom/themes/aditya.zsh-theme"), 'w') as theme_file:
        theme_file.write("""# Default OMZ theme

if [[ "$USER" == "root" ]]; then
  PROMPT="%(?:%{\$fg_bold[red]%}%{\$fg_bold[yellow]%}%{\$fg_bold[red]%} :%{\$fg_bold[red]%} )"
  PROMPT+='%{\$fg[cyan]%}  %c%{\$reset_color%} \$(git_prompt_info)'
else
  PROMPT="%(?:%{\$fg_bold[red]%}%{\$fg_bold[green]%}%{\$fg_bold[yellow]%} :%{\$fg_bold[red]%} )"
  PROMPT+='%{\$fg[cyan]%}  %c%{\$reset_color%} \$(git_prompt_info)'
fi

ZSH_THEME_GIT_PROMPT_PREFIX="%{\$fg_bold[blue]%}  git:(%{\$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{\$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{\$fg[blue]%}) %{\$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{\$fg[blue]%})"
""")

    with open(os.path.join(os.getenv("HOME"), ".zshrc"), 'a') as zshrc:
        zshrc.write("""
#------------------------------------------
alias l='ls -lh'
alias ll='ls -lah'
alias la='ls -a'
alias ld='ls -lhd'
alias p='pwd'
alias u='cd $PREFIX'
alias h='cd $HOME'
alias :q='exit'
alias grep='grep --color=auto'
alias open='termux-open'
alias lc='lolcat'
alias xx='chmod +x'
alias rel='termux-reload-settings'
#------------------------------------------

# SSH Server Connections

# linux (Arch)
#alias arch='ssh UNAME@IP -i ~/.ssh/id_rsa.DEVICE'

# linux sftp (Arch)
#alias archfs='sftp -i ~/.ssh/id_rsa.DEVICE UNAME@IP'
""")

    print("\033[36m\n[*] Configuring Termux...")
    termux_dir = os.path.join(os.getenv("HOME"), ".termux")
    if not os.path.exists(termux_dir):
        os.mkdir(termux_dir)

    shutil.copy(os.path.join(os.getcwd(), "files/.fonts/icons/dejavu-nerd-font.ttf"), os.path.join(termux_dir, "font.ttf"))

    with open(os.path.join(termux_dir, "colors.properties"), 'w') as colors_file:
        colors_file.write("""
background      : #263238
foreground      : #eceff1
color0          : #263238
color8          : #37474f
color1          : #ff9800
color9          : #ffa74d
color2          : #8bc34a
color10         : #9ccc65
color3          : #ffc107
color11         : #ffa000
color4          : #03a9f4
color12         : #81d4fa
color5          : #e91e63
color13         : #f06292
color6          : #009688
color14         : #4db6ac
color7          : #eceff1
color15         : #ffffff
""")

    run_command("termux-reload-settings")
    reset_color()

def setup_panel():
    """Set up the panel with polybar and other necessary configurations."""
    print("\033[31m[*] Setting up polybar... \n")
    if os.path.exists(os.path.join(os.getenv("HOME"), ".config/polybar")):
        shutil.move(os.path.join(os.getenv("HOME"), ".config/polybar"), os.path.join(os.getenv("HOME"), ".config/polybar.old"))

    shutil.copytree(os.path.join(os.getcwd(), "files/.config/polybar"), os.path.join(os.getenv("HOME"), ".config/polybar"))

    if os.path.exists(os.path.join(os.getenv("HOME"), ".config/openbox")):
        shutil.move(os.path.join(os.getenv("HOME"), ".config/openbox"), os.path.join(os.getenv("HOME"), ".config/openbox.old"))

    shutil.copytree(os.path.join(os.getcwd(), "files/.config/openbox"), os.path.join(os.getenv("HOME"), ".config/openbox"))
    
    print("\033[36m[*] Setting up wallpapers... \n")
    reset_color()
    if os.path.exists(os.path.join(os.getenv("HOME"), ".config/wallpapers")):
        shutil.move(os.path.join(os.getenv("HOME"), ".config/wallpapers"), os.path.join(os.getenv("HOME"), ".config/wallpapers.old"))

    shutil.copytree(os.path.join(os.getcwd(), "files/.config/wallpapers"), os.path.join(os.getenv("HOME"), ".config/wallpapers"))
    reset_color()

    print("\033[36m[*] Patching Xresources... \n")
    reset_color()
    shutil.copy(os.path.join(os.getcwd(), "files/.Xresources"), os.path.join(os.getenv("HOME"), ".Xresources"))
    reset_color()

    run_command("xrdb $HOME/.Xresources")
    reset_color()

def uninstall():
    """Uninstall the setup and revert changes."""
    print("\033[31m[*] Removing Openbox Setup...")

    run_command("rm -rf ~/.config/polybar")
    run_command("rm -rf ~/.config/openbox")
    run_command("rm -rf ~/.config/wallpapers")
    run_command("rm ~/.Xresources")

    omz_files = ['.oh-my-zsh', '.termux', '.zshrc']
    for file in omz_files:
        if os.path.exists(os.path.join(os.getenv("HOME"), file)):
            shutil.rmtree(os.path.join(os.getenv("HOME"), file))

    print("\033[31m[*] Uninstall complete.")
    reset_color()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        usage()
        sys.exit(1)

    if sys.argv[1] == "--install":
        setup_base()
        setup_omz()
        setup_panel()
        print("\033[32m\n[+] Installation Complete!\n")
    elif sys.argv[1] == "--uninstall":
        uninstall()
        print("\033[32m\n[+] Uninstallation Complete!\n")
    else:
        usage()
        sys.exit(1)
