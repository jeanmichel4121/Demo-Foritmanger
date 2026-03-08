# FortiManager API Authentication

> **Understand session-based and API key authentication methods.**

[Home](../README.md) > [Docs](./) > Authentication

---

## 📋 Overview

FortiManager supports two authentication methods:

| Method | Available Since | Best For |
|--------|-----------------|----------|
| **Session-based** | All versions | Interactive scripts, testing |
| **Bearer Token (API Key)** | FMG 7.2.2+ | Production automation, CI/CD |

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Authentication Methods                           │
├─────────────────────────────┬───────────────────────────────────────┤
│     Session-Based           │         Bearer Token (API Key)        │
├─────────────────────────────┼───────────────────────────────────────┤
│  1. Login with credentials  │  1. Add header to request             │
│  2. Receive session token   │  2. Make API call                     │
│  3. Include in requests     │  (No login/logout needed)             │
│  4. Logout when done        │                                       │
└─────────────────────────────┴───────────────────────────────────────┘
```

---

## 🔐 Method 1: Session-Based Authentication

### Workflow

```
┌──────────┐                              ┌───────────────┐
│  Client  │                              │ FortiManager  │
└────┬─────┘                              └───────┬───────┘
     │                                            │
     │  1. POST /jsonrpc (login)                  │
     │  ─────────────────────────────────────────>│
     │                                            │
     │  2. Session token                          │
     │  <─────────────────────────────────────────│
     │                                            │
     │  3. API requests (with session)            │
     │  ─────────────────────────────────────────>│
     │                                            │
     │  4. Response                               │
     │  <─────────────────────────────────────────│
     │                                            │
     │  5. POST /jsonrpc (logout)                 │
     │  ─────────────────────────────────────────>│
     │                                            │
```

### Login Request

```json
{
    "id": 1,
    "method": "exec",
    "params": [
        {
            "url": "/sys/login/user",
            "data": {
                "user": "api_admin",
                "passwd": "your_password"
            }
        }
    ]
}
```

### Login Response

```json
{
    "id": 1,
    "session": "vKS8k3N1abc123def456ghj789klm012nop",
    "result": [
        {
            "status": {
                "code": 0,
                "message": "OK"
            },
            "url": "/sys/login/user"
        }
    ]
}
```

**Important**: Save the `session` value - you'll need it for all subsequent requests.

### Using the Session Token

Include the session in every request:

```json
{
    "id": 2,
    "method": "get",
    "params": [
        {
            "url": "/pm/config/adom/root/obj/firewall/address"
        }
    ],
    "session": "vKS8k3N1abc123def456ghj789klm012nop"
}
```

### Logout Request

Always logout to free server resources:

```json
{
    "id": 99,
    "method": "exec",
    "params": [
        {
            "url": "/sys/logout"
        }
    ],
    "session": "vKS8k3N1abc123def456ghj789klm012nop"
}
```

### Session-Based: Advantages & Disadvantages

| Advantages | Disadvantages |
|------------|---------------|
| Works with all FMG versions | Requires explicit login/logout |
| No FMG pre-configuration | Sessions can expire (timeout) |
| Familiar username/password | Password in script (less secure) |
| Good for interactive use | State management required |

---

## 🔑 Method 2: Bearer Token (API Key)

Available since **FortiManager 7.2.2**.

### Creating an API User in FortiManager

1. **Navigate to**: System Settings > Admin > Administrators
2. **Click**: Create New
3. **Configure**:
   - **User Name**: `api_automation`
   - **Admin Profile**: Select appropriate permissions
   - **User Type**: `API User`
4. **Generate API Key**: Click "Generate" and copy the key

```
┌──────────────────────────────────────────────────────────────┐
│ IMPORTANT: The API key is shown ONLY ONCE!                   │
│ Store it securely immediately after generation.              │
└──────────────────────────────────────────────────────────────┘
```

### Using the API Key

Add the `Authorization` header to your HTTP request:

```
Authorization: Bearer your_api_key_here
```

> **Important**: The URL query string method (`?access_token=key`) is **deprecated** since FMG 7.4.7 and 7.6.2. Always use the `Authorization: Bearer` header instead.

**No session field needed in the JSON body:**

```json
{
    "id": 1,
    "method": "get",
    "params": [
        {
            "url": "/pm/config/adom/root/obj/firewall/address"
        }
    ]
}
```

### cURL Example

```bash
curl -k -X POST https://192.168.1.100/jsonrpc \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer rGqsgwp1o9w9tmfjGtxhmQ81K5p5Grjb" \
  -d '{
    "id": 1,
    "method": "get",
    "params": [{"url": "/sys/status"}]
  }'
