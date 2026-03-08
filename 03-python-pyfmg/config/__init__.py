"""
Configuration module for pyFMG demos.

Provides centralized logging and environment loading.
"""

import os
import logging
import sys
from pathlib import Path
from typing import Optional

from dotenv import load_dotenv


# ─────────────────────────────────────────────────────────────────────────────
# Environment Loading
# ─────────────────────────────────────────────────────────────────────────────

def find_env_file() -> Optional[Path]:
    """Search for .env file by traversing up the directory tree."""
    current = Path(__file__).parent
    for _ in range(5):
        env_path = current / ".env"
        if env_path.exists():
            return env_path
        current = current.parent
    return None


# Load .env file
_env_path = find_env_file()
if _env_path:
    load_dotenv(_env_path)


# ─────────────────────────────────────────────────────────────────────────────
# Settings
# ─────────────────────────────────────────────────────────────────────────────

FMG_HOST = os.getenv("FMG_HOST")
FMG_USER = os.getenv("FMG_USERNAME")
FMG_PASS = os.getenv("FMG_PASSWORD")
FMG_API_KEY = os.getenv("FMG_API_KEY")
FMG_ADOM = os.getenv("FMG_ADOM", "root")
FMG_VERIFY = os.getenv("FMG_VERIFY_SSL", "false").lower() == "true"
FMG_DEBUG = os.getenv("FMG_DEBUG", "false").lower() == "true"


# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

DEFAULT_LOG_FORMAT = "%(asctime)s  %(levelname)-8s  %(name)-20s  %(message)s"
DEFAULT_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

LOG_LEVELS = {
    "DEBUG": logging.DEBUG,
    "INFO": logging.INFO,
    "WARNING": logging.WARNING,
    "ERROR": logging.ERROR,
    "CRITICAL": logging.CRITICAL,
}


def get_log_level() -> int:
    """Get log level from environment."""
    if FMG_DEBUG:
        return logging.DEBUG
    level_str = os.getenv("FMG_LOG_LEVEL", "INFO").upper()
    return LOG_LEVELS.get(level_str, logging.INFO)


def setup_logging(
    level: Optional[int] = None,
    log_format: str = DEFAULT_LOG_FORMAT,
    date_format: str = DEFAULT_DATE_FORMAT,
) -> None:
    """
    Configure logging for the application.

    Args:
        level: Logging level (default: from environment or INFO)
        log_format: Log message format
        date_format: Timestamp format
    """
    if level is None:
        level = get_log_level()

    formatter = logging.Formatter(fmt=log_format, datefmt=date_format)

    root_logger = logging.getLogger()
    root_logger.setLevel(level)
    root_logger.handlers.clear()

    console_handler = logging.StreamHandler(sys.stderr)
    console_handler.setLevel(level)
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)

    # Reduce verbosity of third-party libraries
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    logging.getLogger("requests").setLevel(logging.WARNING)


def get_logger(name: str) -> logging.Logger:
    """
    Get a logger for the specified module.

    Args:
        name: Logger name (typically __name__)

    Returns:
        Configured logger instance
    """
    return logging.getLogger(name)


__all__ = [
    "FMG_HOST",
    "FMG_USER",
    "FMG_PASS",
    "FMG_API_KEY",
    "FMG_ADOM",
    "FMG_VERIFY",
    "FMG_DEBUG",
    "setup_logging",
    "get_logger",
]
