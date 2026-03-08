# Firewall Policy Management

CRUD scripts for firewall policies and installation workflow.

## Endpoints

| Type | Endpoint |
|------|----------|
| Policy | `/pm/config/adom/{adom}/pkg/{package}/firewall/policy` |
| Install | `/securityconsole/install/package` |

## Scripts

| Script | Description |
|--------|-------------|
| `crud-policies.ps1` | CRUD operations on policies |
| `install-package.ps1` | Policy package installation |

## Workflow

1. Create/modify objects (addresses, services, etc.)
2. Create/modify policies
3. Install policy package to FortiGates

## Examples

```powershell
# Create a policy
.\crud-policies.ps1 -Action create -Package "default" `
    -Name "Allow_Web" -SrcIntf "port1" -DstIntf "port2" `
    -SrcAddr "NET_USERS" -DstAddr "all" `
    -Service "HTTP,HTTPS" -ActionPolicy "accept"

# List policies
.\crud-policies.ps1 -Action read -Package "default"

# Install
.\install-package.ps1 -Package "default" -Device "FGT-01"
```

## Policy Fields

| Field | Description |
|-------|-------------|
| name | Policy name |
| srcintf | Source interface(s) |
| dstintf | Destination interface(s) |
| srcaddr | Source address(es) |
| dstaddr | Destination address(es) |
| service | Service(s) |
| action | accept, deny |
| schedule | Schedule (default: always) |
| nat | enable/disable |
| logtraffic | all, utm, disable |
