"""
Centralized configuration for FortiManager API

Loads settings from environment variables
or the .env file at the project root.
"""

import os
from pathlib import Path
from dataclasses import dataclass
from typing import Optional

from dotenv import load_dotenv


# Search for .env file in parent directories
def find_env_file() -> Optional[Path]:
    """Search for .env file by traversing up the directory tree."""
    current = Path(__file__).parent
    for _ in range(5):  # Go up max 5 levels
        env_path = current / ".env"
        if env_path.exists():
            return env_path
        current = current.parent
    return None


# Load .env file
env_path = find_env_file()
if env_path:
    load_dotenv(env_path)


@dataclass
class Settings:
    """FortiManager configuration."""

    host: str
    port: int
    username: str
    password: str
    api_key: Optional[str]
    adom: str
    verify_ssl: bool
    debug: bool

    @property
    def base_url(self) -> str:
        """API base URL."""
        return f"https://{self.host}:{self.port}/jsonrpc"


def get_settings() -> Settings:
    """
    Load configuration from environment variables.

    Returns:
        Settings: FortiManager configuration

    Raises:
        ValueError: If required parameters are missing
    """
    host = os.getenv("FMG_HOST")
    if not host:
        raise ValueError(
            "FMG_HOST not defined. "
            "Create a .env file with FMG_HOST=<fortimanager_ip>"
        )

    return Settings(
        host=host,
        port=int(os.getenv("FMG_PORT", "443")),
        username=os.getenv("FMG_USERNAME", ""),
        password=os.getenv("FMG_PASSWORD", ""),
        api_key=os.getenv("FMG_API_KEY"),
        adom=os.getenv("FMG_ADOM", "root"),
        verify_ssl=os.getenv("FMG_VERIFY_SSL", "true").lower() == "true",
        debug=os.getenv("FMG_DEBUG", "false").lower() == "true",
    )
