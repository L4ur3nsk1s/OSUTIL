import datetime

class CustomPrinter:
    # ANSI escape codes for text formatting
    COLORS = {
        'reset': '\033[0m',
        'black': '\033[30m',
        'red': '\033[31m',
        'green': '\033[32m',
        'yellow': '\033[33m',
        'blue': '\033[34m',
        'magenta': '\033[35m',
        'cyan': '\033[36m',
        'white': '\033[37m',
        'bold': '\033[1m',
        'underline': '\033[4m'
    }

    def __init__(self, show_timestamp=True, show_level=True):
        self.show_timestamp = show_timestamp
        self.show_level = show_level

    def _format_message(self, message, level, color):
        timestamp = f"[{self._get_timestamp()}] " if self.show_timestamp else ""
        level_prefix = f"[{level}] " if self.show_level else ""
        color_code = self.COLORS.get(color, self.COLORS['reset'])
        return f"{color_code}{timestamp}{level_prefix}{message}{self.COLORS['reset']}"

    def _get_timestamp(self):
        return datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def print(self, message, level='INFO', color='reset'):
        formatted_message = self._format_message(message, level, color)
        print(formatted_message)