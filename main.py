import os
import subprocess
import logging
from fnmatch import fnmatch
from datetime import datetime
import hashlib

# Command Execution
class CommandRunner:
    @staticmethod
    def run(command):
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
            return result.stdout.strip(), None
        except subprocess.CalledProcessError as e:
            return e.stdout.strip(), e.stderr.strip()

# File Management
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
        return CommandRunner.run(command)

    def list_files(self, dir_name='.', pattern='*'):
        dir_path = self._full_path(dir_name)
        return [f for f in os.listdir(dir_path) if fnmatch(f, pattern)]

    def move_file(self, src, dest):
        return self._execute_file_operation('mv', src, dest)

    def copy_file(self, src, dest):
        return self._execute_file_operation('cp', src, dest)

    def delete_file(self, filename):
        filepath = self._full_path(filename)
        return CommandRunner.run(f"rm {filepath}")

    def create_file(self, filename, content='', overwrite=True):
        filepath = self._full_path(filename)
        if not overwrite and os.path.exists(filepath):
            return None, "File already exists"
        with open(filepath, 'w') as f:
            f.write(content)
        return filepath, None

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
        return self.list_files('.', pattern)

    def change_permissions(self, path, mode):
        full_path = self._full_path(path)
        os.chmod(full_path, int(mode, 8))
        return full_path

    def get_file_size(self, filename):
        filepath = self._full_path(filename)
        if os.path.exists(filepath):
            return os.path.getsize(filepath)
        return None

    def calculate_md5_checksum(self, filename):
        filepath = self._full_path(filename)
        if os.path.exists(filepath):
            with open(filepath, 'rb') as f:
                file_hash = hashlib.md5()
                while chunk := f.read(8192):
                    file_hash.update(chunk)
            return file_hash.hexdigest()
        return None

    def _execute_file_operation(self, operation, src, dest):
        src_path, dest_path = self._full_path(src), self._full_path(dest)
        return CommandRunner.run(f"{operation} {src_path} {dest_path}")

# Bash Script Management
class BashScriptManager:
    def __init__(self, base_dir='/tmp'):
        self.base_dir = base_dir

    def _full_path(self, path):
        return os.path.join(self.base_dir, path)

    def create_script(self, script_name, commands):
        script_path = self._full_path(script_name)
        with open(script_path, 'w') as script_file:
            script_file.write(f"#!/bin/bash\n{commands}")
        os.chmod(script_path, 0o755)
        return script_path

    def execute_script(self, script_name):
        script_path = self._full_path(script_name)
        if os.path.exists(script_path):
            return CommandRunner.run(script_path)
        return None, "Script not found"

# Download Management
class Downloader:
    def __init__(self, download_dir='/tmp'):
        self.download_dir = download_dir

    def download_file(self, url, filename=None):
        filename = filename or os.path.basename(url)
        filepath = os.path.join(self.download_dir, filename)
        return CommandRunner.run(f"wget -O {filepath} {url}")

# Logging
class Logger:
    def __init__(self, log_file='/tmp/system_manager.log'):
        logging.basicConfig(filename=log_file, level=logging.INFO)

    @staticmethod
    def log(message):
        logging.info(message)

    @staticmethod
    def error(message):
        logging.error(message)

# System Management
class SystemManager:
    DISTRO_COMMANDS = {
        "ubuntu": {
            "update": "sudo apt-get update && sudo apt-get upgrade -y",
            "install": "sudo apt-get install -y"
        },
        "debian": {
            "update": "sudo apt-get update && sudo apt-get upgrade -y",
            "install": "sudo apt-get install -y"
        },
        "fedora": {
            "update": "sudo dnf update -y",
            "install": "sudo dnf install -y"
        },
        "centos": {
            "update": "sudo dnf update -y",
            "install": "sudo dnf install -y"
        },
        "rhel": {
            "update": "sudo dnf update -y",
            "install": "sudo dnf install -y"
        },
        "arch": {
            "update": "sudo pacman -Syu",
            "install": "sudo pacman -S"
        }
    }

    def __init__(self):
        self.distro = self.detect_distro()

    def detect_distro(self):
        stdout, _ = CommandRunner.run("grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '\"'")
        return stdout

    def update_system(self):
        command = self._get_command('update')
        return CommandRunner.run(command) if command else (None, "Unsupported Linux distribution")

    def install_package(self, package_name):
        command = self._get_command('install', package_name)
        return CommandRunner.run(command) if command else (None, "Unsupported Linux distribution")

    def _get_command(self, action, package_name=None):
        distro_commands = self.DISTRO_COMMANDS.get(self.distro)
        if not distro_commands:
            return None
        command = distro_commands.get(action)
        if package_name and action == 'install':
            command += f" {package_name}"
        return command

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

