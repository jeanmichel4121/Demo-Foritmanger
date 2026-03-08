# Security Profile Management

[Home](../../../README.md) > [Raw HTTP](../../README.md) > [PowerShell](../README.md) > Security Profiles

## Overview

CRUD scripts for application profiles.

## Endpoints

| Type | Endpoint |
|------|----------|
| Application Group | `/pm/config/adom/{adom}/obj/application/group` |
| URL Filter | `/pm/config/adom/{adom}/obj/webfilter/urlfilter` |

## Scripts

| Script | Description |
|--------|-------------|
| `crud-app-groups.ps1` | Application groups |
| `crud-url-filter.ps1` | URL filters |

## Examples

```powershell
# Create an application group
.\crud-app-groups.ps1 -Action create -Name "SOCIAL_MEDIA" `
    -Applications @("Facebook", "Twitter", "Instagram")

# Create a URL filter
.\crud-url-filter.ps1 -Action create -Name "BLOCK_GAMBLING" `
    -Entries @(@{url="*.gambling.com"; action="block"})
```

## See Also

- [Bash Equivalent](../../bash/06-security-profiles/)
- [Previous: NAT/VIP](../05-nat-vip/)
- [Next: Firewall Policies](../07-firewall-policies/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
