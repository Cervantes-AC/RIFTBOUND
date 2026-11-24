# Combat, character and control redesign

Date: 2026-11-25. Scope decision (allowed by the brief): **six fully playable, tested fighters**. The six new
fighters are fully *designed* below and shown in the roster as **PLANNED / locked**. They cannot be selected to
play, and nothing in the game pretends otherwise.

## 1. Audit of the previous system
| Area | State before | Decision |
|---|---|---|
| Fighter / state machine | One reusable `Fighter` (idle/run/air/action/dodge/hurt/dead), coyote time, jump buffer, double jump, drop-through | Kept, extended |
| Skills | basic + 3 cooldown skills, 12 skill kinds, generic dodge roll | Kept the kinds; slots re-defined (see 3); generic dodge replaced by a per-class mobility ability |
| Class identity | Data only (HP/speed + 3 skills); no class rules | Added a `Mechanic` per class (resource, passive, combo rules) |
| Hit detection | Host-authoritative hitboxes/projectiles/areas with per-target hit registries | Kept untouched; hits now pass through `Mechanic` hooks |
| Controls | 6 fixed buttons + floating stick, no settings | Rewritten: presets, size, opacity, sensitivity, editor, persistence |
| Multiplayer | Guest sends input only; host sends 30 Hz snapshots + effects | Kept; snapshot extended by 5 numbers per fighter |
| Duplicated code | None between classes (one Fighter) | No per-class copies were introduced |
| Unfinished | Final art/audio are placeholders | Still placeholders (see section 10) |

## 2. Roster (12 entries)
### Vanguard - The Unbroken Wall  [PLAYABLE]
* Role: Tank / Protector. Difficulty 1/5. HP 175, speed 215, jumps 1.
* Lore: Last captain of a sunken garrison, Brannoch holds the line because nobody else will. Every blow he endures is a debt the enemy will pay.
* Mechanic **BULWARK**: Taking damage charges the Bulwark meter. Spend it with Retaliate for a counter-strike that grows with the meter.
* Passive **Stalwart**: Knockback taken is reduced by 25%. At 50+ Bulwark, damage taken is reduced by 10%.
* Strengths: Survives pressure, protects allies, huge payoff for being hit. Weaknesses: Slow. Ranged enemies kite him. Retaliate has a visible wind-up.
* Strategy: Walk forward, let Bulwark build, then Retaliate. Save the ultimate to shield the whole team.

### Duelist - Edge of the Moment  [PLAYABLE]
* Role: Skirmisher / Combo. Difficulty 3/5. HP 145, speed 310, jumps 2.
* Lore: Ilsa Verrane fought a hundred duels for coin and lost none. She never stops moving, because stillness is how duellists die.
* Mechanic **MOMENTUM**: Every hit adds a Momentum stack (max 5, +5% damage and +3% speed each). Taking a hit halves them.
* Passive **Riposte Footwork**: Each hit you land shortens the Sidestep cooldown by 0.25s.
* Strengths: Highest burst with stacks, great mobility, can cancel attacks into Sidestep. Weaknesses: Low health. Loses everything if hit while stacking.
* Strategy: Thrust, Quick Slash, Sidestep out. At 3+ stacks Phantom Step refunds Quick Slash. Ultimate is a guaranteed-feeling finisher - use it on a staggered target.

### Ranger - Patient Hunter  [PLAYABLE]
* Role: Marksman / Zoner. Difficulty 3/5. HP 95, speed 245, jumps 1.
* Lore: Sel of the Hollow Wood has never missed a shot she took her time on. She marks her quarry once, then waits.
* Mechanic **HUNTER'S MARK**: Hunter's Mark tags an enemy for 6s: all your damage to them is +25%. Marked hits also charge your ultimate faster.
* Passive **Steady Aim**: Standing still for 0.7s lines up the next arrow for +50% damage.
* Strengths: Longest range, strong zoning, big damage on marked or still targets. Weaknesses: Fragile. Moving cancels Steady Aim. Slow wind-ups.
* Strategy: Mark, plant your feet, fire. Dash back when they close in.

### Gunslinger - Six Chambers  [PLAYABLE]
* Role: Pressure / Burst. Difficulty 4/5. HP 100, speed 260, jumps 1.
* Lore: Dust Calloway has exactly six bullets and an opinion about every one. Run dry and the legend ends.
* Mechanic **AMMO**: Six rounds. Pistol costs 1, Quick Burst 3, Explosive Round 2. Empty = 1.6s forced reload; otherwise rounds slowly refill when you stop shooting.
* Passive **Quick Draw**: Tactical Roll reloads 2 rounds and grants a short speed boost.
* Strengths: Constant pressure, three firing patterns, rolling reload. Weaknesses: Dry chamber leaves him helpless. Low health.
* Strategy: Mix single shots with a burst, roll to reload, finish with an Explosive Round. Dead Eye ignores the ammo limit.

