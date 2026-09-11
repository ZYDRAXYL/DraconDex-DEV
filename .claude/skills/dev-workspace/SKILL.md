---
name: dev-workspace
description: Work across the seven DraconDex clones from the DraconDex-DEV root — route a change to the repo that owns it, read status/branch/dirty state for all seven at once, and commit to the right one, given that DEV's git hard-ignores every child repo so a commit from the root silently captures nothing. Covers the multi-root VS Code workspace (tasks and launch configs live inside DraconDex.code-workspace, not a root .vscode/), the setup/start scripts, and the mirrored-skill law. Use when standing in DraconDex-DEV and asked to commit/push a change, check what's dirty across the repos, set up a new machine, run the app, or asked "แก้ที่ repo ไหน", "commit ให้ด้วย", "repo ไหน dirty", "status ทุก repo", "where do I commit this", "why didn't my commit include anything".
---

# dev-workspace — one checkout, seven repos

DraconDex-DEV is a container. It tracks the workspace file, `scripts/`,
`package.json`, and the README — and **nothing under `DraconDex-*/`**, because
`.gitignore` excludes those folders outright:

```bash
git ls-files                                  # 5-ish files. That is the whole repo.
git check-ignore -v DraconDex-EXE/package.json   # .gitignore:3:DraconDex-EXE/
```

Every `DraconDex-*/` folder beside it is its own repository with its own remote.
That single fact drives everything below.

## The commit-routing rule

A change inside a child repo is **invisible** to git at this root. `git status`
here shows nothing, `git add DraconDex-EXE/...` refuses, and a `git commit -am`
from here captures none of it. There is no warning — it just looks like it
worked.

Always name the repo:

```bash
git -C DraconDex-EXE status
git -C DraconDex-EXE add electron/src/renderer/hub/tree.js
git -C DraconDex-EXE commit -m "..."
git -C DraconDex-EXE push
```

Commit **from this root** only for `DraconDex.code-workspace`, `scripts/`,
`package.json`, `README.md`, or `CLAUDE.md`.

## Status across all seven

```bash
for d in APP SDB EXE APK PWA PKG WEB; do
  printf "%-4s %-28s %s dirty\n" "$d" \
    "$(git -C DraconDex-$d branch --show-current)" \
    "$(git -C DraconDex-$d status --porcelain | wc -l)"
done
```

Run this before starting work and before reporting anything as "done" — in a
seven-repo layout the usual failure is finished work sitting uncommitted in a
repo nobody looked at.

## Routing a change to its owner

Do not guess which repo owns a file. Ask the contract:

```bash
node DraconDex-APP/tools/chain-lib.mjs     # self, edges, and every clone path
cat DraconDex-APP/chain/chain.json         # the ownership table itself
```

| The change is about | It belongs in |
|---|---|
| Desktop app behaviour, renderer, IPC, main process | **EXE** (`electron/`) |
| Mobile app | **APK** (`flutter/`) |
| Schema, Supabase, asset masters | **SDB** |
| Docs, the chain contract, skills/agents, process write-ups | **APP** |
| Browser build of either front-end | **PWA** |
| Downloadable theme/language/view packages | **PKG** |
| The website | **WEB** |
| The workspace file, setup/start scripts | **DEV** (here) |

Once you know the repo, `cd` into it and use **that repo's own skills** —
`run-dracondex`, `dracondex-module-style`, `version-update`, `merge-release`
and the rest are mirrored into each repo that needs them. Do not re-derive
their work from this root.

## A change that spans repos

Land it **upstream first**, then let the chain push it down. Changes flow
`APP → SDB → EXE/APK → PKG/WEB/PWA` and never backwards.

```bash
node DraconDex-APP/tools/chain-survey.mjs   # what already moved elsewhere
```

Then, from inside the repo where the change landed, use its `chained-updated`
skill/agent to open the downstream PRs. Never hand-edit the same change into
two repos from here — that is what the propagation tooling exists to prevent,
and doing it by hand produces two diverging copies.

## The mirrored-skill law

Every child repo's `.claude/` is generated output. Each mirrored file is stamped
*"mirrored-from-app: do not edit here"*. To change a skill:

```bash
# edit DraconDex-APP/.claude/skills/<name>/SKILL.md
npm run mirror --prefix DraconDex-APP          # write
npm run mirror:check --prefix DraconDex-APP    # verify only, for CI
```

`MIRROR_SETS` in `DraconDex-APP/tools/mirror-claude.mjs` decides which repo gets
which skill. Skills under **this** repo's `.claude/` are deliberately outside
that system: DEV is not in `chain.json`, and these skills describe the workspace
itself, which no chain repo can see. Do not add DEV to `MIRROR_SETS`.

## Workspace, setup, and running

- **Tasks and launch configs live inside `DraconDex.code-workspace`**, under its
  `tasks` and `launch` keys — *not* in a root `.vscode/`. This repo's root is
  not one of the workspace's folders, so a root `.vscode/` would never be read.
  Reference a folder as `${workspaceFolder:EXE}`, not `${workspaceFolder}`.
- `./scripts/setup.ps1` — clones missing repos, `npm install`s each. Idempotent.
- `npm start` (root) — delegates to `npm start --prefix DraconDex-EXE`.
- `./scripts/start-dev.ps1 -Target Pwa` — the browser dev server instead.
- `APP`, `EXE`, and `APK` are **private** repos; a clone needs GitHub auth.

## What not to do

- Do not `git add -A` from this root hoping to catch a child repo's change.
- Do not create a root `.vscode/` for tasks or launch configs.
- Do not edit a mirrored `SKILL.md`/agent inside a child repo.
- Do not reimplement chain survey/propagation with your own `git log` loop — the
  tooling in `DraconDex-APP/tools/` already resolves every sibling clone here.
- Do not report work complete without the status loop above coming back clean.
