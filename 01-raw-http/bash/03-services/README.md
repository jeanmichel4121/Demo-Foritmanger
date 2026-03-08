# 🔌 Service Management Scripts

> **CRUD operations for FortiManager custom service objects.**

[Home](../../../README.md) > [Level 1](../../README.md) > [Bash](../README.md) > Services

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

---

## 📜 Scripts

| Script | Description |
|--------|-------------|
| `crud-services.sh` | **Full CRUD** for custom services |

---

## 🔧 Protocol Support

| Protocol | Option | Example |
|----------|--------|---------|
| **TCP** | `-t` | `-t 443` or `-t 80-443` |
| **UDP** | `-u` | `-u 53` or `-u 500-600` |
| **TCP+UDP** | Both | `-t 53 -u 53` |

---

## 💡 Examples

### Create Services

```bash
# TCP service (single port)
./crud-services.sh -a create -n SVC_HTTPS_8443 -t 8443 -c "Custom HTTPS"

# TCP service (port range)
./crud-services.sh -a create -n SVC_HIGH_PORTS -t 8000-9000 -c "High ports"

# UDP service
./crud-services.sh -a create -n SVC_SYSLOG -u 514 -c "Syslog"

# TCP + UDP (same port)
./crud-services.sh -a create -n SVC_DNS -t 53 -u 53 -c "DNS"
```

### Read Services

```bash
# List all custom services
./crud-services.sh -a read

# Get specific service
./crud-services.sh -a read -n SVC_HTTPS_8443

# JSON output
./crud-services.sh -a read -j
```

### Update Services

```bash
# Change port
./crud-services.sh -a update -n SVC_HTTPS_8443 -t 8080

# Update comment
./crud-services.sh -a update -n SVC_HTTPS_8443 -c "Updated HTTPS port"
```

### Delete Services

```bash
./crud-services.sh -a delete -n SVC_HTTPS_8443
```

---

## ⚙️ Options Reference

| Option | Description | Required |
|--------|-------------|----------|
| `-a` | **Action**: `create`, `read`, `update`, `delete` | *Yes* |
| `-n` | Service **name** | *Yes* (except read all) |
| `-t` | **TCP** port or range | *No* |
| `-u` | **UDP** port or range | *No* |
| `-c` | **Comment** | *No* |
| `-j` | JSON output | *No* |

---

## 🔗 See Also

- [PowerShell Equivalent](../../powershell/03-services/)
- [Previous: Addresses](../02-addresses/)
- [Next: Schedules](../04-schedules/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
