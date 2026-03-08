# Level 4: Ansible + FortiManager

> **Declarative Infrastructure as Code for enterprise-grade network automation.**

---

## Overview

This section uses the **fortinet.fortimanager** Ansible collection for declarative configuration management. You'll learn:

- **Declarative approach** - Define desired state, not procedural steps
- **Idempotent operations** - Safe to run repeatedly
- **Version control** - YAML configurations in Git
- **Team collaboration** - Shareable, reviewable playbooks
- **CI/CD integration** - Automate deployments

**Ansible transforms network automation from scripts to infrastructure as code.**

---

## Ansible Advantages

| Feature | Python Scripts | Ansible |
|---------|----------------|---------|
| Paradigm | Procedural | Declarative |
| State handling | Manual checks | Built-in idempotency |
| Configuration | Code | YAML files |
| Version control | Code changes | Config changes |
| Learning curve | Programming | YAML syntax |
| Team collaboration | Code review | Config review |

---

## Prerequisites

- **Ansible Core 2.15+**
- **Python 3.8+**
- **FortiManager 7.2.x - 7.6.x**
- **Network access** to FortiManager (HTTPS)

### Check Ansible Version

```bash
ansible --version
# ansible [core 2.15.x]
```

---

## Installation

```bash
cd 04-ansible

# Install the Fortinet collection
ansible-galaxy collection install -r requirements.yml

# Or install directly
ansible-galaxy collection install fortinet.fortimanager
```

### Verify Installation

```bash
ansible-galaxy collection list | grep fortinet
# fortinet.fortimanager 2.x.x
```

---

## Folder Structure

```
04-ansible/
├── README.md               # This file
├── ansible.cfg             # Ansible configuration
├── requirements.yml        # Collection dependencies
├── inventory/
│   ├── hosts.yml           # FortiManager hosts
│   └── group_vars/
│       └── fortimanager.yml # Connection settings
├── vars/
│   ├── addresses.yml       # Address definitions
│   ├── services.yml        # Service definitions
│   └── policies.yml        # Policy definitions
└── playbooks/
    ├── 01_addresses/
    │   └── manage_addresses.yml
    ├── 02_services/
    │   └── manage_services.yml
    ├── 06_policies/
    │   ├── manage_policies.yml
    │   └── install_package.yml
    └── full_deployment.yml
```

---

## Configuration

### 1. Inventory Setup (`inventory/hosts.yml`)

```yaml
all:
  children:
    fortimanager:
      hosts:
        fmg01:
          # Override per-host if needed
          # ansible_host: 192.168.1.100
      vars:
        # Connection settings
        ansible_network_os: fortinet.fortimanager.fortimanager
        ansible_connection: httpapi
        ansible_httpapi_use_ssl: true
        ansible_httpapi_validate_certs: false
        ansible_httpapi_port: 443
```

### 2. Credentials (`inventory/group_vars/fortimanager.yml`)

```yaml
# Load from environment variables
ansible_host: "{{ lookup('env', 'FMG_HOST') | default('192.168.1.100', true) }}"
ansible_user: "{{ lookup('env', 'FMG_USERNAME') | default('admin', true) }}"
ansible_password: "{{ lookup('env', 'FMG_PASSWORD') | default('', true) }}"

# OR use API Key (uncomment)
# ansible_httpapi_key: "{{ lookup('env', 'FMG_API_KEY') }}"

# FortiManager settings
fmg_adom: "{{ lookup('env', 'FMG_ADOM') | default('root', true) }}"
fmg_package: "default"
```

### 3. Using Ansible Vault (Recommended)

```bash
# Create encrypted vault
ansible-vault create inventory/group_vars/vault.yml

# Add secrets
vault_fmg_password: "your_secure_password"
vault_fmg_apikey: "your_api_key"

# Reference in fortimanager.yml
ansible_password: "{{ vault_fmg_password }}"
```

---

## Quick Start

### 1. Set Environment Variables

```bash
export FMG_HOST=192.168.1.100
export FMG_USERNAME=admin
export FMG_PASSWORD=your_password
export FMG_ADOM=root
```

### 2. Test Connection

```bash
ansible -i inventory/hosts.yml fortimanager -m ping
```

### 3. Run Your First Playbook

```bash
# Dry-run (check mode)
ansible-playbook playbooks/01_addresses/manage_addresses.yml --check

# Actual run
ansible-playbook playbooks/01_addresses/manage_addresses.yml
```

