# Level 1: PowerShell

> **Learn the fundamentals of FortiManager JSON-RPC API through raw HTTP requests.**

[Home](../../README.md) > [Level 1](../README.md) > PowerShell

---

## 📋 Overview

This section teaches you the raw mechanics of the FortiManager API through PowerShell scripts. These are the Windows equivalent of the [Bash scripts](../bash/).

**This foundational knowledge will make you more effective when using higher-level tools like pyFMG or Ansible.**

---

## 📦 Prerequisites

| Requirement | Details |
|-------------|---------|
| **PowerShell** | 7.0+ (recommended) or Windows PowerShell 5.1 |
| **FortiManager** | Accessible via HTTPS |
| **Credentials** | Configured in `.env` file at project root |

```powershell
# Check version
$PSVersionTable.PSVersion
```

---

## 📁 Directory Structure

```
01-raw-http/powershell/
├── config/fmg-config.ps1           # Configuration loader
├── utils/Invoke-FMGRequest.ps1     # JSON-RPC helper function
├── 01-auth/                        # Authentication scripts
├── 02-addresses/                   # Address management
├── 03-services/                    # Service management
├── 04-schedules/                   # Schedule management
├── 05-nat-vip/                     # NAT configuration
├── 06-security-profiles/           # Security profiles
└── 07-firewall-policies/           # Policies + installation
```

---

## 🚀 Quick Start

```powershell
# 1. Configure .env at project root
cp .env.example .env

# 2. Test authentication
cd 01-raw-http/powershell/01-auth
.\login-session.ps1

# 3. Or use Bearer token (recommended)
.\login-bearer.ps1
```

---

## 💡 Usage Examples

### Authentication with Session

```powershell
$session = $null
try {
    $session = .\01-auth\login-session.ps1
    .\02-addresses\read-addresses.ps1 -Session $session
} finally {
    if ($session) { .\01-auth\logout.ps1 -Session $session }
}
```

### Helper Function

```powershell
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

$result = Invoke-FMGRequest -Method "get" `
    -Url "/pm/config/adom/root/obj/firewall/address" `
    -Session $session

if ($result.success) {
    $result.data | ForEach-Object { Write-Host $_.name }
}
```

### CRUD Operations

```powershell
# Create
$data = @{ name = "SRV_WEB_01"; type = "ipmask"; subnet = "192.168.10.10 255.255.255.255" }
Invoke-FMGRequest -Method "add" -Url $url -Data $data -Session $session

# Read with filter
$options = @{ filter = @(,@("name", "like", "SRV_%")) }
Invoke-FMGRequest -Method "get" -Url $url -Options $options -Session $session

# Update
Invoke-FMGRequest -Method "update" -Url "$url/SRV_WEB_01" -Data @{comment="Updated"} -Session $session

# Delete
Invoke-FMGRequest -Method "delete" -Url "$url/SRV_WEB_01" -Session $session
```

---

## ⚠️ Error Handling

```powershell
if (-not $result.success) {
    switch ($result.code) {
        -2 { Write-Error "Object not found" }
        -3 { Write-Warning "Object exists, use update" }
        -6 { Write-Error "Permission denied" }
        default { Write-Error "Error $($result.code): $($result.message)" }
    }
}
```

See [Error Codes Reference](../../cheatsheets/common-errors.md) for complete list.

---

## 🔍 Troubleshooting

| Problem | Solution |
|---------|----------|
| SSL certificate error | `$PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true` |
| Session timeout (-11) | Re-authenticate with `.\login-session.ps1` |
| Connection refused | Check FMG IP, port 443, and firewall rules |

---

## 🔗 See Also

- [Bash Version](../bash/) - Linux/macOS equivalent
- [JSON-RPC Concepts](../../docs/01-concepts-json-rpc.md) - Request structure
- [API Endpoints](../../cheatsheets/api-endpoints.md) - Quick reference
- [Error Codes](../../cheatsheets/common-errors.md) - Troubleshooting
