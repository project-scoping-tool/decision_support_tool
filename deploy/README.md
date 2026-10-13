# PST Test Deployments

This directory holds the local git checkouts that `../deploy.sh` builds,
syncs, and publishes to the project's two test websites. It documents
what each one is, how to deploy to it, and the configuration details
that matter if something looks broken.

Source of truth for all of this is `../deploy.sh` itself — if anything
below ever looks out of date, the script wins.

## At a glance

| | `auto-test` | `manual-test` |
|---|---|---|
| GitHub repo | [`project-scoping-tool/pst-auto-test-site`](https://github.com/project-scoping-tool/pst-auto-test-site) | [`project-scoping-tool/pst-test-site`](https://github.com/project-scoping-tool/pst-test-site) |
| Website | https://pst-auto-test.edum8.us/ | https://pst-test.edum8.us/ |
| Local checkout | `deploy/auto-test-site/` | `deploy/manual-test-site/` |
| Deploy command | `./deploy.sh auto-test "message"` | `./deploy.sh manual-test "message"` |
| Deploy branch | `main` | `main` |
| Base href | `/` | `/` |
| Auto-cloned if missing? | Yes (empty repo, nothing to lose) | No — must be cloned by hand once |

Both sites also have a `production` branch in their repo. **`deploy.sh`
never touches it** — every build/commit/push only ever happens on `main`.

## Deploying

```bash
cd /Users/metehanzorluoglu/decision_support_tool_clone/decision_support_tool

./deploy.sh auto-test "Deploy message here"
./deploy.sh manual-test "Deploy message here"
```

A commit message is required for both — there's no default. Each run:

1. Verifies the target checkout: remote URL matches, on branch `main`,
   working tree clean, **and in sync with `origin/main`** (the script
   `git fetch`es first and refuses to build if the local checkout is
   behind — it never pulls/merges/rebases automatically).
2. Builds the current Flutter source (`flutter build web --release`,
   with the right `--base-href`, output redirected away from
   `flutter/decision_support_tool/build/` so a plain build never
   collides with anything here).
3. Validates the build (`index.html`, `404.html`, `main.dart.js`,
   `flutter_bootstrap.js`, `flutter_service_worker.js`, `manifest.json`,
   `canvaskit/`, `assets/` all present; base href correctly substituted).
4. Syncs the build into the checkout's working tree (`rsync --delete`,
   `.git` excluded/untouched).
5. Re-writes the `CNAME` file (see below) — this has to happen *after*
   step 4, since `rsync --delete` would otherwise remove it.
6. `git add -A` / `git commit` / `git push origin main` — but only if
   something actually changed; a no-op build is reported and skipped,
   not committed.

If any step fails, the script stops immediately (`set -euo pipefail`) —
nothing partial gets committed or pushed.

## `manual-test` must be cloned once, by hand

`pst-auto-test-site` starts out empty, so `deploy.sh` clones it
automatically the first time. `pst-test-site` already carries real
deployment history, so the script deliberately will **not** clone it for
you — if `deploy/manual-test-site/` doesn't exist, `./deploy.sh
manual-test` just prints the exact command and stops:

```bash
git clone https://github.com/project-scoping-tool/pst-test-site.git deploy/manual-test-site
```

## Custom domains and the `CNAME` file

Both sites are served from custom domains at the repo root, not the
default GitHub Pages project-page URL:

- `pst-auto-test.edum8.us` → `pst-auto-test-site`
- `pst-test.edum8.us` → `pst-test-site`

That's *why* `AUTO_TEST_BASE_HREF`/`MANUAL_TEST_BASE_HREF` in `deploy.sh`
are both `"/"` — if either ever read `"/pst-auto-test-site/"` (the
default project-page path) while serving from the custom domain root,
every asset request 404s and the site shows a blank white screen. This
exact bug happened once on `auto-test` — see git history for the
"Fix custom domain base-href and restore CNAME" commit if you want the
full story.

The `CNAME` file (containing just the domain name) is what tells GitHub
Pages which custom domain to serve. It is **not** something
`flutter build web` produces, so `deploy.sh` writes it explicitly after
every sync, in both `cmd_auto_test` and `cmd_manual_test` — this makes it
self-healing even though `rsync --delete` would otherwise strip it on
every single deploy.

`pst-test.edum8.us` additionally sits behind Cloudflare Access (a login
wall) — that's DNS/Cloudflare-side configuration, unrelated to anything
in this repo or `deploy.sh`.

## If a deploy refuses to run

- **"is not a git checkout"** — `deploy/manual-test-site` is missing;
  clone it (see above).
- **"origin ... does not match expected"** / **"is on branch ... expected
  'main'"** — the checkout is pointed at the wrong repo/branch. Fix it
  yourself; the script will never switch branches or remotes for you.
- **"already has uncommitted changes"** — resolve/commit/stash those
  yourself first; the script refuses to build on top of a dirty tree.
- **"is out of sync with origin/main"** — someone (or something) pushed
  directly to the deploy repo (e.g. via GitHub's web UI) since your last
  deploy. Sync it yourself:
  ```bash
  cd deploy/auto-test-site      # or deploy/manual-test-site
  git pull --ff-only
  ```
  then re-run `./deploy.sh ...`.

## After the first deploy to a new repo

`deploy.sh` never configures GitHub Pages, Cloudflare, or DNS itself —
only the build and the git push. For a brand-new target repo, enable
Pages yourself once (Settings → Pages → source = `main` branch, root)
before the custom domain will work.
