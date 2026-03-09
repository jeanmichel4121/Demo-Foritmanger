# Schedule Management

> **CRUD operations for FortiManager schedule objects with pyFMG.**

[Home](../../README.md) > [Level 3](../README.md) > Schedules

---

## Overview

This section provides Python scripts for managing FortiManager one-time schedules using the pyFMG library.

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **One-time Schedule** | `/pm/config/adom/{adom}/obj/firewall/schedule/onetime` |
| **Recurring Schedule** | `/pm/config/adom/{adom}/obj/firewall/schedule/recurring` |

---

## Scripts

| Script | Description |
|--------|-------------|
| `crud_schedules.py` | Full CRUD demo with helper functions |

---

## Usage

### Function-Based Pattern

```python
from pyFMG.fortimgr import FortiManager

with FortiManager(FMG_HOST, FMG_USER, FMG_PASS) as fmg:
    # Create schedule
    create_schedule(fmg, "MAINT", "00:00 2024/12/15", "06:00 2024/12/15", "Maintenance")

    # Read schedules
    schedules = read_schedules(fmg, "MAINT*")

    # Update
    update_schedule(fmg, "MAINT", comment="Updated maintenance")

    # Delete
    delete_schedule(fmg, "MAINT")
```

---

## Available Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `create_schedule()` | fmg, name, start, end, comment | Create schedule |
| `read_schedules()` | fmg, filter_name | List schedules |
| `update_schedule()` | fmg, name, **updates | Update schedule |
| `delete_schedule()` | fmg, name | Delete schedule |

---

## Datetime Format

```
"HH:MM YYYY/MM/DD"
```

Examples:
- `"00:00 2024/12/15"` - Midnight on December 15, 2024
- `"14:30 2025/01/01"` - 2:30 PM on January 1, 2025

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/04_schedules/)
- [Bash Equivalent](../../01-raw-http/bash/04-schedules/)
- [Previous: Services](../03_services/)
- [Next: NAT/VIP](../05_nat_vip/)
