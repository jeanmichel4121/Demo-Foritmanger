# Level 2: Python + Requests

> **Build reusable, well-structured code with proper abstractions and error handling.**

[Home](../README.md) > Level 2: Python + Requests

---

## 📋 Overview

This section demonstrates how to structure Python code for FortiManager automation. You'll learn:

- **Class-based design** - Encapsulate API logic in reusable classes
- **Custom exceptions** - Handle errors gracefully with specific exception types
- **Type hints** - Document your code for better maintainability
- **Context managers** - Ensure proper session cleanup

**This approach forms the foundation for building custom tools and integrations.**

---

## 📦 Prerequisites

- **Python 3.8+**
- **pip** for dependency management
- **FortiManager** accessible via HTTPS
- **Credentials** configured in `.env` file

### Check Python Version

```bash
python --version  # Should be 3.8+
```

---

## ⚙️ Installation

```bash
cd 02-python-requests

# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt
```

### Dependencies

```
requests>=2.28.0
python-dotenv>=1.0.0
```

---

## 📁 Folder Structure

```
📂 02-python-requests/
├── 📝 README.md               # This file
├── 📄 requirements.txt        # Dependencies
├── 📂 config/
│   ├── 🐍 __init__.py
│   └── 🐍 settings.py         # Centralized configuration (Settings dataclass)
├── 📂 utils/
│   ├── 🐍 __init__.py
│   ├── 🐍 fmg_client.py       # FortiManagerClient class
│   └── 🐍 exceptions.py       # Custom exception hierarchy
├── 📂 01_auth/
│   └── 🐍 demo_auth.py        # Authentication demonstrations
├── 📂 02_addresses/
│   └── 🐍 crud_addresses.py   # Address CRUD with AddressManager class
├── 📂 03_services/
│   └── 🐍 crud_services.py    # Service CRUD operations
└── 📂 07_firewall_policies/
    └── 🐍 crud_policies.py    # Policy CRUD operations
```

---

## 🚀 Quick Start

### 1. Configure Environment

```bash
# From project root
cp .env.example .env
# Edit .env with your credentials
```

### 2. Test Connection

```bash
cd 02-python-requests/01_auth
python demo_auth.py
```

Expected output:
```
==================================================
DEMO: Context Manager (with statement)
==================================================
[OK] Automatically connected
FortiManager:
  Hostname: FMG-01
  Version: 7.4.10
[OK] Automatically disconnected
```

---

## 🔧 Core Components

### Settings Management (`config/settings.py`)

Centralized configuration using a dataclass:

```python
from config.settings import get_settings

settings = get_settings()
print(settings.host)       # From FMG_HOST
print(settings.username)   # From FMG_USERNAME
print(settings.base_url)   # https://host:port/jsonrpc
```

### FortiManagerClient (`utils/fmg_client.py`)

The main API client with CRUD methods:

```python
from utils.fmg_client import FortiManagerClient

# Context manager (recommended) - auto login/logout
with FortiManagerClient() as fmg:
    addresses = fmg.get("/pm/config/adom/root/obj/firewall/address")

# API Key mode - no session management needed
fmg = FortiManagerClient(use_api_key=True)
addresses = fmg.get("/pm/config/adom/root/obj/firewall/address")
```

### Custom Exceptions (`utils/exceptions.py`)

Specific exception types for different error conditions:

```python
from utils.exceptions import (
    FMGError,               # Base exception
    FMGAuthError,           # Authentication failed (-11)
    FMGObjectNotFoundError, # Object not found (-2)
    FMGObjectExistsError,   # Object already exists (-3)
    FMGPermissionError,     # Permission denied (-6)
)

try:
    fmg.delete("/pm/config/adom/root/obj/firewall/address/NONEXISTENT")
except FMGObjectNotFoundError as e:
    print(f"Object not found: {e.object_name}")
except FMGPermissionError:
    print("Insufficient permissions")
```

---

## 💡 Detailed Examples

### Authentication

```python
from utils.fmg_client import FortiManagerClient

# Method 1: Context Manager (Session-based)
with FortiManagerClient() as fmg:
    # Automatically logged in
    result = fmg.get("/sys/status")
    # Automatically logged out

# Method 2: Manual Session
fmg = FortiManagerClient()
fmg.login()
try:
    result = fmg.get("/sys/status")
finally:
    fmg.logout()

# Method 3: API Key (No session)
fmg = FortiManagerClient(use_api_key=True)
result = fmg.get("/sys/status")  # No login/logout needed
```

### CRUD Operations

```python
from utils.fmg_client import FortiManagerClient

with FortiManagerClient() as fmg:

    # CREATE
    fmg.add(
        "/pm/config/adom/root/obj/firewall/address",
        {
            "name": "SRV_WEB_01",
            "type": "ipmask",
            "subnet": "192.168.10.10 255.255.255.255",
            "comment": "Web Server"
        }
    )

    # READ (all)
    addresses = fmg.get("/pm/config/adom/root/obj/firewall/address")

    # READ (filtered)
    addresses = fmg.get(
        "/pm/config/adom/root/obj/firewall/address",
        filter=[["name", "like", "SRV_%"]],
        fields=["name", "subnet"]
    )

    # READ (specific)
    address = fmg.get("/pm/config/adom/root/obj/firewall/address/SRV_WEB_01")

    # UPDATE (partial)
    fmg.update(
        "/pm/config/adom/root/obj/firewall/address/SRV_WEB_01",
        {"comment": "Updated comment"}
    )

    # DELETE
    fmg.delete("/pm/config/adom/root/obj/firewall/address/SRV_WEB_01")
```

### Using the AddressManager Class

