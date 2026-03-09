# 🎭 FortiManager Ansible Examples

<div align="center">

**Ready-to-use Ansible Playbooks**

*Infrastructure as Code with fortinet.fortimanager*

[📋 Cheatsheets](README.md) • [🔗 Endpoints](api-endpoints.md) • [🐍 Python](python-examples.md) • [🔧 cURL](curl-examples.md) • [⚠️ Errors](common-errors.md)

---

</div>

## ⚡ Quick Start (3 minutes)

> 🎯 **Goal:** Run your first playbook!

### 1️⃣ Install the collection

```bash
ansible-galaxy collection install fortinet.fortimanager
```

### 2️⃣ Configure the inventory

```yaml
# inventory/hosts.yml
all:
  children:
    fortimanager:
      hosts:
        fmg01:
      vars:
        ansible_network_os: fortinet.fortimanager.fortimanager
        ansible_connection: httpapi
        ansible_httpapi_use_ssl: true
        ansible_httpapi_validate_certs: false
```

### 3️⃣ Set environment variables

```bash
export ANSIBLE_HOST_KEY_CHECKING=False
export FMG_HOST="192.168.1.100"
export FMG_USER="admin"
export FMG_PASS="password"
# or with API Key
export FMG_API_KEY="your_api_key"
```

### 4️⃣ Test the connection

```bash
ansible -i inventory/hosts.yml fortimanager -m fortinet.fortimanager.fmgr_fact \
  -a "facts='adom'" -e "ansible_host=$FMG_HOST ansible_user=$FMG_USER ansible_password=$FMG_PASS"
```

> ✅ **See the ADOMs?** Congratulations, your connection works!

---

## 📖 Table of Contents

