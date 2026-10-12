#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
echo "Shoppers keep carts across visits" > .fake-gh/issue-40
echo "Carts are stored per device" > .fake-gh/issue-50
