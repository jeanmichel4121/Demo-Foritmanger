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

from config import setup_logging, get_logger
from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGObjectExistsError, FMGObjectNotFoundError, FMGError


# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

setup_logging()
log = get_logger(__name__)


# ─────────────────────────────────────────────────────────────────────────────
# Policy Manager
# ─────────────────────────────────────────────────────────────────────────────

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
        self._log = get_logger(f"{__name__}.PolicyManager")

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

        self._log.info("Creating policy '%s' (%s -> %s)", name, srcintf, dstintf)
        result = self.fmg.add(self.base_url, data)
        self._log.info("Policy '%s' created successfully", name)
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

        self._log.debug("Reading policies from %s", url)
        result = self.fmg.get(url, fields=fields or default_fields)

        if result is None:
            return []
        if not isinstance(result, list):
            return [result]
        return result

    def update(self, policy_id: int, **updates) -> Dict[str, Any]:
        """Update a policy."""
        url = f"{self.base_url}/{policy_id}"
        self._log.info("Updating policy ID %d with: %s", policy_id, updates)
        result = self.fmg.update(url, updates)
        self._log.info("Policy ID %d updated successfully", policy_id)
        return result

    def delete(self, policy_id: int) -> Dict[str, Any]:
        """Delete a policy."""
        url = f"{self.base_url}/{policy_id}"
        self._log.info("Deleting policy ID %d", policy_id)
        result = self.fmg.delete(url)
        self._log.info("Policy ID %d deleted successfully", policy_id)
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

        self._log.info("Installing package '%s' to %s", self.package, device or "all devices")
        result = self.fmg.execute("/securityconsole/install/package", data)
        self._log.info("Installation started, task: %s", result)
        return result


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo():
    """CRUD policies demo."""
    log.info("=" * 60)
    log.info("DEMO CRUD FIREWALL POLICIES")
    log.info("=" * 60)

    with FortiManagerClient() as fmg:
        mgr = PolicyManager(fmg)

        # READ - List existing policies
        log.info("--- READ (existing policies) ---")
        policies = mgr.read()
        log.info("Policies in package: %d", len(policies))
        for pol in policies[:5]:  # Max 5
            name = pol.get("name", f"Policy {pol.get('policyid')}")
            log.info("  - ID %s: %s [%s]", pol["policyid"], name, pol.get("action", "N/A"))

        # CREATE (if objects exist)
        log.info("--- CREATE (example) ---")
        log.info("Note: Requires existing objects (addresses, services)")
        log.info("Example code:")
        log.info("""
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
        log.info("--- INSTALL (example) ---")
        log.info("Note: Installation to FortiGate")
        log.info("Example code:")
        log.info("""
        # Install to a specific device
        result = mgr.install(device="FGT-01")
        log.info("Task ID: %s", result.get("task"))
        """)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo()
    log.info("Demo completed successfully")
