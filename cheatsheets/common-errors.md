# Common FortiManager API Errors

> **Troubleshooting guide for FortiManager JSON-RPC API errors.**

---

## Error Code Reference

| Code | Name | Description | Common Cause |
|------|------|-------------|--------------|
| **0** | Success | Operation completed | - |
| **-1** | Generic Error | Unspecified error | Check message for details |
| **-2** | Object Not Found | Object doesn't exist | Wrong name, ADOM, or path |
| **-3** | Object Exists | Duplicate object | Object already created |
| **-4** | Invalid Input | Bad parameter | Malformed data |
| **-5** | Invalid Value | Value out of range | Parameter validation failed |
| **-6** | Permission Denied | Access forbidden | Insufficient privileges |
| **-9** | Invalid URL | Endpoint not found | Typo in URL path |
| **-10** | Object In Use | Referenced elsewhere | Remove dependencies first |
| **-11** | Invalid Session | Auth failure | Session expired or invalid |
| **-20** | Invalid Syntax | JSON parse error | Malformed JSON body |
| **-21** | Invalid Method | Unknown method | Typo in method name |
| **-10147** | No Write Permission | ADOM locked (workspace) | Lock ADOM before changes |

---

## Workspace Mode Errors

### No Write Permission (-10147)

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

**Causes:**
- Trying to modify objects in a locked ADOM (workspace mode enabled)
- ADOM not locked before making changes

**Solutions:**

```json
// 1. Lock ADOM before changes
{
  "method": "exec",
  "params": [{
    "url": "/dvmdb/adom/root/workspace/lock"
  }]
}

// 2. Make your changes...

// 3. Commit changes
{
  "method": "exec",
  "params": [{
    "url": "/dvmdb/adom/root/workspace/commit"
  }]
}

// 4. Unlock ADOM
{
  "method": "exec",
  "params": [{
    "url": "/dvmdb/adom/root/workspace/unlock"
  }]
}
```

**Workflow:**
```
Lock ADOM → Make Changes → Commit → Unlock ADOM
```

---

## Authentication Errors

### Session Expired (-11)

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

**Causes:**
- Session token expired (default: 5 minutes inactivity)
- Token was invalidated (logout called elsewhere)
- Multiple logins with same credentials

**Solutions:**

```python
# Python: Implement session refresh
def ensure_session(fmg):
    try:
        fmg.get("/sys/status")
    except SessionError:
        fmg.login()

# Or use Bearer token (no expiration)
fmg = FortiManager(host, apikey="your_api_key")
```

```powershell
# PowerShell: Handle in catch block
try {
    $result = Invoke-FMGRequest -Session $session -Method "get" -Url $url
}
catch {
    if ($_.Exception -match "-11") {
        $session = Login-FortiManager
        $result = Invoke-FMGRequest -Session $session -Method "get" -Url $url
    }
}
```

### Invalid API Key (HTTP 401)

```
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{"error": "Unauthorized"}
```

**Causes:**
- API key is incorrect
- API user was deleted or disabled
- API key was regenerated

**Solutions:**
1. Verify the API key in FortiManager GUI
2. Check if the API user still exists
3. Regenerate the API key if necessary
4. Verify header format: `Authorization: Bearer <key>`

### Bad Credentials (-1)

```json
{
  "result": [{
    "status": {
      "code": -1,
      "message": "Invalid username or password"
    }
  }]
}
```

**Causes:**
- Wrong username or password
- Admin account locked
- Admin account expired

**Solutions:**
1. Verify credentials
2. Check admin account status in FMG GUI
3. Reset password if needed

---

## Object Errors

### Object Already Exists (-3)

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

**Causes:**
- Trying to `add` an existing object
- Name conflict in same scope

**Solutions:**

```python
# Python: Create-or-update pattern
def upsert_address(fmg, name, data):
    code, _ = fmg.add(url, data)
    if code == -3:  # Already exists
        code, _ = fmg.update(f"{url}/{name}", data)
    return code == 0
```

