# NAT/VIP Management Scripts

> **CRUD operations for VIPs (DNAT) and IP Pools (SNAT).**

---

## API Endpoints

| Type | Endpoint |
|------|----------|
| **Virtual IP** | `/pm/config/adom/{adom}/obj/firewall/vip` |
| **IP Pool** | `/pm/config/adom/{adom}/obj/firewall/ippool` |

---

## Scripts

| Script | NAT Type | Description |
|--------|----------|-------------|
| `crud-vip.sh` | **DNAT** | Virtual IPs / Port forwarding |
| `crud-ippool.sh` | **SNAT** | Outbound NAT pools |

---

## NAT Types Explained

| Type | Direction | Use Case |
|------|-----------|----------|
| **VIP (DNAT)** | *Inbound* | Publish internal servers |
| **IP Pool (SNAT)** | *Outbound* | Source NAT for clients |

---

## VIP Examples (DNAT)

### Static NAT (1:1)

```bash
# Map public IP to internal server
./crud-vip.sh -a create -n VIP_WEB_SERVER \
    --extip 203.0.113.10 \
    --mappedip 192.168.10.10 \
    -c "Web server"
```

### Port Forwarding

```bash
# Forward external port 2222 to internal SSH
./crud-vip.sh -a create -n VIP_SSH_JUMP \
    --extip 203.0.113.10 \
    --mappedip 192.168.10.20 \
    --extport 2222 \
    --mappedport 22 \
    -c "SSH jump host"

# Multiple ports
./crud-vip.sh -a create -n VIP_HTTPS_ALT \
    --extip 203.0.113.10 \
    --mappedip 192.168.10.30 \
    --extport 8443 \
    --mappedport 443
```

### Read VIPs

```bash
# List all VIPs
./crud-vip.sh -a read

# Get specific VIP
./crud-vip.sh -a read -n VIP_WEB_SERVER

# JSON output
./crud-vip.sh -a read -j
```

### Delete VIP

```bash
./crud-vip.sh -a delete -n VIP_WEB_SERVER
```

---

## IP Pool Examples (SNAT)

### Create Pool

```bash
# Single IP pool
./crud-ippool.sh -a create -n POOL_SINGLE \
    --startip 203.0.113.100 \
    --endip 203.0.113.100 \
    -c "Single IP outbound"

# IP range pool
./crud-ippool.sh -a create -n POOL_OUTBOUND \
    --startip 203.0.113.100 \
    --endip 203.0.113.110 \
    -c "Outbound NAT pool"
```

### Read Pools

```bash
# List all pools
./crud-ippool.sh -a read

# Get specific pool
./crud-ippool.sh -a read -n POOL_OUTBOUND
```

### Delete Pool

```bash
./crud-ippool.sh -a delete -n POOL_OUTBOUND
```

---

## Options Reference

### crud-vip.sh

| Option | Description | Required |
|--------|-------------|----------|
| `-a` | **Action**: `create`, `read`, `update`, `delete` | *Yes* |
| `-n` | VIP **name** | *Yes* (except read all) |
| `--extip` | **External** IP address | *Yes* (create) |
| `--mappedip` | **Internal** IP address | *Yes* (create) |
| `--extport` | External **port** | *No* (port forward) |
| `--mappedport` | Internal **port** | *No* (port forward) |
| `-c` | **Comment** | *No* |
| `-j` | JSON output | *No* |

### crud-ippool.sh

| Option | Description | Required |
|--------|-------------|----------|
| `-a` | **Action**: `create`, `read`, `update`, `delete` | *Yes* |
| `-n` | Pool **name** | *Yes* (except read all) |
| `--startip` | **Start** IP of range | *Yes* (create) |
| `--endip` | **End** IP of range | *Yes* (create) |
| `-c` | **Comment** | *No* |
| `-j` | JSON output | *No* |

---

## See Also

- [PowerShell Equivalent](../../01-powershell-curl/05-nat-vip/)
- [API Endpoints Cheatsheet](../../cheatsheets/api-endpoints.md)
