# 🔌 Service Management Scripts

> **CRUD operations for FortiManager custom service objects.**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > Services

---

## 📋 Overview

Services define TCP/UDP ports, protocols, and port ranges used in firewall policies. This section provides scripts for managing custom services and service groups.

For complete API reference, see the [Covered Operations Guide](../../../docs/03-covered-operations.md).

---

## 🔗 API Endpoints

| Type | Endpoint |
|------|----------|
| **Custom Service** | `/pm/config/adom/{adom}/obj/firewall/service/custom` |
| **Service Group** | `/pm/config/adom/{adom}/obj/firewall/service/group` |
| **Service Category** | `/pm/config/adom/{adom}/obj/firewall/service/category` |

---

## 📜 Scripts

| Script | Operation | Description |
|--------|-----------|-------------|
| `crud-services.ps1` | **Full CRUD** | Create, read, update, delete services |

---

## 🔧 Protocol Support

| Protocol | Parameter | Example |
|----------|-----------|---------|
| **TCP** | `-Protocol TCP -Port` | `-Protocol TCP -Port "443"` |
| **UDP** | `-Protocol UDP -Port` | `-Protocol UDP -Port "53"` |
| **TCP+UDP** | `-Protocol TCPUDP -Port` | `-Protocol TCPUDP -Port "53"` |
| **ICMP** | `-Protocol ICMP` | ICMP type/code |
| **IP** | `-Protocol IP -ProtocolNumber` | IP protocol number |

---

## 💡 Examples

### Create Services

```powershell
# TCP service (single port)
.\crud-services.ps1 -Action create -Name "SVC_HTTPS_8443" `
    -Protocol TCP -Port "8443" -Comment "Custom HTTPS"

# TCP service (port range)
.\crud-services.ps1 -Action create -Name "SVC_HIGH_PORTS" `
    -Protocol TCP -Port "8000-9000" -Comment "High ports"

# UDP service
.\crud-services.ps1 -Action create -Name "SVC_SYSLOG" `
    -Protocol UDP -Port "514" -Comment "Syslog"

# TCP + UDP (same port)
.\crud-services.ps1 -Action create -Name "SVC_DNS" `
    -Protocol TCPUDP -Port "53" -Comment "DNS"
```

### Read Services

```powershell
# List all custom services
.\crud-services.ps1 -Action read

# Get specific service
.\crud-services.ps1 -Action read -Name "SVC_HTTPS_8443"

# Filter services
.\crud-services.ps1 -Action read -Filter "SVC_*"

# JSON output
.\crud-services.ps1 -Action read -AsJson | ConvertFrom-Json
```

### Update Services

```powershell
# Change port
.\crud-services.ps1 -Action update -Name "SVC_HTTPS_8443" -Port "8080"

# Update comment
.\crud-services.ps1 -Action update -Name "SVC_HTTPS_8443" -Comment "Updated HTTPS port"
```

### Delete Services

```powershell
.\crud-services.ps1 -Action delete -Name "SVC_HTTPS_8443"
```

---

## ⚙️ Options Reference

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Action` | `create`, `read`, `update`, `delete` | **Yes** |
| `-Name` | Service **name** | **Yes** (except read all) |
| `-Protocol` | `TCP`, `UDP`, `TCPUDP`, `ICMP`, `IP` | **Yes** (create) |
| `-Port` | **Port** or range (e.g., "443", "8000-9000") | **Yes** (create TCP/UDP) |
| `-ProtocolNumber` | IP protocol **number** | **Yes** (create IP) |
| `-Comment` | Description | No |
| `-Filter` | Filter **pattern** | No |
| `-AsJson` | Output as **JSON** | No |

---

## 🔗 See Also

- [Bash Equivalent](../../bash/03-services/)
- [Previous: Addresses](../02-addresses/)
- [Next: Schedules](../04-schedules/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
