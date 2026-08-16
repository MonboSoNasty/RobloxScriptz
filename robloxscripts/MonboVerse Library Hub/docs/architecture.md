# MonboVerse Library Hub — Architecture

> Repo path: `robloxscripts/MonboVerse Library Hub/` · Branch: `main`
> Execution model: executor environment (source distribution, loaded via
> `loadstring`) — **not** Roblox Studio ModuleScripts. Modules are plain Lua
> tables returned at end of file; avoid `require`.

## 1. Module Tree

```
MonboVerse Library Hub/
├── README.md
├── .gitignore                       # secrets.json, release/, *.key, __pycache__/, .DS_Store, *.log
├── config/
│   ├── library.json                 # machine-readable registry + repo config (runtime source of truth)
│   └── secrets.example.json         # optional secret override template (never commit real secrets)
├── scripts/
│   └── MoonIncremental.lua          # refactored game script — NO key system inside
├── metadata/
│   └── MoonIncremental.json         # per-game manifest (semver, placeIds, changelog)
├── src/
│   ├── Bootstrap.lua                # entry point — assembles hub, wires UI flow + K keybind, plays intro
│   ├── Utils.lua                    # safeCall, semver, clone, clipboard, ConnectionTracker
│   ├── Core/
│   │   ├── Library.lua              # assembly root — exposes getgenv().MonboVerse
│   │   ├── GameDetector.lua         # detects current game from PlaceId
│   │   ├── ScriptRegistry.lua       # in-memory registry of games
│   │   └── ScriptLoader.lua         # authorized fetch + loadstring of game scripts
│   ├── Services/
│   │   ├── JunkieConfig.lua         # ⭐ ONLY file with Junkie credentials
│   │   ├── KeySystem.lua            # centralized verification (single source of truth)
│   │   ├── GitHub.lua               # raw fetching + update checks
│   │   └── Metadata.lua             # manifests + Roblox thumbnail API (cached)
│   └── UI/
│       ├── UI.lua                   # shared design system (Tiny Ocean + KC palettes)
│       ├── LibraryUI.lua            # searchable game list
│       ├── GameDetailsUI.lua        # per-game details panel
│       ├── KeyUI.lua                # duration select + verification
│       └── GalaxyIntro.lua          # skippable 6-phase cinematic (round-circle particles)
├── tools/
│   ├── validate.py                  # Lua sanity + project validation (stdlib only)
│   └── release.py                   # deterministic minify/package pipeline (stdlib only)
└── docs/
    └── architecture.md              # this document
```

## 2. Dependency Flow

```
                        ┌─────────────────────────────┐
                        │ Library.lua  (getgenv().    │
                        │   MonboVerse = Library)     │
                        └──────────────┬──────────────┘
                                       │ Init order:
        ┌──────────────┬───────────────┼───────────────┬──────────────┐
        ▼              ▼               ▼               ▼              ▼
   Utils.lua    JunkieConfig.lua  KeySystem.lua   GitHub.lua   Metadata.lua
        │              │               │               │              │
        └──────────────┴───────────────┼───────────────┴──────────────┘
                                       ▼
                               GameDetector.Detect()
                                       │
                                       ▼
                                LibraryUI.Show()  (browse)
                                       │ OnSelect
                                       ▼
                              GameDetailsUI.Show()
                                       │ [Load Script]
                                       ▼
                        KeySystem.RequestVerification(entry)
                                       │
                                       ▼
                     KeyUI.ShowDurationSelect ──► KeyUI.ShowVerification
                                       │        (KeySystem.CheckKey → valid?)
                                       ▼
                          KeySystem.OnVerified(entry, key)
                                       │
                                       ▼
                           ScriptLoader.Load(entry)   ──►  GitHub.FetchRaw(entry.Script)
                                       │                       │
                                       ▼                       ▼
                       loadstring + pcall  ◄────────  scripts/MoonIncremental.lua
                                       │              (game script, no key code)
                                       ▼
                        Game loop runs (Heartbeat, remotes)
```

`src/Bootstrap.lua` is the entry point that drives this flow: it calls
`Library.Init()`, loads the UI modules, publishes the `getgenv().MonboVerse`
namespaces, wires the UI callbacks, registers the `K` keybind, and plays
`GalaxyIntro` before revealing `LibraryUI`.

Module-to-module dependencies (one direction only):

- **UI → Core/Services**: UI reads `ScriptRegistry`, calls `Library.Select` /
  `Library.LoadSelected`, `KeySystem` methods. UI never talks to GitHub/Junkie
  directly.
