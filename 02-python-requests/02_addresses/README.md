# Address Management

> **CRUD operations for FortiManager address objects with Python requests.**

[Home](../../README.md) > [Level 2](../README.md) > Addresses

---

## Overview

This section provides Python scripts for managing FortiManager firewall address objects using the requests library. The AddressManager class encapsulates all CRUD operations with proper error handling.

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
| `crud_addresses.py` | Full CRUD demo with AddressManager class |

---

## Usage

### Class-Based Pattern

```python
from utils.fmg_client import FortiManagerClient

with FortiManagerClient() as fmg:
    mgr = AddressManager(fmg)

    # Create
    mgr.create("NET_SERVERS", "10.10.10.0/24", "Server network")

    # Read
    addresses = mgr.read(filter_pattern="NET_*")

    # Update
    mgr.update("NET_SERVERS", comment="Production servers")

    # Delete
    mgr.delete("NET_SERVERS")
```

---

## AddressManager Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `create()` | name, subnet, comment | Create IPv4 address |
| `read()` | name, filter_pattern | List addresses |
| `update()` | name, **updates | Update address |
| `delete()` | name | Delete address |

---

## See Also

- [pyFMG Equivalent](../../03-python-pyfmg/02_addresses/)
- [Bash Equivalent](../../01-raw-http/bash/02-addresses/)
- [Previous: Authentication](../01_auth/)
- [Next: Services](../03_services/)
