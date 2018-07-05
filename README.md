# Network Control

Project to contain my home rate limiting and access control scripts.

## Debian gateway configuration
### Static IP 

Edit `/etc/dhcpcd.conf`

```
interface eth0
static ip_address=10.0.0.1/24
static routers=10.0.0.1
static domain_name_servers=10.0.0.1
static domain_search=intra.acidchild.org
```

### Setup gateway

Edit `/etc/sysctl.conf`

Change 

`# net.ipV4.ip_ip_forward = 1`

To

`net.ipV4.ip_ip_forward = 1`

Restart networking

`service networking restart`

