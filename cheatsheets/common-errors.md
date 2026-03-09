# ⚠️ FortiManager API Errors

<div align="center">

**Troubleshooting guide for JSON-RPC API**

*Quickly find the solution to your problem*

[📋 Cheatsheets](README.md) • [🔗 Endpoints](api-endpoints.md) • [🔧 cURL Examples](curl-examples.md)

---

</div>

## 🚨 Quick Diagnosis

> **Got an error?** Find it below and click to see the solution!

| Code | Error | Quick Solution |
|:----:|:------|:---------------|
| `-10147` | [No write permission](#-error--10147--no-write-permission) | 🔒 Lock the ADOM! |
| `-11` | [Session expired](#-error--11--session-expired) | 🔄 Reconnect |
| `-3` | [Object exists](#-error--3--object-already-exists) | 📝 Use `set` instead of `add` |
| `-2` | [Not found](#-error--2--object-not-found) | 🔍 Check the exact name |
| `-10` | [Object in use](#-error--10--object-in-use) | 🔗 Remove dependencies |
| `-6` | [Permission denied](#-error--6--permission-denied) | 👤 Check admin rights |
| `-20` | [Invalid JSON](#-error--20--invalid-json) | ✏️ Validate your JSON |
| `401` | [Unauthorized (HTTP)](#-http-error-401--unauthorized) | 🔑 Check API key |

---

## 📊 Error Code Table

| Code | Name | Description | Common Cause |
|:----:|:-----|:------------|:-------------|
| ✅ `0` | Success | Operation succeeded | - |
| ❌ `-1` | Generic Error | Non-specific error | See detailed message |
| 🔍 `-2` | Not Found | Object not found | Wrong name/ADOM/path |
| 📋 `-3` | Object Exists | Object already exists | Duplication |
| ⚙️ `-4` | Invalid Input | Incorrect parameter | Malformed data |
| 📐 `-5` | Invalid Value | Value out of range | Validation failed |
| 🔒 `-6` | Permission Denied | Access forbidden | Insufficient rights |
| 🔗 `-9` | Invalid URL | Endpoint doesn't exist | Typo |
| 📎 `-10` | Object In Use | Object referenced | Remove dependencies |
| 🔑 `-11` | Invalid Session | Auth failed | Session expired |
| 📝 `-20` | Invalid Syntax | Parse error | Malformed JSON |
| ❓ `-21` | Invalid Method | Unknown method | Typo |
| 🔒 `-10147` | No Write Permission | ADOM locked | Workspace mode |

---

## 🔒 Error `-10147` : No Write Permission

> 🚨 **This is the most common error!** It means Workspace Mode is enabled.

### 💬 Message received

```json
{
  "result": [{
    "status": {
      "code": -10147,
      "message": "no write permission"
    }
  }]
}
```

### 🎯 Cause

You're trying to modify objects **without having locked the ADOM** (workspace mode is enabled).

### ✅ Solution: Follow this workflow

```
┌──────────────────────────────────────────────────────────────────┐
│                     WORKSPACE MODE WORKFLOW                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│   1️⃣ LOCK          2️⃣ CHANGES         3️⃣ COMMIT        4️⃣ UNLOCK │
│   ┌─────┐          ┌─────────┐        ┌─────┐         ┌─────┐   │
│   │ 🔒  │   ───►   │  ✏️     │  ───►  │ 💾  │  ───►   │ 🔓  │   │
│   │LOCK │          │ADD/UPD/ │        │SAVE │         │FREE │   │
│   │ADOM │          │DELETE   │        │     │         │ADOM │   │
│   └─────┘          └─────────┘        └─────┘         └─────┘   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### 📝 Code to use

<table>
<tr>
<td width="50%">

**Step 1: Lock ADOM**

```json
{
  "method": "exec",
  "params": [{
    "url": "/dvmdb/adom/root/workspace/lock"
  }]
}
```

</td>
<td width="50%">

**Step 2: Your modifications...**

```json
{
  "method": "add",
  "params": [{
    "url": "/pm/config/adom/root/obj/...",
    "data": { ... }
  }]
}
```

</td>
</tr>
<tr>
<td width="50%">

**Step 3: Commit**

```json
{
  "method": "exec",
  "params": [{
    "url": "/dvmdb/adom/root/workspace/commit"
  }]
}
```

</td>
<td width="50%">

**Step 4: Unlock**

```json
{
  "method": "exec",
  "params": [{
    "url": "/dvmdb/adom/root/workspace/unlock"
  }]
}
```

</td>
</tr>
</table>

> 💡 **Tip:** Always unlock even in case of error, otherwise the ADOM stays locked!

---

## 🔑 Error `-11` : Session Expired

### 💬 Message received

```json
{
  "result": [{
    "status": {
      "code": -11,
      "message": "No permission for the resource"
    }
  }]
}
```

### 🎯 Possible causes

| Cause | Explanation |
|:------|:------------|
| ⏰ Timeout | Session inactive > 5 minutes |
| 🔄 Logout elsewhere | Disconnected from another session |
| 👥 Multi-login | Multiple connections with same account |

### ✅ Solutions

<table>
<tr>
<td width="50%">

#### 🔄 Option 1: Reconnect

```python
# Python - Automatic refresh
def ensure_session(fmg):
    try:
        fmg.get("/sys/status")
    except SessionError:
        fmg.login()  # Reconnect
```

</td>
<td width="50%">

#### 🔑 Option 2: Bearer Token (Recommended)

```bash
# Never expires!
curl -H "Authorization: Bearer $API_KEY" ...
```

</td>
</tr>
</table>

> 💡 **Recommendation:** **Always** use a Bearer Token for automated scripts!

---

## 🔑 HTTP Error 401 : Unauthorized

### 💬 Message received

```
HTTP/1.1 401 Unauthorized
{"error": "Unauthorized"}
```

### 🎯 Possible causes

- ❌ Incorrect API key
- ❌ API user deleted/disabled
- ❌ Key regenerated

### ✅ Verification checklist

```
□ 1. Check API key in FortiManager GUI
     System Settings → Administrators → API User

□ 2. Check header format
     ✓ Correct: "Authorization: Bearer abc123..."
     ✗ Wrong:   "Authorization: abc123..."
     ✗ Wrong:   "Bearer: abc123..."

□ 3. Check that API user is active

□ 4. Regenerate key if necessary
```

---

## 📋 Error `-3` : Object Already Exists

### 💬 Message received

```json
{
  "result": [{
    "status": {
      "code": -3,
      "message": "Object already exists"
    }
  }]
}
```

### 🎯 Cause

You're using `add` for an object that already exists.

### ✅ Solutions

<table>
<tr>
<td width="50%">

#### 📝 Solution 1: Use `set`

`set` = create OR replace

```json
{
  "method": "set",  // ← Not "add"
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address",
    "data": {
      "name": "MY_OBJECT",
      ...
    }
  }]
}
```

</td>
<td width="50%">

#### 🔄 Solution 2: Upsert Pattern

```python
# Python - Create or Update
def upsert_address(fmg, name, data):
    code, _ = fmg.add(url, data)

    if code == -3:  # Already exists
        code, _ = fmg.update(
            f"{url}/{name}",
            data
        )

    return code == 0
```

</td>
</tr>
</table>

> 💡 **Tip:** Use `set` for idempotent operations!

---

## 🔍 Error `-2` : Object Not Found

### 💬 Message received

```json
{
  "result": [{
    "status": {
      "code": -2,
      "message": "Object not found"
    }
  }]
}
```

### 🎯 Common causes

| Cause | Solution |
|:------|:---------|
| Incorrect name | Names are **case-sensitive**! |
| Wrong ADOM | Check `{adom}` in URL |
| Object deleted | Object no longer exists |
| Wrong type | `address` vs `address6` |

### ✅ Verification checklist

```
□ 1. Is the name EXACTLY the same? (case-sensitive)
     "SRV_Web_01" ≠ "srv_web_01" ≠ "SRV_WEB_01"

□ 2. Right ADOM?
     /pm/config/adom/ROOT/...  ← Check here

□ 3. Right object type?
     /obj/firewall/address      ← IPv4
     /obj/firewall/address6     ← IPv6

□ 4. Does the object really exist?
```

### 🔎 Search for the object

```bash
# Search with pattern
curl -X POST "$FMG/jsonrpc" -d '{
  "method": "get",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address",
    "filter": [["name", "like", "%SEARCHTERM%"]]
  }]
}'
```

---

## 📎 Error `-10` : Object In Use

### 💬 Message received

```json
{
  "result": [{
    "status": {
      "code": -10,
      "message": "Object is in use"
    }
  }]
}
```

### 🎯 Cause

The object is referenced in:
- 📜 A policy
- 📁 A group
- 🔀 A NAT rule
- 📦 Another object

### ✅ Solution: Find dependencies

**Step 1: Identify what's using the object**

```json
{
  "method": "get",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address/MY_OBJECT",
    "option": ["get used"]
  }]
}
```

**Response:**

```json
{
  "data": {
    "name": "MY_OBJECT",
    "_used_by": [
      {"path": "/pkg/default/firewall/policy/10", "name": "Policy-Web"},
      {"path": "/obj/firewall/addrgrp/GRP_SERVERS", "name": "GRP_SERVERS"}
    ]
  }
}
```

**Step 2: Deletion workflow**

```
┌─────────────────────────────────────────────────────┐
│            OBJECT DELETION ORDER                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│   1️⃣ Remove from policies                          │
│      └─► Policy-Web uses MY_OBJECT                 │
│                                                     │
│   2️⃣ Remove from groups                            │
│      └─► GRP_SERVERS contains MY_OBJECT            │
│                                                     │
│   3️⃣ Delete the object                             │
│      └─► MY_OBJECT can now be deleted              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 🔒 Error `-6` : Permission Denied

### 💬 Message received

```json
{
  "result": [{
    "status": {
      "code": -6,
      "message": "No permission for the resource"
    }
  }]
}
```

### 🎯 Possible causes

| Cause | Check |
|:------|:------|
| Read-only profile | Profile doesn't have write rights |
| Unauthorized ADOM | Admin doesn't have access to this ADOM |
| Protected resource | Some objects are read-only |

### ✅ Required permissions by operation

| Operation | Required Permission |
|:----------|:-------------------|
| 📖 Read objects | *Policy Objects (Read)* |
| ✏️ Modify objects | *Policy Objects (Read/Write)* |
| 📤 Install policies | *Policy Package + Device Manager* |
| 💻 Manage devices | *Device Manager (Read/Write)* |
| 🔧 Administration | *Super_User or equivalent* |

### 🔎 Check permissions

```
FortiManager GUI:
├── System Settings
│   └── Administrators
│       └── [Your user]
│           └── Admin Profile → Check rights
```

---

## 📝 Error `-20` : Invalid JSON

### 💬 Message received

```json
{
  "result": [{
    "status": {
      "code": -20,
      "message": "Invalid JSON syntax"
    }
  }]
}
```

### 🎯 Common errors

| Error | Incorrect Example | Correct Example |
|:------|:------------------|:----------------|
| Trailing comma | `{"a": 1,}` | `{"a": 1}` |
| Missing quotes | `{name: "test"}` | `{"name": "test"}` |
| Single quotes | `{'name': 'test'}` | `{"name": "test"}` |
| Missing comma | `{"a": 1 "b": 2}` | `{"a": 1, "b": 2}` |

### ✅ Solutions

<table>
<tr>
<td width="50%">

#### 🔍 Validate on command line

```bash
# With jq
echo '{"your": "json"}' | jq .

# If error, jq shows the line
```

</td>
<td width="50%">

#### 📝 Use a heredoc

```bash
curl -X POST "$URL" -d "$(cat <<'EOF'
{
  "id": 1,
  "method": "get",
  "params": [{"url": "..."}]
}
EOF
)"
```

</td>
</tr>
</table>

### 🛠️ JSON validation tools

| Tool | Usage |
|:-----|:------|
| `jq .` | CLI validation |
| [jsonlint.com](https://jsonlint.com) | Online validation |
| VSCode | Syntax highlighting |

---

## 📐 Error `-5` : Invalid Value

### 💬 Message received

```json
{
  "result": [{
    "status": {
      "code": -5,
      "message": "Invalid value for field: subnet"
    }
  }]
}
```

### 🎯 Common errors by field

| Field | ❌ Incorrect | ✅ Correct |
|:------|:-------------|:-----------|
| `subnet` | `"10.0.0.0/24"` | `"10.0.0.0 255.255.255.0"` |
| `action` | `"allow"` | `"accept"` |
| `srcaddr` | `"all"` | `["all"]` |
| `logtraffic` | `"enable"` | `"all"` |
| `nat` | `true` | `"enable"` |

> ⚠️ **Watch out for arrays!** `srcaddr`, `dstaddr`, `service` are **arrays** `["value"]`

### ✅ Get correct syntax

```json
{
  "method": "get",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address",
    "option": ["syntax"]
  }]
}
```

---

## 🔌 Connection Errors

### ⏰ Timeout

```
Error: Connection timed out after 30000ms
```

**Solutions:**

```bash
# Test connectivity
curl -k -v https://$FMG_HOST/jsonrpc

# Check port
nc -zv $FMG_HOST 443

# Increase timeout (Python)
requests.post(url, timeout=120)
```

### 🔐 SSL Error

```
Error: SSL certificate problem: unable to get local issuer certificate
```

**Solutions:**

| Environment | Solution |
|:------------|:---------|
| 🧪 Lab/Dev | Disable verification |
| 🏭 Production | Add CA certificate |

```bash
# Lab (insecure)
curl -k https://$FMG_HOST/jsonrpc

# Production (secure)
curl --cacert fmg-ca.pem https://$FMG_HOST/jsonrpc
```

---

## 🛠️ Debugging Tips

### 📋 Enable detailed logs

<table>
<tr>
<td width="50%">

**cURL**

```bash
curl -v -X POST https://$FMG/jsonrpc \
  -H "Content-Type: application/json" \
  -d '{...}'
```

</td>
<td width="50%">

**Python**

```python
import logging
import http.client

http.client.HTTPConnection.debuglevel = 1
logging.basicConfig(level=logging.DEBUG)
```

</td>
</tr>
</table>

### 🔍 Examine complete response

```python
import json

response = requests.post(url, json=payload)
print(json.dumps(response.json(), indent=2))

# Check each result
for r in response.json().get('result', []):
    if r['status']['code'] != 0:
        print(f"❌ Error: {r['status']}")
    else:
        print(f"✅ Success")
```

---

## ✅ Quick Troubleshooting Checklist

Check in order until you find the problem:

```
□ 1. Valid credentials / API key?
     → Test GET /sys/status

□ 2. Correct ADOM?
     → Check exact name

□ 3. Exact object names? (case-sensitive)
     → "SRV_Web" ≠ "srv_web"

□ 4. Valid JSON?
     → Test with: echo '...' | jq .

□ 5. Correct URL?
     → Check /pm/config vs /dvmdb vs /sys

□ 6. Right method? (get/add/set/update/delete)
     → add = create | set = create or replace

□ 7. Required fields present?
     → Use option: ["syntax"]

□ 8. Arrays for srcaddr/dstaddr/service?
     → ["value"] not "value"

□ 9. Sufficient admin permissions?
     → Check admin profile

□ 10. Network connectivity OK?
      → curl -k https://$FMG/jsonrpc
```

---

## 📚 See Also

<table>
<tr>
<td align="center" width="20%">

🔗 **[API Endpoints](api-endpoints.md)**

*URL reference*

</td>
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

📖 **[Authentication](../docs/02-authentication.md)**

*Detailed guide*

</td>
</tr>
</table>

---

<div align="center">

*An error not documented here? Check the complete message and consult the [documentation](../docs/README.md)!* 🔍

</div>
