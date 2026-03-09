# NAT/VIP Management

> **CRUD operations for FortiManager VIP and IP Pool objects with Python requests.**

[Home](../../README.md) > [Level 2](../README.md) > NAT/VIP

---

## Overview

This section provides Python scripts for managing FortiManager NAT objects:
- **VIP (Virtual IP)**: Destination NAT (DNAT) - expose internal servers
- **IP Pool**: Source NAT (SNAT) - outbound address translation

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **VIP** | `/pm/config/adom/{adom}/obj/firewall/vip` |
| **IP Pool** | `/pm/config/adom/{adom}/obj/firewall/ippool` |

---

## Scripts

| Script | Description |
|--------|-------------|
| `crud_vip.py` | VIP management with VIPManager class |
| `crud_ippool.py` | IP Pool management with IPPoolManager class |

---

## Usage

### VIP (DNAT)

```python
from utils.fmg_client import FortiManagerClient

with FortiManagerClient() as fmg:
    mgr = VIPManager(fmg)

    # Simple static NAT
    mgr.create("VIP_WEB", "203.0.113.10", "192.168.10.10", comment="Web server")

    # Port forwarding
    mgr.create(
        "VIP_SSH",
        "203.0.113.10", "192.168.10.20",
        extport="2222", mappedport="22",
        comment="SSH jump host"
    )
```

### IP Pool (SNAT)

```python
with FortiManagerClient() as fmg:
    mgr = IPPoolManager(fmg)

    # Overload pool (PAT)
    mgr.create("POOL_OUT", "203.0.113.100", "203.0.113.110", "overload")

    # One-to-one pool
    mgr.create("POOL_DMZ", "203.0.113.120", "203.0.113.125", "one-to-one")
```

---

## VIPManager Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `create()` | name, extip, mappedip, extintf, extport, mappedport, comment | Create VIP |
| `read()` | name, filter_pattern | List VIPs |
| `update()` | name, **updates | Update VIP |
| `delete()` | name | Delete VIP |

---

## IPPoolManager Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `create()` | name, startip, endip, pool_type, comment | Create IP Pool |
| `read()` | name, filter_pattern | List pools |
| `update()` | name, **updates | Update pool |
| `delete()` | name | Delete pool |

---

## Pool Types

| Type | Description |
|------|-------------|
| `overload` | Many-to-one (PAT) |
| `one-to-one` | 1:1 mapping |

---

## See Also

- [pyFMG Equivalent](../../03-python-pyfmg/05_nat_vip/)
- [Bash Equivalent](../../01-raw-http/bash/05-nat-vip/)
- [Previous: Schedules](../04_schedules/)
- [Next: Security Profiles](../06_security_profiles/)
