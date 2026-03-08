# Security Profile Management

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
