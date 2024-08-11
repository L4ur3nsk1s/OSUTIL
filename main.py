import os
import subprocess
import logging
from fnmatch import fnmatch

class CommandRunner:
    @staticmethod
    def run(command):
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        return result.stdout.strip(), result.stderr.strip() if result.stderr else None

class FileManager:
    def __init__(self, base_dir='/tmp'):
        self.base_dir = base_dir

    def _full_path(self, path):
        return os.path.join(self.base_dir, path)

    def create_directory(self, dir_name, mode=0o755):
        dir_path = self._full_path(dir_name)
        os.makedirs(dir_path, mode=mode, exist_ok=True)
        return dir_path

    def remove_directory(self, dir_name, recursive=False):
        dir_path = self._full_path(dir_name)
        command = f"rm -{'rf' if recursive else 'r'} {dir_path}"
        stdout, stderr = CommandRunner.run(command)
        return (dir_path, stderr) if stderr else (dir_path, None)

    def list_files(self, dir_name='.', pattern='*'):
        dir_path = self._full_path(dir_name)
        return [f for f in os.listdir(dir_path) if fnmatch(f, pattern)]

    def move_file(self, src, dest):
        src_path, dest_path = self._full_path(src), self._full_path(dest)
        stdout, stderr = CommandRunner.run(f"mv {src_path} {dest_path}")
        return (dest_path, stderr) if stderr else (dest_path, None)

    def copy_file(self, src, dest):
        src_path, dest_path = self._full_path(src), self._full_path(dest)
        stdout, stderr = CommandRunner.run(f"cp {src_path} {dest_path}")
        return (dest_path, stderr) if stderr else (dest_path, None)

    def delete_file(self, filename):
        filepath = self._full_path(filename)
        stdout, stderr = CommandRunner.run(f"rm {filepath}")
        return (filepath, stderr) if stderr else (filepath, None)

    def create_file(self, filename, content='', overwrite=True):
        filepath = self._full_path(filename)
        if not overwrite and os.path.exists(filepath):
            return None, "File already exists"
        with open(filepath, 'w') as f:
            f.write(content)
        return filepath

    def read_file(self, filename):
        filepath = self._full_path(filename)
        if os.path.exists(filepath):
            with open(filepath, 'r') as f:
                return f.read(), None
        return None, "File not found"

    def find_files(self, pattern='*', recursive=False):
        if recursive:
            return [os.path.join(root, file)
                    for root, _, files in os.walk(self.base_dir)
                    for file in files if fnmatch(file, pattern)]
        else:
            return self.list_files('.', pattern)

    def change_permissions(self, path, mode):
        full_path = self._full_path(path)
        os.chmod(full_path, int(mode, 8))
        return full_path

class BashScriptManager:
    def __init__(self, base_dir='/tmp'):
        self.base_dir = base_dir

    def _full_path(self, path):
        return os.path.join(self.base_dir, path)

    def create_script(self, script_name, commands):
        script_path = self._full_path(script_name)
        with open(script_path, 'w') as script_file:
            script_file.write("#!/bin/bash\n")
            script_file.write(commands)
        os.chmod(script_path, 0o755)
        return script_path

    def execute_script(self, script_name):
        script_path = self._full_path(script_name)
        if os.path.exists(script_path):
            stdout, stderr = CommandRunner.run(script_path)
            return stdout, stderr
        return None, "Script not found"

class Downloader:
    def __init__(self, download_dir='/tmp'):
        self.download_dir = download_dir

    def download_file(self, url, filename=None):
        filename = filename or os.path.basename(url)
        filepath = os.path.join(self.download_dir, filename)
        stdout, stderr = CommandRunner.run(f"wget -O {filepath} {url}")
        return (filepath, stderr) if stderr else (filepath, None)

class Logger:
    def __init__(self, log_file='/tmp/system_manager.log'):
        logging.basicConfig(filename=log_file, level=logging.INFO)

    @staticmethod
    def log(message):
        logging.info(message)

    @staticmethod
    def error(message):
        logging.error(message)

class SystemManager:
    def __init__(self):
        self.distro = self.detect_distro()

    def detect_distro(self):
        stdout, _ = CommandRunner.run("grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '\"'")
        return stdout

    def update_system(self):
        commands = {
            "ubuntu": "sudo apt-get update && sudo apt-get upgrade -y",
            "debian": "sudo apt-get update && sudo apt-get upgrade -y",
            "fedora": "sudo dnf update -y",
            "centos": "sudo dnf update -y",
            "rhel": "sudo dnf update -y",
            "arch": "sudo pacman -Syu"
        }
        command = commands.get(self.distro, None)
        return CommandRunner.run(command) if command else (None, "Unsupported Linux distribution")

    def install_package(self, package_name):
        commands = {
            "ubuntu": f"sudo apt-get install -y {package_name}",
            "debian": f"sudo apt-get install -y {package_name}",
            "fedora": f"sudo dnf install -y {package_name}",
            "centos": f"sudo dnf install -y {package_name}",
            "rhel": f"sudo dnf install -y {package_name}",
            "arch": f"sudo pacman -S {package_name}"
        }
        command = commands.get(self.distro, None)
        return CommandRunner.run(command) if command else (None, "Unsupported Linux distribution")

    def check_disk_usage(self):
        return CommandRunner.run("df -h")

    def check_memory_usage(self):
        return CommandRunner.run("free -h")

    def reboot_system(self):
        return CommandRunner.run("sudo reboot")

    def get_ip_address(self):
        stdout, _ = CommandRunner.run("curl -s ifconfig.me")
        return stdout

    def get_system_info(self):
        stdout, _ = CommandRunner.run("uname -a")
        return stdout

    def get_logged_in_users(self):
        stdout, _ = CommandRunner.run("who")
        return stdout

    def get_uptime(self):
        stdout, _ = CommandRunner.run("uptime -p")
        return stdout

