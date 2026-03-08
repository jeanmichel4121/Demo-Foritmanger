# 🏠 Address Management Scripts

> **CRUD operations for FortiManager firewall address objects.**

[Home](../../../README.md) > [Level 1](../../README.md) > [Bash](../README.md) > Addresses

---

## 📋 Overview

This section provides Bash scripts for managing FortiManager firewall address objects. Addresses are the building blocks for firewall policies - they define source and destination endpoints.

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
| `create-address.sh` | **CREATE** | Create IPv4 address object |
| `read-addresses.sh` | **READ** | List and filter addresses |
| `update-address.sh` | **UPDATE** | Modify existing address |
| `delete-address.sh` | **DELETE** | Remove address object |
| `manage-groups.sh` | **CRUD** | Address group management |

---

## 🔧 Address Types

| Type | Description | Example |
|------|-------------|---------|
| `ipmask` | *IP/Subnet mask* | `10.0.0.0 255.255.255.0` |
| `iprange` | *IP range* | `startip: 10.0.0.1, endip: 10.0.0.100` |
| `fqdn` | *DNS hostname* | `www.example.com` |
| `geography` | *Country code* | `country: US` |
| `wildcard` | *Wildcard mask* | `10.0.*.0 255.255.0.255` |

---

## 💡 Examples

### Create Address

```bash
# Network (CIDR notation - auto-converted)
./create-address.sh -n NET_SERVERS -s 10.10.10.0/24 -c "Server network"

# Single host
./create-address.sh -n HOST_WEB -s 192.168.1.10/32 -c "Web server"

# FQDN
./create-address.sh -n FQDN_GOOGLE -s google.com --fqdn -c "Google DNS"
```

### Read Addresses

```bash
# List all addresses
./read-addresses.sh

# Filter by pattern
./read-addresses.sh -f "NET_*"

# Get specific address
./read-addresses.sh -n HOST_WEB

# JSON output (for scripting)
./read-addresses.sh -j | jq '.[] | .name'
```

### Update Address

```bash
# Update comment
./update-address.sh -n NET_SERVERS -c "Production servers"

# Update subnet
./update-address.sh -n NET_SERVERS -s 10.10.20.0/24
```

### Delete Address

```bash
# Delete with confirmation
./delete-address.sh -n NET_SERVERS

# Force delete (no confirmation)
./delete-address.sh -n NET_SERVERS -f
```

### Address Groups

```bash
# Create group
./manage-groups.sh -a create -n GRP_ALL_SERVERS -m "HOST_WEB,HOST_DB,HOST_APP"

# List groups
./manage-groups.sh -a read

# Add member to group
./manage-groups.sh -a update -n GRP_ALL_SERVERS -m "HOST_WEB,HOST_DB,HOST_APP,HOST_NEW"

# Delete group
./manage-groups.sh -a delete -n GRP_ALL_SERVERS
```

---

## ⚙️ Options Reference

### create-address.sh

| Option | Description | Required |
|--------|-------------|----------|
| `-n` | Address **name** | *Yes* |
| `-s` | **Subnet** (CIDR or mask) | *Yes* |
| `-c` | **Comment** | *No* |
| `--fqdn` | Create as *FQDN* type | *No* |
| `-j` | JSON output | *No* |

### read-addresses.sh

| Option | Description | Required |
|--------|-------------|----------|
| `-n` | Specific address **name** | *No* |
| `-f` | **Filter** pattern | *No* |
| `-j` | JSON output | *No* |
| `-S` | Session token | *No* |

---

## 🔗 See Also

- [PowerShell Equivalent](../../powershell/02-addresses/)
- [Previous: Authentication](../01-auth/)
- [Next: Services](../03-services/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
- [Covered Operations](../../../docs/03-covered-operations.md)
