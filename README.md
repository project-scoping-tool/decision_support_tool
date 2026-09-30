# Southern Nevada Decision Support Tool (DST) / Pedestrian Safety Tool (PST)
The Decision Support Tool (DST) is a tool for planning, public works and transportation professionals to integrate health and equity into land use decisions to promote safe, walkable, bikeable, and connected communities.

> **Naming note:** the app itself (`MaterialApp` title, `pubspec.yaml`) still identifies as "Decision Support Tool" / "Infrastructure for Healthy Living: A Project Scoping Tool", while more recent commits and question-instruction copy (e.g. `shade.toml`) refer to it as the **Pedestrian Safety Tool (PST)**. The landing page (below) uses the PST name per current team direction. **TODO:** confirm the final product name with the team and align it across the landing page, app title, and docs.

## Site Architecture

**The Flutter app *is* the website.** There is no separate landing-page build step and no site-assembly script — one Flutter project, built one way, produces the complete site:

```
/       -> Landing page   (lib/ui/landing_page.dart)
/pst/   -> PST tool        (lib/ui/assessment_app.dart, unchanged)
```

`/pst` above is the *default* — both whether there's a landing page at all,
and what path the tool is served at, are centrally configurable in
`flutter/decision_support_tool/lib/config.dart`:

```dart
const bool landingPageEnabled = true;  // false: '/' opens the PST tool directly
const String toolExtension = '/pst';   // e.g. '/tool', '/decision-support'
```

- `landingPageEnabled = true` (default): `/` shows the landing page, the
  tool is at `toolExtension`.
- `landingPageEnabled = false`: `/` opens the PST tool directly — no need
  to visit `toolExtension` first (it still works too, if visited).

This is implemented entirely in `flutter/decision_support_tool/lib/main.dart`, which reads both constants rather than hardcoding a path — `landing_page.dart` and `site_header.dart` do the same for their "Open Tool" links:
- `usePathUrlStrategy()` (from `flutter_web_plugins`) makes web URLs real paths (e.g. `/pst`) instead of hash fragments (`/#/pst`).
- `onGenerateRoute` maps `toolExtension` (with or without a trailing slash) to the existing `AssessmentApp` (completely unmodified — same widgets, same view models, same services). When `landingPageEnabled` is `false`, every other path (including `/`) also maps to `AssessmentApp`; otherwise `/` and any unrecognized path map to `LandingPage`. `/instructions` is unaffected by either setting.
- The landing page CTA calls `Navigator.pushNamed(context, toolExtension)` — a `push`, not a replace, so the browser Back button correctly returns to the landing page.

`flutter/decision_support_tool/web/index.html` has one addition, a `<base href="$FLUTTER_BASE_HREF">` tag, needed so compiled asset paths resolve correctly; it defaults to `/` (root) for this deployment.

> An earlier version of this repo used a separate static `landing/` page plus a `scripts/build_site.sh` assembler that physically copied the Flutter build into a `pst/` subfolder. That architecture has been retired — `landing/`, `scripts/`, `build.sh`, and `run.sh` no longer exist. If you find a reference to them anywhere (docs, notes, muscle memory), it's stale.

## Local Development

```bash
cd flutter/decision_support_tool
flutter run -d chrome
```

