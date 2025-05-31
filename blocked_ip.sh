#!/bin/bash

set -e

{
  echo "create geoblock hash:net family inet"
  for cc in RU AR; do
    location list-networks-by-cc --family=ipv4 $cc | while read ip; do
      echo "add geoblock $ip"
    done
  done
} > /usr/local/sbin/blocked_ip_list

ipset restore < /usr/local/sbin/blocked_ip_list

ipset list geoblock > lista

head -10 lista
