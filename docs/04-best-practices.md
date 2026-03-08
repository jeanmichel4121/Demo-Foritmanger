# Best Practices

> **Guidelines for secure, maintainable, and production-ready FortiManager automation.**

[Home](../README.md) > [Docs](./) > Best Practices

---

## Security

### Credential Management

| Practice | Description |
|----------|-------------|
| **Never commit credentials** | Use `.env` files and add to `.gitignore` |
| **Use API Keys** | More secure than session-based for automation (FMG 7.2.2+) |
| **Validate SSL in production** | Set `FMG_VERIFY_SSL=true` |
| **Least privilege** | Create API users with minimal required permissions |

```bash
# .gitignore
.env
*.env
credentials.json
```

### API Key vs Session Authentication

| Criteria | API Key (Bearer) | Session-based |
|----------|------------------|---------------|
| **Best for** | Automation, CI/CD | Interactive scripts |
| **FMG Version** | 7.2.2+ required | All versions |
| **State** | Stateless | Requires logout |
| **Security** | Higher | Lower (password in memory) |

**Recommendation:** Use API Keys for production automation.

---

## Code Quality

### Always Check Status Codes

```python
# Python example
code = response["result"][0]["status"]["code"]
if code != 0:
    raise Exception(f"API error: {response['result'][0]['status']['message']}")
```

```powershell
# PowerShell example
if ($result.code -ne 0) {
    throw "API error: $($result.message)"
}
```

### Use Idempotent Operations

Prefer `set` over `add` for create-or-update patterns:

```python
# Instead of checking existence first...
try:
    fmg.add(url, data)
except ObjectExistsError:
    fmg.update(url, data)

# Use 'set' for idempotent operations
fmg.set(url, data)  # Creates or replaces
```

### Enable Debug Mode for Development

```bash
# In .env
FMG_DEBUG=true
```

This shows raw requests and responses for troubleshooting.

### Document Complex Operations

```python
def create_policy_with_dependencies(name: str, src_addr: str, dst_addr: str):
    """
    Create a firewall policy with all required dependencies.

    Steps:
    1. Create source address if not exists
    2. Create destination address if not exists
    3. Create the policy referencing both

    Args:
        name: Policy name
        src_addr: Source address CIDR
        dst_addr: Destination address CIDR
    """
    ...
```

---

## Operations

### Preview Before Install

Always preview changes before installing to production FortiGates:

```python
# Preview first
fmg.execute("/securityconsole/install/preview", adom=ADOM, pkg=PKG)

# Review in FortiManager UI or via API

# Then install
fmg.execute("/securityconsole/install/package", adom=ADOM, pkg=PKG, scope=[...])
```

### Test in Lab Environment

```
Development -> Lab FMG -> Staging FMG -> Production FMG
     |            |            |              |
  Write code   Test API    Validate       Deploy
```

### Backup Before Bulk Operations

Before bulk modifications:

1. Export current configuration
2. Document rollback procedure
3. Test rollback in non-production

### Monitor Long-Running Tasks

```python
# Installation tasks are asynchronous
code, task = fmg.execute("/securityconsole/install/package", ...)
task_id = task["task"]

# Poll for completion
while True:
    code, status = fmg.get(f"/task/task/{task_id}")
    if status["state"] in [4, 5]:  # Done or Error
        break
    time.sleep(5)
```

---

## Session Management

### Always Use Context Managers (Python)

```python
# Good: Automatic cleanup
with FortiManagerClient() as fmg:
    fmg.get(...)
# Session automatically closed, even on errors

# Bad: Manual management (error-prone)
fmg = FortiManagerClient()
fmg.login()
fmg.get(...)
fmg.logout()  # Might not be called on error!
```

### Use Try/Finally (PowerShell)

```powershell
$session = $null
try {
    $session = .\login-session.ps1
    # Your operations here
} finally {
    if ($session) {
        .\logout.ps1 -Session $session
    }
}
```

### Always Logout (Bash)

```bash
SESSION=$(./login-session.sh)
trap "./logout.sh '$SESSION'" EXIT  # Logout on script exit

# Your operations here
```

---

## Naming Conventions

### Object Naming

Use prefixes to indicate object type:

