import os
from fnmatch import fnmatch
from . import CommandRunner


class FileManager:
    def __init__(self, base_dir=''):
        self.base_dir = base_dir

    def _full_path(self, path):
        return os.path.join(self.base_dir, path)

    def create_directory(self, dir_name, mode=0o755):
        dir_path = os.path.expanduser(self._full_path(dir_name))
        os.makedirs(dir_path, mode=mode, exist_ok=True)
        return dir_path

    def remove_directory(self, dir_name, recursive=False):
        dir_path = os.path.expanduser(self._full_path(dir_name))
        command = f"rm -{'rf' if recursive else 'r'} {dir_path}"
        stdout, stderr = CommandRunner.run(command)
        return (dir_path, stderr) if stderr else (dir_path, None)

    def list_files(self, dir_name='.', pattern='*'):
        dir_path = os.path.expanduser(self._full_path(dir_name))
        return [f for f in os.listdir(dir_path) if fnmatch(f, pattern)]

    def move_file(self, src, dest):
        src_path, dest_path = os.path.expanduser(self._full_path(src)), os.path.expanduser(self._full_path(dest))
        stdout, stderr = CommandRunner.run(f"mv {src_path} {dest_path}")
        return (dest_path, stderr) if stderr else (dest_path, None)

    def copy_file(self, src, dest):
        src_path, dest_path = os.path.expanduser(self._full_path(src)), os.path.expanduser(self._full_path(dest))
        stdout, stderr = CommandRunner.run(f"cp {src_path} {dest_path}")
        return (dest_path, stderr) if stderr else (dest_path, None)

    def delete_file(self, filename):
        filepath = os.path.expanduser(self._full_path(filename))
        stdout, stderr = CommandRunner.run(f"rm {filepath}")
        return (filepath, stderr) if stderr else (filepath, None)

    def create_file(self, filename, content='', overwrite=True):
        filepath = os.path.expanduser(self._full_path(filename))
        if not overwrite and os.path.exists(filepath):
            return None, "File already exists"
        with open(filepath, 'w') as f:
            f.write(content)
        return filepath

    def read_file(self, filename):
        filepath = os.path.expanduser(self._full_path(filename))
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
        full_path = os.path.expanduser(self._full_path(path))
        os.chmod(full_path, int(mode, 8))
        return full_path
