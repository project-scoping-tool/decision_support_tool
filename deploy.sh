#!/usr/bin/env bash
# deploy.sh — builds, validates, and deploys Flutter web builds for the
# PST project's test deployments.
#
#   ./deploy.sh auto-test "Commit message"
#   ./deploy.sh manual-test "Commit message"
#
# Each run builds the current Flutter source (no branch switching),
# validates the output, syncs it into the target deployment checkout, and
# then automatically runs `git add -A` / `git commit` / `git push origin
# main` in that checkout — but only after verifying the checkout's remote
# and current branch match exactly what's expected. If verification fails,
# or the build/validation fails, the script stops immediately before
# making any git change. If nothing changed, commit and push are skipped.
#
# A commit message is required for both commands; there is no default.
# The "production" branch (and anything that isn't "main") is never
# touched by this script, in either deployment checkout.
#
# deploy/manual-test-site is the one and only local git checkout this
# script uses for project-scoping-tool/pst-test-site. It must already
# exist (clone it yourself first — see the error message if it's
# missing); this script never clones it automatically, since, unlike
# pst-auto-test-site, it already carries real deployment history.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
FLUTTER_DIR="$REPO_ROOT/flutter/decision_support_tool"
DEPLOY_ROOT="$REPO_ROOT/deploy"

DEPLOY_BRANCH="main"

AUTO_TEST_REPO_URL="https://github.com/project-scoping-tool/pst-auto-test-site.git"
AUTO_TEST_DIR="$DEPLOY_ROOT/auto-test-site"
# pst-auto-test-site now has a custom domain (pst-auto-test.edum8.us) at
# the repo root — confirmed via `gh api repos/project-scoping-tool/
# pst-auto-test-site/pages`. Base href must be "/", matching the domain
# root, not "/pst-auto-test-site/" (that only applied to the old default
# GitHub *project page* URL, before the custom domain was set up — serving
# "/" under that base href is exactly what produced the blank-white-screen
# bug: every asset request 404'd against the custom domain's root).
AUTO_TEST_BASE_HREF="/"
# Written into AUTO_TEST_DIR after every sync (see cmd_auto_test) so the
# custom domain survives even though `flutter build web` knows nothing
# about it and rsync --delete would otherwise remove it, since it isn't
# part of the Flutter build output.
AUTO_TEST_CNAME="pst-auto-test.edum8.us"

MANUAL_TEST_REPO_URL="https://github.com/project-scoping-tool/pst-test-site.git"
MANUAL_TEST_DIR="$DEPLOY_ROOT/manual-test-site"
# Matches pst-test-site's actual existing config: a custom domain
# (pst-test.edum8.us) at the repo root, confirmed via
# `gh api repos/project-scoping-tool/pst-test-site/pages`.
MANUAL_TEST_BASE_HREF="/"
# Written into MANUAL_TEST_DIR after every sync (see cmd_manual_test), for
# the same reason as AUTO_TEST_CNAME above: `flutter build web` doesn't
# produce this file, so rsync --delete would otherwise remove it.
MANUAL_TEST_CNAME="pst-test.edum8.us"

# Paths this script will never build into directly (build output always
# goes to a throwaway raw-build dir first; it's rsynced into a deployment
# checkout only after that checkout's remote/branch have been verified).
# flutter/decision_support_tool/build/ in particular is plain Flutter
# build output with no git checkout of its own — deploy.sh has no
# deployment target there at all.
PROTECTED_BUILD_PATHS=(
  "$FLUTTER_DIR/build"
  "$REPO_ROOT/landing_page_design"
)

guard_build_path() {
  local target="$1"
  for forbidden in "${PROTECTED_BUILD_PATHS[@]}"; do
    case "$target" in
      "$forbidden"*)
        echo "ERROR: refusing to build into '$target' — inside protected path '$forbidden'." >&2
        exit 1
        ;;
    esac
  done
}

build_flutter() {
  local base_href="$1" out_dir="$2"
  guard_build_path "$out_dir"
  echo "==> Building Flutter web (base-href=$base_href) into $out_dir"
  rm -rf "$out_dir"
  mkdir -p "$out_dir"
  (cd "$FLUTTER_DIR" && flutter build web --release --base-href "$base_href" --output "$out_dir")
  cp "$out_dir/index.html" "$out_dir/404.html"
  touch "$out_dir/.nojekyll"
}