```json
// Use 'set' instead of 'add' (creates or replaces)
{
  "method": "set",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address",
    "data": {...}
  }]
}
```

### Object Not Found (-2)

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

**Causes:**
- Object name is incorrect (case-sensitive!)
- Object is in different ADOM
- Object was deleted
- Typo in URL path

**Solutions:**

```bash
# Verify object exists
curl -X POST "$FMG_URL" -d '{
  "method": "get",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address",
    "filter": [["name", "like", "%SEARCHTERM%"]]
  }],
  "session": "..."
}'
```

**Checklist:**
- [ ] Object name matches exactly (case-sensitive)
- [ ] Correct ADOM specified
- [ ] URL path is correct
- [ ] Object type is correct (address vs address6)

### Object In Use (-10)

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

**Causes:**
- Address referenced in policy
- Address used in address group
- Service used in service group
- Object referenced elsewhere

**Solutions:**

```json
// Find what's using the object
{
  "method": "get",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address/MY_ADDR",
    "option": ["get used"]
  }]
}
```

**Response shows references:**
```json
{
  "data": {
    "name": "MY_ADDR",
    "_used_by": [
      {"path": "/pkg/default/firewall/policy/10", "name": "policy-10"}
    ]
  }
}
```

**Resolution order:**
1. Find all references using `"option": ["get used"]`
2. Remove object from policies/groups
3. Delete the object

---

## Syntax & Validation Errors

### Invalid JSON (-20)

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

**Causes:**
- Missing quotes around strings
- Trailing commas
- Missing commas between fields
- Unescaped special characters
- Wrong encoding

**Solutions:**

```bash
# Validate JSON before sending
echo '{"your": "json"}' | jq .

# Use heredoc for complex JSON
curl -X POST "$URL" -d "$(cat <<'EOF'
{
  "id": 1,
  "method": "add",
  "params": [{"url": "...", "data": {...}}]
}
EOF
)"
```

### Missing Parameter

```json
{
  "result": [{
    "status": {
      "code": -1,
      "message": "Missing required parameter: name"
    }
  }]
}
```

**Solutions:**
1. Check required fields for object type
2. Refer to API documentation
3. Use `"option": ["syntax"]` to get field requirements:

```json
{
  "method": "get",
  "params": [{
    "url": "/pm/config/adom/root/obj/firewall/address",
    "option": ["syntax"]
  }]
}
```

### Invalid Value (-5)

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

**Common mistakes:**

| Field | Wrong | Correct |
|-------|-------|---------|
| **subnet** | `"10.0.0.0/24"` | `"10.0.0.0 255.255.255.0"` |
| **action** | `"allow"` | `"accept"` |
| **srcaddr** | `"all"` | `["all"]` |
| **logtraffic** | `"enable"` | `"all"` |

---

## Permission Errors

### Permission Denied (-6)

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

**Causes:**
- Admin profile lacks required permissions
- ADOM access not granted
- Read-only profile trying to write

**Solutions:**
1. Check admin profile in FMG GUI
2. Verify ADOM access permissions
3. Ensure write permissions for modify operations

**Required permissions by operation:**

| Operation | Required Permission |
|-----------|---------------------|
| **Read objects** | *Policy Objects (Read)* |
| **Modify objects** | *Policy Objects (Read/Write)* |
| **Install policies** | *Policy Package + Device Manager* |
| **Manage devices** | *Device Manager (Read/Write)* |

---

## Installation Errors

### Device Not Found

```json
{
  "result": [{
    "status": {
      "code": -2,
      "message": "device not found"
    }
  }]
}
```

**Causes:**
- Device name incorrect
- Device not in specified ADOM
- Device not authorized

**Solutions:**

```json
// List devices to verify name
{
  "method": "get",
  "params": [{
    "url": "/dvmdb/adom/root/device",
    "fields": ["name", "hostname", "conn_status"]
  }]
}
```

### Package Not Found