```

### Python Example

```python
import requests

API_KEY = "rGqsgwp1o9w9tmfjGtxhmQ81K5p5Grjb"
FMG_HOST = "192.168.1.100"

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {API_KEY}"
}

payload = {
    "id": 1,
    "method": "get",
    "params": [{"url": "/sys/status"}]
}

response = requests.post(
    f"https://{FMG_HOST}/jsonrpc",
    headers=headers,
    json=payload,
    verify=False
)

print(response.json())
```

### Bearer Token: Advantages & Disadvantages

| Advantages | Disadvantages |
|------------|---------------|
| No login/logout required | Requires FMG 7.2.2+ |
| No session expiration | Pre-configuration needed |
| More secure (no password) | Key compromise = regenerate |
| Simpler code | Limited to API-only access |
| Better for automation | |

---

## ⚖️ Comparison

| Aspect | Session-Based | Bearer Token |
|--------|---------------|--------------|
| **Minimum Version** | All | 7.2.2+ |
| **FMG Setup** | None | Create API User |
| **Login/Logout** | Required | Not needed |
| **Expiration** | Session timeout | Never (until revoked) |
| **Security Level** | Medium | High |
| **Code Complexity** | Medium | Low |
| **Concurrent Sessions** | Limited | Unlimited |
| **Best For** | Testing, interactive | Production, CI/CD |

---

## 💡 Recommendations

### Development & Testing

```
Use Session-Based Authentication
├── Quick setup, no FMG configuration
├── Easy to test with different users
└── Suitable for learning and debugging
```

### Production & Automation

```
Use Bearer Token (API Key)
├── No state management
├── No session timeout issues
├── Secure (no password in code)
├── Perfect for CI/CD pipelines
└── Works with scheduled tasks
```

---

## ⚠️ Error Handling

### Session Expired (-11)

```json
{
    "result": [
        {
            "status": {
                "code": -11,
                "message": "No permission for the resource"
            }
        }
    ]
}
```

**Solution**: Re-login or switch to Bearer token.

```python
def handle_session_error(fmg, error_code):
    if error_code == -11:
        print("Session expired, re-authenticating...")
        fmg.login()
        return True
    return False
```

### Invalid API Key (HTTP 401)

```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{
    "error": "Unauthorized"
}
```

**Solution**:
1. Verify the API key is correct
2. Check if the key was revoked
3. Regenerate if necessary

### Permission Denied (-6)

```json
{
    "result": [
        {
            "status": {
                "code": -6,
                "message": "No permission for the resource"
            }
        }
    ]
}
```

**Solution**: Check the admin profile assigned to the user/API key.

---

## ✅ Best Practices

### 1. Never Commit Credentials

```bash
# .gitignore
.env
*.env
secrets/
credentials.json
```

### 2. Use Environment Variables

```bash
# .env file (not committed)
FMG_HOST=192.168.1.100
FMG_USERNAME=api_admin
FMG_PASSWORD=secure_password
FMG_API_KEY=your_api_key_here
```

```python
import os
from dotenv import load_dotenv

load_dotenv()

