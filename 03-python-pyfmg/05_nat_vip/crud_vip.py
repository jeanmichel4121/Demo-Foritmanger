#!/usr/bin/env python3
"""
CRUD Virtual IPs (VIP/DNAT) with pyFMG

Demonstration of CRUD operations on VIP objects
using the pyFMG module (v0.8.6.3).
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
# CRUD Functions
# ─────────────────────────────────────────────────────────────────────────────

def create_vip(
    fmg,
    name: str,
    extip: str,
    mappedip: str,
    extintf: str = "any",
    extport: Optional[str] = None,
    mappedport: Optional[str] = None,
    comment: str = ""
) -> Dict[str, Any]:
    """
    Create a Virtual IP (DNAT).

    Args:
        fmg: Connected FortiManager instance
        name: VIP name
        extip: External (public) IP address
        mappedip: Mapped (internal) IP address
        extintf: External interface (default: any)
        extport: External port for port forwarding
        mappedport: Mapped port for port forwarding
        comment: Optional comment

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/vip"

    log.info("Creating VIP '%s' (%s -> %s)", name, extip, mappedip)

    kwargs = {
        "name": name,
        "type": "static-nat",
        "extip": extip,
        "mappedip": mappedip,
        "extintf": extintf,
    }

    # Port forwarding configuration
    if extport and mappedport:
        kwargs["portforward"] = "enable"
        kwargs["protocol"] = "tcp"
        kwargs["extport"] = extport
        kwargs["mappedport"] = mappedport

    if comment:
        kwargs["comment"] = comment

    code, response = fmg.add(url, **kwargs)

    if code == 0:
        log.info("VIP '%s' created successfully", name)
    else:
        log.error("Failed to create '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def read_vips(fmg, filter_name: Optional[str] = None) -> List[Dict]:
    """
    List VIPs in the ADOM.

    Args:
        fmg: FortiManager instance
        filter_name: Optional filter (wildcards supported)

    Returns:
        List of VIPs
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/vip"

    kwargs = {"loadsub": 0}

    if filter_name:
        pattern = filter_name.replace("*", "%")
        kwargs["filter"] = [["name", "like", pattern]]

    log.debug("Reading VIPs with filter: %s", filter_name)
    code, response = fmg.get(url, **kwargs)

    if code == 0:
        vips = response if isinstance(response, list) else []
        log.info("Found %d VIP(s)", len(vips))
        return vips
    else:
        log.error("Failed to read VIPs: code %d", code)
        return []


def update_vip(fmg, name: str, **updates) -> Dict[str, Any]:
    """
    Update an existing VIP.

    Args:
        fmg: FortiManager instance
        name: VIP name
        **updates: Fields to modify

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/vip/{name}"

    log.info("Updating VIP '%s' with: %s", name, updates)
    code, response = fmg.update(url, **updates)

    if code == 0:
        log.info("VIP '%s' updated successfully", name)
    else:
        log.error("Failed to update '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def delete_vip(fmg, name: str) -> Dict[str, Any]:
    """
    Delete a VIP.

    Args:
        fmg: FortiManager instance
        name: VIP name

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/vip/{name}"

    log.info("Deleting VIP '%s'", name)
    code, response = fmg.delete(url)

    if code == 0:
        log.info("VIP '%s' deleted successfully", name)
    else:
        log.error("Failed to delete '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo_crud():
    """Complete CRUD demonstration with pyFMG."""

    log.info("=" * 60)
    log.info("DEMO CRUD VIP (DNAT) - pyFMG")
    log.info("=" * 60)

    # Context manager = automatic login/logout
    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:

        # CREATE
        log.info("--- CREATE ---")
        create_vip(fmg, "PYFMG_VIP_WEB", "203.0.113.10", "192.168.10.10", comment="Demo pyFMG - Web")
        create_vip(
            fmg, "PYFMG_VIP_SSH", "203.0.113.10", "192.168.10.20",
            extport="2222", mappedport="22", comment="Demo pyFMG - SSH"
        )

        # READ
        log.info("--- READ ---")
        vips = read_vips(fmg, "PYFMG_*")
        for vip in vips:
            mappedip = vip.get("mappedip", "-")
            if isinstance(mappedip, list):
                mappedip = mappedip[0] if mappedip else "-"
            log.info("  - %s: %s -> %s", vip["name"], vip.get("extip", "-"), mappedip)

        # UPDATE
        log.info("--- UPDATE ---")
        update_vip(fmg, "PYFMG_VIP_WEB", comment="Updated web server VIP")

        # DELETE
        log.info("--- DELETE ---")
        delete_vip(fmg, "PYFMG_VIP_WEB")
        delete_vip(fmg, "PYFMG_VIP_SSH")

    log.info("Demo completed (automatic logout)")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_crud()
