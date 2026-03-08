# Schedule Management

CRUD scripts for FortiManager schedule objects.

## Endpoints

| Type | Endpoint |
|------|----------|
| One-time | `/pm/config/adom/{adom}/obj/firewall/schedule/onetime` |
| Recurring | `/pm/config/adom/{adom}/obj/firewall/schedule/recurring` |
| Group | `/pm/config/adom/{adom}/obj/firewall/schedule/group` |

## Scripts

| Script | Description |
|--------|-------------|
| `crud-schedules.ps1` | CRUD operations on schedules |

## Examples

```powershell
# One-time schedule (maintenance window)
.\crud-schedules.ps1 -Action create -Type onetime -Name "MAINT_2024" `
    -Start "2024-06-01 22:00" -End "2024-06-02 06:00"

# Recurring schedule (business hours)
.\crud-schedules.ps1 -Action create -Type recurring -Name "BUSINESS_HOURS" `
    -Days @("monday","tuesday","wednesday","thursday","friday") `
    -StartTime "08:00" -EndTime "18:00"

# List schedules
.\crud-schedules.ps1 -Action read
```