Opens Chrome directly to the landing page at `/` (or the PST tool, if `landingPageEnabled` is `false` — see [Site Architecture](#site-architecture)), with full hot reload (`r`) and hot restart (`R`) support — verified working: editing `landing_page.dart` or any PST source file while running updates the app in place without losing state or changing the URL. Click "Open Project Scoping Tool" to navigate to the configured tool path (URL updates, no server round-trip); the browser Back button returns to the landing page.

This is now the *only* local dev command — it exercises the real site structure directly, so there's no separate "full site" vs. "Flutter only" mode to choose between anymore.

## Production Build

```bash
cd flutter/decision_support_tool
flutter build web --release
```

`build/web/` is the complete, deployable website — landing page and PST tool both included, nothing else to assemble. Verified present: `main.dart.js`, `flutter_bootstrap.js`, `flutter_service_worker.js`, `canvaskit/` (wasm renderer), all `assets/assets/question_info/*.toml`, `assets/assets/data/*.csv`/`*.json`, and fonts.

### SPA fallback (required for direct navigation to the tool path)

Because the PST tool's path (`/pst/` by default — see [Site Architecture](#site-architecture), configurable via `toolExtension` in `config.dart`) only exists as a client-side Flutter route (there's no real `build/web/pst/index.html` file), a **fresh page load** at that path — a bookmark, a shared link, or a hard refresh — depends on the web server serving `index.html`'s content for that path instead of a 404. `flutter run`'s dev server does this automatically (verified). Static hosts like GitHub Pages and Apache do not, by default, and need one extra step each. **None of the server-side config below depends on what `toolExtension` is set to** — it falls back to `index.html` for *any* unmatched path, so changing `toolExtension` needs no deployment changes.

**GitHub Pages** has no rewrite rules, but it does serve a custom `404.html` for any unmatched path (with an HTTP 404 status, but the browser still executes the page). Making `404.html` an exact copy of `index.html` turns that into a working SPA fallback: the app boots, reads the real `window.location.pathname` (`/pst/`), and renders the right route. **Verified locally** with a test server that mimics GitHub Pages' behavior (serves real files normally, falls back to `404.html` content — with a 404 status — for anything else): `/`, direct navigation to `/pst/`, and all asset categories (JS, canvaskit/wasm, service worker, fonts, `question_info` TOML, crash CSV/JSON) all loaded correctly through the fallback.

After building, before deploying to GitHub Pages:

```bash
cp build/web/index.html build/web/404.html
```

This is a one-line, GitHub-Pages-specific necessity, not a build script — nothing else needs to run.

**Apache (future UNLV/TRC deployment)** needs an equivalent fallback, configured server-side. This repo does not (and currently cannot, since we don't have access to that server) ship an `.htaccess` or `httpd.conf` change — document this requirement for whoever provisions the server:

```apache
# Simplest option (mod_dir, usually enabled by default):
FallbackResource /index.html
```

or, if `FallbackResource` isn't available:

```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ /index.html [L]
```

Either directive, scoped to the site's document root, makes any unmatched path (the tool path, a refresh mid-assessment, etc.) serve `index.html` so Flutter's client-side router can take over — the same effect the GitHub Pages `404.html` trick achieves without rewrite support.

## GitHub Pages Deployment

Current configuration (as found in this repository's git remotes — not guessed):

- **Deploy target repo:** `github.com/metehanzorluoglu/metehanzorluoglu.github.io` — a GitHub **user page** repo. This is a *separate* repository from `decision_support_tool` (the `origin` remote); it holds only the deployed static site.
- **Branch / directory:** `main`, root directory. Classic "Deploy from a branch" Pages — **no GitHub Actions workflow** exists anywhere in either repo.
- **Custom domain:** set via a committed `CNAME` file (check `site/CNAME` locally — deliberately not repeated here so this doc never needs to change if the domain does). Because it's a user-page repo with a custom domain, **no `/decision_support_tool/`-style path prefix applies** — the site is served at the domain root. That's why the default base href is `/` (root), not `/decision_support_tool/`.
- **Deploy checkout — currently `site/.git`, not yet migrated:** earlier in this project's history, the Pages checkout lived directly in `flutter/decision_support_tool/build/web/.git` (build output doubling as the git checkout), then was moved to `site/.git` when the site briefly consisted of two separate static apps (landing + pst) assembled into `site/`. That two-app era is now over, but **`site/.git` has deliberately been left exactly where it is** rather than moved again, to avoid touching GitHub Pages history without an explicit, reviewed plan. `site/CNAME` and `site/.nojekyll` are preserved there too. **`site/` is not deleted, not regenerated by anything, and is safe to ignore until you decide how to deploy next** — see the options below.

### Deploying next: two options

**Option A — migrate the deploy checkout back to `build/web/`** (matches the new one-Flutter-app architecture most closely; this mirrors how the checkout lived before the site briefly split into two static apps):

1. `cd flutter/decision_support_tool && flutter build web --release && cp build/web/index.html build/web/404.html`
2. From the repo root, move the checkout into the fresh build output: `mv site/.git flutter/decision_support_tool/build/web/.git`, `mv site/CNAME flutter/decision_support_tool/build/web/CNAME`, `mv site/.nojekyll flutter/decision_support_tool/build/web/.nojekyll`
3. `cd flutter/decision_support_tool/build/web && git status` — expect a large diff (old `landing/` + `pst/` layout → new flat layout), review it, then `git add -A && git commit && git push origin main` when ready.
4. Once confirmed working, the now-empty `site/` directory can be deleted from the repo root.

**Option B — keep deploying from `site/`** for now: copy `build/web/` (plus `404.html`) into `site/` yourself before each commit, leaving `site/.git` where it is. More manual, but zero risk to the existing checkout.

Neither option has been executed — deploying, and choosing between A and B, is left to you.

## Deploying to a UNLV/TRC Apache Server

```bash
cd flutter/decision_support_tool
flutter build web --release
```

Copy the contents of `build/web/` to the Apache document root (e.g. via `scp`/`rsync`, however UNLV/OIT provisions the server), and see [SPA fallback](#spa-fallback-required-for-direct-navigation-to-the-tool-path) above for the server-side config that deployment will eventually need for the tool path to survive a direct visit or refresh.

## Requirements and Installation
This code was developed on a Windows 10 machine usi ng [Visual Studio Code](https://code.visualstudio.com/).

To install the Flutter framework, install it in VS Code using the provided steps provded [here](https://docs.flutter.dev/development/tools/vs-code) and [here](https://docs.flutter.dev/get-started/editor?tab=vscode).

## Changing Flutter Version
This code was tested on Flutter 2.10.2 on the [stable channel](https://docs.flutter.dev/development/tools/sdk/releases). After installing Flutter on VS Code, do the following steps to ensure you have the correct environment versioning:
* Check if Flutter is in the **stable channel** by running the following in the terminal in VS Code:
```bash
flutter channel
``` 
* If the channel is not on **stable**, run the following in the same terminal:
```bash
flutter channel stable
flutter upgrade
```
* After changing the channel to **stable**, check your Flutter version by running:
```bash
flutter --version
```
* If your Flutter version is not 2.10.2 in the stable channel, then run the following
```bash
flutter version v2.10.2
```

## Running the Code
* Clone the repo on your machine.
* Change to the jurisdiction branch:
```bash
git checkout jurisdiction
```
* In VS Code, open ```decision_support_tool/flutter/decision_support_tool```.
    * This is the root of the Flutter project.
* Check to see if Flutter detects any devices on your machine (i.e. web browsers).
```bash
flutter devices
```
* For example, if you have Microsoft Edge and Google Chrome browsers on your machine, you can run one following in the terminal in VS Code in debug mode:
```bash
flutter run -d edge
flutter run -d chrome
```
**The code has been optimized in full screen mode.**


## Building the Web Package (Dart to Java Script)
To build a web package (js package), run
```bash
flutter build web
```

After the package has been built, go to ```decision_support_tool/flutter/decision_support_tool/build/web```. The contents in *web* is the js package.

For more information in building web packages, [see here.](https://docs.flutter.dev/get-started/web)
