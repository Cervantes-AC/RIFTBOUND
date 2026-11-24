# RIFTBOUND: Arena Clash

Team: _(add team member names)_  Platform: **Android**  Orientation: **landscape** (1280 × 720 reference, `canvas_items` / `expand`)

> **Provenance note.** The lab asked for a one-page GDD in the template below. No separate "finalized GDD" file
> was present in the repository (`docs/source/` only contains the ITSD 85 lab sheet), so this document was written
> from the RIFTBOUND master development brief and follows the lab's 11-section template. Where the brief and the
> lab sheet differ, the **lab sheet wins** (see "Differences" at the end).

## 1. Pitch

A fast 16-bit-style platform fighter where you pick a class, jump into unstable "Rift" arenas full of hazards,
and beat the computer in a five-level campaign - or fight a friend on another phone over the same Wi-Fi.

## 2. Genre and target players

2D side-view pixel-art **platform fighting game**. Casual-to-competitive players aged 12+, short 1-3 minute matches,
one-thumb-per-hand touch play.

## 3. Core mechanic and touch controls

Every few seconds the player moves, jumps between platforms, attacks, dodges and fires one of **three class
skills** on cooldown.

| Control | Position | Action |
|---|---|---|
| Virtual joystick (floating) | left | move, push down + Jump to drop through platforms |
| Attack | right, big | basic attack (melee swing, arrow, bullet, orb ...) |
| Jump | right | jump (Duelist can double-jump) |
| Dodge | right | quick invulnerable roll |
| Skill 1 / 2 / 3 | right arc | class special skills (cooldown sweep shown on the button) |

Keyboard (desktop testing): `A/D` or arrows move, `Space/K` jump, `J/Z` attack, `L/X` dodge, `U I O` or `1 2 3` skills, `Esc/P` pause.

**Six classes** (stats/skills live in `resources/classes/classes.json` and `resources/skills/skills.json`):

| Archetype | Class | Skills | Identity |
|---|---|---|---|
| Melee | Vanguard | Shield Rush, Ground Breaker, Iron Fortress | tanky frontliner |
| Melee | Duelist | Quick Slash, Blade Spin, Phantom Step | fast, double jump |
| Ranged | Ranger | Piercing Shot, Arrow Rain, Shadow Dash | bow, long range |
| Ranged | Gunslinger | Quick Burst, Explosive Round, Tactical Roll | rapid projectiles |
| Magic | Arcanist | Arcane Bolt, Frost Nova, Meteor Fall | area damage and control |
| Magic | Shadeweaver | Shadow Bolt, Binding Chains, Rift Blink | control and mobility |

## 4. Goal, win condition, lose condition

* **Goal:** reduce every opponent's health to zero before the timer ends.
* **Win (campaign):** eliminate the enemy before time runs out.
* **Lose (campaign):** your health reaches 0, **or** the timer ends.
* **Quick match / online:** a team wins by eliminating the other team; on timeout the team with the higher total
  health percentage wins (equal = draw).
* **Stars:** 1 = clear the level, 2 = clear with ≥ 30 % health left, 3 = clear with ≥ 60 % health left. Best stars per level are kept.

## 5. Level plan

| # | Arena | Goal text shown at start | What is new / harder | Time |
|---|---|---|---|---|
| 1 | Forgotten Forest | Defeat the Forest Scout | beginner AI (slow reactions, low damage), tutorial hints (move, jump, attack, dodge, skills) | 100 s |
| 2 | Molten Cavern | Defeat the Ember Duelist. Avoid the lava pit! | more aggressive AI, **lava pit** (damage + launch) | 95 s |
| 3 | Frozen Citadel | Defeat the Frost Ranger | faster, dodging ranged enemy, **slippery ice floor** | 90 s |
| 4 | Shadow Realm | Defeat the Shade Warden | stronger AI that mixes skills, **moving rift orbs** | 85 s |
| 5 | Rift Sanctuary | Defeat the Rift Sovereign | boss: 2x health, strongest AI, enrages at 50 % health; **lava + low-friction floor + orbs + falling rift surges** | 120 s |

