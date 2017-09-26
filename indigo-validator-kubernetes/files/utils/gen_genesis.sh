#!/bin/sh

set -e

genesis=$(cat << EOT
{
    "genesis_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "chain_id": "indigo-$(uuid)",
    "validators": [],
    "app_hash": ""
}
EOT
)

i=0
for pub_key in "$@"; do
    validator=$(cat $pub_key | jq ". as \$k | {pub_key: \$k, amount: 10, name: \"node-$i\"}")
    genesis=$(echo $genesis | jq ".validators |= .+ [$validator]")
    i=$((i+1))
done

echo $genesis | jq -M "."
