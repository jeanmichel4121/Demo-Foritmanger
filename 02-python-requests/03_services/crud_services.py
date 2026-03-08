#!/usr/bin/env python3
"""
CRUD Services with Python requests
"""

import sys
from pathlib import Path
from typing import Optional, List, Dict, Any

sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGObjectExistsError, FMGObjectNotFoundError


class ServiceManager:
    """FortiManager service manager."""

    def __init__(self, fmg: FortiManagerClient):
        self.fmg = fmg
        self.base_url = fmg.get_adom_url("obj/firewall/service/custom")

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

        print(f"Creating service '{name}' ({protocol}/{port})...")
        result = self.fmg.add(self.base_url, data)
        print("[OK] Service created")
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

        result = self.fmg.get(url, **kwargs)

        if result is None:
            return []
        if not isinstance(result, list):
            return [result]
        return result

    def delete(self, name: str) -> Dict[str, Any]:
        """Delete a service."""
        url = f"{self.base_url}/{name}"
        print(f"Deleting service '{name}'...")
        result = self.fmg.delete(url)
        print("[OK] Service deleted")
        return result


def demo():
    """CRUD services demo."""
    print("\n" + "=" * 60)
    print("DEMO CRUD SERVICES")
    print("=" * 60)

    with FortiManagerClient() as fmg:
        mgr = ServiceManager(fmg)

        # CREATE
        print("\n--- CREATE ---")
        try:
            mgr.create("DEMO_SVC_8443", "TCP", "8443", "Demo HTTPS alt")
            mgr.create("DEMO_SVC_DNS_ALT", "UDP", "5353", "Demo DNS alt")
        except FMGObjectExistsError as e:
            print(f"[WARNING] {e}")

        # READ
        print("\n--- READ ---")
        services = mgr.read(filter_pattern="DEMO_*")
        print(f"Services: {len(services)}")
        for svc in services:
            port = svc.get("tcp-portrange") or svc.get("udp-portrange") or "N/A"
            print(f"  - {svc['name']}: {port}")

        # DELETE
        print("\n--- DELETE ---")
        for name in ["DEMO_SVC_8443", "DEMO_SVC_DNS_ALT"]:
            try:
                mgr.delete(name)
            except FMGObjectNotFoundError:
                print(f"[WARNING] {name} not found")


if __name__ == "__main__":
    demo()
