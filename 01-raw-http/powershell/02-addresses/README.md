# 🏠 Address Management Scripts

> **CRUD operations for FortiManager firewall address objects.**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > Addresses

---

## 📋 Overview

This section provides PowerShell scripts for managing FortiManager firewall address objects. Addresses are the building blocks for firewall policies - they define source and destination endpoints.

For complete API reference, see the [Covered Operations Guide](../../../docs/03-covered-operations.md).

---

## 🔗 API Endpoints

| Type | Endpoint |
|------|----------|
| **IPv4 Address** | `/pm/config/adom/{adom}/obj/firewall/address` |
| **IPv6 Address** | `/pm/config/adom/{adom}/obj/firewall/address6` |
| **IPv4 Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp` |
| **IPv6 Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp6` |

---

## 📜 Scripts

| Script | Operation | Description |
|--------|-----------|-------------|
| `create-address.ps1` | **CREATE** | Create IPv4 address object |
| `read-addresses.ps1` | **READ** | List and filter addresses |
| `update-address.ps1` | **UPDATE** | Modify existing address |
| `delete-address.ps1` | **DELETE** | Remove address object |
| `manage-groups.ps1` | **CRUD** | Address group management |

---

## 💡 Examples

### Create Address

```powershell
# Network (CIDR notation)
.\create-address.ps1 -Name "NET_SERVERS" -Subnet "10.10.10.0/24" -Comment "Server network"

# Single host
.\create-address.ps1 -Name "HOST_WEB" -Subnet "192.168.1.10/32" -Comment "Web server"

# FQDN address
.\create-address.ps1 -Name "FQDN_GOOGLE" -FQDN "google.com" -Comment "Google DNS"

# IP Range
.\create-address.ps1 -Name "RANGE_DHCP" -StartIP "192.168.1.100" -EndIP "192.168.1.200" -Comment "DHCP range"
```

### Read Addresses

```powershell
# List all addresses
.\read-addresses.ps1

# Filter by pattern
.\read-addresses.ps1 -Filter "NET_*"

# Get specific address
.\read-addresses.ps1 -Name "HOST_WEB"

# JSON output (for scripting)
$addresses = .\read-addresses.ps1 -AsJson | ConvertFrom-Json
$addresses | Select-Object name, subnet
```

### Update Address

```powershell
# Update comment
.\update-address.ps1 -Name "NET_SERVERS" -Comment "Production servers"

# Update subnet
.\update-address.ps1 -Name "NET_SERVERS" -Subnet "10.10.20.0/24"
```

### Delete Address

```powershell
# Delete with confirmation
.\delete-address.ps1 -Name "NET_SERVERS"

# Force delete (no confirmation)
.\delete-address.ps1 -Name "NET_SERVERS" -Force
```

### Address Groups

```powershell
# Create group
.\manage-groups.ps1 -Action create -Name "GRP_ALL_SERVERS" `
    -Members @("HOST_WEB", "HOST_DB", "HOST_APP")

# List groups
.\manage-groups.ps1 -Action read

# Add member to group
.\manage-groups.ps1 -Action update -Name "GRP_ALL_SERVERS" `
    -Members @("HOST_WEB", "HOST_DB", "HOST_APP", "HOST_NEW")

# Delete group
.\manage-groups.ps1 -Action delete -Name "GRP_ALL_SERVERS"
```

---

## ⚙️ Options Reference

### create-address.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Name` | Address **name** | **Yes** |
| `-Subnet` | **Subnet** (CIDR or mask) | **Yes** (ipmask) |
| `-FQDN` | **FQDN** hostname | **Yes** (fqdn type) |
| `-StartIP` | **Start IP** for range | **Yes** (iprange) |
| `-EndIP` | **End IP** for range | **Yes** (iprange) |
| `-Comment` | Description | No |

### read-addresses.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Name` | Specific address **name** | No |
| `-Filter` | **Filter** pattern (wildcards) | No |
| `-AsJson` | Output as **JSON** | No |
| `-Session` | Session token | No |

### update-address.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Name` | Address **name** to update | **Yes** |
| `-Subnet` | New **subnet** | No |
| `-Comment` | New **comment** | No |

### delete-address.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Name` | Address **name** to delete | **Yes** |
| `-Force` | Skip confirmation | No |

### manage-groups.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Action` | `create`, `read`, `update`, `delete` | **Yes** |
| `-Name` | Group **name** | **Yes** (except read all) |
| `-Members` | Array of **member** addresses | **Yes** (create/update) |
| `-Comment` | Description | No |

---

## 🔗 See Also

- [Bash Equivalent](../../bash/02-addresses/)
- [Previous: Authentication](../01-auth/)
- [Next: Services](../03-services/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
- [Covered Operations](../../../docs/03-covered-operations.md)