| Prefix | Object Type | Example |
|--------|-------------|---------|
| `NET_` | Network/subnet | `NET_SERVERS_DMZ` |
| `HOST_` | Single host | `HOST_WEB_01` |
| `GRP_` | Group | `GRP_ALL_SERVERS` |
| `SRV_` | Service | `SRV_HTTPS_8443` |
| `POL_` | Policy | `POL_ALLOW_WEB` |
| `VIP_` | Virtual IP | `VIP_PUBLIC_WEB` |
| `POOL_` | IP Pool | `POOL_OUTBOUND` |

### Environment Prefixes

```
DEV_NET_SERVERS     # Development
STG_NET_SERVERS     # Staging
PROD_NET_SERVERS    # Production
```

---

## Error Handling

### Common Error Codes

| Code | Meaning | Recommended Action |
|------|---------|-------------------|
| **0** | Success | Process data |
| **-2** | Object not found | Check name, ADOM, URL path |
| **-3** | Object exists | Use `update` or `set` instead |
| **-6** | Permission denied | Check user permissions |
| **-10** | Object in use | Remove references first |
| **-11** | Invalid session | Re-authenticate |
| **-20** | Invalid URL/Syntax | Check endpoint path |
| **-10147** | No write permission | Lock ADOM (workspace mode) |

### Graceful Error Recovery

```python
from utils.exceptions import FMGObjectExistsError, FMGObjectNotFoundError

def safe_create_or_update(fmg, url, data):
    """Create object or update if exists."""
    try:
        return fmg.add(url, data)
    except FMGObjectExistsError:
        return fmg.update(f"{url}/{data['name']}", data)

def safe_delete(fmg, url, name):
    """Delete object, ignore if not found."""
    try:
        return fmg.delete(f"{url}/{name}")
    except FMGObjectNotFoundError:
        return None  # Already deleted
```

---

## Performance

### Use Filtering

Reduce response size by filtering:

```json
{
    "filter": [["name", "like", "PROD_%"]],
    "fields": ["name", "subnet", "comment"]
}
```

### Batch Operations

Send multiple operations in one request:

```json
{
    "method": "add",
    "params": [
        {"url": "...", "data": {"name": "NET_A", ...}},
        {"url": "...", "data": {"name": "NET_B", ...}},
        {"url": "...", "data": {"name": "NET_C", ...}}
    ]
}
```

### Paginate Large Datasets

```python
offset = 0
batch_size = 100
all_data = []

while True:
    response = fmg.get(url, range=[offset, batch_size])
    data = response.get("data", [])
    if not data:
        break
    all_data.extend(data)
    offset += batch_size
```

---

## Workspace Mode

When workspace mode is enabled on FortiManager:

### Required Workflow

```
1. Lock ADOM    ->  /dvmdb/adom/{adom}/workspace/lock
2. Make changes ->  Your CRUD operations
3. Commit       ->  /dvmdb/adom/{adom}/workspace/commit
4. Unlock       ->  /dvmdb/adom/{adom}/workspace/unlock
```

### Error -10147

If you get error `-10147` (no write permission):
1. Check if workspace mode is enabled
2. Lock the ADOM before making changes
3. Use try/finally to ensure unlock

---

## CI/CD Integration

### Environment Variables

```yaml
# GitHub Actions example
env:
  FMG_HOST: ${{ secrets.FMG_HOST }}
  FMG_API_KEY: ${{ secrets.FMG_API_KEY }}
  FMG_ADOM: production
  FMG_VERIFY_SSL: true
```

### Pipeline Stages

```
1. Lint/Validate    ->  Check syntax and configuration
2. Dry-run          ->  Check mode / preview
3. Deploy (staging) ->  Apply to staging environment
4. Test             ->  Verify changes
5. Deploy (prod)    ->  Apply to production
```

### Ansible Check Mode

```bash
# Always run check mode first
ansible-playbook playbook.yml --check --diff

# Then apply
ansible-playbook playbook.yml
```

---

## See Also

- [Common Errors Cheatsheet](../cheatsheets/common-errors.md)
- [Authentication Guide](02-authentication.md)
- [Error Codes Diagram](../diagrams/08-error-codes.png)
