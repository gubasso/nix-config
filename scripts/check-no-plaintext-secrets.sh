#!/usr/bin/env bash
set -euo pipefail

root="${1:-secrets}"

if [[ ! -d "$root" ]]; then
  echo "secrets guard: directory not found: $root" >&2
  exit 1
fi

status=0

while IFS= read -r -d '' file; do
  name="$(basename "$file")"

  case "$name" in
    .keep)
      continue
      ;;
    .sops.yaml)
      if ! rg -q '^(keys|creation_rules):' "$file"; then
        echo "secrets guard: invalid .sops.yaml metadata: $file" >&2
        status=1
      fi
      continue
      ;;
  esac

  if ! rg -q 'sops:' "$file"; then
    echo "secrets guard: plaintext or unmanaged secret candidate: $file" >&2
    status=1
  fi
done < <(find "$root" -type f -print0)

exit "$status"
