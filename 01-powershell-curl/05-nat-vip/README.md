# NAT / VIP Management

CRUD scripts for VIPs and IP Pools management.

## Endpoints

| Type | Endpoint |
|------|----------|
| VIP IPv4 | `/pm/config/adom/{adom}/obj/firewall/vip` |
| VIP IPv6 | `/pm/config/adom/{adom}/obj/firewall/vip6` |
| VIP Group | `/pm/config/adom/{adom}/obj/firewall/vipgrp` |
| IP Pool IPv4 | `/pm/config/adom/{adom}/obj/firewall/ippool` |
| IP Pool IPv6 | `/pm/config/adom/{adom}/obj/firewall/ippool6` |

## Scripts

| Script | Description |
|--------|-------------|
| `crud-vip.ps1` | CRUD operations on VIPs |
| `crud-ippool.ps1` | CRUD operations on IP Pools |

## VIP Examples (DNAT)

```powershell
# Create a static NAT VIP
.\crud-vip.ps1 -Action create -Name "VIP_WEB" `
    -ExtIP "203.0.113.10" -MappedIP "10.10.10.5"

# VIP with port forwarding
.\crud-vip.ps1 -Action create -Name "VIP_WEB_8080" `
    -ExtIP "203.0.113.10" -MappedIP "10.10.10.5" `
    -ExtPort "8080" -MappedPort "80"
```

## IP Pool Examples (SNAT)

```powershell
# Overload pool (PAT)
.\crud-ippool.ps1 -Action create -Name "POOL_NAT" `
    -StartIP "203.0.113.20" -EndIP "203.0.113.25" -Type overload
```
