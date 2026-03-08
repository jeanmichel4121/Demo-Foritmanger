#!/usr/bin/env python3
"""
FortiManager authentication methods demonstration

This script shows the two authentication methods:
1. Session-based (login/logout)
2. Bearer Token (API Key)
"""

import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from config import setup_logging, get_logger
from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGAuthError


# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

setup_logging()
log = get_logger(__name__)


# ─────────────────────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────────────────────

def demo_session_auth():
    """
    Session-based authentication demonstration.

    Uses context manager for automatic login/logout.
    """
    log.info("=" * 60)
    log.info("DEMO: Session Authentication")
    log.info("=" * 60)

    try:
        # Context manager handles login/logout
        with FortiManagerClient() as fmg:
            log.info("Connected! Session: %s...", fmg.session[:20])

            # Test: get system status
            status = fmg.get("/sys/status")
            log.info("FortiManager Info:")
            log.info("  Hostname: %s", status.get("Hostname", "N/A"))
            log.info("  Version:  %s", status.get("Version", "N/A"))
            log.info("  Serial:   %s", status.get("Serial", "N/A"))

        log.info("Automatically disconnected")

    except FMGAuthError as e:
        log.error("Authentication failed: %s", e)
    except Exception as e:
        log.exception("Unexpected error: %s", e)


def demo_bearer_auth():
    """
    API Key (Bearer token) authentication demonstration.

    No login/logout, token is sent with each request.
    """
    log.info("=" * 60)
    log.info("DEMO: Bearer Token Authentication")
    log.info("=" * 60)

    try:
        # No context manager needed with API Key
        fmg = FortiManagerClient(use_api_key=True)

        if not fmg.settings.api_key:
            log.warning("FMG_API_KEY not configured in .env")
            log.info("To use Bearer token:")
            log.info("  1. Create an API admin on FortiManager")
            log.info("  2. Add FMG_API_KEY=<your_key> to .env")
            return

        # Test: get system status
        status = fmg.get("/sys/status")
        log.info("Bearer connection successful!")
        log.info("FortiManager Info:")
        log.info("  Hostname: %s", status.get("Hostname", "N/A"))
        log.info("  Version:  %s", status.get("Version", "N/A"))
        log.info("  Admin:    %s", status.get("Admin", "N/A"))

        log.info("No logout needed with Bearer token")

    except FMGAuthError as e:
        log.error("Invalid API Key: %s", e)
    except Exception as e:
        log.exception("Unexpected error: %s", e)


def demo_manual_session():
    """
    Manual login/logout demonstration (without context manager).

    Useful for understanding the mechanism.
    """
    log.info("=" * 60)
    log.info("DEMO: Manual Session")
    log.info("=" * 60)

    fmg = FortiManagerClient()

    try:
        # Explicit login
        log.info("Logging in...")
        session = fmg.login()
        log.info("Session: %s...", session[:20])

        # Perform some operations
        log.info("Retrieving ADOMs...")
        adoms = fmg.get("/dvmdb/adom")
        if adoms:
            log.info("%d ADOM(s) found", len(adoms))
            for adom in adoms[:5]:  # Max 5
                log.info("  - %s", adom.get("name"))

    except Exception as e:
        log.exception("Error: %s", e)

    finally:
        # Explicit logout (important!)
        log.info("Logging out...")
        fmg.logout()
        log.info("Disconnected")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    log.info("#" * 60)
    log.info("# FORTIMANAGER AUTHENTICATION DEMONSTRATION")
    log.info("#" * 60)

    # Session-based demo
    demo_session_auth()

    # Bearer token demo
    demo_bearer_auth()

    # Manual session demo
    demo_manual_session()

    log.info("#" * 60)
    log.info("# END OF DEMONSTRATION")
    log.info("#" * 60)
