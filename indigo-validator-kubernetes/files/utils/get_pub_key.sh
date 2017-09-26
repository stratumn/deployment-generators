#!/bin/sh

set -e

cat $1 | jq -M ".pub_key"
