#!/bin/bash

set -e

echo "start ip update"

location update

{
  echo "create geoblock hash:net family inet -exist"
  echo "flush geoblock"
  for cc in RU AR; do
    location list-networks-by-cc --family=ipv4 $cc | while read ip; do
      echo "add geoblock $ip"
    done
  done
} > /usr/local/sbin/blocked_ip_list

ipset restore < /usr/local/sbin/blocked_ip_list

echo "end ip update"