---

## Core Concepts

### Playbook Structure

```yaml
---
- name: Manage FortiManager Addresses
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars_files:
    - ../../vars/addresses.yml

  tasks:
    - name: Create IPv4 address
      fortinet.fortimanager.fmgr_firewall_address:
        state: present
        adom: "{{ fmg_adom }}"
        firewall_address:
          name: "SRV_WEB_01"
          type: "ipmask"
          subnet: "192.168.10.10/32"
          comment: "Web Server"
```

### Key Parameters

| Parameter | Description |
|-----------|-------------|
| `state` | `present` (create/update) or `absent` (delete) |
| `adom` | Target ADOM |
| `firewall_address` | Object parameters |

### Idempotency

Ansible checks if the desired state already exists:

```bash
# First run: Creates resources
TASK [Create address] changed: [fmg01]

# Second run: No changes needed
TASK [Create address] ok: [fmg01]
```

---

## Detailed Examples

### Managing Addresses

**Variable file (`vars/addresses.yml`):**
```yaml
addresses_ipv4:
  - name: "NET_WEB_SERVERS"
    subnet: "192.168.10.0/24"
    comment: "Web server network"

  - name: "NET_DB_SERVERS"
    subnet: "192.168.20.0/24"
    comment: "Database network"

  - name: "HOST_ADMIN_PC"
    subnet: "10.0.0.100/32"
    comment: "Admin workstation"

address_groups:
  - name: "GRP_SERVERS"
    members:
      - "NET_WEB_SERVERS"
      - "NET_DB_SERVERS"
```

**Playbook (`playbooks/01_addresses/manage_addresses.yml`):**
```yaml
- name: Manage Addresses
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars_files:
    - ../../vars/addresses.yml

  tasks:
    - name: Create IPv4 addresses
      fortinet.fortimanager.fmgr_firewall_address:
        state: present
        adom: "{{ fmg_adom }}"
        firewall_address:
          name: "{{ item.name }}"
          type: "ipmask"
          subnet: "{{ item.subnet }}"
          comment: "{{ item.comment | default(omit) }}"
      loop: "{{ addresses_ipv4 }}"

    - name: Create address groups
      fortinet.fortimanager.fmgr_firewall_addrgrp:
        state: present
        adom: "{{ fmg_adom }}"
        firewall_addrgrp:
          name: "{{ item.name }}"
          member: "{{ item.members }}"
      loop: "{{ address_groups }}"
```

### Managing Services

```yaml
- name: Create custom service
  fortinet.fortimanager.fmgr_firewall_service_custom:
    state: present
    adom: "{{ fmg_adom }}"
    firewall_service_custom:
      name: "HTTPS_8443"
      protocol: "TCP/UDP/SCTP"
      tcp-portrange: "8443"
      comment: "Custom HTTPS port"
```

### Managing Policies

```yaml
- name: Create firewall policy
  fortinet.fortimanager.fmgr_pkg_firewall_policy:
    state: present
    adom: "{{ fmg_adom }}"
    pkg: "{{ fmg_package }}"
    pkg_firewall_policy:
      name: "Allow-Web-Traffic"
      srcintf:
        - "port1"
      dstintf:
        - "port2"
      srcaddr:
        - "all"
      dstaddr:
        - "NET_WEB_SERVERS"
      service:
        - "HTTP"
        - "HTTPS"
      action: "accept"
      logtraffic: "all"
      nat: "enable"
```

### Installing Policies

```yaml
- name: Preview installation
  fortinet.fortimanager.fmgr_securityconsole_install_preview:
    securityconsole_install_preview:
      adom: "{{ fmg_adom }}"
      device: "{{ target_device | default(omit) }}"
      flags:
        - "none"
  register: preview_result

- name: Install policy package
  fortinet.fortimanager.fmgr_securityconsole_install_package:
    securityconsole_install_package:
      adom: "{{ fmg_adom }}"
      pkg: "{{ fmg_package }}"
      scope:
        - name: "FGT-01"
          vdom: "root"
  when: not preview_only
```

---

## Common Modules

| Module | Purpose |
|--------|---------|
| `fmgr_firewall_address` | IPv4 addresses |
| `fmgr_firewall_address6` | IPv6 addresses |
| `fmgr_firewall_addrgrp` | Address groups |
| `fmgr_firewall_service_custom` | Custom services |
| `fmgr_firewall_service_group` | Service groups |
| `fmgr_pkg_firewall_policy` | Firewall policies |
| `fmgr_securityconsole_install_package` | Policy installation |
| `fmgr_securityconsole_install_preview` | Installation preview |

