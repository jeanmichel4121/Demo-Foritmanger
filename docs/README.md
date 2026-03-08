# Documentation

> **Conceptual guides and reference documentation for FortiManager API automation.**

[Home](../README.md) > Docs

---

## Reading Order

Start here and follow the sequence for optimal learning:

| # | Document | Description |
|---|----------|-------------|
| 1 | [Introduction](00-introduction.md) | What is FortiManager? Why automate? |
| 2 | [JSON-RPC Concepts](01-concepts-json-rpc.md) | Request structure, methods, filtering |
| 3 | [Authentication](02-authentication.md) | Session vs Bearer token authentication |
| 4 | [Covered Operations](03-covered-operations.md) | Supported objects and CRUD operations |
| 5 | [Best Practices](04-best-practices.md) | Security, code quality, production tips |

---

## Quick Links

| Topic | Go To |
|-------|-------|
| **API Endpoints** | [Cheatsheet](../cheatsheets/api-endpoints.md) |
| **Error Codes** | [Troubleshooting](../cheatsheets/common-errors.md) |
| **cURL Examples** | [Cheatsheet](../cheatsheets/curl-examples.md) |
| **Visual Diagrams** | [Diagrams](../diagrams/README.md) |

---

## Document Overview

### 00-introduction.md

- FortiManager's role as centralized management platform
- Why use the API (bulk operations, standardization, integration)
- Key concepts: ADOM, Policy Package, Installation Workflow
- Supported versions (7.2.x - 7.6.x)

### 01-concepts-json-rpc.md

- REST vs JSON-RPC comparison
- Request/Response structure
- Available methods (get, add, set, update, delete, exec, move, clone)
- URL patterns and structure
- Query options (filtering, field selection, pagination, sorting)

### 02-authentication.md

- Session-based authentication (all versions)
- Bearer token / API Key authentication (7.2.2+)
- Code examples for Python, PowerShell, Bash
- Error handling and troubleshooting

### 03-covered-operations.md

- Complete list of supported objects (addresses, services, schedules, NAT, security profiles, policies)
- API paths for each object type
- Operations coverage by learning level

### 04-best-practices.md

- Credential management and security
- Code quality patterns
- Session management
- Naming conventions
- Error handling
- Performance optimization
- CI/CD integration

---

## See Also

- [Main README](../README.md)
- [Cheatsheets](../cheatsheets/README.md)
- [Diagrams](../diagrams/README.md)
