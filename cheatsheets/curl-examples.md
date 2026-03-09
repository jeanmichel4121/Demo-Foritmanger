# 🔧 FortiManager cURL Examples

<div align="center">

**Ready-to-copy-paste commands**

*Test the API in seconds*

[📋 Cheatsheets](README.md) • [🔗 Endpoints](api-endpoints.md) • [⚠️ Errors](common-errors.md)

---

</div>

## ⚡ Quick Start (2 minutes)

> 🎯 **Goal:** Test your first API command!

### 1️⃣ Configure your variables

```bash
# Copy and adapt these lines
export FMG_HOST="192.168.1.100"     # IP of your FortiManager
export FMG_API_KEY="your_api_key"   # Your API key
export FMG_ADOM="root"              # ADOM name
export FMG_PKG="default"            # Package name

# Option to ignore SSL errors (lab only!)
export CURL_OPTS="-k -s"
```

### 2️⃣ Test the connection

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/sys/status"}]}'
```

### 3️⃣ Expected result

```json
{
  "result": [{
    "status": { "code": 0, "message": "OK" },
    "data": {
      "Admin Domain Configuration": "Enabled",
      "Version": "v7.4.x",
      ...
    }
  }]
}
```

> ✅ **Code 0?** Congratulations, your connection works!

---

## 📖 Table of Contents

| Section | Description | Difficulty |
|:--------|:------------|:-----------|
| [🛠️ Configuration](#️-configuration) | Variables and helpers | ⭐ Easy |
| [🔐 Authentication](#-authentication) | Login / Logout | ⭐ Easy |
| [📍 Firewall Addresses](#-firewall-addresses) | CRUD addresses | ⭐⭐ Medium |
| [🔌 Services](#-services) | Ports and protocols | ⭐⭐ Medium |
| [📜 Policies](#-firewall-policies) | Security rules | ⭐⭐ Medium |
| [🔀 VIP / NAT](#-vip--nat) | Address translation | ⭐⭐ Medium |
| [🚀 Installation](#-installation) | Config deployment | ⭐⭐⭐ Advanced |
| [💻 Devices](#-devices) | Device management | ⭐⭐ Medium |
| [📦 Bulk Operations](#-bulk-operations) | Multiple operations | ⭐⭐⭐ Advanced |
| [⚡ One-Liners](#-useful-one-liners) | Quick commands | ⭐⭐ Medium |

---

## 🛠️ Configuration

### 📝 Environment Variables

```bash
# ═══════════════════════════════════════════════════════════
# Basic configuration - Adapt to your environment
# ═══════════════════════════════════════════════════════════

export FMG_HOST="192.168.1.100"    # 🖥️ IP or FQDN of FortiManager
export FMG_USER="admin"            # 👤 Username (for session)
export FMG_PASS="password"         # 🔑 Password (for session)
export FMG_ADOM="root"             # 🏢 ADOM name
export FMG_PKG="default"           # 📦 Policy package name

# 🔑 Bearer Token authentication (RECOMMENDED)
export FMG_API_KEY="your_api_key_here"

# ⚙️ cURL options
export CURL_OPTS="-k -s"           # -k = ignore SSL, -s = silent
```

### 🔧 Helper Function (Optional)

> 💡 Add this function to your `~/.bashrc` to simplify calls

```bash
fmg_curl() {
    curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $FMG_API_KEY" \
        -d "$1"
}

# Simplified usage:
fmg_curl '{"id":1,"method":"get","params":[{"url":"/sys/status"}]}'
```

---

## 🔐 Authentication

### 🔓 Login (Session)

> ⚠️ **Note:** Sessions expire after 5 min of inactivity. Prefer Bearer Token!

```bash
# Login and capture session token
SESSION=$(curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "method": "exec",
    "params": [{
      "url": "/sys/login/user",
      "data": {
        "user": "'$FMG_USER'",
        "passwd": "'$FMG_PASS'"
      }
    }]
  }' | jq -r '.session')

echo "✅ Session: $SESSION"
```

### 🔒 Logout (Session)

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 99,
    "method": "exec",
    "params": [{"url": "/sys/logout"}],
    "session": "'$SESSION'"
  }'
```

### 🔑 Bearer Token (Recommended)

> ✅ **Advantages:** No expiration, no login/logout, ideal for scripts!

```bash
# Simple - just add the header
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{"url": "/sys/status"}]
  }'
```

