#!/usr/bin/env python3
"""
CRUD Application Groups with pyFMG

Demonstration of CRUD operations on application group objects
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

def create_app_group(
    fmg,
    name: str,
    applications: Optional[List[str]] = None,
    comment: str = ""
) -> Dict[str, Any]:
    """
    Create an application group.

    Args:
        fmg: Connected FortiManager instance
        name: Group name
        applications: List of application names or IDs
        comment: Optional comment

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/application/group"

    log.info("Creating app group '%s' with %d apps", name, len(applications or []))

    kwargs = {"name": name}

    if applications:
        kwargs["application"] = applications

    if comment:
        kwargs["comment"] = comment

    code, response = fmg.add(url, **kwargs)

    if code == 0:
        log.info("App group '%s' created successfully", name)
    else:
        log.error("Failed to create '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def read_app_groups(fmg, filter_name: Optional[str] = None) -> List[Dict]:
    """
    List application groups in the ADOM.

    Args:
        fmg: FortiManager instance
        filter_name: Optional filter (wildcards supported)

    Returns:
        List of application groups
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/application/group"

    kwargs = {"loadsub": 0}

    if filter_name:
        pattern = filter_name.replace("*", "%")
        kwargs["filter"] = [["name", "like", pattern]]

    log.debug("Reading app groups with filter: %s", filter_name)
    code, response = fmg.get(url, **kwargs)

    if code == 0:
        groups = response if isinstance(response, list) else []
        log.info("Found %d app group(s)", len(groups))
        return groups
    else:
        log.error("Failed to read app groups: code %d", code)
        return []


def update_app_group(fmg, name: str, **updates) -> Dict[str, Any]:
    """
    Update an existing application group.

    Args:
        fmg: FortiManager instance
        name: Group name
        **updates: Fields to modify

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/application/group/{name}"

    log.info("Updating app group '%s' with: %s", name, updates)
    code, response = fmg.update(url, **updates)

    if code == 0:
        log.info("App group '%s' updated successfully", name)
    else:
        log.error("Failed to update '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def delete_app_group(fmg, name: str) -> Dict[str, Any]:
    """
    Delete an application group.

    Args:
        fmg: FortiManager instance
        name: Group name

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/application/group/{name}"

    log.info("Deleting app group '%s'", name)
    code, response = fmg.delete(url)

    if code == 0:
        log.info("App group '%s' deleted successfully", name)
    else:
        log.error("Failed to delete '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo_crud():
    """Complete CRUD demonstration with pyFMG."""

    log.info("=" * 60)
    log.info("DEMO CRUD APPLICATION GROUPS - pyFMG")
    log.info("=" * 60)

    # Context manager = automatic login/logout
    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:

        # CREATE
        log.info("--- CREATE ---")
        create_app_group(fmg, "PYFMG_APP_SOCIAL", ["Facebook", "Twitter", "Instagram"], "Demo pyFMG - Social")
        create_app_group(fmg, "PYFMG_APP_STREAM", ["Netflix", "YouTube", "Spotify"], "Demo pyFMG - Streaming")

        # READ
        log.info("--- READ ---")
        groups = read_app_groups(fmg, "PYFMG_*")
        for grp in groups:
            apps = grp.get("application", [])
            if isinstance(apps, list):
                apps = ", ".join(str(a) for a in apps)
            log.info("  - %s: %s", grp["name"], apps)

        # UPDATE
        log.info("--- UPDATE ---")
        update_app_group(
            fmg, "PYFMG_APP_SOCIAL",
            application=["Facebook", "Twitter", "Instagram", "LinkedIn"],
            comment="Updated social apps"
        )

        # DELETE
        log.info("--- DELETE ---")
        delete_app_group(fmg, "PYFMG_APP_SOCIAL")
        delete_app_group(fmg, "PYFMG_APP_STREAM")

    log.info("Demo completed (automatic logout)")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_crud()
