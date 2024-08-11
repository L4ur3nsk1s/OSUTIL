import os
from . import CommandRunner

class Downloader:
    def __init__(self, download_dir='/tmp'):
        self.download_dir = download_dir

    def download_file(self, url, filename=None):
        filename = filename or os.path.basename(url)
        filepath = os.path.join(self.download_dir, filename)
        stdout, stderr = CommandRunner.run(f"wget -O {filepath} {url}")
        return (filepath, stderr) if stderr else (filepath, None)
