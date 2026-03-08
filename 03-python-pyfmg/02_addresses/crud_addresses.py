#!/usr/bin/env python3
"""
CRUD Addresses with pyFMG

Demonstration of CRUD operations on address objects
using the pyFMG module (v0.8.6.3).

pyFMG significantly simplifies FortiManager interaction
by automatically managing sessions and JSON-RPC structure.
"""

import sys
from pathlib import Path
from typing import Optional, List, Dict, Any

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
# Helper Functions
# ─────────────────────────────────────────────────────────────────────────────

def cidr_to_mask(cidr: str) -> str:
    """Convert CIDR notation to IP MASK format."""
    ip, bits = cidr.split("/")
    bits = int(bits)
    mask = (0xFFFFFFFF << (32 - bits)) & 0xFFFFFFFF
    mask_str = ".".join(str((mask >> (8 * i)) & 0xFF) for i in range(3, -1, -1))
    return f"{ip} {mask_str}"


# ─────────────────────────────────────────────────────────────────────────────
# CRUD Functions
# ─────────────────────────────────────────────────────────────────────────────

def create_address(fmg, name: str, subnet: str, comment: str = "") -> Dict[str, Any]:
    """
    Create an IPv4 address.

    Args:
        fmg: Connected FortiManager instance
        name: Address name
        subnet: Subnet (format: "IP MASK" or "IP/CIDR")
        comment: Optional comment

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/address"

    # Convert CIDR if needed
    if "/" in subnet:
        subnet = cidr_to_mask(subnet)

    log.info("Creating address '%s' with subnet %s", name, subnet)

    # pyFMG allows passing fields as kwargs
    code, response = fmg.add(
        url,
        name=name,
        type="ipmask",
        subnet=subnet,
        comment=comment,
        **{"allow-routing": "disable", "visibility": "enable"}
    )

    if code == 0:
        log.info("Address '%s' created successfully", name)
    else:
        log.error("Failed to create '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def read_addresses(fmg, filter_name: Optional[str] = None) -> List[Dict]:
    """
    List addresses in the ADOM.

    Args:
        fmg: FortiManager instance
        filter_name: Optional filter (wildcards supported)

    Returns:
        List of addresses
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/address"

    # Options
    kwargs = {"loadsub": 0}

    if filter_name:
        # pyFMG supports filters via the filter parameter
        pattern = filter_name.replace("*", "%")
        kwargs["filter"] = [["name", "like", pattern]]

    log.debug("Reading addresses with filter: %s", filter_name)
    code, response = fmg.get(url, **kwargs)

    if code == 0:
        addresses = response if isinstance(response, list) else []
        log.info("Found %d address(es)", len(addresses))
        return addresses
    else:
        log.error("Failed to read addresses: code %d", code)
        return []


def update_address(fmg, name: str, **updates) -> Dict[str, Any]:
    """
    Update an existing address.

    Args:
        fmg: FortiManager instance
        name: Address name
        **updates: Fields to modify

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/address/{name}"

    log.info("Updating address '%s' with: %s", name, updates)
    code, response = fmg.update(url, **updates)

    if code == 0:
        log.info("Address '%s' updated successfully", name)
    else:
        log.error("Failed to update '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def delete_address(fmg, name: str) -> Dict[str, Any]:
    """
    Delete an address.

    Args:
        fmg: FortiManager instance
        name: Address name

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/address/{name}"

    log.info("Deleting address '%s'", name)
    code, response = fmg.delete(url)

    if code == 0:
        log.info("Address '%s' deleted successfully", name)
    else:
        log.error("Failed to delete '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo_crud():
    """Complete CRUD demonstration with pyFMG."""

    log.info("=" * 60)
    log.info("DEMO CRUD ADDRESSES - pyFMG")
    log.info("=" * 60)

    # Context manager = automatic login/logout
    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:

        # CREATE
        log.info("--- CREATE ---")
        create_address(fmg, "PYFMG_NET_WEB", "192.168.10.0/24", "Demo pyFMG - Web")
        create_address(fmg, "PYFMG_NET_DB", "192.168.20.0/24", "Demo pyFMG - DB")

        # READ
        log.info("--- READ ---")
        addresses = read_addresses(fmg, "PYFMG_*")
        for addr in addresses:
            subnet = addr.get("subnet", [])
            if isinstance(subnet, list):
                subnet = " ".join(subnet)
            log.info("  - %s: %s", addr["name"], subnet)

        # UPDATE
        log.info("--- UPDATE ---")
        update_address(fmg, "PYFMG_NET_WEB", comment="Demo pyFMG - Web PRODUCTION")

        # DELETE
        log.info("--- DELETE ---")
        delete_address(fmg, "PYFMG_NET_WEB")
        delete_address(fmg, "PYFMG_NET_DB")

    log.info("Demo completed (automatic logout)")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_crud()