| Section | Description | Difficulty |
|:--------|:------------|:-----------|
| [🛠️ Configuration](#️-configuration) | Collection and inventory | ⭐ Easy |
| [🔐 Authentication](#-authentication) | Credentials and vault | ⭐ Easy |
| [📍 Firewall Addresses](#-firewall-addresses) | CRUD addresses | ⭐⭐ Medium |
| [🔌 Services](#-services) | Ports and protocols | ⭐⭐ Medium |
| [📜 Policies](#-firewall-policies) | Security rules | ⭐⭐ Medium |
| [🔀 VIP / NAT](#-vip--nat) | Address translation | ⭐⭐ Medium |
| [🚀 Installation](#-installation) | Config deployment | ⭐⭐⭐ Advanced |
| [💻 Devices](#-devices) | Device management | ⭐⭐ Medium |
| [📦 Variables and Loops](#-variables-and-loops) | Automation | ⭐⭐ Medium |
| [🗂️ Role Structure](#️-role-structure) | Organization | ⭐⭐⭐ Advanced |
| [🔄 CI/CD](#-cicd) | GitHub Actions | ⭐⭐⭐ Advanced |
| [⚡ Utility Playbooks](#-utility-playbooks) | Quick commands | ⭐⭐ Medium |
| [💡 Best Practices](#-best-practices) | Recommended patterns | ⭐⭐ Medium |

---

## 🛠️ Configuration

### 📦 Collection Installation

```bash
# From Ansible Galaxy
ansible-galaxy collection install fortinet.fortimanager

# Or via requirements.yml
cat > requirements.yml << 'EOF'
collections:
  - name: fortinet.fortimanager
    version: ">=2.5.0"
EOF

ansible-galaxy collection install -r requirements.yml
```

### 📁 Recommended Project Structure

```
project/
├── ansible.cfg
├── inventory/
│   ├── hosts.yml
│   └── group_vars/
│       └── fortimanager.yml
├── vars/
│   ├── addresses.yml
│   ├── services.yml
│   └── policies.yml
├── playbooks/
│   ├── manage_addresses.yml
│   ├── manage_services.yml
│   └── install_package.yml
└── roles/
    └── fmg_addresses/
```

### ⚙️ ansible.cfg

```ini
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
deprecation_warnings = False

[persistent_connection]
connect_timeout = 60
command_timeout = 60
```

### 📋 Complete Inventory

```yaml
# inventory/hosts.yml
all:
  children:
    fortimanager:
      hosts:
        fmg01:
          # Optional: override per host
          # ansible_host: 192.168.1.100

      vars:
        # Connection settings
        ansible_network_os: fortinet.fortimanager.fortimanager
        ansible_connection: httpapi
        ansible_httpapi_use_ssl: true
        ansible_httpapi_validate_certs: false
        ansible_httpapi_port: 443

        # FortiManager settings
        fmg_adom: "root"
        fmg_package: "default"
```

---

## 🔐 Authentication

### 🔑 Environment Variables

```yaml
# inventory/group_vars/fortimanager.yml
ansible_host: "{{ lookup('env', 'FMG_HOST') }}"
ansible_user: "{{ lookup('env', 'FMG_USER') }}"
ansible_password: "{{ lookup('env', 'FMG_PASS') }}"

# Or with API Key
ansible_httpapi_token: "{{ lookup('env', 'FMG_API_KEY') }}"
```

### 🔒 Ansible Vault

```bash
# Create a vault file
ansible-vault create inventory/group_vars/vault.yml
```

```yaml
# inventory/group_vars/vault.yml (encrypted)
vault_fmg_user: "admin"
vault_fmg_pass: "SecretPassword123!"
vault_fmg_api_key: "your_secret_api_key"
```

```yaml
# inventory/group_vars/fortimanager.yml
ansible_user: "{{ vault_fmg_user }}"
ansible_password: "{{ vault_fmg_pass }}"
# or
ansible_httpapi_token: "{{ vault_fmg_api_key }}"
```

```bash
# Run with vault
ansible-playbook playbooks/manage_addresses.yml --ask-vault-pass
# or
ansible-playbook playbooks/manage_addresses.yml --vault-password-file ~/.vault_pass
```

---

## 📍 Firewall Addresses

### 📝 Variables File

```yaml
# vars/addresses.yml
addresses_ipv4:
  - name: "NET_SERVERS_WEB"
    subnet: "10.10.10.0/24"
    comment: "Frontend web servers"
    state: present

  - name: "NET_SERVERS_APP"
    subnet: "10.10.20.0/24"
    comment: "Application servers"
    state: present

  - name: "HOST_DNS_PRIMARY"
    subnet: "10.0.0.10/32"
    comment: "Primary DNS server"
    state: present

addresses_ipv6:
  - name: "NET6_SERVERS"
    ip6: "2001:db8:10::/48"
    comment: "IPv6 server network"
    state: present

addresses_fqdn:
  - name: "FQDN_GITHUB"
    fqdn: "github.com"
    comment: "GitHub for developers"
    state: present

  - name: "FQDN_MICROSOFT"
    fqdn: "*.microsoft.com"
    comment: "Microsoft services"
    state: present

addresses_iprange:
  - name: "RANGE_DHCP"
    start_ip: "192.168.1.100"
    end_ip: "192.168.1.200"
    comment: "DHCP pool"
    state: present

  - name: "RANGE_GUESTS"
    start_ip: "10.10.100.1"
    end_ip: "10.10.100.50"
    comment: "Guest network"
    state: present

address_groups:
  - name: "GRP_SERVERS_ALL"
    members:
      - "NET_SERVERS_WEB"
      - "NET_SERVERS_APP"
    comment: "All servers"
    state: present
```

### ➕ Create Addresses (Playbook)

```yaml
# playbooks/manage_addresses.yml
---
- name: FortiManager Address Management
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars_files:
    - ../vars/addresses.yml

  tasks:
    # ─────────────────────────────────────────────────────
    # IPv4 Addresses
    # ─────────────────────────────────────────────────────
    - name: Manage IPv4 addresses
      fortinet.fortimanager.fmgr_firewall_address:
        state: "{{ item.state | default('present') }}"
        adom: "{{ fmg_adom }}"
        firewall_address:
          name: "{{ item.name }}"
          type: "ipmask"
          subnet: "{{ item.subnet }}"
          comment: "{{ item.comment | default(omit) }}"
      loop: "{{ addresses_ipv4 | default([]) }}"
      tags:
        - addresses
        - ipv4

    # ─────────────────────────────────────────────────────
    # FQDN Addresses
    # ─────────────────────────────────────────────────────
    - name: Manage FQDN addresses
      fortinet.fortimanager.fmgr_firewall_address:
        state: "{{ item.state | default('present') }}"
        adom: "{{ fmg_adom }}"
        firewall_address:
          name: "{{ item.name }}"
          type: "fqdn"
          fqdn: "{{ item.fqdn }}"
          comment: "{{ item.comment | default(omit) }}"
      loop: "{{ addresses_fqdn | default([]) }}"
      tags:
        - addresses
        - fqdn

    # ─────────────────────────────────────────────────────
    # IP Range Addresses
    # ─────────────────────────────────────────────────────
    - name: Manage IP range addresses
      fortinet.fortimanager.fmgr_firewall_address:
        state: "{{ item.state | default('present') }}"
        adom: "{{ fmg_adom }}"
        firewall_address:
          name: "{{ item.name }}"
          type: "iprange"
          start-ip: "{{ item.start_ip }}"
          end-ip: "{{ item.end_ip }}"
          comment: "{{ item.comment | default(omit) }}"
      loop: "{{ addresses_iprange | default([]) }}"
      tags:
        - addresses
        - iprange

    # ─────────────────────────────────────────────────────
    # Address Groups
    # ─────────────────────────────────────────────────────
    - name: Manage address groups
      fortinet.fortimanager.fmgr_firewall_addrgrp:
        state: "{{ item.state | default('present') }}"
        adom: "{{ fmg_adom }}"
        firewall_addrgrp:
          name: "{{ item.name }}"
          member: "{{ item.members }}"
          comment: "{{ item.comment | default(omit) }}"
      loop: "{{ address_groups | default([]) }}"
      tags:
        - addresses
        - groups
```

### ▶️ Execution

```bash
# Dry-run (check mode)
ansible-playbook playbooks/manage_addresses.yml --check

# Run only IPv4 addresses
ansible-playbook playbooks/manage_addresses.yml --tags ipv4

# Run with custom variables
ansible-playbook playbooks/manage_addresses.yml -e "fmg_adom=customer"

# Verbose mode
ansible-playbook playbooks/manage_addresses.yml -vvv
```

---

## 🔌 Services

### 📝 Variables File

```yaml
# vars/services.yml
services_custom:
  - name: "HTTPS_8443"
    protocol: "TCP/UDP/SCTP"
    tcp_portrange: "8443"
    comment: "Alternate HTTPS"
    state: present

  - name: "APP_PORTS"
    protocol: "TCP/UDP/SCTP"
    tcp_portrange: "8000-8100"
    comment: "Application ports"
    state: present

service_groups:
  - name: "GRP_WEB_SERVICES"
    members:
      - "HTTP"
      - "HTTPS"
      - "HTTPS_8443"
    comment: "Web Services"
    state: present
```

### ➕ Create Services (Playbook)

```yaml
# playbooks/manage_services.yml
---
- name: FortiManager Service Management
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars_files:
    - ../vars/services.yml

  tasks:
    - name: Manage custom services
      fortinet.fortimanager.fmgr_firewall_service_custom:
        state: "{{ item.state | default('present') }}"
        adom: "{{ fmg_adom }}"
        firewall_service_custom:
          name: "{{ item.name }}"
          protocol: "{{ item.protocol }}"
          tcp-portrange: "{{ item.tcp_portrange | default(omit) }}"
          udp-portrange: "{{ item.udp_portrange | default(omit) }}"
          comment: "{{ item.comment | default(omit) }}"
      loop: "{{ services_custom | default([]) }}"
      tags:
        - services

    - name: Manage service groups
      fortinet.fortimanager.fmgr_firewall_service_group:
        state: "{{ item.state | default('present') }}"
        adom: "{{ fmg_adom }}"
        firewall_service_group:
          name: "{{ item.name }}"
          member: "{{ item.members }}"
          comment: "{{ item.comment | default(omit) }}"
      loop: "{{ service_groups | default([]) }}"
      tags:
        - services
        - groups
```

---

## 📜 Firewall Policies

### 📝 Variables File

```yaml
# vars/policies.yml
firewall_policies:
  - name: "Allow-Web-to-Internet"
    srcintf: ["port1"]
    dstintf: ["port2"]
    srcaddr: ["NET_SERVERS_WEB"]
    dstaddr: ["all"]
    service: ["HTTP", "HTTPS"]
    action: "accept"
    logtraffic: "all"
    comments: "Web servers Internet access"
    state: present

  - name: "Deny-All"
    srcintf: ["any"]
    dstintf: ["any"]
    srcaddr: ["all"]
    dstaddr: ["all"]
    service: ["ALL"]
    action: "deny"
    logtraffic: "all"
    comments: "Cleanup rule"
    state: present
```

### ➕ Create Policies (Playbook)

```yaml
# playbooks/manage_policies.yml
---
- name: FortiManager Policy Management
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars_files:
    - ../vars/policies.yml

  tasks:
    - name: Manage firewall policies
      fortinet.fortimanager.fmgr_pkg_firewall_policy:
        state: "{{ item.state | default('present') }}"
        adom: "{{ fmg_adom }}"
        pkg: "{{ fmg_package }}"
        pkg_firewall_policy:
          name: "{{ item.name }}"
          srcintf: "{{ item.srcintf }}"
          dstintf: "{{ item.dstintf }}"
          srcaddr: "{{ item.srcaddr }}"
          dstaddr: "{{ item.dstaddr }}"
          service: "{{ item.service }}"
          action: "{{ item.action }}"
          logtraffic: "{{ item.logtraffic | default('disable') }}"
          comments: "{{ item.comments | default(omit) }}"
      loop: "{{ firewall_policies | default([]) }}"
      tags:
        - policies
```

---

## 🔀 VIP / NAT

### 📝 Variables File

```yaml
# vars/vips.yml
firewall_vips:
  # VIP Static NAT (1:1)
  - name: "VIP_WEB_SERVER"
    type: "static-nat"
    extip: "203.0.113.10"
    mappedip: "192.168.10.10"
    extintf: "any"
    comment: "NAT to web server"
    state: present

  # Port Forwarding
  - name: "VIP_WEB_8080"
    type: "static-nat"
    extip: "203.0.113.10"
    extport: "8080"
    mappedip: "192.168.10.10"
    mappedport: "80"
    portforward: "enable"
    protocol: "tcp"
    extintf: "any"
    comment: "External port 8080 to internal port 80"
    state: present

  # VIP for HTTPS
  - name: "VIP_HTTPS_SERVER"
    type: "static-nat"
    extip: "203.0.113.11"
    extport: "443"
    mappedip: "192.168.10.20"
    mappedport: "443"
    portforward: "enable"
    protocol: "tcp"
    extintf: "any"
    comment: "HTTPS web server"
    state: present
```

### ➕ Create VIPs (Playbook)

```yaml
# playbooks/manage_vips.yml
---
- name: FortiManager VIP Management
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars_files:
    - ../vars/vips.yml

  tasks:
    # ─────────────────────────────────────────────────────
    # Static NAT VIPs
    # ─────────────────────────────────────────────────────
    - name: Manage VIP entries
      fortinet.fortimanager.fmgr_firewall_vip:
        state: "{{ item.state | default('present') }}"
        adom: "{{ fmg_adom }}"
        firewall_vip:
          name: "{{ item.name }}"
          type: "{{ item.type | default('static-nat') }}"
          extip: "{{ item.extip }}"
          mappedip: "{{ item.mappedip }}"
          extintf: "{{ item.extintf | default('any') }}"
          extport: "{{ item.extport | default(omit) }}"
          mappedport: "{{ item.mappedport | default(omit) }}"
          portforward: "{{ item.portforward | default(omit) }}"
          protocol: "{{ item.protocol | default(omit) }}"
          comment: "{{ item.comment | default(omit) }}"
      loop: "{{ firewall_vips | default([]) }}"
      tags:
        - vips
        - nat
```

### 📊 VIP Diagram

```
┌─────────────────────────────────────────────────────┐
│              STATIC NAT (1:1)                       │
│                                                     │
│  Internet              FortiGate           Internal │
│  ─────────►  203.0.113.10  ────►  192.168.10.10    │
│              (Public IP)          (Private IP)      │
│                                                     │
├─────────────────────────────────────────────────────┤
│              PORT FORWARDING                        │
│                                                     │
│  Internet              FortiGate           Internal │
│  ───► :8080  ──►  203.0.113.10:8080 ──► :80        │
│     (external)                       (internal)     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 Installation

### 📦 Install a Package

```yaml
# playbooks/install_package.yml
---
- name: Install FortiManager Package
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars:
    target_devices:
      - name: "FGT-DC1"
        vdom: "root"

  tasks:
    - name: Install package to devices
      fortinet.fortimanager.fmgr_securityconsole_install_package:
        securityconsole_install_package:
          adom: "{{ fmg_adom }}"
          pkg: "{{ fmg_package }}"
          scope:
            - name: "{{ item.name }}"
              vdom: "{{ item.vdom }}"
      loop: "{{ target_devices }}"
      register: install_result
      tags:
        - install

    - name: Display install result
      ansible.builtin.debug:
        msg: "Task ID: {{ install_result.results[0].meta.response_data.task }}"
      when: install_result is defined
      tags:
        - install
```

### ⏳ Wait for Installation Completion

```yaml
# playbooks/install_and_wait.yml
---
- name: Install Package and Wait
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars:
    target_device: "FGT-DC1"
    target_vdom: "root"

  tasks:
    - name: Install package
      fortinet.fortimanager.fmgr_securityconsole_install_package:
        securityconsole_install_package:
          adom: "{{ fmg_adom }}"
          pkg: "{{ fmg_package }}"
          scope:
            - name: "{{ target_device }}"
              vdom: "{{ target_vdom }}"
      register: install_result

    - name: Wait for task completion
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "task_task"
          params:
            task: "{{ install_result.meta.response_data.task }}"
      register: task_status
      until: task_status.meta.response_data[0].percent == 100
      retries: 60
      delay: 5

    - name: Check final status
      ansible.builtin.debug:
        msg: "Installation {{ 'succeeded' if task_status.meta.response_data[0].state == 'done' else 'failed' }}"
```

---

## 💻 Devices

### 📋 List Devices

```yaml
# playbooks/list_devices.yml
---
- name: List FortiManager Devices
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  tasks:
    - name: Get all devices in ADOM
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "dvmdb_device"
          params:
            adom: "{{ fmg_adom }}"
      register: devices_result

    - name: Display device list
      ansible.builtin.debug:
        msg: |
          Device: {{ item.name }}
          Hostname: {{ item.hostname | default('N/A') }}
          IP: {{ item.ip | default('N/A') }}
          Status: {{ 'Connected' if item.conn_status == 1 else 'Disconnected' }}
          Version: {{ item.os_ver | default('N/A') }}
      loop: "{{ devices_result.meta.response_data }}"
      loop_control:
        label: "{{ item.name }}"
```

### 🔍 Device Details

```yaml
# playbooks/device_details.yml
---
- name: Get Device Details
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars:
    target_device: "FGT-01"

  tasks:
    - name: Get device details
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "dvmdb_device"
          params:
            adom: "{{ fmg_adom }}"
            device: "{{ target_device }}"
      register: device_result

    - name: Display device details
      ansible.builtin.debug:
        var: device_result.meta.response_data
```

### 📊 Devices Summary

```yaml
# playbooks/devices_summary.yml
---
- name: Devices Summary Report
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  tasks:
    - name: Get all devices
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "dvmdb_device"
          params:
            adom: "{{ fmg_adom }}"
      register: devices

    - name: Calculate statistics
      ansible.builtin.set_fact:
        total_devices: "{{ devices.meta.response_data | length }}"
        connected_devices: "{{ devices.meta.response_data | selectattr('conn_status', 'equalto', 1) | list | length }}"
        disconnected_devices: "{{ devices.meta.response_data | selectattr('conn_status', 'equalto', 0) | list | length }}"

    - name: Display summary
      ansible.builtin.debug:
        msg: |
          📊 Devices Summary:
          Total: {{ total_devices }}
          🟢 Connected: {{ connected_devices }}
          🔴 Disconnected: {{ disconnected_devices }}
```

---

## 📦 Variables and Loops

### 🔄 Loops with loop

```yaml
- name: Create multiple addresses
  fortinet.fortimanager.fmgr_firewall_address:
    state: present
    adom: "{{ fmg_adom }}"
    firewall_address:
      name: "{{ item.name }}"
      subnet: "{{ item.subnet }}"
  loop:
    - { name: "NET_A", subnet: "10.0.0.0/24" }
    - { name: "NET_B", subnet: "172.16.0.0/24" }
    - { name: "NET_C", subnet: "192.168.0.0/24" }
```

### 📊 Loops with loop_control

```yaml
- name: Create addresses with progress
  fortinet.fortimanager.fmgr_firewall_address:
    state: present
    adom: "{{ fmg_adom }}"
    firewall_address:
      name: "{{ item.name }}"
      subnet: "{{ item.subnet }}"
  loop: "{{ addresses_ipv4 }}"
  loop_control:
    label: "{{ item.name }}"  # Display only the name
    index_var: idx
  register: results

- name: Show summary
  ansible.builtin.debug:
    msg: "Created {{ results.results | selectattr('changed', 'equalto', true) | list | length }} addresses"
```

### 🎛️ Conditionals

```yaml
- name: Create address only if not exists
  fortinet.fortimanager.fmgr_firewall_address:
    state: present
    adom: "{{ fmg_adom }}"
    firewall_address:
      name: "{{ item.name }}"
      subnet: "{{ item.subnet }}"
  loop: "{{ addresses_ipv4 }}"
  when: item.state | default('present') == 'present'
```

---

## 🗂️ Role Structure

### 📁 Directory Tree

```
roles/fmg_addresses/
├── tasks/
│   └── main.yml
├── defaults/
│   └── main.yml
├── vars/
│   └── main.yml
├── handlers/
│   └── main.yml
└── meta/
    └── main.yml
```

### 📋 tasks/main.yml

```yaml
# roles/fmg_addresses/tasks/main.yml
---
- name: Manage IPv4 addresses
  fortinet.fortimanager.fmgr_firewall_address:
    state: "{{ item.state | default('present') }}"
    adom: "{{ fmg_adom }}"
    firewall_address:
      name: "{{ item.name }}"
      type: "ipmask"
      subnet: "{{ item.subnet }}"
      comment: "{{ item.comment | default(omit) }}"
  loop: "{{ fmg_addresses_ipv4 | default([]) }}"

- name: Manage address groups
  fortinet.fortimanager.fmgr_firewall_addrgrp:
    state: "{{ item.state | default('present') }}"
    adom: "{{ fmg_adom }}"
    firewall_addrgrp:
      name: "{{ item.name }}"
      member: "{{ item.members }}"
      comment: "{{ item.comment | default(omit) }}"
  loop: "{{ fmg_address_groups | default([]) }}"
```

### 📋 defaults/main.yml

```yaml
# roles/fmg_addresses/defaults/main.yml
---
fmg_adom: "root"
fmg_addresses_ipv4: []
fmg_address_groups: []
```

### ▶️ Using the Role

```yaml
# playbooks/site.yml
---
- name: Configure FortiManager
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  roles:
    - role: fmg_addresses
      vars:
        fmg_addresses_ipv4:
          - name: "NET_PRODUCTION"
            subnet: "10.0.0.0/8"
            comment: "Production network"
```

---

## 🔄 CI/CD

### 🔧 GitHub Actions

```yaml
# .github/workflows/deploy-fmg.yml
name: Deploy FortiManager Config

on:
  push:
    branches: [main]
    paths:
      - 'vars/**'
      - 'playbooks/**'
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install Ansible
        run: |
          pip install ansible
          ansible-galaxy collection install fortinet.fortimanager

      - name: Run playbook
        env:
          FMG_HOST: ${{ secrets.FMG_HOST }}
          FMG_API_KEY: ${{ secrets.FMG_API_KEY }}
        run: |
          ansible-playbook playbooks/manage_addresses.yml \
            -e "ansible_host=$FMG_HOST" \
            -e "ansible_httpapi_token=$FMG_API_KEY"
```

### 📊 Complete Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    CI/CD WORKFLOW                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📝 vars/         🎭 playbook.yml      📦 FortiManager     │
│  addresses.yml    ─────────────────►   API                 │
│  services.yml                                              │
│  policies.yml                                              │
│                                                             │
│  ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐    │
│  │ Git  │──►│Check │──►│Apply │──►│Wait  │──►│Verify│    │
│  │ Push │   │ Mode │   │      │   │ Task │   │      │    │
│  └──────┘   └──────┘   └──────┘   └──────┘   └──────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚡ Utility Playbooks

### 📋 List Address Names

```yaml
# playbooks/list_addresses.yml
---
- name: List Address Names
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  tasks:
    - name: Get all addresses
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "firewall_address"
          params:
            adom: "{{ fmg_adom }}"
      register: addresses

    - name: Display address names
      ansible.builtin.debug:
        msg: "{{ addresses.meta.response_data | map(attribute='name') | list }}"
```

### 🔢 Count Objects

```yaml
# playbooks/count_objects.yml
---
- name: Count FortiManager Objects
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  tasks:
    - name: Get addresses
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "firewall_address"
          params:
            adom: "{{ fmg_adom }}"
      register: addresses

    - name: Get services
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "firewall_service_custom"
          params:
            adom: "{{ fmg_adom }}"
      register: services

    - name: Get policies
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "pkg_firewall_policy"
          params:
            adom: "{{ fmg_adom }}"
            pkg: "{{ fmg_package }}"
      register: policies

    - name: Display counts
      ansible.builtin.debug:
        msg: |
          📊 Object Counts:
          Addresses: {{ addresses.meta.response_data | length }}
          Services: {{ services.meta.response_data | length }}
          Policies: {{ policies.meta.response_data | length }}
```

### 📤 Export CSV

```yaml
# playbooks/export_addresses_csv.yml
---
- name: Export Addresses to CSV
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  vars:
    export_file: "/tmp/addresses_export.csv"

  tasks:
    - name: Get all addresses
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "firewall_address"
          params:
            adom: "{{ fmg_adom }}"
      register: addresses

    - name: Create CSV content
      ansible.builtin.set_fact:
        csv_content: |
          name,type,subnet,comment
          {% for addr in addresses.meta.response_data %}
          {{ addr.name }},{{ addr.type | default('') }},{{ addr.subnet | default('') | join('/') if addr.subnet is iterable and addr.subnet is not string else addr.subnet | default('') }},{{ addr.comment | default('') }}
          {% endfor %}

    - name: Write CSV file
      ansible.builtin.copy:
        content: "{{ csv_content }}"
        dest: "{{ export_file }}"
      delegate_to: localhost

    - name: Display export location
      ansible.builtin.debug:
        msg: "✅ Exported to {{ export_file }}"
```

### 🔍 Audit Unused Objects

```yaml
# playbooks/audit_unused.yml
---
- name: Audit Unused Objects
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  tasks:
    - name: Get addresses with usage info
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "firewall_address"
          params:
            adom: "{{ fmg_adom }}"
          option: "get used"
      register: addresses

    - name: Find unused addresses
      ansible.builtin.set_fact:
        unused_addresses: "{{ addresses.meta.response_data | selectattr('_used_by', 'undefined') | map(attribute='name') | list }}"

    - name: Display unused addresses
      ansible.builtin.debug:
        msg: |
          🔍 Unused Addresses ({{ unused_addresses | length }}):
          {% for addr in unused_addresses %}
          - {{ addr }}
          {% endfor %}
      when: unused_addresses | length > 0

    - name: No unused addresses
      ansible.builtin.debug:
        msg: "✅ All addresses are in use"
      when: unused_addresses | length == 0
```

### 📊 Policies Summary by Action

```yaml
# playbooks/policies_summary.yml
---
- name: Policies Summary by Action
  hosts: fortimanager
  gather_facts: false
  connection: httpapi

  tasks:
    - name: Get all policies
      fortinet.fortimanager.fmgr_fact:
        facts:
          selector: "pkg_firewall_policy"
          params:
            adom: "{{ fmg_adom }}"
            pkg: "{{ fmg_package }}"
      register: policies

    - name: Count by action
      ansible.builtin.set_fact:
        accept_count: "{{ policies.meta.response_data | selectattr('action', 'equalto', 'accept') | list | length }}"
        deny_count: "{{ policies.meta.response_data | selectattr('action', 'equalto', 'deny') | list | length }}"

    - name: Display summary
      ansible.builtin.debug:
        msg: |
          📊 Policies by Action:
          Total: {{ policies.meta.response_data | length }}
          ✅ Accept: {{ accept_count }}
          ❌ Deny: {{ deny_count }}
```

---

## 💡 Best Practices

<table>
<tr>
<td width="50%">

### ✅ Do

- 🔐 **Use Ansible Vault** for secrets
- 🧪 **Check mode** before production
- 🏷️ **Tags** for selective execution
- 📁 **Separate** vars, playbooks, roles
- 🔄 **Idempotence** with state: present/absent
- 📝 **Comment** your variables

</td>
<td width="50%">

### ❌ Don't

- ❌ Secrets in code
- ❌ Hardcode ADOMs
- ❌ Ignore errors (ignore_errors: yes)
- ❌ Monolithic playbooks
- ❌ Modify prod without check mode
- ❌ Forget tags

</td>
</tr>
</table>

### 🔄 Idempotent Pattern

```yaml
# ✅ GOOD - Idempotent, uses state
- name: Ensure address exists
  fortinet.fortimanager.fmgr_firewall_address:
    state: present
    adom: "{{ fmg_adom }}"
    firewall_address:
      name: "NET_TEST"
      subnet: "10.0.0.0/24"
```

```yaml
# ❌ BAD - Not idempotent, ignores errors
- name: Create address
  fortinet.fortimanager.fmgr_firewall_address:
    adom: "root"  # Hardcoded!
    firewall_address:
      name: "NET_TEST"
      subnet: "10.0.0.0/24"
  ignore_errors: yes  # Dangerous!
```

---

## 🔧 Troubleshooting

| Problem | Cause | Solution |
|:--------|:------|:---------|
| `Authentication failed` | Incorrect credentials | Check vault or env vars |
| `Connection refused` | Port or SSL | `ansible_httpapi_port: 443` |
| `Object not found` | Wrong ADOM or name | Check `fmg_adom` |
| `Permission denied` | Insufficient rights | Check user profile |
| `Timeout` | Slow network | Increase `command_timeout` |

### 🐛 Debug Mode

```bash
# Maximum verbosity
ansible-playbook playbooks/manage_addresses.yml -vvvv

# View variables
ansible-playbook playbooks/manage_addresses.yml -e "ansible_debug=true"
```

### 📋 Module Reference

| Module | Description | API Endpoint |
|:-------|:------------|:-------------|
| `fmgr_firewall_address` | IPv4 Addresses | `/obj/firewall/address` |
| `fmgr_firewall_address6` | IPv6 Addresses | `/obj/firewall/address6` |
| `fmgr_firewall_addrgrp` | Address Groups | `/obj/firewall/addrgrp` |
| `fmgr_firewall_service_custom` | Services | `/obj/firewall/service/custom` |
| `fmgr_firewall_service_group` | Service Groups | `/obj/firewall/service/group` |
| `fmgr_pkg_firewall_policy` | Policies | `/pkg/{pkg}/firewall/policy` |
| `fmgr_securityconsole_install_package` | Installation | `/securityconsole/install/package` |

---

## 📚 See Also

<table>
<tr>
<td align="center" width="25%">

🔗 **[API Endpoints](api-endpoints.md)**

*Find the right URL*

</td>
<td align="center" width="25%">

🐍 **[Python Examples](python-examples.md)**

*Scripts with requests*

</td>
<td align="center" width="25%">

🔧 **[cURL Examples](curl-examples.md)**

*Quick CLI tests*

</td>
<td align="center" width="25%">

⚠️ **[Common Errors](common-errors.md)**

*Diagnosis and solutions*

</td>
</tr>
</table>

---

<div align="center">

*These playbooks are made to be copied and adapted - declare your infra!* 🎭

</div>
