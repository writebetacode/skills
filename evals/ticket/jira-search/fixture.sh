#!/bin/sh
set -e
. "$(dirname "$0")/../base.sh"
fake_acli
cat > .fake-acli/search.json <<'X'
[{"key":"SHOP-12","fields":{"summary":"Accented searches find nothing","status":{"name":"To Do"},"assignee":null}},
 {"key":"SHOP-15","fields":{"summary":"Saved cart lost when switching devices","status":{"name":"In Progress"},"assignee":{"displayName":"Dev"}}}]
X
