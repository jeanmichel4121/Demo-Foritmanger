# Authentication Scripts

> **Authenticate with FortiManager API using session tokens or API keys.**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > Authentication

---

## Overview

FortiManager supports two authentication methods. This section provides scripts to authenticate and manage sessions for subsequent API operations.

![Authentication Methods](../../../diagrams/03-authentication-methods.png)

---

## Scripts

| Script | Method | Description |
|--------|--------|-------------|
| `login-session.ps1` | **Session** | Login with username/password, returns session token |
| `login-bearer.ps1` | **Bearer** | Test API key connection |
| `logout.ps1` | **Session** | Close and invalidate session |

---

## Authentication Methods

| Method | Best For | FMG Version | State |
|--------|----------|-------------|-------|
| **Bearer Token** | Automation, CI/CD | 7.2.2+ | Stateless |
| **Session-based** | Interactive scripts | All versions | Requires logout |

---

## Quick Start

### Bearer Token (Recommended)

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

## Usage Examples

### Test Connection

```powershell
# With API Key
.\login-bearer.ps1

# Expected output:
# Connected to 192.168.1.100
# FortiManager: FMG-01
# Version: 7.4.10
```

### Session Workflow

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

---

## API Reference

### Login Endpoint

| Field | Value |
|-------|-------|
| **URL** | `/sys/login/user` |
| **Method** | `exec` |

```json
{
    "method": "exec",
    "params": [{
        "url": "/sys/login/user",
        "data": {
            "user": "admin",
            "passwd": "password"
        }
    }]
}
```

### Logout Endpoint

| Field | Value |
|-------|-------|
| **URL** | `/sys/logout` |
| **Method** | `exec` |

---

## Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `-11` | Invalid credentials | Check username/password |
| `-6` | Permission denied | Verify API user permissions |
| Connection refused | Network issue | Check FMG_HOST and firewall rules |

---

## See Also

- [Bash Equivalent](../../bash/01-auth/)
- [Next: Addresses](../02-addresses/)
- [Authentication Guide](../../../docs/02-authentication.md)
- [Authentication Diagram](../../../diagrams/03-authentication-methods.png)
