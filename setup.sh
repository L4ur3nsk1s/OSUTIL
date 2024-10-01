#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y git wget zsh bat eza nala

# Install development tools
sudo apt install -y golang rustc nodejs python3 python3-pip php
