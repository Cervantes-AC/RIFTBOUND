# Requirements traceability

Status legend: **AUTO** = verified by an automated test that was actually run (see `docs/TEST_PLAN.md` for results) -
**PC** = exercised on a Windows PC in a real window (screenshots) - **DEVICE?** = implemented but **not yet verified on a real phone**.

## ITSD 85 lab acceptance checklist (R1-R10)

| ID | Lab requirement | Scene / script that satisfies it | Test | Status |
|---|---|---|---|---|
| R1 | >= 5 levels, each harder/different | `resources/levels/levels.json`, `scenes/arenas/*.tscn`, `Arena.gd`, `ArenaArt.gd`, `GameState.build_campaign_config` | `SimTest` data checks ("five levels defined", difficulty and AI reaction monotonic), campaign sim plays all 5 | AUTO (instructor play-through pending) |
| R2 | Clear goal shown at level start | `MatchManager._build_ui` -> `HUD.show_banner` (level name + objective) and lose-rule hint; tutorial hints in level 1 | screenshots `match_*_countdown.png`; `SimTest` checks objective text exists for every level | AUTO + PC |
| R3 | Win/lose + result screen with Retry / Next / Menu | `ResultScreen.gd` (stars, health, time), `MatchManager._present_result/_finish` | `SimTest` "level N shows a result screen", unlock-flow test (win and loss branches) | AUTO + PC |
| R4 | Level n+1 locked until n cleared; lock icon; cannot open | `SaveManager.is_level_unlocked/complete_level`, `LevelSelect.gd` (padlock), `GameState.build_campaign_config` (returns `{}` if locked), `MatchManager._ready` (re-checks lock) | `SimTest` progression block (fresh install, clear L1 unlocks only L2, replay keeps progress, locked config refused) | AUTO + PC |
| R5 | Progress saved and survives closing the app | `SaveManager` -> `user://save.cfg` (`ConfigFile`), saved immediately in `complete_level` | `SimTest` reload-from-disk checks (progress, stars, settings, stats), tamper test | AUTO + emulator (load after force-stop verified on emulator with an injected save; earning progress and restarting a physical phone: DEVICE?) |
| R6 | Offline mode playable in airplane mode | campaign + quick match use no network code (`NetworkManager` is idle unless the lobby is used) | `SimTest` plays levels with the network never started | AUTO + emulator (app launches/navigates with airplane mode on; physical phone: DEVICE?) |
| R7 | Online mode, two devices, same match | `NetworkManager.gd`, `OnlineLobby.gd`, `MatchManager` host/guest paths, `RemoteController.gd` | `NetTest` two processes over real ENet sockets: lobby sync, input to host, snapshots to guest, result on both | AUTO (two-process on one PC) - **two phones: DEVICE?** |
| R8 | Mode selection Offline/Online + clear message when server unreachable | `MainMenu.gd` (Play Offline / Play Online), `OnlineLobby._on_failed`, `NetworkManager.join_game` (8 s timeout, validation, "no Wi-Fi" check) | `NetTest -- fail` and `-- badip` | AUTO |
| R9 | Runs on real phone (APK), one orientation, touch controls | `project.godot` (`window/handheld/orientation=0` landscape), `export_presets.cfg`, `TouchControls.gd` | `SimTest` touch layout (no overlap, >= 88 px) and multitouch input tests | APK builds/installs/runs on an Android 16 **emulator** with real touch events (TEST_PLAN B0); physical phone: DEVICE? |
| R10 | Title, pause menu, sound on/off, readable text | `TitleScreen.gd`, `PauseMenu.gd` (Resume/Restart/Sound/Music/Quit), `SettingsScreen.gd`, `PixelUI` (min font 14, body 16+) | screenshots; `SaveManager` setting persistence in `SimTest` | AUTO + PC (small-screen legibility: DEVICE?) |
| Optional | Star rating, settings (volume, vibration), tutorial hints | `SaveManager.stars_for_health`, `SettingsScreen`, level-1 hints in `levels.json` | `SimTest` star thresholds | AUTO |

## Master-brief gameplay requirements

| Brief section | Requirement | Implementation | Test | Status |
|---|---|---|---|---|
| 3.1 | Six classes, three archetypes, 18 skills, configurable data | `classes.json`, `skills.json`, `ClassData/SkillData/Library`, one `Fighter` | `SimTest` data + "all 6 classes x basic + 3 skills execute, start cooldown and damage" | AUTO |
| 3.1 | Unique visuals, attack/hurt/death animations | `CharacterVisual.gd` (procedural **placeholder**) | screenshots | PC (placeholder art) |
| 3.2 | Movement, jump, platforms, facing, hitboxes/hurtboxes, damage, knockback, dodge, cooldowns, projectiles, AoE, defence, health bars, elimination, timer, win/lose | `Fighter`, `CombatComponent`, `Hitbox`, `Projectile`, `AreaEffect`, `HealthComponent`, `SkillManager`, `HUD`, `MatchManager` | `SimTest` combat block (exact damage, single hit per swing, 3-hit multi-hit, cooldown, shield 70 %, dodge i-frames, jump/land, bounds, no friendly fire, dead cannot attack, HP never < 0) | AUTO |
| 3.3 | 1v1 / 2v2 / 3v3 offline; online 1v1 | `GameState.build_quick_config`, `MatchModeSelect.gd`, `NetworkManager` | `SimTest` team modes; `NetTest` | AUTO (online 2v2/3v3 optional - not implemented) |
| 3.4 | 5 arenas with hazards (lava, ice, moving hazards, boss) | `Arena.gd`, `ArenaArt.gd`, `MatchManager` (surges, enrage) | `SimTest` hazard checks, 5-level sim; screenshots | AUTO + PC |
| 3.5 | Progression + star ratings (1 / >=30 % / >=60 %), best stars saved | `SaveManager`, `MatchManager._present_result` | `SimTest` star + unlock tests | AUTO |
| 3.6 | `user://save.cfg` with all listed fields; online does not alter campaign | `SaveManager` | `SimTest` persistence + "online match does not alter campaign progress"; `NetTest` | AUTO (restart-phone: DEVICE?) |
| 3.7 | Offline without internet | see R6 | | AUTO / DEVICE? |
| 3.8 | ENet host/join, IP display, status, failures, class selection, start sync, movement/attack/health/timer/result sync, disconnect handling, host-authoritative, port 7777, Android permissions | `NetworkManager`, `OnlineLobby`, `MatchManager`, `export_presets.cfg` | `NetTest` (host+guest), `-- fail`, `-- badip` | AUTO (two phones: DEVICE?) |
| 4 | Architecture (autoloads, components, signals, typed GDScript, no 3rd-party deps) | see `docs/ARCHITECTURE.md` | `CheckAll` loads every script/scene | AUTO |
| 5 | Visual design, 13 screens, mobile controls, original/verified assets | all `scenes/ui/*`, `HUD`, `PauseMenu`, `ResultScreen`, `TouchControls` | screenshots | PC; art is placeholder |
| 7 | Five-week schedule, playtest, 3 improvements, retest, paper, video | `docs/PLAYTEST_PLAN.md` | - | **Not started** (needs real testers; paper/video are manual deliverables) |
| 9 | Required documents | `README.md`, `docs/*` | - | Done (playtest results intentionally an empty template) |

## Differences between the brief and the lab sheet

See the end of `docs/GDD.md`. In short: renderer set to GL Compatibility (both documents ask for it), lab touch/text guidelines applied, levels are data-driven rather than five `Level0N.tscn` files.
