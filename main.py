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

printer.print("Starting script...", level="INFO", color="blue")

# Install Zsh
printer.print("Installing Zsh...", level="INFO", color="blue")
stdout, stderr = system_manager.install_package('zsh')
printer.print(f"Zsh Installation: {stdout}", level="INFO", color="green")
if stderr:
    printer.print(f"Error installing Zsh: {stderr}", level="ERROR", color="red")

# Install Oh My Zsh
printer.print("Installing Oh My Zsh...", level="INFO", color="blue")
ohmyzsh_install_script = 'https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh'
stdout, stderr = CommandRunner.run(f"sh -c \"$(curl -fsSL {ohmyzsh_install_script})\"")
printer.print(f"Oh My Zsh Installation: {stdout}", level="INFO", color="green")
if stderr:
    printer.print(f"Error installing Oh My Zsh: {stderr}", level="ERROR", color="red")

# Update .zshrc with a custom configuration (optional)
zshrc_file = os.path.expanduser('~/.zshrc')
custom_zshrc_content = '''
# Custom Zsh configuration

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Set the theme
ZSH_THEME="agnoster"

# Enable plugins
plugins=(git z)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Custom aliases
alias ll='ls -la'
alias gs='git status'
'''

# Create or overwrite the .zshrc file
printer.print("Updating .zshrc with custom configuration...", level="INFO", color="blue")
zshrc_file_path = file_manager.create_file(zshrc_file, content=custom_zshrc_content, overwrite=True)
printer.print(f"Updated .zshrc File: {zshrc_file_path}", level="INFO", color="green")

# Change the default shell to Zsh
printer.print("Changing default shell to Zsh...", level="INFO", color="blue")
stdout, stderr = CommandRunner.run('chsh -s $(which zsh)')
printer.print(f"Change Default Shell to Zsh: {stdout}", level="INFO", color="green")
if stderr:
    printer.print(f"Error changing default shell: {stderr}", level="ERROR", color="red")

# Inform the user
printer.print("Zsh and Oh My Zsh setup complete. Please restart your terminal or log out and log back in to apply changes.", level="COMPLETE", color="green")
