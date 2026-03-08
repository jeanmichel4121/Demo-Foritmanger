# Address Management

CRUD scripts for FortiManager address objects.

## Endpoints

| Type | Endpoint |
|------|----------|
| IPv4 | `/pm/config/adom/{adom}/obj/firewall/address` |
| IPv6 | `/pm/config/adom/{adom}/obj/firewall/address6` |
| IPv4 Group | `/pm/config/adom/{adom}/obj/firewall/addrgrp` |
| IPv6 Group | `/pm/config/adom/{adom}/obj/firewall/addrgrp6` |

## Scripts

| Script | Operation | Description |
|--------|-----------|-------------|
| `create-address.ps1` | CREATE | Create IPv4 address |
| `read-addresses.ps1` | READ | List addresses |
| `update-address.ps1` | UPDATE | Modify address |
| `delete-address.ps1` | DELETE | Delete address |
| `manage-groups.ps1` | CRUD | Group management |

## Examples

### Create an address

```powershell
.\create-address.ps1 -Name "NET_SERVERS" -Subnet "10.10.10.0/24" -Comment "Servers"
```

### List addresses

```powershell
# All addresses
.\read-addresses.ps1

# With filter
.\read-addresses.ps1 -Filter "NET_*"
```

### Modify an address

```powershell
.\update-address.ps1 -Name "NET_SERVERS" -Comment "New comment"
```

### Delete an address

```powershell
.\delete-address.ps1 -Name "NET_SERVERS"
```

## Address Types

| Type | Description | Example |
|------|-------------|---------|
| `ipmask` | IP/Mask | `10.0.0.0 255.255.255.0` |
| `iprange` | IP Range | `startip: 10.0.0.1, endip: 10.0.0.100` |
| `fqdn` | DNS Name | `www.example.com` |
| `geography` | Country | `country: US` |
| `wildcard` | Wildcard | `10.0.*.0 255.255.0.255` |
