#!/usr/bin/env python3
"""
CRUD Firewall Policies with Python requests

This module demonstrates operations on firewall policies,
including the installation workflow.
"""

import sys
from pathlib import Path
from typing import Optional, List, Dict, Any

sys.path.insert(0, str(Path(__file__).parent.parent))

from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGObjectExistsError, FMGObjectNotFoundError, FMGError


class PolicyManager:
    """FortiManager policy manager."""

    def __init__(self, fmg: FortiManagerClient, package: str = "default"):
        """
        Initialize the manager.

        Args:
            fmg: FortiManager client
            package: Policy package name
        """
        self.fmg = fmg
        self.package = package
        self.base_url = fmg.get_adom_url(f"pkg/{package}/firewall/policy")

    def create(
        self,
        name: str,
        srcintf: List[str],
        dstintf: List[str],
        srcaddr: List[str],
        dstaddr: List[str],
        service: List[str],
        action: str = "accept",
        schedule: str = "always",
        nat: str = "disable",
        comment: str = "",
    ) -> Dict[str, Any]:
        """
        Create a firewall policy.

        Args:
            name: Policy name
            srcintf: Source interface(s)
            dstintf: Destination interface(s)
            srcaddr: Source address(es)
            dstaddr: Destination address(es)
            service: Service(s)
            action: accept or deny
            schedule: Schedule (default: always)
            nat: enable or disable
            comment: Comment
        """
        data = {
            "name": name,
            "srcintf": srcintf,
            "dstintf": dstintf,
            "srcaddr": srcaddr,
            "dstaddr": dstaddr,
            "service": service,
            "action": action,
            "schedule": schedule,
            "nat": nat,
            "logtraffic": "all",
            "status": "enable",
        }

        if comment:
            data["comments"] = comment

        print(f"Creating policy '{name}'...")
        result = self.fmg.add(self.base_url, data)
        print("[OK] Policy created")
        return result

    def read(
        self,
        policy_id: Optional[int] = None,
        fields: Optional[List[str]] = None,
    ) -> List[Dict[str, Any]]:
        """
        List policies.

        Args:
            policy_id: Specific ID (optional)
            fields: Fields to return
        """
        url = f"{self.base_url}/{policy_id}" if policy_id else self.base_url

        default_fields = [
            "policyid", "name", "srcintf", "dstintf",
            "srcaddr", "dstaddr", "service", "action", "status"
        ]

        result = self.fmg.get(url, fields=fields or default_fields)

        if result is None:
            return []
        if not isinstance(result, list):
            return [result]
        return result

    def update(self, policy_id: int, **updates) -> Dict[str, Any]:
        """Update a policy."""
        url = f"{self.base_url}/{policy_id}"
        print(f"Updating policy ID {policy_id}...")
        result = self.fmg.update(url, updates)
        print("[OK] Policy updated")
        return result

    def delete(self, policy_id: int) -> Dict[str, Any]:
        """Delete a policy."""
        url = f"{self.base_url}/{policy_id}"
        print(f"Deleting policy ID {policy_id}...")
        result = self.fmg.delete(url)
        print("[OK] Policy deleted")
        return result

    def install(self, device: Optional[str] = None) -> Dict[str, Any]:
        """
        Install the policy package to FortiGate devices.

        Args:
            device: Target device name (optional)

        Returns:
            Installation result (task ID)
        """
        data = {
            "adom": self.fmg.settings.adom,
            "pkg": self.package,
        }

        if device:
            data["scope"] = [{"name": device, "vdom": "root"}]

        print(f"Installing package '{self.package}'...")
        result = self.fmg.execute("/securityconsole/install/package", data)
        print("[OK] Installation started")
        return result


def demo():
    """CRUD policies demo."""
    print("\n" + "=" * 60)
    print("DEMO CRUD FIREWALL POLICIES")
    print("=" * 60)

    with FortiManagerClient() as fmg:
        mgr = PolicyManager(fmg)

        # READ - List existing policies
        print("\n--- READ (existing policies) ---")
        policies = mgr.read()
        print(f"Policies in package: {len(policies)}")
        for pol in policies[:5]:  # Max 5
            name = pol.get("name", f"Policy {pol.get('policyid')}")
            print(f"  - ID {pol['policyid']}: {name} [{pol.get('action', 'N/A')}]")

        # CREATE (if objects exist)
        print("\n--- CREATE (example) ---")
        print("Note: Requires existing objects (addresses, services)")
        print("Example code:")
        print("""
        mgr.create(
            name="Allow_Web_Access",
            srcintf=["internal"],
            dstintf=["wan1"],
            srcaddr=["NET_USERS"],
            dstaddr=["all"],
            service=["HTTP", "HTTPS"],
            action="accept",
            nat="enable",
            comment="Web access for users"
        )
        """)

        # INSTALL (example)
        print("\n--- INSTALL (example) ---")
        print("Note: Installation to FortiGate")
        print("Example code:")
        print("""
        # Install to a specific device
        result = mgr.install(device="FGT-01")
        print(f"Task ID: {result.get('task')}")
        """)


if __name__ == "__main__":
    demo()
