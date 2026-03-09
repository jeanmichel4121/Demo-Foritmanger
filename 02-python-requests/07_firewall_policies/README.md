# Firewall Policy Management

> **CRUD operations for FortiManager firewall policies with Python requests.**

[Home](../../README.md) > [Level 2](../README.md) > Firewall Policies

---

## Overview

This section provides Python scripts for managing FortiManager firewall policies. Policies combine all previously defined objects (addresses, services, schedules, etc.) into access control rules.

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **Firewall Policy** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy` |
| **Policy Package** | `/pm/pkg/adom/{adom}` |
| **Install Task** | `/securityconsole/install/package` |

---

## Scripts

| Script | Description |
|--------|-------------|
| `crud_policies.py` | Policy CRUD and package installation |

---

## Usage

### Policy Management

```python
from utils.fmg_client import FortiManagerClient

with FortiManagerClient() as fmg:
    mgr = PolicyManager(fmg)

    # Create policy
    mgr.create(
        name="Allow_Web",
        srcintf=["port1"],
        dstintf=["port2"],
        srcaddr=["all"],
        dstaddr=["VIP_WEB"],
        service=["HTTP", "HTTPS"],
        action="accept"
    )

    # Read policies
    policies = mgr.read()

    # Move policy to top
    mgr.move("Allow_Web", "before", "first")

    # Delete policy
    mgr.delete("Allow_Web")
```

### Package Installation

```python
# Install package to device
mgr.install_package("default", ["FGT-01"])
```

---

## PolicyManager Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `create()` | name, srcintf, dstintf, srcaddr, dstaddr, service, action, ... | Create policy |
| `read()` | policyid, filter_pattern | List policies |
| `update()` | policyid, **updates | Update policy |
| `delete()` | policyid | Delete policy |
| `move()` | policyid, option, target | Move policy position |
| `install_package()` | pkg_name, devices | Install to devices |

---

## Policy Workflow

```
1. Create objects (addresses, services, etc.)
2. Create policy referencing objects
3. Move policy to desired position
4. Install package to FortiGate devices
```

---

## See Also

- [pyFMG Equivalent](../../03-python-pyfmg/07_firewall_policies/)
- [Bash Equivalent](../../01-raw-http/bash/07-firewall-policies/)
- [Previous: Security Profiles](../06_security_profiles/)
- [Policy Installation Workflow](../../docs/03-covered-operations.md)