Every level shows its objective and lose rule on start, has a result screen with **Retry / Next / Menu**, and the
AI parameters (`reaction`, `aggression`, `speed`, `damage`, `dodge`, `skill`) rise level by level in `resources/levels/levels.json`.

## 6. Unlocking rule

Level 1 is unlocked on a fresh install. Level *n+1* unlocks only after level *n* is **cleared** (won).
Locked levels show a padlock and refuse to open; the match scene itself also re-checks the lock, so progression
cannot be bypassed by UI navigation or by loading the scene directly. Replaying earlier levels never lowers
progress, and the best star rating is kept.

## 7. Offline mode

* **Campaign** (5 levels, vs AI).
* **Quick Match:** 1v1 Duel, 2v2 Team Battle (you + AI ally vs 2 AI), 3v3 Rift Clash (you + 2 allies vs 3 AI),
  easy / normal / hard AI, any of the five arenas.
* No network code runs and nothing needs the internet.

## 8. Online mode (same Wi-Fi, 1v1)

Godot High-level Multiplayer with `ENetMultiplayerPeer`, port **7777**, one guest. **Host-authoritative:**
the guest sends only its input (stick + button presses); the host simulates the match, applies damage,
runs the timer and decides the winner, then sends snapshots (~30 Hz: positions, health, status, cooldowns, timer),
spawn/effect events and the final result. The lobby shows the host's local IP; the guest types it in. Class and arena
choices and the "ready" state are synchronised before the host starts the match. Disconnects and unreachable hosts
produce a readable message and return the player to the lobby. Online matches are counted separately and
**never** touch campaign progress.

## 9. Screens

Title, Main Menu (Play Offline / Play Online / Settings / Credits / Quit), Offline Mode Select (Campaign / Quick Match),
Quick Match Mode Select (1v1 / 2v2 / 3v3, difficulty, arena), Campaign Level Select, Class Select, Online Lobby
(choose / host / join / room), Gameplay HUD, Pause menu, Victory/Defeat/Draw result screen, Settings, Credits.

## 10. Art and sound style and asset sources

Dark-fantasy, rift-purple, 16-bit-inspired. **All art is procedural placeholder art drawn by code** (characters,
arenas, icons, effects) and **all audio is synthesised at runtime** - no third-party art or audio is used.
The only external asset is the **Press Start 2P** font (SIL OFL 1.1). See `docs/CREDITS.md` for the exact
replacement assets that would be needed for final artwork.

## 11. Risks and fallbacks

| Risk | Fallback |
|---|---|
| Procedural art looks rough on some devices | placeholder sprites can be swapped for sprite sheets without touching gameplay code (`CharacterVisual`, `ArenaArt`) |
| Online lag | host-authoritative with snapshot interpolation; if too laggy, reduce snapshot rate or lower arena complexity |
| Internet-less lab Wi-Fi blocks peer-to-peer ("client isolation") | use one phone's mobile hotspot |
| 2v2 / 3v3 online | explicitly **optional**; not implemented - only the mandatory 1v1 online mode exists |

## Differences between the brief and the lab sheet

* The brief says the project **renderer** is "Compatibility"; the repository's starter `project.godot` used `mobile`. It was switched to **GL Compatibility**, matching both documents.
* The lab's touch-target guideline (about 9 mm) and "readable text" guideline were applied (minimum font 14 px, most text 16 px+, skill/jump buttons ≥ 88 px at the 1280 × 720 reference).
* The lab suggests `scenes/levels/Level01..05.tscn`; levels are instead **data-driven** (`levels.json`) and rendered by one `Match.tscn` plus five arena scenes in `scenes/arenas/`, which avoids five copies of the same scene.
