from . import CommandRunner

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
