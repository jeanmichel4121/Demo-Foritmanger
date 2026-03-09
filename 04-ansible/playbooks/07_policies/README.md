# Firewall Policy Management

> **Declarative firewall policy management with Ansible playbooks.**

[Home](../../../README.md) > [Level 4](../../README.md) > Policies

---

## Overview

This section provides Ansible playbooks for managing FortiManager firewall policies and policy package installation.

---

## Ansible Modules

| Module | Description |
|--------|-------------|
| `fmgr_pkg_firewall_policy` | Firewall policy management |
| `fmgr_securityconsole_install_package` | Package installation |

---

## Playbooks

| Playbook | Description |
|----------|-------------|
| `manage_policies.yml` | Firewall policy CRUD |
| `install_package.yml` | Deploy policies to devices |

---

## Usage

### Manage Policies

```bash
ansible-playbook playbooks/07_policies/manage_policies.yml
```

### Install Package

```bash
ansible-playbook playbooks/07_policies/install_package.yml
```

### Run with Tags

```bash
# Only policies
ansible-playbook playbooks/07_policies/manage_policies.yml --tags policies

# Only installation
ansible-playbook playbooks/07_policies/install_package.yml --tags install
```

---

## Vars File Structure

`vars/policies.yml`:

```yaml
policies:
  - name: "Allow_Web_Inbound"
    srcintf: ["port1"]
    dstintf: ["port2"]
    srcaddr: ["all"]
    dstaddr: ["VIP_WEB"]
    service: ["HTTP", "HTTPS"]
    action: "accept"
    state: present

  - name: "Deny_Default"
    srcintf: ["any"]
    dstintf: ["any"]
    srcaddr: ["all"]
    dstaddr: ["all"]
    service: ["ALL"]
    action: "deny"
    state: present
```

---

## Tags

| Tag | Description |
|-----|-------------|
| `policies` | Policy management tasks |
| `install` | Package installation tasks |

---

## Policy Workflow

```
1. Define objects in vars files
2. Run address/service/etc playbooks
3. Run manage_policies.yml
4. Run install_package.yml to deploy
```

---

## Common Policy Fields

| Field | Description |
|-------|-------------|
| `name` | Policy name |
| `srcintf` | Source interfaces |
| `dstintf` | Destination interfaces |
| `srcaddr` | Source addresses |
| `dstaddr` | Destination addresses |
| `service` | Services |
| `action` | accept/deny |
| `schedule` | Time schedule |
| `nat` | Enable NAT |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/07_firewall_policies/)
- [pyFMG Equivalent](../../03-python-pyfmg/07_firewall_policies/)
- [Previous: Security Profiles](../06_security_profiles/)
- [Full Deployment Playbook](../full_deployment.yml)
