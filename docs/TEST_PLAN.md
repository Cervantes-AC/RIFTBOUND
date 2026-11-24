# Test plan and results

**Rule:** a test is reported as passed only if it was actually run. Status below is split into
(A) tests that were run automatically on the development PC and (B) tests that still need a real Android device.

Environment used for (A): Windows 11, Godot 4.7.2 stable, GL Compatibility renderer, AMD Radeon iGPU for the windowed runs.

## A. Automated tests (run)

| Suite | Command | What it covers | Last result |
|---|---|---|---|
| `CheckAll` | `godot --headless --path . res://tests/CheckAll.tscn` | every `.gd` and `.tscn` loads/instantiates without parse errors | 67 files, 0 failures |
| `SimTest` | `godot --headless --path . --fixed-fps 60 res://tests/SimTest.tscn` | see table below | **186 passed, 0 failed** |
| `NetTest` | host + guest processes, `-- fail`, `-- badip` | real ENet sockets on localhost: lobby sync, input -> host, snapshots -> guest, results, failure messages | host+guest: all checks OK, both exit 0 (re-run on the final code); `fail` and `badip`: OK |
| `Balance` | `godot --headless --path . --fixed-fps 60 res://tests/Balance.tscn` | class-vs-class AI win-rate matrix (not pass/fail; used for tuning) | last sweep (4 rounds per pairing, noisy): average win rate vanguard 10 %, shadeweaver 30 %, duelist 40 %, ranger 70 %, arcanist 70 %, gunslinger 75 %. Not fully balanced; AI-vs-AI over 4 rounds is a rough guide only - revisit after human playtests |
| `ScreenSizes` | `godot --path . res://tests/ScreenSizes.tscn` | key screens + a 2v2 match rendered at 1920x864 (20:9), 1024x768 (4:3) and 854x480 | 15 images reviewed by eye; layouts adapt, nothing cut off |
| `Screenshots` | `godot --path . res://tests/Screenshots.tscn` | renders all screens and arenas in a real window (visual inspection) | 31 images generated and reviewed by eye |

### What `SimTest` checks (maps to the required checks in the brief, section 8)

| Required check | Test |
|---|---|
| Attacks deal correct damage | basic attack deals exactly its data damage; shield cuts damage 70 %; each class's basic + 3 skills damage a target in range |
| One attack cannot damage repeatedly | hitbox stays alive many frames but hits once; Quick Slash hits exactly its configured number of times |
| Skills respect cooldowns | skill unusable right after use, counts down, ready again after its cooldown |
| Dead players cannot attack / health never below zero | overkill clamps to 0, further damage is 0, `try_skill` refuses when dead |
| Friendly fire / dodge | team members are never hurt; dodge grants invulnerability |
| Movement | stand on floor, jump and land, move left/right and turn, arena bounds |
| Level 1 unlocked on fresh install, later levels locked | progression block |
| Clearing a level unlocks only the next; replay never reduces progress; best stars kept | progression block |
| Star rule (1 / >= 30 % / >= 60 %) | boundary values 29/30/59/60/100 % |
| Save loads on launch and survives restart | save -> wipe memory -> `load_save()`: progress, stars, settings, stats; tampered file cannot skip levels |
| Online does not alter campaign | `record_match(online)` leaves progress untouched (also checked inside the two-process `NetTest`) |
| 5 levels, rising difficulty, goals present | data checks + all five levels played by an AI "player" until a result screen appears |
| Hazards | lava damages/launches; ice floor has low friction; rift orbs move |
| Real clear-a-level flow | a win unlocks the next level immediately, stores stars, persists to disk; a loss unlocks nothing |
| Team modes | 2v2 and 3v3 build correct teams with AI allies/opponents and end by elimination/timeout rules |
| Touch controls | buttons do not overlap, >= 88 px, multi-touch (joystick + attack + jump at once), dead-zone, release handling |

### What `NetTest` shows (two real processes)

* Host creates a match; guest joins by IP; the guest's class selection and ready state reach the host; the host's class/arena reach the guest.
* Both enter the same match scene; the guest is a non-authoritative puppet; its attacks/skills/jumps (sent as input) reach the host simulation.
* The host runs the timer and decides the winner; the guest receives the result and shows its result screen (the guest cannot declare a result).
* Joining with nobody listening reports a readable error after 8 s and returns the manager to offline; an invalid IP is rejected immediately with a message.
* The online match leaves campaign progress untouched.

## B0. Android emulator run (performed) - NOT a substitute for real phones

Android Studio emulator "Medium Phone", Android 16 (API 36.1), x86_64, 1080x2400 portrait device rotated to landscape by the app, 2 GB RAM,
host-GPU rendering. Debug APK built with `godot --headless --export-debug Android build/RIFTBOUND.apk` (arm64-v8a + x86_64, signed).