host = os.getenv("FMG_HOST")
api_key = os.getenv("FMG_API_KEY")
```

### 3. Minimal Permissions

Create API users with only the required permissions:

| Task | Required Permissions |
|------|---------------------|
| Read objects | Read on Policy Objects |
| Modify objects | Read/Write on Policy Objects |
| Install policies | Policy Package + Device Manager |
| Full automation | Read/Write on all relevant sections |

### 4. Key Rotation

For production systems:
- Rotate API keys periodically (e.g., every 90 days)
- Have a process to update keys in all automation
- Keep old keys active briefly during transition

### 5. Always Close Sessions

When using session-based auth:

```python
# Python - Use context managers
with FortiManagerClient() as fmg:
    fmg.get(...)
# Session automatically closed

# Or use try/finally
fmg = FortiManagerClient()
fmg.login()
try:
    fmg.get(...)
finally:
    fmg.logout()
```

```powershell
# PowerShell - Use try/finally
$session = Login-FortiManager
try {
    Get-FMGAddresses -Session $session
}
finally {
    Logout-FortiManager -Session $session
}
```

### 6. Secure API Key Storage

For production:
- Use secrets management (HashiCorp Vault, AWS Secrets Manager)
- Encrypt at rest
- Audit access logs

---

## 💻 Code Examples

### PowerShell - Session-Based

```powershell
# Login
$loginPayload = @{
    id = 1
    method = "exec"
    params = @(
        @{
            url = "/sys/login/user"
            data = @{
                user = $env:FMG_USERNAME
                passwd = $env:FMG_PASSWORD
            }
        }
    )
}

$response = Invoke-RestMethod -Uri "https://$env:FMG_HOST/jsonrpc" `
    -Method Post `
    -Body ($loginPayload | ConvertTo-Json -Depth 10) `
    -SkipCertificateCheck

$session = $response.session

# Use session...

# Logout
$logoutPayload = @{
    id = 99
    method = "exec"
    params = @(@{ url = "/sys/logout" })
    session = $session
}

Invoke-RestMethod -Uri "https://$env:FMG_HOST/jsonrpc" `
    -Method Post `
    -Body ($logoutPayload | ConvertTo-Json) `
    -SkipCertificateCheck
```

### Python - Bearer Token

```python
import os
import requests
from dotenv import load_dotenv

load_dotenv()

class FortiManagerAPI:
    def __init__(self):
        self.host = os.getenv("FMG_HOST")
        self.api_key = os.getenv("FMG_API_KEY")
        self.base_url = f"https://{self.host}/jsonrpc"
        self.headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }

    def request(self, method: str, url: str, data: dict = None) -> dict:
        payload = {
            "id": 1,
            "method": method,
            "params": [{"url": url}]
        }
        if data:
            payload["params"][0]["data"] = data

        response = requests.post(
            self.base_url,
            headers=self.headers,
            json=payload,
            verify=False
        )
        return response.json()

# Usage
api = FortiManagerAPI()
result = api.request("get", "/sys/status")
print(result)
```

---

## 🔍 Troubleshooting

| Problem | Possible Cause | Solution |
|---------|----------------|----------|
| Login fails | Wrong credentials | Verify username/password |
| Session invalid | Timeout | Re-login or use API key |
| 401 Unauthorized | Invalid API key | Check/regenerate key |
| Permission denied | Insufficient rights | Check admin profile |
| Connection refused | Network/firewall | Check FMG accessibility |

---

## 🔗 See Also

| Document | Description |
|----------|-------------|
| [00-introduction.md](00-introduction.md) | FortiManager overview |
| [01-concepts-json-rpc.md](01-concepts-json-rpc.md) | JSON-RPC fundamentals |
| [../cheatsheets/api-endpoints.md](../cheatsheets/api-endpoints.md) | Endpoint reference |

---

**Ready to start?** Head to [01-raw-http/](../01-raw-http/) for hands-on examples.
