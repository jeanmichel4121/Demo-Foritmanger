# Security Profiles Management

> **CRUD operations for FortiManager security profile objects with Python requests.**

[Home](../../README.md) > [Level 2](../README.md) > Security Profiles

---

## Overview

This section provides Python scripts for managing FortiManager security profile objects. Application groups allow grouping applications for use in firewall policies.

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **Application Group** | `/pm/config/adom/{adom}/obj/application/group` |
| **Application List** | `/pm/config/adom/{adom}/obj/application/list` |

---

## Scripts

| Script | Description |
|--------|-------------|
| `crud_app_groups.py` | Application group management |

---

## Usage

### Application Groups

```python
from utils.fmg_client import FortiManagerClient

with FortiManagerClient() as fmg:
    mgr = AppGroupManager(fmg)

    # Create application group
    mgr.create(
        "APP_SOCIAL",
        ["Facebook", "Twitter", "Instagram"],
        "Social media apps"
    )

    # Read groups
    groups = mgr.read(filter_pattern="APP_*")

    # Update (add LinkedIn)
    mgr.update(
        "APP_SOCIAL",
        applications=["Facebook", "Twitter", "Instagram", "LinkedIn"]
    )

    # Delete
    mgr.delete("APP_SOCIAL")
```

---

## AppGroupManager Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `create()` | name, applications, comment | Create group |
| `read()` | name, filter_pattern | List groups |
| `update()` | name, applications, comment | Update group |
| `delete()` | name | Delete group |

---

## Common Application Categories

| Category | Examples |
|----------|----------|
| Social Media | Facebook, Twitter, Instagram, LinkedIn |
| Streaming | Netflix, YouTube, Spotify, Disney.Plus |
| Productivity | Microsoft.Office.365, Google.Workspace, Slack |
| Gaming | Steam, PlayStation.Network, Xbox.Live |

---

## See Also

- [pyFMG Equivalent](../../03-python-pyfmg/06_security_profiles/)
- [Bash Equivalent](../../01-raw-http/bash/06-security-profiles/)
- [Previous: NAT/VIP](../05_nat_vip/)
- [Next: Firewall Policies](../07_firewall_policies/)
