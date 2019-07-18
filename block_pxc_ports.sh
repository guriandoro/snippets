#!/bin/bash

# inbound TCP ports
iptables -I INPUT -m tcp -p tcp --dport 3306 -j REJECT
iptables -I INPUT -m tcp -p tcp --dport 4567 -j REJECT
iptables -I INPUT -m tcp -p tcp --dport 4568 -j REJECT
iptables -I INPUT -m tcp -p tcp --dport 4444 -j REJECT
# inbound UDP ports
iptables -I INPUT -p udp --dport 4567 -j REJECT

# outbound TCP ports
iptables -I OUTPUT -m tcp -p tcp --dport 3306 -j REJECT
iptables -I OUTPUT -m tcp -p tcp --dport 4567 -j REJECT
iptables -I OUTPUT -m tcp -p tcp --dport 4568 -j REJECT
iptables -I OUTPUT -m tcp -p tcp --dport 4444 -j REJECT
# outbound UDP ports
iptables -I OUTPUT -p udp --dport 4567 -j REJECT
