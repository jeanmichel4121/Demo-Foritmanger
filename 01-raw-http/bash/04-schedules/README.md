# 📅 Schedule Management Scripts

> **CRUD operations for FortiManager schedule objects.**

[Home](../../../README.md) > [Level 1](../../README.md) > [Bash](../README.md) > Schedules

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

---

## 📜 Scripts

| Script | Description |
|--------|-------------|
| `crud-schedules.sh` | **Full CRUD** for one-time schedules |

---

## 🔧 Schedule Types

| Type | Use Case | Example |
|------|----------|---------|
| **One-time** | *Maintenance windows* | Dec 25, 00:00-06:00 |
| **Recurring** | *Business hours* | Mon-Fri, 09:00-18:00 |

---

## 💡 Examples

### Create Schedule

```bash
# One-time maintenance window
./crud-schedules.sh -a create -n MAINTENANCE_XMAS \
    --start "00:00 2024/12/25" \
    --end "06:00 2024/12/25" \
    -c "Christmas maintenance window"

# Short format
./crud-schedules.sh -a create -n MAINT_01 \
    --start "22:00 2024/01/15" \
    --end "04:00 2024/01/16"
```

### Read Schedules

```bash
# List all schedules
./crud-schedules.sh -a read

# Get specific schedule
./crud-schedules.sh -a read -n MAINTENANCE_XMAS

# JSON output
./crud-schedules.sh -a read -j
```

### Update Schedule

```bash
# Extend maintenance window
./crud-schedules.sh -a update -n MAINTENANCE_XMAS \
    --end "08:00 2024/12/25"

# Update comment
./crud-schedules.sh -a update -n MAINTENANCE_XMAS \
    -c "Extended maintenance window"
```

### Delete Schedule

```bash
./crud-schedules.sh -a delete -n MAINTENANCE_XMAS
```

---

## 📆 Date Format

| Format | Example |
|--------|---------|
| **DateTime** | `HH:MM YYYY/MM/DD` |
| **Example** | `00:00 2024/12/25` |

> **Note**: Use 24-hour format for times.

---

## ⚙️ Options Reference

| Option | Description | Required |
|--------|-------------|----------|
| `-a` | **Action**: `create`, `read`, `update`, `delete` | *Yes* |
| `-n` | Schedule **name** | *Yes* (except read all) |
| `--start` | **Start** datetime | *Yes* (create) |
| `--end` | **End** datetime | *Yes* (create) |
| `-c` | **Comment** | *No* |
| `-j` | JSON output | *No* |

---

## 🔗 See Also

- [PowerShell Equivalent](../../powershell/04-schedules/)
- [Previous: Services](../03-services/)
- [Next: NAT/VIP](../05-nat-vip/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
