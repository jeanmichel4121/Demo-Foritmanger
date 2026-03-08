#!/usr/bin/env python3
"""
Complete Workflow with pyFMG

This script demonstrates a complete workflow:
1. Create objects (addresses, services)
2. Create a policy
3. Install to FortiGate
"""

import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from config import (
    FMG_HOST, FMG_USER, FMG_PASS, FMG_ADOM, FMG_VERIFY,
    setup_logging, get_logger
)
from pyFMG.fortimgr import FortiManager


# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

setup_logging()
log = get_logger(__name__)


# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

PACKAGE = "default"


# ─────────────────────────────────────────────────────────────────────────────
# Workflow Functions
# ─────────────────────────────────────────────────────────────────────────────

def create_objects(fmg):
    """Create the necessary objects."""
    log.info("--- STEP 1: Create objects ---")

    # Source address
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/address"
    code, _ = fmg.add(
        url,
        name="DEMO_SRC_NET",
        type="ipmask",
        subnet="10.10.0.0 255.255.0.0",
        comment="Demo - Source network"
    )
    if code == 0:
        log.info("  Source address: OK")
    else:
        log.error("  Source address: Code %d", code)

    # Destination address
    code, _ = fmg.add(
        url,
        name="DEMO_DST_NET",
        type="ipmask",
        subnet="192.168.100.0 255.255.255.0",
        comment="Demo - Destination network"
    )
    if code == 0:
        log.info("  Destination address: OK")
    else:
        log.error("  Destination address: Code %d", code)


def create_policy(fmg):
    """Create a firewall policy."""
    log.info("--- STEP 2: Create policy ---")

    url = f"/pm/config/adom/{FMG_ADOM}/pkg/{PACKAGE}/firewall/policy"

    code, response = fmg.add(
        url,
        name="DEMO_POLICY_ALLOW",
        srcintf=["any"],
        dstintf=["any"],
        srcaddr=["DEMO_SRC_NET"],
        dstaddr=["DEMO_DST_NET"],
        service=["ALL"],
        action="accept",
        schedule="always",
        nat="disable",
        logtraffic="all",
        status="enable",
        comments="Demo - Policy created by pyFMG"
    )

    if code == 0:
        log.info("  Policy created successfully")
    else:
        log.error("  Error: %s", response)


def preview_install(fmg):
    """Preview installation."""
    log.info("--- STEP 3: Installation preview ---")

    code, response = fmg.execute(
        "/securityconsole/install/preview",
        adom=FMG_ADOM,
        pkg=PACKAGE
    )

    if code == 0:
        log.info("  Preview generated - Check FortiManager")
    else:
        log.error("  Preview error: %s", response)


def install_package(fmg, device: str = None):
    """
    Install the policy package.

    Args:
        fmg: FortiManager instance
        device: Target device name (optional)
    """
    log.info("--- STEP 4: Installation ---")

    data = {
        "adom": FMG_ADOM,
        "pkg": PACKAGE,
    }

    if device:
        data["scope"] = [{"name": device, "vdom": "root"}]

    code, response = fmg.execute("/securityconsole/install/package", **data)

    if code == 0:
        task_id = response.get("task") if isinstance(response, dict) else None
        log.info("  Installation started")
        if task_id:
            log.info("  Task ID: %s", task_id)
    else:
        log.error("  Installation error: %s", response)


def cleanup(fmg):
    """Clean up demo objects."""
    log.info("--- CLEANUP ---")

    # Delete policy (find its ID first)
    url = f"/pm/config/adom/{FMG_ADOM}/pkg/{PACKAGE}/firewall/policy"
    code, policies = fmg.get(url)

    if code == 0 and policies:
        for pol in policies:
            if pol.get("name") == "DEMO_POLICY_ALLOW":
                del_url = f"{url}/{pol['policyid']}"
                fmg.delete(del_url)
                log.info("  Policy deleted")
                break

    # Delete addresses
    addr_url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/address"
    for name in ["DEMO_SRC_NET", "DEMO_DST_NET"]:
        fmg.delete(f"{addr_url}/{name}")
        log.info("  Address %s deleted", name)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

def demo_workflow():
    """Complete workflow demonstration."""

    log.info("=" * 60)
    log.info("DEMO COMPLETE WORKFLOW - pyFMG")
    log.info("=" * 60)
    log.info("ADOM: %s", FMG_ADOM)
    log.info("Package: %s", PACKAGE)

    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:

        # Create objects
        create_objects(fmg)

        # Create policy
        create_policy(fmg)

        # Preview (don't actually install in demo)
        preview_install(fmg)

        # Actual installation would be:
        # install_package(fmg, device="FGT-01")

        log.info("Actual installation disabled in demo")
        log.info("To install: uncomment install_package()")

        # Cleanup
        log.info("Cleaning up demo objects...")
        cleanup(fmg)

    log.info("=" * 60)
    log.info("WORKFLOW COMPLETED")
    log.info("=" * 60)


if __name__ == "__main__":
    demo_workflow()
