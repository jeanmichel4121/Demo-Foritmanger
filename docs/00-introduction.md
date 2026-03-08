# Introduction to FortiManager API

> **Understand FortiManager's role and why API automation matters.**

[Home](../README.md) > [Docs](./) > Introduction

---

## 📋 What is FortiManager?

FortiManager is Fortinet's **centralized management platform** for FortiGate firewalls. It serves as the single point of control for:

- **Configuration Management** - Centralized policies, objects, and security profiles
- **Multi-Device Control** - Manage hundreds of FortiGates from one interface
- **Change Deployment** - Push configurations in controlled, auditable workflows
- **Compliance** - Maintain consistent security posture across your organization

---

## 💡 Why Use the API?

Manual configuration through the GUI becomes impractical at scale.

| Use Case | Description |
|----------|-------------|
| **Bulk Operations** | Import hundreds of addresses from CSV, CMDB, or IPAM |
| **Standardization** | Deploy consistent configurations across environments |
| **Integration** | Connect with Ansible, Terraform, CI/CD pipelines |
| **Self-Service** | Build portals for network requests |
| **Audit & Compliance** | Automated configuration validation |
| **Disaster Recovery** | Rapid re-deployment from code |

### API vs GUI

| Operation | GUI Time | API Time | Benefit |
|-----------|----------|----------|---------|
| Create 100 addresses | ~30 min | ~5 sec | 360x faster |
| Update policy comment | ~2 min | ~1 sec | Consistent |
| Audit all objects | ~1 hour | ~10 sec | Complete |

---

## 🔑 Key Concepts

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
├── ADOM: Production
└── ADOM: Development
```

### Policy Package

A **container for firewall policies** that can be assigned to devices:

- Contains ordered list of firewall rules
- Can include security profiles
- Must be **installed** to apply changes to FortiGates
- Changes in FortiManager don't affect FortiGates until installed

### Installation Workflow

```
1. Create/Modify    2. Review         3. Preview        4. Install
   Objects &           Changes           Config            to
   Policies            in FMG            Diff             FortiGates
```

---

## 📦 Supported Versions

This repository targets **FortiManager 7.2.x - 7.6.x**.

| Version | Key Features |
|---------|--------------|
| 7.2.x | API Key authentication (7.2.2+) |
| 7.4.x | Partial install, enhanced API |
| 7.6.x | Latest features and improvements |

---

## ⏭️ Next Steps

| Document | Description |
|----------|-------------|
| [JSON-RPC Concepts](01-concepts-json-rpc.md) | Request structure, methods, filtering |
| [Authentication](02-authentication.md) | Session vs Bearer token |
| [Covered Operations](03-covered-operations.md) | Supported objects and CRUD |
| [Best Practices](04-best-practices.md) | Security and code quality |