validate_build() {
  local dir="$1" expected_href="$2"
  echo "==> Validating build at $dir"
  local required=(index.html 404.html main.dart.js flutter_bootstrap.js flutter_service_worker.js manifest.json canvaskit assets)
  for f in "${required[@]}"; do
    if [[ ! -e "$dir/$f" ]]; then
      echo "ERROR: expected build output '$f' missing from $dir" >&2
      exit 1
    fi
  done
  if grep -q '\$FLUTTER_BASE_HREF' "$dir/index.html"; then
    echo "ERROR: base href placeholder was not substituted in $dir/index.html" >&2
    exit 1
  fi
  if ! grep -q "base href=\"$expected_href\"" "$dir/index.html"; then
    echo "ERROR: $dir/index.html base href does not match expected '$expected_href'" >&2
    exit 1
  fi
  echo "    OK: required files present, base href is '$expected_href'."
}

# Verifies a deployment checkout's remote and current branch before any
# git-mutating command is allowed to run against it. Exits non-zero (via
# `set -e`, since this runs in the main shell) on any mismatch.
verify_checkout() {
  local dir="$1" expected_remote="$2" expected_branch="$3"

  if [[ ! -d "$dir/.git" ]]; then
    echo "ERROR: '$dir' is not a git checkout (.git missing). Refusing to continue." >&2
    exit 1
  fi

  local remote_url
  remote_url="$(git -C "$dir" remote get-url origin)"
  if [[ "$remote_url" != "$expected_remote" ]]; then
    echo "ERROR: '$dir' origin ('$remote_url') does not match expected '$expected_remote'. Refusing to continue." >&2
    exit 1
  fi

  local current_branch
  current_branch="$(git -C "$dir" rev-parse --abbrev-ref HEAD)"
  if [[ "$current_branch" != "$expected_branch" ]]; then
    echo "ERROR: '$dir' is on branch '$current_branch', expected '$expected_branch'." >&2
    echo "       This script never switches branches or touches any branch other than" >&2
    echo "       '$expected_branch' (in particular, it will not touch 'production')." >&2
    exit 1
  fi

  # Fetch (read-only -- only updates the origin/* remote-tracking ref,
  # never the local branch or working tree) and refuse to build on top of
  # a checkout that's behind its remote. Without this, a build+commit
  # would still happen before the eventual `git push` is rejected
  # (non-fast-forward), wasting a full build cycle and leaving a stray
  # local commit that needs manual untangling.
  git -C "$dir" fetch origin "$expected_branch" --quiet
  local local_rev remote_rev
  local_rev="$(git -C "$dir" rev-parse "$expected_branch")"
  remote_rev="$(git -C "$dir" rev-parse "origin/$expected_branch")"
  if [[ "$local_rev" != "$remote_rev" ]]; then
    echo "ERROR: '$dir' ($expected_branch) is out of sync with origin/$expected_branch." >&2
    echo "       local:  $local_rev" >&2
    echo "       origin: $remote_rev" >&2
    echo "       Sync this checkout yourself first (e.g. 'git pull --ff-only') --" >&2
    echo "       this script never pulls, merges, or rebases automatically." >&2
    exit 1
  fi

  local dirty_before
  dirty_before="$(git -C "$dir" status --porcelain)"
  if [[ -n "$dirty_before" ]]; then
    echo "ERROR: '$dir' already has uncommitted changes before this run:" >&2
    echo "$dirty_before" | sed 's/^/    /' >&2
    echo "       Refusing to build on top of a dirty checkout — resolve this yourself first." >&2
    exit 1
  fi

  echo "    OK: '$dir' -> origin '$remote_url', branch '$current_branch', clean, in sync with origin."
}

# Stages, commits, and pushes a deployment checkout, but only after
# verify_checkout has already confirmed its remote/branch. Skips commit
# and push (not an error) if there is nothing to commit.
commit_and_push() {
  local dir="$1" branch="$2" message="$3"

  echo "==> Staging changes in $dir"
  git -C "$dir" add -A

  if git -C "$dir" diff --cached --quiet; then
    echo "No changes to commit in $dir - skipping commit and push."
    return 0
  fi

  echo "==> Committing in $dir"
  git -C "$dir" commit -m "$message"

  echo "==> Pushing $branch to origin"
  git -C "$dir" push origin "$branch"

  echo "    Pushed $(git -C "$dir" rev-parse --short HEAD) to $branch."
}

