# FortiManager API Endpoints Cheatsheet

> **Quick reference for FortiManager JSON-RPC API endpoints.**

---

## URL Format

```
Base Pattern:
/pm/config/adom/{adom}/obj/{category}/{type}
/pm/config/adom/{adom}/pkg/{package}/firewall/policy

Variables:
{adom}     = Administrative domain (e.g., "root", "customer1")
{pkg}      = Policy package name (e.g., "default", "branch-fw")
{object}   = Object name (e.g., "SRV_WEB_01")
```

---

## System & Authentication

| Action | Method | Endpoint |
|--------|--------|----------|
| Login | `exec` | `/sys/login/user` |
| Logout | `exec` | `/sys/logout` |
| System Status | `get` | `/sys/status` |
| Admin Profile | `get` | `/cli/global/system/admin/profile` |
| List Admins | `get` | `/cli/global/system/admin/user` |

---

## ADOM Management

| Action | Method | Endpoint |
|--------|--------|----------|
| List all ADOMs | `get` | `/dvmdb/adom` |
| Get ADOM details | `get` | `/dvmdb/adom/{adom}` |
| Create ADOM | `add` | `/dvmdb/adom` |
| Delete ADOM | `delete` | `/dvmdb/adom/{adom}` |
| Lock ADOM (workspace) | `exec` | `/dvmdb/adom/{adom}/workspace/lock` |
| Unlock ADOM | `exec` | `/dvmdb/adom/{adom}/workspace/unlock` |
| Commit ADOM | `exec` | `/dvmdb/adom/{adom}/workspace/commit` |

---

## Firewall Addresses

| Object Type | Endpoint |
|-------------|----------|
| **IPv4 Address** | `/pm/config/adom/{adom}/obj/firewall/address` |
| **IPv6 Address** | `/pm/config/adom/{adom}/obj/firewall/address6` |
| **IPv4 Range** | `/pm/config/adom/{adom}/obj/firewall/address` (type: iprange) |
| **FQDN** | `/pm/config/adom/{adom}/obj/firewall/address` (type: fqdn) |
| **IPv4 Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp` |
| **IPv6 Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp6` |
| **Wildcard Address** | `/pm/config/adom/{adom}/obj/firewall/address` (type: wildcard) |
| **Geography** | `/pm/config/adom/{adom}/obj/firewall/address` (type: geography) |
| **Dynamic Address** | `/pm/config/adom/{adom}/obj/firewall/address` (type: dynamic) |

### Address Types

| Type | Description | Key Field |
|------|-------------|-----------|
| `ipmask` | IP + subnet mask | `subnet`: "10.0.0.0 255.255.255.0" |
| `iprange` | IP range | `start-ip`, `end-ip` |
| `fqdn` | Domain name | `fqdn`: "example.com" |
| `wildcard` | Wildcard | `wildcard`: "10.0.0.0 0.0.255.255" |
| `geography` | Country | `country`: "US" |
| `dynamic` | SDN connector | `sdn`, `filter` |

---

## Services

| Object Type | Endpoint |
|-------------|----------|
| **Custom Service** | `/pm/config/adom/{adom}/obj/firewall/service/custom` |
| **Service Group** | `/pm/config/adom/{adom}/obj/firewall/service/group` |
| **Service Category** | `/pm/config/adom/{adom}/obj/firewall/service/category` |

### Service Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `protocol` | Protocol type | `TCP/UDP/SCTP`, `ICMP`, `IP` |
| `tcp-portrange` | TCP ports | `"80"`, `"443"`, `"8000-9000"` |
| `udp-portrange` | UDP ports | `"53"`, `"161-162"` |
| `protocol-number` | IP protocol | `47` (GRE), `50` (ESP) |

---

## Schedules

| Object Type | Endpoint |
|-------------|----------|
| **One-time** | `/pm/config/adom/{adom}/obj/firewall/schedule/onetime` |
| **Recurring** | `/pm/config/adom/{adom}/obj/firewall/schedule/recurring` |
| **Schedule Group** | `/pm/config/adom/{adom}/obj/firewall/schedule/group` |

---

## NAT / VIP

| Object Type | Endpoint | Purpose |
|-------------|----------|---------|
| **VIP (IPv4)** | `/pm/config/adom/{adom}/obj/firewall/vip` | DNAT (inbound) |
| **VIP (IPv6)** | `/pm/config/adom/{adom}/obj/firewall/vip6` | DNAT (inbound) |
| **VIP Group** | `/pm/config/adom/{adom}/obj/firewall/vipgrp` | Group VIPs |
| **IP Pool (IPv4)** | `/pm/config/adom/{adom}/obj/firewall/ippool` | SNAT (outbound) |
| **IP Pool (IPv6)** | `/pm/config/adom/{adom}/obj/firewall/ippool6` | SNAT (outbound) |
| **Central SNAT** | `/pm/config/adom/{adom}/obj/firewall/central-snat-map` | Central NAT |

---

## Security Profiles

| Profile Type | Endpoint |
|--------------|----------|
| **Antivirus** | `/pm/config/adom/{adom}/obj/antivirus/profile` |
| **Web Filter** | `/pm/config/adom/{adom}/obj/webfilter/profile` |
| **URL Filter** | `/pm/config/adom/{adom}/obj/webfilter/urlfilter` |
| **Application Control** | `/pm/config/adom/{adom}/obj/application/list` |
| **Application Group** | `/pm/config/adom/{adom}/obj/application/group` |
| **IPS Sensor** | `/pm/config/adom/{adom}/obj/ips/sensor` |
| **SSL Inspection** | `/pm/config/adom/{adom}/obj/firewall/ssl-ssh-profile` |
| **DNS Filter** | `/pm/config/adom/{adom}/obj/dnsfilter/profile` |
| **DLP Sensor** | `/pm/config/adom/{adom}/obj/dlp/sensor` |

