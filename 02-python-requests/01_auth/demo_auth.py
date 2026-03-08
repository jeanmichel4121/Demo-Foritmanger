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

from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGAuthError


def demo_session_auth():
    """
    Session-based authentication demonstration.

    Uses context manager for automatic login/logout.
    """
    print("\n" + "=" * 60)
    print("DEMO: Session Authentication")
    print("=" * 60)

    try:
        # Context manager handles login/logout
        with FortiManagerClient() as fmg:
            print(f"[OK] Connected! Session: {fmg.session[:20]}...")

            # Test: get system status
            status = fmg.get("/sys/status")
            print(f"\nFortiManager Info:")
            print(f"  Hostname: {status.get('Hostname', 'N/A')}")
            print(f"  Version:  {status.get('Version', 'N/A')}")
            print(f"  Serial:   {status.get('Serial', 'N/A')}")

        print("\n[OK] Automatically disconnected")

    except FMGAuthError as e:
        print(f"\n[ERROR] Authentication failed: {e}")
    except Exception as e:
        print(f"\n[ERROR] {e}")


def demo_bearer_auth():
    """
    API Key (Bearer token) authentication demonstration.

    No login/logout, token is sent with each request.
    """
    print("\n" + "=" * 60)
    print("DEMO: Bearer Token Authentication")
    print("=" * 60)

    try:
        # No context manager needed with API Key
        fmg = FortiManagerClient(use_api_key=True)

        if not fmg.settings.api_key:
            print("[WARNING] FMG_API_KEY not configured in .env")
            print("To use Bearer token:")
            print("  1. Create an API admin on FortiManager")
            print("  2. Add FMG_API_KEY=<your_key> to .env")
            return

        # Test: get system status
        status = fmg.get("/sys/status")
        print(f"[OK] Bearer connection successful!")
        print(f"\nFortiManager Info:")
        print(f"  Hostname: {status.get('Hostname', 'N/A')}")
        print(f"  Version:  {status.get('Version', 'N/A')}")
        print(f"  Admin:    {status.get('Admin', 'N/A')}")

        print("\n[INFO] No logout needed with Bearer token")

    except FMGAuthError as e:
        print(f"\n[ERROR] Invalid API Key: {e}")
    except Exception as e:
        print(f"\n[ERROR] {e}")


def demo_manual_session():
    """
    Manual login/logout demonstration (without context manager).

    Useful for understanding the mechanism.
    """
    print("\n" + "=" * 60)
    print("DEMO: Manual Session")
    print("=" * 60)

    fmg = FortiManagerClient()

    try:
        # Explicit login
        print("Login...")
        session = fmg.login()
        print(f"[OK] Session: {session[:20]}...")

        # Perform some operations
        print("\nRetrieving ADOMs...")
        adoms = fmg.get("/dvmdb/adom")
        if adoms:
            print(f"[OK] {len(adoms)} ADOM(s) found")
            for adom in adoms[:5]:  # Max 5
                print(f"  - {adom.get('name')}")

    except Exception as e:
        print(f"[ERROR] {e}")

    finally:
        # Explicit logout (important!)
        print("\nLogout...")
        fmg.logout()
        print("[OK] Disconnected")


if __name__ == "__main__":
    print("\n" + "#" * 60)
    print("# FORTIMANAGER AUTHENTICATION DEMONSTRATION")
    print("#" * 60)

    # Session-based demo
    demo_session_auth()

    # Bearer token demo
    demo_bearer_auth()

    # Manual session demo
    demo_manual_session()

    print("\n" + "#" * 60)
    print("# END OF DEMONSTRATION")
    print("#" * 60)
