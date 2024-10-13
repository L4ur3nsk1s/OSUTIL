@echo off
SETLOCAL

REM Check for administrator privileges
net session >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo This script requires administrative privileges. Please run as administrator.
    exit /b
)

REM Enable WSL and Virtual Machine Platform features
echo Enabling Windows Subsystem for Linux (WSL) and Virtual Machine Platform...
wsl --install

REM Wait for the installation to complete
echo Please wait while WSL installs...
timeout /t 30

REM Set the default WSL version to WSL 2
echo Setting default WSL version to 2...
wsl --set-default-version 2

REM Install Ubuntu (or any other distribution)
echo Installing Ubuntu...
wsl --install -d Ubuntu

REM Wait for the installation to complete
echo Please wait while Ubuntu installs...
timeout /t 30

REM Launch Ubuntu to set up the user
echo Launching Ubuntu for initial setup...
start wsl -d Ubuntu

REM Provide instructions for further configuration
echo.
echo The initial setup for Ubuntu is complete.
echo Please follow the prompts to create a new user account.
echo After creating a user, you can customize your environment as needed.
echo.

REM Wait for user to finish setting up the Ubuntu environment
echo Waiting for user to finish setup...
timeout /t 60

REM Install Neovim and NVChad
echo Installing Neovim and NVChad...
wsl -d Ubuntu -- bash -c "sudo apt update && sudo apt install -y neovim git"
wsl -d Ubuntu -- bash -c "git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1"

REM Copy .zshrc file to home directory
echo Copying .zshrc file...
wsl -d Ubuntu -- bash -c "echo 'export ZSH=$HOME/.config/zsh' > ~/.zshrc"
wsl -d Ubuntu -- bash -c "echo 'ZSH_THEME=\"robbyrussell\"' >> ~/.zshrc"
wsl -d Ubuntu -- bash -c "echo 'plugins=(git zsh-syntax-highlighting zsh-autosuggestions)' >> ~/.zshrc"

REM Install Zsh and Oh My Zsh
wsl -d Ubuntu -- bash -c "sudo apt install -y zsh && sh -c 'curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O && sh install.sh --unattended'"

REM Install additional commands and programming languages
echo Installing additional commands and programming languages...
wsl -d Ubuntu -- bash -c "sudo apt update && sudo apt upgrade -y && sudo apt install -y python3 python3-pip golang nodejs npm rustc"

REM Install Zsh plugins
echo Installing Zsh plugins (syntax highlighting and autosuggestions)...
wsl -d Ubuntu -- bash -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.config/zsh-syntax-highlighting"
wsl -d Ubuntu -- bash -c "git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.config/zsh-autosuggestions"

REM Append plugin configurations to .zshrc
wsl -d Ubuntu -- bash -c "echo 'source $HOME/.config/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc"
wsl -d Ubuntu -- bash -c "echo 'source $HOME/.config/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc"

echo Setup complete!
echo Please launch your Ubuntu terminal to complete Zsh configuration.
ENDLOCAL
pause
