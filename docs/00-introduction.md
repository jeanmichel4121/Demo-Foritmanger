# Introduction to FortiManager API

> **Understand FortiManager's role and why API automation matters.**

---

## What is FortiManager?

FortiManager is Fortinet's **centralized management platform** for FortiGate firewalls and other Fortinet devices. It serves as the single point of control for:

- **Configuration Management** - Centralized policies, objects, and security profiles
- **Multi-Device Control** - Manage hundreds of FortiGates from one interface
- **Change Deployment** - Push configurations in controlled, auditable workflows
- **Compliance** - Maintain consistent security posture across your organization

```
                    ┌─────────────────────────────────────┐
                    │          FortiManager               │
                    │  ┌─────────┐  ┌─────────────────┐   │
                    │  │ Objects │  │ Policy Packages │   │
                    │  │ Address │  │    ┌───────┐    │   │
                    │  │ Service │  │    │Policy │    │   │
                    │  │   VIP   │  │    │ Rules │    │   │
                    │  └─────────┘  │    └───────┘    │   │
                    │               └─────────────────┘   │
                    └──────────────────┬──────────────────┘
                                       │ Install
                    ┌──────────────────┼──────────────────┐
                    │                  │                  │
                    ▼                  ▼                  ▼
              ┌──────────┐       ┌──────────┐       ┌──────────┐
              │FortiGate │       │FortiGate │       │FortiGate │
              │    01    │       │    02    │       │    03    │
              └──────────┘       └──────────┘       └──────────┘
```

---

## Why Use the API?

Manual configuration through the GUI becomes impractical at scale. The FortiManager API enables:

### Automation Use Cases

| Use Case | Description |
|----------|-------------|
| **Bulk Operations** | Import hundreds of addresses from CSV, CMDB, or IPAM |
| **Standardization** | Deploy consistent configurations across environments |
| **Integration** | Connect with Ansible, Terraform, CI/CD pipelines |
| **Self-Service** | Build portals for network requests |
| **Audit & Compliance** | Automated configuration validation |
| **Disaster Recovery** | Rapid re-deployment from code |

### Benefits of API Automation

```
Manual (GUI)                    API Automation
─────────────────              ─────────────────
Hours of clicking    →         Seconds of execution
Human errors         →         Consistent results
No audit trail       →         Git version control
Knowledge in heads   →         Documentation in code
Single operator      →         Team collaboration
```

---

## Key Concepts

### ADOM (Administrative Domain)

ADOMs provide **logical separation** within FortiManager:

- Each ADOM contains its own objects, policies, and devices
- Enables multi-tenancy (different teams, customers, environments)
- `root` is the default ADOM when ADOM mode is disabled

```
FortiManager
├── ADOM: root (default)
│   ├── Objects (addresses, services, etc.)
│   ├── Policy Packages
│   └── Devices (FortiGates)
│
├── ADOM: Production
│   ├── Objects
│   ├── Policy Packages
│   └── Production FortiGates
│
└── ADOM: Development
    ├── Objects
    ├── Policy Packages
    └── Dev/Test FortiGates
```

### Policy Package

A **container for firewall policies** that can be assigned to devices:

- Contains ordered list of firewall rules
- Can include security profiles
- Must be **installed** to apply changes to FortiGates
- Changes in FortiManager don't affect FortiGates until installed

### Object Types

| Category | Objects |
|----------|---------|
| **Addresses** | IPv4/IPv6 addresses, FQDNs, address groups |
| **Services** | TCP/UDP ports, service groups |
| **Schedules** | Time-based access control |
| **NAT** | VIPs (DNAT), IP Pools (SNAT) |
| **Security Profiles** | Antivirus, IPS, Web Filter, App Control |

### Installation Workflow

```
1. Create/Modify    2. Review          3. Preview         4. Install
   Objects &           Changes            Config             to
   Policies            in FMG             Diff              FortiGates

   ┌─────────┐      ┌─────────┐       ┌─────────┐       ┌─────────┐
   │ address │      │  Check  │       │  View   │       │  Push   │
   │ service │  →   │  diff   │   →   │ changes │   →   │ config  │
   │ policy  │      │ history │       │ preview │       │ install │
   └─────────┘      └─────────┘       └─────────┘       └─────────┘
```

