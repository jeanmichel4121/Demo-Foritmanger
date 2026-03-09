# 🐍 FortiManager Python Examples

<div align="center">

**Ready-to-use Python scripts**

*Automate FortiManager with requests*

[📋 Cheatsheets](README.md) • [🔗 Endpoints](api-endpoints.md) • [🔧 cURL](curl-examples.md) • [🎭 Ansible](ansible-examples.md) • [⚠️ Errors](common-errors.md)

---

</div>

## ⚡ Quick Start (2 minutes)

> 🎯 **Goal:** Run your first Python script!

### 1️⃣ Install dependencies

```bash
pip install requests python-dotenv
```

### 2️⃣ Create your `.env` file

```bash
# .env
FMG_HOST=192.168.1.100
FMG_API_KEY=your_api_key
FMG_ADOM=root
```

### 3️⃣ Test the connection

```python
import requests
import os
from dotenv import load_dotenv

load_dotenv()

response = requests.post(
    f"https://{os.getenv('FMG_HOST')}/jsonrpc",
    json={"id": 1, "method": "get", "params": [{"url": "/sys/status"}]},
    headers={"Authorization": f"Bearer {os.getenv('FMG_API_KEY')}"},
    verify=False
)

print(response.json()["result"][0]["status"])
# {'code': 0, 'message': 'OK'}
```

> ✅ **Code 0?** Congratulations, your connection works!

---

## 📖 Table of Contents

