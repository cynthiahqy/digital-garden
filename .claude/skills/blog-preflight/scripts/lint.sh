#!/usr/bin/env bash
# Run proselint and aspell over a Quarto post and print consolidated results.
# Usage: lint.sh <path/to/index.qmd>
set -euo pipefail

FILE="${1:?Usage: lint.sh <path/to/post.qmd>}"

echo "=== proselint ==="
proselint check "$FILE" || true

echo
echo "=== aspell (unrecognized words, deduped) ==="
aspell --mode=markdown --lang=en list < "$FILE" | sort -u
