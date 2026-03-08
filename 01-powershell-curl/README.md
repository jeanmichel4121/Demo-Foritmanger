# Level 1: PowerShell + cURL

> **Learn the fundamentals of FortiManager JSON-RPC API through raw HTTP requests.**

---

## Overview

This section teaches you the raw mechanics of the FortiManager API. By working directly with HTTP requests, you'll understand:

- How JSON-RPC differs from REST APIs
- The exact structure of API requests and responses
- Authentication flow (login -> operations -> logout)
- Error handling at the HTTP level

**This foundational knowledge will make you more effective when using higher-level tools like pyFMG or Ansible.**

---

## Prerequisites

- **PowerShell 7.0+** (recommended) or Windows PowerShell 5.1
- **FortiManager** accessible via HTTPS
- **Credentials** configured in `.env` file (see root README)

### Check PowerShell Version

```powershell
$PSVersionTable.PSVersion
```

---

## Folder Structure

```
01-powershell-curl/
├── README.md                 # This file
├── config/
│   └── fmg-config.ps1        # Configuration loader
├── utils/
│   └── Invoke-FMGRequest.ps1 # JSON-RPC helper function
├── 01-auth/
│   ├── login-session.ps1     # Session-based login
│   ├── login-bearer.ps1      # API Key test
│   └── logout.ps1            # Session cleanup
├── 02-addresses/
│   ├── create-address.ps1    # Create IPv4 address
│   ├── read-addresses.ps1    # List/filter addresses
│   ├── update-address.ps1    # Modify address
│   ├── delete-address.ps1    # Delete address
│   └── manage-groups.ps1     # Address group operations
├── 03-services/
│   └── crud-services.ps1     # Service CRUD operations
├── 04-schedules/
│   └── crud-schedules.ps1    # Schedule CRUD operations
├── 05-nat-vip/
│   ├── crud-vip.ps1          # Virtual IP (DNAT) operations
│   └── crud-ippool.ps1       # IP Pool (SNAT) operations
├── 06-security-profiles/
│   └── crud-app-groups.ps1   # Application group operations
└── 07-firewall-policies/
    ├── crud-policies.ps1     # Policy CRUD operations
    └── install-package.ps1   # Policy installation
```

---

## Quick Start

### 1. Configure Environment

Make sure your `.env` file is configured at the project root:

```bash
# From project root
cp .env.example .env
# Edit .env with your credentials
```

### 2. Test Authentication

```powershell
cd 01-powershell-curl/01-auth
.\login-session.ps1
```

Expected output:
```
Connecting to 192.168.1.100...
Login successful!
Session: abc123def456...
```

### 3. Run Your First Query

```powershell
cd ../02-addresses
.\read-addresses.ps1
```

---

## Core Concepts

### JSON-RPC Structure

Every request follows this pattern:

```json
{
    "id": 1,
    "method": "get",
    "params": [
        {
            "url": "/pm/config/adom/root/obj/firewall/address",
            "filter": [["name", "like", "NET_%"]]
        }
    ],
    "session": "your-session-token"
}
```

| Field | Description |
|-------|-------------|
| `id` | Request identifier (for correlation) |
| `method` | Operation: get, add, set, update, delete, exec |
| `params` | Array containing URL and data |
| `session` | Authentication token (from login) |

### Authentication Flow

```
┌─────────┐     Login      ┌─────────────┐
│ Client  │ ───────────────> FortiManager │
│         │ <─────────────── │             │
│         │   Session Token  │             │
│         │                  │             │
│         │   Operations     │             │
│         │ ───────────────> │             │
│         │ (with session)   │             │
│         │                  │             │
│         │     Logout       │             │
│         │ ───────────────> │             │
└─────────┘                  └─────────────┘
```

### Helper Function: Invoke-FMGRequest

The `utils/Invoke-FMGRequest.ps1` function simplifies API calls:

```powershell
# Load the helper
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

# Make a request
$result = Invoke-FMGRequest -Method "get" `
    -Url "/pm/config/adom/root/obj/firewall/address" `
    -Session $session

# Check result
if ($result.success) {
    $result.data | ForEach-Object { Write-Host $_.name }
}
```

---

## Detailed Examples

### Authentication

**Session Login:**
```powershell
# login-session.ps1
$payload = @{
    id = 1
    method = "exec"
    params = @(
        @{
            url = "/sys/login/user"
            data = @{
                user = $env:FMG_USERNAME
                passwd = $env:FMG_PASSWORD
            }
        }
    )
}

$response = Invoke-RestMethod -Uri $uri -Method Post -Body ($payload | ConvertTo-Json -Depth 10)
$session = $response.session
```

**Session Logout:**
```powershell
# Always logout to free server resources
$payload = @{
    id = 1
    method = "exec"
    params = @(@{ url = "/sys/logout" })
    session = $session
}
Invoke-RestMethod -Uri $uri -Method Post -Body ($payload | ConvertTo-Json)
```

### CRUD Operations

