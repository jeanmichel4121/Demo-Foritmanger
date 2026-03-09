#!/usr/bin/env python3
"""
CRUD IP Pools (SNAT) with Python requests

This module demonstrates CRUD operations on FortiManager IP Pool objects.
"""

import sys
from pathlib import Path
from typing import Optional, List, Dict, Any

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
# IP Pool Manager
# ─────────────────────────────────────────────────────────────────────────────

class IPPoolManager:
    """FortiManager IP Pool (SNAT) manager."""

    def __init__(self, fmg: FortiManagerClient):
        self.fmg = fmg
        self.base_url = fmg.get_adom_url("obj/firewall/ippool")
        self._log = get_logger(f"{__name__}.IPPoolManager")

    def create(
        self,
        name: str,
        startip: str,
        endip: str,
        pool_type: str = "overload",
        comment: str = "",
    ) -> Dict[str, Any]:
        """
        Create an IP Pool (SNAT).

        Args:
            name: Pool name
            startip: Start IP of the pool
            endip: End IP of the pool
            pool_type: Pool type (overload, one-to-one)
            comment: Optional comment
        """
        data = {
            "name": name,
            "type": pool_type,
            "startip": startip,
            "endip": endip,
        }

        if comment:
            data["comment"] = comment

        self._log.info(
            "Creating IP Pool '%s' (%s - %s, %s)",
            name, startip, endip, pool_type
        )
        result = self.fmg.add(self.base_url, data)
        self._log.info("IP Pool '%s' created successfully", name)
        return result

    def read(
        self,
        name: Optional[str] = None,
        filter_pattern: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """List IP Pools."""
        url = f"{self.base_url}/{name}" if name else self.base_url

        kwargs = {
            "fields": ["name", "startip", "endip", "type", "comment"]
        }
        if filter_pattern:
            pattern = filter_pattern.replace("*", "%")
            kwargs["filter"] = [["name", "like", pattern]]

        self._log.debug("Reading IP Pools from %s", url)
        result = self.fmg.get(url, **kwargs)

        if result is None:
            return []
        if not isinstance(result, list):
            return [result]
        return result

    def update(
        self,
        name: str,
        startip: Optional[str] = None,
        endip: Optional[str] = None,
        comment: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update an IP Pool."""
        url = f"{self.base_url}/{name}"

        data = {}
        if startip:
            data["startip"] = startip
        if endip:
            data["endip"] = endip
        if comment is not None:
            data["comment"] = comment

        self._log.info("Updating IP Pool '%s'", name)
        result = self.fmg.update(url, data)
        self._log.info("IP Pool '%s' updated successfully", name)
        return result

    def delete(self, name: str) -> Dict[str, Any]:
        """Delete an IP Pool."""
        url = f"{self.base_url}/{name}"
        self._log.info("Deleting IP Pool '%s'", name)
        result = self.fmg.delete(url)
        self._log.info("IP Pool '%s' deleted successfully", name)
        return result


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo():
    """CRUD IP Pool demo."""
    log.info("=" * 60)
    log.info("DEMO CRUD IP POOL (SNAT)")
    log.info("=" * 60)

    with FortiManagerClient() as fmg:
        mgr = IPPoolManager(fmg)

        # CREATE
        log.info("--- CREATE ---")
        try:
            mgr.create(
                "DEMO_POOL_OUTBOUND",
                "203.0.113.100",
                "203.0.113.110",
                "overload",
                "Demo outbound NAT pool"
            )
            mgr.create(
                "DEMO_POOL_DMZ",
                "203.0.113.120",
                "203.0.113.125",
                "one-to-one",
                "Demo DMZ pool"
            )
        except FMGObjectExistsError as e:
            log.warning("IP Pool already exists: %s", e)

        # READ
        log.info("--- READ ---")
        pools = mgr.read(filter_pattern="DEMO_POOL_*")
        log.info("IP Pools found: %d", len(pools))
        for pool in pools:
            log.info(
                "  - %s: %s - %s (%s)",
                pool["name"],
                pool.get("startip", "-"),
                pool.get("endip", "-"),
                pool.get("type", "-")
            )

        # DELETE
        log.info("--- DELETE ---")
        for name in ["DEMO_POOL_OUTBOUND", "DEMO_POOL_DMZ"]:
            try:
                mgr.delete(name)
            except FMGObjectNotFoundError:
                log.warning("IP Pool not found: %s", name)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo()
    log.info("Demo completed successfully")