### 📊 Check System Status

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{"url": "/sys/status"}]
  }' | jq '.result[0].data'
```

<details>
<summary>📋 <b>Example response</b> (click to view)</summary>

```json
{
  "Admin Domain Configuration": "Enabled",
  "BIOS version": "04000024",
  "Branch Point": "2454",
  "Build": "2454",
  "Current Time": "Sun Mar 08 10:30:00 UTC 2026",
  "Hostname": "FMG-01",
  "License Status": "Valid",
  "Version": "v7.4.4"
}
```

</details>

---

## 📍 Firewall Addresses

### 📋 List All Addresses

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address"
    }]
  }' | jq '.result[0].data[] | {name, subnet, type}'
```

### 🔍 Filter by Name

> 💡 `%` is the wildcard (like `*` in shell)

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address",
      "filter": [["name", "like", "NET_%"]],
      "fields": ["name", "subnet", "comment"]
    }]
  }'
```

### ➕ Create an IP/Mask Address

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address",
      "data": {
        "name": "NET_SERVERS",
        "type": "ipmask",
        "subnet": "192.168.10.0 255.255.255.0",
        "comment": "Production server network"
      }
    }]
  }'
```

> ⚠️ **Subnet format:** `"IP MASK"` with **space**, not CIDR!

### ➕ Create an FQDN Address

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address",
      "data": {
        "name": "FQDN_GITHUB",
        "type": "fqdn",
        "fqdn": "github.com",
        "comment": "GitHub for developers"
      }
    }]
  }'
```

### ➕ Create an IP Range

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address",
      "data": {
        "name": "RANGE_DHCP",
        "type": "iprange",
        "start-ip": "192.168.1.100",
        "end-ip": "192.168.1.200",
        "comment": "DHCP pool"
      }
    }]
  }'
```

### ✏️ Modify an Address

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "update",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address/NET_SERVERS",
      "data": {
        "comment": "Modified: Production servers DMZ zone"
      }
    }]
  }'
```

### ❌ Delete an Address

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "delete",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address/NET_SERVERS"
    }]
  }'
```

> ⚠️ **Error -10?** The object is in use elsewhere. See [error guide](common-errors.md#-error--10--object-in-use).

### 📁 Create an Address Group

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/addrgrp",
      "data": {
        "name": "GRP_ALL_SERVERS",
        "member": ["NET_WEB_SERVERS", "NET_DB_SERVERS"],
        "comment": "All servers"
      }
    }]
  }'
```

---

## 🔌 Services

### 📋 List Custom Services

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/service/custom",
      "fields": ["name", "tcp-portrange", "udp-portrange"]
    }]
  }'
```

### ➕ Create a TCP Service

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/service/custom",
      "data": {
        "name": "TCP_8443",
        "protocol": "TCP/UDP/SCTP",
        "tcp-portrange": "8443",
        "comment": "Alternate HTTPS"
      }
    }]
  }'
```

### ➕ Create a UDP Service

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/service/custom",
      "data": {
        "name": "UDP_VOIP",
        "protocol": "TCP/UDP/SCTP",
        "udp-portrange": "5060-5065",
        "comment": "VoIP SIP ports"
      }
    }]
  }'
```

### 📁 Create a Service Group

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/service/group",
      "data": {
        "name": "GRP_WEB",
        "member": ["HTTP", "HTTPS", "TCP_8443"],
        "comment": "Web services"
      }
    }]
  }'
```

---

## 📜 Firewall Policies

### 📋 List Policies

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/pkg/'$FMG_PKG'/firewall/policy",
      "fields": ["policyid", "name", "srcaddr", "dstaddr", "service", "action"]
    }]
  }' | jq '.result[0].data'
```

### ➕ Create an Allow Policy

> ⚠️ **Important:** `srcaddr`, `dstaddr`, `service` are **arrays** `["value"]`!

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/pkg/'$FMG_PKG'/firewall/policy",
      "data": {
        "name": "Allow-Web-Servers",
        "srcintf": ["any"],
        "dstintf": ["any"],
        "srcaddr": ["all"],
        "dstaddr": ["NET_SERVERS"],
        "service": ["HTTP", "HTTPS"],
        "action": "accept",
        "logtraffic": "all",
        "nat": "enable",
        "status": "enable",
        "comments": "Web access to servers"
      }
    }]
  }'
