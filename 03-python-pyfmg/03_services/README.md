# Service Management

> **CRUD operations for FortiManager service objects with pyFMG.**

[Home](../../README.md) > [Level 3](../README.md) > Services

---

## Overview

This section provides Python scripts for managing FortiManager custom service objects using the pyFMG library. Functions handle TCP, UDP, and SCTP services.

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **Custom Service** | `/pm/config/adom/{adom}/obj/firewall/service/custom` |
| **Service Group** | `/pm/config/adom/{adom}/obj/firewall/service/group` |

---

## Scripts

| Script | Description |
|--------|-------------|
| `crud_services.py` | Full CRUD demo with helper functions |

---

## Usage

### Function-Based Pattern

```python
from pyFMG.fortimgr import FortiManager

with FortiManager(FMG_HOST, FMG_USER, FMG_PASS) as fmg:
    # Create TCP service
    create_service(fmg, "SVC_HTTPS_ALT", "TCP", "8443", "HTTPS alternative")

    # Create UDP service
    create_service(fmg, "SVC_DNS_ALT", "UDP", "5353", "DNS alternative")

    # Read services
    services = read_services(fmg, "SVC_*")

    # Delete
    delete_service(fmg, "SVC_HTTPS_ALT")
```

---

## Available Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `create_service()` | fmg, name, protocol, port, comment | Create service |
| `read_services()` | fmg, filter_name | List services |
| `delete_service()` | fmg, name | Delete service |

---

## Protocols

| Protocol | Port Field |
|----------|------------|
| TCP | `tcp-portrange` |
| UDP | `udp-portrange` |
| SCTP | `sctp-portrange` |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/03_services/)
- [Bash Equivalent](../../01-raw-http/bash/03-services/)
- [Previous: Addresses](../02_addresses/)
- [Next: Schedules](../04_schedules/)
