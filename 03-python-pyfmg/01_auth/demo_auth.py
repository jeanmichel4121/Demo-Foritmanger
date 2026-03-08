#!/usr/bin/env python3
"""
pyFMG authentication demonstration

pyFMG greatly simplifies session management thanks
to the context manager (with statement).
"""

import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from config import (
    FMG_HOST, FMG_USER, FMG_PASS, FMG_API_KEY, FMG_VERIFY,
    setup_logging, get_logger
)
from pyFMG.fortimgr import FortiManager


# ─────────────────────────────────────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────────────────────────────────────

setup_logging()
log = get_logger(__name__)


# ─────────────────────────────────────────────────────────────────────────────
# Demonstrations
# ─────────────────────────────────────────────────────────────────────────────

def demo_context_manager():
    """
    Context manager usage (recommended).

    Login is performed automatically when entering 'with',
    and logout on exit (even on error).
    """
    log.info("=" * 60)
    log.info("DEMO: Context Manager (with statement)")
    log.info("=" * 60)

    with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY) as fmg:
        log.info("Automatically connected")

        # Test: get status
        code, data = fmg.get("/sys/status")
        if code == 0:
            log.info("FortiManager:")
            log.info("  Hostname: %s", data.get("Hostname", "N/A"))
            log.info("  Version:  %s", data.get("Version", "N/A"))
        else:
            log.error("Failed to get status: code %d", code)

    log.info("Automatically disconnected")


def demo_api_key():
    """
    API Key usage (FMG 7.2.2+).

    No context manager needed as there's no session to manage.
    """
    log.info("=" * 60)
    log.info("DEMO: API Key (Bearer Token)")
    log.info("=" * 60)

    if not FMG_API_KEY:
        log.warning("FMG_API_KEY not configured")
        log.info("Add FMG_API_KEY=<your_key> to .env")
        return

    # With API Key, no context manager needed
    fmg = FortiManager(FMG_HOST, apikey=FMG_API_KEY, verify_ssl=FMG_VERIFY)

    code, data = fmg.get("/sys/status")
    if code == 0:
        log.info("API Key connection successful")
        log.info("  Version: %s", data.get("Version", "N/A"))
    else:
        log.error("API Key connection failed: code %d", code)


def demo_manual():
    """
    Manual session management (to understand the mechanism).
    """
    log.info("=" * 60)
    log.info("DEMO: Manual Session")
    log.info("=" * 60)

    fmg = FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=FMG_VERIFY)

    try:
        # Explicit login
        fmg.login()
        log.info("Login completed")

        # Operations...
        code, data = fmg.get("/dvmdb/adom")
        if code == 0 and data:
            log.info("ADOMs found: %d", len(data))
            for adom in data[:5]:
                log.info("  - %s", adom.get("name"))
        else:
            log.error("Failed to get ADOMs: code %d", code)

    except Exception as e:
        log.exception("Error during operation: %s", e)

    finally:
        # Explicit logout
        fmg.logout()
        log.info("Logout completed")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    log.info("#" * 60)
    log.info("# PYFMG AUTHENTICATION DEMO")
    log.info("#" * 60)

    demo_context_manager()
    demo_api_key()
    demo_manual()

    log.info("Demos completed successfully")
