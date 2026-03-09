# Service Management

> **CRUD operations for FortiManager service objects with Python requests.**

[Home](../../README.md) > [Level 2](../README.md) > Services

---

## Overview

This section provides Python scripts for managing FortiManager custom service objects. The ServiceManager class handles TCP, UDP, and SCTP services with proper port range support.

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
| `crud_services.py` | Full CRUD demo with ServiceManager class |

---

## Usage

### Class-Based Pattern

```python
from utils.fmg_client import FortiManagerClient

with FortiManagerClient() as fmg:
    mgr = ServiceManager(fmg)

    # Create TCP service
    mgr.create("SVC_HTTPS_ALT", "TCP", "8443", "HTTPS alternative")

    # Create UDP service
    mgr.create("SVC_DNS_ALT", "UDP", "5353", "DNS alternative")

    # Read services
    services = mgr.read(filter_pattern="SVC_*")

    # Delete
    mgr.delete("SVC_HTTPS_ALT")
```

---

## ServiceManager Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `create()` | name, protocol, port, comment | Create service |
| `read()` | name, filter_pattern | List services |
| `delete()` | name | Delete service |

---

## Protocols

| Protocol | Port Field |
|----------|------------|
| TCP | `tcp-portrange` |
| UDP | `udp-portrange` |
| SCTP | `sctp-portrange` |

---

## See Also

- [pyFMG Equivalent](../../03-python-pyfmg/03_services/)
- [Bash Equivalent](../../01-raw-http/bash/03-services/)
- [Previous: Addresses](../02_addresses/)
- [Next: Schedules](../04_schedules/)
