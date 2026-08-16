# 🌌 MonboVerse Library Hub

A Roblox **executor script library** — a unified hub that detects the game you are in,
lets you browse supported games, verifies access through a single centralized key
system (Junkie), and loads the matching game script. Built in Lua/Luau for
executor environments (not Roblox Studio).

> Repo path: `robloxscripts/MonboVerse Library Hub/` in `MonboSoNasty/RobloxScriptz`
> (branch `main`).

---

## Overview

The hub is a source-distribution library loaded via `loadstring` inside an executor.
It is split into **Core** (library lifecycle, detection, registry, loading),
**Services** (Junkie key system, GitHub, metadata), and **UI** (design system,
library browser, game details, key UI, Galaxy intro). Game scripts live in
`scripts/` and are plain, self-contained Luau files with **no key-system code** —
verification always happens in the hub *before* a game script is loaded.

The hub ships its first registered game script: **Moon Incremental by NVHeadMonbo
v2.0** — a faithful refactor of the original with the key system removed.

## Features

- 🔍 **Auto-detection** — reads `game.PlaceId` and finds a matching registry entry.
- 📚 **Library browser** — searchable game list with icons, versions, status badges.
- 🎬 **Galaxy intro** — skippable 6-phase cinematic on startup (all particles are
  round circles — no text-glyph "stars" or square nebula artifacts).
- 🔑 **Centralized key system** — one Junkie config, one verification flow, applied
  to every game. Game scripts contain zero key code.
- ⌨️ **K keybind** — toggles the library; after a script loads, `K` is handed off
  to that script's UI automatically (no duplicate handlers).
- 🧩 **Modular architecture** — Core / UI / Services modules, all pcall-guarded so a
  single failing entry never breaks the hub.
- ✅ **Tooling** — `tools/validate.py` (Lua sanity + project checks) and
  `tools/release.py` (deterministic minify/package pipeline).
- 🖥️ **First game script** — Moon Incremental v2.0 (Tiny Ocean theme, rainbow border,
  draggable window, toggles, sliders, toasts, `K` keybind, single Heartbeat loop).

## Installation

Requirements: a Roblox executor that supports `loadstring`, `game:HttpGet`,
`writefile`/`readfile`/`delfile`, and standard Luau.

1. Open Roblox and join the game you want to use (e.g., Moon Incremental).
2. Attach your executor and paste the loader below (or run the hub file from a
   saved script):

```lua
-- MonboVerse Library Hub loader (raw GitHub) — full experience (Galaxy intro + library UI)
local url = "https://raw.githubusercontent.com/MonboSoNasty/RobloxScriptz/main/robloxscripts/MonboVerse%20Library%20Hub/src/Bootstrap.lua"
local source = game:HttpGet(url)
local ok, err = loadstring(source)
if ok then
    ok, err = pcall(ok)
end
if not ok then
    warn("[MonboVerse Library] failed to load:", err)
end
```

> Tip: `src/Bootstrap.lua` is the full entry point (Galaxy intro + library UI +
> wiring). `src/Core/Library.lua` loads only the core (detection + registry)
> without the UI.

3. The Galaxy intro plays (press the skip button to skip).
4. The hub detects the current game, shows the library, and you pick a game →
   **Load Script**.
5. Choose a key duration, complete verification (Junkie), and on **Access Granted**
   the game script loads automatically.

> Note: URLs with spaces are percent-encoded (`%20`). All game scripts under
> `scripts/` can also be run standalone — they have no key gate.

## Keybinds

- **K** — toggle the library window open/closed. Ignored while typing in a text
  box (e.g. search or key input).
- **K (after a script loads)** — the hub closes the library, disconnects its own
  `K` handler, and hands `K` to the loaded script, so `K` toggles that script's
  UI without reopening the library or double-firing.

## Supported Games

| Game | PlaceId | Version | Status |
| ---- | ------- | ------- | ------ |
| Moon Incremental | TODO | 2.0.0 | Stable |

> The real Moon Incremental PlaceId is still **TODO** — until it is added to
> `config/library.json`, auto-detection cannot match the game and the script must
> be launched manually or via "Load" from the library.

## Adding a New Game

1. **Write the script** — add a self-contained Luau file to `scripts/<Game>.lua`.
   It may reuse hub helpers via `getgenv().MonboVerse` but must keep its game logic
   self-contained. **No key-system code** — the hub verifies first.
2. **Create the manifest** — `metadata/<Game>.json` (see Metadata Format below).
3. **Register the game** — add an entry to the `games` array in
   `config/library.json` with `script` and `metadata` relative paths.
4. **Validate** — run `python tools/validate.py` and fix any errors.
5. **Release & commit** — run `python tools/release.py`, then commit:
   `feat: add <Game> to library (v<version>)`.

## Metadata Format

`metadata/<Game>.json`:

```json
{
  "name": "Moon Incremental",
  "id": "moon-incremental",
  "author": "NVHeadMonbo",
  "version": "2.0.0",
  "placeIds": [],
  "description": "Moon Incremental automation/features",
  "status": "stable",
  "lastUpdated": "2026-08-16",
  "tags": ["incremental", "moon", "automation"],
  "changelog": ["Improved UI", "Added library integration", "Centralized key system"]
}
```

