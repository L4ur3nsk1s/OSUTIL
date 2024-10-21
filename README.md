
# Initialization Scripts for Linux-like Systems

This repository contains various initialization scripts designed for Linux-like environments, such as Termux and Windows Subsystem for Linux (WSL). These scripts automate the setup process for essential tools and configurations.

## Table of Contents
- [Linux Initialization Scripts](#linux-initialization-scripts)
  - [Termux UI Script](#termux-ui-script)
  - [Essential Setup Script](#essential-setup-script)
  - [Neovim Setup Script](#neovim-setup-script)
  - [Zsh Setup Script](#zsh-setup-script)
  - [WSL Setup Script](#wsl-setup-script)

## Linux Initialization Scripts

### Termux UI Script
This script configures the Termux UI settings. You can run the following command to download, make it executable, and run it:

```bash
curl -O https://raw.githubusercontent.com/L4ur3nsk1s/OSUTIL/main/termux-ui.sh && chmod +x termux-ui.sh && ./termux-ui.sh
```

### Essential Setup Script
This script installs the basic packages and configurations required for setting up the environment:

```bash
curl -O https://raw.githubusercontent.com/L4ur3nsk1s/OSUTIL/main/essentials.sh && chmod +x essentials.sh && ./essentials.sh
```

### Neovim Setup Script
This script installs and configures Neovim along with plugins and custom settings:

```bash
curl -O https://raw.githubusercontent.com/L4ur3nsk1s/OSUTIL/main/scripts/nvim.sh && chmod +x scripts/nvim.sh && ./scripts/nvim.sh
```

### Zsh Setup Script
This script sets up Zsh with Oh My Zsh and additional plugins and themes:

```bash
curl -O https://raw.githubusercontent.com/L4ur3nsk1s/OSUTIL/main/scripts/zsh.sh && chmod +x scripts/zsh.sh && ./scripts/zsh.sh
```

### WSL Setup Script
For setting up your WSL environment with necessary configurations, use this script:

```bash
curl -O https://raw.githubusercontent.com/L4ur3nsk1s/OSUTIL/main/scripts/wsl.sh && chmod +x scripts/wsl.sh && ./scripts/wsl.sh
```

---

This structure includes the new files and provides the same user-friendly approach for downloading, making them executable, and running each script.