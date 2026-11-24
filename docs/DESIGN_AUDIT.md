# RIFTBOUND design audit and visual direction

Date: 2026-11-25. Inspected: all scenes, scripts, screenshots from `tests/Screenshots.tscn`.

## What already works (kept untouched)
Fighter state machine, 12 skill kinds, hit registries, AI, SaveManager/unlocks, ENet multiplayer
(effects go through `MatchManager.fx(kind,pos,data)` and are replicated by kind+data), touch controls,
pause/result flow, five arena layouts and hazards, tests (`CheckAll`, `SimTest`, `NetTest`).
All art is procedural (`_draw`) - there are no image assets. That stays: it keeps the APK small and
needs no licensing. Everything is original.

## Why it looks plain
| Area | Problem |
|---|---|
| Main menu | Flat column of default-looking buttons, a lightning-like crack, no logo treatment, no portal, only two menu entries (brief asks six). |
| Arenas | Sky bands + one repeated silhouette per level. No ruins, no architecture, no portal in level 1, almost no foreground. Lava pit and orbs have no warning cues. |
| Characters | One body template recoloured; silhouettes differ only by headgear/weapon. Idle motion identical. |
| Combat FX | Single white cross for every hit; no class identity; no afterimages; no victory pose. |
| HUD | Bars and a colour chip only. No portraits. |
| Class select | Small preview, no role/damage readout, no selection animation. |
| Level select / results | Flat cards, star row only. |

## Visual identity
* **Concept:** "Rift archaeology" - ancient ruins torn open by unstable dimensional energy.
* **Palette:** ink `#0d0a1a`, panel violet `#1d1533`, rift violet `#b04cff`, relic gold `#ffd24a`,
  plus one strong key colour per arena (forest teal-lime, cavern magma orange, citadel ice cyan,
  shadow crimson, sanctuary gold-white). Class colours stay as in `classes.json`.
* **Type:** Press Start 2P everywhere (already bundled, OFL). Min 14 px.
* **Panels:** 4 px dark outline, 2 px inner highlight, hard drop shadow, gold edge = focus/selected.
* **Readability rule:** background value range is darker and lower-contrast than fighters;
  hazards use the only saturated warning colours (hazard orange / rift magenta) with pulsing telegraphs.

## Plan (phases)
1. Arenas: layered, per-level scenery + foreground node above fighters (edges only) + hazard telegraphs.
2. Menu: animated rift portal, logo treatment, six entries, reusable button polish.
3. Combat: class-coloured sparks, afterimages, chains/runes/impact cracks, victory pose.
4. HUD: portraits, nameplates.
5. Class select, level select, results polish.
6. Test: `CheckAll`, `SimTest`, `NetTest`, screenshots at 1280x720 and wide/small sizes.