```json
{
  "result": [{
    "status": {
      "code": -2,
      "message": "pkg not found"
    }
  }]
}
```

**Solutions:**

```json
// List packages to verify name
{
  "method": "get",
  "params": [{
    "url": "/pm/pkg/adom/root"
  }]
}
```

### Installation Failed

**Check task status:**

```json
{
  "method": "get",
  "params": [{
    "url": "/task/task/12345"
  }]
}
```

**Task line details:**

```json
{
  "method": "get",
  "params": [{
    "url": "/task/task/12345/line",
    "fields": ["detail", "state", "progress"]
  }]
}
```

---

## Connection Errors

### Connection Timeout

```
Error: Connection timed out after 30000ms
```

**Causes:**
- Network connectivity issues
- Firewall blocking port 443
- FortiManager not reachable

**Solutions:**

```bash
# Test connectivity
curl -k -v https://$FMG_HOST/jsonrpc

# Check port
nc -zv $FMG_HOST 443

# Increase timeout
requests.post(url, timeout=120)
```

### SSL Certificate Error

```
Error: SSL certificate problem: unable to get local issuer certificate
```

**Solutions:**

| Environment | Solution |
|-------------|----------|
| **Lab/Dev** | *Disable verification* |
| **Production** | *Add FMG CA certificate* |

```python
# Python (Lab only!)
requests.post(url, verify=False)

# Or with CA cert
requests.post(url, verify='/path/to/fmg-ca.pem')
```

```powershell
# PowerShell 7+
Invoke-RestMethod -Uri $url -SkipCertificateCheck
```

```bash
# cURL
curl -k https://$FMG_HOST/jsonrpc  # Insecure
curl --cacert fmg-ca.pem https://$FMG_HOST/jsonrpc  # Secure
```

---

## Debugging Tips

### Enable Debug Logging

**Python:**
```python
import logging
import http.client

# Enable HTTP debug
http.client.HTTPConnection.debuglevel = 1
logging.basicConfig(level=logging.DEBUG)

# Or for requests library
import requests
from requests_toolbelt.utils import dump

response = requests.post(url, json=payload)
print(dump.dump_all(response).decode('utf-8'))
```

**PowerShell:**
```powershell
$env:FMG_DEBUG = "true"

# Or use Invoke-WebRequest with -Verbose
Invoke-WebRequest -Uri $url -Method Post -Body $body -Verbose
```

**cURL:**
```bash
curl -v -X POST https://$FMG_HOST/jsonrpc \
  -H "Content-Type: application/json" \
  -d '{...}'
```

### Check Full Response

Always examine the complete response:

```python
import json

response = requests.post(url, json=payload)
print(json.dumps(response.json(), indent=2))

# Check for nested error details
result = response.json()
for r in result.get('result', []):
    if r['status']['code'] != 0:
        print(f"Error: {r['status']}")
```

### Validate Request Structure

```json
// Minimal valid request
{
  "id": 1,
  "method": "get",
  "params": [{"url": "/sys/status"}],
  "session": "your_session_token"
}

// Required fields:
// - id: integer
// - method: string
// - params: array of objects
// - session OR Authorization header
```

---

## Quick Troubleshooting Checklist

```
[ ] 1. Check credentials/API key
[ ] 2. Verify ADOM is correct
[ ] 3. Confirm object names (case-sensitive)
[ ] 4. Validate JSON syntax
[ ] 5. Check URL path spelling
[ ] 6. Verify method name (get/add/set/update/delete)
[ ] 7. Confirm required fields are present
[ ] 8. Check array fields are arrays ["value"]
[ ] 9. Review admin permissions
[ ] 10. Test network connectivity
```

---

## See Also

| Resource | Link |
|----------|------|
| **API Endpoints** | [api-endpoints.md](api-endpoints.md) |
| **cURL Examples** | [curl-examples.md](curl-examples.md) |
| **Authentication** | [../docs/02-authentication.md](../docs/02-authentication.md) |
