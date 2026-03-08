# Level 1: Bash/cURL

> **Raw HTTP/JSON-RPC automation using Bash scripts and cURL on Linux/macOS.**

[Home](../../README.md) > [Level 1](../README.md) > Bash

---

## 📋 Overview

This section provides **Bash scripts** for automating FortiManager API operations on Linux/macOS systems. These scripts are the equivalent of the [PowerShell scripts](../powershell/).

**Why Bash/cURL?**
- Native on Linux/macOS - minimal dependencies
- Universal and lightweight
- Easy CI/CD integration

---

## 📦 Prerequisites

| Tool | Purpose | Installation |
|------|---------|--------------|
| **bash** | Shell (4.0+) | Pre-installed |
| **curl** | HTTP client | Pre-installed |
| **jq** | JSON parser | `apt install jq` / `brew install jq` |

### Environment Setup

```bash
# Copy and configure .env file at project root
cp .env.example .env
nano .env
```

Required variables: `FMG_HOST`, `FMG_PORT`, `FMG_USERNAME`, `FMG_PASSWORD` (or `FMG_API_KEY`), `FMG_ADOM`

---

## 📁 Directory Structure

```
📂 01-raw-http/bash/
├── 📂 config/
│   └── 🔧 fmg-config.sh         # Configuration loader
├── 📂 utils/
│   └── 📜 fmg-request.sh        # JSON-RPC helper functions
├── 📂 01-auth/                  # Authentication scripts
├── 📂 02-addresses/             # Address management
├── 📂 03-services/              # Service management
├── 📂 04-schedules/             # Schedule management
├── 📂 05-nat-vip/               # NAT configuration
├── 📂 06-security-profiles/     # Security profiles
└── 📂 07-firewall-policies/     # Policies + installation
```

---

## 🚀 Quick Start

```bash
# 1. Make scripts executable
chmod +x 01-raw-http/bash/**/*.sh

# 2. Test connection (Bearer token recommended)
./01-auth/login-bearer.sh

# 3. Or use session-based auth
SESSION=$(./01-auth/login-session.sh)
./02-addresses/read-addresses.sh -S "$SESSION"
./01-auth/logout.sh "$SESSION"
```

---

## 💡 Usage Examples

### Addresses

```bash
./02-addresses/create-address.sh -n NET_SERVERS -s 10.10.10.0/24 -c "Server network"
./02-addresses/read-addresses.sh -f "NET_*"
./02-addresses/update-address.sh -n NET_SERVERS -c "Updated comment"
./02-addresses/delete-address.sh -n NET_SERVERS -f
```

### Services

```bash
./03-services/crud-services.sh -a create -n TCP_8443 -t 8443 -c "Custom HTTPS"
./03-services/crud-services.sh -a read
./03-services/crud-services.sh -a delete -n TCP_8443
```

### Firewall Policies

```bash
./07-firewall-policies/crud-policies.sh -a create -n "Allow-Web" \
    --srcintf "port1" --dstintf "port2" \
    --srcaddr "all" --dstaddr "NET_SERVERS" \
    --service "HTTP,HTTPS" --policy-action accept

./07-firewall-policies/install-package.sh -d FGT-01 -p default
```

---

## 🔧 Helper Functions

The `utils/fmg-request.sh` provides reusable functions:

```bash
source ./config/fmg-config.sh
source ./utils/fmg-request.sh

fmg_get "/pm/config/adom/root/obj/firewall/address"
fmg_add "/pm/config/adom/root/obj/firewall/address" '{"name":"TEST",...}'
fmg_update "/pm/config/adom/root/obj/firewall/address/TEST" '{"comment":"Updated"}'
fmg_delete "/pm/config/adom/root/obj/firewall/address/TEST"
```

---

## 🔍 Debug Mode

```bash
export FMG_DEBUG=true
./02-addresses/read-addresses.sh
```

---

## 🔗 See Also

- [PowerShell Scripts](../powershell/) - Windows equivalent
- [cURL Examples](../../cheatsheets/curl-examples.md) - One-liner examples
- [Authentication Guide](../../docs/02-authentication.md) - Auth methods
