# JSON-RPC API Concepts

> **Master the fundamentals of FortiManager's JSON-RPC protocol.**

---

## Introduction

FortiManager uses a **JSON-RPC** API, not a traditional REST API. Understanding this difference is essential for effective API automation.

---

## REST vs JSON-RPC

| Aspect | REST API | JSON-RPC (FortiManager) |
|--------|----------|-------------------------|
| **Endpoint** | Multiple URLs (`/users`, `/posts`) | Single endpoint (`/jsonrpc`) |
| **HTTP Method** | GET, POST, PUT, DELETE | Always POST |
| **Routing** | Via URL path | Via `method` field in body |
| **Resource** | In URL path | In `url` field of payload |
| **Status** | HTTP status code (200, 404, etc.) | `status.code` field in response |

### Why JSON-RPC?

JSON-RPC provides:
- **Simplified proxy/firewall rules** - Only one endpoint to allow
- **Batch operations** - Multiple operations in single request
- **Consistent error handling** - All errors in response body
- **Protocol independence** - Works over HTTP, WebSocket, etc.

---

## Request Structure

Every FortiManager API request follows this format:

```json
{
    "id": 1,
    "method": "get",
    "params": [
        {
            "url": "/pm/config/adom/root/obj/firewall/address",
            "filter": [["name", "like", "NET_%"]],
            "fields": ["name", "subnet", "comment"]
        }
    ],
    "session": "your-session-token"
}
```

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | Integer | Request identifier for correlation |
| `method` | String | Operation to perform (get, add, set, etc.) |
| `params` | Array | Array containing request parameters |

### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `session` | String | Session token (not needed with Bearer auth) |
| `verbose` | Integer | Enable verbose output (1 = enabled) |

### The `params` Array

Each element in `params` is an object with:

| Field | Description |
|-------|-------------|
| `url` | API endpoint path |
| `data` | Object data for create/update operations |
| `filter` | Query filters for read operations |
| `fields` | Limit returned fields |
| `option` | Additional options (e.g., `["loadsub"]`) |

---

## Available Methods

| Method | Description | REST Equivalent | When to Use |
|--------|-------------|-----------------|-------------|
| `get` | Read objects | GET | Retrieve data |
| `add` | Create new object | POST | Create new, fail if exists |
| `set` | Create or replace | PUT | Create or overwrite entirely |
| `update` | Partial update | PATCH | Modify specific fields |
| `delete` | Remove object | DELETE | Delete object |
| `exec` | Execute action | POST (action) | Login, install, tasks |
| `move` | Reorder in list | - | Change policy position |
| `clone` | Duplicate object | - | Copy existing object |

### `set` vs `update` - Important Distinction

```
┌─────────────────────────────────────────────────────────────────────┐
│ SET (Replace)                                                       │
│                                                                     │
│ Before: { name: "A", subnet: "10.0.0.0/8", comment: "Old" }        │
│ Request: set { name: "A", subnet: "192.168.0.0/16" }               │
│ After:  { name: "A", subnet: "192.168.0.0/16", comment: "" }       │
│                                                                     │
│ Comment is RESET because it wasn't specified                        │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ UPDATE (Partial)                                                    │
│                                                                     │
│ Before: { name: "A", subnet: "10.0.0.0/8", comment: "Old" }        │
│ Request: update { subnet: "192.168.0.0/16" }                        │
│ After:  { name: "A", subnet: "192.168.0.0/16", comment: "Old" }    │
│                                                                     │
│ Comment is PRESERVED because only subnet was updated                │
└─────────────────────────────────────────────────────────────────────┘
```

**Best Practice**: Use `update` for modifications, `set` only when you want to replace entirely.

---

## URL Structure

FortiManager URLs follow a hierarchical pattern:

```
/pm/config/adom/{adom}/obj/{type}/{subtype}/{object_name}
│         │          │        │
│         │          │        └── Object category
│         │          └── "obj" for objects, "pkg" for packages
│         └── Administrative domain
└── Configuration scope ("pm" = policy manager)
```

### Common URL Patterns