The `AddressManager` class in `02_addresses/crud_addresses.py` demonstrates a domain-specific abstraction:

```python
from utils.fmg_client import FortiManagerClient

class AddressManager:
    """Encapsulates address operations."""

    def __init__(self, fmg: FortiManagerClient):
        self.fmg = fmg
        self.base_url = fmg.get_adom_url("obj/firewall/address")

    def create(self, name: str, subnet: str, comment: str = "") -> dict:
        """Create an IPv4 address with CIDR support."""
        if "/" in subnet:
            subnet = self._cidr_to_mask(subnet)

        return self.fmg.add(self.base_url, {
            "name": name,
            "type": "ipmask",
            "subnet": subnet,
            "comment": comment
        })

    def read(self, name: str = None, filter_pattern: str = None) -> list:
        """Read addresses with optional filtering."""
        url = f"{self.base_url}/{name}" if name else self.base_url
        kwargs = {}
        if filter_pattern:
            kwargs["filter"] = [["name", "like", filter_pattern.replace("*", "%")]]
        return self.fmg.get(url, **kwargs) or []

    def update(self, name: str, **updates) -> dict:
        """Partial update of an address."""
        return self.fmg.update(f"{self.base_url}/{name}", updates)

    def delete(self, name: str) -> dict:
        """Delete an address."""
        return self.fmg.delete(f"{self.base_url}/{name}")

    @staticmethod
    def _cidr_to_mask(cidr: str) -> str:
        """Convert CIDR (10.0.0.0/24) to mask (10.0.0.0 255.255.255.0)."""
        ip, bits = cidr.split("/")
        mask = (0xFFFFFFFF << (32 - int(bits))) & 0xFFFFFFFF
        mask_str = ".".join(str((mask >> (8 * i)) & 0xFF) for i in range(3, -1, -1))
        return f"{ip} {mask_str}"


# Usage
with FortiManagerClient() as fmg:
    mgr = AddressManager(fmg)

    mgr.create("NET_WEB", "192.168.10.0/24", "Web servers")
    addresses = mgr.read(filter_pattern="NET_*")
    mgr.update("NET_WEB", comment="Production web servers")
    mgr.delete("NET_WEB")
```

---

## ⚠️ Error Handling

### Exception Hierarchy

```
FMGError (base)
├── FMGAuthError (-11)
├── FMGRequestError (generic)
├── FMGObjectNotFoundError (-2)
├── FMGObjectExistsError (-3)
└── FMGPermissionError (-6)
```

### Handling Errors

```python
from utils.fmg_client import FortiManagerClient
from utils.exceptions import (
    FMGObjectExistsError,
    FMGObjectNotFoundError,
    FMGPermissionError
)

with FortiManagerClient() as fmg:

    # Create or update pattern
    try:
        fmg.add(url, data)
    except FMGObjectExistsError:
        fmg.update(url, data)  # Already exists, update instead

    # Safe delete
    try:
        fmg.delete(url)
    except FMGObjectNotFoundError:
        pass  # Already deleted

    # Permission check
    try:
        fmg.add(admin_url, data)
    except FMGPermissionError as e:
        print(f"Need admin rights: {e}")
```

---

## ✅ Best Practices

### 1. Use Context Managers

```python
# Good: Automatic cleanup
with FortiManagerClient() as fmg:
    fmg.get(...)

# Bad: Manual management
fmg = FortiManagerClient()
fmg.login()
fmg.get(...)
fmg.logout()  # Might not be called on error!
```

### 2. Use Type Hints

```python
from typing import List, Dict, Optional

def get_addresses(
    fmg: FortiManagerClient,
    filter_pattern: Optional[str] = None
) -> List[Dict[str, Any]]:
    """Get addresses with optional filtering."""
    ...
```

### 3. Create Domain Classes

```python
# Instead of raw API calls everywhere...
class FirewallManager:
    def __init__(self, fmg: FortiManagerClient):
        self.addresses = AddressManager(fmg)
        self.services = ServiceManager(fmg)
        self.policies = PolicyManager(fmg)

with FortiManagerClient() as fmg:
    fw = FirewallManager(fmg)
    fw.addresses.create("NET_WEB", "10.0.0.0/24")
    fw.policies.create(srcaddr=["NET_WEB"], ...)
```

### 4. Enable Debug Mode

```bash
# In .env
FMG_DEBUG=true
```

This prints raw JSON requests and responses.

---

## ⚖️ Comparison with Level 1 (PowerShell)

| Aspect | PowerShell | Python + requests |
|--------|------------|-------------------|
| Structure | Script files | Classes and modules |
| Error handling | Status codes | Custom exceptions |
| Session | Manual variable | Context manager |
| Reusability | Functions | Classes with inheritance |
| Documentation | Comments | Docstrings + type hints |

---

## ⏭️ Next Steps

Once you're comfortable with this approach:

1. **Try pyFMG** (`03-python-pyfmg/`) - See how an official library simplifies things
2. **Explore Ansible** (`04-ansible/`) - Declarative automation

---

## 🔗 Reference

### Documentation

- [Main README](../README.md)
- [Introduction](../docs/00-introduction.md) - FortiManager overview
- [JSON-RPC Concepts](../docs/01-concepts-json-rpc.md) - Request structure, methods
- [Authentication](../docs/02-authentication.md) - Session vs Bearer token
- [Covered Operations](../docs/03-covered-operations.md) - Supported objects
- [Best Practices](../docs/04-best-practices.md) - Security and code quality

### Quick Reference

- [API Endpoints Cheatsheet](../cheatsheets/api-endpoints.md)
- [Common Errors](../cheatsheets/common-errors.md)

### External

- [pyFMG Documentation](https://github.com/p4r4n0y1ng/pyfmg)
