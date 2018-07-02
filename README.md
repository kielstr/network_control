# network_control

Project to contain my home rate limiting and access control scripts.

## Debian gateway configuration

Edit `/etc/sysctl.conf`

Change 

`# net.ipV4.ip_ip_forward = 1`

To

`net.ipV4.ip_ip_forward = 1`

Restart networking

`service networking restart`

