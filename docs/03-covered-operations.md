# Covered Operations

> **Complete reference of FortiManager objects and operations supported in this repository.**

[Home](../README.md) > [Docs](./) > Covered Operations

---

## Overview

This repository demonstrates CRUD (Create, Read, Update, Delete) operations on FortiManager objects. Each section covers specific object types with practical examples across all 4 learning levels.

---

## CRUD Methods

![CRUD Methods](../diagrams/07-crud-methods.png)

| Method | Purpose | REST Equivalent | When to Use |
|--------|---------|-----------------|-------------|
| **`get`** | Read objects | GET | Retrieve data |
| **`add`** | Create new object | POST | Create new, fail if exists |
| **`set`** | Create or replace | PUT | Create or overwrite entirely |
| **`update`** | Partial update | PATCH | Modify specific fields |
| **`delete`** | Remove object | DELETE | Delete object |
| **`exec`** | Execute action | POST (action) | Login, install, tasks |

---

## Firewall Objects

### IPv4 Addresses

| Property | Description | Example |
|----------|-------------|---------|
| **name** | Unique identifier | `"SRV_WEB_01"` |
| **type** | Address type | `"ipmask"`, `"fqdn"`, `"iprange"` |
| **subnet** | IP and mask | `"192.168.10.10 255.255.255.255"` |
| **comment** | Description | `"Web Server"` |

**API Path:** `/pm/config/adom/{adom}/obj/firewall/address`

**Supported Types:**
- `ipmask` - IP with subnet mask
- `iprange` - IP range (start-ip, end-ip)
- `fqdn` - Fully qualified domain name
- `wildcard` - Wildcard mask
- `geography` - Country code
- `dynamic` - SDN connector

### IPv6 Addresses

**API Path:** `/pm/config/adom/{adom}/obj/firewall/address6`

Same operations as IPv4, with IPv6-specific fields.

### Address Groups

| Property | Description | Example |
|----------|-------------|---------|
| **name** | Group name | `"GRP_WEB_SERVERS"` |
| **member** | Array of addresses | `["SRV_WEB_01", "SRV_WEB_02"]` |
| **comment** | Description | `"All web servers"` |

**API Path:** `/pm/config/adom/{adom}/obj/firewall/addrgrp`

---

## Services

### Custom Services

| Property | Description | Example |
|----------|-------------|---------|
| **name** | Service name | `"TCP_8443"` |
| **protocol** | Protocol type | `"TCP/UDP/SCTP"` |
| **tcp-portrange** | TCP ports | `"8443"`, `"8000-9000"` |
| **udp-portrange** | UDP ports | `"53"`, `"161-162"` |

**API Path:** `/pm/config/adom/{adom}/obj/firewall/service/custom`

### Service Groups

**API Path:** `/pm/config/adom/{adom}/obj/firewall/service/group`

---

## Schedules

### One-time Schedules

| Property | Description | Example |
|----------|-------------|---------|
| **name** | Schedule name | `"MAINT_WINDOW_2024"` |
| **start** | Start datetime | `"00:00 2024/06/01"` |
| **end** | End datetime | `"06:00 2024/06/01"` |

**API Path:** `/pm/config/adom/{adom}/obj/firewall/schedule/onetime`

### Recurring Schedules

| Property | Description | Example |
|----------|-------------|---------|
| **name** | Schedule name | `"BUSINESS_HOURS"` |
| **day** | Days of week | `["monday", "tuesday", ...]` |
| **start** | Start time | `"08:00"` |
| **end** | End time | `"18:00"` |

**API Path:** `/pm/config/adom/{adom}/obj/firewall/schedule/recurring`

---

## NAT Configuration

### Virtual IPs (DNAT - Inbound)

| Property | Description | Example |
|----------|-------------|---------|
| **name** | VIP name | `"VIP_WEB_SERVER"` |
| **extip** | External IP | `"203.0.113.10"` |
| **mappedip** | Internal IP | `"192.168.10.10"` |
| **extport** | External port | `"443"` |
| **mappedport** | Internal port | `"8443"` |

**API Path:** `/pm/config/adom/{adom}/obj/firewall/vip`

### IP Pools (SNAT - Outbound)

| Property | Description | Example |
|----------|-------------|---------|
| **name** | Pool name | `"POOL_OUTBOUND"` |
| **startip** | First IP in pool | `"203.0.113.100"` |
| **endip** | Last IP in pool | `"203.0.113.110"` |
| **type** | Pool type | `"overload"`, `"one-to-one"` |

**API Path:** `/pm/config/adom/{adom}/obj/firewall/ippool`

---

## Security Profiles

### Application Groups

| Property | Description | Example |
|----------|-------------|---------|
| **name** | Group name | `"SOCIAL_MEDIA"` |
| **application** | App IDs | `[16000, 16001, ...]` |
| **comment** | Description | `"Social media apps"` |

**API Path:** `/pm/config/adom/{adom}/obj/application/group`

### Other Profiles

| Profile Type | API Path |
|--------------|----------|
| **Antivirus** | `/pm/config/adom/{adom}/obj/antivirus/profile` |
| **Web Filter** | `/pm/config/adom/{adom}/obj/webfilter/profile` |
| **IPS Sensor** | `/pm/config/adom/{adom}/obj/ips/sensor` |
| **SSL Inspection** | `/pm/config/adom/{adom}/obj/firewall/ssl-ssh-profile` |

---

## Firewall Policies

### Policy Structure

| Property | Description | Example |
|----------|-------------|---------|
| **name** | Policy name | `"Allow-Web-Traffic"` |
| **srcintf** | Source interfaces | `["port1"]` |
| **dstintf** | Destination interfaces | `["port2"]` |
| **srcaddr** | Source addresses | `["all"]` |
| **dstaddr** | Destination addresses | `["SRV_WEB_01"]` |
| **service** | Services | `["HTTP", "HTTPS"]` |
| **action** | Action | `"accept"`, `"deny"` |
| **logtraffic** | Logging | `"all"`, `"utm"`, `"disable"` |
| **nat** | NAT enable | `"enable"`, `"disable"` |

**API Path:** `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy`

### Policy Installation

![Policy Installation](../diagrams/05-policy-installation-workflow.png)

| Action | Method | API Path |
|--------|--------|----------|
| **Preview** | `exec` | `/securityconsole/install/preview` |
| **Install** | `exec` | `/securityconsole/install/package` |
| **Status** | `get` | `/task/task/{task_id}` |

---

## Operations by Level

| Operation | Level 1 | Level 2 | Level 3 | Level 4 |
|-----------|---------|---------|---------|---------|
| **Addresses** | Full CRUD | Full CRUD | Full CRUD | Full CRUD |
| **Services** | Full CRUD | Full CRUD | - | Full CRUD |
| **Schedules** | Full CRUD | - | - | - |
| **NAT/VIP** | Full CRUD | - | - | - |
| **Security Profiles** | Full CRUD | - | - | - |
| **Policies** | Full CRUD | Full CRUD | Full CRUD | Full CRUD |
| **Installation** | Yes | Yes | Yes | Yes |

---

## See Also

- [API Endpoints Cheatsheet](../cheatsheets/api-endpoints.md)
- [JSON-RPC Concepts](01-concepts-json-rpc.md)
- [Object Hierarchy Diagram](../diagrams/04-object-hierarchy.png)
