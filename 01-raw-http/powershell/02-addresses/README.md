# Address Management

> **CRUD scripts for FortiManager address objects.**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > Addresses

---

## Overview

This section provides PowerShell scripts for managing FortiManager firewall address objects. Addresses are the building blocks for firewall policies - they define source and destination endpoints.

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **IPv4 Address** | `/pm/config/adom/{adom}/obj/firewall/address` |
| **IPv6 Address** | `/pm/config/adom/{adom}/obj/firewall/address6` |
| **IPv4 Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp` |
| **IPv6 Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp6` |

---

## Scripts

| Script | Operation | Description |
|--------|-----------|-------------|
| `create-address.ps1` | **CREATE** | Create IPv4 address |
| `read-addresses.ps1` | **READ** | List addresses |
| `update-address.ps1` | **UPDATE** | Modify address |
| `delete-address.ps1` | **DELETE** | Delete address |
| `manage-groups.ps1` | **CRUD** | Group management |

---

## Examples

### Create an Address

```powershell
.\create-address.ps1 -Name "NET_SERVERS" -Subnet "10.10.10.0/24" -Comment "Servers"
```

### List Addresses

```powershell
# All addresses
.\read-addresses.ps1

# With filter
.\read-addresses.ps1 -Filter "NET_*"
```

### Modify an Address

```powershell
.\update-address.ps1 -Name "NET_SERVERS" -Comment "New comment"
```

### Delete an Address

```powershell
.\delete-address.ps1 -Name "NET_SERVERS"
```

---

## Address Types

| Type | Description | Example |
|------|-------------|---------|
| `ipmask` | *IP/Subnet mask* | `10.0.0.0 255.255.255.0` |
| `iprange` | *IP range* | `startip: 10.0.0.1, endip: 10.0.0.100` |
| `fqdn` | *DNS hostname* | `www.example.com` |
| `geography` | *Country code* | `country: US` |
| `wildcard` | *Wildcard mask* | `10.0.*.0 255.255.0.255` |

---

## See Also

- [Bash Equivalent](../../bash/02-addresses/)
- [Previous: Authentication](../01-auth/)
- [Next: Services](../03-services/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
- [Covered Operations](../../../docs/03-covered-operations.md)
