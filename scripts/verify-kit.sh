#!/usr/bin/env bash
# Check every file listed in SHA256SUMS. Files under private/ may be absent (GitHub copy).
set -uo pipefail
KIT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$KIT"
if command -v sha256sum >/dev/null; then H() { sha256sum "$1" | cut -d' ' -f1; }
else H() { shasum -a 256 "$1" | cut -d' ' -f1; }; fi
ok=0; bad=0; missing_private=0
while IFS= read -r line; do
  sum="${line%%  *}"; path="${line#*  }"
  if [ ! -f "$path" ]; then
    case "$path" in private/*) missing_private=$((missing_private+1)); continue;; esac
    echo "MISSING  $path"; bad=$((bad+1)); continue
  fi
  if [ "$(H "$path")" = "$sum" ]; then ok=$((ok+1)); else echo "CHANGED  $path"; bad=$((bad+1)); fi
done < SHA256SUMS
echo "checked $ok files, $bad problems, $missing_private private files not present"
[ "$missing_private" -gt 0 ] && echo "(private/ comes from the USB stick only)"
[ "$bad" -eq 0 ] && echo "ALL OK" || { echo "FAILED"; exit 1; }
