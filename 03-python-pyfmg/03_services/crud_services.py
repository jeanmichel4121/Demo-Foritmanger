#!/usr/bin/env python3
"""
CRUD Services with pyFMG

Demonstration of CRUD operations on service objects
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

def create_service(
    fmg,
    name: str,
    protocol: str = "TCP",
    port: str = "",
    comment: str = ""
) -> Dict[str, Any]:
    """
    Create a custom service.

    Args:
        fmg: Connected FortiManager instance
        name: Service name
        protocol: TCP, UDP, or SCTP
        port: Port or range (e.g., "443", "8080-8090")
        comment: Optional comment

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/service/custom"

    log.info("Creating service '%s' (%s/%s)", name, protocol, port)

    kwargs = {
        "name": name,
        "protocol": "TCP/UDP/SCTP",
    }

    if protocol.upper() == "TCP":
        kwargs["tcp-portrange"] = port
    elif protocol.upper() == "UDP":
        kwargs["udp-portrange"] = port
    elif protocol.upper() == "SCTP":
        kwargs["sctp-portrange"] = port

    if comment:
        kwargs["comment"] = comment

    code, response = fmg.add(url, **kwargs)

    if code == 0:
        log.info("Service '%s' created successfully", name)
    else:
        log.error("Failed to create '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def read_services(fmg, filter_name: Optional[str] = None) -> List[Dict]:
    """
    List services in the ADOM.

    Args:
        fmg: FortiManager instance
        filter_name: Optional filter (wildcards supported)

    Returns:
        List of services
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/service/custom"

    kwargs = {"loadsub": 0}

    if filter_name:
        pattern = filter_name.replace("*", "%")
        kwargs["filter"] = [["name", "like", pattern]]

    log.debug("Reading services with filter: %s", filter_name)
    code, response = fmg.get(url, **kwargs)

    if code == 0:
        services = response if isinstance(response, list) else []
        log.info("Found %d service(s)", len(services))
        return services
    else:
        log.error("Failed to read services: code %d", code)
        return []


def delete_service(fmg, name: str) -> Dict[str, Any]:
    """
    Delete a service.

    Args:
        fmg: FortiManager instance
        name: Service name

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/service/custom/{name}"

    log.info("Deleting service '%s'", name)
    code, response = fmg.delete(url)

    if code == 0:
        log.info("Service '%s' deleted successfully", name)
    else:
        log.error("Failed to delete '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo_crud():
    """Complete CRUD demonstration with pyFMG."""

    log.info("=" * 60)
    log.info("DEMO CRUD SERVICES - pyFMG")
    log.info("=" * 60)

    # Context manager = automatic login/logout
    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:

        # CREATE
        log.info("--- CREATE ---")
        create_service(fmg, "PYFMG_SVC_8443", "TCP", "8443", "Demo pyFMG - HTTPS alt")
        create_service(fmg, "PYFMG_SVC_DNS_ALT", "UDP", "5353", "Demo pyFMG - DNS alt")

        # READ
        log.info("--- READ ---")
        services = read_services(fmg, "PYFMG_*")
        for svc in services:
            port = svc.get("tcp-portrange") or svc.get("udp-portrange") or "N/A"
            log.info("  - %s: %s", svc["name"], port)

        # DELETE
        log.info("--- DELETE ---")
        delete_service(fmg, "PYFMG_SVC_8443")
        delete_service(fmg, "PYFMG_SVC_DNS_ALT")

    log.info("Demo completed (automatic logout)")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_crud()
