### Firewall script / configuration written by GoAutoDial - go_firewall.pl
### Manual customization of this file is not recommended.
/sbin/iptables -F INPUT
/sbin/iptables -F OUTPUT
/sbin/iptables -F FORWARD
/sbin/iptables -t nat -F PREROUTING
/sbin/iptables -t nat -F OUTPUT
/sbin/iptables -t nat -F POSTROUTING
/sbin/iptables -t mangle -F PREROUTING
/sbin/iptables -t mangle -F OUTPUT
/sbin/iptables -F RH-Firewall-1-INPUT
/sbin/iptables -X
/sbin/iptables -P INPUT ACCEPT
/sbin/iptables -P OUTPUT ACCEPT
/sbin/iptables -P FORWARD ACCEPT
/sbin/iptables -A INPUT -i lo -j ACCEPT
/sbin/iptables -A INPUT -p icmp --icmp-type any -j ACCEPT
/sbin/iptables -A INPUT    -p 50 -j ACCEPT
/sbin/iptables -A INPUT    -p 51 -j ACCEPT
/sbin/iptables -A INPUT -p udp -s 224.0.0.251  --dport 5353 -j ACCEPT
/sbin/iptables -A INPUT -m udp -p udp   --dport 631 -j ACCEPT
/sbin/iptables -A INPUT -m state --state ESTABLISH,RELATED     -j ACCEPT
/sbin/iptables -A INPUT -m udp -p udp   --dport 5060 -j ACCEPT
/sbin/iptables -A INPUT -m udp -p udp   --dport 4569 -j ACCEPT
/sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp   --dport 21 -j ACCEPT
/sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp   --dport 80 -j ACCEPT
/sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp   --dport 22 -j ACCEPT
/sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp   --dport 443 -j ACCEPT
/sbin/iptables -A INPUT -m state --state NEW -m tcp -p tcp   --dport 10000 -j ACCEPT
/sbin/iptables -A INPUT -m udp -p udp   --dport 10000:65000 -j ACCEPT
/sbin/iptables -A INPUT -s 77.81.128.0/21 -j DROP
/sbin/iptables -A INPUT -s 221.224.0.0/13 -j DROP
/sbin/iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
