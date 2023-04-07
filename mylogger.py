import logging


def setup_logger(logger: logging.Logger, to_level: int = logging.DEBUG, newline: str = ""):
    """Устанавливает базовые настройки логгера.

    :param logger: Логгер.
    :type logger: logging.Logger
    """
    console_handler = logging.StreamHandler()
    FORMAT = newline + "%(asctime)s — %(name)s — %(levelname)s — %(message)s"
    format = logging.Formatter(FORMAT, validate=True)
    console_handler.setFormatter(format)
    logger.addHandler(console_handler)
    logger.setLevel(to_level)