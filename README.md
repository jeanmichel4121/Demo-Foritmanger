# FortiManager API Automation Demo

> **Learn FortiManager JSON-RPC API automation through 4 progressive levels.**

![FortiManager Version](https://img.shields.io/badge/FortiManager-7.2.x%20--%207.6.x-red)
![License](https://img.shields.io/badge/License-MIT-blue)
![Python](https://img.shields.io/badge/Python-3.8+-green)
![Ansible](https://img.shields.io/badge/Ansible-2.15+-orange)

---

## 📋 Overview

This repository provides hands-on examples for automating FortiManager operations using its JSON-RPC API. Progress from raw HTTP requests to production-ready Ansible playbooks.

![Architecture Overview](diagrams/01-architecture-overview.png)

---

## 🚀 Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/your-username/Demo-FortiManager.git
cd Demo-FortiManager
cp .env.example .env
```

### 2. Edit `.env` with your credentials

```bash
FMG_HOST=192.168.1.100
FMG_PORT=443
FMG_USERNAME=api_admin
FMG_PASSWORD=your_password
# FMG_API_KEY=your_key    # Recommended for FMG 7.2.2+
FMG_ADOM=root
FMG_VERIFY_SSL=false
```

### 3. Choose your level and start learning

---

## 📚 Learning Path

![Learning Progression](diagrams/06-learning-progression.png)

| Level | Folder | Description | Best For |
|-------|--------|-------------|----------|
| **1** | [01-raw-http/](01-raw-http/) | Raw HTTP requests (PowerShell/Bash) | Understanding fundamentals |
| **2** | [02-python-requests/](02-python-requests/) | Python abstraction layer | Building custom tools |
| **3** | [03-python-pyfmg/](03-python-pyfmg/) | Official pyFMG SDK | Production scripts |
| **4** | [04-ansible/](04-ansible/) | Infrastructure as Code | Team collaboration, CI/CD |

**Recommended path:** Start with Level 1 to understand the API mechanics, then progress to higher levels.

---

## 📁 Project Structure

```
Demo-FortiManager/
├── .env.example              # Environment template
├── README.md                 # This file
│
├── 01-raw-http/              # Level 1: Raw HTTP
│   ├── powershell/           #   Windows (PowerShell 7.0+)
│   └── bash/                 #   Linux/macOS (bash, curl, jq)
├── 02-python-requests/       # Level 2: Python abstraction
├── 03-python-pyfmg/          # Level 3: Official SDK
├── 04-ansible/               # Level 4: Infrastructure as Code
│
├── docs/                     # In-depth documentation
├── cheatsheets/              # Quick reference guides
└── diagrams/                 # Visual documentation
```

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [Introduction](docs/00-introduction.md) | FortiManager overview and API basics |
| [JSON-RPC Concepts](docs/01-concepts-json-rpc.md) | Request/response structure, methods |
| [Authentication](docs/02-authentication.md) | Session vs Bearer token |
| [Covered Operations](docs/03-covered-operations.md) | Supported objects and CRUD operations |
| [Best Practices](docs/04-best-practices.md) | Security, code quality, operations |

### Quick Reference

| Cheatsheet | Description |
|------------|-------------|
| [API Endpoints](cheatsheets/api-endpoints.md) | URL patterns and parameters |
| [Common Errors](cheatsheets/common-errors.md) | Error codes and solutions |
| [cURL Examples](cheatsheets/curl-examples.md) | One-liner examples |

---

## 📦 Prerequisites

| Requirement | Details |
|-------------|---------|
| **FortiManager** | 7.2.x - 7.6.x |
| **Network** | HTTPS access (port 443) |
| **Credentials** | Admin user or API Key |

See each level's README for platform-specific requirements.

---

## 🔗 References

### Official Documentation

- [FortiManager Administration Guide](https://docs.fortinet.com/document/fortimanager/7.6.0/administration-guide)
- [FortiManager API Best Practices](https://docs.fortinet.com/document/fortimanager/7.6.0/api-best-practices/500458/introduction)
- [How to FortiManager API](https://how-to-fortimanager-api.readthedocs.io/)

### Libraries

- [pyFMG](https://pypi.org/project/pyfmg/) - Official Python library
- [fortinet.fortimanager](https://docs.ansible.com/ansible/latest/collections/fortinet/fortimanager/index.html) - Ansible collection

---

## License

MIT License - see [LICENSE](LICENSE) file.
