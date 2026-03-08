"""
Centralized logging configuration for FortiManager API client.

Provides consistent logging setup across all modules with:
- Console and optional file output
- Configurable log levels via environment
- Structured format with timestamps
- Module-specific loggers

Usage:
    from config.logging_config import setup_logging, get_logger

    # Setup once at application start
    setup_logging()

    # Get logger in each module
    log = get_logger(__name__)
    log.info("Operation completed")
"""

import logging
import os
import sys
from typing import Optional


# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

DEFAULT_LOG_LEVEL = "INFO"
DEFAULT_LOG_FORMAT = "%(asctime)s  %(levelname)-8s  %(name)-20s  %(message)s"
DEFAULT_DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

# Mapping string levels to logging constants
LOG_LEVELS = {
    "DEBUG": logging.DEBUG,
    "INFO": logging.INFO,
    "WARNING": logging.WARNING,
    "ERROR": logging.ERROR,
    "CRITICAL": logging.CRITICAL,
}


# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

def get_log_level() -> int:
    """
    Get log level from environment variable.

    Environment:
        FMG_LOG_LEVEL: DEBUG, INFO, WARNING, ERROR, CRITICAL (default: INFO)
        FMG_DEBUG: If 'true', sets level to DEBUG (for backwards compatibility)

    Returns:
        Logging level constant
    """
    # Check FMG_DEBUG first for backwards compatibility
    if os.getenv("FMG_DEBUG", "").lower() == "true":
        return logging.DEBUG

    level_str = os.getenv("FMG_LOG_LEVEL", DEFAULT_LOG_LEVEL).upper()
    return LOG_LEVELS.get(level_str, logging.INFO)


def setup_logging(
    level: Optional[int] = None,
    log_file: Optional[str] = None,
    log_format: str = DEFAULT_LOG_FORMAT,
    date_format: str = DEFAULT_DATE_FORMAT,
) -> None:
    """
    Configure logging for the application.

    Should be called once at application startup before any logging occurs.

    Args:
        level: Logging level (default: from environment or INFO)
        log_file: Optional file path to write logs
        log_format: Log message format
        date_format: Timestamp format

    Example:
        >>> setup_logging()  # Use defaults from environment
        >>> setup_logging(level=logging.DEBUG)  # Force debug level
        >>> setup_logging(log_file="/var/log/fmg.log")  # Also write to file
    """
    if level is None:
        level = get_log_level()

    # Create formatter
    formatter = logging.Formatter(fmt=log_format, datefmt=date_format)

    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(level)

    # Remove existing handlers to avoid duplicates
    root_logger.handlers.clear()

    # Console handler (stderr)
    console_handler = logging.StreamHandler(sys.stderr)
    console_handler.setLevel(level)
    console_handler.setFormatter(formatter)
    root_logger.addHandler(console_handler)

    # File handler (optional)
    if log_file:
        file_handler = logging.FileHandler(log_file, encoding="utf-8")
        file_handler.setLevel(level)
        file_handler.setFormatter(formatter)
        root_logger.addHandler(file_handler)

    # Reduce verbosity of third-party libraries
    logging.getLogger("urllib3").setLevel(logging.WARNING)
    logging.getLogger("requests").setLevel(logging.WARNING)


def get_logger(name: str) -> logging.Logger:
    """
    Get a logger for the specified module.

    Use __name__ as the argument to get a module-specific logger.

    Args:
        name: Logger name (typically __name__)

    Returns:
        Configured logger instance

    Example:
        >>> log = get_logger(__name__)
        >>> log.info("Processing started")
        >>> log.debug("Detailed info: %s", data)
        >>> log.error("Operation failed: %s", error)
    """
    return logging.getLogger(name)


# ─────────────────────────────────────────────────────────────────────────────
# Convenience functions
# ─────────────────────────────────────────────────────────────────────────────

def mask_sensitive(data: dict, keys: tuple = ("passwd", "password", "api_key", "session")) -> dict:
    """
    Mask sensitive values in a dictionary for safe logging.

    Args:
        data: Dictionary potentially containing sensitive data
        keys: Tuple of keys to mask

    Returns:
        Copy of dictionary with sensitive values masked

    Example:
        >>> payload = {"user": "admin", "passwd": "secret123"}
        >>> log.debug("Request: %s", mask_sensitive(payload))
        # Output: Request: {'user': 'admin', 'passwd': '***'}
    """
    if not isinstance(data, dict):
        return data

    masked = data.copy()
    for key in keys:
        if key in masked:
            masked[key] = "***"

    # Handle nested data
    if "data" in masked and isinstance(masked["data"], dict):
        masked["data"] = mask_sensitive(masked["data"], keys)

    if "params" in masked and isinstance(masked["params"], list):
        masked["params"] = [
            mask_sensitive(p, keys) if isinstance(p, dict) else p
            for p in masked["params"]
        ]

    return masked
