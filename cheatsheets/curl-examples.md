# cURL FortiManager API Examples

> **Ready-to-use cURL commands for FortiManager JSON-RPC API.**

---

## Setup

### Environment Variables

```bash
# Set these before running the examples
export FMG_HOST="192.168.1.100"
export FMG_USER="admin"
export FMG_PASS="password"
export FMG_ADOM="root"
export FMG_PKG="default"

# For Bearer token authentication (recommended)
export FMG_API_KEY="your_api_key_here"

# cURL options for lab environments
export CURL_OPTS="-k -s"
```

### Helper Function (Bash)

```bash
# Add to ~/.bashrc or run before examples
fmg_curl() {
    curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $FMG_API_KEY" \
        -d "$1"
}

# Usage
fmg_curl '{"id":1,"method":"get","params":[{"url":"/sys/status"}]}'
```

---

## Authentication

### Session Login

```bash
# Login and get session token
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

echo "Session: $SESSION"
```

### Session Logout

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

### Bearer Token (API Key)

```bash
# No login/logout needed - just add header
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{"url": "/sys/status"}]
  }'
```

### Check System Status

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

---

## Firewall Addresses

### List All Addresses

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

### Filter Addresses by Name

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

### Create IPv4 Address (ipmask)

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
        "comment": "Server network"
      }
    }]
  }'
```

### Create FQDN Address

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
        "name": "FQDN_EXAMPLE",
        "type": "fqdn",
        "fqdn": "example.com",
        "comment": "External website"
      }
    }]
  }'
```

### Create IP Range Address

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

### Update Address

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
        "comment": "Updated: Production server network"
      }
    }]
  }'
```

### Delete Address

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

### Create Address Group

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
        "comment": "All server networks"
      }
    }]
  }'
```

---

## Services

### List Custom Services

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

### Create TCP Service

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
        "comment": "Custom HTTPS port"
      }
    }]
  }'
```

### Create UDP Service

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
        "name": "UDP_CUSTOM",
        "protocol": "TCP/UDP/SCTP",
        "udp-portrange": "5000-5100",
        "comment": "Custom UDP range"
      }
    }]
  }'
```

### Create Service Group

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
        "name": "GRP_WEB_SERVICES",
        "member": ["HTTP", "HTTPS", "TCP_8443"],
        "comment": "Web services group"
      }
    }]
  }'
```

---

## Firewall Policies

### List All Policies

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

### Create Firewall Policy

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
        "name": "Allow-Web-Traffic",
        "srcintf": ["any"],
        "dstintf": ["any"],
        "srcaddr": ["all"],
        "dstaddr": ["NET_SERVERS"],
        "service": ["HTTP", "HTTPS"],
        "action": "accept",
        "logtraffic": "all",
        "nat": "enable",
        "status": "enable",
        "comments": "Allow web access to servers"
      }
    }]
  }'
```

### Create Deny Policy

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

### Move Policy Position

```bash
# Move policy ID 5 before policy ID 2
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

### Delete Policy

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

## VIP (NAT)

### Create Static NAT (1:1)

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
        "comment": "Web server NAT"
      }
    }]
  }'
```

### Create Port Forwarding VIP

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
        "comment": "Port forward 8080 to 80"
      }
    }]
  }'
```

---

## Installation

### Preview Installation

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

### Install Policy Package

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
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
  }' | tee /tmp/install.json | jq '.result[0].data.task'
```

### Check Task Status

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
  }' | jq '.result[0].data | {state, percent, line: .line[]?.detail}'
```

### Wait for Task Completion

```bash
#!/bin/bash
TASK_ID=$1

while true; do
    STATUS=$(curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $FMG_API_KEY" \
      -d '{
        "id": 1,
        "method": "get",
        "params": [{"url": "/task/task/'$TASK_ID'"}]
      }' | jq -r '.result[0].data.state')

    echo "Task status: $STATUS"

    case $STATUS in
        4) echo "Done!"; break ;;
        5|7) echo "Failed/Aborted!"; exit 1 ;;
        *) sleep 5 ;;
    esac
done
```

---

## Device Management

### List All Devices

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

### Get Device Details

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

## Bulk Operations

### Create Multiple Addresses

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

### Bulk Create from CSV

```bash
#!/bin/bash
# addresses.csv format: name,subnet,comment
# NET_A,10.0.0.0/8,Network A
# NET_B,172.16.0.0/16,Network B

# Convert CIDR to mask
cidr_to_mask() {
    local cidr=$1
    local ip="${cidr%/*}"
    local bits="${cidr#*/}"
    local mask=$((0xffffffff << (32 - bits)))
    printf "%s %d.%d.%d.%d" "$ip" \
        $((mask >> 24 & 255)) $((mask >> 16 & 255)) \
        $((mask >> 8 & 255)) $((mask & 255))
}

# Process CSV
while IFS=, read -r name subnet comment; do
    [[ "$name" == "name" ]] && continue  # Skip header
    subnet_mask=$(cidr_to_mask "$subnet")

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

    echo "Created: $name"
done < addresses.csv
```

---

## Useful One-Liners

### List Address Names

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/pm/config/adom/root/obj/firewall/address","fields":["name"]}]}' \
  | jq -r '.result[0].data[].name'
```

### Count Objects

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/pm/config/adom/root/obj/firewall/address"}]}' \
  | jq '.result[0].data | length'
```

### Export Addresses to CSV

```bash
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/pm/config/adom/root/obj/firewall/address","fields":["name","subnet","comment"]}]}' \
  | jq -r '.result[0].data[] | [.name, (.subnet | join("/")), .comment] | @csv' > addresses.csv
```

### Find Unused Addresses

```bash
# Get addresses with "get used" option
curl $CURL_OPTS -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/pm/config/adom/root/obj/firewall/address","option":["get used"]}]}' \
  | jq '.result[0].data[] | select(._used_by == null) | .name'
```

---

## See Also

| Resource | Link |
|----------|------|
| API Endpoints | [api-endpoints.md](api-endpoints.md) |
| Common Errors | [common-errors.md](common-errors.md) |
| JSON-RPC Concepts | [../docs/01-concepts-json-rpc.md](../docs/01-concepts-json-rpc.md) |
