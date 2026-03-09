# Schedule Management

> **CRUD operations for FortiManager schedule objects with Python requests.**

[Home](../../README.md) > [Level 2](../README.md) > Schedules

---

## Overview

This section provides Python scripts for managing FortiManager one-time schedules. Schedules define time windows for firewall policies.

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
| `crud_schedules.py` | Full CRUD demo with ScheduleManager class |

---

## Usage

### Class-Based Pattern

```python
from utils.fmg_client import FortiManagerClient

with FortiManagerClient() as fmg:
    mgr = ScheduleManager(fmg)

    # Create one-time schedule
    mgr.create(
        "MAINT_WINDOW",
        "00:00 2024/12/15",
        "06:00 2024/12/15",
        "Maintenance window"
    )

    # Read schedules
    schedules = mgr.read(filter_pattern="MAINT_*")

    # Update
    mgr.update("MAINT_WINDOW", comment="Updated maintenance")

    # Delete
    mgr.delete("MAINT_WINDOW")
```

---

## ScheduleManager Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `create()` | name, start, end, comment | Create schedule |
| `read()` | name, filter_pattern | List schedules |
| `update()` | name, start, end, comment | Update schedule |
| `delete()` | name | Delete schedule |

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

- [pyFMG Equivalent](../../03-python-pyfmg/04_schedules/)
- [Bash Equivalent](../../01-raw-http/bash/04-schedules/)
- [Previous: Services](../03_services/)
- [Next: NAT/VIP](../05_nat_vip/)
