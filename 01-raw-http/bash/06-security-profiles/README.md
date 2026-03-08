# Security Profile Scripts

[Home](../../../README.md) > [Raw HTTP](../../README.md) > [Bash](../README.md) > Security Profiles

## Overview

CRUD operations for security profiles and application groups.

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **Application Group** | `/pm/config/adom/{adom}/obj/application/group` |
| **Web Filter Profile** | `/pm/config/adom/{adom}/obj/webfilter/profile` |
| **AV Profile** | `/pm/config/adom/{adom}/obj/antivirus/profile` |

---

## Scripts

| Script | Description |
|--------|-------------|
| `crud-app-groups.sh` | **Full CRUD** for application groups |

---

## Application Categories

| Category | Examples |
|----------|----------|
| **Social Media** | *Facebook, Twitter, Instagram, LinkedIn* |
| **Video Streaming** | *YouTube, Netflix, Twitch* |
| **Cloud Storage** | *Dropbox, Google Drive, OneDrive* |
| **Gaming** | *Steam, Xbox Live, PlayStation Network* |

---

## Examples

### Create Application Group

```bash
# Block social media
./crud-app-groups.sh -a create -n SOCIAL_MEDIA_BLOCK \
    --apps "Facebook,Twitter,Instagram,TikTok" \
    -c "Social media apps to block"

# Allow business apps
./crud-app-groups.sh -a create -n BUSINESS_APPS \
    --apps "Salesforce,Slack,Microsoft.Teams,Zoom" \
    -c "Allowed business applications"
```

### Read Application Groups

```bash
# List all groups
./crud-app-groups.sh -a read

# Get specific group
./crud-app-groups.sh -a read -n SOCIAL_MEDIA_BLOCK

# JSON output
./crud-app-groups.sh -a read -j
```

### Update Application Group

```bash
# Add more apps
./crud-app-groups.sh -a update -n SOCIAL_MEDIA_BLOCK \
    --apps "Facebook,Twitter,Instagram,TikTok,LinkedIn"

# Update comment
./crud-app-groups.sh -a update -n SOCIAL_MEDIA_BLOCK \
    -c "Updated social media list"
```

### Delete Application Group

```bash
./crud-app-groups.sh -a delete -n SOCIAL_MEDIA_BLOCK
```

---

## Options Reference

| Option | Description | Required |
|--------|-------------|----------|
| `-a` | **Action**: `create`, `read`, `update`, `delete` | *Yes* |
| `-n` | Group **name** | *Yes* (except read all) |
| `--apps` | **Applications** (comma-separated) | *Yes* (create) |
| `-c` | **Comment** | *No* |
| `-j` | JSON output | *No* |

---

## See Also

- [PowerShell Equivalent](../../powershell/06-security-profiles/)
- [Previous: NAT/VIP](../05-nat-vip/)
- [API Endpoints Cheatsheet](../../../cheatsheets/api-endpoints.md)
