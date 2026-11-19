#!/usr/bin/env bash
# Builds and publishes a new Sankalp release on GitHub Actions (nothing is built locally).
#
#   scripts/release.sh            # patch release: 1.2.3 -> 1.2.4
#   scripts/release.sh minor      # minor release: 1.2.3 -> 1.3.0
#   scripts/release.sh major      # major release: 1.2.3 -> 2.0.0
#
# Options:
#   -n, --notes "text"   release notes (default: generated from commits)
#   -y, --yes            don't ask for confirmation
#   --no-watch           don't wait for the build to finish
#
# The workflow builds whatever is on GitHub's main branch, so push your changes first.
# It commits the version bump back to main, so run `git pull` afterwards.
set -euo pipefail

WORKFLOW="release.yml"
BRANCH="main"
bump="patch"
notes=""
assume_yes=0
watch=1

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    patch|release) bump="patch" ;;
    minor) bump="minor" ;;
    major) bump="major" ;;
    -n|--notes) shift; notes="${1:-}" ;;
    -y|--yes) assume_yes=1 ;;
    --no-watch) watch=0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

cd "$(git rev-parse --show-toplevel)"

if ! command -v gh >/dev/null 2>&1; then
  echo "The GitHub CLI (gh) is required: https://cli.github.com" >&2
  exit 1
fi
gh auth status >/dev/null 2>&1 || { echo "Run 'gh auth login' first." >&2; exit 1; }

confirm() {
  [ "$assume_yes" = 1 ] && return 0
  read -r -p "$1 [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

# Warn about work that would not be part of the release.
git fetch -q origin "$BRANCH" || true
if [ -n "$(git status --porcelain)" ]; then
  echo "Warning: you have uncommitted changes. They will NOT be in this release."
  confirm "Continue anyway?" || exit 1
fi
ahead=$(git rev-list --count "origin/$BRANCH..HEAD" 2>/dev/null || echo 0)
if [ "$ahead" != "0" ]; then
  echo "Warning: $ahead local commit(s) not pushed to origin/$BRANCH. They will NOT be in this release."
  confirm "Continue anyway?" || exit 1
fi

current=$(git show "origin/$BRANCH:pubspec.yaml" 2>/dev/null | grep -E '^version:' | awk '{print $2}')
echo "Current version on origin/$BRANCH: ${current:-unknown}  ->  $bump release"
confirm "Start the release build on GitHub Actions?" || exit 1

started_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
args=(-f "bump=$bump")
[ -n "$notes" ] && args+=(-f "notes=$notes")
gh workflow run "$WORKFLOW" --ref "$BRANCH" "${args[@]}"
echo "Release workflow started."

if [ "$watch" = 0 ]; then
  echo "Follow it with: gh run list --workflow $WORKFLOW"
  exit 0
fi

# Find the run we just started (it can take a few seconds to show up).
run_id=""
for _ in $(seq 1 15); do
  run_id=$(gh run list --workflow "$WORKFLOW" --event workflow_dispatch --limit 5 \
    --json databaseId,createdAt \
    --jq "[.[] | select(.createdAt >= \"$started_at\")] | last | .databaseId // empty")
  [ -n "$run_id" ] && break
  sleep 2
done

if [ -z "$run_id" ]; then
  echo "Could not find the run yet. Follow it with: gh run list --workflow $WORKFLOW"
  exit 0
fi

if gh run watch "$run_id" --exit-status; then
  echo
  echo "Release published: $(gh release view --json url --jq .url)"
  echo "Run 'git pull' to get the version bump commit."
else
  echo "Release failed. Logs: gh run view $run_id --log-failed" >&2
  exit 1
fi
