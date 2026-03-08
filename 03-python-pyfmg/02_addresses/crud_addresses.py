#!/usr/bin/env python3
"""
CRUD Addresses with pyFMG

Demonstration of CRUD operations on address objects
using the pyFMG module (v0.8.6.3).

pyFMG significantly simplifies FortiManager interaction
by automatically managing sessions and JSON-RPC structure.
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


def create_address(fmg, name: str, subnet: str, comment: str = "") -> dict:
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
        ip, bits = subnet.split("/")
        bits = int(bits)
        mask = (0xFFFFFFFF << (32 - bits)) & 0xFFFFFFFF
        mask_str = ".".join(str((mask >> (8 * i)) & 0xFF) for i in range(3, -1, -1))
        subnet = f"{ip} {mask_str}"

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
        print(f"[OK] Address '{name}' created")
    else:
        print(f"[ERROR] Code {code}: {response}")

    return {"code": code, "response": response}


def read_addresses(fmg, filter_name: str = None) -> list:
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

    code, response = fmg.get(url, **kwargs)

    if code == 0:
        addresses = response if isinstance(response, list) else []
        print(f"[OK] {len(addresses)} address(es)")
        return addresses
    else:
        print(f"[ERROR] Code {code}")
        return []


def update_address(fmg, name: str, **updates) -> dict:
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

    code, response = fmg.update(url, **updates)

    if code == 0:
        print(f"[OK] Address '{name}' updated")
    else:
        print(f"[ERROR] Code {code}: {response}")

    return {"code": code, "response": response}


def delete_address(fmg, name: str) -> dict:
    """
    Delete an address.

    Args:
        fmg: FortiManager instance
        name: Address name

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/address/{name}"

    code, response = fmg.delete(url)

    if code == 0:
        print(f"[OK] Address '{name}' deleted")
    else:
        print(f"[ERROR] Code {code}: {response}")

    return {"code": code, "response": response}


# =============================================================================
# DEMO
# =============================================================================

def demo_crud():
    """Complete CRUD demonstration with pyFMG."""

    print("\n" + "=" * 60)
    print("DEMO CRUD ADDRESSES - pyFMG")
    print("=" * 60)

    # Context manager = automatic login/logout
    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:

        # CREATE
        print("\n--- CREATE ---")
        create_address(fmg, "PYFMG_NET_WEB", "192.168.10.0/24", "Demo pyFMG - Web")
        create_address(fmg, "PYFMG_NET_DB", "192.168.20.0/24", "Demo pyFMG - DB")

        # READ
        print("\n--- READ ---")
        addresses = read_addresses(fmg, "PYFMG_*")
        for addr in addresses:
            subnet = addr.get("subnet", [])
            if isinstance(subnet, list):
                subnet = " ".join(subnet)
            print(f"  - {addr['name']}: {subnet}")

        # UPDATE
        print("\n--- UPDATE ---")
        update_address(fmg, "PYFMG_NET_WEB", comment="Demo pyFMG - Web PRODUCTION")

        # DELETE
        print("\n--- DELETE ---")
        delete_address(fmg, "PYFMG_NET_WEB")
        delete_address(fmg, "PYFMG_NET_DB")

    print("\n[OK] Demo completed (automatic logout)")


if __name__ == "__main__":
    demo_crud()
