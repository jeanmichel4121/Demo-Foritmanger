# Address Management

> **Declarative address management with Ansible playbooks.**

[Home](../../../README.md) > [Level 4](../../README.md) > Addresses

---

## Overview

This section provides Ansible playbooks for managing FortiManager firewall address objects. Addresses are defined in YAML vars files and applied declaratively.

---

## Ansible Modules

| Module | Description |
|--------|-------------|
| `fmgr_firewall_address` | IPv4 address management |
| `fmgr_firewall_address6` | IPv6 address management |
| `fmgr_firewall_addrgrp` | Address group management |

---

## Playbooks

| Playbook | Description |
|----------|-------------|
| `manage_addresses.yml` | IPv4, IPv6, and group management |

---

## Usage

### Run All Address Tasks

```bash
ansible-playbook playbooks/02_addresses/manage_addresses.yml
```

### Run Specific Tags

```bash
# Only IPv4 addresses
ansible-playbook playbooks/02_addresses/manage_addresses.yml --tags ipv4

# Only groups
ansible-playbook playbooks/02_addresses/manage_addresses.yml --tags groups
```

### Dry Run (Check Mode)

```bash
ansible-playbook playbooks/02_addresses/manage_addresses.yml --check
```

---

## Vars File Structure

`vars/addresses.yml`:

```yaml
addresses_ipv4:
  - name: "NET_SERVERS"
    subnet: "10.10.10.0 255.255.255.0"
    comment: "Server network"
    state: present

  - name: "HOST_WEB"
    subnet: "192.168.1.10 255.255.255.255"
    comment: "Web server"
    state: present

address_groups:
  - name: "GRP_ALL_SERVERS"
    members:
      - "NET_SERVERS"
      - "HOST_WEB"
    state: present
```

---

## Tags

| Tag | Description |
|-----|-------------|
| `addresses` | All address tasks |
| `ipv4` | IPv4 addresses only |
| `ipv6` | IPv6 addresses only |
| `groups` | Address groups only |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/02_addresses/)
- [pyFMG Equivalent](../../03-python-pyfmg/02_addresses/)
- [Next: Services](../03_services/)
