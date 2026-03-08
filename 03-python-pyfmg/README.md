# Level 3: Python + pyFMG

> **Use Fortinet's official library for simplified, production-ready automation.**

---

## Overview

This section uses **pyFMG** (v0.8.6.3), the official Python library maintained by the Fortinet North America CSE Team. You'll learn:

- **Simplified API calls** - No manual JSON-RPC construction
- **Context managers** - Automatic session handling
- **API Key support** - Secure, stateless authentication
- **Production patterns** - Ready for real-world deployments

**pyFMG abstracts the complexity of JSON-RPC, letting you focus on your automation logic.**

---

## pyFMG Advantages

| Feature | Manual (requests) | pyFMG |
|---------|-------------------|-------|
| Session management | Manual login/logout | Context manager |
| JSON-RPC payload | Build manually | Abstracted |
| API methods | Custom implementation | Built-in get/add/set/update/delete |
| Error codes | Manual parsing | Returned as tuple |
| SSL handling | Configure urllib3 | Parameter |

---

## Prerequisites

- **Python 3.8+**
- **pip** for package management
- **FortiManager 7.2.x - 7.6.x**
- **Credentials** configured in `.env` file

---

## Installation

```bash
cd 03-python-pyfmg

# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt
```

### Dependencies

```
pyfmg>=0.8.6.3
python-dotenv>=1.0.0
```

---

## Folder Structure

```
03-python-pyfmg/
├── README.md               # This file
├── requirements.txt        # Dependencies
├── 01_auth/
│   └── demo_auth.py        # Authentication methods demo
├── 02_addresses/
│   └── crud_addresses.py   # Address CRUD operations
└── 07_firewall_policies/
    └── complete_workflow.py # End-to-end workflow demo
```

---

## Quick Start

### 1. Configure Environment

```bash
# From project root
cp .env.example .env
# Edit with your credentials
```

### 2. Test Connection

```bash
cd 03-python-pyfmg/01_auth
python demo_auth.py
```

Expected output:
```
============================================================
DEMO: Context Manager (with statement)
============================================================
[OK] Automatically connected

FortiManager:
  Hostname: FMG-01
  Version: 7.4.10
[OK] Automatically disconnected
```

---

## Core Usage

### Basic Import

```python
from pyFMG.fortimgr import FortiManager
```

### Session-Based (Context Manager)

```python
# Automatic login on enter, logout on exit
with FortiManager("192.168.1.100", "admin", "password", verify_ssl=False) as fmg:
    code, data = fmg.get("/sys/status")
    print(f"Version: {data.get('Version')}")
# Session automatically closed
```

### API Key Authentication (FMG 7.2.2+)

```python
# No login/logout required - stateless
fmg = FortiManager("192.168.1.100", apikey="your_api_key", verify_ssl=False)
code, data = fmg.get("/sys/status")
```

### Manual Session (When Needed)

```python
fmg = FortiManager("192.168.1.100", "admin", "password", verify_ssl=False)

fmg.login()
try:
    code, data = fmg.get("/dvmdb/adom")
    print(f"ADOMs: {len(data)}")
finally:
    fmg.logout()
```

---

## CRUD Operations

### Create (add)

```python
with FortiManager(host, user, password, verify_ssl=False) as fmg:

    code, response = fmg.add(
        "/pm/config/adom/root/obj/firewall/address",
        name="SRV_WEB_01",
        type="ipmask",
        subnet="192.168.10.10 255.255.255.255",
        comment="Web Server"
    )

    if code == 0:
        print("Address created successfully")
    elif code == -3:
        print("Address already exists")
```

### Read (get)

```python
# Get all addresses
code, addresses = fmg.get("/pm/config/adom/root/obj/firewall/address")

# Get specific address
code, address = fmg.get("/pm/config/adom/root/obj/firewall/address/SRV_WEB_01")

# Get with filter
code, addresses = fmg.get(
    "/pm/config/adom/root/obj/firewall/address",
    filter=[["name", "like", "SRV_%"]]
)

# Get specific fields
code, addresses = fmg.get(
    "/pm/config/adom/root/obj/firewall/address",
    fields=["name", "subnet", "comment"]
)
```

### Update (update/set)

```python
# Partial update - only specified fields
code, response = fmg.update(
    "/pm/config/adom/root/obj/firewall/address/SRV_WEB_01",
    comment="Updated comment"
)

# Full update - replaces entire object
code, response = fmg.set(
    "/pm/config/adom/root/obj/firewall/address/SRV_WEB_01",
    name="SRV_WEB_01",
    type="ipmask",
    subnet="192.168.10.10 255.255.255.255",
    comment="New full definition"
)
```

### Delete (delete)

```python
code, response = fmg.delete("/pm/config/adom/root/obj/firewall/address/SRV_WEB_01")

if code == 0:
    print("Deleted successfully")
elif code == -2:
    print("Object not found")
elif code == -10:
    print("Object is in use - remove references first")
```

---

## Complete Workflow Example

The `07_firewall_policies/complete_workflow.py` demonstrates a full automation scenario:

