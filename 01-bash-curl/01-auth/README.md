# Authentication Scripts

> **Authenticate with FortiManager API using session tokens or API keys.**

---

## Scripts

| Script | Method | Description |
|--------|--------|-------------|
| `login-session.sh` | **Session** | Login and return session token |
| `login-bearer.sh` | **Bearer** | Test API key connection |
| `logout.sh` | **Session** | Close and invalidate session |

---

## Authentication Methods

| Method | Best For | FMG Version |
|--------|----------|-------------|
| **Bearer Token** | *Automation, CI/CD* | 7.2.2+ |
| **Session-based** | *Interactive scripts* | All versions |

---

## Usage

### Bearer Token *(Recommended)*

```bash
# Set API key in .env
FMG_API_KEY=your_api_key_here

# Test connection
./login-bearer.sh

# No login/logout needed - all scripts auto-detect API key
```

### Session-Based

```bash
# Login and capture session token
SESSION=$(./login-session.sh)

# Use session in subsequent calls
../02-addresses/read-addresses.sh -S "$SESSION"

# Always logout when done
./logout.sh "$SESSION"
```

---

## Options

### login-session.sh

| Option | Description |
|--------|-------------|
| `-h` | Show help |
| `-v` | Verbose output |

### logout.sh

| Option | Description |
|--------|-------------|
| `$1` | **Required**: Session token to invalidate |

---

## See Also

- [Authentication Guide](../../docs/02-authentication.md)
- [Main README](../README.md)