- `version` must be **semver** (`MAJOR.MINOR.PATCH`).
- `placeIds` is a list of integers (may be empty while the real PlaceId is unknown —
  mark it TODO).
- `status`: `stable` | `beta` | `alpha` | `disabled`.

`config/library.json` mirrors the registry (source of truth for the hub at runtime):
`repo`, `schemaVersion`, and a `games` array with `id`, `name`, `placeIds`,
`script`, `metadata`, `version`, `enabled`, `status`, `author`, `description`,
`tags`, `updatedAt`.

## Versioning

Strict [semver](https://semver.org/) — `MAJOR.MINOR.PATCH`:

- **MAJOR** — breaking change (UI/API overhaul, breaking remote changes).
- **MINOR** — new feature (new toggle, new game).
- **PATCH** — bugfix (crash fix, tuning, polish).

Bump the version in **both** `metadata/<Game>.json` and `config/library.json`
together; add a `changelog` entry. `tools/validate.py` enforces the format.

## GitHub Workflow

- Default branch: `main`. All changes land via small, focused commits (or PRs).
- Commit message conventions:

```
feat: add Moon Incremental to library (v2.0.0)
fix: stop sliders from dragging while minimized
docs: document adding a new game
refactor: centralize remote fetching in ScriptLoader
chore: bump library.json schemaVersion
```

- Run `python tools/validate.py` before every push; a failing validation blocks the
  release. Never commit `config/secrets.json` (it is gitignored).

## Key System

- **Single source of truth**: `src/Services/JunkieConfig.lua` holds the Junkie
  service/identifier/provider. No other file may contain Junkie credentials.
- `src/Services/KeySystem.lua` drives everything: loads the SDK, shows duration
  select + verification UI, checks keys, saves verified keys via `writefile`,
  and calls the success callback → `ScriptLoader.Load(entry)`.
- Game scripts must **never** call Junkie directly.
- Optional overrides (e.g. SDK URL, defaults) live in gitignored
  `config/secrets.json` (template: `config/secrets.example.json`). Keys saved by
  the executor are also gitignored (`*.key`).

## Development Setup

1. Clone `MonboSoNasty/RobloxScriptz` and `cd "robloxscripts/MonboVerse Library Hub"`.
2. Python 3.10+ (stdlib only — no dependencies).
3. Edit modules; every file starts with
   `-- MonboVerse Library Hub :: <ModuleName> :: <one-line purpose>`.
4. Sanity-check with the tools:

```
python tools/validate.py          # Lua sanity + JSON/semver/paths
python tools/release.py           # build release/ (minified + packaged)
```

## Release Process

1. Bump versions (`metadata/`, `config/library.json`) and update changelogs.
2. `python tools/validate.py` → must end with `✅ All checks passed`.
3. `python tools/release.py` → writes minified Lua + copied payload into
   `release/` (relative paths preserved). It never modifies `scripts/` or `src/`
   and never deletes anything — `release/` is a generated artifact you can remove
   and regenerate at any time.
4. Test the `release/` output in an executor (validated by re-running
   `python tools/validate.py release`).
5. Commit (`feat:`/`fix:`/`chore:`) and push to `main`.

## Troubleshooting

| Problem | Fix |
| ------- | --- |
| Hub loads but shows nothing | Executor blocks `game:HttpGet` — allow network access / use a supported executor. |
| "Script Unavailable" | `script` path in `library.json` is wrong or the file moved — run `validate.py`. |
| Game not detected | `placeIds` for that game is empty/TODO or your PlaceId isn't listed — add it. |
| Key UI never appears | Junkie SDK URL unreachable or `secrets.json` override broken — check `config/`. |
| "✕ Invalid Key" | Key expired/mistyped — get a new key via the **Get Key** button. |
| Script loaded, toggles do nothing | Wrong PlaceId / remotes changed — check the game's current remotes and update the script. |
| `K` doesn't open the library | A text box (search/key) has focus, or a script already owns `K` — click outside the box / reload the hub. |
| `validate.py` reports unbalanced blocks | You edited a `.lua` and broke an `end` — check the reported line. |
| Windows can't run `python` | Use `py -3 tools/validate.py` or add Python to PATH. |

## Security Notes

- No real secrets/tokens are ever committed. `config/secrets.json` is gitignored;
  commit only `config/secrets.example.json`.
- This repository is **public**. The Junkie `identifier` in `JunkieConfig.lua` is
  a **public script ID**, not a secret — the loader needs it and executor users
  can read it anyway. It stays in the repo; only real credentials (e.g. a GitHub
  PAT) belong in gitignored `config/secrets.json`.
- No anti-cheat circumvention or evasion obfuscation — the release pipeline is
  minify/package only.
- Every HTTP/load/verify call is wrapped in `pcall`; one failed entry never breaks
  the hub, and all connections are tracked and cleaned up.
