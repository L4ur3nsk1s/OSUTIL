import subprocess

class CommandRunner:
    @staticmethod
    def run(command):
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        return result.stdout.strip(), result.stderr.strip() if result.stderr else None
