# Covered Operations

> **Complete reference of FortiManager objects and API paths supported in this repository.**

[Home](../README.md) > [Docs](./) > Covered Operations

---

## 📋 Overview

This repository demonstrates CRUD operations on FortiManager objects. Each section covers specific object types with practical examples across all 4 learning levels.

For details on CRUD methods (`get`, `add`, `set`, `update`, `delete`), see [JSON-RPC Concepts](01-concepts-json-rpc.md#available-methods).

![CRUD Methods](../diagrams/07-crud-methods.png)

---

## 🏠 Firewall Objects

### Addresses

Addresses are the building blocks for firewall policies - they define source and destination endpoints.

| Object Type | API Path | Description |
|-------------|----------|-------------|
| **IPv4 Address** | `/pm/config/adom/{adom}/obj/firewall/address` | Single hosts, subnets, ranges |
| **IPv6 Address** | `/pm/config/adom/{adom}/obj/firewall/address6` | IPv6 equivalents |
| **Address Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp` | Logical grouping of addresses |
| **Address Group (IPv6)** | `/pm/config/adom/{adom}/obj/firewall/addrgrp6` | IPv6 address groups |

**Supported Address Types:**

| Type | Description | Example |
|------|-------------|---------|
| `ipmask` | IP with subnet mask | `10.0.0.0 255.255.255.0` |
| `iprange` | IP range | `startip: 10.0.0.1, endip: 10.0.0.100` |
| `fqdn` | DNS hostname | `www.example.com` |
| `wildcard` | Wildcard mask | `10.0.*.0 255.255.0.255` |
| `geography` | Country code | `country: US` |
| `dynamic` | Dynamic address | FortiClient EMS tags |

### Services

Services define TCP/UDP ports, protocols, and port ranges used in firewall policies.

| Object Type | API Path | Description |
|-------------|----------|-------------|
| **Custom Service** | `/pm/config/adom/{adom}/obj/firewall/service/custom` | User-defined services |
| **Service Group** | `/pm/config/adom/{adom}/obj/firewall/service/group` | Logical grouping |
| **Service Category** | `/pm/config/adom/{adom}/obj/firewall/service/category` | Service categories |

**Protocol Support:**

| Protocol | Description |
|----------|-------------|
| `TCP/UDP/SCTP` | Layer 4 protocols with port ranges |
| `ICMP` | ICMP types and codes |
| `IP` | Raw IP protocol numbers |

### Schedules

Schedules define time windows for policy enforcement.

| Object Type | API Path | Use Case |
|-------------|----------|----------|
| **One-time** | `/pm/config/adom/{adom}/obj/firewall/schedule/onetime` | Maintenance windows |
| **Recurring** | `/pm/config/adom/{adom}/obj/firewall/schedule/recurring` | Business hours |
| **Schedule Group** | `/pm/config/adom/{adom}/obj/firewall/schedule/group` | Combined schedules |

---

## 🔀 NAT Configuration

Network Address Translation for inbound and outbound traffic.

| Object Type | API Path | Direction | Purpose |
|-------------|----------|-----------|---------|
| **VIP (IPv4)** | `/pm/config/adom/{adom}/obj/firewall/vip` | Inbound | DNAT / Port forwarding |
| **VIP (IPv6)** | `/pm/config/adom/{adom}/obj/firewall/vip6` | Inbound | IPv6 DNAT |
| **VIP Group** | `/pm/config/adom/{adom}/obj/firewall/vipgrp` | Inbound | Grouped VIPs |
| **IP Pool (IPv4)** | `/pm/config/adom/{adom}/obj/firewall/ippool` | Outbound | SNAT |
| **IP Pool (IPv6)** | `/pm/config/adom/{adom}/obj/firewall/ippool6` | Outbound | IPv6 SNAT |

**VIP Types:**

| Type | Description |
|------|-------------|
| `static-nat` | 1:1 NAT mapping |
| `server-load-balance` | Load balancing across servers |
| `dns-translation` | DNS-based translation |

**IP Pool Types:**

| Type | Description |
|------|-------------|
| `overload` | PAT - many-to-one |
| `one-to-one` | 1:1 source NAT |
| `fixed-port-range` | Deterministic NAT |

---

## 🛡️ Security Profiles

Deep inspection and content control profiles.

| Profile Type | API Path | Purpose |
|--------------|----------|---------|
| **Application Group** | `/pm/config/adom/{adom}/obj/application/group` | App control groups |
| **Application List** | `/pm/config/adom/{adom}/obj/application/list` | App control policies |
| **Antivirus** | `/pm/config/adom/{adom}/obj/antivirus/profile` | Malware scanning |
| **Web Filter** | `/pm/config/adom/{adom}/obj/webfilter/profile` | URL/content filtering |
| **URL Filter** | `/pm/config/adom/{adom}/obj/webfilter/urlfilter` | URL lists |
| **IPS Sensor** | `/pm/config/adom/{adom}/obj/ips/sensor` | Intrusion prevention |
| **SSL/SSH Inspection** | `/pm/config/adom/{adom}/obj/firewall/ssl-ssh-profile` | Deep inspection |

---

## 🔥 Firewall Policies

The core of FortiGate security - controlling traffic flow.

| Object Type | API Path | Description |
|-------------|----------|-------------|
| **Firewall Policy** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy` | All policies in package |
| **Policy by ID** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy/{id}` | Specific policy |

**Policy Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Policy name |
| `srcintf` | Array | Source interfaces |
| `dstintf` | Array | Destination interfaces |
| `srcaddr` | Array | Source addresses |
| `dstaddr` | Array | Destination addresses |
| `service` | Array | Services |
| `action` | String | `accept`, `deny`, `reject` |
| `schedule` | String | Time-based control |
| `nat` | String | `enable`, `disable` |
| `logtraffic` | String | `all`, `utm`, `disable` |

### Policy Installation

| Action | Method | API Path | Description |
|--------|--------|----------|-------------|
| **Preview** | `exec` | `/securityconsole/install/preview` | Dry-run before install |
| **Install** | `exec` | `/securityconsole/install/package` | Deploy to devices |
| **Status** | `get` | `/task/task/{task_id}` | Check task progress |

![Policy Installation Workflow](../diagrams/05-policy-installation-workflow.png)

---

## 📊 Operations Coverage by Level

| Operation | Level 1 (Raw HTTP) | Level 2 (Python) | Level 3 (pyFMG) | Level 4 (Ansible) |
|-----------|:------------------:|:----------------:|:---------------:|:-----------------:|
| **Authentication** | Session + Bearer | Session + Bearer | Session + Bearer | httpapi |
| **Addresses** | Full CRUD | Full CRUD | Full CRUD | Full CRUD |
| **Address Groups** | Full CRUD | - | - | Full CRUD |
| **Services** | Full CRUD | Full CRUD | - | Full CRUD |
| **Service Groups** | - | - | - | Full CRUD |
| **Schedules** | Full CRUD | - | - | - |
| **VIPs (DNAT)** | Full CRUD | - | - | - |
| **IP Pools (SNAT)** | Full CRUD | - | - | - |
| **App Groups** | Full CRUD | - | - | - |
| **URL Filters** | PowerShell only | - | - | - |
| **Policies** | Full CRUD + Move | Full CRUD | Full CRUD | Full CRUD |
| **Installation** | Preview + Install | Preview + Install | Preview + Install | Preview + Install |

> **Legend**: Full CRUD = Create, Read, Update, Delete operations demonstrated

---

## 🔄 Common Patterns

### Create or Update (Upsert)

```python
# Using 'set' method for idempotent operations
fmg.set(url, data)  # Creates if not exists, replaces if exists

# Or handle explicitly
try:
    fmg.add(url, data)
except ObjectExistsError:
    fmg.update(f"{url}/{name}", data)
```

### Bulk Operations

```json
{
    "method": "add",
    "params": [
        {"url": "...", "data": {"name": "NET_A", ...}},
        {"url": "...", "data": {"name": "NET_B", ...}},
        {"url": "...", "data": {"name": "NET_C", ...}}
    ]
}
```

### Filtered Read

```json
{
    "method": "get",
    "params": [{
        "url": "/pm/config/adom/root/obj/firewall/address",
        "filter": [["name", "like", "NET_%"]],
        "fields": ["name", "subnet", "comment"]
    }]
}
```

---

## 🔗 See Also

- [API Endpoints Cheatsheet](../cheatsheets/api-endpoints.md) - Complete endpoint reference
- [JSON-RPC Concepts](01-concepts-json-rpc.md) - Request structure and methods
- [Common Errors](../cheatsheets/common-errors.md) - Error codes and solutions
- [Best Practices](04-best-practices.md) - Security and code quality guidelines