---

## Policies

| Object Type | Endpoint |
|-------------|----------|
| **Firewall Policy** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy` |
| **Policy by ID** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy/{policyid}` |
| **Policy Section** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy/section` |
| **Security Policy** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/security-policy` |
| **Consolidated Policy** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/consolidated/policy` |

### Policy Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Policy name |
| `srcintf` | array | Source interfaces |
| `dstintf` | array | Destination interfaces |
| `srcaddr` | array | Source addresses |
| `dstaddr` | array | Destination addresses |
| `service` | array | Services |
| `action` | string | `accept`, `deny`, `ipsec` |
| `logtraffic` | string | `disable`, `all`, `utm` |
| `nat` | string | `enable`, `disable` |
| `status` | string | `enable`, `disable` |

---

## Policy Packages

| Action | Method | Endpoint |
|--------|--------|----------|
| List packages | `get` | `/pm/pkg/adom/{adom}` |
| Get package | `get` | `/pm/pkg/adom/{adom}/{pkg}` |
| Create package | `add` | `/pm/pkg/adom/{adom}` |
| Delete package | `delete` | `/pm/pkg/adom/{adom}/{pkg}` |
| Clone package | `clone` | `/pm/pkg/adom/{adom}/{pkg}` |

---

## Device Management

| Action | Method | Endpoint |
|--------|--------|----------|
| List all devices | `get` | `/dvmdb/device` |
| Devices in ADOM | `get` | `/dvmdb/adom/{adom}/device` |
| Device details | `get` | `/dvmdb/device/{device}` |
| Device status | `get` | `/dvmdb/device/{device}/status` |
| Device interfaces | `get` | `/pm/config/device/{device}/global/system/interface` |
| Add device | `exec` | `/dvm/cmd/add/device` |
| Delete device | `exec` | `/dvm/cmd/del/device` |
| Authorize device | `exec` | `/dvm/cmd/update/device` |

---

## Installation & Deployment

| Action | Method | Endpoint |
|--------|--------|----------|
| **Install package** | `exec` | `/securityconsole/install/package` |
| **Preview install** | `exec` | `/securityconsole/install/preview` |
| **Device settings** | `exec` | `/securityconsole/install/device` |
| **Get install status** | `get` | `/task/task/{task_id}` |
| **Cancel install** | `exec` | `/securityconsole/cancel/install` |
| **Reinstall** | `exec` | `/securityconsole/reinstall/package` |

---

## Tasks & Jobs

| Action | Method | Endpoint |
|--------|--------|----------|
| List tasks | `get` | `/task/task` |
| Task details | `get` | `/task/task/{task_id}` |
| Task lines | `get` | `/task/task/{task_id}/line` |
| Cancel task | `exec` | `/task/task/{task_id}/stop` |
| Delete task | `delete` | `/task/task/{task_id}` |

### Task Status Values

| Status | Meaning |
|--------|---------|
| `0` | Pending |
| `1` | Running |
| `2` | Cancelling |
| `3` | Cancelled |
| `4` | Done |
| `5` | Error |
| `6` | Aborting |
| `7` | Aborted |
| `8` | Warning |

---

## Common Query Parameters

### Filtering

```json
{
  "filter": [
    ["name", "like", "NET_%"],
    ["type", "==", "ipmask"]
  ]
}
```

| Operator | Description |
|----------|-------------|
| `==` | Equals |
| `!=` | Not equals |
| `like` | Wildcard (% = any) |
| `!like` | Not like |
| `in` | In list |
| `contain` | Contains |
| `>`, `<`, `>=`, `<=` | Comparison |

### Field Selection

```json
{
  "fields": ["name", "subnet", "comment"]
}
```

### Options

```json
{
  "option": ["loadsub", "devinfo", "get used"]
}
```

| Option | Description |
|--------|-------------|
| `loadsub` | Load sub-objects |
| `devinfo` | Include device info |
| `get used` | Get objects using this |
| `syntax` | Get syntax info |

### Pagination

```json
{
  "range": [0, 100]
}
```

### Sorting

```json
{
  "sortings": [{"name": 1}]
}
```

---

## Quick Examples

### Read All Addresses

```json
{
  "id": 1,
  "method": "get",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address"
  }],
  "session": "..."
}
```

### Create Address

```json
{
  "id": 1,
  "method": "add",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address",
    "data": {
      "name": "SRV_WEB_01",
      "type": "ipmask",
      "subnet": "192.168.10.10 255.255.255.255",
      "comment": "Web Server"
    }
  }],
  "session": "..."
}
```

### Filter and Select Fields

```json
{
  "id": 1,
  "method": "get",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address",
    "filter": [["name", "like", "SRV_%"]],
    "fields": ["name", "subnet", "comment"]
  }],
  "session": "..."
}
```

### Install Policy Package

```json
{
  "id": 1,
  "method": "exec",
  "params": [{
    "url": "/securityconsole/install/package",
    "data": {
      "adom": "root",
      "pkg": "default",
      "scope": [
        {"name": "FGT-01", "vdom": "root"}
      ]
    }
  }],
  "session": "..."
}
```

---

## See Also

| Resource | Link |
|----------|------|
| Common Errors | [common-errors.md](common-errors.md) |
| cURL Examples | [curl-examples.md](curl-examples.md) |
| JSON-RPC Concepts | [../docs/01-concepts-json-rpc.md](../docs/01-concepts-json-rpc.md) |
