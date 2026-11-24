# Development log

## 2026-11-25 - Milestone 1: first complete build (all phases implemented on PC)

### Phase 1 - inspect and plan
* Repository state at start: Godot 4.7 starter project (`project.godot` set to the *mobile* renderer, Jolt/D3D12 3D settings), one commit, `docs/source/ITSD 85 Lab ... .md` (the lab sheet). **No separate finalized GDD file existed**, so `docs/GDD.md` was written from the master brief using the lab's template (noted in the GDD).
* Tools found: Godot 4.7.2 (`C:\Godot\godot.exe`), JDK 25, Android SDK (build-tools 36.1, platform-tools). **Godot export templates were not installed.**
* Requirements checklist: `docs/REQUIREMENTS_TRACEABILITY.md`.
* Project settings changed: GL Compatibility renderer, 1280x720, `canvas_items`/`expand`, sensor-landscape orientation, mouse->touch emulation, Android back button handled in-game (`quit_on_go_back=false`).

### Phase 2/3 - playable build and character system
* Data layer (JSON -> `ClassData`/`SkillData` resources), one reusable `Fighter` (state machine, coyote time, jump buffer, double jump, drop-through platforms, dodge, status effects), `CombatComponent` (12 skill kinds), `Hitbox` / `Projectile` / `AreaEffect` with per-target hit registries.
* Procedural placeholder art for six classes with weapons and animations; five procedural arenas; procedural SFX and music.
* HUD (team bars with damage trail, timer, banners, countdown), touch controls (floating joystick + 6 multi-touch buttons with cooldown sweeps), pause menu, result screen.

### Phase 4/5 - campaign and team modes
* Five levels from `levels.json` (AI parameters rise per level; boss with enrage), hazards (lava, ice, moving rift orbs, rift surges), objective banner + lose rule + level-1 tutorial hints.
* `SaveManager` (ConfigFile `user://save.cfg`): unlocks, best stars, totals, stats, settings; tamper guard; online stats kept separately.
* Locked levels: padlock UI + refusal in `GameState` + re-check inside `MatchManager`.
* Offline 2v2 / 3v3 with AI allies and opponents; elimination/timeout rules.

### Phase 6 - Wi-Fi multiplayer
* `NetworkManager` (ENet, port 7777, one guest), lobby (host IP display, join by IP, class + arena + ready sync), host-authoritative match (guest sends input only; host sends 30 Hz snapshots, effects, SFX and the final result), disconnect handling both ways, 8 s join timeout, validation, "no Wi-Fi" message.
* Tested with two real Godot processes over ENet on localhost (`tests/NetTest.gd`). **Not yet tested on two phones.**

### Phase 7 - polish
* Menus: title, main, offline mode select, quick-match select, level select, class select, lobby, settings, credits.
* Readability pass after reviewing the lab guidelines: minimum font 14 px / body 16+ px, touch buttons >= 88 px, safe-area insets for notched phones.
* Arena background animation throttled to 20 Hz for phone performance.

### Bugs found by running the project, and fixed
| Found by | Problem | Fix |
|---|---|---|
| first import | `preload` of the font failed before the font was imported | ran `--import`; PixelUI keeps the preload |
| `CheckAll` | `draw_line` argument order (width/colour swapped) in `CharacterVisual`; `abs()` returned Variant in `MenuBackdrop` | fixed signatures, `absf` |
| screenshots | class previews invisible: `set_physics_process(false)` before `add_child` is re-enabled on tree entry, so previews fell off-screen | disable after `add_child` |
| screenshots | touch controls invisible: `set_anchors_preset` inside `_ready` under a `CanvasLayer` left size 0 | explicit anchors/offsets |
| `SimTest` | melee skills tested at ranged distance; movement test relied on a controller-less fighter | tests corrected (not game bugs) |
| `NetTest` | the test node was the current scene and was freed by the first scene change | detach from `current_scene` |
| balance sweep | Duelist 0 % win rate, Gunslinger 80 %, Shadeweaver 15 % (AI vs AI) | HP/damage/cooldown tuning pass (see `tests/Balance.gd` output in the test plan) |
| `SimTest` | Quick Slash test hard-coded old damage after rebalancing | test reads the skill data |

