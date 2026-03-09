#!/usr/bin/env python3
"""
CRUD Schedules with pyFMG

Demonstration of CRUD operations on schedule objects
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

def create_schedule(
    fmg,
    name: str,
    start: str,
    end: str,
    comment: str = ""
) -> Dict[str, Any]:
    """
    Create a one-time schedule.

    Args:
        fmg: Connected FortiManager instance
        name: Schedule name
        start: Start datetime (format: "HH:MM YYYY/MM/DD")
        end: End datetime (format: "HH:MM YYYY/MM/DD")
        comment: Optional comment

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/schedule/onetime"

    log.info("Creating schedule '%s' (%s -> %s)", name, start, end)

    kwargs = {
        "name": name,
        "start": start,
        "end": end,
    }

    if comment:
        kwargs["comment"] = comment

    code, response = fmg.add(url, **kwargs)

    if code == 0:
        log.info("Schedule '%s' created successfully", name)
    else:
        log.error("Failed to create '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def read_schedules(fmg, filter_name: Optional[str] = None) -> List[Dict]:
    """
    List schedules in the ADOM.

    Args:
        fmg: FortiManager instance
        filter_name: Optional filter (wildcards supported)

    Returns:
        List of schedules
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/schedule/onetime"

    kwargs = {"loadsub": 0}

    if filter_name:
        pattern = filter_name.replace("*", "%")
        kwargs["filter"] = [["name", "like", pattern]]

    log.debug("Reading schedules with filter: %s", filter_name)
    code, response = fmg.get(url, **kwargs)

    if code == 0:
        schedules = response if isinstance(response, list) else []
        log.info("Found %d schedule(s)", len(schedules))
        return schedules
    else:
        log.error("Failed to read schedules: code %d", code)
        return []


def update_schedule(fmg, name: str, **updates) -> Dict[str, Any]:
    """
    Update an existing schedule.

    Args:
        fmg: FortiManager instance
        name: Schedule name
        **updates: Fields to modify (start, end, comment)

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/schedule/onetime/{name}"

    log.info("Updating schedule '%s' with: %s", name, updates)
    code, response = fmg.update(url, **updates)

    if code == 0:
        log.info("Schedule '%s' updated successfully", name)
    else:
        log.error("Failed to update '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


def delete_schedule(fmg, name: str) -> Dict[str, Any]:
    """
    Delete a schedule.

    Args:
        fmg: FortiManager instance
        name: Schedule name

    Returns:
        dict with code and response
    """
    url = f"/pm/config/adom/{FMG_ADOM}/obj/firewall/schedule/onetime/{name}"

    log.info("Deleting schedule '%s'", name)
    code, response = fmg.delete(url)

    if code == 0:
        log.info("Schedule '%s' deleted successfully", name)
    else:
        log.error("Failed to delete '%s': code %d - %s", name, code, response)

    return {"code": code, "response": response}


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo_crud():
    """Complete CRUD demonstration with pyFMG."""

    log.info("=" * 60)
    log.info("DEMO CRUD SCHEDULES - pyFMG")
    log.info("=" * 60)

    # Context manager = automatic login/logout
    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:

        # CREATE
        log.info("--- CREATE ---")
        create_schedule(fmg, "PYFMG_MAINT", "00:00 2024/12/15", "06:00 2024/12/15", "Demo pyFMG - Maintenance")
        create_schedule(fmg, "PYFMG_BACKUP", "02:00 2024/12/20", "04:00 2024/12/20", "Demo pyFMG - Backup")

        # READ
        log.info("--- READ ---")
        schedules = read_schedules(fmg, "PYFMG_*")
        for sched in schedules:
            log.info("  - %s: %s -> %s", sched["name"], sched.get("start", "N/A"), sched.get("end", "N/A"))

        # UPDATE
        log.info("--- UPDATE ---")
        update_schedule(fmg, "PYFMG_MAINT", comment="Updated maintenance window")

        # DELETE
        log.info("--- DELETE ---")
        delete_schedule(fmg, "PYFMG_MAINT")
        delete_schedule(fmg, "PYFMG_BACKUP")

    log.info("Demo completed (automatic logout)")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_crud()
