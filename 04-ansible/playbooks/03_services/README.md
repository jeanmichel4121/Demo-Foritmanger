# Service Management

> **Declarative service management with Ansible playbooks.**

[Home](../../../README.md) > [Level 4](../../README.md) > Services

---

## Overview

This section provides Ansible playbooks for managing FortiManager custom services. Services are defined in YAML vars files and applied declaratively.

---

## Ansible Modules

| Module | Description |
|--------|-------------|
| `fmgr_firewall_service_custom` | Custom service management |
| `fmgr_firewall_service_group` | Service group management |

---

## Playbooks

| Playbook | Description |
|----------|-------------|
| `manage_services.yml` | Custom services and groups |

---

## Usage

### Run All Service Tasks

```bash
ansible-playbook playbooks/03_services/manage_services.yml
```

### Run Specific Tags

```bash
# Only custom services
ansible-playbook playbooks/03_services/manage_services.yml --tags custom

# Only groups
ansible-playbook playbooks/03_services/manage_services.yml --tags groups
```

### Dry Run (Check Mode)

```bash
ansible-playbook playbooks/03_services/manage_services.yml --check
```

---

## Vars File Structure

`vars/services.yml`:

```yaml
services_custom:
  - name: "SVC_HTTPS_ALT"
    tcp_portrange: "8443"
    comment: "HTTPS alternative"
    state: present

  - name: "SVC_DNS_ALT"
    udp_portrange: "5353"
    comment: "DNS alternative"
    state: present

service_groups:
  - name: "GRP_WEB_SERVICES"
    members:
      - "HTTP"
      - "HTTPS"
      - "SVC_HTTPS_ALT"
    state: present
```

---

## Tags

| Tag | Description |
|-----|-------------|
| `services` | All service tasks |
| `custom` | Custom services only |
| `groups` | Service groups only |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/03_services/)
- [pyFMG Equivalent](../../03-python-pyfmg/03_services/)
- [Previous: Addresses](../02_addresses/)
- [Next: Schedules](../04_schedules/)
