# CLAUDE.md

Guidance for Claude Code working in **DraconDex-DEV**.

## What this is

DraconDex-DEV is the **controller/workspace repo**, not an application repo. It
tracks five files — `DraconDex.code-workspace`, `package.json`, `scripts/`,
`README.md`, `LICENSE`, `.gitignore`/`.gitattributes` — and nothing else.

The eight `DraconDex-*/` folders beside it are **separate git repositories**,
each with its own GitHub remote under `ZYDRAXYL/`. `.gitignore` excludes them
from this repo entirely, so they are invisible to this repo's git.

If you are here to change app behaviour, **you are in the wrong folder.** Pick
the owning repo below, `cd` into it, and use that repo's own skills.

| Repo | Owns | Releases |
|---|---|---|
| **APP** | `.claude/`, `chain/`, `docs/`, `process/`, `tools/` — the hub | — |
| **SDB** | `schema/`, `supabase/`, asset masters | `sdb-v*` |
| **TRX** | `netlify/`, `public/` — the DDX Transfer hand-off service | — |
| **EXE** | `electron/` — the Windows desktop app | `v*` |
| **APK** | `flutter/` — Android/iOS | `flutter-v*` |
| **PWA** | `tools/`, `shim/`, `dist/` — both front-ends in a browser | — |
| **PKG** | `packages/` — theme/language/view packages | `pkg-v*` |
| **WEB** | the website and the public release mirror | mirror |
| **DEV** (here) | the workspace file, the setup/start scripts | — |

`DraconDex-APP/chain/chain.json` is the machine-readable contract. Read it
rather than trusting this table where the two disagree.

## Hard rules

1. **Never `git add`/`git commit` from this root for a change inside a child
   repo.** Those paths are hard-ignored here — the commit silently captures
   nothing. Always route to the repo that owns the file:
   ```bash
   git -C DraconDex-EXE status
   git -C DraconDex-EXE commit -am "..."
   ```
   Commit from this root *only* for the workspace file, scripts, or README.

2. **Never edit a `SKILL.md` or agent inside a child repo.** Every child repo's
   `.claude/` is generated output, stamped "mirrored-from-app: do not edit
   here". Edit it in `DraconDex-APP/.claude/`, then
   `npm run mirror --prefix DraconDex-APP`. A local edit downstream is lost on
   the next mirror.

3. **Skills in *this* repo's `.claude/` are DEV-only and are not mirrored.**
   They cover the workspace and cloud-session concerns that no chain repo knows
   about. Do not copy chain-repo skills in here, and do not add DEV to
   `MIRROR_SETS`.

4. **Reuse the chain tooling; never reimplement it.** It already resolves all
   eight sibling clones from this layout:
   ```bash
   node DraconDex-APP/tools/chain-lib.mjs      # resolved chain + clone paths
   node DraconDex-APP/tools/chain-survey.mjs   # what moved in the other repos
   ```

## Running the app

```powershell
./scripts/setup.ps1                 # clone missing repos + npm install each
npm start                           # -> DraconDex-EXE (Windows desktop app)
./scripts/start-dev.ps1 -Target Pwa # -> DraconDex-PWA dev server
```
