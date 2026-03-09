# Authentication Management

> **FortiManager authentication with pyFMG library.**

[Home](../../README.md) > [Level 3](../README.md) > Authentication

---

## Overview

This section demonstrates FortiManager authentication patterns using the official pyFMG library. pyFMG simplifies API interactions with built-in session management and context manager support.

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **Login** | `/sys/login/user` |
| **Logout** | `/sys/logout` |
| **System Status** | `/sys/status` |

---

## Scripts

| Script | Description |
|--------|-------------|
| `demo_auth.py` | Authentication demo with multiple patterns |

---

## Authentication Methods

| Method | Description | Best For |
|--------|-------------|----------|
| **Session** | Context manager auto-login/logout | Standard use |
| **API Key** | Stateless authentication | Automation |

---

## Usage

### Context Manager (Recommended)

```python
from pyFMG.fortimgr import FortiManager

with FortiManager(FMG_HOST, FMG_USER, FMG_PASS, verify_ssl=False) as fmg:
    code, data = fmg.get("/sys/status")
    if code == 0:
        print(data)
```

### API Key Authentication

```python
from pyFMG.fortimgr import FortiManager

fmg = FortiManager(FMG_HOST, apikey=FMG_API_KEY)
code, data = fmg.get("/sys/status")
```

### Manual Session Management

```python
from pyFMG.fortimgr import FortiManager

fmg = FortiManager(FMG_HOST, FMG_USER, FMG_PASS)
fmg.login()
try:
    code, data = fmg.get("/sys/status")
finally:
    fmg.logout()
```

---

## Return Value Pattern

pyFMG returns a tuple: `(code, response)`

```python
code, data = fmg.get(url)
if code == 0:
    # Success
    print(data)
else:
    # Error
    print(f"Error code: {code}")
```

---

## See Also

- [Python Requests Equivalent](../../02-python-requests/01_auth/)
- [Bash Equivalent](../../01-raw-http/bash/01-auth/)
- [Next: Addresses](../02_addresses/)
