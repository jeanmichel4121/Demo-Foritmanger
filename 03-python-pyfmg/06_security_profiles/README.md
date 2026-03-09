# Security Profiles Management

> **CRUD operations for FortiManager security profile objects with pyFMG.**

[Home](../../README.md) > [Level 3](../README.md) > Security Profiles

---

## Overview

This section provides Python scripts for managing FortiManager security profile objects using pyFMG. Application groups allow grouping applications for firewall policies.

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
from pyFMG.fortimgr import FortiManager

with FortiManager(FMG_HOST, FMG_USER, FMG_PASS) as fmg:
    # Create group
    create_app_group(fmg, "APP_SOCIAL", ["Facebook", "Twitter", "Instagram"])

    # Read groups
    groups = read_app_groups(fmg, "APP_*")

    # Update
    update_app_group(fmg, "APP_SOCIAL",
                     application=["Facebook", "Twitter", "Instagram", "LinkedIn"])

    # Delete
    delete_app_group(fmg, "APP_SOCIAL")
```

---

## Available Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `create_app_group()` | fmg, name, applications, comment | Create group |
| `read_app_groups()` | fmg, filter_name | List groups |
| `update_app_group()` | fmg, name, **updates | Update group |
| `delete_app_group()` | fmg, name | Delete group |

---

## Common Application Categories

| Category | Examples |
|----------|----------|
| Social Media | Facebook, Twitter, Instagram, LinkedIn |
| Streaming | Netflix, YouTube, Spotify |
| Productivity | Microsoft.Office.365, Google.Workspace |
| Gaming | Steam, PlayStation.Network |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/06_security_profiles/)
- [Bash Equivalent](../../01-raw-http/bash/06-security-profiles/)
- [Previous: NAT/VIP](../05_nat_vip/)
- [Next: Firewall Policies](../07_firewall_policies/)
