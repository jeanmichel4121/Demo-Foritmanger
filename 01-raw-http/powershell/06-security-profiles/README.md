# 🛡️ Security Profile Scripts

> **CRUD operations for security profiles and application groups.**

[Home](../../../README.md) > [Level 1](../../README.md) > [PowerShell](../README.md) > Security Profiles

---

## 📋 Overview

Security profiles enable deep inspection and control of traffic - including application control, web filtering, and content inspection. This section covers application groups and URL filters.

For complete API reference, see the [Covered Operations Guide](../../../docs/03-covered-operations.md).

---

## 🔗 API Endpoints

| Type | Endpoint |
|------|----------|
| **Application Group** | `/pm/config/adom/{adom}/obj/application/group` |
| **URL Filter** | `/pm/config/adom/{adom}/obj/webfilter/urlfilter` |
| **Web Filter Profile** | `/pm/config/adom/{adom}/obj/webfilter/profile` |
| **AV Profile** | `/pm/config/adom/{adom}/obj/antivirus/profile` |

---

## 📜 Scripts

| Script | Description |
|--------|-------------|
| `crud-app-groups.ps1` | **Full CRUD** for application groups |
| `crud-url-filter.ps1` | **Full CRUD** for URL filters |

---

## 🔧 Application Categories

| Category | Examples |
|----------|----------|
| **Social Media** | *Facebook, Twitter, Instagram, LinkedIn, TikTok* |
| **Video Streaming** | *YouTube, Netflix, Twitch, Disney+* |
| **Cloud Storage** | *Dropbox, Google Drive, OneDrive, iCloud* |
| **Gaming** | *Steam, Xbox Live, PlayStation Network* |
| **Business** | *Salesforce, Slack, Microsoft Teams, Zoom* |

---

## 💡 Application Group Examples

### Create Application Group

```powershell
# Block social media
.\crud-app-groups.ps1 -Action create -Name "SOCIAL_MEDIA_BLOCK" `
    -Applications @("Facebook", "Twitter", "Instagram", "TikTok") `
    -Comment "Social media apps to block"

# Allow business apps
.\crud-app-groups.ps1 -Action create -Name "BUSINESS_APPS" `
    -Applications @("Salesforce", "Slack", "Microsoft.Teams", "Zoom") `
    -Comment "Allowed business applications"

# Block gaming
.\crud-app-groups.ps1 -Action create -Name "GAMING_BLOCK" `
    -Applications @("Steam", "Xbox.Live", "PlayStation.Network") `
    -Comment "Gaming platforms to block"
```

### Read Application Groups

```powershell
# List all groups
.\crud-app-groups.ps1 -Action read

# Get specific group
.\crud-app-groups.ps1 -Action read -Name "SOCIAL_MEDIA_BLOCK"

# JSON output
.\crud-app-groups.ps1 -Action read -AsJson | ConvertFrom-Json
```

### Update Application Group

```powershell
# Add more apps
.\crud-app-groups.ps1 -Action update -Name "SOCIAL_MEDIA_BLOCK" `
    -Applications @("Facebook", "Twitter", "Instagram", "TikTok", "LinkedIn")

# Update comment
.\crud-app-groups.ps1 -Action update -Name "SOCIAL_MEDIA_BLOCK" `
    -Comment "Updated social media list"
```

### Delete Application Group

```powershell
.\crud-app-groups.ps1 -Action delete -Name "SOCIAL_MEDIA_BLOCK"
```

---

## 💡 URL Filter Examples

### Create URL Filter

```powershell
# Block gambling sites
.\crud-url-filter.ps1 -Action create -Name "BLOCK_GAMBLING" `
    -Entries @(
        @{url="*.gambling.com"; action="block"},
        @{url="*.casino.com"; action="block"},
        @{url="*.bet365.com"; action="block"}
    ) `
    -Comment "Block gambling websites"

# Allow specific sites
.\crud-url-filter.ps1 -Action create -Name "ALLOW_BUSINESS" `
    -Entries @(
        @{url="*.microsoft.com"; action="allow"},
        @{url="*.office365.com"; action="allow"}
    )
```

### Read URL Filters

```powershell
# List all filters
.\crud-url-filter.ps1 -Action read

# Get specific filter
.\crud-url-filter.ps1 -Action read -Name "BLOCK_GAMBLING"
```

### Delete URL Filter

```powershell
.\crud-url-filter.ps1 -Action delete -Name "BLOCK_GAMBLING"
```

---

## ⚙️ Options Reference

### crud-app-groups.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Action` | `create`, `read`, `update`, `delete` | **Yes** |
| `-Name` | Group **name** | **Yes** (except read all) |
| `-Applications` | Array of **application** names | **Yes** (create) |
| `-Comment` | Description | No |
| `-AsJson` | Output as **JSON** | No |

### crud-url-filter.ps1

| Parameter | Description | Required |
|-----------|-------------|----------|
| `-Action` | `create`, `read`, `update`, `delete` | **Yes** |
| `-Name` | Filter **name** | **Yes** (except read all) |
| `-Entries` | Array of **URL entries** | **Yes** (create) |
| `-Comment` | Description | No |
| `-AsJson` | Output as **JSON** | No |

### URL Entry Format

```powershell
@{
    url = "*.example.com"    # URL pattern (wildcards supported)
    action = "block"         # "block", "allow", "monitor"
}
```

---

## 🔗 See Also

- [Bash Equivalent](../../bash/06-security-profiles/)
- [Previous: NAT/VIP](../05-nat-vip/)
- [Next: Firewall Policies](../07-firewall-policies/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
