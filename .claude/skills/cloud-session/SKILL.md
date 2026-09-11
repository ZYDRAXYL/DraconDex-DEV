---
name: cloud-session
description: How to work on DraconDex from a managed Claude Code session that has exactly one repository checked out and no sibling clones — Claude Code on the web, a cloud/remote session, a GitHub Action, or any sandbox that cloned one repo. Covers the trap that DraconDex-DEV clones to five files with zero application code (so it is the wrong repo to launch an app-work session on), which repo to launch on for a given task, how the chain tooling falls back from local clones to git ls-remote when siblings are absent, what genuinely cannot run there (the Electron driver, the PowerShell setup scripts, electron-builder, Flutter devices, npm start), and the one-PR-per-repo flow for landing cross-repo work. Use when starting or planning work in a cloud/web/remote Claude Code session, when a session cannot find a sibling repo or a file it expected, before delegating DraconDex work to a cloud agent, or when asked "ทำงานบน cloud ยังไง", "cloud claude code", "repo ไหนควรเปิด session", "ทำไมหา repo อื่นไม่เจอ", "why is this repo empty", "run this in the cloud".
---

# cloud-session — one repo, no siblings, no display

A local checkout of this project gives Claude seven repositories side by side.
A managed session — Claude Code on the web, a cloud session, CI — gives it
**one**, with no siblings on disk and usually no Windows and no display.
Everything that goes wrong in a cloud session traces back to one of those three
absences.

## Trap 1: DraconDex-DEV clones to nothing

DEV's `.gitignore` excludes all seven `DraconDex-*/` folders, so they are not in
its history. A fresh clone of DraconDex-DEV contains:

```
.gitattributes  .gitignore  DraconDex.code-workspace  LICENSE  README.md
package.json  scripts/
```

No `electron/`, no `flutter/`, no `schema/`, no app code of any kind. `npm start`
there fails — `DraconDex-EXE` does not exist to delegate to, and
`./scripts/setup.ps1` is PowerShell that expects Windows and GitHub auth for
three private repos.

**A cloud session launched on DEV can only change the workspace file, the
scripts, the README, and this `.claude/` directory.** That is a legitimate task
— it is just not app work. For anything else, launch the session on the repo
that owns the change.

## Which repo to launch the session on

| The task | Launch on |
|---|---|
| Desktop app behaviour — renderer, IPC, main process | **DraconDex-EXE** |
| Mobile app | **DraconDex-APK** |
| Schema, Supabase setup, generated schema artifacts | **DraconDex-SDB** |
| Docs, the chain contract, skills/agents, process write-ups | **DraconDex-APP** |
| Browser build of either front-end | **DraconDex-PWA** |
| Theme/language/view packages | **DraconDex-PKG** |
| The website | **DraconDex-WEB** |
| The workspace file, setup/start scripts, DEV's own docs | **DraconDex-DEV** |

This choice is made when the session is created and cannot be changed from
inside it. Getting it wrong costs the whole session, so confirm the owner
against `chain/chain.json` before launching, not after.

`APP`, `EXE`, and `APK` are **private**. The cloud environment needs credentials
with access to them; a session that cannot clone is an access problem, not a
code problem.

## Trap 2: siblings resolve to null, and that is by design

The chain tooling looks for peers as sibling directories. In a cloud session
there are none, and it already handles that:

```js
// DraconDex-APP/tools/chain-lib.mjs
// "Returns null when that repo is not cloned locally, so callers can fall back
//  to the GitHub API instead of failing."
clonePathOf('SDB')   // -> null in a cloud session
```

So:

- `node tools/chain-lib.mjs` and `node tools/chain-survey.mjs` **work** — the
  survey reads peers with `git ls-remote`, not from disk. Expect
  `(not cloned here)` next to every peer; that is correct output, not a fault.
- Anything that needs a peer's *file contents* does not work. Read it from the
  peer's remote over the API, or state that the check could not be performed.
  Never substitute a guess about another repo's contents.
- Do not try to `cd ../DraconDex-SDB`, and do not clone a peer beside the
  checkout to work around this — a second clone inside a managed session is
  untracked state that nothing will push.

## Trap 3: what cannot run there

| Will not run | Why | Do this instead |
|---|---|---|
| `run-dracondex` driver, `npm start` | Needs a real Electron binary and a display; verified on Windows only | Read the renderer/main/db code and the tests; state plainly that no live verification was possible |
| `scripts/setup.ps1`, `scripts/start-dev.ps1` | PowerShell, Windows paths | `npm install` / `npm run <script>` directly in the one repo you have |
| `electron-builder` Windows targets, `build:exe`, `build:installer` | Windows toolchain | Leave the build to the `build-electron.yml` workflow a tag triggers |
| Flutter device/emulator runs | No device, no Android SDK | `flutter analyze` if the SDK is present; otherwise review by reading |
| `dracondex-module-style` visual comparison | Screenshots need the running app | Run its static `check.mjs` half only, and say the visual half was skipped |

What **does** run, because it is plain Node: SDB's `npm run generate` /
`npm run check`, PWA's `npm run build` / `test`, PKG's `npm run build`, APP's
`npm run mirror:check`, every `node --test` suite, and the chain survey.

## Landing the work

One session owns one repo, so it opens **one pull request in that repo**. Never
try to land a cross-repo change from a single cloud session.

For work that spans repos: land it in the owning repo upstream-most first, then
let the `chained-updated` tooling open the downstream PRs from a session (or a
local checkout) in that repo. Changes flow `APP → SDB → EXE/APK → PKG/WEB/PWA`
and never backwards.

Two behaviours to respect:

- **`version-update` does not commit in a managed remote/cloud session** — by
  its own rule. Let it compute the bump and report it; the commit happens
  locally or through the PR.
- **Releases are cut by pushing a tag**, which triggers the build workflow. Do
  not attempt a release build inside the session.

## What not to do

- Do not launch an app-work session on DraconDex-DEV and then conclude the
  project is empty or broken.
- Do not clone sibling repos into a managed checkout to fake the local layout.
- Do not report a change as verified when the Electron driver could not run —
  say which verification was skipped and why.
- Do not hand-copy a change into a second repo; upstream-first, then propagate.
- Do not edit a mirrored `SKILL.md`/agent in any repo but APP.
