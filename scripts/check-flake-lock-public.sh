#!/usr/bin/env bash
# Guard: a PUBLIC flake.lock must reference only public forge/CDN hosts.
#
# This is the one irreversible leak vector — if the private consumer is ever
# added as an input here, its URL and revision land in a public file. There is
# no consolidated pre-commit hook for "public-host allowlist", so this local
# guard fills that single custom gap. It uses a POSITIVE allowlist of permitted
# public hosts and never encodes any private string, so the guard itself leaks
# nothing.
#
# Requires: jq.
set -euo pipefail

lock="${1:-flake.lock}"

if [[ ! -f "$lock" ]]; then
  echo "flake-lock guard: file not found: $lock" >&2
  exit 1
fi

# Input node types that are inherently public or local (never a private remote).
allow_types='github|indirect|path|tarball'

# Hosts permitted to appear in a locked URL.
allow_hosts='github.com|api.github.com|raw.githubusercontent.com|codeload.github.com|releases.nixos.org|cache.nixos.org|channels.nixos.org|nixos.org'

status=0

# 1. Flag any node whose lock type is not on the public allowlist
#    (e.g. a raw `git`, `gitlab`, `sourcehut`, or `mercurial` remote).
while IFS= read -r type; do
  [[ -z "$type" ]] && continue
  if ! grep -Eqx "$allow_types" <<<"$type"; then
    echo "flake-lock guard: non-public input type present: '$type'" >&2
    status=1
  fi
done < <(jq -r '.nodes | to_entries[] | .value.locked.type // empty' "$lock")

# 2. Flag any explicit locked URL whose host is not on the public allowlist.
while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  host="${url#*://}"
  host="${host%%/*}"
  host="${host##*@}"
  if ! grep -Eqx "$allow_hosts" <<<"$host"; then
    echo "flake-lock guard: URL host not on public allowlist: '$host' ($url)" >&2
    status=1
  fi
done < <(jq -r '.nodes | to_entries[] | .value.locked.url // empty' "$lock")

if [[ "$status" -eq 0 ]]; then
  echo "flake-lock guard: ok — only public hosts referenced."
fi

exit "$status"
