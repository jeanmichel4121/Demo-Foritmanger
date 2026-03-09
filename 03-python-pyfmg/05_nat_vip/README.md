# NAT/VIP Management

> **CRUD operations for FortiManager VIP and IP Pool objects with pyFMG.**

[Home](../../README.md) > [Level 3](../README.md) > NAT/VIP

---

## Overview

This section provides Python scripts for managing FortiManager NAT objects using pyFMG:
- **VIP (Virtual IP)**: Destination NAT (DNAT)
- **IP Pool**: Source NAT (SNAT)

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
| `crud_vip.py` | VIP management functions |
| `crud_ippool.py` | IP Pool management functions |

---

## Usage

### VIP (DNAT)

```python
from pyFMG.fortimgr import FortiManager

with FortiManager(FMG_HOST, FMG_USER, FMG_PASS) as fmg:
    # Simple static NAT
    create_vip(fmg, "VIP_WEB", "203.0.113.10", "192.168.10.10")

    # Port forwarding
    create_vip(fmg, "VIP_SSH", "203.0.113.10", "192.168.10.20",
               extport="2222", mappedport="22")
```

### IP Pool (SNAT)

```python
with FortiManager(FMG_HOST, FMG_USER, FMG_PASS) as fmg:
    # Overload pool
    create_ippool(fmg, "POOL_OUT", "203.0.113.100", "203.0.113.110", "overload")

    # One-to-one pool
    create_ippool(fmg, "POOL_DMZ", "203.0.113.120", "203.0.113.125", "one-to-one")
```

---

## VIP Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `create_vip()` | fmg, name, extip, mappedip, ... | Create VIP |
| `read_vips()` | fmg, filter_name | List VIPs |
| `update_vip()` | fmg, name, **updates | Update VIP |
| `delete_vip()` | fmg, name | Delete VIP |

---

## IP Pool Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `create_ippool()` | fmg, name, startip, endip, pool_type, comment | Create pool |
| `read_ippools()` | fmg, filter_name | List pools |
| `update_ippool()` | fmg, name, **updates | Update pool |
| `delete_ippool()` | fmg, name | Delete pool |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/05_nat_vip/)
- [Bash Equivalent](../../01-raw-http/bash/05-nat-vip/)
- [Previous: Schedules](../04_schedules/)
- [Next: Security Profiles](../06_security_profiles/)
