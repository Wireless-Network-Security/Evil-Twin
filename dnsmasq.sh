#!bin/bash

read interface

ifconfig $interface up 192.168.1.1 netmask 255.255.255.0
route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables -P FORWARD ACCEPT


iptables -t nat -A PREROUTING -i $interface -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:80
iptables -t nat -A PREROUTING -i $interface -p tcp --dport 443 -j DNAT --to-destination 192.168.1.1:80
iptables -t nat -A POSTROUTING -j MASQUERADE

service apache2 start 

echo nameserver 127.0.0.1 > /etc/resolv.conf

dnsmasq -C pap/dnsmasq.conf -d