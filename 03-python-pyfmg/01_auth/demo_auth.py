#!/usr/bin/env python3
"""
pyFMG authentication demonstration

pyFMG greatly simplifies session management thanks
to the context manager (with statement).
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# Load .env
env_path = Path(__file__).parent.parent.parent / ".env"
load_dotenv(env_path)

from pyFMG.fortimgr import FortiManager


def demo_context_manager():
    """
    Context manager usage (recommended).

    Login is performed automatically when entering 'with',
    and logout on exit (even on error).
    """
    print("\n" + "=" * 60)
    print("DEMO: Context Manager (with statement)")
    print("=" * 60)

    host = os.getenv("FMG_HOST")
    user = os.getenv("FMG_USERNAME")
    passwd = os.getenv("FMG_PASSWORD")
    verify = os.getenv("FMG_VERIFY_SSL", "false").lower() == "true"

    with FortiManager(host, user, passwd, verify_ssl=verify) as fmg:
        print("[OK] Automatically connected")

        # Test: get status
        code, data = fmg.get("/sys/status")
        if code == 0:
            print(f"\nFortiManager:")
            print(f"  Hostname: {data.get('Hostname', 'N/A')}")
            print(f"  Version:  {data.get('Version', 'N/A')}")

    print("[OK] Automatically disconnected")


def demo_api_key():
    """
    API Key usage (FMG 7.2.2+).

    No context manager needed as there's no session to manage.
    """
    print("\n" + "=" * 60)
    print("DEMO: API Key (Bearer Token)")
    print("=" * 60)

    host = os.getenv("FMG_HOST")
    api_key = os.getenv("FMG_API_KEY")
    verify = os.getenv("FMG_VERIFY_SSL", "false").lower() == "true"

    if not api_key:
        print("[WARNING] FMG_API_KEY not configured")
        print("Add FMG_API_KEY=<your_key> to .env")
        return

    # With API Key, no context manager needed
    fmg = FortiManager(host, apikey=api_key, verify_ssl=verify)

    code, data = fmg.get("/sys/status")
    if code == 0:
        print("[OK] API Key connection successful")
        print(f"  Version: {data.get('Version', 'N/A')}")


def demo_manual():
    """
    Manual session management (to understand the mechanism).
    """
    print("\n" + "=" * 60)
    print("DEMO: Manual Session")
    print("=" * 60)

    host = os.getenv("FMG_HOST")
    user = os.getenv("FMG_USERNAME")
    passwd = os.getenv("FMG_PASSWORD")
    verify = os.getenv("FMG_VERIFY_SSL", "false").lower() == "true"

    fmg = FortiManager(host, user, passwd, verify_ssl=verify)

    try:
        # Explicit login
        fmg.login()
        print("[OK] Login completed")

        # Operations...
        code, data = fmg.get("/dvmdb/adom")
        if code == 0 and data:
            print(f"ADOMs: {len(data)}")

    finally:
        # Explicit logout
        fmg.logout()
        print("[OK] Logout completed")


if __name__ == "__main__":
    print("\n" + "#" * 60)
    print("# PYFMG AUTHENTICATION DEMO")
    print("#" * 60)

    demo_context_manager()
    demo_api_key()
    demo_manual()

    print("\n[OK] Demos completed")
