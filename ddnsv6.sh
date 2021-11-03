#!/usr/bin/env bash

set -xu
set -eo pipefail

domain="example.com"
sub_domain="www.example.com"
email="admin@example.com"
zone_id=""
key=""

v6addr=$(curl -s6 ip.sb)

if [ -z "$v6addr" ]; then
    echo "v6addr cannot empty" >&2
fi

echo "ipv4: ${v6addr}"

domain_id=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records?name=${sub_domain}" \
    -H "X-Auth-Email: ${email}" \
    -H "X-Auth-Key: ${key}" \
    -H "Content-Type: application/json" |
    jq '.result[0].id' |
    tr -d '"')

if [ -z "$domain_id" ]; then
    echo "domain_id cannot empty" >&2
fi

echo "domain_id: ${domain_id}"

curl -sX PUT "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${domain_id}" \
    -H "X-Auth-Email: ${email}" \
    -H "X-Auth-Key: ${key}" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"AAAA\",\"name\":\"${sub_domain}\",\"content\":\"${v6addr}\",\"ttl\":1,\"proxied\":false}"
