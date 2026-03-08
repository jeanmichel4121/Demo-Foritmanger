# Level 1: Raw HTTP Requests

> **Master the fundamentals of FortiManager JSON-RPC API through direct HTTP calls.**

[Home](../README.md) > Level 1: Raw HTTP

---

## Overview

This section teaches you the **raw mechanics** of the FortiManager API. By working directly with HTTP requests, you'll understand:

- How JSON-RPC differs from REST APIs
- The exact structure of API requests and responses
- Authentication flow (login -> operations -> logout)
- Error handling at the HTTP level

**This foundational knowledge will make you more effective when using higher-level tools like pyFMG or Ansible.**

---

## Choose Your Platform

| Platform | Folder | Best For |
|----------|--------|----------|
| **Windows** | [powershell/](powershell/) | PowerShell 7.0+ users, Windows environments |
| **Linux/macOS** | [bash/](bash/) | Bash 4.0+ users, CI/CD pipelines, containers |

Both implementations cover the same operations - choose based on your preferred environment.

---

## What You'll Learn

### Authentication
- Session-based login/logout flow
- Bearer token (API Key) authentication
- When to use each method

### CRUD Operations
- **Create** - Add new firewall objects
- **Read** - List and filter existing objects
- **Update** - Modify object properties
- **Delete** - Remove objects safely

### Object Types Covered

| Category | Objects |
|----------|---------|
| **Addresses** | IPv4, IPv6, Address Groups |
| **Services** | Custom services, Service Groups |
| **Schedules** | One-time, Recurring |
| **NAT** | Virtual IPs (DNAT), IP Pools (SNAT) |
| **Security** | Application Groups, Security Profiles |
| **Policies** | Firewall rules, Policy installation |

---

## Quick Start

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

## Folder Structure

```
01-raw-http/
├── README.md               # This file
├── powershell/             # Windows implementation
│   ├── README.md           # PowerShell guide
│   ├── config/             # Configuration loader
│   ├── utils/              # Helper functions
│   ├── 01-auth/            # Authentication scripts
│   ├── 02-addresses/       # Address management
│   ├── 03-services/        # Service management
│   ├── 04-schedules/       # Schedule management
│   ├── 05-nat-vip/         # NAT configuration
│   ├── 06-security-profiles/
│   └── 07-firewall-policies/
└── bash/                   # Linux/macOS implementation
    ├── README.md           # Bash guide
    └── [same structure]
```

---

## Prerequisites

### Common Requirements

| Requirement | Details |
|-------------|---------|
| **FortiManager** | 7.2.x - 7.6.x |
| **Network** | HTTPS access (port 443) |
| **Credentials** | API user or API Key |

### Platform-Specific

| Platform | Requirements |
|----------|--------------|
| **PowerShell** | PowerShell 7.0+ (recommended) or Windows PowerShell 5.1 |
| **Bash** | bash 4.0+, curl, jq |

---

## Core Concepts

### JSON-RPC vs REST

FortiManager uses **JSON-RPC**, not REST:

| Aspect | REST | JSON-RPC (FortiManager) |
|--------|------|-------------------------|
| **Endpoint** | Multiple URLs | Single `/jsonrpc` |
| **HTTP Method** | GET, POST, PUT, DELETE | Always POST |
| **Routing** | URL path | `method` field in body |

### Request Structure

```json
{
    "id": 1,
    "method": "get",
    "params": [{
        "url": "/pm/config/adom/root/obj/firewall/address"
    }],
    "session": "your-session-token"
}
```

---

## Learning Path

```
01-auth         ->  Authentication fundamentals
02-addresses    ->  Address CRUD operations
03-services     ->  Service management
04-schedules    ->  Time-based access control
05-nat-vip      ->  NAT configuration (DNAT/SNAT)
06-security-profiles -> Security features
07-firewall-policies -> Policies and installation
```

---

## Next Steps

Once you're comfortable with raw HTTP requests:

| Level | Description | Folder |
|-------|-------------|--------|
| **Level 2** | Python abstraction layer | [02-python-requests/](../02-python-requests/) |
| **Level 3** | Official pyFMG SDK | [03-python-pyfmg/](../03-python-pyfmg/) |
| **Level 4** | Ansible automation | [04-ansible/](../04-ansible/) |

---

## See Also

- [JSON-RPC Concepts](../docs/01-concepts-json-rpc.md)
- [Authentication Guide](../docs/02-authentication.md)
- [API Endpoints Cheatsheet](../cheatsheets/api-endpoints.md)
- [Learning Progression Diagram](../diagrams/06-learning-progression.png)
