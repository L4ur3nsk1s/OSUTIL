#!/usr/bin/env python3
import os
import subprocess
import shutil
import sys

ESSENTIALS = [
    "git",
    "zsh",
    "neovim",
    "curl",
    "wget",
    "fastfetch",
    "btop",
]

DEV_TOOLS = [
    "nodejs",   
    "python",   
    "clang",
    "make",
]

NVIM_CONFIG_DIR = os.path.expanduser("~/.config/nvim")
NVIM_INIT_FILE = os.path.join(NVIM_CONFIG_DIR, "init.vim")
VIM_PLUG_URL = "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

def run_command(cmd, check=True):
    print(f"[RUN] {cmd}")
    subprocess.run(cmd, shell=True, check=check)

def install_packages(packages):
    print("Updating package lists...")
    run_command("pkg update -y")
    print(f"Installing packages: {' '.join(packages)}")
    run_command("pkg install -y " + " ".join(packages))

def install_oh_my_zsh():
    if not shutil.which("zsh"):
        print("Zsh is not installed, installing first...")
        install_packages(["zsh"])

    if not os.path.exists(os.path.expanduser("~/.oh-my-zsh")):
        print("Installing Oh My Zsh...")
        run_command(
            'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"',
            check=False
        )
    else:
        print("Oh My Zsh already installed.")

def setup_neovim_config():
    print("Setting up basic Neovim config with vim-plug and some plugins...")

    os.makedirs(NVIM_CONFIG_DIR, exist_ok=True)

    autoload_dir = os.path.expanduser("~/.local/share/nvim/site/autoload")
    os.makedirs(autoload_dir, exist_ok=True)
    plug_path = os.path.join(autoload_dir, "plug.vim")
    if not os.path.isfile(plug_path):
        run_command(
            f"curl -fLo {plug_path} --create-dirs {VIM_PLUG_URL}"
        )
    else:
        print("vim-plug already installed.")

    init_vim_content = """
call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-sensible'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

syntax on
set number
filetype plugin indent on
    """.strip()

    with open(NVIM_INIT_FILE, "w") as f:
        f.write(init_vim_content)

    print("Neovim config written to ~/.config/nvim/init.vim")

    print("Installing Neovim plugins...")
    run_command("nvim --headless +PlugInstall +qall", check=False)

def set_default_shell_to_zsh():
    user_shell = os.environ.get("SHELL", "")
    if "zsh" not in user_shell:
        print("Setting Zsh as default shell...")
        run_command("chsh -s $(which zsh)")
        print("Zsh set as default shell. You may need to restart Termux or start a new session.")
    else:
        print("Zsh is already the default shell.")

def main():
    print("=== Termux Essentials & Dev Tools Setup ===")
    install_packages(ESSENTIALS + DEV_TOOLS)
    install_oh_my_zsh()
    set_default_shell_to_zsh()
    setup_neovim_config()
    print("\n✅ Setup complete! Restart your Termux session to use Zsh and Neovim.")

if __name__ == "__main__":
    main()
