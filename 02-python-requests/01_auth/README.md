# Authentication Management

> **FortiManager authentication with Python requests library.**

[Home](../../README.md) > [Level 2](../README.md) > Authentication

---

## Overview

This section demonstrates FortiManager authentication patterns using the Python requests library. The FortiManagerClient class provides a reusable wrapper with context manager support for automatic session handling.

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
| **Session** | Login/logout with session token | Interactive use |
| **API Key** | Bearer token (stateless) | Automation, CI/CD |

---

## Usage

### Context Manager (Recommended)

```python
from utils.fmg_client import FortiManagerClient

# Automatic login/logout
with FortiManagerClient() as fmg:
    result = fmg.get("/sys/status")
    print(result)
```

### Manual Session Management

```python
from utils.fmg_client import FortiManagerClient

fmg = FortiManagerClient()
fmg.login()
try:
    result = fmg.get("/sys/status")
finally:
    fmg.logout()
```

### API Key Authentication

```python
from utils.fmg_client import FortiManagerClient

# Set FMG_API_KEY in environment or .env file
fmg = FortiManagerClient(use_api_key=True)
result = fmg.get("/sys/status")
```

---

## FortiManagerClient Methods

| Method | Description |
|--------|-------------|
| `login()` | Establish session |
| `logout()` | Close session |
| `get(url, **kwargs)` | GET operation |
| `add(url, data)` | ADD operation |
| `update(url, data)` | UPDATE operation |
| `delete(url)` | DELETE operation |
| `get_adom_url(path)` | Build ADOM URL |

---

## See Also

- [pyFMG Equivalent](../../03-python-pyfmg/01_auth/)
- [Bash Equivalent](../../01-raw-http/bash/01-auth/)
- [Next: Addresses](../02_addresses/)
