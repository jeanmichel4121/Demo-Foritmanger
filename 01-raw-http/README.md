# Level 1: Raw HTTP Requests

> **Master the fundamentals of FortiManager JSON-RPC API through direct HTTP calls.**

[Home](../README.md) > Level 1: Raw HTTP

---

## 📋 Overview

This section teaches you the **raw mechanics** of the FortiManager API. By working directly with HTTP requests, you'll understand exactly how the JSON-RPC protocol works.

**This foundational knowledge will make you more effective when using higher-level tools like pyFMG or Ansible.**

> For complete documentation on JSON-RPC concepts, see [JSON-RPC Concepts](../docs/01-concepts-json-rpc.md).

---

## 🖥️ Choose Your Platform

| Platform | Folder | Best For |
|----------|--------|----------|
| **Windows** | [powershell/](powershell/) | PowerShell 7.0+ users, Windows environments |
| **Linux/macOS** | [bash/](bash/) | Bash 4.0+ users, CI/CD pipelines, containers |

Both implementations cover the same operations - choose based on your preferred environment.

---

## 📚 What You'll Learn

| Category | Topics |
|----------|--------|
| **Authentication** | Session-based login/logout, Bearer token (API Key) |
| **CRUD Operations** | Create, Read, Update, Delete firewall objects |
| **Object Types** | Addresses, Services, Schedules, NAT/VIP, Security Profiles, Policies |
| **Deployment** | Policy package installation to FortiGates |

---

## 🚀 Quick Start

### PowerShell (Windows)

```powershell
cd powershell/01-auth

# Test connection with API Key
.\login-bearer.ps1

# Or use session-based auth
$session = .\login-session.ps1
.\logout.ps1 -Session $session
```

### Bash (Linux/macOS)

```bash
cd bash/01-auth

# Test connection with API Key
./login-bearer.sh

# Or use session-based auth
SESSION=$(./login-session.sh)
./logout.sh "$SESSION"
```

---

## 📁 Folder Structure

```
01-raw-http/
├── README.md               # This file
├── powershell/             # Windows implementation
│   ├── README.md           # PowerShell guide
│   ├── config/             # Configuration loader
│   ├── utils/              # Helper functions
│   └── 01-auth/ ... 07-firewall-policies/
└── bash/                   # Linux/macOS implementation
    ├── README.md           # Bash guide
    └── [same structure]
```

---

## 📦 Prerequisites

| Requirement | Details |
|-------------|---------|
| **FortiManager** | 7.2.x - 7.6.x |
| **Network** | HTTPS access (port 443) |
| **Credentials** | API user or API Key |
| **PowerShell** | 7.0+ (recommended) or Windows PowerShell 5.1 |
| **Bash** | bash 4.0+, curl, jq |

---

## 📈 Learning Path

| Step | Folder | Description |
|------|--------|-------------|
| 1 | `01-auth/` | Authentication fundamentals |
| 2 | `02-addresses/` | Address CRUD operations |
| 3 | `03-services/` | Service management |
| 4 | `04-schedules/` | Time-based access control |
| 5 | `05-nat-vip/` | NAT configuration (DNAT/SNAT) |
| 6 | `06-security-profiles/` | Security features |
| 7 | `07-firewall-policies/` | Policies and installation |

---

## ⏭️ Next Steps

Once you're comfortable with raw HTTP requests:

| Level | Description | Folder |
|-------|-------------|--------|
| **Level 2** | Python abstraction layer | [02-python-requests/](../02-python-requests/) |
| **Level 3** | Official pyFMG SDK | [03-python-pyfmg/](../03-python-pyfmg/) |
| **Level 4** | Ansible automation | [04-ansible/](../04-ansible/) |

---

## 🔗 See Also

- [JSON-RPC Concepts](../docs/01-concepts-json-rpc.md) - Request structure, methods, filtering
- [Authentication Guide](../docs/02-authentication.md) - Session vs Bearer token
- [API Endpoints Cheatsheet](../cheatsheets/api-endpoints.md) - Quick reference
