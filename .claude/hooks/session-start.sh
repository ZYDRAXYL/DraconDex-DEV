#!/bin/bash
# SessionStart hook for DraconDex-DEV, the controller repo.
#
# A fresh clone of DEV is five files and no application code: .gitignore keeps
# all eight DraconDex-* repos out of this repo's history, so a managed session
# starts with no siblings on disk. This hook installs whatever the manifest
# asks for and then states plainly what is and is not available, so the session
# does not conclude the project is empty or reach for tooling that cannot run.
set -euo pipefail

# A local checkout already has the eight sibling clones, Windows and PowerShell.
# None of the below applies there.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

# --- dependencies ------------------------------------------------------------
# DEV declares none today, and an unconditional `npm install` would do nothing
# but drop an empty package-lock.json into a clean tree. Install only when the
# manifest actually asks for something, so this keeps working if it ever does.
if node -e 'const p=require("./package.json");process.exit((p.dependencies||p.devDependencies)?0:1)'; then
  npm install --no-audit --no-fund >&2
  deps="npm install completed"
else
  deps="package.json declares no dependencies - nothing to install"
fi

# --- orientation -------------------------------------------------------------
# Everything below goes to stdout, which Claude Code adds to the session context.
cat <<CONTEXT
DraconDex-DEV session ready.

Toolchain: node $(node -v), npm $(npm -v). Dependencies: ${deps}.

This is the controller/workspace repo, not an application repo. It tracks only
DraconDex.code-workspace, package.json, scripts/, README.md, LICENSE and the
git dotfiles. The eight DraconDex-*/ folders are separate git repositories that
.gitignore excludes here, so they are NOT on disk in this session. That is by
design, not a broken checkout.

What this session can legitimately change: the workspace file, scripts/, the
README, and this repo's .claude/ directory. For anything else, the session has
to be launched on the repo that owns it (EXE = desktop, APK = mobile,
SDB = schema, APP = docs/chain/skills, PWA = browser build, PKG = packages,
TRX = transfer service, WEB = website).

Verified unavailable here, so do not try:
  - npm start            -> delegates to DraconDex-EXE, which is not cloned
  - scripts/*.ps1        -> PowerShell; pwsh is not installed in this container
  - the chain tooling    -> lives in DraconDex-APP/tools/, also not cloned
There is no linter and no test suite in this repo to run.

Read .claude/skills/cloud-session/SKILL.md before working around any of that,
and CLAUDE.md for the routing rules.
CONTEXT
