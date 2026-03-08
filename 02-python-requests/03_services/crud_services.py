#!/usr/bin/env python3
"""
CRUD Services with Python requests

This module demonstrates CRUD operations on FortiManager service objects.
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
# Service Manager
# ─────────────────────────────────────────────────────────────────────────────

class ServiceManager:
    """FortiManager service manager."""

    def __init__(self, fmg: FortiManagerClient):
        self.fmg = fmg
        self.base_url = fmg.get_adom_url("obj/firewall/service/custom")
        self._log = get_logger(f"{__name__}.ServiceManager")

    def create(
        self,
        name: str,
        protocol: str = "TCP",
        port: str = "",
        comment: str = "",
    ) -> Dict[str, Any]:
        """
        Create a custom service.

        Args:
            name: Service name
            protocol: TCP, UDP, SCTP
            port: Port or range (e.g., "443", "8080-8090")
            comment: Optional comment
        """
        data = {
            "name": name,
            "protocol": "TCP/UDP/SCTP",
        }

        if protocol.upper() == "TCP":
            data["tcp-portrange"] = port
        elif protocol.upper() == "UDP":
            data["udp-portrange"] = port
        elif protocol.upper() == "SCTP":
            data["sctp-portrange"] = port

        if comment:
            data["comment"] = comment

        self._log.info("Creating service '%s' (%s/%s)", name, protocol, port)
        result = self.fmg.add(self.base_url, data)
        self._log.info("Service '%s' created successfully", name)
        return result

    def read(
        self,
        name: Optional[str] = None,
        filter_pattern: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """List services."""
        url = f"{self.base_url}/{name}" if name else self.base_url

        kwargs = {"fields": ["name", "tcp-portrange", "udp-portrange", "comment"]}
        if filter_pattern:
            pattern = filter_pattern.replace("*", "%")
            kwargs["filter"] = [["name", "like", pattern]]

        self._log.debug("Reading services from %s", url)
        result = self.fmg.get(url, **kwargs)

        if result is None:
            return []
        if not isinstance(result, list):
            return [result]
        return result

    def delete(self, name: str) -> Dict[str, Any]:
        """Delete a service."""
        url = f"{self.base_url}/{name}"
        self._log.info("Deleting service '%s'", name)
        result = self.fmg.delete(url)
        self._log.info("Service '%s' deleted successfully", name)
        return result


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo():
    """CRUD services demo."""
    log.info("=" * 60)
    log.info("DEMO CRUD SERVICES")
    log.info("=" * 60)

    with FortiManagerClient() as fmg:
        mgr = ServiceManager(fmg)

        # CREATE
        log.info("--- CREATE ---")
        try:
            mgr.create("DEMO_SVC_8443", "TCP", "8443", "Demo HTTPS alt")
            mgr.create("DEMO_SVC_DNS_ALT", "UDP", "5353", "Demo DNS alt")
        except FMGObjectExistsError as e:
            log.warning("Service already exists: %s", e)

        # READ
        log.info("--- READ ---")
        services = mgr.read(filter_pattern="DEMO_*")
        log.info("Services found: %d", len(services))
        for svc in services:
            port = svc.get("tcp-portrange") or svc.get("udp-portrange") or "N/A"
            log.info("  - %s: %s", svc["name"], port)

        # DELETE
        log.info("--- DELETE ---")
        for name in ["DEMO_SVC_8443", "DEMO_SVC_DNS_ALT"]:
            try:
                mgr.delete(name)
            except FMGObjectNotFoundError:
                log.warning("Service not found: %s", name)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo()
    log.info("Demo completed successfully")
