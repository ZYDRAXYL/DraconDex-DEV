---
name: run-app
description: Run, launch, drive, screenshot, or smoke-test the DraconDex app from the DraconDex-DEV workspace root. Use when asked to run/start/test the app while standing in DEV, or asked "how do I run the app from here", "npm start doesn't work", "รันแอพยังไง", "ทดสอบแอพจาก DEV". This repo has no app code itself — it points you at the real driver in DraconDex-EXE.
---

# Running the app from DraconDex-DEV

DEV has no app code — it's the workspace container. `npm start` here is a
one-line delegation ([package.json](../../../package.json)):

```json
"scripts": { "start": "npm start --prefix DraconDex-EXE" }
```

That's already wired up; you don't need to add anything to make `npm start`
work. If it fails with "Electron binary is missing or incomplete", the child
repo just hasn't been installed yet:

```bash
npm install --prefix DraconDex-EXE
```

## Driving/testing the app programmatically (screenshots, clicking, IPC checks)

The real driver — `run-dracondex` — lives in `DraconDex-EXE/.claude/skills/`
(mirrored from `DraconDex-APP`). **Do not copy it here**: its paths
(`electron/main.js`, `tmp-user-data/`, `.claude/skills/run-dracondex/driver.mjs`)
are all relative to the `DraconDex-EXE` repo root, and per this repo's
[CLAUDE.md](../../../CLAUDE.md) rule, chain-repo skills are never duplicated
into DEV — they'd immediately drift out of sync with the real one in APP.

Instead, `cd` into `DraconDex-EXE` (or set that as cwd) and use its own skill
directly:

```bash
cd DraconDex-EXE
node .claude/skills/run-dracondex/driver.mjs --fresh \
  "ss 01-nexus" "click .module-item:has-text('Director')" "ss 02-director"
```

Screenshots land in `DraconDex-EXE/tmp-driver-data/shots/`. See
`DraconDex-EXE/.claude/skills/run-dracondex/SKILL.md` for the full command
vocabulary, the Welcome-window/`nextwindow` handoff, and troubleshooting.

## Other targets

- Browser build (PWA) instead of the Electron app: `./scripts/start-dev.ps1 -Target Pwa`
- Repo routing for everything else (which repo owns a file, how to commit): see the [dev-workspace](../dev-workspace/SKILL.md) skill.
