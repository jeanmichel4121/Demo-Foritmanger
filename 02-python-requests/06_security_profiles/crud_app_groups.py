#!/usr/bin/env python3
"""
CRUD Application Groups with Python requests

This module demonstrates CRUD operations on FortiManager application group objects.
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
# Application Group Manager
# ─────────────────────────────────────────────────────────────────────────────

class AppGroupManager:
    """FortiManager application group manager."""

    def __init__(self, fmg: FortiManagerClient):
        self.fmg = fmg
        self.base_url = fmg.get_adom_url("obj/application/group")
        self._log = get_logger(f"{__name__}.AppGroupManager")

    def create(
        self,
        name: str,
        applications: Optional[List[str]] = None,
        comment: str = "",
    ) -> Dict[str, Any]:
        """
        Create an application group.

        Args:
            name: Group name
            applications: List of application names or IDs
            comment: Optional comment
        """
        data = {"name": name}

        if applications:
            data["application"] = applications

        if comment:
            data["comment"] = comment

        self._log.info("Creating app group '%s' with %d apps", name, len(applications or []))
        result = self.fmg.add(self.base_url, data)
        self._log.info("App group '%s' created successfully", name)
        return result

    def read(
        self,
        name: Optional[str] = None,
        filter_pattern: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """List application groups."""
        url = f"{self.base_url}/{name}" if name else self.base_url

        kwargs = {"fields": ["name", "application", "comment"]}
        if filter_pattern:
            pattern = filter_pattern.replace("*", "%")
            kwargs["filter"] = [["name", "like", pattern]]

        self._log.debug("Reading app groups from %s", url)
        result = self.fmg.get(url, **kwargs)

        if result is None:
            return []
        if not isinstance(result, list):
            return [result]
        return result

    def update(
        self,
        name: str,
        applications: Optional[List[str]] = None,
        comment: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Update an application group."""
        url = f"{self.base_url}/{name}"

        data = {}
        if applications is not None:
            data["application"] = applications
        if comment is not None:
            data["comment"] = comment

        self._log.info("Updating app group '%s'", name)
        result = self.fmg.update(url, data)
        self._log.info("App group '%s' updated successfully", name)
        return result

    def delete(self, name: str) -> Dict[str, Any]:
        """Delete an application group."""
        url = f"{self.base_url}/{name}"
        self._log.info("Deleting app group '%s'", name)
        result = self.fmg.delete(url)
        self._log.info("App group '%s' deleted successfully", name)
        return result


# ─────────────────────────────────────────────────────────────────────────────
# Demonstration
# ─────────────────────────────────────────────────────────────────────────────

def demo():
    """CRUD application groups demo."""
    log.info("=" * 60)
    log.info("DEMO CRUD APPLICATION GROUPS")
    log.info("=" * 60)

    with FortiManagerClient() as fmg:
        mgr = AppGroupManager(fmg)

        # CREATE
        log.info("--- CREATE ---")
        try:
            mgr.create(
                "DEMO_APP_SOCIAL",
                ["Facebook", "Twitter", "Instagram"],
                "Demo social media apps"
            )
            mgr.create(
                "DEMO_APP_STREAMING",
                ["Netflix", "YouTube", "Spotify"],
                "Demo streaming apps"
            )
        except FMGObjectExistsError as e:
            log.warning("App group already exists: %s", e)

        # READ
        log.info("--- READ ---")
        groups = mgr.read(filter_pattern="DEMO_APP_*")
        log.info("App groups found: %d", len(groups))
        for grp in groups:
            apps = grp.get("application", [])
            if isinstance(apps, list):
                apps = ", ".join(apps)
            log.info("  - %s: %s", grp["name"], apps)

        # UPDATE
        log.info("--- UPDATE ---")
        try:
            mgr.update(
                "DEMO_APP_SOCIAL",
                applications=["Facebook", "Twitter", "Instagram", "LinkedIn"],
                comment="Updated social media apps"
            )
        except FMGObjectNotFoundError:
            log.warning("App group not found for update")

        # DELETE
        log.info("--- DELETE ---")
        for name in ["DEMO_APP_SOCIAL", "DEMO_APP_STREAMING"]:
            try:
                mgr.delete(name)
            except FMGObjectNotFoundError:
                log.warning("App group not found: %s", name)


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo()
    log.info("Demo completed successfully")
