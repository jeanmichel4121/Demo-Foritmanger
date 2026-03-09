# 🔗 FortiManager API Endpoints

<div align="center">

**Complete JSON-RPC API endpoint reference**

*Quickly find the URL you need*

[📋 Cheatsheets](README.md) • [🔧 cURL Examples](curl-examples.md) • [⚠️ Errors](common-errors.md)

---

</div>

## 📖 Table of Contents

| Section | Description |
|:--------|:------------|
| [🎯 Understanding URLs](#-understanding-urls) | Basic structure |
| [🔐 Authentication](#-authentication) | Login, logout, status |
| [🏢 ADOM & Workspace](#-adom--workspace) | Domain management |
| [📍 Firewall Addresses](#-firewall-addresses) | Network objects |
| [🔌 Services](#-services) | Ports and protocols |
| [📅 Schedules](#-schedules) | Time scheduling |
| [🔀 NAT / VIP](#-nat--vip) | Address translation |
| [🛡️ Security Profiles](#️-security-profiles) | AV, IPS, WebFilter... |
| [📜 Policies](#-policies) | Firewall rules |
| [📦 Packages](#-packages) | Policy packages |
| [💻 Devices](#-devices) | Device management |
| [🚀 Installation](#-installation) | Deployment |
| [📊 Tasks](#-tasks) | Task tracking |
| [🔍 Filters & Options](#-filters--options) | Advanced queries |

---

## 🎯 Understanding URLs

> 💡 **All FortiManager URLs follow a logical pattern!**

```
┌─────────────────────────────────────────────────────────────────┐
│                    URL STRUCTURE                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  /pm/config/adom/{adom}/obj/firewall/address                   │
│  ├──────┘ ├───┘ ├────┘ ├─┘ ├──────┘ ├──────┘                   │
│  │        │     │      │   │        │                          │
│  │        │     │      │   │        └─► Object type            │
│  │        │     │      │   └──────────► Category               │
│  │        │     │      └──────────────► Global objects         │
│  │        │     └─────────────────────► ADOM name              │
│  │        └───────────────────────────► ADOM config            │
│  └────────────────────────────────────► Policy Manager         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 📐 Main Patterns

| Pattern | Usage | Example |
|:--------|:------|:--------|
| `/pm/config/adom/{adom}/obj/...` | Shared objects | Addresses, services |
| `/pm/config/adom/{adom}/pkg/{pkg}/...` | Package objects | Policies |
| `/dvmdb/...` | Device database | Devices, ADOMs |
| `/sys/...` | System | Login, status |
| `/task/...` | Tasks | Installation status |

### 📝 Variables to Replace

| Variable | Description | Examples |
|:---------|:------------|:---------|
| `{adom}` | ADOM name | `root`, `customer1`, `branch-offices` |
| `{pkg}` | Package name | `default`, `main-policy`, `branch-fw` |
| `{object}` | Object name | `SRV_WEB_01`, `NET_SERVERS` |
| `{device}` | Device name | `FGT-01`, `FGT-BRANCH-001` |

---

## 🔐 Authentication

> 🔑 **First step before any operation!**

| Action | Method | Endpoint | Description |
|:-------|:-------|:---------|:------------|
| 🔓 **Login** | `exec` | `/sys/login/user` | Get session token |
| 🔒 **Logout** | `exec` | `/sys/logout` | End session |
| 📊 **Status** | `get` | `/sys/status` | Check system |
| 👤 **Admin Profile** | `get` | `/cli/global/system/admin/profile` | View profiles |
| 👥 **Admin List** | `get` | `/cli/global/system/admin/user` | List admins |

<details>
<summary>💡 <b>Tip: Bearer Token vs Session</b> (click to view)</summary>

---

| Method | Advantages | Disadvantages |
|:-------|:-----------|:--------------|
| **Session** | Simple to implement | Expires after 5 min of inactivity |
| **Bearer Token** | Never expires | Requires creation in GUI |

**Recommendation:** Use **Bearer Token** for automated scripts!

---

</details>

---

## 🏢 ADOM & Workspace

> 🏗️ **ADOM = Administrative Domain** - Logical configuration isolation

| Action | Method | Endpoint |
|:-------|:-------|:---------|
| 📋 List ADOMs | `get` | `/dvmdb/adom` |
| 🔍 ADOM Details | `get` | `/dvmdb/adom/{adom}` |
| ➕ Create ADOM | `add` | `/dvmdb/adom` |
| ❌ Delete ADOM | `delete` | `/dvmdb/adom/{adom}` |

### 🔒 Workspace Mode

> ⚠️ **CRITICAL!** If workspace mode is enabled, you MUST follow this workflow:

```
┌─────────┐     ┌──────────────┐     ┌────────┐     ┌──────────┐
│  LOCK   │ ──► │   CHANGES    │ ──► │ COMMIT │ ──► │  UNLOCK  │
│  ADOM   │     │  (add/del/   │     │        │     │   ADOM   │
│         │     │   update)    │     │        │     │          │
└─────────┘     └──────────────┘     └────────┘     └──────────┘
```

| Action | Method | Endpoint |
|:-------|:-------|:---------|
| 🔒 **Lock ADOM** | `exec` | `/dvmdb/adom/{adom}/workspace/lock` |
| 💾 **Commit** | `exec` | `/dvmdb/adom/{adom}/workspace/commit` |
| 🔓 **Unlock ADOM** | `exec` | `/dvmdb/adom/{adom}/workspace/unlock` |

> 🚨 **Error `-10147`?** → You forgot to lock the ADOM!

---

## 📍 Firewall Addresses

> 🌐 **Network objects usable in policies**

### Address Types

| Type | Endpoint | Description |
|:-----|:---------|:------------|
| 🖥️ **IPv4** | `/pm/config/adom/{adom}/obj/firewall/address` | IPv4 addresses |
| 🌐 **IPv6** | `/pm/config/adom/{adom}/obj/firewall/address6` | IPv6 addresses |
| 📁 **IPv4 Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp` | Address groups |
| 📁 **IPv6 Group** | `/pm/config/adom/{adom}/obj/firewall/addrgrp6` | IPv6 groups |

### 🏷️ Detailed Address Types

| Type | Description | Key Field | Example Value |
|:-----|:------------|:----------|:--------------|
| 📍 `ipmask` | IP + mask | `subnet` | `"192.168.1.0 255.255.255.0"` |
| 📍 `iprange` | IP range | `start-ip`, `end-ip` | `"192.168.1.100"` → `"192.168.1.200"` |
| 🌐 `fqdn` | Domain name | `fqdn` | `"example.com"` |
| 🃏 `wildcard` | Wildcard mask | `wildcard` | `"10.0.0.0 0.0.255.255"` |
| 🌍 `geography` | Country code | `country` | `"FR"`, `"US"`, `"DE"` |
| ☁️ `dynamic` | SDN connector | `sdn`, `filter` | AWS, Azure, GCP... |

<details>
<summary>📝 <b>JSON Example: Create an ipmask address</b></summary>

```json
{
  "method": "add",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address",
    "data": {
      "name": "SRV_WEB_01",
      "type": "ipmask",
      "subnet": "192.168.10.10 255.255.255.255",
      "comment": "Main web server"
    }
  }]
}
```

</details>

---

## 🔌 Services

> 🔧 **Ports and protocols definition**

| Type | Endpoint |
|:-----|:---------|
| ⚙️ **Custom Service** | `/pm/config/adom/{adom}/obj/firewall/service/custom` |
| 📁 **Service Group** | `/pm/config/adom/{adom}/obj/firewall/service/group` |
| 📂 **Category** | `/pm/config/adom/{adom}/obj/firewall/service/category` |

### 📊 Service Parameters

| Parameter | Description | Examples |
|:----------|:------------|:---------|
| `protocol` | Protocol type | `TCP/UDP/SCTP`, `ICMP`, `IP` |
| `tcp-portrange` | TCP ports | `"80"`, `"443"`, `"8000-9000"` |
| `udp-portrange` | UDP ports | `"53"`, `"161-162"` |
| `protocol-number` | IP protocol number | `47` (GRE), `50` (ESP) |

---

## 📅 Schedules

> ⏰ **Policy time scheduling**

| Type | Endpoint | Usage |
|:-----|:---------|:------|
| 📆 **One-time** | `/pm/config/adom/{adom}/obj/firewall/schedule/onetime` | Single date |
| 🔄 **Recurring** | `/pm/config/adom/{adom}/obj/firewall/schedule/recurring` | Weekly |
| 📁 **Group** | `/pm/config/adom/{adom}/obj/firewall/schedule/group` | Grouping |

---

## 🔀 NAT / VIP

> 🔄 **Network address translation**

| Type | Endpoint | Direction |
|:-----|:---------|:----------|
| 🔽 **VIP IPv4** | `/pm/config/adom/{adom}/obj/firewall/vip` | DNAT (inbound) |
| 🔽 **VIP IPv6** | `/pm/config/adom/{adom}/obj/firewall/vip6` | DNAT (inbound) |
| 📁 **VIP Group** | `/pm/config/adom/{adom}/obj/firewall/vipgrp` | Grouping |
| 🔼 **IP Pool IPv4** | `/pm/config/adom/{adom}/obj/firewall/ippool` | SNAT (outbound) |
| 🔼 **IP Pool IPv6** | `/pm/config/adom/{adom}/obj/firewall/ippool6` | SNAT (outbound) |
| 🔄 **Central SNAT** | `/pm/config/adom/{adom}/obj/firewall/central-snat-map` | Centralized NAT |

```
┌────────────┐                              ┌────────────┐
│  INTERNET  │                              │  INTERNAL  │
└─────┬──────┘                              └─────┬──────┘
      │                                           │
      │  ┌─────────────────────────────────┐     │
      │  │         FORTIGATE               │     │
      │  │                                 │     │
      ├──┤  VIP (DNAT)    ◄───── Inbound   │◄────┤
      │  │  203.0.113.10 → 192.168.10.10   │     │
      │  │                                 │     │
      │  │  IP Pool (SNAT) ────► Outbound  │◄────┤
      │  │  192.168.x.x → 203.0.113.x      │     │
      │  │                                 │     │
      │  └─────────────────────────────────┘     │
      │                                           │
```

---

## 🛡️ Security Profiles

> 🔒 **Advanced protection (UTM)**

| Profile | Endpoint | Protection |
|:--------|:---------|:-----------|
| 🦠 **Antivirus** | `/pm/config/adom/{adom}/obj/antivirus/profile` | Malware |
| 🌐 **Web Filter** | `/pm/config/adom/{adom}/obj/webfilter/profile` | Websites |
| 🔗 **URL Filter** | `/pm/config/adom/{adom}/obj/webfilter/urlfilter` | Specific URLs |
| 📱 **App Control** | `/pm/config/adom/{adom}/obj/application/list` | Applications |
| 📱 **App Group** | `/pm/config/adom/{adom}/obj/application/group` | App groups |
| 🛡️ **IPS** | `/pm/config/adom/{adom}/obj/ips/sensor` | Intrusions |
| 🔐 **SSL Inspect** | `/pm/config/adom/{adom}/obj/firewall/ssl-ssh-profile` | SSL inspection |
| 🌍 **DNS Filter** | `/pm/config/adom/{adom}/obj/dnsfilter/profile` | DNS queries |
| 📄 **DLP** | `/pm/config/adom/{adom}/obj/dlp/sensor` | Data leakage |

---

## 📜 Policies

> 🛡️ **Firewall security rules**

| Type | Endpoint |
|:-----|:---------|
| 📜 **Firewall Policy** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy` |
| 🔍 **Policy by ID** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy/{id}` |
| 📑 **Section** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy/section` |
| 🔒 **Security Policy** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/security-policy` |
| 📋 **Consolidated** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/consolidated/policy` |

### 📊 Policy Parameters

| Parameter | Type | Values |
|:----------|:-----|:-------|
| `name` | string | Rule name |
| `srcintf` | array | `["port1"]`, `["any"]` |
| `dstintf` | array | `["port2"]`, `["wan1"]` |
| `srcaddr` | array | `["all"]`, `["NET_SERVERS"]` |
| `dstaddr` | array | `["all"]`, `["VIP_WEB"]` |
| `service` | array | `["HTTP", "HTTPS"]` |
| `action` | string | `accept`, `deny`, `ipsec` |
| `logtraffic` | string | `disable`, `all`, `utm` |
| `nat` | string | `enable`, `disable` |
| `status` | string | `enable`, `disable` |

> ⚠️ **Warning!** `srcaddr`, `dstaddr`, `service` fields are **arrays** `["value"]`, not strings!

---

## 📦 Packages

> 📦 **Policy containers**

| Action | Method | Endpoint |
|:-------|:-------|:---------|
| 📋 List | `get` | `/pm/pkg/adom/{adom}` |
| 🔍 Details | `get` | `/pm/pkg/adom/{adom}/{pkg}` |
| ➕ Create | `add` | `/pm/pkg/adom/{adom}` |
| ❌ Delete | `delete` | `/pm/pkg/adom/{adom}/{pkg}` |
| 📑 Clone | `clone` | `/pm/pkg/adom/{adom}/{pkg}` |

---

## 💻 Devices

> 🖥️ **FortiGate management**

| Action | Method | Endpoint |
|:-------|:-------|:---------|
| 📋 All devices | `get` | `/dvmdb/device` |
| 📋 ADOM devices | `get` | `/dvmdb/adom/{adom}/device` |
| 🔍 Device details | `get` | `/dvmdb/device/{device}` |
| 📊 Device status | `get` | `/dvmdb/device/{device}/status` |
| 🔌 Interfaces | `get` | `/pm/config/device/{device}/global/system/interface` |
| ➕ Add device | `exec` | `/dvm/cmd/add/device` |
| ❌ Delete device | `exec` | `/dvm/cmd/del/device` |
| ✅ Authorize device | `exec` | `/dvm/cmd/update/device` |

---

## 🚀 Installation

> 📤 **Configuration deployment**

| Action | Method | Endpoint |
|:-------|:-------|:---------|
| 📤 **Install package** | `exec` | `/securityconsole/install/package` |
| 👁️ **Preview** | `exec` | `/securityconsole/install/preview` |
| ⚙️ **Device config** | `exec` | `/securityconsole/install/device` |
| 📊 **Install status** | `get` | `/task/task/{task_id}` |
| 🛑 **Cancel** | `exec` | `/securityconsole/cancel/install` |
| 🔄 **Reinstall** | `exec` | `/securityconsole/reinstall/package` |

---

## 📊 Tasks

> ⏳ **Asynchronous task tracking**

| Action | Method | Endpoint |
|:-------|:-------|:---------|
| 📋 List tasks | `get` | `/task/task` |
| 🔍 Task details | `get` | `/task/task/{task_id}` |
| 📜 Task lines | `get` | `/task/task/{task_id}/line` |
| 🛑 Cancel task | `exec` | `/task/task/{task_id}/stop` |
| ❌ Delete task | `delete` | `/task/task/{task_id}` |

### 🚦 Task States

| Code | State | Meaning |
|:-----|:------|:--------|
| `0` | ⏳ Pending | Waiting |
| `1` | 🔄 Running | In progress |
| `2` | ⏸️ Cancelling | Cancellation in progress |
| `3` | 🛑 Cancelled | Cancelled |
| `4` | ✅ **Done** | **Completed successfully** |
| `5` | ❌ **Error** | **Failed** |
| `6` | ⏸️ Aborting | Aborting in progress |
| `7` | 🛑 Aborted | Aborted |
| `8` | ⚠️ Warning | Completed with warnings |

---

## 🔍 Filters & Options

> 🎛️ **Customize your queries**

### Filtering

```json
{
  "filter": [
    ["name", "like", "NET_%"],
    ["type", "==", "ipmask"]
  ]
}
```

| Operator | Description | Example |
|:---------|:------------|:--------|
| `==` | Equal | `["name", "==", "SRV_01"]` |
| `!=` | Not equal | `["type", "!=", "fqdn"]` |
| `like` | Pattern (% = wildcard) | `["name", "like", "NET_%"]` |
| `!like` | Not like | `["name", "!like", "%_OLD"]` |
| `in` | In list | `["type", "in", ["ipmask", "iprange"]]` |
| `contain` | Contains | `["comment", "contain", "prod"]` |
| `>`, `<`, `>=`, `<=` | Comparison | `["policyid", ">", "10"]` |

### Field Selection

```json
{
  "fields": ["name", "subnet", "comment"]
}
```

> 💡 Returns only specified fields → lighter responses!

### Special Options

```json
{
  "option": ["loadsub", "devinfo", "get used"]
}
```

| Option | Description |
|:-------|:------------|
| `loadsub` | Load sub-objects |
| `devinfo` | Include device info |
| `get used` | See where object is used |
| `syntax` | Get syntax/schema |

### Pagination

```json
{
  "range": [0, 100]
}
```

> 📖 Returns elements 0 to 99 (100 elements)

### Sorting

```json
{
  "sortings": [{"name": 1}]
}
```

> ⬆️ `1` = Ascending | ⬇️ `-1` = Descending

---

## 📚 See Also

<table>
<tr>
<td align="center" width="20%">

🔧 **[cURL Examples](curl-examples.md)**

*CLI commands*

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

*Troubleshooting*

</td>
<td align="center" width="20%">

📖 **[JSON-RPC Concepts](../docs/01-concepts-json-rpc.md)**

*Understanding the API*

</td>
</tr>
</table>

---

<div align="center">

*Need an example? Check the [cURL guide](curl-examples.md)!* 🚀

</div>