- **Core → Services**: `ScriptLoader` uses `Services.GitHub.FetchRaw`;
  `Library.Init` wires `Utils → JunkieConfig → KeySystem → GitHub → Metadata →
  GameDetector → ScriptRegistry`.
- **Game scripts → hub**: optional read of `getgenv().MonboVerse.UI` only; game
  logic stays self-contained (no hard dependency).

## 3. Module Responsibilities

| Module | Responsibility | Key functions |
| ------ | -------------- | ------------- |
| `Bootstrap.lua` | Entry point; wires the full UX flow + `K` keybind | loads Library + UI, publishes namespaces, `K` toggle/handoff, plays Galaxy intro |
| `Utils.lua` | Safe wrappers & small helpers | `safeCall`, `semverCompare`, `isValidSemver`, `clone`, `getPlaceId`, `ConnectionTracker` |
| `Core/Library.lua` | Assembly root; owns `getgenv().MonboVerse` | `Init`, `Select`, `LoadSelected`, `GetDetected`, `GetSelected`, `GetRegistry` |
| `Core/GameDetector.lua` | Detect current game from PlaceId | `Detect`, `FindEntry`, `GetStatus` |
| `Core/ScriptRegistry.lua` | Registry of games (enabled + disabled) | `GetGames`, `GetById`, `FindByPlaceId`, `AddGame`, `RemoveGame` |
| `Core/ScriptLoader.lua` | Authorized loading of game scripts | `FetchSource`, `Load` (loadstring + pcall, registry-gated) |
| `Services/JunkieConfig.lua` | ⭐ ONLY Junkie credentials | `Provider/Service/Identifier`, `SDKUrl`, `KeyDurations`, `Defaults` |
| `Services/KeySystem.lua` | Single source of truth for verification | `Init`, `RequestVerification`, `CheckKey`, `GetKeyLink`, `SaveKey`, `LoadSavedKey`, `OnVerified` |
| `Services/GitHub.lua` | Raw repo access + updates | `RawUrl`, `FetchRaw`, `FetchJson`, `FetchRegistry`, `CheckForUpdates` |
| `Services/Metadata.lua` | Manifests + Roblox thumbnails (cached) | `Get`, `GetGameMetaFromRoblox`, `GetGameIcon`, `ClearCache` |
| `UI/UI.lua` | Design system (Tiny Ocean + KC palettes) | `newWindow`, `toast`, `createCard`, `setupSlider`, `setupToggle`, `nav`, `blur` |
| `UI/LibraryUI.lua` | Library browser page | `Show`, `Hide`, `IsVisible`, `ToggleVisible`, `Refresh`, `OnSelect` |
| `UI/GameDetailsUI.lua` | Game details panel | `Show`, `Hide`, `OnLoadRequested` |
| `UI/KeyUI.lua` | Duration select + key verification UI | `ShowDurationSelect`, `ShowVerification`, `SetStatus`, `Close` |
| `UI/GalaxyIntro.lua` | 6-phase cinematic (round-circle particles) | `Play`, `Skip` |
| `scripts/MoonIncremental.lua` | First registered game script (self-contained) | UI + Heartbeat loop + remotes, **no key code** |
| `tools/validate.py` | Lua sanity + JSON/semver/path checks | exit 0/1 |
| `tools/release.py` | Deterministic minify/package into `release/` | never touches sources |

## 4. Key System — Single Source of Truth

**Rule:** Only `src/Services/JunkieConfig.lua` holds the Junkie service,
identifier, and provider. Only `src/Services/KeySystem.lua` talks to the Junkie
SDK. No other module — and **no game script** — may call Junkie directly.

Why:

- One config to update when the Junkie service/identifier changes.
- Verification is enforced once, before any script loads; scripts cannot bypass or
  duplicate it.
- Saved keys are validated (`CheckKey`) before trust; invalid keys are cleared.
- `config/secrets.json` may override defaults at runtime but is gitignored —
  committed files contain **no real credentials**.

Note: the repo is public, but the Junkie `identifier` is a **public script ID**,
not a secret — the `loadstring` loader needs it and executor users can read it
anyway, so it correctly stays in `JunkieConfig.lua`.

## 5. Startup / Selection / Verification Flow

1. **Bootstrap** — `src/Bootstrap.lua` loads the Library, calls `Library.Init()`,
   loads the UI modules, publishes `getgenv().MonboVerse.UI` (design system, with
   submodules attached as `UI.KeyUI` etc.), and wires the UI callbacks.
