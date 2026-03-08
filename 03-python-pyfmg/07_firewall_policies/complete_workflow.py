#!/usr/bin/env python3
"""
Complete Workflow with pyFMG

This script demonstrates a complete workflow:
1. Create objects (addresses, services)
2. Create a policy
3. Install to FortiGate
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env
env_path = Path(__file__).parent.parent.parent / ".env"
load_dotenv(env_path)

from pyFMG.fortimgr import FortiManager


# Configuration
FMG_HOST = os.getenv("FMG_HOST")
FMG_USER = os.getenv("FMG_USERNAME")
FMG_PASS = os.getenv("FMG_PASSWORD")
FMG_ADOM = os.getenv("FMG_ADOM", "root")
FMG_VERIFY = os.getenv("FMG_VERIFY_SSL", "false").lower() == "true"
PACKAGE = "default"


def create_objects(fmg):
    """Create the necessary objects."""
    print("\n--- STEP 1: Create objects ---")

    # Source address
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/address"
    code, _ = fmg.add(
        url,
        name="DEMO_SRC_NET",
        type="ipmask",
        subnet="10.10.0.0 255.255.0.0",
        comment="Demo - Source network"
    )
    print(f"  Source address: {'OK' if code == 0 else f'Code {code}'}")

    # Destination address
    code, _ = fmg.add(
        url,
        name="DEMO_DST_NET",
        type="ipmask",
        subnet="192.168.100.0 255.255.255.0",
        comment="Demo - Destination network"
    )
    print(f"  Destination address: {'OK' if code == 0 else f'Code {code}'}")


def create_policy(fmg):
    """Create a firewall policy."""
    print("\n--- STEP 2: Create policy ---")

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
        print(f"  Policy created successfully")
    else:
        print(f"  Error: {response}")


def preview_install(fmg):
    """Preview installation."""
    print("\n--- STEP 3: Installation preview ---")

    code, response = fmg.execute(
        "/securityconsole/install/preview",
        adom=FMG_ADOM,
        pkg=PACKAGE
    )

    if code == 0:
        print("  Preview generated - Check FortiManager")
    else:
        print(f"  Preview error: {response}")


def install_package(fmg, device: str = None):
    """
    Install the policy package.

    Args:
        fmg: FortiManager instance
        device: Target device name (optional)
    """
    print("\n--- STEP 4: Installation ---")

    data = {
        "adom": FMG_ADOM,
        "pkg": PACKAGE,
    }

    if device:
        data["scope"] = [{"name": device, "vdom": "root"}]

    code, response = fmg.execute("/securityconsole/install/package", **data)

    if code == 0:
        task_id = response.get("task") if isinstance(response, dict) else None
        print(f"  Installation started")
        if task_id:
            print(f"  Task ID: {task_id}")
    else:
        print(f"  Installation error: {response}")


def cleanup(fmg):
    """Clean up demo objects."""
    print("\n--- CLEANUP ---")

    # Delete policy (find its ID first)
    url = f"/pm/config/adom/{FMG_ADOM}/pkg/{PACKAGE}/firewall/policy"
    code, policies = fmg.get(url)

    if code == 0 and policies:
        for pol in policies:
            if pol.get("name") == "DEMO_POLICY_ALLOW":
                del_url = f"{url}/{pol['policyid']}"
                fmg.delete(del_url)
                print(f"  Policy deleted")
                break

    # Delete addresses
    addr_url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/address"
    for name in ["DEMO_SRC_NET", "DEMO_DST_NET"]:
        fmg.delete(f"{addr_url}/{name}")
        print(f"  Address {name} deleted")


def demo_workflow():
    """Complete workflow demonstration."""

    print("\n" + "=" * 60)
    print("DEMO COMPLETE WORKFLOW - pyFMG")
    print("=" * 60)
    print(f"\nADOM: {FMG_ADOM}")
    print(f"Package: {PACKAGE}")

    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:

        # Create objects
        create_objects(fmg)

        # Create policy
        create_policy(fmg)

        # Preview (don't actually install in demo)
        preview_install(fmg)

        # Actual installation would be:
        # install_package(fmg, device="FGT-01")

        print("\n[INFO] Actual installation disabled in demo")
        print("To install: uncomment install_package()")

        # Cleanup
        print("\nCleaning up demo objects...")
        cleanup(fmg)

    print("\n" + "=" * 60)
    print("WORKFLOW COMPLETED")
    print("=" * 60)


if __name__ == "__main__":
    demo_workflow()