```

### ➕ Create a Deny Policy

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/pkg/'$FMG_PKG'/firewall/policy",
      "data": {
        "name": "Block-All-Default",
        "srcintf": ["any"],
        "dstintf": ["any"],
        "srcaddr": ["all"],
        "dstaddr": ["all"],
        "service": ["ALL"],
        "action": "deny",
        "logtraffic": "all",
        "status": "enable"
      }
    }]
  }'
```

### 🔄 Move a Policy

```
┌─────────────────────────────────────────┐
│  Before move:                           │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐   │
│  │ 1  │ │ 2  │ │ 3  │ │ 4  │ │ 5  │   │
│  └────┘ └────┘ └────┘ └────┘ └────┘   │
│                                         │
│  Move policy 5 BEFORE policy 2:         │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐   │
│  │ 1  │ │ 5  │ │ 2  │ │ 3  │ │ 4  │   │
│  └────┘ └────┘ └────┘ └────┘ └────┘   │
└─────────────────────────────────────────┘
```

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "move",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/pkg/'$FMG_PKG'/firewall/policy/5",
      "option": "before",
      "target": "2"
    }]
  }'
```

### ❌ Delete a Policy

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "delete",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/pkg/'$FMG_PKG'/firewall/policy/10"
    }]
  }'
```

---

## 🔀 VIP / NAT

### ➕ Create a Static NAT VIP (1:1)

```
┌─────────────────────────────────────────────────────┐
│              STATIC NAT (1:1)                       │
│                                                     │
│  Internet              FortiGate           Internal │
│  ─────────►  203.0.113.10  ────►  192.168.10.10    │
│              (Public IP)          (Private IP)      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/vip",
      "data": {
        "name": "VIP_WEB_SERVER",
        "type": "static-nat",
        "extip": "203.0.113.10",
        "mappedip": "192.168.10.10",
        "extintf": "any",
        "comment": "NAT to web server"
      }
    }]
  }'
```

### ➕ Create Port Forwarding

```
┌─────────────────────────────────────────────────────┐
│              PORT FORWARDING                        │
│                                                     │
│  Internet              FortiGate           Internal │
│  ───► :8080  ──►  203.0.113.10:8080 ──► :80        │
│     (external)                       (internal)     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [{
      "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/vip",
      "data": {
        "name": "VIP_WEB_8080",
        "type": "static-nat",
        "extip": "203.0.113.10",
        "extport": "8080",
        "mappedip": "192.168.10.10",
        "mappedport": "80",
        "extintf": "any",
        "portforward": "enable",
        "protocol": "tcp",
        "comment": "External port 8080 to internal port 80"
      }
    }]
  }'
```

---

## 🚀 Installation

### 👁️ Preview (Simulation)

> 💡 Check what will be deployed **before** installation!

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "exec",
    "params": [{
      "url": "/securityconsole/install/preview",
      "data": {
        "adom": "'$FMG_ADOM'",
        "device": "FGT-01",
        "flags": ["none"]
      }
    }]
  }'
```

### 📤 Install a Package

```bash
# Install and retrieve Task ID
TASK_ID=$(curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "exec",
    "params": [{
      "url": "/securityconsole/install/package",
      "data": {
        "adom": "'$FMG_ADOM'",
        "pkg": "'$FMG_PKG'",
        "scope": [
          {"name": "FGT-01", "vdom": "root"}
        ]
      }
    }]
  }' | jq -r '.result[0].data.task')

echo "📤 Installation started - Task ID: $TASK_ID"
```

### 📊 Check Task Status

```bash
TASK_ID=12345

curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{
      "url": "/task/task/'$TASK_ID'"
    }]
  }' | jq '.result[0].data | {state, percent, num_done, num_err}'
```

### ⏳ Wait for Task Completion (Script)

```bash
#!/bin/bash
# Usage: ./wait_task.sh <task_id>

TASK_ID=$1

echo "⏳ Waiting for task $TASK_ID..."

while true; do
    RESULT=$(curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $FMG_API_KEY" \
      -d '{
        "id": 1,
        "method": "get",
        "params": [{"url": "/task/task/'$TASK_ID'"}]
      }')

    STATE=$(echo $RESULT | jq -r '.result[0].data.state')
    PERCENT=$(echo $RESULT | jq -r '.result[0].data.percent')

    echo "📊 State: $STATE | Progress: $PERCENT%"

    case $STATE in
        4) echo "✅ Task completed successfully!"; exit 0 ;;
        5) echo "❌ Task failed!"; exit 1 ;;
        7) echo "🛑 Task aborted!"; exit 1 ;;
        *) sleep 3 ;;
    esac
