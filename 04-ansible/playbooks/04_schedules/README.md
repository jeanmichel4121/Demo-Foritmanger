# Schedule Management

> **Declarative schedule management with Ansible playbooks.**

[Home](../../../README.md) > [Level 4](../../README.md) > Schedules

---

## Overview

This section provides Ansible playbooks for managing FortiManager one-time schedules. Schedules are defined in YAML vars files and applied declaratively.

---

## Ansible Modules

| Module | Description |
|--------|-------------|
| `fmgr_firewall_schedule_onetime` | One-time schedule management |
| `fmgr_firewall_schedule_recurring` | Recurring schedule management |

---

## Playbooks

| Playbook | Description |
|----------|-------------|
| `manage_schedules.yml` | One-time schedules |

---

## Usage

### Run All Schedule Tasks

```bash
ansible-playbook playbooks/04_schedules/manage_schedules.yml
```

### Run Specific Tags

```bash
# Only one-time schedules
ansible-playbook playbooks/04_schedules/manage_schedules.yml --tags onetime
```

### Dry Run (Check Mode)

```bash
ansible-playbook playbooks/04_schedules/manage_schedules.yml --check
```

---

## Vars File Structure

`vars/schedules.yml`:

```yaml
schedules_onetime:
  - name: "MAINT_MONTHLY"
    start: "00:00 2024/12/15"
    end: "06:00 2024/12/15"
    comment: "Monthly maintenance window"
    state: present

  - name: "MAINT_EMERGENCY"
    start: "22:00 2024/12/20"
    end: "02:00 2024/12/21"
    comment: "Emergency maintenance"
    state: present
```

---

## Datetime Format

```
"HH:MM YYYY/MM/DD"
```

Examples:
- `"00:00 2024/12/15"` - Midnight on December 15, 2024
- `"14:30 2025/01/01"` - 2:30 PM on January 1, 2025

---

## Tags

| Tag | Description |
|-----|-------------|
| `schedules` | All schedule tasks |
| `onetime` | One-time schedules only |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/04_schedules/)
- [pyFMG Equivalent](../../03-python-pyfmg/04_schedules/)
- [Previous: Services](../03_services/)
- [Next: NAT/VIP](../05_nat_vip/)
