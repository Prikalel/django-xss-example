import importlib
from pathlib import Path
import logging
import os
import sys


class LoggersSetup:
    console_default_level: int = logging.ERROR
    file_default_level: int = logging.NOTSET
    file_log_name: str = 'log.txt'
    FORMAT = "%(asctime)s — %(name)s — %(levelname)s — %(message)s"

    __file_handler = None

    @staticmethod
    def set_console_default_level(new_level: int):
        LoggersSetup.console_default_level = new_level

    @staticmethod
    def set_file_default_level(new_level: int):
        LoggersSetup.file_default_level = new_level

    @staticmethod
    def set_file_log_name(name: str):
        LoggersSetup.file_log_name = name

    @staticmethod
    def __get_file_handler():
        if LoggersSetup.__file_handler is None:
            LoggersSetup.__file_handler = logging.FileHandler(LoggersSetup.file_log_name, "w", "utf-8")
            LoggersSetup.__file_handler.setFormatter(logging.Formatter(LoggersSetup.FORMAT, validate=True))
            LoggersSetup.__file_handler.setLevel(LoggersSetup.file_default_level)
        return LoggersSetup.__file_handler

    @staticmethod
    def __setup_logger(logger: logging.Logger, override_console_level):
        """Устанавливает базовые настройки логгера."""
        logger.setLevel(logging.DEBUG)
        # logger.addHandler(LoggersSetup.__get_file_handler()) #<- uncomment to log to file / comment to disable.
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(logging.Formatter(LoggersSetup.FORMAT, validate=True))
        console_handler.setLevel(override_console_level or LoggersSetup.console_default_level)
        logger.addHandler(console_handler)

    @staticmethod
    def __setup_default_logger(logger_name: str, override_console_level: int = None):
        LoggersSetup.__setup_logger(logging.getLogger(logger_name), override_console_level)

    @staticmethod
    def setup_all():
        """Настраивает все логгеры."""
        main_script_path = Path(os.path.abspath(str(sys.modules['__main__'].__file__)))
        main_path = main_script_path.parent
        for module in filter(lambda x: not x.startswith('_'), sys.modules.keys()):
            r = importlib.machinery.PathFinder().find_module(module)
            if r is not None:
                module_path = Path(os.path.dirname(os.path.abspath(r.get_filename())))
                if main_path in (module_path, *module_path.parents):
                    LoggersSetup.__setup_default_logger(module)
        LoggersSetup.__setup_default_logger(main_script_path.stem, logging.INFO)