done
```

---

## 💻 Devices

### 📋 List Devices

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{
      "url": "/dvmdb/adom/'$FMG_ADOM'/device",
      "fields": ["name", "hostname", "ip", "conn_status", "os_ver"]
    }]
  }' | jq '.result[0].data[] | {name, hostname, ip, conn_status}'
```

### 🔍 Device Details

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{
      "url": "/dvmdb/device/FGT-01"
    }]
  }'
```

---

## 📦 Bulk Operations

### ➕ Create Multiple Addresses in One Request

> 💡 Use an array in `params` for multiple requests!

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "add",
    "params": [
      {
        "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address",
        "data": {"name": "NET_A", "type": "ipmask", "subnet": "10.0.0.0 255.0.0.0"}
      },
      {
        "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address",
        "data": {"name": "NET_B", "type": "ipmask", "subnet": "172.16.0.0 255.255.0.0"}
      },
      {
        "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address",
        "data": {"name": "NET_C", "type": "ipmask", "subnet": "192.168.0.0 255.255.255.0"}
      }
    ]
  }'
```

### 📄 Import from CSV (Script)

> 📁 **CSV Format:** `name,subnet,comment`

```bash
#!/bin/bash
# Usage: ./import_addresses.sh addresses.csv

CSV_FILE=$1

# CIDR to Mask conversion
cidr_to_mask() {
    local ip="${1%/*}"
    local bits="${1#*/}"
    local mask=$((0xffffffff << (32 - bits)))
    printf "%s %d.%d.%d.%d" "$ip" \
        $((mask >> 24 & 255)) $((mask >> 16 & 255)) \
        $((mask >> 8 & 255)) $((mask & 255))
}

# Read CSV
echo "📄 Importing from $CSV_FILE"

while IFS=, read -r name subnet comment; do
    # Skip header
    [[ "$name" == "name" ]] && continue

    subnet_mask=$(cidr_to_mask "$subnet")

    echo "➕ Creating: $name ($subnet_mask)"

    curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $FMG_API_KEY" \
      -d '{
        "id": 1,
        "method": "add",
        "params": [{
          "url": "/pm/config/adom/'$FMG_ADOM'/obj/firewall/address",
          "data": {
            "name": "'"$name"'",
            "type": "ipmask",
            "subnet": "'"$subnet_mask"'",
            "comment": "'"$comment"'"
          }
        }]
      }'

done < "$CSV_FILE"

echo "✅ Import complete!"
```

---

## ⚡ Useful One-Liners

### 📋 List Address Names

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/pm/config/adom/root/obj/firewall/address","fields":["name"]}]}' \
  | jq -r '.result[0].data[].name'
```

### 🔢 Count Objects

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/pm/config/adom/root/obj/firewall/address"}]}' \
  | jq '.result[0].data | length'
```

### 📤 Export Addresses to CSV

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/pm/config/adom/root/obj/firewall/address","fields":["name","subnet","comment"]}]}' \
  | jq -r '.result[0].data[] | [.name, (.subnet // [] | if type == "array" then join("/") else . end), .comment] | @csv' > addresses_export.csv

echo "✅ Exported to addresses_export.csv"
```

### 🔍 Find Unused Addresses

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/pm/config/adom/root/obj/firewall/address","option":["get used"]}]}' \
  | jq -r '.result[0].data[] | select(._used_by == null) | .name'
```

### 📊 Policies Summary by Action

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/pm/config/adom/root/pkg/default/firewall/policy","fields":["action"]}]}' \
  | jq '.result[0].data | group_by(.action) | map({action: .[0].action, count: length})'
```

---

## 📚 See Also

<table>
<tr>
<td align="center" width="20%">

🔗 **[API Endpoints](api-endpoints.md)**

*Find the right URL*

</td>
<td align="center" width="20%">

🐍 **[Python Examples](python-examples.md)**

*Scripts with requests*

</td>
<td align="center" width="20%">

🎭 **[Ansible Examples](ansible-examples.md)**

*IaC Playbooks*

</td>
<td align="center" width="20%">

⚠️ **[Common Errors](common-errors.md)**

*When things don't work*

</td>
<td align="center" width="20%">

📖 **[Documentation](../docs/README.md)**

*Detailed guides*

</td>
</tr>
</table>

---

<div align="center">

*Copy, paste, adapt - these commands are made to be used!* 🚀

</div>
