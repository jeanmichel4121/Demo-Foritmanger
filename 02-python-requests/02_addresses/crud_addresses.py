#!/usr/bin/env python3
"""
CRUD Addresses with Python requests

This module demonstrates CRUD operations on FortiManager address objects
using the FortiManagerClient class.
"""

import sys
from pathlib import Path
from typing import Optional, List, Dict, Any

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from config import setup_logging, get_logger
from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGObjectExistsError, FMGObjectNotFoundError


# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

setup_logging()
log = get_logger(__name__)


# ─────────────────────────────────────────────────────────────────────────────
# Address Manager
# ─────────────────────────────────────────────────────────────────────────────

class AddressManager:
    """
    FortiManager address manager.

    Encapsulates CRUD operations for firewall address objects.
    """

    def __init__(self, fmg: FortiManagerClient):
        """
        Initialize the manager.

        Args:
            fmg: Connected FortiManager client
        """
        self.fmg = fmg
        self.base_url = fmg.get_adom_url("obj/firewall/address")
        self._log = get_logger(f"{__name__}.AddressManager")

    def create(
        self,
        name: str,
        subnet: str,
        comment: str = "",
        type: str = "ipmask",
    ) -> Dict[str, Any]:
        """
        Create a new IPv4 address.

        Args:
            name: Unique address name
            subnet: Subnet (format: "10.0.0.0 255.255.255.0" or "10.0.0.0/24")
            comment: Optional comment
            type: Address type (ipmask, iprange, fqdn, etc.)

        Returns:
            Creation result

        Raises:
            FMGObjectExistsError: If address already exists
        """
        # Convert CIDR to IP MASK format if needed
        if "/" in subnet:
            subnet = self._cidr_to_mask(subnet)

        data = {
            "name": name,
            "type": type,
            "subnet": subnet,
            "allow-routing": "disable",
            "visibility": "enable",
        }

        if comment:
            data["comment"] = comment

        self._log.info("Creating address '%s' with subnet %s", name, subnet)
        result = self.fmg.add(self.base_url, data)
        self._log.info("Address '%s' created successfully", name)
        return result

    def read(
        self,
        name: Optional[str] = None,
        filter_pattern: Optional[str] = None,
        fields: Optional[List[str]] = None,
    ) -> List[Dict[str, Any]]:
        """
        Read one or more addresses.

        Args:
            name: Exact address name (optional)
            filter_pattern: Filter pattern (e.g., "NET_*")
            fields: Fields to return

        Returns:
            List of addresses
        """
        url = f"{self.base_url}/{name}" if name else self.base_url

        kwargs = {}
        if fields:
            kwargs["fields"] = fields
        if filter_pattern:
            # Convert wildcard to FMG format
            pattern = filter_pattern.replace("*", "%")
            kwargs["filter"] = [["name", "like", pattern]]

        self._log.debug("Reading addresses from %s with kwargs: %s", url, kwargs)
        result = self.fmg.get(url, **kwargs)

        # Normalize to list
        if result is None:
            return []
        if not isinstance(result, list):
            return [result]
        return result

    def update(self, name: str, **updates) -> Dict[str, Any]:
        """
        Update an existing address.

        Args:
            name: Address name
            **updates: Fields to modify

        Returns:
            Update result

        Raises:
            FMGObjectNotFoundError: If address doesn't exist
        """
        url = f"{self.base_url}/{name}"

        # Convert subnet if present
        if "subnet" in updates and "/" in updates["subnet"]:
            updates["subnet"] = self._cidr_to_mask(updates["subnet"])

        self._log.info("Updating address '%s' with: %s", name, updates)
        result = self.fmg.update(url, updates)
        self._log.info("Address '%s' updated successfully", name)
        return result

    def delete(self, name: str) -> Dict[str, Any]:
        """
        Delete an address.

        Args:
            name: Address name

        Returns:
            Deletion result

        Raises:
            FMGObjectNotFoundError: If address doesn't exist
        """
        url = f"{self.base_url}/{name}"

        self._log.info("Deleting address '%s'", name)
        result = self.fmg.delete(url)
        self._log.info("Address '%s' deleted successfully", name)
        return result

    @staticmethod
    def _cidr_to_mask(cidr: str) -> str:
        """Convert CIDR notation to IP MASK."""
        ip, bits = cidr.split("/")
        bits = int(bits)
        mask = (0xFFFFFFFF << (32 - bits)) & 0xFFFFFFFF
        mask_str = ".".join(str((mask >> (8 * i)) & 0xFF) for i in range(3, -1, -1))
        return f"{ip} {mask_str}"


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo_crud():
    """Complete CRUD operations demonstration."""

    log.info("=" * 60)
    log.info("DEMO CRUD ADDRESSES")
    log.info("=" * 60)

    with FortiManagerClient() as fmg:
        mgr = AddressManager(fmg)

        # CREATE
        log.info("--- CREATE ---")
        try:
            mgr.create(
                name="DEMO_NET_WEB",
                subnet="192.168.10.0/24",
                comment="Demo - Web servers",
            )
            mgr.create(
                name="DEMO_NET_DB",
                subnet="192.168.20.0/24",
                comment="Demo - Database servers",
            )
        except FMGObjectExistsError as e:
            log.warning("Address already exists: %s", e)

        # READ
        log.info("--- READ ---")
        addresses = mgr.read(
            filter_pattern="DEMO_*",
            fields=["name", "subnet", "comment"],
        )
        log.info("Addresses found: %d", len(addresses))
        for addr in addresses:
            subnet = addr.get("subnet", [])
            if isinstance(subnet, list):
                subnet = " ".join(subnet)
            log.info("  - %s: %s", addr["name"], subnet)

        # UPDATE
        log.info("--- UPDATE ---")
        try:
            mgr.update("DEMO_NET_WEB", comment="Demo - Web servers PRODUCTION")
        except FMGObjectNotFoundError as e:
            log.warning("Address not found: %s", e)

        # DELETE
        log.info("--- DELETE ---")
        for name in ["DEMO_NET_WEB", "DEMO_NET_DB"]:
            try:
                mgr.delete(name)
            except FMGObjectNotFoundError as e:
                log.warning("Address not found: %s", e)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_crud()
    log.info("Demo completed successfully")