| Check | Result |
|---|---|
| APK builds and is signed | **Yes** (57 MB with both ABIs). Manifest verified with `aapt`: package `com.riftbound.arenaclash`, permissions INTERNET / ACCESS_NETWORK_STATE / ACCESS_WIFI_STATE / VIBRATE, `screenOrientation=sensorLandscape` |
| APK installs on the emulator | **Yes** (`adb install -r` -> Success) |
| App launches, rotates to landscape, title/menus/campaign render | **Yes** (screenshots) |
| Touch input through real Android events (`adb input tap/swipe`) | **Yes**: menu buttons, locked-level refusal + toast, class screen -> FIGHT, attack button (swing + cooldown sweep), skill button, joystick drag moved the fighter, Retry button |
| Match, HUD, objective text, tutorial hint, defeat result screen with Retry / Next (disabled) / Menu | **Yes** |
| `user://save.cfg` is written on the device | **Yes** (`files/save.cfg` contained `matches_played=2, losses=2` after two defeats) |
| Force-stop + cold start loads saved progress | **Yes**, with a save file written to the app's `files/save.cfg` through `adb push` + `run-as` (Level 1 = 3 stars, Level 2 unlocked, 3-5 locked were shown after relaunch). The progress itself was injected, not earned on the device, because stepping through a full win by blind taps was impractical |
| Airplane mode (`airplane_mode_on=1`) | **Yes**: app launched, navigated the menus and loaded the campaign with the radio off. A full level was not played to completion in airplane mode on the emulator (the earlier defeat on-device was played with the network on) |
| Online play on the emulator | **Not tested** (one emulator; no second device) |

**Bug found by this run and fixed:** the first APK crashed ~40 s after launch with `SIGSEGV` in `libgodot_android.so` from the Android audio thread
(the mixer read past the end of the looping music `AudioStreamWAV`). Fix: music is no longer a native loop (replayed on `finished`), and all synthesised
streams get trailing silence. After the fix the app ran for 110+ s without a crash.

**Emulator-only artefact observed:** with the software "SwiftShader" GPU (`GL_MAX_FRAGMENT_UNIFORM_VECTORS` = 261) Godot's canvas shader failed to link and the screen stayed
dark; with host-GPU rendering there were 0 shader errors. This is believed to be an emulator limit but **it has not been verified on a physical low-end phone** - if a real device shows a black screen, check `adb logcat` for "uniforms exceed".

## B. Manual tests still required on a real Android device (NOT yet run)

Tick and date each line when done; record phone model/OS in the matrix at the bottom.

### Android
- [ ] APK installs and opens
- [ ] Landscape is locked; both landscape directions work
- [ ] Touch controls: joystick + buttons respond, multi-touch works (move + attack + jump together)
- [ ] UI fits the screen on a small and a large phone; nothing hidden by the notch / rounded corners
- [ ] No crash in 10 minutes of play; frame rate smooth; phone not hot
- [ ] Pause menu works; Android back button pauses/goes back

### Persistence / offline
- [ ] Fresh install: only level 1 unlocked
- [ ] Clear level 1, **force-stop** the app, reopen: level 2 unlocked, stars kept
- [ ] Clear level 2, restart the **phone**, reopen: level 3 unlocked
- [ ] **Airplane mode ON:** open the game, play the campaign and a quick match - everything works, nothing asks for the internet

### Online (two phones, same Wi-Fi or hotspot)
- [ ] Host shows its Wi-Fi IP; guest joins using that IP; both see the lobby, class picks and Ready
- [ ] Both phones show the same match; movement, attacks, skills, health bars and timer agree
- [ ] The host's result is shown on both phones
- [ ] Turn Wi-Fi off, press Host/Join: a readable error appears, no crash
- [ ] Kill the app on one phone mid-match: the other phone shows a clear disconnect message and can return to the lobby
- [ ] Online matches did not change campaign progress

### Phone test matrix (lab Phase 7)

| Test | Phone 1 (model, OS) | Phone 2 (model, OS) |
|---|---|---|
| App installs and opens | | |
| Layout fits the screen, nothing cut off | | |
| Touch controls respond correctly | | |
| Progress saved after force-close | | |
| Offline mode in airplane mode | | |
| Online match between the two phones | | |
| Frame rate smooth | | |
| Battery/heat acceptable after 10 minutes | | |

## C. Known gaps / honest notes

* No real-phone testing has been possible in this development environment, so every DEVICE? item in `REQUIREMENTS_TRACEABILITY.md` is open.
* The AI-vs-AI balance numbers are a tuning aid, not evidence of fun; human playtesting (see `PLAYTEST_PLAN.md`) is required.
* Headless tests do not render; visual quality was checked from screenshots of windowed runs.
