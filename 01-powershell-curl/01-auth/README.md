# FortiManager Authentication

This section contains authentication scripts.

## Scripts

| Script | Description |
|--------|-------------|
| `login-session.ps1` | Session-based login (username/password) |
| `login-bearer.ps1` | Test connection with API Key |
| `logout.ps1` | Session logout |

## Method 1: Session-based

```powershell
# Login
$session = .\login-session.ps1

# Use session in other scripts
.\02-addresses\read-addresses.ps1 -Session $session

# Logout (important!)
.\logout.ps1 -Session $session
```

## Method 2: Bearer Token (recommended)

1. Configure `FMG_API_KEY` in `.env`
2. Scripts automatically use Bearer token
3. No login/logout needed

```powershell
# Test connection
.\login-bearer.ps1

# Use scripts directly
.\02-addresses\read-addresses.ps1
```

## Method Selection

The `Invoke-FMGRequest.ps1` helper auto-detects:
- If `FMG_API_KEY` is defined -> Bearer token
- Otherwise -> session token (passed as parameter)