# Network Management
class NetworkManager:
    @staticmethod
    def get_network_interfaces():
        return CommandRunner.run("ip a")

    @staticmethod
    def restart_network_service():
        stdout, stderr = CommandRunner.run("sudo systemctl restart network.service")
        return stdout, stderr

    @staticmethod
    def get_default_gateway():
        return CommandRunner.run("ip route | grep default")

# Service Management
class ServiceManager:
    @staticmethod
    def start_service(service_name):
        return CommandRunner.run(f"sudo systemctl start {service_name}")

    @staticmethod
    def stop_service(service_name):
        return CommandRunner.run(f"sudo systemctl stop {service_name}")

    @staticmethod
    def restart_service(service_name):
        return CommandRunner.run(f"sudo systemctl restart {service_name}")

    @staticmethod
    def check_service_status(service_name):
        return CommandRunner.run(f"systemctl status {service_name}")

# Process Management
class ProcessManager:
    @staticmethod
    def list_processes():
        return CommandRunner.run("ps aux")

    @staticmethod
    def kill_process(pid):
        return CommandRunner.run(f"kill {pid}")

    @staticmethod
    def kill_process_by_name(process_name):
        return CommandRunner.run(f"pkill {process_name}")

    @staticmethod
    def get_process_info(pid):
        return CommandRunner.run(f"ps -p {pid} -o pid,ppid,cmd")

# Archive Management
class ArchiveManager:
    @staticmethod
    def create_archive(archive_name, *files):
        files_str = ' '.join(files)
        return CommandRunner.run(f"tar -czf {archive_name} {files_str}")

    @staticmethod
    def extract_archive(archive_name, dest_dir):
        return CommandRunner.run(f"tar -xzf {archive_name} -C {dest_dir}")

    @staticmethod
    def list_archive_contents(archive_name):
        return CommandRunner.run(f"tar -tf {archive_name}")

# Cron Job Management
class CronJobManager:
    @staticmethod
    def list_cron_jobs(user=None):
        user_option = f"-u {user}" if user else ""
        return CommandRunner.run(f"crontab {user_option} -l")

    @staticmethod
    def add_cron_job(job, user=None):
        current_jobs, _ = CronJobManager.list_cron_jobs(user)
        new_jobs = current_jobs + f"\n{job}"
        return CommandRunner.run(f"echo '{new_jobs}' | crontab {user_option}")

    @staticmethod
    def remove_cron_job(job, user=None):
        user_option = f"-u {user}" if user else ""
        current_jobs, _ = CronJobManager.list_cron_jobs(user)
        updated_jobs = "\n".join(line for line in current_jobs.splitlines() if line != job)
        return CommandRunner.run(f"echo '{updated_jobs}' | crontab {user_option}")

# User Management
class UserManager:
    @staticmethod
    def create_user(username, password=None):
        command = f"sudo useradd {username}"
        if password:
            command += f" && echo '{username}:{password}' | sudo chpasswd"
        return CommandRunner.run(command)

    @staticmethod
    def delete_user(username):
        return CommandRunner.run(f"sudo userdel -r {username}")

    @staticmethod
    def list_users():
        return CommandRunner.run("cut -d: -f1 /etc/passwd")

    @staticmethod
    def change_user_password(username, new_password):
        return CommandRunner.run(f"echo '{username}:{new_password}' | sudo chpasswd")

# System Log Management
class SystemLogManager:
    @staticmethod
    def get_system_logs():
        return CommandRunner.run("journalctl")

    @staticmethod
    def search_logs(keyword):
        return CommandRunner.run(f"journalctl | grep {keyword}")

    @staticmethod
    def get_recent_logs(lines=100):
        return CommandRunner.run(f"journalctl -n {lines}")

# Permission Management
class PermissionManager:
    @staticmethod
    def set_permissions(path, mode):
        return CommandRunner.run(f"chmod {mode} {path}")

    @staticmethod
    def set_ownership(path, user, group):
        return CommandRunner.run(f"chown {user}:{group} {path}")

# Utility Functions
def get_current_timestamp():
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S')

def ensure_directory_exists(dir_path):
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)

def get_file_extension(filename):
    return os.path.splitext(filename)[1]

def write_to_file(filepath, content):
    with open(filepath, 'w') as file:
        file.write(content)

def read_from_file(filepath):
    with open(filepath, 'r') as file:
        return file.read()

def get_environment_variable(var_name):
    return os.getenv(var_name)