### Milestone 1b - QA audit and Android build (same day)
* Installed the official Godot 4.7.2 Android export templates (1.28 GB download; only the Android files were extracted), pointed Godot's *editor setting* "Java SDK path" at the installed JDK, enabled ETC2/ASTC import (required by the Android export), reused the standard Android debug keystore. Debug APK exports and is signed.
* Ran the APK on an Android 16 emulator: install, launch, landscape, menus, touch input, match, defeat screen, on-device save, force-stop reload, airplane mode (details and limits in `docs/TEST_PLAN.md` B0).
* **Real bug found on Android and fixed:** SIGSEGV in the audio mixer ~40 s after launch (native `AudioStreamWAV` loop on the music). Replaced with replay-on-finish and padded streams.
* **Layout fix found on a wide screen:** the right-team spawn was hidden behind the skill buttons; spawns moved inward. Toast text moved off the screen titles.
* Verified layouts at 20:9, 4:3 and 854x480 (`tests/ScreenSizes.gd`).
* Re-ran all automated suites on the final code: `CheckAll` 69 files OK, `SimTest` 186/186, `NetTest` host+guest OK, failure paths OK.
* Added x86_64 to the export preset so emulators/Chromebooks can run the APK (arm64-v8a for phones).

### Remaining issues / not done
* **Physical-phone verification** (touch feel, performance, airplane mode, force-stop/restart persistence, **two-phone online match**) - procedures in `docs/TEST_PLAN.md`. Only an emulator was available; online play was tested between two desktop processes, not between two devices.
* The emulator's software GPU failed to link a shader; confirm on a real low-end phone that rendering works.
* Online 2v2 / 3v3 (optional in the brief) - not implemented.
* Final pixel-art sprites, audio and launcher icon - placeholders documented in `docs/CREDITS.md`.
* Week-5 deliverables that need people: external playtest (>= 5 testers), >= 3 improvements, retest with >= 2 new testers, IEEE-style paper, demo video, repository cleanup. Plan and empty results template exist.
* Git: nothing has been committed by the assistant; the working tree is ready to commit.

### Exact next development task
Install the APK on two Android phones and run the manual checklist in `docs/TEST_PLAN.md` section B (airplane mode, force-stop persistence, two-phone online match), fix whatever the phones reveal, then start the Week-5 playtest using `docs/PLAYTEST_PLAN.md`.

## 2026-11-25 - Milestone 2: visual identity and polish pass

Audit and direction: `docs/DESIGN_AUDIT.md`. Gameplay, AI, save data and networking code were not changed
(effects still go through `MatchManager.fx(kind,pos,data)`, so new effects replicate online automatically).

* **Arenas** (`ArenaArt.gd`, rewritten): per-level layered scenery - forest ruins + background portal + glowing flora + fireflies;
  cavern lava falls, basalt columns, magma-veined walls, heat shimmer; citadel aurora, ice castle, crystals, snow;
  shadow realm Watcher eye, leaning ruins, unstable portals; sanctuary great Rift with lightning, glyph pillars, floating platforms.
  Edge-only foreground node drawn above fighters. Hazard telegraphs: lava pit glow + warning signs, rift orbs show their next 1.2 s path.
* **UI:** `PixelBox` bevelled button style (hover/pressed/disabled/focus ring), animated Rift-portal backdrop (`MenuBackdrop`),
  `RiftLogo`, new main menu with the six required entries + campaign progress pips, standalone Character Selection flow.
* **Characters:** per-class idle personality, victory pose, chain-link root visual, dash/dodge afterimages, `Portrait` art.
* **Combat FX:** class-specific hit sparks (directional particles), slash crescents, muzzle stars, ground cracks on shockwaves, Arcanist casting runes.
* **HUD:** class portraits with team frames, arena intro band at round start.
* **Class select:** big stage preview, role, damage stat, skill descriptions, select pulse. **Level select:** per-arena landmarks, CLEAR badge. **Results:** portrait + confetti.
* New test helpers: `tests/ArenaShots`, `tests/UIShots` (windowed screenshots).

Verified: `CheckAll` 76 files OK, `SimTest` 186/186, `NetTest` host+join, `fail`, `badip` OK, `Screenshots` and `ScreenSizes` (1920x864, 1024x768, 854x480) reviewed by eye.
Not verified: on a physical phone (performance of the richer scenery), two-phone online play, Android export of this build, audio (unchanged placeholders).
