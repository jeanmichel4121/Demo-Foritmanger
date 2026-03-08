# 🔀 NAT/VIP Management Scripts

> **CRUD operations for VIPs (DNAT) and IP Pools (SNAT).**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > NAT/VIP

---

## 📋 Overview

NAT configuration enables network address translation for inbound (DNAT/VIP) and outbound (SNAT/IP Pool) traffic flows. This section provides scripts for managing both VIPs and IP Pools.

For complete API reference, see the [Covered Operations Guide](../../../docs/03-covered-operations.md).

---

## 🔗 API Endpoints

| Type | Endpoint |
|------|----------|
| **Virtual IP (IPv4)** | `/pm/config/adom/{adom}/obj/firewall/vip` |
| **Virtual IP (IPv6)** | `/pm/config/adom/{adom}/obj/firewall/vip6` |
| **VIP Group** | `/pm/config/adom/{adom}/obj/firewall/vipgrp` |
| **IP Pool (IPv4)** | `/pm/config/adom/{adom}/obj/firewall/ippool` |
| **IP Pool (IPv6)** | `/pm/config/adom/{adom}/obj/firewall/ippool6` |

---

## 📜 Scripts

| Script | NAT Type | Description |
|--------|----------|-------------|
| `crud-vip.ps1` | **DNAT** | Virtual IPs / Port forwarding |
| `crud-ippool.ps1` | **SNAT** | Outbound NAT pools |

---

## 🔧 NAT Types Explained

| Type | Direction | Use Case |
|------|-----------|----------|
| **VIP (DNAT)** | *Inbound* | Publish internal servers to external |
| **IP Pool (SNAT)** | *Outbound* | Source NAT for client traffic |

---

## 💡 VIP Examples (DNAT)

### Static NAT (1:1)

```powershell
# Map public IP to internal server
.\crud-vip.ps1 -Action create -Name "VIP_WEB_SERVER" `
    -ExtIP "203.0.113.10" `
    -MappedIP "192.168.10.10" `
    -Comment "Web server"
```

### Port Forwarding

```powershell
# Forward external port 2222 to internal SSH
.\crud-vip.ps1 -Action create -Name "VIP_SSH_JUMP" `
    -ExtIP "203.0.113.10" `
    -MappedIP "192.168.10.20" `
    -ExtPort "2222" `
    -MappedPort "22" `
    -Comment "SSH jump host"

# HTTPS on alternate port
.\crud-vip.ps1 -Action create -Name "VIP_HTTPS_ALT" `
    -ExtIP "203.0.113.10" `
    -MappedIP "192.168.10.30" `
    -ExtPort "8443" `
    -MappedPort "443"
```

### Read VIPs

```powershell
# List all VIPs
.\crud-vip.ps1 -Action read

# Get specific VIP
.\crud-vip.ps1 -Action read -Name "VIP_WEB_SERVER"

# JSON output
.\crud-vip.ps1 -Action read -AsJson | ConvertFrom-Json
```

### Delete VIP

```powershell
.\crud-vip.ps1 -Action delete -Name "VIP_WEB_SERVER"
```

---

## 💡 IP Pool Examples (SNAT)

### Create Pool

```powershell
# Single IP pool (overload/PAT)
.\crud-ippool.ps1 -Action create -Name "POOL_SINGLE" `
    -StartIP "203.0.113.100" `
    -EndIP "203.0.113.100" `
    -Type overload `
    -Comment "Single IP outbound"

# IP range pool
.\crud-ippool.ps1 -Action create -Name "POOL_OUTBOUND" `
    -StartIP "203.0.113.100" `
    -EndIP "203.0.113.110" `
    -Type overload `
    -Comment "Outbound NAT pool"

# One-to-one pool
.\crud-ippool.ps1 -Action create -Name "POOL_ONETO_ONE" `
    -StartIP "203.0.113.50" `
    -EndIP "203.0.113.60" `
    -Type "one-to-one" `
    -Comment "1:1 NAT pool"
```

### Read Pools

```powershell
# List all pools
.\crud-ippool.ps1 -Action read

# Get specific pool
.\crud-ippool.ps1 -Action read -Name "POOL_OUTBOUND"
```

### Delete Pool

```powershell
.\crud-ippool.ps1 -Action delete -Name "POOL_OUTBOUND"
```

---

## ⚙️ Options Reference

### crud-vip.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Action` | `create`, `read`, `update`, `delete` | **Yes** |
| `-Name` | VIP **name** | **Yes** (except read all) |
| `-ExtIP` | **External** IP address | **Yes** (create) |
| `-MappedIP` | **Internal** IP address | **Yes** (create) |
| `-ExtPort` | External **port** (port forward) | No |
| `-MappedPort` | Internal **port** (port forward) | No |
| `-Comment` | Description | No |
| `-AsJson` | Output as **JSON** | No |

### crud-ippool.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Action` | `create`, `read`, `update`, `delete` | **Yes** |
| `-Name` | Pool **name** | **Yes** (except read all) |
| `-StartIP` | **Start** IP of range | **Yes** (create) |
| `-EndIP` | **End** IP of range | **Yes** (create) |
| `-Type` | `overload`, `one-to-one` | No (default: overload) |
| `-Comment` | Description | No |
| `-AsJson` | Output as **JSON** | No |

---

## 🔗 See Also

- [Bash Equivalent](../../bash/05-nat-vip/)
- [Previous: Schedules](../04-schedules/)
- [Next: Security Profiles](../06-security-profiles/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
