# Service Management

> **CRUD scripts for FortiManager service objects.**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > Services

---

## Overview

Services define TCP/UDP ports, protocols, and port ranges used in firewall policies. This section provides scripts for managing custom services and service groups.

---

## Endpoints

| Type | Endpoint |
|------|----------|
| Custom | `/pm/config/adom/{adom}/obj/firewall/service/custom` |
| Group | `/pm/config/adom/{adom}/obj/firewall/service/group` |
| Category | `/pm/config/adom/{adom}/obj/firewall/service/category` |

## Scripts

| Script | Description |
|--------|-------------|
| `crud-services.ps1` | CRUD operations on custom services |

## Examples

```powershell
# Create a TCP service
.\crud-services.ps1 -Action create -Name "SVC_HTTPS_8443" -Protocol TCP -Port "8443"

# Create a UDP service
.\crud-services.ps1 -Action create -Name "SVC_DNS_ALT" -Protocol UDP -Port "5353"

# List services
.\crud-services.ps1 -Action read

# Delete
.\crud-services.ps1 -Action delete -Name "SVC_HTTPS_8443"
```

## Protocol Types

- `TCP/UDP/SCTP`: Specific ports
- `ICMP`: ICMP type/code
- `IP`: IP protocol number
