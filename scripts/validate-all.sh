#!/usr/bin/env bash
# Runs `terraform init -backend=false` + `terraform validate` in every
# directory that contains .tf files. Never touches AWS or remote state.
#
# Usage:  ./scripts/validate-all.sh            (from the repository root)
# Tip:    export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
#         so the AWS provider is downloaded once instead of per directory.
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
failed=()

mapfile -t dirs < <(find "$root" -name '*.tf' -not -path '*/.terraform/*' -printf '%h\n' | sort -u)

for dir in "${dirs[@]}"; do
  rel="${dir#"$root"/}"
  printf '==> %s\n' "$rel"
  if ! terraform -chdir="$dir" init -backend=false -input=false -no-color >/dev/null 2>"$dir/.init.err"; then
    cat "$dir/.init.err"
    failed+=("$rel (init)")
  elif ! terraform -chdir="$dir" validate -no-color; then
    failed+=("$rel (validate)")
  fi
  rm -f "$dir/.init.err"
done

echo
if ((${#failed[@]})); then
  echo "FAILED:"
  printf '  %s\n' "${failed[@]}"
  exit 1
fi
echo "All ${#dirs[@]} configurations are valid."
