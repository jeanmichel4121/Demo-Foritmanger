# 🔥 Firewall Policy Scripts

> **CRUD operations for firewall policies and policy package installation.**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > Firewall Policies

---

## 📋 Overview

Firewall policies are the core of FortiGate security - they control what traffic is allowed, denied, or inspected. This section covers policy CRUD operations and deployment to FortiGates.

![Policy Installation Workflow](../../../diagrams/05-policy-installation-workflow.png)

---

## 🔗 API Endpoints

| Type | Endpoint |
|------|----------|
| **Firewall Policy** | `/pm/config/adom/{adom}/pkg/{pkg}/firewall/policy` |
| **Install Package** | `/securityconsole/install/package` |
| **Install Preview** | `/securityconsole/install/preview` |

---

## 📜 Scripts

| Script | Description |
|--------|-------------|
| `crud-policies.ps1` | **Full CRUD** + move for firewall policies |
| `install-package.ps1` | **Install** policy package to devices |

---

## 🔧 Policy Actions

| Action | Description |
|--------|-------------|
| **accept** | *Allow traffic* |
| **deny** | *Block traffic (silent)* |
| **reject** | *Block with ICMP response* |

---

## 💡 Examples

### Create Policy

```powershell
# Allow web traffic
.\crud-policies.ps1 -Action create -Package "default" `
    -Name "Allow-Web-Traffic" `
    -SrcIntf "port1" `
    -DstIntf "port2" `
    -SrcAddr "all" `
    -DstAddr "NET_SERVERS" `
    -Service @("HTTP", "HTTPS") `
    -PolicyAction accept `
    -NAT enable `
    -Comment "Allow web to servers"

# Block social media
.\crud-policies.ps1 -Action create -Package "default" `
    -Name "Block-Social" `
    -SrcIntf "port1" `
    -DstIntf "port3" `
    -SrcAddr "NET_USERS" `
    -DstAddr "all" `
    -Service @("ALL") `
    -PolicyAction deny `
    -Comment "Block social media"
```

### Read Policies

```powershell
# List all policies
.\crud-policies.ps1 -Action read -Package "default"

# Get specific policy by ID
.\crud-policies.ps1 -Action read -Package "default" -PolicyID 5

# JSON output
.\crud-policies.ps1 -Action read -Package "default" -AsJson | ConvertFrom-Json
```

### Update Policy

```powershell
# Update comment
.\crud-policies.ps1 -Action update -Package "default" -PolicyID 5 `
    -Comment "Updated policy comment"

# Change action
.\crud-policies.ps1 -Action update -Package "default" -PolicyID 5 `
    -PolicyAction deny
```

### Move Policy

```powershell
# Move policy 5 before policy 2
.\crud-policies.ps1 -Action move -Package "default" -PolicyID 5 `
    -MoveTarget 2 -MoveOption before

# Move policy 3 after policy 10
.\crud-policies.ps1 -Action move -Package "default" -PolicyID 3 `
    -MoveTarget 10 -MoveOption after
```

### Delete Policy

```powershell
.\crud-policies.ps1 -Action delete -Package "default" -PolicyID 5
```

---

## 📦 Policy Installation

### Preview Changes

```powershell
# Preview before installing (recommended)
.\install-package.ps1 -Device "FGT-01" -Package "default" -Preview
```

### Install Package

```powershell
# Install to single device
.\install-package.ps1 -Device "FGT-01" -Package "default" -VDOM "root"

# Install to multiple devices
.\install-package.ps1 -Device @("FGT-01", "FGT-02") -Package "default"

# Wait for completion
.\install-package.ps1 -Device "FGT-01" -Package "default" -Wait
```

### Check Task Status

```powershell
# Installation returns task ID - retrieve status
$result = .\install-package.ps1 -Device "FGT-01" -Package "default"
$taskId = $result.task

# Check status (using generic API call)
# GET /task/task/{task_id}
```

---

## ⚙️ Options Reference

### crud-policies.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Action` | `create`, `read`, `update`, `delete`, `move` | **Yes** |
| `-Package` | Policy **package** name | **Yes** |
| `-PolicyID` | Policy **ID** | **Yes** (update/delete/move) |
| `-Name` | Policy **name** | **Yes** (create) |
| `-SrcIntf` | **Source** interface | **Yes** (create) |
| `-DstIntf` | **Destination** interface | **Yes** (create) |
| `-SrcAddr` | **Source** address | **Yes** (create) |
| `-DstAddr` | **Destination** address | **Yes** (create) |
| `-Service` | **Services** array | **Yes** (create) |
| `-PolicyAction` | `accept`, `deny`, `reject` | **Yes** (create) |
| `-NAT` | `enable`, `disable` | No |
| `-LogTraffic` | `all`, `utm`, `disable` | No |
| `-MoveTarget` | Target policy **ID** for move | **Yes** (move) |
| `-MoveOption` | `before`, `after` | **Yes** (move) |
| `-Comment` | Description | No |
| `-AsJson` | Output as **JSON** | No |

### install-package.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Device` | **Device** name(s) | **Yes** |
| `-Package` | **Package** name | No (default: default) |
| `-VDOM` | **VDOM** name | No (default: root) |
| `-Preview` | Preview only (*dry-run*) | No |
| `-Wait` | Wait for completion | No |

---

## 📋 Policy Fields Reference

| Field | Description | Values |
|-------|-------------|--------|
| `name` | Policy name | String |
| `srcintf` | Source interface(s) | Array |
| `dstintf` | Destination interface(s) | Array |
| `srcaddr` | Source address(es) | Array |
| `dstaddr` | Destination address(es) | Array |
| `service` | Service(s) | Array |
| `action` | Policy action | `accept`, `deny` |
| `schedule` | Schedule | String (default: always) |
| `nat` | NAT enable | `enable`, `disable` |
| `logtraffic` | Logging | `all`, `utm`, `disable` |
| `status` | Policy status | `enable`, `disable` |

---

## ✅ Best Practices

| Practice | Reason |
|----------|--------|
| **Always preview first** | *Avoid unexpected changes* |
| **Use descriptive names** | *Easier troubleshooting* |
| **Comment all policies** | *Document purpose* |
| **Order matters** | *First match wins* |

---

## 🔗 See Also

- [Bash Equivalent](../../bash/07-firewall-policies/)
- [Previous: Security Profiles](../06-security-profiles/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
- [Common Errors](../../../cheatsheets/common-errors.md)
- [Policy Installation Diagram](../../../diagrams/05-policy-installation-workflow.png)