| Section | Description | Difficulty |
|:--------|:------------|:-----------|
| [🛠️ Configuration](#️-configuration) | Setup and client | ⭐ Easy |
| [🔐 Authentication](#-authentication) | Session and API Key | ⭐ Easy |
| [📍 Firewall Addresses](#-firewall-addresses) | CRUD addresses | ⭐⭐ Medium |
| [🔌 Services](#-services) | Ports and protocols | ⭐⭐ Medium |
| [📜 Policies](#-firewall-policies) | Security rules | ⭐⭐ Medium |
| [🔀 VIP / NAT](#-vip--nat) | Address translation | ⭐⭐ Medium |
| [🚀 Installation](#-installation) | Config deployment | ⭐⭐⭐ Advanced |
| [💻 Devices](#-devices) | Device management | ⭐⭐ Medium |
| [⚠️ Error Handling](#️-error-handling) | Python exceptions | ⭐⭐ Medium |
| [📦 Bulk Operations](#-bulk-operations) | CSV import | ⭐⭐⭐ Advanced |
| [⚡ One-Liners](#-useful-one-liners) | Quick commands | ⭐⭐ Medium |
| [💡 Best Practices](#-best-practices) | Recommended patterns | ⭐⭐ Medium |

---

## 🛠️ Configuration

### 📝 Environment Variables

```python
# .env - Basic configuration
FMG_HOST=192.168.1.100        # FortiManager IP or FQDN
FMG_USERNAME=admin            # Username (for session)
FMG_PASSWORD=password         # Password (for session)
FMG_API_KEY=your_api_key      # API Key (recommended)
FMG_ADOM=root                 # ADOM name
FMG_VERIFY_SSL=false          # SSL verification
```

### 🔧 FortiManager Client

> 💡 Use the client provided in `02-python-requests/utils/fmg_client.py`

```python
from utils.fmg_client import FortiManagerClient

# With context manager (auto login/logout session)
with FortiManagerClient() as fmg:
    result = fmg.get("/sys/status")
    print(f"Version: {result['Version']}")

# With API Key (no login/logout needed)
fmg = FortiManagerClient(use_api_key=True)
result = fmg.get("/sys/status")
```

### 📊 Client Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FortiManagerClient                        │
├─────────────────────────────────────────────────────────────┤
│  __init__(use_api_key=False)                                │
│  __enter__() → automatic login                              │
│  __exit__()  → automatic logout                             │
├─────────────────────────────────────────────────────────────┤
│  CRUD Methods:                                              │
│    get(url, fields, filter)   → Read                        │
│    add(url, data)             → Create                      │
│    update(url, data)          → Partial Update              │
│    set(url, data)             → Full Replace                │
│    delete(url)                → Delete                      │
│    execute(url, data)         → Actions (install, etc.)     │
├─────────────────────────────────────────────────────────────┤
│  Helpers:                                                   │
│    get_adom_url(path)         → Build full URL              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Authentication

### 🔑 API Key (Recommended)

```python
from utils.fmg_client import FortiManagerClient

# API Key - no session management
fmg = FortiManagerClient(use_api_key=True)

# Ready to use directly
addresses = fmg.get("/pm/config/adom/root/obj/firewall/address")
print(f"Found {len(addresses)} addresses")
```

### 🔓 Session (Login/Logout)

```python
from utils.fmg_client import FortiManagerClient

# Context manager = automatic login/logout
with FortiManagerClient() as fmg:
    addresses = fmg.get("/pm/config/adom/root/obj/firewall/address")
    print(f"Found {len(addresses)} addresses")
# Automatic logout when exiting the block
```

### 🔄 Session Workflow

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────┐
│   LOGIN     │────►│    OPERATIONS    │────►│   LOGOUT    │
│  (auto)     │     │  get/add/update  │     │   (auto)    │
└─────────────┘     └──────────────────┘     └─────────────┘
      │                     │                       │
      │  with ... as fmg:   │   fmg.get(...)       │  end of block
      └─────────────────────┴───────────────────────┘
```

---

## 📍 Firewall Addresses

### ➕ Create an IPv4 Address

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/address")

    # Network address (ipmask)
    fmg.add(url, {
        "name": "NET_WEB_SERVERS",
        "type": "ipmask",
        "subnet": "192.168.10.0 255.255.255.0",
        "comment": "Web Servers"
    })

    # Single host address
    fmg.add(url, {
        "name": "SRV_DATABASE",
        "type": "ipmask",
        "subnet": "192.168.10.50 255.255.255.255",
        "comment": "Primary DB server"
    })

    # FQDN
    fmg.add(url, {
        "name": "FQDN_GITHUB",
        "type": "fqdn",
        "fqdn": "github.com",
        "comment": "GitHub"
    })

    # IP range
    fmg.add(url, {
        "name": "RANGE_DHCP",
        "type": "iprange",
        "start-ip": "192.168.10.100",
        "end-ip": "192.168.10.200",
        "comment": "DHCP Pool"
    })
```

### 📖 Read Addresses

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/address")

    # All addresses
    all_addresses = fmg.get(url)
    print(f"Total: {len(all_addresses)} addresses")

    # Specific address
    my_addr = fmg.get(f"{url}/NET_WEB_SERVERS")
    print(f"Subnet: {my_addr['subnet']}")

    # With filter (name starts with NET_)
    filtered = fmg.get(url, filter=[["name", "like", "NET_%"]])
    print(f"NET_* addresses: {len(filtered)}")

    # Only specific fields
    names_only = fmg.get(url, fields=["name", "subnet"])
```

### ✏️ Update an Address

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/address/NET_WEB_SERVERS")

    # Partial update (keeps other fields)
    fmg.update(url, {
        "comment": "Web Servers - Production",
        "subnet": "192.168.10.0 255.255.254.0"
    })
```

### ❌ Delete an Address

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/address/NET_WEB_SERVERS")
    fmg.delete(url)
```

### 👥 Address Groups

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/addrgrp")

    # Create a group
    fmg.add(url, {
        "name": "GRP_SERVERS",
        "member": ["NET_WEB_SERVERS", "SRV_DATABASE"],
        "comment": "All servers"
    })

    # Add a member to the group
    fmg.update(f"{url}/GRP_SERVERS", {
        "member": ["NET_WEB_SERVERS", "SRV_DATABASE", "SRV_MAIL"]
    })
```

---

## 🔌 Services

### ➕ Create a Service

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/service/custom")

    # TCP Service
    fmg.add(url, {
        "name": "HTTPS_8443",
        "protocol": "TCP/UDP/SCTP",
        "tcp-portrange": "8443",
        "comment": "Alternate HTTPS"
    })

    # Service with port range
    fmg.add(url, {
        "name": "APP_PORTS",
        "protocol": "TCP/UDP/SCTP",
        "tcp-portrange": "8000-8100",
        "comment": "Application ports"
    })

    # UDP Service
    fmg.add(url, {
        "name": "SYSLOG_UDP",
        "protocol": "TCP/UDP/SCTP",
        "udp-portrange": "514",
        "comment": "Syslog"
    })
```

### 👥 Service Groups

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/service/group")

    fmg.add(url, {
        "name": "GRP_WEB_SERVICES",
        "member": ["HTTP", "HTTPS", "HTTPS_8443"],
        "comment": "Web Services"
    })
```

---

## 📜 Firewall Policies

### ➕ Create a Policy

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("pkg/default/firewall/policy")

    # Allow Policy
    fmg.add(url, {
        "name": "Allow-Web-to-Internet",
        "srcintf": ["port1"],
        "dstintf": ["port2"],
        "srcaddr": ["NET_WEB_SERVERS"],
        "dstaddr": ["all"],
        "service": ["HTTP", "HTTPS"],
        "action": "accept",
        "logtraffic": "all",
        "comments": "Internet access for Web servers"
    })

    # Deny Policy (explicit)
    fmg.add(url, {
        "name": "Deny-All",
        "srcintf": ["any"],
        "dstintf": ["any"],
        "srcaddr": ["all"],
        "dstaddr": ["all"],
        "service": ["ALL"],
        "action": "deny",
        "logtraffic": "all",
        "comments": "Deny all - cleanup rule"
    })
```

### 🔄 Move a Policy

```python
with FortiManagerClient() as fmg:
    # Move policy 5 before policy 3
    fmg.execute("/securityconsole/move", {
        "adom": "root",
        "pkg": "default",
        "obj": "firewall/policy/5",
        "target": "3",
        "option": "before"
    })
```

---

## 🔀 VIP / NAT

### ➕ Create a Static NAT VIP (1:1)

```
┌─────────────────────────────────────────────────────┐
│              STATIC NAT (1:1)                       │
│                                                     │
│  Internet              FortiGate           Internal │
│  ─────────►  203.0.113.10  ────►  192.168.10.10    │
│              (Public IP)          (Private IP)      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/vip")

    # VIP Static NAT (1:1)
    fmg.add(url, {
        "name": "VIP_WEB_SERVER",
        "type": "static-nat",
        "extip": "203.0.113.10",
        "mappedip": "192.168.10.10",
        "extintf": "any",
        "comment": "NAT to web server"
    })
```

### ➕ Create Port Forwarding

```
┌─────────────────────────────────────────────────────┐
│              PORT FORWARDING                        │
│                                                     │
│  Internet              FortiGate           Internal │
│  ───► :8080  ──►  203.0.113.10:8080 ──► :80        │
│     (external)                       (internal)     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/vip")

    # Port Forwarding
    fmg.add(url, {
        "name": "VIP_WEB_8080",
        "type": "static-nat",
        "extip": "203.0.113.10",
        "extport": "8080",
        "mappedip": "192.168.10.10",
        "mappedport": "80",
        "extintf": "any",
        "portforward": "enable",
        "protocol": "tcp",
        "comment": "External port 8080 to internal port 80"
    })
```

### 📋 List VIPs

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/vip")

    # All VIPs
    vips = fmg.get(url)
    for vip in vips:
        print(f"{vip['name']}: {vip.get('extip')} → {vip.get('mappedip')}")

    # Port forwarding VIPs only
    port_forwards = fmg.get(url, filter=[["portforward", "==", "enable"]])
```

---

## 🚀 Installation

### 📦 Install a Package

```python
with FortiManagerClient() as fmg:
    # Start installation
    result = fmg.execute("/securityconsole/install/package", {
        "adom": "root",
        "pkg": "default",
        "scope": [{
            "name": "FGT-DC1",
            "vdom": "root"
        }],
        "flags": ["none"]
    })

    task_id = result.get("task")
    print(f"Task ID: {task_id}")
```

### ⏳ Wait for Task Completion

```python
import time

def wait_for_task(fmg, task_id, timeout=300, interval=5):
    """Wait for a FortiManager task to complete."""
    elapsed = 0

    while elapsed < timeout:
        result = fmg.get(f"/task/task/{task_id}")

        percent = result.get("percent", 0)
        state = result.get("state", "unknown")

        print(f"Progress: {percent}% - State: {state}")

        if percent == 100:
            if state == "done":
                print("✅ Task completed successfully")
                return True
            else:
                print(f"❌ Task failed: {state}")
                return False

        time.sleep(interval)
        elapsed += interval

    raise TimeoutError(f"Timeout after {timeout}s")

# Usage
with FortiManagerClient() as fmg:
    result = fmg.execute("/securityconsole/install/package", {
        "adom": "root",
        "pkg": "default",
        "scope": [{"name": "FGT-DC1", "vdom": "root"}]
    })

    wait_for_task(fmg, result["task"])
```

---

## 💻 Devices

### 📋 List Devices

```python
with FortiManagerClient() as fmg:
    # List all devices in an ADOM
    url = f"/dvmdb/adom/{fmg.adom}/device"
    devices = fmg.get(url, fields=["name", "hostname", "ip", "conn_status", "os_ver"])

    for device in devices:
        status = "🟢" if device.get("conn_status") == 1 else "🔴"
        print(f"{status} {device['name']} - {device.get('ip')} ({device.get('os_ver')})")
```

### 🔍 Device Details

```python
with FortiManagerClient() as fmg:
    # Full device details
    device = fmg.get("/dvmdb/device/FGT-01")

    print(f"Hostname: {device.get('hostname')}")
    print(f"IP: {device.get('ip')}")
    print(f"Version: {device.get('os_ver')}")
    print(f"Serial: {device.get('sn')}")
    print(f"Status: {'Connected' if device.get('conn_status') == 1 else 'Disconnected'}")
```

### 📊 Devices Summary by Status

```python
with FortiManagerClient() as fmg:
    url = f"/dvmdb/adom/{fmg.adom}/device"
    devices = fmg.get(url, fields=["name", "conn_status"])

    connected = sum(1 for d in devices if d.get("conn_status") == 1)
    disconnected = len(devices) - connected

    print(f"📊 Devices: {len(devices)} total")
    print(f"   🟢 Connected: {connected}")
    print(f"   🔴 Disconnected: {disconnected}")
```

---

## ⚠️ Error Handling

### 🎯 Exception Hierarchy

```
FMGError (base)
├── FMGAuthError        (code -11)  → Authentication failed
├── FMGObjectNotFoundError (code -2) → Object not found
├── FMGObjectExistsError   (code -3) → Object already exists
├── FMGPermissionError     (code -6) → Permission denied
└── FMGRequestError        (other)   → Generic error
```

### 🔄 Create-or-Update Pattern

```python
from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGObjectExistsError, FMGObjectNotFoundError

def create_or_update_address(fmg, name, subnet, comment=""):
    """Create an address or update it if it exists."""
    url = fmg.get_adom_url("obj/firewall/address")

    data = {
        "name": name,
        "type": "ipmask",
        "subnet": subnet,
        "comment": comment
    }

    try:
        # Try to create
        fmg.add(url, data)
        print(f"✅ Created: {name}")
    except FMGObjectExistsError:
        # Update if exists
        fmg.update(f"{url}/{name}", data)
        print(f"🔄 Updated: {name}")

# Usage
with FortiManagerClient() as fmg:
    create_or_update_address(fmg, "NET_TEST", "10.0.0.0 255.255.255.0", "Test")
```

### 🛡️ Complete Error Handling

```python
from utils.exceptions import (
    FMGError,
    FMGAuthError,
    FMGObjectNotFoundError,
    FMGObjectExistsError,
    FMGPermissionError,
)

def safe_operation(fmg, operation, *args, **kwargs):
    """Execute an operation with error handling."""
    try:
        return operation(*args, **kwargs)

    except FMGAuthError:
        print("❌ Authentication error - check your credentials")
        raise

    except FMGObjectNotFoundError as e:
        print(f"⚠️ Object not found: {e}")
        return None

    except FMGObjectExistsError as e:
        print(f"⚠️ Object already exists: {e}")
        return None

    except FMGPermissionError:
        print("❌ Permission denied - check user permissions")
        raise

    except FMGError as e:
        print(f"❌ API Error: {e}")
        raise

# Usage
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/address/NONEXISTENT")
    result = safe_operation(fmg, fmg.get, url)
    # ⚠️ Object not found: [-2] Object 'NONEXISTENT' not found
```

---

## 📦 Bulk Operations

### 📥 Import from CSV

```python
import csv
from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGObjectExistsError

def cidr_to_mask(cidr):
    """Convert CIDR to mask notation (e.g.: /24 → 255.255.255.0)"""
    network, prefix = cidr.split("/")
    prefix = int(prefix)
    mask = ".".join([str((0xffffffff << (32 - prefix) >> i) & 0xff)
                     for i in [24, 16, 8, 0]])
    return f"{network} {mask}"

def import_addresses_from_csv(csv_file):
    """Import addresses from a CSV file."""
    with FortiManagerClient() as fmg:
        url = fmg.get_adom_url("obj/firewall/address")

        created = 0
        updated = 0
        errors = 0

        with open(csv_file, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)

            for row in reader:
                name = row["name"]
                subnet = cidr_to_mask(row["subnet"])
                comment = row.get("comment", "")

                try:
                    fmg.add(url, {
                        "name": name,
                        "type": "ipmask",
                        "subnet": subnet,
                        "comment": comment
                    })
                    created += 1
                    print(f"✅ Created: {name}")

                except FMGObjectExistsError:
                    fmg.update(f"{url}/{name}", {
                        "subnet": subnet,
                        "comment": comment
                    })
                    updated += 1
                    print(f"🔄 Updated: {name}")

                except Exception as e:
                    errors += 1
                    print(f"❌ Error {name}: {e}")

        print(f"\n📊 Summary: {created} created, {updated} updated, {errors} errors")

# Usage
# addresses.csv:
# name,subnet,comment
# NET_A,10.0.0.0/24,Network A
# NET_B,172.16.0.0/16,Network B
import_addresses_from_csv("addresses.csv")
```

### 📤 Export to CSV

```python
import csv
from utils.fmg_client import FortiManagerClient

def export_addresses_to_csv(csv_file):
    """Export addresses to a CSV file."""
    with FortiManagerClient() as fmg:
        url = fmg.get_adom_url("obj/firewall/address")
        addresses = fmg.get(url, fields=["name", "type", "subnet", "comment"])

        with open(csv_file, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=["name", "type", "subnet", "comment"])
            writer.writeheader()

            for addr in addresses:
                subnet = addr.get("subnet", [])
                if isinstance(subnet, list):
                    subnet = " ".join(subnet)

                writer.writerow({
                    "name": addr.get("name", ""),
                    "type": addr.get("type", ""),
                    "subnet": subnet,
                    "comment": addr.get("comment", "")
                })

        print(f"✅ Exporté {len(addresses)} adresses vers {csv_file}")

# Usage
export_addresses_to_csv("addresses_export.csv")
```

---

## ⚡ Useful One-Liners

### 📋 List Address Names

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/address")
    names = [addr["name"] for addr in fmg.get(url, fields=["name"])]
    print("\n".join(names))
```

### 🔢 Count Objects

```python
with FortiManagerClient() as fmg:
    counts = {
        "addresses": len(fmg.get(fmg.get_adom_url("obj/firewall/address"))),
        "services": len(fmg.get(fmg.get_adom_url("obj/firewall/service/custom"))),
        "policies": len(fmg.get(fmg.get_adom_url("pkg/default/firewall/policy"))),
        "vips": len(fmg.get(fmg.get_adom_url("obj/firewall/vip"))),
    }
    for obj, count in counts.items():
        print(f"{obj}: {count}")
```

### 🔍 Find Unused Addresses

```python
with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/address")
    # Use "get used" option to see references
    addresses = fmg.get(url, option=["get used"])

    unused = [addr["name"] for addr in addresses if not addr.get("_used_by")]
    print(f"🔍 {len(unused)} unused addresses:")
    for name in unused:
        print(f"  - {name}")
```

### 📊 Policies Summary by Action

```python
from collections import Counter

with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("pkg/default/firewall/policy")
    policies = fmg.get(url, fields=["action"])

    actions = Counter(p.get("action", "unknown") for p in policies)
    print("📊 Policies by action:")
    for action, count in actions.items():
        print(f"  {action}: {count}")
```

### 📤 CSV Export One-liner

```python
import csv
from utils.fmg_client import FortiManagerClient

# Quick one-line export (after setup)
with FortiManagerClient() as fmg, open("export.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=["name", "subnet"])
    writer.writeheader()
    writer.writerows([{"name": a["name"], "subnet": a.get("subnet", "")}
                      for a in fmg.get(fmg.get_adom_url("obj/firewall/address"))])
```

---

## 💡 Best Practices

<table>
<tr>
<td width="50%">

### ✅ Do

- 🔐 **Use API Key** instead of session
- 📦 **Context manager** for sessions
- ⚠️ **Handle specific exceptions**
- 🔄 **Create-or-update pattern** for idempotence
- 📝 **Use .env** for secrets
- 🧪 **Test in lab** before production

</td>
<td width="50%">

### ❌ Don't

- ❌ Store secrets in code
- ❌ Ignore API errors
- ❌ Forget logout without context manager
- ❌ Hardcode ADOM URLs
- ❌ Modify production without testing
- ❌ Ignore error codes

</td>
</tr>
</table>

### 🔄 Recommended Pattern

```python
# ✅ GOOD - Context manager + exceptions + helpers
from utils.fmg_client import FortiManagerClient
from utils.exceptions import FMGObjectExistsError

with FortiManagerClient() as fmg:
    url = fmg.get_adom_url("obj/firewall/address")

    try:
        fmg.add(url, {"name": "TEST", "subnet": "10.0.0.0 255.0.0.0"})
    except FMGObjectExistsError:
        fmg.update(f"{url}/TEST", {"subnet": "10.0.0.0 255.0.0.0"})
```

```python
# ❌ BAD - No error handling, hardcoded
import requests

response = requests.post(
    "https://192.168.1.100/jsonrpc",  # Hardcoded!
    json={...},
    headers={"Authorization": "Bearer abc123"},  # Secret in code!
    verify=False
)
# No error handling!
print(response.json())
```

---

## 🔧 Troubleshooting

| Problem | Cause | Solution |
|:--------|:------|:---------|
| `SSLError` | Invalid certificate | `FMG_VERIFY_SSL=false` or install CA |
| `FMGAuthError` | Invalid credentials | Check `.env` and API permissions |
| `Timeout` | Network or FMG overloaded | Increase timeout or retry |
| `FMGObjectNotFoundError` | Wrong name or ADOM | Check URL and ADOM |
| `FMGPermissionError` | Insufficient rights | Check user profile |

### 🐛 Enable Debug

```python
import logging

# Enable debug logging
logging.basicConfig(level=logging.DEBUG)

# Requests/responses will be displayed
with FortiManagerClient() as fmg:
    fmg.get("/sys/status")
```

---

## 📚 See Also

<table>
<tr>
<td align="center" width="25%">

🔗 **[API Endpoints](api-endpoints.md)**

*Find the right URL*

</td>
<td align="center" width="25%">

🔧 **[cURL Examples](curl-examples.md)**

*Quick CLI tests*

</td>
<td align="center" width="25%">

🎭 **[Ansible Examples](ansible-examples.md)**

*Infrastructure as Code*

</td>
<td align="center" width="25%">

⚠️ **[Common Errors](common-errors.md)**

*Diagnostics and solutions*

</td>
</tr>
</table>

---

<div align="center">

*These scripts are made to be copied and adapted - use them!* 🐍

</div>
