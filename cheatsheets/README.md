# 📋 FortiManager API Cheatsheets

<div align="center">

**Quick reference guides for FortiManager automation**

*Designed for beginners • Ready to copy-paste • Concrete examples*

[🏠 Home](../README.md) • [📖 Documentation](../docs/README.md) • [📊 Diagrams](../diagrams/README.md)

---

</div>

## 🎯 Choose Your Guide

<table>
<tr>
<td width="20%" align="center">

### 🔗 [API Endpoints](api-endpoints.md)

**Complete URL reference**

```
📍 Quickly find
   any endpoint
```

*Ideal for building your calls*

</td>
<td width="20%" align="center">

### 🔧 [cURL Examples](curl-examples.md)

**Ready-to-use commands**

```
📋 Copy, paste,
   execute!
```

*Perfect for quick testing*

</td>
<td width="20%" align="center">

### 🐍 [Python Examples](python-examples.md)

**Structured Python scripts**

```
🐍 Automate with
   requests!
```

*For developers*

</td>
<td width="20%" align="center">

### 🎭 [Ansible Examples](ansible-examples.md)

**Infrastructure as Code Playbooks**

```
📦 Declare your config,
   Ansible handles it
```

*For teams and CI/CD*

</td>
<td width="20%" align="center">

### ⚠️ [Common Errors](common-errors.md)

**Troubleshooting guide**

```
🩺 Diagnose and
   resolve errors
```

*When things don't work*

</td>
</tr>
</table>

---

## 👤 Who Is This For?

| You are... | Start with... | Why? |
|:-----------|:--------------|:-----|
| 🌱 **Complete beginner** | [cURL Examples](curl-examples.md) | Concrete copy-paste examples |
| 🔍 **Building a script** | [API Endpoints](api-endpoints.md) | Find the right URL quickly |
| 🐍 **Python developer** | [Python Examples](python-examples.md) | Structured scripts with requests |
| 🎭 **DevOps / Ops** | [Ansible Examples](ansible-examples.md) | Infrastructure as Code, CI/CD |
| 🐛 **Stuck on an error** | [Common Errors](common-errors.md) | Solutions to common problems |
| 📚 **Need to understand** | [Documentation](../docs/README.md) | Detailed conceptual guides |

---

## ⚡ Ultra-Quick Start

> **Want to test the API in 2 minutes?** Follow these 3 steps:

### 1️⃣ Configure your variables

```bash
export FMG_HOST="192.168.1.100"    # Your FortiManager
export FMG_API_KEY="your_key"      # Your API key
```

### 2️⃣ Test the connection

```bash
curl -k -X POST "https://$FMG_HOST/jsonrpc" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FMG_API_KEY" \
  -d '{"id":1,"method":"get","params":[{"url":"/sys/status"}]}'
```

### 3️⃣ You should see:

```json
{
  "result": [{
    "status": { "code": 0, "message": "OK" },
    "data": { "Version": "7.x.x", ... }
  }]
}
```

> ✅ **Code 0 = Success!** You're ready to explore the cheatsheets.

---

## 💡 Usage Tips

<table>
<tr>
<td width="50%">

### ✨ Best Practices

- 📌 **Bookmark these pages** - daily reference
- 📋 **Copy the examples** - they're made for that!
- 🔄 **Adapt the variables** - change ADOM, names, IPs
- 🧪 **Test in lab environment** - before production

</td>
<td width="50%">

### ⚠️ Avoid

- ❌ Don't modify production without testing
- ❌ Don't share your API keys
- ❌ Don't ignore `-10147` errors
- ❌ Don't forget workspace lock/unlock

</td>
</tr>
</table>

---

## 🗺️ Quick Navigation by Topic

| Topic | Endpoints | cURL | Python | Ansible | Errors |
|:------|:----------|:-----|:-------|:--------|:-------|
| 🔐 **Authentication** | [→](api-endpoints.md#-authentication) | [→](curl-examples.md#-authentication) | [→](python-examples.md#-authentication) | [→](ansible-examples.md#-authentication) | [→](common-errors.md#-error--11--session-expired) |
| 📍 **Addresses** | [→](api-endpoints.md#-firewall-addresses) | [→](curl-examples.md#-firewall-addresses) | [→](python-examples.md#-firewall-addresses) | [→](ansible-examples.md#-firewall-addresses) | [→](common-errors.md#-error--2--object-not-found) |
| 🔌 **Services** | [→](api-endpoints.md#-services) | [→](curl-examples.md#-services) | [→](python-examples.md#-services) | [→](ansible-examples.md#-services) | - |
| 🛡️ **Policies** | [→](api-endpoints.md#-policies) | [→](curl-examples.md#-firewall-policies) | [→](python-examples.md#-firewall-policies) | [→](ansible-examples.md#-firewall-policies) | - |
| 🔀 **VIP / NAT** | [→](api-endpoints.md#-nat--vip) | [→](curl-examples.md#-vip--nat) | [→](python-examples.md#-vip--nat) | [→](ansible-examples.md#-vip--nat) | - |
| 📦 **Installation** | [→](api-endpoints.md#-installation) | [→](curl-examples.md#-installation) | [→](python-examples.md#-installation) | [→](ansible-examples.md#-installation) | [→](common-errors.md#-error--10147--no-write-permission) |
| 💻 **Devices** | [→](api-endpoints.md#-devices) | [→](curl-examples.md#-devices) | [→](python-examples.md#-devices) | [→](ansible-examples.md#-devices) | - |

---

## 📚 Additional Resources

<table>
<tr>
<td align="center" width="33%">

📖 **[Documentation](../docs/README.md)**

*In-depth conceptual guides*

</td>
<td align="center" width="33%">

📊 **[Diagrams](../diagrams/README.md)**

*Visual workflows*

</td>
<td align="center" width="33%">

🏠 **[Main Project](../README.md)**

*Overview*

</td>
</tr>
</table>

---

<div align="center">

*These cheatsheets are here to help you - feel free to print them or consult them often!* 📝

</div>
