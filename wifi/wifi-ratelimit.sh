#!/bin/bash

DEV="wlx000f12820a6d"

sudo tc qdisc del dev $DEV root

sudo tc qdisc add dev $DEV root handle 2: htb default 2

sudo tc class add dev $DEV parent 2: classid 2:1 htb rate 20mbit ceil 20mbit

# KIELS APPLE TV
TV_RATE="6mbit"
TV_RATE_CEIL="6mbit"
TV_ADDRESS="192.168.2.10"

sudo tc class add dev $DEV parent 2:1 classid 2:10 htb rate 20mbit ceil 20mbit prio 1
sudo tc class add dev $DEV parent 2:10 classid 2:11 htb rate $TV_RATE ceil $TV_RATE_CEIL prio 1
sudo tc filter add dev $DEV parent 2:0 protocol ip prio 1 handle 11 fw classid 2:11
sudo iptables -t mangle -D POSTROUTING -d $TV_ADDRESS -j MARK --set-mark 11
sudo iptables -t mangle -D POSTROUTING -d $TV_ADDRESS -j RETURN
sudo iptables -t mangle -A POSTROUTING -d $TV_ADDRESS -j MARK --set-mark 11
sudo iptables -t mangle -A POSTROUTING -d $TV_ADDRESS -j RETURN

# KIELS APPLE TV
TV_RATE="6mbit"
TV_RATE_CEIL="6mbit"
TV_ADDRESS="192.168.2.11"

sudo tc class add dev $DEV parent 2:1 classid 2:20 htb rate 20mbit ceil 20mbit prio 1
sudo tc class add dev $DEV parent 2:20 classid 2:21 htb rate $TV_RATE ceil $TV_RATE_CEIL prio 1
sudo tc filter add dev $DEV parent 2:0 protocol ip prio 1 handle 21 fw classid 2:21
sudo iptables -t mangle -D POSTROUTING -d $TV_ADDRESS -j MARK --set-mark 21
sudo iptables -t mangle -D POSTROUTING -d $TV_ADDRESS -j RETURN
sudo iptables -t mangle -A POSTROUTING -d $TV_ADDRESS -j MARK --set-mark 21
sudo iptables -t mangle -A POSTROUTING -d $TV_ADDRESS -j RETURN