---

## Running Playbooks

### Basic Execution

```bash
# Run playbook
ansible-playbook playbooks/01_addresses/manage_addresses.yml

# With custom ADOM
ansible-playbook playbooks/01_addresses/manage_addresses.yml -e "fmg_adom=customer"

# Check mode (dry-run)
ansible-playbook playbooks/01_addresses/manage_addresses.yml --check

# Verbose output
ansible-playbook playbooks/01_addresses/manage_addresses.yml -vvv

# With vault password
ansible-playbook playbooks/01_addresses/manage_addresses.yml --ask-vault-pass
```

### Using Tags

```yaml
# In playbook
tasks:
  - name: Create addresses
    tags: [addresses]

  - name: Create policies
    tags: [policies]
```

```bash
# Run only specific tags
ansible-playbook full_deployment.yml --tags addresses
ansible-playbook full_deployment.yml --skip-tags install
```

---

## Best Practices

### 1. Use Variables for Reusability

```yaml
# vars/common.yml
fmg_adom: "production"
fmg_package: "main-policy"
naming_prefix: "PROD_"

# In playbook
name: "{{ naming_prefix }}WEB_SERVER"
```

### 2. Use Check Mode First

```bash
# Always preview changes
ansible-playbook playbook.yml --check --diff
```

### 3. Use Ansible Vault for Secrets

```bash
# Never commit plain-text passwords
ansible-vault encrypt inventory/group_vars/vault.yml
```

### 4. Organize with Roles

```
roles/
└── fmg_address/
    ├── tasks/main.yml
    ├── defaults/main.yml
    └── vars/main.yml
```

### 5. Use Meaningful Names

```yaml
# Good
- name: Create web server address in production ADOM

# Bad
- name: Create address
```

---

## Troubleshooting

### Connection Issues

```bash
# Test connectivity
ansible -i inventory/hosts.yml fortimanager -m ping -vvv

# Check httpapi settings
ansible_network_os: fortinet.fortimanager.fortimanager
ansible_connection: httpapi
```

### Authentication Errors

```bash
# Verify credentials
echo $FMG_USERNAME
echo $FMG_PASSWORD

# Check API key
ansible_httpapi_key: "your_api_key"
```

### Debug Output

```yaml
- name: Show result
  ansible.builtin.debug:
    var: result
    verbosity: 1
```

### Common Error Messages

| Error | Solution |
|-------|----------|
| "Authentication failed" | Check credentials/API key |
| "Object does not exist" | Verify ADOM and object name |
| "Permission denied" | Check user permissions |
| "Object is used" | Remove references before delete |

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Deploy FortiManager Config

on:
  push:
    branches: [main]
    paths: ['04-ansible/**']

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Ansible
        run: pip install ansible

      - name: Install Collection
        run: ansible-galaxy collection install fortinet.fortimanager

      - name: Run Playbook
        env:
          FMG_HOST: ${{ secrets.FMG_HOST }}
          FMG_API_KEY: ${{ secrets.FMG_API_KEY }}
        run: |
          cd 04-ansible
          ansible-playbook playbooks/full_deployment.yml
```

---

## Full Deployment Example

The `playbooks/full_deployment.yml` combines all operations:

```yaml
---
- name: Full FortiManager Deployment
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars_files:
    - ../vars/addresses.yml
    - ../vars/services.yml
    - ../vars/policies.yml

  tasks:
    - name: Deploy addresses
      ansible.builtin.include_tasks: 01_addresses/manage_addresses.yml

    - name: Deploy services
      ansible.builtin.include_tasks: 02_services/manage_services.yml

    - name: Deploy policies
      ansible.builtin.include_tasks: 06_policies/manage_policies.yml

    - name: Install to devices
      ansible.builtin.include_tasks: 06_policies/install_package.yml
      when: install_enabled | default(false)
```

---

## Reference

- [Main README](../README.md)
- [Ansible Collection Documentation](https://docs.ansible.com/ansible/latest/collections/fortinet/fortimanager/index.html)
- [Fortinet FortiManager Ansible Collection (ReadTheDocs)](https://ansible-galaxy-fortimanager-docs.readthedocs.io/)
- [FortiManager Administration Guide](https://docs.fortinet.com/document/fortimanager/7.6.0/administration-guide)
