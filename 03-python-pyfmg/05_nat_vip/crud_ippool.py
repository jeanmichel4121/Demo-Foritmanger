#!/usr/bin/env python3
"""
CRUD IP Pools (SNAT) with pyFMG

Demonstration of CRUD operations on IP Pool objects
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

def create_ippool(
    fmg,
    name: str,
    startip: str,
    endip: str,
    pool_type: str = "overload",
    comment: str = ""
) -> Dict[str, Any]:
    """
    Create an IP Pool (SNAT).

    Args:
        fmg: Connected FortiManager instance
        name: Pool name
        startip: Start IP of the pool
        endip: End IP of the pool
        pool_type: Pool type (overload, one-to-one)
        comment: Optional comment

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/ippool"

    log.info("Creating IP Pool '%s' (%s - %s, %s)", name, startip, endip, pool_type)

    kwargs = {
        "name": name,
        "type": pool_type,
        "startip": startip,
        "endip": endip,
    }

    if comment:
        kwargs["comment"] = comment

    code, response = fmg.add(url, **kwargs)

    if code == 0:
        log.info("IP Pool '%s' created successfully", name)
    else:
        log.error("Failed to create '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def read_ippools(fmg, filter_name: Optional[str] = None) -> List[Dict]:
    """
    List IP Pools in the ADOM.

    Args:
        fmg: FortiManager instance
        filter_name: Optional filter (wildcards supported)

    Returns:
        List of IP Pools
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/ippool"

    kwargs = {"loadsub": 0}

    if filter_name:
        pattern = filter_name.replace("*", "%")
        kwargs["filter"] = [["name", "like", pattern]]

    log.debug("Reading IP Pools with filter: %s", filter_name)
    code, response = fmg.get(url, **kwargs)

    if code == 0:
        pools = response if isinstance(response, list) else []
        log.info("Found %d IP Pool(s)", len(pools))
        return pools
    else:
        log.error("Failed to read IP Pools: code %d", code)
        return []


def update_ippool(fmg, name: str, **updates) -> Dict[str, Any]:
    """
    Update an existing IP Pool.

    Args:
        fmg: FortiManager instance
        name: Pool name
        **updates: Fields to modify

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/ippool/{name}"

    log.info("Updating IP Pool '%s' with: %s", name, updates)
    code, response = fmg.update(url, **updates)

    if code == 0:
        log.info("IP Pool '%s' updated successfully", name)
    else:
        log.error("Failed to update '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def delete_ippool(fmg, name: str) -> Dict[str, Any]:
    """
    Delete an IP Pool.

    Args:
        fmg: FortiManager instance
        name: Pool name

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/ippool/{name}"

    log.info("Deleting IP Pool '%s'", name)
    code, response = fmg.delete(url)

    if code == 0:
        log.info("IP Pool '%s' deleted successfully", name)
    else:
        log.error("Failed to delete '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo_crud():
    """Complete CRUD demonstration with pyFMG."""

    log.info("=" * 60)
    log.info("DEMO CRUD IP POOL (SNAT) - pyFMG")
    log.info("=" * 60)

    # Context manager = automatic login/logout
    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:

        # CREATE
        log.info("--- CREATE ---")
        create_ippool(fmg, "PYFMG_POOL_OUT", "203.0.113.100", "203.0.113.110", "overload", "Demo pyFMG - Outbound")
        create_ippool(fmg, "PYFMG_POOL_DMZ", "203.0.113.120", "203.0.113.125", "one-to-one", "Demo pyFMG - DMZ")

        # READ
        log.info("--- READ ---")
        pools = read_ippools(fmg, "PYFMG_*")
        for pool in pools:
            log.info(
                "  - %s: %s - %s (%s)",
                pool["name"],
                pool.get("startip", "-"),
                pool.get("endip", "-"),
                pool.get("type", "-")
            )

        # UPDATE
        log.info("--- UPDATE ---")
        update_ippool(fmg, "PYFMG_POOL_OUT", comment="Updated outbound pool")

        # DELETE
        log.info("--- DELETE ---")
        delete_ippool(fmg, "PYFMG_POOL_OUT")
        delete_ippool(fmg, "PYFMG_POOL_DMZ")

    log.info("Demo completed (automatic logout)")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_crud()
