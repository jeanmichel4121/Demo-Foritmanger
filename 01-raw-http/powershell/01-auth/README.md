# 🔐 Authentication Scripts

> **Authenticate with FortiManager API using session tokens or API keys.**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > Authentication

---

## 📋 Overview

FortiManager supports two authentication methods: **Session-based** (all versions) and **Bearer Token/API Key** (FMG 7.2.2+).

For a complete understanding of authentication concepts, security best practices, and detailed workflows, see the **[Authentication Guide](../../../docs/02-authentication.md)**.

![Authentication Methods](../../../diagrams/03-authentication-methods.png)

---

## 📜 Scripts

| Script | Method | Description |
|--------|--------|-------------|
| `login-session.ps1` | **Session** | Login with username/password, returns session token |
| `login-bearer.ps1` | **Bearer** | Test API key connection |
| `logout.ps1` | **Session** | Close and invalidate session |

---

## 🚀 Quick Start

### Bearer Token *(Recommended for automation)*

```powershell
# 1. Set API key in .env
# FMG_API_KEY=your_api_key_here

# 2. Test connection
.\login-bearer.ps1

# 3. Use scripts directly - no login/logout needed
..\02-addresses\read-addresses.ps1
```

### Session-Based

```powershell
# 1. Login and capture session token
$session = .\login-session.ps1

# 2. Use session in subsequent calls
..\02-addresses\read-addresses.ps1 -Session $session

# 3. Always logout when done
.\logout.ps1 -Session $session
```

---

## 💡 Examples

### Test Connection with API Key

```powershell
.\login-bearer.ps1

# Expected output:
# Connected to 192.168.1.100
# FortiManager: FMG-01
# Version: 7.4.10
```

### Session Workflow with Error Handling

```powershell
$session = $null
try {
    # Login
    $session = .\login-session.ps1
    Write-Host "Session: $session"

    # Your operations here
    ..\02-addresses\read-addresses.ps1 -Session $session

} finally {
    # Always logout
    if ($session) {
        .\logout.ps1 -Session $session
    }
}
```

### Verbose Login for Debugging

```powershell
# Enable debug mode
$env:FMG_DEBUG = "true"

$session = .\login-session.ps1
# Shows raw JSON-RPC request and response
```

---

## ⚙️ Options Reference

### login-session.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Verbose` | Show detailed output | No |

**Returns:** Session token string

### login-bearer.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Verbose` | Show detailed output | No |

**Returns:** Connection test result

### logout.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Session` | Session token to invalidate | **Yes** |

---

## 🔗 See Also

- [Bash Equivalent](../../bash/01-auth/)
- [Next: Addresses](../02-addresses/)
- [Authentication Guide](../../../docs/02-authentication.md) *(Complete reference)*
- [Common Errors](../../../cheatsheets/common-errors.md)
