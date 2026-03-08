# Level 1: Bash/cURL for Linux

> **Raw HTTP/JSON-RPC automation using Bash scripts and cURL on Linux.**

---

## Overview

This section provides **Bash scripts** for automating FortiManager API operations on Linux systems. These scripts are the equivalent of the PowerShell scripts in `01-powershell-curl/`.

### Why Bash/cURL?

- **Native on Linux** - No additional tools needed (just `jq` for JSON parsing)
- **Universal** - Works on any Unix-like system
- **Lightweight** - Minimal dependencies
- **Scriptable** - Easy to integrate in CI/CD pipelines

---

## Prerequisites

### Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| **`bash`** | *Shell (4.0+)* | Pre-installed |
| **`curl`** | *HTTP client* | Pre-installed |
| **`jq`** | *JSON parser* | `apt install jq` / `yum install jq` |

### Environment Setup

```bash
# Copy and configure .env file
cp .env.example .env
nano .env

# Required variables:
FMG_HOST=192.168.1.100
FMG_PORT=443
FMG_USERNAME=api_admin    # For session auth
FMG_PASSWORD=password     # For session auth
FMG_API_KEY=your_key      # For Bearer auth (recommended)
FMG_ADOM=root
FMG_VERIFY_SSL=false      # Set to 'true' in production
```

---

## Directory Structure

```
01-bash-curl/
│
├── 📄 README.md                    # This file
├── 📁 config/
│   └── 📄 fmg-config.sh            # ⚙️ Configuration loader
├── 📁 utils/
│   └── 📄 fmg-request.sh           # 🔧 JSON-RPC helper functions
├── 📁 01-auth/                     # 🔐 Authentication
│   ├── 📄 login-session.sh         # Session-based login
│   ├── 📄 login-bearer.sh          # Test Bearer token
│   └── 📄 logout.sh                # Close session
├── 📁 02-addresses/                # 🏠 Address management
│   ├── 📄 create-address.sh        # Create address
│   ├── 📄 read-addresses.sh        # List/filter addresses
│   ├── 📄 update-address.sh        # Modify address
│   ├── 📄 delete-address.sh        # Delete address
│   └── 📄 manage-groups.sh         # Address groups CRUD
├── 📁 03-services/                 # 🔌 Service management
│   └── 📄 crud-services.sh         # Services CRUD
├── 📁 04-schedules/                # 📅 Schedule management
│   └── 📄 crud-schedules.sh        # Schedules CRUD
├── 📁 05-nat-vip/                  # 🔀 NAT configuration
│   ├── 📄 crud-vip.sh              # VIP (DNAT) CRUD
│   └── 📄 crud-ippool.sh           # IP Pool (SNAT) CRUD
├── 📁 06-security-profiles/        # 🛡️ Security profiles
│   └── 📄 crud-app-groups.sh       # Application groups CRUD
└── 📁 07-firewall-policies/        # 🔥 Firewall policies
    ├── 📄 crud-policies.sh         # Policies CRUD
    └── 📄 install-package.sh       # Policy installation
```

---

## Quick Start

### 1. Make Scripts Executable

```bash
chmod +x 01-bash-curl/**/*.sh
```

### 2. Test Connection

**With Bearer Token (Recommended):**
```bash
./01-auth/login-bearer.sh
```

**With Session:**
```bash
# Login
SESSION=$(./01-auth/login-session.sh)

# Use session in subsequent calls
./02-addresses/read-addresses.sh -S "$SESSION"

# Logout
./01-auth/logout.sh "$SESSION"
```

### 3. Basic Operations

```bash
# Create an address
./02-addresses/create-address.sh -n NET_SERVERS -s 10.10.10.0/24 -c "Server network"

# List addresses
./02-addresses/read-addresses.sh

# Filter addresses
./02-addresses/read-addresses.sh -f "NET_*"

# Update address
./02-addresses/update-address.sh -n NET_SERVERS -c "Updated comment"

# Delete address
./02-addresses/delete-address.sh -n NET_SERVERS -f
```

---

## Usage Examples

### Authentication

```bash
# Bearer token (no login/logout needed)
export FMG_API_KEY="your_api_key"
./02-addresses/read-addresses.sh

# Session-based
SESSION=$(./01-auth/login-session.sh)
./02-addresses/read-addresses.sh -S "$SESSION"
./01-auth/logout.sh "$SESSION"
```

