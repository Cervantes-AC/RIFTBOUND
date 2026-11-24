# Credits and asset licenses

Every asset used by RIFTBOUND: Arena Clash is listed here. The in-game Credits screen (`scripts/ui/CreditsScreen.gd`) must be kept in sync.

## Third-party assets

| Asset | File | Source | Author | License |
|---|---|---|---|---|
| Press Start 2P (font) | `assets/fonts/PressStart2P-Regular.ttf`, license text `assets/fonts/OFL.txt` | https://fonts.google.com/specimen/Press+Start+2P (file from the `google/fonts` repository) | "The Press Start 2P Project Authors" (see `assets/fonts/OFL.txt`; copyright 2012) | SIL Open Font License 1.1 |
| Godot Engine 4.7 | engine (not in repo) | https://godotengine.org | Godot Engine contributors | MIT |

## Original / generated content (no third-party files)

| Content | Where | Notes |
|---|---|---|
| Character art (6 classes) | `scripts/player/CharacterVisual.gd` | **PLACEHOLDER.** Drawn procedurally with rectangles/lines in a chunky 16-bit style. Not finished pixel art. |
| Arena backgrounds, floors, platforms, hazards (5 arenas) | `scripts/arenas/ArenaArt.gd` | **PLACEHOLDER.** Procedural. |
| Skill/UI icons | `scripts/ui/SkillIcons.gd` | **PLACEHOLDER.** Procedural glyphs. |
| Menu backdrop, effects, particles | `scripts/ui/MenuBackdrop.gd`, `scripts/effects/Fx.gd` | Procedural. |
| Sound effects | `autoload/AudioManager.gd` | **PLACEHOLDER.** Synthesised at runtime (square/triangle/sine/noise sweeps). |
| Music (menu + battle loops) | `autoload/AudioManager.gd` | **PLACEHOLDER.** Tiny chiptune sequencer generated at runtime. |
| App icon | `icon.svg` | Godot project template icon - **replace** before publishing. |

No sprites, characters, music, sound effects or logos from commercial games, films or brands were used.

## Exact replacement assets needed for final artwork

If the placeholders are replaced by real assets (all must be original or have a verified license that is added to the table above):

1. **Character sprite sheets** - 6 classes x animations *idle (4f), run (6f), jump, fall, basic attack (4f), skill cast / dash / guard (4f each), hurt (2f), death (5f), dodge roll (4f)*, 64 x 64 px frames facing right, one shared palette (suggested 32 colours), transparent PNG. Hook: replace `CharacterVisual` with an `AnimatedSprite2D` driven by `Fighter.state` / `act_style` / `act_progress`.
2. **Arena art** - for each of the 5 arenas: 3 parallax background layers (1920 x 1080 or wider), a 64 x 64 floor tile set, a one-way platform tile, hazard sprites (lava animation, ice overlay, rift orb 48 x 48 animation, rift-surge pillar).
3. **Skill icons** - 24 icons (6 basic attacks + 18 skills) at 64 x 64, plus Jump and Dodge.
4. **Hit/impact effect sprites** - slash arcs, impact sparks, shockwave, nova ring, meteor, arrow rain, chains (4-6 frames each).
5. **UI** - 9-slice pixel panel and button frames (normal / pressed / disabled), star icon, padlock icon, logo.
6. **Audio** - 15-20 short effects (`.wav`) and 2-3 music loops (`.ogg`), e.g. from jsfxr / LMMS / OpenGameArt / Freesound with licenses recorded here.
7. **Launcher icon** - 1024 x 1024 icon (Krita/Inkscape) for `Project Settings -> Application -> Config -> Icon` and the Android export preset.

## Tools

Godot Engine, GDScript, Git. (Krita, Inkscape, LibreSprite, Audacity, jsfxr and LMMS are suggested for the replacement assets.)