cmd_auto_test() {
  local message="$1"
  mkdir -p "$DEPLOY_ROOT"

  if [[ ! -d "$AUTO_TEST_DIR" ]]; then
    echo "==> Cloning $AUTO_TEST_REPO_URL into $AUTO_TEST_DIR"
    echo "    (this repo is new/empty on GitHub - zero commits, nothing to lose)"
    git clone "$AUTO_TEST_REPO_URL" "$AUTO_TEST_DIR"
    git -C "$AUTO_TEST_DIR" checkout -B "$DEPLOY_BRANCH" 2>/dev/null || true
  fi

  verify_checkout "$AUTO_TEST_DIR" "$AUTO_TEST_REPO_URL" "$DEPLOY_BRANCH"

  local raw_dir="$DEPLOY_ROOT/.auto-test-raw-build"
  build_flutter "$AUTO_TEST_BASE_HREF" "$raw_dir"
  validate_build "$raw_dir" "$AUTO_TEST_BASE_HREF"

  echo "==> Syncing build output into $AUTO_TEST_DIR (working tree only, .git untouched)"
  rsync -a --delete --exclude='.git' "$raw_dir"/ "$AUTO_TEST_DIR"/
  rm -rf "$raw_dir"

  # Re-asserted after every sync (not just created once) so a custom-domain
  # deploy is self-healing: this survives even if it was ever previously
  # deleted by rsync --delete, since it's never part of the Flutter build
  # output rsync just replaced.
  echo "==> Writing CNAME ($AUTO_TEST_CNAME)"
  echo "$AUTO_TEST_CNAME" > "$AUTO_TEST_DIR/CNAME"

  commit_and_push "$AUTO_TEST_DIR" "$DEPLOY_BRANCH" "$message"
}

cmd_manual_test() {
  local message="$1"
  mkdir -p "$DEPLOY_ROOT"

  if [[ ! -d "$MANUAL_TEST_DIR" ]]; then
    cat <<EOF >&2
ERROR: $MANUAL_TEST_DIR does not exist yet.

pst-test-site already carries real deployment history, so this script
will not clone it automatically. Set it up yourself first:

  git clone $MANUAL_TEST_REPO_URL "$MANUAL_TEST_DIR"

Then re-run: $0 manual-test "$message"
EOF
    exit 1
  fi

  # Verified before building anything, so a misconfigured checkout never
  # even costs a build, and a dirty checkout is never built on top of.
  verify_checkout "$MANUAL_TEST_DIR" "$MANUAL_TEST_REPO_URL" "$DEPLOY_BRANCH"

  local raw_dir="$DEPLOY_ROOT/.manual-test-raw-build"
  build_flutter "$MANUAL_TEST_BASE_HREF" "$raw_dir"
  validate_build "$raw_dir" "$MANUAL_TEST_BASE_HREF"

  echo "==> Syncing build output into $MANUAL_TEST_DIR (working tree only, .git untouched)"
  rsync -a --delete --exclude='.git' "$raw_dir"/ "$MANUAL_TEST_DIR"/
  rm -rf "$raw_dir"

  # Re-asserted after every sync, same reasoning as cmd_auto_test: this
  # file is never part of the Flutter build output, so rsync --delete
  # would otherwise remove it on every single deploy.
  echo "==> Writing CNAME ($MANUAL_TEST_CNAME)"
  echo "$MANUAL_TEST_CNAME" > "$MANUAL_TEST_DIR/CNAME"

  commit_and_push "$MANUAL_TEST_DIR" "$DEPLOY_BRANCH" "$message"
}

usage() {
  echo "Usage: $0 {auto-test|manual-test} \"Commit message\"" >&2
  exit 1
}

TARGET="${1:-}"
MESSAGE="${2:-}"

case "$TARGET" in
  auto-test|manual-test) ;;
  *) usage ;;
esac

if [[ -z "$MESSAGE" ]]; then
  echo "ERROR: a commit message is required: $0 $TARGET \"Commit message\"" >&2
  exit 1
fi

case "$TARGET" in
  auto-test) cmd_auto_test "$MESSAGE" ;;
  manual-test) cmd_manual_test "$MESSAGE" ;;
esac
