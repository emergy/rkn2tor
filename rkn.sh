#!/bin/bash

PID=`ps ax -opid,cmd | awk '$NF ~ /rkn.sh$/ {printf $1}'`
[ -n "$PID" ] && kill $PID

PROXY_PORT="9040"

ipset create rkn hash:ip hashsize 16777216 maxelem 16777216

iptables -t nat -I PREROUTING 1 -m set --match-set rkn src -p tcp --syn -j REDIRECT --to-ports $PROXY_PORT
iptables -t nat -I PREROUTING 1 -m set --match-set rkn dst -p tcp --syn -j REDIRECT --to-ports $PROXY_PORT

for i in `curl https://api.reserve-rbl.ru/api/v2/ips/csv`; do
    ipset -A rkn $i
done