**Create Address:**
```powershell
$data = @{
    name = "SRV_WEB_01"
    type = "ipmask"
    subnet = "192.168.10.10 255.255.255.255"
    comment = "Web Server"
}

$result = Invoke-FMGRequest -Method "add" `
    -Url "/pm/config/adom/root/obj/firewall/address" `
    -Data $data `
    -Session $session
```

**Read with Filter:**
```powershell
$options = @{
    filter = @(,@("name", "like", "SRV_%"))
    fields = @("name", "subnet", "comment")
}

$result = Invoke-FMGRequest -Method "get" `
    -Url "/pm/config/adom/root/obj/firewall/address" `
    -Options $options `
    -Session $session
```

**Update Address:**
```powershell
$data = @{
    comment = "Updated comment"
}

$result = Invoke-FMGRequest -Method "update" `
    -Url "/pm/config/adom/root/obj/firewall/address/SRV_WEB_01" `
    -Data $data `
    -Session $session
```

**Delete Address:**
```powershell
$result = Invoke-FMGRequest -Method "delete" `
    -Url "/pm/config/adom/root/obj/firewall/address/SRV_WEB_01" `
    -Session $session
```

### Policy Operations

**Create Policy:**
```powershell
$policy = @{
    name = "Allow-Web-Traffic"
    srcintf = @("port1")
    dstintf = @("port2")
    srcaddr = @("all")
    dstaddr = @("SRV_WEB_01")
    service = @("HTTP", "HTTPS")
    action = "accept"
    logtraffic = "all"
    nat = "enable"
}

$result = Invoke-FMGRequest -Method "add" `
    -Url "/pm/config/adom/root/pkg/default/firewall/policy" `
    -Data $policy `
    -Session $session
```

**Install Policy Package:**
```powershell
$installData = @{
    adom = "root"
    pkg = "default"
    scope = @(
        @{
            name = "FGT-01"
            vdom = "root"
        }
    )
}

$result = Invoke-FMGRequest -Method "exec" `
    -Url "/securityconsole/install/package" `
    -Data $installData `
    -Session $session
```

---

## Error Handling

### Response Structure

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
            "data": [...]
        }
    ]
}
```

### Common Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | Process data |
| -2 | Object not found | Check name/path |
| -3 | Object exists | Use update instead |
| -6 | Permission denied | Check user permissions |
| -10 | Object in use | Remove references first |
| -11 | Auth failed | Check credentials |

### Error Handling Example

```powershell
$result = Invoke-FMGRequest -Method "add" -Url $url -Data $data -Session $session

if (-not $result.success) {
    switch ($result.code) {
        -2 { Write-Error "Object not found" }
        -3 { Write-Warning "Object exists, updating instead..."
             Invoke-FMGRequest -Method "update" -Url $url -Data $data -Session $session
        }
        -6 { Write-Error "Permission denied - check API user privileges" }
        default { Write-Error "Error $($result.code): $($result.message)" }
    }
}
```

---

## Best Practices

### 1. Always Use Try/Finally for Sessions

```powershell
$session = $null
try {
    $session = .\login-session.ps1

    # Your operations here

} finally {
    if ($session) {
        .\logout.ps1 -Session $session
    }
}
```

### 2. Enable Debug Mode for Troubleshooting

In your `.env`:
```
FMG_DEBUG=true
```

This shows raw requests and responses.

### 3. Use Consistent Naming

```powershell
# Good: Prefix indicates object type
$data = @{ name = "NET_SERVERS_DMZ" }
$data = @{ name = "SRV_HTTPS_8443" }
$data = @{ name = "POL_ALLOW_WEB" }
```

### 4. Validate Before Delete

```powershell
# Check if object exists before deleting
$existing = Invoke-FMGRequest -Method "get" -Url "$url/$name" -Session $session
if ($existing.success -and $existing.data) {
    $confirm = Read-Host "Delete $name? (y/n)"
    if ($confirm -eq 'y') {
        Invoke-FMGRequest -Method "delete" -Url "$url/$name" -Session $session
    }
}
```

---

## Troubleshooting

### SSL Certificate Errors

If you get certificate errors with self-signed certs:

```powershell
# PowerShell 7+
$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true

# Or set in .env
FMG_VERIFY_SSL=false
```

### Session Timeout

Sessions expire after inactivity. If you get `-11` or `-20` errors:

```powershell
# Re-authenticate
$session = .\login-session.ps1
```

### Connection Refused

- Verify FortiManager IP and port
- Check firewall rules
- Confirm HTTPS is enabled on FMG

---

## Next Steps

Once you're comfortable with raw HTTP requests:

1. **Move to Python** (`02-python-requests/`) - See how to structure code properly
2. **Try pyFMG** (`03-python-pyfmg/`) - Experience the official library
3. **Explore Ansible** (`04-ansible/`) - Declarative automation

---

## Reference

- [Main README](../README.md)
- [JSON-RPC Concepts](../docs/01-concepts-json-rpc.md)
- [API Endpoints Cheatsheet](../cheatsheets/api-endpoints.md)
- [Error Codes Reference](../cheatsheets/common-errors.md)
