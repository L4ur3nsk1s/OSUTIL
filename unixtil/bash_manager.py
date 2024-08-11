import os
from . import CommandRunner

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
