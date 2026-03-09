#!/usr/bin/env python3
"""
CRUD Virtual IPs (VIP/DNAT) with Python requests

This module demonstrates CRUD operations on FortiManager VIP objects.
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
# VIP Manager
# ─────────────────────────────────────────────────────────────────────────────

class VIPManager:
    """FortiManager Virtual IP (DNAT) manager."""

    def __init__(self, fmg: FortiManagerClient):
        self.fmg = fmg
        self.base_url = fmg.get_adom_url("obj/firewall/vip")
        self._log = get_logger(f"{__name__}.VIPManager")

    def create(
        self,
        name: str,
        extip: str,
        mappedip: str,
        extintf: str = "any",
        extport: Optional[str] = None,
        mappedport: Optional[str] = None,
        comment: str = "",
    ) -> Dict[str, Any]:
        """
        Create a Virtual IP (DNAT).

        Args:
            name: VIP name
            extip: External (public) IP address
            mappedip: Mapped (internal) IP address
            extintf: External interface (default: any)
            extport: External port for port forwarding
            mappedport: Mapped port for port forwarding
            comment: Optional comment
        """
        data = {
            "name": name,
            "type": "static-nat",
            "extip": extip,
            "mappedip": mappedip,
            "extintf": extintf,
        }

        # Port forwarding configuration
        if extport and mappedport:
            data["portforward"] = "enable"
            data["protocol"] = "tcp"
            data["extport"] = extport
            data["mappedport"] = mappedport

        if comment:
            data["comment"] = comment

        self._log.info("Creating VIP '%s' (%s -> %s)", name, extip, mappedip)
        result = self.fmg.add(self.base_url, data)
        self._log.info("VIP '%s' created successfully", name)
        return result

    def read(
        self,
        name: Optional[str] = None,
        filter_pattern: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """List Virtual IPs."""
        url = f"{self.base_url}/{name}" if name else self.base_url

        kwargs = {
            "fields": ["name", "extip", "mappedip", "extport", "mappedport", "comment"]
        }
        if filter_pattern:
            pattern = filter_pattern.replace("*", "%")
            kwargs["filter"] = [["name", "like", pattern]]

        self._log.debug("Reading VIPs from %s", url)
        result = self.fmg.get(url, **kwargs)

        if result is None:
            return []
        if not isinstance(result, list):
            return [result]
        return result

    def update(
        self,
        name: str,
        extip: Optional[str] = None,
        mappedip: Optional[str] = None,
        comment: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update a VIP."""
        url = f"{self.base_url}/{name}"

        data = {}
        if extip:
            data["extip"] = extip
        if mappedip:
            data["mappedip"] = mappedip
        if comment is not None:
            data["comment"] = comment

        self._log.info("Updating VIP '%s'", name)
        result = self.fmg.update(url, data)
        self._log.info("VIP '%s' updated successfully", name)
        return result

    def delete(self, name: str) -> Dict[str, Any]:
        """Delete a VIP."""
        url = f"{self.base_url}/{name}"
        self._log.info("Deleting VIP '%s'", name)
        result = self.fmg.delete(url)
        self._log.info("VIP '%s' deleted successfully", name)
        return result


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo():
    """CRUD VIP demo."""
    log.info("=" * 60)
    log.info("DEMO CRUD VIP (DNAT)")
    log.info("=" * 60)

    with FortiManagerClient() as fmg:
        mgr = VIPManager(fmg)

        # CREATE
        log.info("--- CREATE ---")
        try:
            # Simple static NAT
            mgr.create(
                "DEMO_VIP_WEB",
                "203.0.113.10",
                "192.168.10.10",
                comment="Demo web server"
            )
            # Port forwarding
            mgr.create(
                "DEMO_VIP_SSH",
                "203.0.113.10",
                "192.168.10.20",
                extport="2222",
                mappedport="22",
                comment="Demo SSH jump host"
            )
        except FMGObjectExistsError as e:
            log.warning("VIP already exists: %s", e)

        # READ
        log.info("--- READ ---")
        vips = mgr.read(filter_pattern="DEMO_VIP_*")
        log.info("VIPs found: %d", len(vips))
        for vip in vips:
            mappedip = vip.get("mappedip", "-")
            if isinstance(mappedip, list):
                mappedip = mappedip[0] if mappedip else "-"
            log.info(
                "  - %s: %s -> %s",
                vip["name"],
                vip.get("extip", "-"),
                mappedip
            )

        # DELETE
        log.info("--- DELETE ---")
        for name in ["DEMO_VIP_WEB", "DEMO_VIP_SSH"]:
            try:
                mgr.delete(name)
            except FMGObjectNotFoundError:
                log.warning("VIP not found: %s", name)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo()
    log.info("Demo completed successfully")
