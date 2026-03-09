# Firewall Policy Management

> **CRUD operations for FortiManager firewall policies with pyFMG.**

[Home](../../README.md) > [Level 3](../README.md) > Firewall Policies

---

## Overview

This section provides Python scripts for managing FortiManager firewall policies using pyFMG. The complete_workflow.py demonstrates end-to-end policy management including package installation.

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **Firewall Policy** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy` |
| **Policy Package** | `/pm/pkg/adom/{adom}` |
| **Install Task** | `/securityconsole/install/package` |

---

## Scripts

| Script | Description |
|--------|-------------|
| `complete_workflow.py` | End-to-end policy workflow demo |

---

## Usage

### Complete Workflow

```python
from pyFMG.fortimgr import FortiManager

with FortiManager(FMG_HOST, FMG_USER, FMG_PASS) as fmg:
    # 1. Create address objects
    fmg.add(addr_url, name="NET_WEB", subnet="10.10.10.0 255.255.255.0")

    # 2. Create policy
    fmg.add(policy_url,
        name="Allow_Web",
        srcintf=["port1"],
        dstintf=["port2"],
        srcaddr=["all"],
        dstaddr=["NET_WEB"],
        service=["HTTP", "HTTPS"],
        action="accept"
    )

    # 3. Install package
    fmg.exec("/securityconsole/install/package",
        adom=FMG_ADOM,
        pkg="default",
        scope=[{"name": "FGT-01", "vdom": "root"}]
    )
```

---

## Policy Workflow

```
1. Create objects (addresses, services, schedules, etc.)
2. Create policy referencing objects
3. Move policy to desired position
4. Install package to FortiGate devices
```

---

## Common Policy Fields

| Field | Description |
|-------|-------------|
| `name` | Policy name |
| `srcintf` | Source interfaces |
| `dstintf` | Destination interfaces |
| `srcaddr` | Source addresses |
| `dstaddr` | Destination addresses |
| `service` | Services |
| `action` | accept/deny |
| `schedule` | Time schedule |
| `nat` | Enable NAT |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/07_firewall_policies/)
- [Bash Equivalent](../../01-raw-http/bash/07-firewall-policies/)
- [Previous: Security Profiles](../06_security_profiles/)
- [Policy Installation Workflow](../../docs/03-covered-operations.md)