### Addresses

```bash
# Create
./02-addresses/create-address.sh -n HOST_WEB -s 192.168.1.10/32 -c "Web server"

# Read all
./02-addresses/read-addresses.sh

# Read with filter
./02-addresses/read-addresses.sh -f "HOST_*"

# Read specific
./02-addresses/read-addresses.sh -n HOST_WEB

# Update
./02-addresses/update-address.sh -n HOST_WEB -s 192.168.1.20/32

# Delete
./02-addresses/delete-address.sh -n HOST_WEB -f

# JSON output
./02-addresses/read-addresses.sh -j | jq '.[] | .name'
```

### Services

```bash
# Create TCP service
./03-services/crud-services.sh -a create -n TCP_8443 -t 8443 -c "Custom HTTPS"

# Create UDP service
./03-services/crud-services.sh -a create -n UDP_SYSLOG -u 514 -c "Syslog"

# List services
./03-services/crud-services.sh -a read

# Delete
./03-services/crud-services.sh -a delete -n TCP_8443
```

### Firewall Policies

```bash
# Create policy
./07-firewall-policies/crud-policies.sh -a create \
    -n "Allow-Web" \
    --srcintf "port1" \
    --dstintf "port2" \
    --srcaddr "all" \
    --dstaddr "NET_SERVERS" \
    --service "HTTP,HTTPS" \
    --policy-action accept \
    --nat enable

# List policies
./07-firewall-policies/crud-policies.sh -a read

# Update policy
./07-firewall-policies/crud-policies.sh -a update -i 5 -c "Updated policy"

# Move policy
./07-firewall-policies/crud-policies.sh -a move -i 5 --move-target 2 --move-option before

# Delete policy
./07-firewall-policies/crud-policies.sh -a delete -i 5

# Install to device
./07-firewall-policies/install-package.sh -d FGT-01 -p default

# Preview installation
./07-firewall-policies/install-package.sh -d FGT-01 --preview
```

---

## Helper Functions

The `utils/fmg-request.sh` provides reusable functions:

```bash
source ./config/fmg-config.sh
source ./utils/fmg-request.sh

# Low-level request
fmg_request "get" "/pm/config/adom/root/obj/firewall/address"

# Convenience functions
fmg_get "/pm/config/adom/root/obj/firewall/address"
fmg_add "/pm/config/adom/root/obj/firewall/address" '{"name":"TEST","type":"ipmask","subnet":"10.0.0.0 255.0.0.0"}'
fmg_update "/pm/config/adom/root/obj/firewall/address/TEST" '{"comment":"Updated"}'
fmg_delete "/pm/config/adom/root/obj/firewall/address/TEST"
fmg_exec "/sys/logout"

# Helper functions
cidr_to_mask "10.0.0.0/24"        # Returns: 10.0.0.0 255.255.255.0
fmg_is_success "$RESPONSE"         # Check if request succeeded
fmg_get_data "$RESPONSE"           # Extract data from response
fmg_get_error "$RESPONSE"          # Get error message

# Output helpers
print_success "Done!"
print_error "Failed!"
print_warning "Check this"
print_info "Processing..."
```

---

## Debug Mode

Enable debug output to see raw requests/responses:

```bash
export FMG_DEBUG=true
./02-addresses/read-addresses.sh
```

---

## Error Handling

All scripts return proper exit codes:
- `0` - Success
- `1` - Error (see stderr for details)

```bash
if ./02-addresses/create-address.sh -n TEST -s 10.0.0.0/24; then
    echo "Success"
else
    echo "Failed"
fi
```

---

## Comparison: PowerShell vs Bash

| Aspect | PowerShell | Bash |
|--------|------------|------|
| **Platform** | *Windows/Linux/macOS* | *Linux/macOS/WSL* |
| **JSON parsing** | *Built-in* | *Requires `jq`* |
| **Arguments** | *Named params* | *getopts* |
| **Output** | *Objects* | *Text/JSON* |
| **Colors** | *Write-Host* | *ANSI codes* |

---

## See Also

| Resource | Description |
|----------|-------------|
| **[PowerShell Scripts](../01-powershell-curl/)** | *Windows equivalent* |
| **[cURL Examples](../cheatsheets/curl-examples.md)** | *One-liner cURL examples* |
| **[Authentication Guide](../docs/02-authentication.md)** | *Auth methods explained* |
