# Cheatsheets

> **Quick reference guides for FortiManager API automation.**

[Home](../README.md) > Cheatsheets

---

## Available Cheatsheets

| Cheatsheet | Description | Use When |
|------------|-------------|----------|
| [API Endpoints](api-endpoints.md) | Complete endpoint reference | Looking up URL paths |
| [Common Errors](common-errors.md) | Error codes and troubleshooting | Debugging API responses |
| [cURL Examples](curl-examples.md) | Ready-to-use cURL commands | Quick testing and validation |

---

## Cheatsheet Details

### api-endpoints.md

**Complete API endpoint reference including:**

- URL format and patterns
- System & Authentication endpoints
- ADOM Management
- Firewall Objects (addresses, services, schedules)
- NAT / VIP configuration
- Security Profiles
- Firewall Policies
- Policy Packages
- Device Management
- Installation & Deployment
- Tasks & Jobs
- Query parameters (filtering, field selection, pagination)

### common-errors.md

**Troubleshooting guide including:**

- Error code reference table (-1 to -10147)
- Workspace mode errors and solutions
- Authentication errors (session expired, invalid API key)
- Object errors (exists, not found, in use)
- Syntax & validation errors
- Permission errors
- Installation errors
- Connection errors
- Debugging tips and checklist

### curl-examples.md

**Ready-to-use cURL commands for:**

- Authentication (session and bearer token)
- Firewall addresses (CRUD operations)
- Services (CRUD operations)
- Firewall policies (CRUD + move)
- VIP / NAT configuration
- Policy installation
- Device management
- Bulk operations
- Useful one-liners

---

## Usage Tips

1. **Keep these open** while developing - they're quick references
2. **Use API Endpoints** when constructing new API calls
3. **Use Common Errors** when debugging failed requests
4. **Use cURL Examples** for rapid testing before coding

---

## See Also

- [Documentation](../docs/README.md) - Conceptual guides
- [Diagrams](../diagrams/README.md) - Visual references
- [Main README](../README.md) - Project overview