### Arcanist - Weaver of Elements  [PLAYABLE]
* Role: Caster / Area Control. Difficulty 4/5. HP 95, speed 225, jumps 1.
* Lore: Orsolya burned her academy library to learn what the books were afraid of. She now carries three flames in one staff.
* Mechanic **ELEMENTS**: Attune cycles Fire, Frost and Storm. Spells use mana. Fire on a slowed target SHATTERS (+50%). Storm chains to a nearby enemy and stuns a slowed target.
* Passive **Arcane Reserve**: Mana regenerates twice as fast while you stand still.
* Strengths: Flexible damage, chain and slow control, devastating ultimate. Weaknesses: Low health, mana runs out, must plan the element order.
* Strategy: Frost to slow, Attune, Fire to shatter. Storm when two enemies stand close together.

### Shadeweaver - Hollow Trickster  [PLAYABLE]
* Role: Trickster / Control. Difficulty 5/5. HP 135, speed 255, jumps 1.
* Lore: Nobody remembers Vesh's face; the Rift took it as payment. What remains is a cloak, a scythe and a talent for being elsewhere.
* Mechanic **SHADOW**: Shadow builds while you move and hit. Spend it on Binding Chains and Shadow Echo: teleport forward leaving an echo, press again within 3s to swap back.
* Passive **Umbral Drift**: +8% move speed, and basic attacks deal up to +40% damage as Shadow fills. Rooted enemies become immune to roots for 2.5s.
* Strengths: Slippery, strong control, great reposition options. Weaknesses: Needs movement to fuel Shadow. Modest raw damage. Hardest to play.
* Strategy: Keep moving, chain a target, Echo behind them, Eclipse to lock the whole group briefly.

### Riftblade - Seam-Walker  [PLANNED (not implemented)]
* Role: Assassin / Repositioner. Difficulty 4/5. HP 130, speed 280, jumps 2.
* Lore: Cuts doors in the air and walks through them.
* Mechanic **RIFT MARKERS**: Place two linked rift gates; stepping through one exits the other with a free slash from behind.
* Passive **Phase Edge**: Attacks from behind deal bonus damage.
* Strengths: Unexpected angles. Weaknesses: Needs setup time.
* Strategy: Planned.

### Warden - Keeper of the Line  [PLANNED (not implemented)]
* Role: Controller / Support. Difficulty 2/5. HP 165, speed 220, jumps 1.
* Lore: Plants wards where friends will stand.
* Mechanic **WARDS**: Place defensive zones that reduce or redirect incoming damage for allies inside.
* Passive **Guardian Link**: Allies near the Warden take less damage.
* Strengths: Team protection. Weaknesses: Low personal damage.
* Strategy: Planned.

### Stormcaller - Thunder's Voice  [PLANNED (not implemented)]
* Role: Chain Caster. Difficulty 3/5. HP 100, speed 235, jumps 1.
* Lore: Speaks the language of the storm.
* Mechanic **CHARGE**: Build electrical charge; discharge it as chain lightning that jumps between enemies.
* Passive **Static Field**: Standing near enemies builds charge.
* Strengths: Groups of enemies. Weaknesses: Weak 1v1 when uncharged.
* Strategy: Planned.

### Reaper - Harvest Bound  [PLANNED (not implemented)]
* Role: Bruiser / Sustain. Difficulty 3/5. HP 150, speed 240, jumps 1.
* Lore: Collects what the battlefield leaves behind.
* Mechanic **SOULS**: Gain limited soul energy; convert it to a capped heal or a burst of damage.
* Passive **Last Rites**: Defeated enemies release souls.
* Strengths: Sustain in long fights. Weaknesses: Healing is capped.
* Strategy: Planned.

### Chronomancer - Borrowed Seconds  [PLANNED (not implemented)]
* Role: Tempo Controller. Difficulty 5/5. HP 105, speed 235, jumps 1.
* Lore: Spends tomorrow's seconds today.
* Mechanic **TEMPO**: Slow chosen enemies or projectiles using time energy; rewind a short step of movement. Deterministic, never unlimited.
* Passive **Borrowed Time**: Cooldowns tick slightly faster.
* Strengths: Tempo control. Weaknesses: Complex.
* Strategy: Planned.

