# Address Management

> **CRUD operations for FortiManager address objects with pyFMG.**

[Home](../../README.md) > [Level 3](../README.md) > Addresses

---

## Overview

This section provides Python scripts for managing FortiManager firewall address objects using the pyFMG library. Functions handle CRUD operations with automatic CIDR-to-mask conversion.

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **IPv4 Address** | `/pm/config/adom/{adom}/obj/firewall/address` |
| **IPv4 Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp` |

---

## Scripts

| Script | Description |
|--------|-------------|
| `crud_addresses.py` | Full CRUD demo with helper functions |

---

## Usage

### Function-Based Pattern

```python
from pyFMG.fortimgr import FortiManager

with FortiManager(FMG_HOST, FMG_USER, FMG_PASS) as fmg:
    # Create
    create_address(fmg, "NET_SERVERS", "10.10.10.0/24", "Server network")

    # Read
    addresses = read_addresses(fmg, "NET_*")

    # Update
    update_address(fmg, "NET_SERVERS", comment="Production servers")

    # Delete
    delete_address(fmg, "NET_SERVERS")
```

---

## Available Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `create_address()` | fmg, name, subnet, comment | Create address |
| `read_addresses()` | fmg, filter_name | List addresses |
| `update_address()` | fmg, name, **updates | Update address |
| `delete_address()` | fmg, name | Delete address |
| `cidr_to_mask()` | cidr | Convert CIDR to IP/mask |

---

## Return Value Pattern

```python
result = create_address(fmg, "NET_TEST", "10.0.0.0/24")
if result["code"] == 0:
    print("Success!")
else:
    print(f"Error: {result['response']}")
```

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/02_addresses/)
- [Bash Equivalent](../../01-raw-http/bash/02-addresses/)
- [Previous: Authentication](../01_auth/)
- [Next: Services](../03_services/)