| Category | URL Pattern | Example |
|----------|-------------|---------|
| **Objects** | `/pm/config/adom/{adom}/obj/firewall/{type}` | `/pm/config/adom/root/obj/firewall/address` |
| **Packages** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy` | `/pm/config/adom/root/pkg/default/firewall/policy` |
| **Devices** | `/dvmdb/adom/{adom}/device` | `/dvmdb/adom/root/device` |
| **System** | `/sys/{action}` | `/sys/status`, `/sys/login/user` |
| **Tasks** | `/task/task/{id}` | `/task/task/123` |

### URL Examples

| URL | Description |
|-----|-------------|
| `/pm/config/adom/root/obj/firewall/address` | All IPv4 addresses |
| `/pm/config/adom/root/obj/firewall/address/MY_ADDR` | Specific address |
| `/pm/config/adom/root/obj/firewall/address6` | All IPv6 addresses |
| `/pm/config/adom/root/obj/firewall/addrgrp` | Address groups |
| `/pm/config/adom/root/obj/firewall/service/custom` | Custom services |
| `/pm/config/adom/root/obj/firewall/service/group` | Service groups |
| `/pm/config/adom/root/obj/firewall/vip` | Virtual IPs |
| `/pm/config/adom/root/obj/firewall/ippool` | IP Pools |
| `/pm/config/adom/root/pkg/default/firewall/policy` | Firewall policies |
| `/securityconsole/install/package` | Install policy package |

---

## Response Structure

All responses follow this format:

```json
{
    "id": 1,
    "result": [
        {
            "status": {
                "code": 0,
                "message": "OK"
            },
            "url": "/pm/config/adom/root/obj/firewall/address",
            "data": [
                {
                    "name": "NET_SERVERS",
                    "type": "ipmask",
                    "subnet": ["10.10.10.0", "255.255.255.0"],
                    "comment": "Server network"
                }
            ]
        }
    ]
}
```

### Response Fields

| Field | Description |
|-------|-------------|
| `id` | Matches request ID (for correlation) |
| `result` | Array of results (one per param in request) |
| `result[].status.code` | 0 = success, negative = error |
| `result[].status.message` | Human-readable status |
| `result[].data` | Returned data (for get operations) |
| `result[].url` | URL that was processed |

---

## Status Codes

| Code | Meaning | Description |
|------|---------|-------------|
| **0** | Success | Operation completed |
| **-1** | Generic error | Check message for details |
| **-2** | Object not found | Object doesn't exist |
| **-3** | Object exists | Object already exists (use update) |
| **-6** | Permission denied | User lacks required permissions |
| **-10** | Object in use | Remove references before delete |
| **-11** | Invalid session | Session expired or invalid |
| **-20** | Invalid URL | Endpoint path is wrong |

### Error Handling Pattern

```python
code = response["result"][0]["status"]["code"]

if code == 0:
    print("Success")
elif code == -2:
    print("Object not found - check name")
elif code == -3:
    print("Already exists - use update instead")
elif code == -6:
    print("Permission denied - check user rights")
elif code == -10:
    print("In use - remove references first")
elif code == -11:
    print("Session expired - re-authenticate")
else:
    print(f"Error {code}: {response['result'][0]['status']['message']}")
