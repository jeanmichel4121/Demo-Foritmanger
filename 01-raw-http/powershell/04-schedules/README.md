# 📅 Schedule Management Scripts

> **CRUD operations for FortiManager schedule objects.**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > Schedules

---

## 📋 Overview

Schedules define time windows for firewall policies - enabling time-based access control for maintenance windows, business hours, or special events.

For complete API reference, see the [Covered Operations Guide](../../../docs/03-covered-operations.md).

---

## 🔗 API Endpoints

| Type | Endpoint |
|------|----------|
| **One-time Schedule** | `/pm/config/adom/{adom}/obj/firewall/schedule/onetime` |
| **Recurring Schedule** | `/pm/config/adom/{adom}/obj/firewall/schedule/recurring` |
| **Schedule Group** | `/pm/config/adom/{adom}/obj/firewall/schedule/group` |

---

## 📜 Scripts

| Script | Operation | Description |
|--------|-----------|-------------|
| `crud-schedules.ps1` | **Full CRUD** | Create, read, update, delete schedules |

---

## 🔧 Schedule Types

| Type | Use Case | Example |
|------|----------|---------|
| **One-time** | *Maintenance windows* | Dec 25, 00:00-06:00 |
| **Recurring** | *Business hours* | Mon-Fri, 09:00-18:00 |

---

## 💡 Examples

### Create Schedules

```powershell
# One-time maintenance window
.\crud-schedules.ps1 -Action create -Type onetime -Name "MAINTENANCE_XMAS" `
    -Start "2024-12-25 00:00" -End "2024-12-25 06:00" `
    -Comment "Christmas maintenance window"

# One-time with date span
.\crud-schedules.ps1 -Action create -Type onetime -Name "MAINT_WEEKEND" `
    -Start "2024-06-15 22:00" -End "2024-06-16 08:00"

# Recurring business hours
.\crud-schedules.ps1 -Action create -Type recurring -Name "BUSINESS_HOURS" `
    -Days @("monday", "tuesday", "wednesday", "thursday", "friday") `
    -StartTime "08:00" -EndTime "18:00" `
    -Comment "Standard business hours"

# Recurring weekend
.\crud-schedules.ps1 -Action create -Type recurring -Name "WEEKENDS" `
    -Days @("saturday", "sunday") `
    -StartTime "00:00" -EndTime "23:59"
```

### Read Schedules

```powershell
# List all schedules
.\crud-schedules.ps1 -Action read

# Get specific schedule
.\crud-schedules.ps1 -Action read -Name "MAINTENANCE_XMAS"

# Filter by type
.\crud-schedules.ps1 -Action read -Type onetime

# JSON output
.\crud-schedules.ps1 -Action read -AsJson | ConvertFrom-Json
```

### Update Schedule

```powershell
# Extend maintenance window
.\crud-schedules.ps1 -Action update -Name "MAINTENANCE_XMAS" `
    -End "2024-12-25 08:00"

# Update comment
.\crud-schedules.ps1 -Action update -Name "MAINTENANCE_XMAS" `
    -Comment "Extended maintenance window"
```

### Delete Schedule

```powershell
.\crud-schedules.ps1 -Action delete -Name "MAINTENANCE_XMAS"
```

---

## ⚙️ Options Reference

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Action` | `create`, `read`, `update`, `delete` | **Yes** |
| `-Type` | `onetime`, `recurring` | **Yes** (create) |
| `-Name` | Schedule **name** | **Yes** (except read all) |
| `-Start` | **Start** datetime (one-time) | **Yes** (create onetime) |
| `-End` | **End** datetime (one-time) | **Yes** (create onetime) |
| `-Days` | Array of **days** (recurring) | **Yes** (create recurring) |
| `-StartTime` | **Start time** HH:MM (recurring) | **Yes** (create recurring) |
| `-EndTime` | **End time** HH:MM (recurring) | **Yes** (create recurring) |
| `-Comment` | Description | No |
| `-AsJson` | Output as **JSON** | No |

### Date/Time Formats

| Type | Format | Example |
|------|--------|---------|
| **One-time datetime** | `YYYY-MM-DD HH:MM` | `2024-12-25 06:00` |
| **Recurring time** | `HH:MM` | `08:00` |
| **Days** | Array of day names | `@("monday", "friday")` |

---

## 🔗 See Also

- [Bash Equivalent](../../bash/04-schedules/)
- [Previous: Services](../03-services/)
- [Next: NAT/VIP](../05-nat-vip/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
