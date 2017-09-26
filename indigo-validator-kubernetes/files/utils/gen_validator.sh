#!/bin/sh

set -e

docker run --rm {{input `tendermintImage`}} gen_validator