### Beastbound - Pack Mother  [PLANNED (not implemented)]
* Role: Summoner / Brawler. Difficulty 3/5. HP 140, speed 250, jumps 1.
* Lore: The wolf follows; the wolf bites; the wolf is family.
* Mechanic **COMPANION**: A companion wolf attacks on command for a limited duration.
* Passive **Pack Bond**: Companion shares a little of your damage bonus.
* Strengths: Two-front pressure. Weaknesses: Companion can be killed.
* Strategy: Planned.


## 3. Ability framework
Every playable fighter has the same six parts. The framework is shared; the *rules* live in the class mechanic.

| Part | Slot / input | Notes |
|---|---|---|
| Passive | always on | implemented by the class `Mechanic` hooks |
| Basic attack | slot 0 / ATTACK | repeatable, may cost a little resource (Gunslinger, Arcanist) |
| Special | slot 1 / SPECIAL | main combat tool, cooldown |
| Signature | slot 2 / SIGNATURE | the ability that interacts with the class mechanic (Retaliate, Phantom Step, Hunter's Mark, Explosive Round, Attune, Shadow Echo) |
| Mobility | slot 4 / MOBILITY | dash, blink, roll or evade with its own invulnerability and cooldown; replaces the generic dodge |
| Ultimate | slot 3 / ULTIMATE | needs a **full ultimate meter** (100). Meter = 0.9 x damage dealt + 0.5 x damage taken + 1/s, with a short telegraph |

Rules enforced in code: no ability without cooldown or resource; every ultimate has a visible wind-up
(`telegraph` ring or ground marker); every ability can be dodged by the mobility ability or by moving out of the
marked area; stun is capped (see 6); effects are drawn with transparency and short lifetimes.

### Abilities
**Vanguard**

| Slot | Ability | Effect | Cost |
|---|---|---|---|
| Basic | Shield Bash | Quick shield strike. Landing it lets you cancel into Ground Breaker or Retaliate. | repeatable |
| Special | Ground Breaker | Smash the ground: launches enemies and sends a shockwave. | cd 8.0s |
| Signature | Retaliate | Spend ALL Bulwark: damage grows with the amount spent (up to +24). | 30+ Bulwark |
| Mobility | Shield Rush | Charge forward with the shield raised, knocking enemies back. | cd 6.5s |
| Ultimate | Titan's Bastion | Shield yourself AND nearby allies (-60% damage, 4s) and blast nearby enemies away. | Ultimate |

**Duelist**

| Slot | Ability | Effect | Cost |
|---|---|---|---|
| Basic | Rapier Thrust | Fast thrust. Each hit builds Momentum. | repeatable |
| Special | Quick Slash | Three rapid slashes. Great for stacking Momentum. | cd 4.0s |
| Signature | Phantom Step | Dash through enemies; your next hit deals x1.8. With 3+ Momentum, Quick Slash is refunded. | cd 7.5s |
| Mobility | Sidestep | Short invulnerable step. Can cancel any attack's recovery. | cd 2.4s |
| Ultimate | Thousand Cuts | Blink to the nearest enemy and cut eight times. Consumes your Momentum bonus into the finishing blow. | Ultimate |

**Ranger**

| Slot | Ability | Effect | Cost |
|---|---|---|---|
| Basic | Arrow | Quick arrow. Stand still 0.7s first for +50% damage. | repeatable |
| Special | Piercing Shot | Heavy arrow that pierces up to 5 targets. | cd 6.0s |
| Signature | Hunter's Mark | Mark an enemy for 6s: your damage to them is +25% and your ultimate charges faster. | cd 8.0s |
| Mobility | Shadow Dash | Leap backwards with brief invulnerability and gain speed. | cd 6.0s |
| Ultimate | Arrow Storm | Rain arrows over the target for 10 volleys. Marked enemies take +25%. | Ultimate |

**Gunslinger**

| Slot | Ability | Effect | Cost |
|---|---|---|---|
| Basic | Pistol Shot | Single shot. Costs 1 round. | 1 ammo |
| Special | Quick Burst | Four rapid shots. Costs 3 rounds. | 3 ammo |
| Signature | Explosive Round | Slow shell that explodes on contact. Costs 2 rounds. | 2 ammo |
| Mobility | Tactical Roll | Roll with invulnerability. Reloads 2 rounds. | cd 5.0s |
| Ultimate | Dead Eye | Fire a six-bullet fan. For 5s you have infinite ammo and +25% damage. | Ultimate |

**Arcanist**

| Slot | Ability | Effect | Cost |
|---|---|---|---|
| Basic | Elemental Orb | Orb of the attuned element. Costs 6 mana. | 6 mana |
| Special | Arcane Bolt | Homing bolt of the attuned element. Costs 18 mana. | 18 mana |
| Signature | Attune | Cycle element: Fire (+20% dmg), Frost (slows), Storm (chains). Fire on a slowed enemy = Shatter x1.5. | Free |
| Mobility | Arcane Slip | Slip backwards, briefly untouchable. | cd 5.0s |
| Ultimate | Cataclysm | A colossal meteor crashes on the target after a long warning, slowing survivors. | Ultimate |

**Shadeweaver**

| Slot | Ability | Effect | Cost |
|---|---|---|---|
| Basic | Void Lash | Scythe sweep. Damage grows with Shadow (up to +40%). | repeatable |
| Special | Binding Chains | Chains that root the target for 1.4s. Rooted foes are then immune to roots for 2.5s. | 20 shadow |
| Signature | Shadow Echo | Teleport forward, leaving an echo. Press again within 3s to swap back. An unused echo bursts when it fades. | 25 shadow |
| Mobility | Rift Blink | Blink through the Rift and burst on exit. Gives +10 Shadow. | cd 6.0s |
| Ultimate | Eclipse | A wave of darkness roots every enemy nearby for 1.3s after a clear wind-up. | Ultimate |


## 4. Balance table (data-driven, generated from `resources/*.json`)
| Class | HP | Speed | Jumps | Basic (dmg / cd) | Special | Signature | Mobility cd | Ultimate | Resource |
|---|---|---|---|---|---|---|---|---|---|
| Vanguard | 175 | 215 | 1x | Shield Bash 9 / 0.50s | Ground Breaker 18 / 8.0s | Retaliate 14 / 2.0s | Shield Rush / 6.5s | Titan's Bastion 12 | BULWARK |
| Duelist | 145 | 310 | 2x | Rapier Thrust 8 / 0.30s | Quick Slash 8 x3 / 4.0s | Phantom Step - / 7.5s | Sidestep / 2.4s | Thousand Cuts 6 x8 | MOMENTUM |
| Ranger | 95 | 245 | 1x | Arrow 7 / 0.50s | Piercing Shot 20 / 6.0s | Hunter's Mark 3 / 8.0s | Shadow Dash / 6.0s | Arrow Storm 6 x10 ticks | HUNTER'S MARK |
| Gunslinger | 100 | 260 | 1x | Pistol Shot 5 / 0.34s | Quick Burst 6 x4 / 4.0s | Explosive Round 12 (+16 blast) / 8.0s | Tactical Roll / 5.0s | Dead Eye 6 x6 | AMMO |
| Arcanist | 95 | 225 | 1x | Elemental Orb 8 / 0.55s | Arcane Bolt 17 / 3.5s | Attune - / 0.7s | Arcane Slip / 5.0s | Cataclysm 38 | ELEMENTS |
| Shadeweaver | 135 | 255 | 1x | Void Lash 12 / 0.34s | Binding Chains 14 / 7.0s | Shadow Echo - / 0.7s | Rift Blink / 6.0s | Eclipse 26 | SHADOW |

Ultimate requirement for everyone: 100 meter (about 80 damage dealt plus 40 taken, plus 1 per second). AI fights last about 11 s on average; ultimate frequency in real play still needs human playtesting.
AI-vs-AI sweep (`tests/Balance.tscn`, 8 rounds per pairing, noisy): average win rate Vanguard ~75%, Gunslinger ~62%,
Duelist ~45%, Ranger ~45%, Arcanist ~37%, Shadeweaver ~35% (last sweep, before the final Vanguard nerf). The AI cannot use the Shadeweaver's echo, Arcanist's
element planning or the Ranger's mark as a human can, so these three are expected to feel stronger in human hands.
Vanguard was nerfed once (Retaliate scaling, Bulwark gain). Revisit after human playtests.

## 5. Controls (Android landscape)
Presets (`ControlLayout`): **Standard** (button radius 46-62) and **Compact** (38-54).
* Left: floating joystick (anywhere in the left half) and JUMP at the bottom left.
* Right: a fan around ATTACK (largest button): MOBILITY above, SIGNATURE up-left, SPECIAL left, ULTIMATE far left
  (meter ring, pulses gold when ready). Nothing sits in the top 40% of the screen, so the arena stays visible.
* Cooldown sweep + seconds, red ring when off cooldown but missing resource, press animation, opacity setting.
* **Control editor** (Settings > Touch controls): presets, SIZE 0.7-1.35, OPACITY, STICK sensitivity, drag any button,
  RESET. Saved in `user://save.cfg` section `[controls]` and loaded at start (verified by `MechTest`).
* Touch bounce guard: the same button ignores a second press within 70 ms; each finger is tracked by index.
* Keyboard (desktop testing): A/D move, SPACE jump, J attack, U special, I signature, L mobility, O ultimate.

## 6. Movement and combat input
* Coyote time 0.1 s and jump buffer 0.12 s (existing, kept). **New:** ability input buffer 0.2 s.
* **Cancel rules:** MOBILITY can cancel the recovery of any action. After a basic attack CONNECTS, SPECIAL and
  SIGNATURE can cancel its recovery (basic -> special link).
* **Dodge -> counter:** being hit during the mobility invulnerability shows DODGE! and gives +25% to your next hit.
* **Combo counter:** hits and damage are shown for the local player; best combo and damage dealt appear on the result screen.
* **Anti-lock:** hit-stun shrinks 20% per consecutive stun (existing) and after 6 stunning hits the target cannot be
  stunned until the chain breaks; roots grant 2.5 s root immunity afterwards.
* Air attacks: every ability can be used in the air (the state machine allows it). Directional attacks (up/down aimed
  attacks) are **not** implemented.

## 7. Character guide, training room, selection
* **Character select:** 12 cards (6 playable, 6 locked "PLANNED"), big animated preview, title, role, difficulty,
  health/damage/speed/jump bars, mechanic + passive name and all five abilities. GUIDE opens the full move list.
* **Move guide** (`MoveGuide`): lore, mechanic, passive, strengths, weaknesses, strategy, per-ability input/key/effect/
  cost/suggested use, class combos. Opened from Character Select, the pause menu and the training room.
* **Training room** (Local Battle > Training Room): stationary dummy that jabs lightly every 3 s (to practise
  dodging into counters), is healed automatically, ultimate meter refills in ~4 s, no win/lose.

## 8. Architecture (requested names -> implementation)
| Requested | Implemented as |
|---|---|
| CharacterBase | `Fighter` (one shared controller for every class and for AI / remote / puppet) |
| CharacterData | `ClassData` (+ `classes.json`) |
| AbilityBase / AbilityData | `SkillData` (+ `skills.json`, `kind` selects behaviour in `CombatComponent`) and class hooks in `Mechanic` |
| CombatController | `CombatComponent` |
| InputController | `Intent` + `LocalController` / `AIController` / `RemoteController`; buffering and cancels in `Fighter` |
| TouchControls | `TouchControls`, `ControlLayout`, `ControlEditor` |
| ResourceManager | `Mechanic` base + `VanguardMech`, `DuelistMech`, `RangerMech`, `GunslingerMech`, `ArcanistMech`, `ShadeweaverMech` |
| CooldownManager | `SkillManager` (5 slots) |
| ComboManager | combo fields and rules inside `Fighter` (no separate class; kept small on purpose) |
| AnimationController | `CharacterVisual` (shared skeleton, per-class idle/victory/poses) + `MechOverlay` (mechanic feedback) + `Fx` |
| CharacterSelectionManager | `ClassPicker` + `ClassSelect`, `Library.roster_ids()` |
| MultiplayerCombatManager | `MatchManager` + `NetworkManager` (host-authoritative, snapshots carry cooldowns, ultimate meter and mechanic state) |

## 9. Multiplayer
Unchanged model: the guest sends input only, the host runs every rule (cost checks, hits, mechanics, results) and sends
30 Hz snapshots. Each fighter snapshot now carries the five slot cooldowns, ultimate meter, combo count and three
mechanic numbers (resource, auxiliary, echo x): 22 values, verified small by `MechTest`. Effects (including the new
telegraph, ultimate and chain-lightning effects) are replicated through the existing `fx(kind,pos,data)` channel.
The guest never decides damage, resources or results. **Two-device testing was not possible**; two-process localhost
testing (`NetTest`) passes.

## 10. Known gaps (honest list)
* Six fighters are planned, not implemented (Riftblade, Warden, Stormcaller, Reaper, Chronomancer, Beastbound).
* Animations: all fighters share one procedural skeleton. They differ in idle, victory, weapons, overlays and effects,
  but there are no hand-drawn per-class sprite sheets; defeat/hit/land animations are shared. Final art is still needed.
* No directional (up/down) attacks; no separate landing animation.
* Balance numbers come from AI play and are provisional.
* Not tested on physical phones (performance, touch feel, two-device online play).
