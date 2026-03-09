# Security Profiles Management

> **Declarative security profile management with Ansible playbooks.**

[Home](../../../README.md) > [Level 4](../../README.md) > Security Profiles

---

## Overview

This section provides Ansible playbooks for managing FortiManager security profile objects. Application groups allow grouping applications for firewall policies.

---

## Ansible Modules

| Module | Description |
|--------|-------------|
| `fmgr_application_group` | Application group management |

---

## Playbooks

| Playbook | Description |
|----------|-------------|
| `manage_app_groups.yml` | Application group management |

---

## Usage

### Run Application Group Tasks

```bash
ansible-playbook playbooks/06_security_profiles/manage_app_groups.yml
```

### Run with Tags

```bash
ansible-playbook playbooks/06_security_profiles/manage_app_groups.yml --tags app_groups
```

### Dry Run (Check Mode)

```bash
ansible-playbook playbooks/06_security_profiles/manage_app_groups.yml --check
```

---

## Vars File Structure

`vars/security_profiles.yml`:

```yaml
app_groups:
  - name: "APP_GRP_SOCIAL"
    applications:
      - "Facebook"
      - "Twitter"
      - "Instagram"
      - "LinkedIn"
    comment: "Social media applications"
    state: present

  - name: "APP_GRP_STREAMING"
    applications:
      - "Netflix"
      - "YouTube"
      - "Spotify"
    comment: "Streaming applications"
    state: present
```

---

## Tags

| Tag | Description |
|-----|-------------|
| `security` | All security profile tasks |
| `app_groups` | Application groups only |

---

## Common Application Categories

| Category | Examples |
|----------|----------|
| Social Media | Facebook, Twitter, Instagram |
| Streaming | Netflix, YouTube, Spotify |
| Productivity | Microsoft.Office.365, Google.Workspace |
| Gaming | Steam, PlayStation.Network |

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/06_security_profiles/)
- [pyFMG Equivalent](../../03-python-pyfmg/06_security_profiles/)
- [Previous: NAT/VIP](../05_nat_vip/)
- [Next: Policies](../07_policies/)