2. **Init** — `Library.Init()` loads `Utils → JunkieConfig → KeySystem → GitHub →
   Metadata`, detects the current game (`GameDetector.Detect`), and builds the
   registry.
3. **Galaxy intro** — `GalaxyIntro.Play(onComplete)` runs the skippable cinematic
   (Void → Universe formation → explosion → reverse collapse → MonboVerse title →
   library reveal), then cleans up all connections/objects.
4. **Browse** — `LibraryUI.Show()` renders the searchable game list from the
   registry (icon, name, version, status badge, description, View / Load).
5. **Details** — selecting a game opens `GameDetailsUI.Show(entry)` (back button,
   icon, name, version, status, author, description, changelog, **Load Script**).
6. **Load Script** — `Bootstrap.onLoadScript` selects the entry and calls
   `KeySystem.RequestVerification(entry)`.
7. **Duration** — `KeyUI.ShowDurationSelect` offers the configured durations
   (1/3/7/30 days) from `JunkieConfig.KeyDurations`.
8. **Junkie** — `KeyUI.ShowVerification` (key box, Verify, Get Key, clipboard,
   status states: "Scanning Library..." → "Generating Key Link..." →
   "Verifying Key...").
9. **Access granted** — `KeySystem.CheckKey` returns `valid`; `OnVerified`
   fires; Bootstrap hides the library + details, disconnects its `K` handler,
   and `ScriptLoader.Load(entry)` fetches the script via `GitHub.FetchRaw` and
   runs `loadstring` + `pcall`.
10. **Script runs** — `scripts/MoonIncremental.lua` builds its UI immediately and
    starts its Heartbeat game loop. No key code inside.
11. **K keybind** — `Bootstrap` registers one `UserInputService` handler: while
    the library is active, `K` toggles `LibraryUI.ToggleVisible()` (ignored while
    a text box has focus). On verification success the handler disconnects, so the
    loaded script owns `K` exclusively — no duplicate handlers, and the library
    never reopens behind the script's UI.

Status strings (KeyUI): "Scanning Library...", "Loading Metadata...",
"Checking Compatibility...", "Initializing Verification...", "Generating Key
Link...", "Verifying Key...", "Access Granted", "Loading Script...". Errors:
"✕ Invalid Key", "⚠ Script Unavailable".

## 6. Extension Guide

### 6.1 Add a Game

1. **Script** — add `scripts/<Game>.lua`, self-contained (own theme + helpers;
   may optionally use `getgenv().MonboVerse.UI`). No key-system code, no Junkie
   calls. Start with the header comment
   `-- <Game> by <Author> v<version> — MonboVerse Library entry`.
2. **Manifest** — add `metadata/<Game>.json` (name, id, author, semver `version`,
   `placeIds`, description, `status`, `lastUpdated`, `tags`, `changelog`).
3. **Register** — append to `games` in `config/library.json`:
   `{ "id", "name", "placeIds", "script": "scripts/<Game>.lua",
     "metadata": "metadata/<Game>.json", "version", "enabled", "status",
     "author", "description", "tags", "updatedAt" }`.
4. **Validate** — `python tools/validate.py` (Lua balance + JSON + semver +
   path existence).
5. **Release** — `python tools/release.py`, then commit `feat: add <Game> (vX.Y.Z)`.

### 6.2 Add a UI Page

1. Create `src/UI/<Page>UI.lua` returning a table, e.g.
   `function <Page>UI.Show(...)` / `Hide()` / `OnX(callback)`.
2. Build on the design system (`UI.newWindow`, `UI.createCard`, `UI.setupSlider`,
   `UI.toast`, `UI.blur`) — never hardcode a second palette.
3. Wire it into `Bootstrap.lua` or the owning UI module (e.g. add a nav entry in
   `LibraryUI` and register the page in its `switchPage`-style dispatcher).
4. Add a status string to the KeyUI loading/status sequence if the page involves
   async work.
5. Validate + release (`tools/validate.py`, `tools/release.py`), commit
   `feat: add <Page> page to hub`.

## 7. Hard Rules

1. Only `JunkieConfig.lua` holds Junkie service/identifier/provider.
2. No real secrets/tokens in committed files; `config/secrets.json` is gitignored.
3. No anti-cheat circumvention, no evasion obfuscation; release = minify/package
   only.
4. Every HTTP/load/verify call wrapped in `pcall`; one failed entry never breaks
   the hub.
5. Track and clean up all connections (`Utils.ConnectionTracker`).
6. Every file starts with
   `-- MonboVerse Library Hub :: <ModuleName> :: <one-line purpose>`.
