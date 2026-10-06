# DraconDex-DEV

Controller repo for the DraconDex multi-repository project. It holds no
application code — only the VS Code workspace, setup/start scripts, and
gitignore rules that keep the eight real repos out of this one's history.

## Layout

```
DraconDex-DEV/
├── DraconDex.code-workspace   # multi-root workspace (relative paths, safe to move)
├── scripts/
│   ├── setup.ps1              # clone whichever child repos are missing + npm install
│   └── start-dev.ps1          # run a dev target (-Target Exe|Pwa)
├── DraconDex-APP/  # hub: docs, chain contract, shared Claude tooling  → repo of its own
├── DraconDex-SDB/  # schema, Supabase setup, asset masters            → repo of its own
├── DraconDex-EXE/  # Windows desktop app (Electron)                   → repo of its own
├── DraconDex-APK/  # Android/iOS (Flutter)                            → repo of its own
├── DraconDex-PWA/  # browser build of EXE/APK                         → repo of its own
├── DraconDex-PKG/  # downloadable theme/language/view packages        → repo of its own
├── DraconDex-TRX/  # DDX Transfer service (Netlify)                    → repo of its own
└── DraconDex-WEB/  # public website                                   → repo of its own
```

Each `DraconDex-*` folder is its own git repository (own `.git`, own GitHub
remote under `ZYDRAXYL/`). `.gitignore` excludes them entirely from this
repo, so this repo only ever tracks the controller files above. See
`DraconDex-APP/chain/README.md` for how changes flow between the eight repos.

## Chained repositories

The eight repos in `DraconDex-APP/chain/chain.json`, all under [`ZYDRAXYL`](https://github.com/ZYDRAXYL):

| Repo | What it is | Releases | Visibility |
|---|---|---|---|
| [DraconDex-APP](https://github.com/ZYDRAXYL/DraconDex-APP) | Hub — docs, chain contract, shared Claude tooling | — | private |
| [DraconDex-SDB](https://github.com/ZYDRAXYL/DraconDex-SDB) | SQLite schema, Supabase setup, asset masters | `sdb-v*` | public |
| [DraconDex-TRX](https://github.com/ZYDRAXYL/DraconDex-TRX) | DDX Transfer hand-off service (Netlify) | — | public |
| [DraconDex-EXE](https://github.com/ZYDRAXYL/DraconDex-EXE) | Windows desktop app (Electron) | `v*` | private |
| [DraconDex-APK](https://github.com/ZYDRAXYL/DraconDex-APK) | Android/iOS app (Flutter) | `flutter-v*` | private |
| [DraconDex-PWA](https://github.com/ZYDRAXYL/DraconDex-PWA) | Browser build of EXE and APK | — | public |
| [DraconDex-PKG](https://github.com/ZYDRAXYL/DraconDex-PKG) | Downloadable theme/language/view packages | `pkg-v*` | public |
| [DraconDex-WEB](https://github.com/ZYDRAXYL/DraconDex-WEB) | Public website and release mirror | release mirror | public |

Changes flow one way along the chain — see [`chain/README.md`](https://github.com/ZYDRAXYL/DraconDex-APP/blob/main/chain/README.md) in DraconDex-APP:

```
EXE   APP > SDB, TRX > EXE > PKG, WEB, PWA
APK   APP > SDB, TRX > APK > PKG, WEB, PWA
PWA   APP > SDB, TRX > EXE, APK > PWA > WEB
```

## First-time setup on a new device

### Prerequisites

- [Git](https://git-scm.com/) — and GitHub access to the `ZYDRAXYL` org.
  `APP`, `EXE`, and `APK` are **private** repos, so `git clone` over HTTPS
  will prompt for GitHub sign-in the first time; have that ready.
- [Node.js LTS](https://nodejs.org/) (ships `npm`) — required by every repo.
- [VS Code](https://code.visualstudio.com/) — optional but this project
  ships a workspace file with its own tasks/launch configs.
- Flutter SDK — only needed if you're working inside `DraconDex-APK`.

### Steps

```powershell
git clone https://github.com/ZYDRAXYL/DraconDex-DEV.git
cd DraconDex-DEV
./scripts/setup.ps1
```

`setup.ps1` clones any of the eight `DraconDex-*` repos that aren't already
present next to it and runs `npm install` in each. It's idempotent — re-run
it any time to pick up a repo you don't have locally yet.

> If PowerShell refuses to run the script ("running scripts is disabled on
> this system"), run it once as:
> `powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1`

Verify the setup worked:

```powershell
npm start
```

This launches the Windows desktop app (`DraconDex-EXE`) from the DEV root.

Then open `DraconDex.code-workspace` in VS Code. It ships its own tasks and
launch configs (Command Palette → *Tasks: Run Task* / *Run and Debug*):

- **Setup: Clone & Install All Repos** — re-run `setup.ps1`
- **Start: EXE (Electron)** / **Start: PWA (serve)** — run a dev target
- **Chain: Survey** / **Chain: Propagate** — the cross-repo chain tooling
- **Debug EXE (Electron Main)** — launch the desktop app under the debugger

### Troubleshooting

- **"Electron binary is missing or incomplete"** when running `npm start` —
  `npm install` hasn't finished in `DraconDex-EXE` yet. Run
  `npm install --prefix DraconDex-EXE` (or re-run `setup.ps1`).
- **Clone of `APP`/`EXE`/`APK` fails with 404 or asks for a password on
  every attempt** — your GitHub account doesn't have access to that private
  repo yet, or Git's stored credentials are stale; sign in again via
  `git credential-manager` or switch that repo's remote to SSH.

## License

MIT — see [LICENSE](LICENSE). Created by LDKTC.
