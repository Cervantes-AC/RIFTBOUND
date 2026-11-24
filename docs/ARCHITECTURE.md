# Architecture

Godot 4.7, GDScript (typed where practical), GL Compatibility renderer, no third-party dependencies.

## Folder layout

```
autoload/            global singletons (see below)
scenes/ui/           one scene per screen (root Control + script; widgets are built in code with PixelUI)
scenes/levels/       Match.tscn - the single gameplay scene used by campaign, quick match and online
scenes/arenas/       five arena scenes (same Arena.gd, different arena_id)
scripts/classes/     SkillData, ClassData (Resources) + Library (JSON loader)
scripts/player/      Fighter, CombatComponent, HealthComponent, SkillManager, Hitbox, Projectile, AreaEffect,
                     Intent, LocalController, CharacterVisual
scripts/ai/          AIController
scripts/arenas/      Arena (collision/hazards/spawns), ArenaArt (procedural backgrounds)
scripts/managers/    MatchManager (match flow, services, results)
scripts/multiplayer/ RemoteController (host-side guest input)
scripts/effects/     Fx (slashes, rings, particles, damage numbers)
scripts/ui/          PixelUI (look & feel), HUD, TouchControls, PauseMenu, ResultScreen, all screen scripts
resources/           classes.json, skills.json, levels.json  (all balance data)
assets/fonts/        Press Start 2P (OFL)
tests/               automated tests (see docs/TEST_PLAN.md)
docs/                documentation (+ docs/source: the lab sheet)
```

## Autoloads

| Autoload | Responsibility |
|---|---|
| `GameState` | pending `MatchConfig`, selected class/difficulty, builds campaign/quick/online configs, registers keyboard input actions. `build_campaign_config` returns `{}` for a locked level. |
| `SaveManager` | `user://save.cfg` via `ConfigFile`: highest unlocked level, best stars, totals, wins/losses (offline) + online counters, sound/music/vibration, three volumes. Saves immediately on level completion. Sanitises a tampered file (cannot be unlocked past highest cleared + 1). |
| `AudioManager` | synthesised SFX + two chiptune loops, Music/SFX buses, mute/volume from settings. On the online host every gameplay SFX is mirrored to the guest. |
| `NetworkManager` | ENet host/join, lobby state, all RPCs (guest -> host input only; host -> guest state), join timeout, readable errors. |
| `UIManager` | fade transitions (`go(path)`), toasts, vibration, Android back-button signal (`back_requested`). |

## Data-driven content

* `classes.json` - hp, speed, jump velocity, number of jumps, dodge cooldown, body size, colours, weapon look, basic + 3 skills.
* `skills.json` - each skill has a `kind` plus its own parameters (cooldown, damage, windup/recover, knockback, ...).
  Kinds implemented in `CombatComponent`: `melee`, `multi_melee`, `dash_hit`, `slam`, `shield`, `spin`, `dash_through`,
  `projectile`, `zone`, `nova`, `evade`, `blink`. Adding a skill = add JSON (+ a new kind only if the behaviour is new).
* `levels.json` - arena, time limit, enemy class, enemy health multiplier, AI parameters, objective/lose text, tutorial hints, boss flag.
* `ClassData` / `SkillData` are `Resource` classes built from this JSON by `Library` (static, lazy).

## Gameplay pipeline

```
controller (LocalController | AIController | RemoteController)  --Intent-->  Fighter
Fighter state machine: IDLE/RUN/AIR/ACTION/DODGE/HURT/DEAD
  try_skill() -> windup -> CombatComponent.fire(kind) -> active -> recover
CombatComponent spawns Hitbox (melee/aoe), Projectile, AreaEffect (via MatchManager services)
Hitbox/Projectile/AreaEffect query physics shapes against fighters (layer 2 = "hurtboxes")
  -> Fighter.receive_hit(hit)  [shield/invulnerability/knockback/stun/status]  -> HealthComponent
MatchManager: phases LOADING -> COUNTDOWN -> FIGHTING -> ENDED, timer, team elimination, timeout rule,
  campaign stars + SaveManager, result screen, pause.
```

* **One reusable Fighter** for all six classes (no per-class movement controller).
* **No repeated damage:** every Hitbox/Projectile/AreaEffect keeps a per-target "already hit" set
  (multi-hit attacks clear it once per tick interval, so Quick Slash hits exactly 3 times).
* **Health** is clamped in `HealthComponent`; dead fighters leave the fighter collision layer and cannot start actions.
* Physics layers: 1 = world, 2 = fighters, 3 = one-way platforms.
* Hazards (`Arena.update_hazards`): lava pit (damage + launch out), low-friction floor, moving rift orbs (pure function of `arena.time`), rift surges (spawned as `AreaEffect`s).

## Touch controls

`TouchControls` tracks each finger by touch index (multi-touch), and presses/releases the same Input actions the
keyboard uses, so `LocalController` is identical for both. Layout offsets are anchored to the bottom-right corner and
adjusted for phone notch/rounded-corner safe areas (`PixelUI.safe_insets`). Cooldown sweeps are drawn on the buttons.

## Online protocol (host-authoritative, 1v1)

```
guest -> host   _srv_set_class, _srv_ready, _srv_loaded            (reliable)
guest -> host   _srv_input(move, mask)                             (unreliable_ordered, every physics frame)
guest -> host   _srv_press(button)                                 (reliable: jump/attack/dodge/skill1-3)
host  -> guest  _cli_lobby, _cli_start(lobby info)                 (reliable, mode "authority")
host  -> guest  _cli_snapshot([time_left, arena_time, phase, countdown, fighter snapshots...])  (30 Hz, unreliable_ordered)
host  -> guest  _cli_fx, _cli_projectile, _cli_area, _cli_projectile_end   (reliable)
host  -> guest  _cli_sfx (unreliable), _cli_result (reliable)
```

* `_srv_*` handlers verify the sender is the connected guest. `_cli_*` use RPC mode `authority`, so the guest cannot call them on the host.
* The guest scene creates the fighters as **puppets** (no controller, no hit detection, no timer); it interpolates snapshots and plays replicated effects.
* The host alone calls `MatchManager._finish()`; the guest's result screen is driven by the host's `_cli_result`.
* If the guest disconnects mid-match the host wins by forfeit; if the host disconnects the guest sees a clear message and returns to the lobby.
* `SaveManager.record_match(won, online=true)` only touches the separate online counters.

## How to extend

* **New class:** add an entry to `classes.json` (+ skills in `skills.json`), add the id to `Library.CLASS_ORDER`, add headgear/weapon drawing in `CharacterVisual` (or sprites).
* **New arena:** add a `match` branch in `Arena.configure()`, a theme + scenery in `ArenaArt`, a scene in `scenes/arenas/`, an entry in `GameState.ARENA_SCENES/IDS/NAMES`.
* **New level:** append to `levels.json` (and raise `SaveManager.MAX_LEVEL` / `Library` order if beyond 5).