```python
from pyFMG.fortimgr import FortiManager

def complete_workflow():
    """Create objects, policy, and install."""

    with FortiManager(HOST, USER, PASS, verify_ssl=False) as fmg:

        # 1. Create source address
        fmg.add(
            f"/pm/config/adom/{ADOM}/obj/firewall/address",
            name="DEMO_SRC_NET",
            type="ipmask",
            subnet="10.10.0.0 255.255.0.0"
        )

        # 2. Create destination address
        fmg.add(
            f"/pm/config/adom/{ADOM}/obj/firewall/address",
            name="DEMO_DST_NET",
            type="ipmask",
            subnet="192.168.100.0 255.255.255.0"
        )

        # 3. Create firewall policy
        fmg.add(
            f"/pm/config/adom/{ADOM}/pkg/{PACKAGE}/firewall/policy",
            name="DEMO_POLICY",
            srcintf=["any"],
            dstintf=["any"],
            srcaddr=["DEMO_SRC_NET"],
            dstaddr=["DEMO_DST_NET"],
            service=["ALL"],
            action="accept",
            logtraffic="all"
        )

        # 4. Preview installation
        code, response = fmg.execute(
            "/securityconsole/install/preview",
            adom=ADOM,
            pkg=PACKAGE
        )
        print("Preview generated - check FortiManager UI")

        # 5. Install (uncomment for actual deployment)
        # code, response = fmg.execute(
        #     "/securityconsole/install/package",
        #     adom=ADOM,
        #     pkg=PACKAGE,
        #     scope=[{"name": "FGT-01", "vdom": "root"}]
        # )
```

---

## Return Codes

All pyFMG methods return a tuple: `(code, data)`

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | Process data |
| -2 | Object not found | Check name/URL |
| -3 | Object exists | Use update or set |
| -6 | Permission denied | Check user permissions |
| -10 | Object in use | Remove references |
| -11 | Auth error | Check credentials |

### Handling Return Codes

```python
code, data = fmg.add(url, **params)

if code == 0:
    print(f"Success: {data}")
elif code == -3:
    print("Already exists, updating...")
    code, data = fmg.update(url, **params)
else:
    print(f"Error code: {code}")
```

---

## pyFMG Constructor Options

```python
from pyFMG.fortimgr import FortiManager

fmg = FortiManager(
    host="192.168.1.100",       # FMG IP/hostname
    username="admin",           # For session auth
    password="password",        # For session auth
    apikey="abc123",            # For API key auth (alternative)
    verify_ssl=False,           # SSL verification
    debug=True,                 # Enable debug output
    timeout=100,                # Request timeout (seconds)
    use_ssl=True,               # Use HTTPS (default True)
    disable_request_warnings=True,  # Suppress urllib3 warnings
    check_adom_workspace=False  # Check workspace mode
)
```

---

## Best Practices

### 1. Always Use Context Managers

```python
# Good: Automatic cleanup
with FortiManager(host, user, password, verify_ssl=False) as fmg:
    fmg.get(...)
    fmg.add(...)
# Session automatically closed, even on errors
```

### 2. Check Return Codes

```python
code, data = fmg.add(url, **params)
if code != 0:
    raise Exception(f"API error: {code}")
```

### 3. Use API Keys for Automation

```python
# Better for scripts, CI/CD, scheduled jobs
fmg = FortiManager(host, apikey=api_key, verify_ssl=False)
```

### 4. Enable Debug for Troubleshooting

```python
fmg = FortiManager(host, user, password, debug=True)
# Prints raw HTTP requests/responses
```

---

## Comparison: pyFMG vs Manual requests

```python
# === Manual (requests library) ===
payload = {
    "id": 1,
    "method": "add",
    "params": [{
        "url": "/pm/config/adom/root/obj/firewall/address",
        "data": {
            "name": "TEST",
            "type": "ipmask",
            "subnet": "10.0.0.0 255.0.0.0"
        }
    }],
    "session": session_token
}
response = requests.post(url, json=payload)
result = response.json()
code = result["result"][0]["status"]["code"]

# === pyFMG ===
code, data = fmg.add(
    "/pm/config/adom/root/obj/firewall/address",
    name="TEST",
    type="ipmask",
    subnet="10.0.0.0 255.0.0.0"
)
```

---

## Common Patterns

### Create or Update (Upsert)

```python
def upsert_address(fmg, name, subnet, comment=""):
    url = f"/pm/config/adom/root/obj/firewall/address"

    code, _ = fmg.add(url, name=name, type="ipmask", subnet=subnet, comment=comment)

    if code == -3:  # Already exists
        code, _ = fmg.update(f"{url}/{name}", subnet=subnet, comment=comment)

    return code == 0
```

### Bulk Operations

```python
addresses = [
    {"name": "NET_A", "subnet": "10.0.0.0 255.0.0.0"},
    {"name": "NET_B", "subnet": "172.16.0.0 255.255.0.0"},
    {"name": "NET_C", "subnet": "192.168.0.0 255.255.255.0"},
]

with FortiManager(host, user, password, verify_ssl=False) as fmg:
    for addr in addresses:
        code, _ = fmg.add(
            "/pm/config/adom/root/obj/firewall/address",
            type="ipmask",
            **addr
        )
        status = "OK" if code == 0 else f"Error {code}"
        print(f"{addr['name']}: {status}")
```

---

## Next Steps

Once you've mastered pyFMG:

1. **Explore Ansible** (`04-ansible/`) - Declarative infrastructure as code
2. **Build production tools** - Use pyFMG in real automation projects

---

## Reference

- [Main README](../README.md)
- [pyFMG on PyPI](https://pypi.org/project/pyfmg/)
- [pyFMG on GitHub](https://github.com/p4r4n0y1ng/pyfmg)
- [FortiManager API Best Practices](https://docs.fortinet.com/document/fortimanager/7.6.0/api-best-practices/500458/introduction)