---

## API Architecture

FortiManager uses **JSON-RPC** over HTTPS:

```
┌───────────────────────────────────────────────────────────────────┐
│                         Your Automation                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │ PowerShell  │  │   Python    │  │   Ansible   │  │  CI/CD   │ │
│  │   Scripts   │  │   pyFMG     │  │  Playbooks  │  │ Pipeline │ │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └────┬─────┘ │
└─────────┼────────────────┼────────────────┼──────────────┼───────┘
          │                │                │              │
          └────────────────┴────────────────┴──────────────┘
                                   │
                           HTTPS POST /jsonrpc
                           (JSON-RPC Protocol)
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │       FortiManager          │
                    │       API Server            │
                    │        (Port 443)           │
                    └─────────────────────────────┘
```

### JSON-RPC Key Points

| Aspect | Description |
|--------|-------------|
| **Single Endpoint** | All requests go to `/jsonrpc` |
| **Always POST** | HTTP method is always POST |
| **Method in Body** | Action specified in JSON payload |
| **Session or Bearer** | Authenticate via session token or API key |

---

## Supported Versions

This repository targets **FortiManager 7.2.x - 7.6.x**.

| Version | Key Features |
|---------|--------------|
| 7.2.x | API Key authentication (7.2.2+) |
| 7.4.x | Partial install, enhanced API |
| 7.6.x | Latest features and improvements |

### Version Compatibility Notes

- **Core API** structure is consistent across versions
- **New endpoints** may be added in newer versions
- **Authentication** methods vary (Bearer token requires 7.2.2+)
- Always verify endpoint availability in your FMG version

---

## Learning Path

This repository provides a **progressive learning experience**:

```
Level 1                Level 2                Level 3               Level 4
PowerShell/cURL   →    Python + requests  →   Python + pyFMG   →   Ansible

┌─────────────┐       ┌─────────────┐       ┌─────────────┐      ┌─────────────┐
│ Raw HTTP    │       │ Structured  │       │ Official    │      │ Declarative │
│ Requests    │       │ Code        │       │ SDK         │      │ IaC         │
│             │       │             │       │             │      │             │
│ Understand  │       │ Build       │       │ Production  │      │ Team        │
│ the basics  │       │ abstractions│       │ ready       │      │ workflows   │
└─────────────┘       └─────────────┘       └─────────────┘      └─────────────┘
```

### Recommended Order

1. **Start Here** - Read this introduction
2. **JSON-RPC Concepts** - [01-concepts-json-rpc.md](01-concepts-json-rpc.md)
3. **Authentication** - [02-authentication.md](02-authentication.md)
4. **Hands-On** - Begin with `01-powershell-curl/` folder

---

## API vs GUI

| Operation | GUI Time | API Time | Benefit |
|-----------|----------|----------|---------|
| Create 100 addresses | ~30 min | ~5 sec | 360x faster |
| Update policy comment | ~2 min | ~1 sec | Consistent |
| Audit all objects | ~1 hour | ~10 sec | Complete |
| Disaster recovery | Hours | Minutes | Automated |

---

## Next Steps

| Document | Description |
|----------|-------------|
| [01-concepts-json-rpc.md](01-concepts-json-rpc.md) | Deep dive into JSON-RPC |
| [02-authentication.md](02-authentication.md) | Authentication methods |
| [../cheatsheets/api-endpoints.md](../cheatsheets/api-endpoints.md) | Quick reference |
| [../01-powershell-curl/](../01-powershell-curl/) | Start hands-on learning |

---

## Quick Reference

```bash
# Test API connectivity
curl -k -X POST https://<fmg-ip>/jsonrpc \
  -H "Content-Type: application/json" \
  -d '{"id":1,"method":"get","params":[{"url":"/sys/status"}],"session":"<token>"}'
```

---

**Ready to learn?** Continue to [JSON-RPC Concepts](01-concepts-json-rpc.md).
