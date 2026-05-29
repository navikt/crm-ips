#!/usr/bin/env bash
set -euo pipefail

# repo-sync: Henter siste endringer fra Git uten destruktive operasjoner.
# Trygt å kjøre automatisk — bytter aldri branch, bruker kun --ff-only.
#
# Exit-koder:
#   0 = OK (oppdatert eller allerede oppdatert)
#   1 = Feil (ikke git-repo, feil branch, nettverksfeil, etc.)
#
# Output (stdout): JSON med status og detaljer.

json_output() {
  local status="$1" message="$2" count="${3:-0}"
  printf '{"status":"%s","message":"%s","count":%d}\n' "$status" "$message" "$count"
}

# 1. Sjekk at vi er i et git-repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  json_output "error" "Ikke et git-repo"
  exit 1
fi

# 2. Finn hovedbranch
main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)
if [[ -z "$main_branch" ]]; then
  for candidate in main master; do
    if git show-ref --verify --quiet "refs/remotes/origin/$candidate" 2>/dev/null; then
      main_branch="$candidate"
      break
    fi
  done
fi

if [[ -z "$main_branch" ]]; then
  json_output "error" "Fant ikke hovedbranch"
  exit 1
fi

# 3. Sjekk at vi er på hovedbranch
current_branch=$(git branch --show-current 2>/dev/null || true)
if [[ "$current_branch" != "$main_branch" ]]; then
  json_output "skipped" "Ikke på hovedbranch ($current_branch)"
  exit 0
fi

# 4. Fetch
if ! git fetch origin "$main_branch" --quiet 2>/dev/null; then
  json_output "error" "Kunne ikke hente fra GitHub"
  exit 1
fi

# 5. Sjekk om det finnes oppdateringer
behind=$(git rev-list "HEAD..origin/$main_branch" --count 2>/dev/null || echo 0)

if [[ "$behind" -eq 0 ]]; then
  json_output "current" "Allerede oppdatert"
  exit 0
fi

# 6. Pull med --ff-only
if ! git pull --ff-only origin "$main_branch" --quiet 2>/dev/null; then
  json_output "error" "Kunne ikke oppdatere — historikken har divergert"
  exit 1
fi

json_output "updated" "Hentet nye endringer" "$behind"
