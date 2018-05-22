#!/bin/bash

PID=`ps ax -opid,cmd | awk '$NF ~ /rkn.sh$/ {printf $1}'`
[ -n "$PID" ] && kill $PID

PROXY_PORT="9040"
LIST_FILE="/tmp/rkn-list.tmp"
TMP_FILE="/tmp/rkn-list.txt"

ipset create rkn hash:ip hashsize 16777216 maxelem 16777216

iptables -t nat -I PREROUTING 1 -m set --match-set rkn src -p tcp --syn -j REDIRECT --to-ports $PROXY_PORT
iptables -t nat -I PREROUTING 1 -m set --match-set rkn dst -p tcp --syn -j REDIRECT --to-ports $PROXY_PORT

curl -s https://api.reserve-rbl.ru/api/v2/ips/csv -o/tmp/rkn-list.tmp
grep -Ev '([0-9]{1,3}\.){3}[0-9]{1,3}' /tmp/rkn-list.tmp >/dev/null || mv /tmp/rkn-list.tmp /tmp/rkn-list.txt

for i in `cat /tmp/rkn-list.txt`; do
    ipset -A rkn $i
done

