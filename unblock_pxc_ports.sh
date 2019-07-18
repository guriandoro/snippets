#!/bin/bash

# inbound TCP ports
iptables -D INPUT -m tcp -p tcp --dport 3306 -j REJECT
iptables -D INPUT -m tcp -p tcp --dport 4567 -j REJECT
iptables -D INPUT -m tcp -p tcp --dport 4568 -j REJECT
iptables -D INPUT -m tcp -p tcp --dport 4444 -j REJECT
# inbound UDP ports
iptables -D INPUT -p udp --dport 4567 -j REJECT

# outbound TCP ports
iptables -D OUTPUT -m tcp -p tcp --dport 3306 -j REJECT
iptables -D OUTPUT -m tcp -p tcp --dport 4567 -j REJECT
iptables -D OUTPUT -m tcp -p tcp --dport 4568 -j REJECT
iptables -D OUTPUT -m tcp -p tcp --dport 4444 -j REJECT
# outbound UDP ports
iptables -D OUTPUT -p udp --dport 4567 -j REJECT
