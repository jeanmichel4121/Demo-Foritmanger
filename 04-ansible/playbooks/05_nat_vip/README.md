# NAT/VIP Management

> **Declarative NAT/VIP management with Ansible playbooks.**

[Home](../../../README.md) > [Level 4](../../README.md) > NAT/VIP

---

## Overview

This section provides Ansible playbooks for managing FortiManager NAT objects:
- **VIP (Virtual IP)**: Destination NAT (DNAT)
- **IP Pool**: Source NAT (SNAT)

---

## Ansible Modules

| Module | Description |
|--------|-------------|
| `fmgr_firewall_vip` | VIP management |
| `fmgr_firewall_ippool` | IP Pool management |

---

## Playbooks

| Playbook | Description |
|----------|-------------|
| `manage_vip.yml` | Virtual IP (DNAT) management |
| `manage_ippool.yml` | IP Pool (SNAT) management |

---

## Usage

### Run VIP Tasks

```bash
ansible-playbook playbooks/05_nat_vip/manage_vip.yml
```

### Run IP Pool Tasks

```bash
ansible-playbook playbooks/05_nat_vip/manage_ippool.yml
```

### Run with Tags

```bash
# VIPs only
ansible-playbook playbooks/05_nat_vip/manage_vip.yml --tags vip

# IP Pools only
ansible-playbook playbooks/05_nat_vip/manage_ippool.yml --tags ippool
```

---

## Vars File Structure

`vars/nat_vip.yml`:

```yaml
vips:
  - name: "VIP_WEB_SERVER"
    extip: "203.0.113.10"
    mappedip: "192.168.10.10"
    comment: "Public web server"
    state: present

  - name: "VIP_SSH_JUMP"
    extip: "203.0.113.10"
    mappedip: "192.168.10.20"
    portforward: "enable"
    protocol: "tcp"
    extport: "2222"
    mappedport: "22"
    comment: "SSH jump host"
    state: present

ippools:
  - name: "POOL_OUTBOUND"
    startip: "203.0.113.100"
    endip: "203.0.113.110"
    type: "overload"
    comment: "Outbound NAT pool"
    state: present
```

---

## Tags

| Tag | Description |
|-----|-------------|
| `nat` | All NAT tasks |
| `vip` | VIP tasks only |
| `ippool` | IP Pool tasks only |

---

## Pool Types

| Type | Description |
|------|-------------|
| `overload` | Many-to-one (PAT) |
| `one-to-one` | 1:1 mapping |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/05_nat_vip/)
- [pyFMG Equivalent](../../03-python-pyfmg/05_nat_vip/)
- [Previous: Schedules](../04_schedules/)
- [Next: Security Profiles](../06_security_profiles/)
