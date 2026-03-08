"""
FortiManager JSON-RPC client using requests

This module provides a class to interact with the FortiManager API
using only the standard requests library.

Usage:
    from utils.fmg_client import FortiManagerClient

    # With session (context manager)
    with FortiManagerClient() as fmg:
        addresses = fmg.get("/pm/config/adom/root/obj/firewall/address")

    # With API Key
    fmg = FortiManagerClient(use_api_key=True)
    addresses = fmg.get("/pm/config/adom/root/obj/firewall/address")
"""

import json
import requests
import urllib3
from typing import Optional, Dict, Any, List, Union

from config.settings import get_settings, Settings
from .exceptions import (
    FMGError,
    FMGAuthError,
    FMGRequestError,
    FMGObjectNotFoundError,
    FMGObjectExistsError,
    FMGPermissionError,
)


class FortiManagerClient:
    """
    Client for FortiManager JSON-RPC API.

    Supports session-based authentication (login/logout) or API Key (Bearer).
    Implements context manager for clean session handling.

    Attributes:
        settings: FortiManager configuration
        session: Active session token (if session-based)
        use_api_key: True if using Bearer token

    Example:
        >>> with FortiManagerClient() as fmg:
        ...     result = fmg.get("/pm/config/adom/root/obj/firewall/address")
        ...     print(f"Found {len(result)} addresses")
    """

    # Error code to exception mapping
    ERROR_MAPPING = {
        -2: FMGObjectNotFoundError,
        -3: FMGObjectExistsError,
        -6: FMGPermissionError,
        -11: FMGAuthError,
    }

    def __init__(self, use_api_key: bool = False, settings: Optional[Settings] = None):
        """
        Initialize the FortiManager client.

        Args:
            use_api_key: If True, use API Key instead of session login
            settings: Configuration (loads from .env if not provided)
        """
        self.settings = settings or get_settings()
        self.use_api_key = use_api_key
        self.session: Optional[str] = None
        self._request_id = 0

        # Disable SSL warnings if needed
        if not self.settings.verify_ssl:
            urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

    def __enter__(self) -> "FortiManagerClient":
        """Context manager: automatic login."""
        if not self.use_api_key:
            self.login()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        """Context manager: automatic logout."""
        if not self.use_api_key and self.session:
            try:
                self.logout()
            except Exception:
                pass  # Ignore logout errors

    def _get_request_id(self) -> int:
        """Generate a unique ID for each request."""
        self._request_id += 1
        return self._request_id

    def _build_headers(self) -> Dict[str, str]:
        """Build HTTP headers."""
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        if self.use_api_key and self.settings.api_key:
            headers["Authorization"] = f"Bearer {self.settings.api_key}"
        return headers

    def _handle_error(self, code: int, message: str, url: str) -> None:
        """
        Handle API errors by raising the appropriate exception.

        Args:
            code: Error code returned by the API
            message: Error message
            url: Request URL (to extract object name)
        """
        # Extract object name if possible
        parts = url.rstrip("/").split("/")
        object_name = parts[-1] if parts else "unknown"

        # Specific exceptions
        if code == -2:
            raise FMGObjectNotFoundError(object_name)
        elif code == -3:
            raise FMGObjectExistsError(object_name)
        elif code == -6:
            raise FMGPermissionError(message)
        elif code == -11:
            raise FMGAuthError(message)
        else:
            raise FMGRequestError(message, code)

    def _send_request(
        self,
        method: str,
        url: str,
        data: Optional[Dict] = None,
        **kwargs,
    ) -> Any:
        """
        Send a JSON-RPC request to FortiManager.

        Args:
            method: JSON-RPC method (get, add, set, update, delete, exec)
            url: FMG object URL
            data: Data to send
            **kwargs: Additional options (filter, fields, etc.)

        Returns:
            Response data

        Raises:
            FMGRequestError: If the request fails
            FMGAuthError: If authentication fails
        """
        params: Dict[str, Any] = {"url": url}

        if data is not None:
            params["data"] = data

        # Add options
        for key, value in kwargs.items():
            if value is not None:
                params[key] = value

        payload: Dict[str, Any] = {
            "id": self._get_request_id(),
            "method": method,
            "params": [params],
        }

        # Add session if not using API Key
        if not self.use_api_key and self.session:
            payload["session"] = self.session

        # Debug
        if self.settings.debug:
            print(f"\n>>> REQUEST >>>\n{json.dumps(payload, indent=2)}")

        # Send request
        response = requests.post(
            self.settings.base_url,
            json=payload,
            headers=self._build_headers(),
            verify=self.settings.verify_ssl,
        )
        response.raise_for_status()

        result = response.json()

        # Debug
        if self.settings.debug:
            print(f"\n<<< RESPONSE <<<\n{json.dumps(result, indent=2)}")

        # Check response status
        if "result" in result and result["result"]:
            status = result["result"][0].get("status", {})
            code = status.get("code", 0)

            if code != 0:
                self._handle_error(code, status.get("message", "Unknown error"), url)

            return result["result"][0].get("data")

        return result

    def login(self) -> str:
        """
        Session-based authentication.

        Returns:
            Session token

        Raises:
            FMGAuthError: If authentication fails
            ValueError: If username/password not configured
        """
        if not self.settings.username or not self.settings.password:
            raise ValueError(
                "FMG_USERNAME and FMG_PASSWORD required for session authentication"
            )

        payload = {
            "id": self._get_request_id(),
            "method": "exec",
            "params": [
                {
                    "url": "/sys/login/user",
                    "data": {
                        "user": self.settings.username,
                        "passwd": self.settings.password,
                    },
                }
            ],
        }

        response = requests.post(
            self.settings.base_url,
            json=payload,
            headers=self._build_headers(),
            verify=self.settings.verify_ssl,
        )
        response.raise_for_status()

        result = response.json()

        # Check status
        if result.get("result", [{}])[0].get("status", {}).get("code") != 0:
            raise FMGAuthError("Authentication failed - check credentials")

        self.session = result.get("session")
        if not self.session:
            raise FMGAuthError("No session token in response")

        return self.session

    def logout(self) -> None:
        """Clean session logout."""
        if self.session:
            try:
                self._send_request("exec", "/sys/logout")
            finally:
                self.session = None

    # ==========================================================================
    # Simplified CRUD methods
    # ==========================================================================

    def get(
        self,
        url: str,
        fields: Optional[List[str]] = None,
        filter: Optional[List] = None,
        **kwargs,
    ) -> Any:
        """
        Retrieve one or more objects.

        Args:
            url: Object or collection URL
            fields: List of fields to return
            filter: Filter in format [["name", "like", "NET_%"]]
            **kwargs: Additional options

        Returns:
            Object or list of objects

        Example:
            >>> fmg.get("/pm/config/adom/root/obj/firewall/address")
            >>> fmg.get("/pm/config/adom/root/obj/firewall/address/MY_ADDR")
            >>> fmg.get("/pm/config/adom/root/obj/firewall/address",
            ...         filter=[["name", "like", "NET_%"]])
        """
        return self._send_request(
            "get", url, fields=fields, filter=filter, **kwargs
        )

    def add(self, url: str, data: Dict) -> Any:
        """
        Create a new object.

        Args:
            url: Collection URL
            data: Object data to create

        Returns:
            Creation result

        Example:
            >>> fmg.add("/pm/config/adom/root/obj/firewall/address",
            ...         {"name": "TEST", "type": "ipmask", "subnet": "10.0.0.0 255.255.255.0"})
        """
        return self._send_request("add", url, data=data)

    def set(self, url: str, data: Dict) -> Any:
        """
        Update an object (complete overwrite).

        Args:
            url: Object URL
            data: New data

        Returns:
            Update result
        """
        return self._send_request("set", url, data=data)

    def update(self, url: str, data: Dict) -> Any:
        """
        Partially update an object.

        Args:
            url: Object URL
            data: Fields to modify

        Returns:
            Update result

        Example:
            >>> fmg.update("/pm/config/adom/root/obj/firewall/address/MY_ADDR",
            ...            {"comment": "New comment"})
        """
        return self._send_request("update", url, data=data)

    def delete(self, url: str) -> Any:
        """
        Delete an object.

        Args:
            url: Object URL

        Returns:
            Deletion result

        Example:
            >>> fmg.delete("/pm/config/adom/root/obj/firewall/address/MY_ADDR")
        """
        return self._send_request("delete", url)

    def execute(self, url: str, data: Optional[Dict] = None) -> Any:
        """
        Execute an action (install, move, etc.).

        Args:
            url: Action URL
            data: Action data

        Returns:
            Execution result

        Example:
            >>> fmg.execute("/securityconsole/install/package",
            ...             {"adom": "root", "pkg": "default"})
        """
        return self._send_request("exec", url, data=data)

    # ==========================================================================
    # Utility methods
    # ==========================================================================

    def get_adom_url(self, path: str) -> str:
        """
        Build the complete URL with configured ADOM.

        Args:
            path: Relative path (e.g., "obj/firewall/address")

        Returns:
            Complete URL

        Example:
            >>> fmg.get_adom_url("obj/firewall/address")
            '/pm/config/adom/root/obj/firewall/address'
        """
        return f"/pm/config/adom/{self.settings.adom}/{path}"
