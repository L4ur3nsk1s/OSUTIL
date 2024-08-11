import logging

class Logger:
    def __init__(self, log_file='/tmp/system_manager.log'):
        logging.basicConfig(filename=log_file, level=logging.INFO)

    @staticmethod
    def log(message):
        logging.info(message)

    @staticmethod
    def error(message):
        logging.error(message)