```

---

## Query Options

### Filtering

Filter results using comparison operators:

```json
{
    "filter": [
        ["name", "like", "NET_%"]
    ]
}
```

**Available Operators:**

| Operator | Description | Example |
|----------|-------------|---------|
| `==` | Equals | `["name", "==", "exact_name"]` |
| `!=` | Not equals | `["type", "!=", "fqdn"]` |
| `like` | Wildcard match | `["name", "like", "SRV_%"]` |
| `!like` | Not matching | `["name", "!like", "TEST_%"]` |
| `in` | In list | `["type", "in", ["ipmask", "fqdn"]]` |
| `contain` | Contains substring | `["comment", "contain", "server"]` |
| `>` | Greater than | `["policyid", ">", 100]` |
| `<` | Less than | `["policyid", "<", 50]` |

**Multiple Filters (AND logic):**

```json
{
    "filter": [
        ["name", "like", "NET_%"],
        ["type", "==", "ipmask"]
    ]
}
```

### Field Selection

Limit returned fields to reduce response size:

```json
{
    "fields": ["name", "subnet", "comment"]
}
```

### Loading Sub-objects

Include nested objects in response:

```json
{
    "option": ["loadsub"],
    "loadsub": 1
}
```

### Sorting

Order results:

```json
{
    "sortings": [
        {"name": 1}
    ]
}
```

(1 = ascending, -1 = descending)

### Pagination

For large datasets:

```json
{
    "range": [0, 50]
}
```

(Start index, count)

---

## Complete Examples

### Example 1: List Filtered Addresses

**Request:**
```json
{
    "id": 1,
    "method": "get",
    "params": [
        {
            "url": "/pm/config/adom/root/obj/firewall/address",
            "filter": [["name", "like", "SRV_%"]],
            "fields": ["name", "subnet", "comment"],
            "sortings": [{"name": 1}]
        }
    ],
    "session": "abc123..."
}
```

**Response:**
```json
{
    "id": 1,
    "result": [
        {
            "status": {"code": 0, "message": "OK"},
            "data": [
                {"name": "SRV_DB_01", "subnet": ["10.10.20.1", "255.255.255.255"], "comment": "Database"},
                {"name": "SRV_WEB_01", "subnet": ["10.10.10.1", "255.255.255.255"], "comment": "Web Server"}
            ]
        }
    ]
}
```

### Example 2: Create Address

**Request:**
```json
{
    "id": 2,
    "method": "add",
    "params": [
        {
            "url": "/pm/config/adom/root/obj/firewall/address",
            "data": {
                "name": "SRV_NEW_01",
                "type": "ipmask",
                "subnet": "192.168.100.10 255.255.255.255",
                "comment": "New Server"
            }
        }
    ],
    "session": "abc123..."
}
```

**Response:**
```json
{
    "id": 2,
    "result": [
        {
            "status": {"code": 0, "message": "OK"},
            "url": "/pm/config/adom/root/obj/firewall/address"
        }
    ]
}
```

### Example 3: Update Address

**Request:**
```json
{
    "id": 3,
    "method": "update",
    "params": [
        {
            "url": "/pm/config/adom/root/obj/firewall/address/SRV_NEW_01",
            "data": {
                "comment": "Updated comment - Production server"
            }
        }
    ],
    "session": "abc123..."
}
```

### Example 4: Delete Address

**Request:**
```json
{
    "id": 4,
    "method": "delete",
    "params": [
        {
            "url": "/pm/config/adom/root/obj/firewall/address/SRV_NEW_01"
        }
    ],
    "session": "abc123..."
}
```

### Example 5: Create Firewall Policy

**Request:**
```json
{
    "id": 5,
    "method": "add",
    "params": [
        {
            "url": "/pm/config/adom/root/pkg/default/firewall/policy",
            "data": {
                "name": "Allow-Web-Traffic",
                "srcintf": ["port1"],
                "dstintf": ["port2"],
                "srcaddr": ["all"],
                "dstaddr": ["SRV_WEB_01"],
                "service": ["HTTP", "HTTPS"],
                "action": "accept",
                "logtraffic": "all",
                "nat": "enable"
            }
        }
    ],
    "session": "abc123..."
}
```

---

## Batch Requests

Send multiple operations in one request:

```json
{
    "id": 1,
    "method": "add",
    "params": [
        {
            "url": "/pm/config/adom/root/obj/firewall/address",
            "data": {"name": "NET_A", "type": "ipmask", "subnet": "10.0.0.0 255.0.0.0"}
        },
        {
            "url": "/pm/config/adom/root/obj/firewall/address",
            "data": {"name": "NET_B", "type": "ipmask", "subnet": "172.16.0.0 255.255.0.0"}
        },
        {
            "url": "/pm/config/adom/root/obj/firewall/address",
            "data": {"name": "NET_C", "type": "ipmask", "subnet": "192.168.0.0 255.255.255.0"}
        }
    ],
    "session": "abc123..."
}
```

Response contains status for each operation:

```json
{
    "id": 1,
    "result": [
        {"status": {"code": 0, "message": "OK"}, "url": "..."},
        {"status": {"code": 0, "message": "OK"}, "url": "..."},
        {"status": {"code": -3, "message": "Object exists"}, "url": "..."}
    ]
}
```

---

## Best Practices

### 1. Always Check Status Code

```python
if response["result"][0]["status"]["code"] != 0:
    raise Exception(response["result"][0]["status"]["message"])
```

### 2. Use Unique Request IDs

```python
import uuid
request_id = int(uuid.uuid4().int & 0xFFFFFFFF)
```

### 3. Filter and Limit Fields

```json
{
    "filter": [["type", "==", "ipmask"]],
    "fields": ["name", "subnet"]
}
```

### 4. Handle Pagination for Large Datasets

```python
offset = 0
batch_size = 100
all_data = []

while True:
    response = fmg.get(url, range=[offset, batch_size])
    data = response.get("data", [])
    if not data:
        break
    all_data.extend(data)
    offset += batch_size
```

### 5. Use Transactions When Available

For critical operations, wrap in workspace lock/unlock (if workspace mode enabled).

---

## See Also

| Document | Description |
|----------|-------------|
| [02-authentication.md](02-authentication.md) | Authentication methods |
| [../cheatsheets/api-endpoints.md](../cheatsheets/api-endpoints.md) | Endpoint reference |
| [../cheatsheets/common-errors.md](../cheatsheets/common-errors.md) | Error codes |

---

**Next:** Learn about [Authentication Methods](02-authentication.md).
