#!/usr/bin/env python3
"""
CRUD Schedules with Python requests

This module demonstrates CRUD operations on FortiManager schedule objects.
"""

import sys
from pathlib import Path
from typing import Optional, List, Dict, Any

sys.path.insert(0, str(Path(__file__).parent.parent))

from config import setup_logging, get_logger
from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGObjectExistsError, FMGObjectNotFoundError


# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

setup_logging()
log = get_logger(__name__)


# ─────────────────────────────────────────────────────────────────────────────
# Schedule Manager
# ─────────────────────────────────────────────────────────────────────────────

class ScheduleManager:
    """FortiManager schedule manager for one-time schedules."""

    def __init__(self, fmg: FortiManagerClient):
        self.fmg = fmg
        self.base_url = fmg.get_adom_url("obj/firewall/schedule/onetime")
        self._log = get_logger(f"{__name__}.ScheduleManager")

    def create(
        self,
        name: str,
        start: str,
        end: str,
        comment: str = "",
    ) -> Dict[str, Any]:
        """
        Create a one-time schedule.

        Args:
            name: Schedule name
            start: Start datetime (format: "HH:MM YYYY/MM/DD")
            end: End datetime (format: "HH:MM YYYY/MM/DD")
            comment: Optional comment
        """
        data = {
            "name": name,
            "start": start,
            "end": end,
        }

        if comment:
            data["comment"] = comment

        self._log.info("Creating schedule '%s' (%s -> %s)", name, start, end)
        result = self.fmg.add(self.base_url, data)
        self._log.info("Schedule '%s' created successfully", name)
        return result

    def read(
        self,
        name: Optional[str] = None,
        filter_pattern: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """List schedules."""
        url = f"{self.base_url}/{name}" if name else self.base_url

        kwargs = {"fields": ["name", "start", "end", "comment"]}
        if filter_pattern:
            pattern = filter_pattern.replace("*", "%")
            kwargs["filter"] = [["name", "like", pattern]]

        self._log.debug("Reading schedules from %s", url)
        result = self.fmg.get(url, **kwargs)

        if result is None:
            return []
        if not isinstance(result, list):
            return [result]
        return result

    def update(
        self,
        name: str,
        start: Optional[str] = None,
        end: Optional[str] = None,
        comment: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update a schedule."""
        url = f"{self.base_url}/{name}"

        data = {}
        if start:
            data["start"] = start
        if end:
            data["end"] = end
        if comment is not None:
            data["comment"] = comment

        self._log.info("Updating schedule '%s'", name)
        result = self.fmg.update(url, data)
        self._log.info("Schedule '%s' updated successfully", name)
        return result

    def delete(self, name: str) -> Dict[str, Any]:
        """Delete a schedule."""
        url = f"{self.base_url}/{name}"
        self._log.info("Deleting schedule '%s'", name)
        result = self.fmg.delete(url)
        self._log.info("Schedule '%s' deleted successfully", name)
        return result


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo():
    """CRUD schedules demo."""
    log.info("=" * 60)
    log.info("DEMO CRUD SCHEDULES")
    log.info("=" * 60)

    with FortiManagerClient() as fmg:
        mgr = ScheduleManager(fmg)

        # CREATE
        log.info("--- CREATE ---")
        try:
            mgr.create(
                "DEMO_MAINT_WINDOW",
                "00:00 2024/12/15",
                "06:00 2024/12/15",
                "Demo maintenance window"
            )
            mgr.create(
                "DEMO_BACKUP_TIME",
                "02:00 2024/12/20",
                "04:00 2024/12/20",
                "Demo backup schedule"
            )
        except FMGObjectExistsError as e:
            log.warning("Schedule already exists: %s", e)

        # READ
        log.info("--- READ ---")
        schedules = mgr.read(filter_pattern="DEMO_*")
        log.info("Schedules found: %d", len(schedules))
        for sched in schedules:
            log.info(
                "  - %s: %s -> %s",
                sched["name"],
                sched.get("start", "N/A"),
                sched.get("end", "N/A")
            )

        # UPDATE
        log.info("--- UPDATE ---")
        try:
            mgr.update("DEMO_MAINT_WINDOW", comment="Updated maintenance window")
        except FMGObjectNotFoundError:
            log.warning("Schedule not found for update")

        # DELETE
        log.info("--- DELETE ---")
        for name in ["DEMO_MAINT_WINDOW", "DEMO_BACKUP_TIME"]:
            try:
                mgr.delete(name)
            except FMGObjectNotFoundError:
                log.warning("Schedule not found: %s", name)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo()
    log.info("Demo completed successfully")
