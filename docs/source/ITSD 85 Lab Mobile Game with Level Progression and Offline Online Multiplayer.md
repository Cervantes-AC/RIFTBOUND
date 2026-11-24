ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

Oct 20, 2026 · @rb 

Activity overview 

Students design and build their own mobile game forAndroid or iOS in which the player must clear a level to unlock the next one, playable both offline and online against another player, then improve it based on structured playtest feedback. 

| Item  | Detail |
| ----- | :---- |
| Course  | ITSD 85 – Special Topics in Software Development |
| Laboratory no.  | \_\_\_\_ |
| Title  | Mobile Game Development with Level Progression and Offline/Online Multiplayer |
| Duration  | 5 weeks (about 3 hours lab \+ 3 hours outside work per week) |
| Grouping  | Teams of 2–3 students (individual allowed with instructor approval) |
| Target platform  | Android **or** iOS (team's choice) |
| Game idea  | Free choice, approved by the instructor in Week 1 |
| Cost to students  | ₱0 – free and open-source tools only |

Learning outcomes 

At the end of this activity, students will be able to: 

1\. Write a one-page Game Design Document (GDD) that defines the game's goal, rules, levels and win/lose conditions. 

2\. Build a mobile game with a free, open-source engine and organize it into scenes, scripts and assets. 

Page 1 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

3\. Implement a level-progression system that locks levels until the previous one is cleared and saves progress on the device. 

4\. Implement an offline mode that works with no internet connection. 

5\. Implement an online mode where two players on different devices play together through a network connection. 

6\. Export, install and run the game on a real Android or iOS device. 

7\. Plan and run a playtest, collect evaluation feedback with a standard form, and use the results to improve the game. 

Whatthe team submits atthe end 

A playable game installed on a phone, with at least **5 levels**, an **offline mode** and an **online mode**. 

The source code in a Git repository. 

The GDD, a playtest feedback summary, and a short demo video. 

Your game idea is your own: puzzle, platformer, racing, quiz, tower defense, card or board game, rhythm game, or something new. The only rule is that it must meet the minimum requirements in the next section. 

Minimum game requirements 

Every game, whatever its idea, must pass all ten checks below; teams use this list as their acceptance checklist before submission. 

| \#  | Requirement  | How it will be checked |
| ----- | :---- | :---- |
| R1  | **At least 5 levels**, each harder or different from the last (more enemies, less time, new mechanic, bigger map) | Instructor plays levels 1–3; video shows 4–5 |
| R2  | **Clear goal per level** shown to the player (e.g. "Collect 10 stars in 60 seconds") | Goal text visible on level start |
| R3  | **Win and lose conditions** with a result screen (stars, score or time) and Retry / Next / Menu buttons | Fail a level on purpose, then clear it |

Page 2 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| \#  | Requirement  | How it will be checked |
| ----- | :---- | :---- |
| R4  | **Level unlocking**: level *n+1* stays locked until level *n* is cleared | Locked levels show a lock icon and cannot be opened |
| R5  | **Progress is saved** on the device and survives closing the app | Clear level 2, force-close the app, reopen: level 3 still unlocked |
| R6  | **Offline mode** playable in airplane mode (solo, versus computer, or two players on one device) | Turn on airplane mode and play |
| R7  | **Online mode** where two players on two devices play the same match in real time or turn by turn | Two phones play one match |
| R8  | **Mode selection** on the main menu (Offline / Online) and a clear message when the online server cannot be reached | Turn off Wi-Fi, choose Online: the game shows an error, not a crash |
| R9  | **Runs on a real phone** (Android APK or iOS build), in one fixed orientation, with touch controls | Installed on a team member's phone |
| R10  | **Basic polish**: title screen, pause menu, sound on/off option, readable text on small screens | Checklist during demo |

Optionalfeatures (bonus points) 

Star rating per level (1–3 stars) and total stars needed to unlock later worlds. Online leaderboard or player names. 

Settings screen (volume, vibration, language). 

Tutorial level or first-time hints. 

Accessibility: color-blind-friendly palette, adjustable text size. 

Free tools and platform notes 

The recommended stack is **Godot Engine 4** for the game and either Godot's built-in networking or **Nakama** for online play; both are open source and free with no royalties. 

Page 3 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Need  | Recommended (free / open source) | Alternative  | Notes |
| ----- | ----- | :---- | :---- |
| Game engine  | **Godot 4.7** (latest 4.x stable), MIT license | Flutter \+ Flame (BSD/MIT); Unity Personal (free, not  open source) | Godot exports to Android and iOS from one  project;  GDScript is  easy to learn |
| Programming language | GDScript (Python-like)  | C\# in Godot .NET build  | GDScript  keeps the  Android export simple |
| Online mode – same Wi-Fi | Godot **High-level  Multiplayer** with  ENetMultiplayerPeer | —  | No server  needed: one  phone hosts,  the other joins by IP |
| Online mode – over the  internet | **Nakama** game server (Apache 2.0), self  hosted with Docker \+ nakama-godot client | Godot headless server with WebSocketMultiplayerPeer | Run Nakama  on a laptop or  the school lab server; gives  matchmaking, accounts,  leaderboards |
| Saving  progress | Godot ConfigFile / FileAccess to  user:// | SQLite plugin  | Works offline, stored on the  phone |
| Graphics  | **Krita**, **Inkscape**,  **LibreSprite** (pixel art) | Free assets from Kenney.nl (CC0), OpenGameArt | Credit every  asset that is  not CC0 |
| Sound  | **Audacity**, **LMMS**, **jsfxr**  | Freesound (check each  license) | Use .ogg for  music, .wav  for short  effects |

Page 4 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Need  | Recommended (free / open source) | Alternative  | Notes |
| :---- | :---- | :---- | ----- |
| Version  control | **Git** \+ free GitHub or  Codeberg repository | GitLab  | Use the Godot .gitignore  template |
| Android build tools | **OpenJDK 17** \+ Android SDK command-line  tools (free) | Android Studio (free)  | Needed only  forAndroid  export |
| iOS build  tools | **Xcode** on a Mac (free download) | —  | Needed only  for iOS export |

Choosing Android or iOS 

|  | Android  | iOS |
| ----- | :---- | :---- |
| Computer needed  | Windows, Linux or Mac  | **Mac only** (Xcode) |
| Install on your own  phone | Free: copy the .apk file and install it | Free with a personal Apple ID through Xcode; the app **stops opening after 7 days** and must be reinstalled |
| Number of test phones  | Unlimited  | Limited number of devices per week with a free Apple ID |
| Publishing to a store  | Optional; Google Play charges a one-time registration fee | Optional; Apple Developer Program charges a yearly fee |
| Recommendation for this lab | **Default choice** – cheapest and simplest | Choose only if the team has a Mac and an iPhone |

Publishing to an app store is **not required** for this lab. Install the build directly on a phone. 

Game flow 

Every game, whatever its theme, follows the same screen flow: the player picks Offline or Online, and only a cleared level unlocks the next one. 

Page 5 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

![][image1]Game screen flow · offline levels and online match 

In offline mode a failed level goes straight to the result screen with Retry, while a cleared level unlocks level n+1 and saves before the result screen. In online mode a failed connection must end on a clear error message and return to mode select, never a crash or a frozen screen. 

Phase 1 – Game concept and Game Design Document(Week 1\) 

Goal: agree on one game idea small enough to finish in five weeks, and get it approved before writing code. 

Page 6 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

Step 1.1Brainstorm (30 min) 

1\. Each member proposes one idea in one sentence: *"A game where the player \_\_\_ to \_\_\_ before \_\_\_."* 

2\. For each idea, answer: How does a level get harder? What do two players do together online – race, compete, or cooperate? Can we build it in 5 weeks? 

3\. Vote and choose one. Keep it **small**: one main mechanic done well beats five half-done ones. 

Example ideas that fit the requirements: 

| Game idea  | How levels progress  | Offline mode  | Online mode |
| :---- | ----- | ----- | :---- |
| Maze runner  | Bigger mazes, less time, moving traps | Solo against  the clock | Two players race in the same maze |
| Math quiz battle  | Harder operations, shorter timer | Solo or vs  computer | Two players answer the same questions; fastest wins |
| Tile-matching puzzle  | Fewer moves, new tile types | Solo  | Turn-based duel on one shared board |
| Top-down tank game  | More enemy tanks, walls, power-ups | Vs computer tanks | 1-vs-1 tank battle |
| Local-culture trivia (e.g. Mindanao  history) | New topic per level  | Solo  | Head-to-head quiz |

Step 1.2Write the one-page GDD 

Copy this template into your repository as docs/GDD.md and fill in every line. 

Page 7 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

\# \<Game title\> 

Team: \<names\> Platform: Android / iOS Orientation: portrait / landscape 

\#\# 1\. Pitch (one sentence) 

\#\# 2\. Genre and target players (age, casual or competitive) 

\#\# 3\. Core mechanic: what the player does every few seconds, and the touch controls 

\#\# 4\. Goal, win condition, lose condition 

\#\# 5\. Level plan (table: level no. \| goal \| what is new or harder \| time/moves limit) 

\#\# 6\. Unlocking rule (e.g. clear level n to open n+1; 3 stars \= time under X) \#\# 7\. Offline mode: solo / vs computer / two players on one device \#\# 8\. Online mode: race / versus / co-op; real-time or turn-based; what data is sent 

\#\# 9\. Screens list: title, main menu, mode select, level select, game, pause, result, lobby 

\#\# 10\. Art and sound style \+ asset sources and licenses 

\#\# 11\. Risks: what might be too hard, and the simpler fallback 

Step 1.3 Paper prototype (30 min) 

Draw level 1 on paper or a whiteboard and play it with paper pieces while a classmate acts as "the computer". If it is not fun on paper, change the rules now – it is the cheapest time to change. 

**Checkpoint 1 (instructor approval):** GDD and a photo of the paper prototype. Do not start Phase 3 until the idea is approved. 

Phase 2 – Project setup (Week 1\) 

Goal: every team member can open the same Godot project from Git and run it. 

1\. Download **Godot 4.7** (standard version, not .NET) from godotengine.org/download. It is a single program; no installer needed. 

2\. **New Project** → name it after your game → Renderer: **Compatibility** (runs on older and low-cost Android phones) → Create. 

3\. Open **Project → Project Settings** (turn on **Advanced Settings**) and set: Page 8 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Setting  | Portrait game  | Landscape  game |
| ----- | :---- | :---- |
| Display → Window → Size → Viewport Width × Height | 720 × 1280  | 1280 × 720 |
| Display → Window → Stretch → Mode  | canvas\_items  | canvas\_items |
| Display → Window → Stretch → Aspect  | expand  | expand |
| Display → Window → Handheld → Orientation | Portrait  | Landscape |
| Input Devices → Pointing → Emulate Touch From Mouse | On (lets you test touch with the mouse) | On |

4\. Create this folder structure in the FileSystem panel: 

res:// 

├── autoload/ \# global scripts: GameState.gd, Net.gd 

├── scenes/ 

│ ├── ui/ \# TitleScreen, MainMenu, ModeSelect, LevelSelect, Result, Lobby 

│ ├── levels/ \# Level01.tscn ... Level05.tscn 

│ └── actors/ \# Player, Enemy, Pickup 

├── scripts/ 

├── assets/ 

│ ├── art/ 

│ ├── audio/ 

│ └── fonts/ 

└── docs/ \# GDD.md, CREDITS.md, playtest results 

5\. Put the project under Git (from the project folder): 

git init 

\# .gitignore for Godot 4 

printf ".godot/\\n/android/\\n\*.apk\\n\*.aab\\n\*.ipa\\nexport/\\n" \> .gitignore git add . 

git commit \-m "Initial Godot project" 

git remote add origin \<your repository URL\> 

git push \-u origin main 

Page 9 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

6\. Team workflow: each member works on a branch ( feature/level-select , feature/online-lobby ), and merges to main only when the game still runs. Edit **different scenes** at the same time to avoid merge conflicts in .tscn files. 

**Checkpoint 2:** every member clones the repo, opens it in Godot and presses **F5** to run an empty main scene. 

Phase 3 – Core gameplay and the level system (Weeks 2–3) 

Goal: a playable Level 1, then Levels 2–5, with a level-select screen that unlocks levels in order and remembers progress after the app closes. 

Step 3.1Build the core mechanic in Level 1 first 

1\. Create scenes/levels/Level01.tscn with your player, obstacles and goal objects. 2\. Use touch input: InputEventScreenTouch and InputEventScreenDrag , or on-screen TouchScreenButton nodes for left/right/jump. 

3\. Play it on the computer until the core action feels good. **Do not build more levels until Level 1 is fun.** 

Step 3.2 Global game state (saves progress and unlocks levels) 

Create autoload/GameState.gd , then add it in **Project Settings → Globals → Autoload** with the name GameState . It is then available from every scene. 

extends Node 

const SAVE\_PATH := "user://save.cfg" \# user:// is the app's private folder on the phone 

const TOTAL\_LEVELS := 5 

var unlocked\_level: int \= 1 \# highest level the player may open var best\_stars: Dictionary \= {} \# level number \-\> best stars (1..3) var current\_level: int \= 1 

var mode: String \= "offline" \# "offline" or "online" 

var last\_result: Dictionary \= {} \# filled when a level ends 

func \_ready() \-\> void: 

load\_progress() 

func is\_unlocked(level: int) \-\> bool: 

Page 10 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

return level \<= unlocked\_level 

func complete\_level(level: int, stars: int) \-\> void: 

best\_stars\[level\] \= max(stars, best\_stars.get(level, 0)) 

if level \== unlocked\_level and level \< TOTAL\_LEVELS: 

unlocked\_level \= level \+ 1 \# unlock the next level 

save\_progress() 

func save\_progress() \-\> void: 

var cfg := ConfigFile.new() 

cfg.set\_value("progress", "unlocked\_level", unlocked\_level) 

cfg.set\_value("progress", "best\_stars", best\_stars) 

cfg.save(SAVE\_PATH) 

func load\_progress() \-\> void: 

var cfg := ConfigFile.new() 

if cfg.load(SAVE\_PATH) \== OK: 

unlocked\_level \= cfg.get\_value("progress", "unlocked\_level", 

1\) 

best\_stars \= cfg.get\_value("progress", "best\_stars", {}) 

func reset\_progress() \-\> void: \# call from a hidden debug button while testing 

unlocked\_level \= 1 

best\_stars.clear() 

save\_progress() 

func level\_scene\_path(level: int) \-\> String: 

return "res://scenes/levels/Level%02d.tscn" % level 

GDScript uses **tabs** for indentation. If pasted code shows indentation errors, use **Edit → Indentation → Convert Indent to Tabs** in the script editor. 

Step 3.3 A reusable level script(win, lose, stars) 

Attach scripts/Level.gd to the root node of every level. Each level only changes the exported values in the Inspector. 

extends Node2D 

@export var level\_number: int \= 1 

@export var goal\_text: String \= "Collect 10 coins in 60 seconds" Page 11 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

@export var time\_limit: float \= 60.0 

@export var target\_score: int \= 10 

var time\_left: float 

var score: int \= 0 

var finished := false 

@onready var goal\_label: Label \= \$HUD/GoalLabel 

@onready var timer\_label: Label \= \$HUD/TimerLabel 

func \_ready() \-\> void: 

time\_left \= time\_limit 

goal\_label.text \= goal\_text 

func \_process(delta: float) \-\> void: 

if finished: 

return 

time\_left \-= delta 

timer\_label.text \= str(ceili(time\_left)) 

if time\_left \<= 0.0: 

end\_level(false) 

func add\_score(points: int) \-\> void: \# call this from coins, enemies, correct answers... 

score \+= points 

if score \>= target\_score: 

end\_level(true) 

func end\_level(won: bool) \-\> void: 

finished \= true 

var stars := 0 

if won: 

stars \= 1 

if time\_left \> time\_limit \* 0.5: 

stars \= 3 

elif time\_left \> time\_limit \* 0.25: 

stars \= 2 

GameState.complete\_level(level\_number, stars) 

GameState.last\_result \= {"won": won, "stars": stars, "level": 

level\_number, "score": score} 

get\_tree().change\_scene\_to\_file("res://scenes/ui/Result.tscn") Page 12 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

Adapt the win rule to your game (reach the exit, answer 8 of 10 correctly, destroy all enemies) but keep calling end\_level() . 

Step 3.4 Level-select screen with locks 

scenes/ui/LevelSelect.tscn : a Control root with a GridContainer named Grid (3 columns). Script: 

extends Control 

@onready var grid: GridContainer \= \$Grid 

func \_ready() \-\> void: 

for i in range(1, GameState.TOTAL\_LEVELS \+ 1): 

var b := Button.new() 

b.custom\_minimum\_size \= Vector2(180, 180\) \# big enough for 

a thumb 

if GameState.is\_unlocked(i): 

b.text \= "Level %d\\nStars: %d/3" % \[i, 

GameState.best\_stars.get(i, 0)\] 

b.pressed.connect(\_on\_level\_pressed.bind(i)) 

else: 

b.text \= "Level %d\\nLOCKED" % i 

b.disabled \= true 

grid.add\_child(b) 

func \_on\_level\_pressed(level: int) \-\> void: 

GameState.current\_level \= level 

get\_tree().change\_scene\_to\_file(GameState.level\_scene\_path(level)) Replace the text with a lock icon image when you add art in Phase 6\. 

Step 3.5 Result screen 

scenes/ui/Result.tscn reads GameState.last\_result and shows *Level Cleared\!* or *Try Again*, the stars, and three buttons: **Retry** (same level), **Next** (disabled if lost or on the last level), **Menu**. 

Step 3.6 Design Levels 2–5 with a difficulty curve 

Change **one or two things per level** so the player learns gradually: 

Page 13 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Level  | Typical change |
| ----- | :---- |
| 1  | Teach the basic action; generous time |
| 2  | Same action, less time or more targets |
| 3  | Introduce one new element (moving enemy, new tile, new question type) |
| 4  | Combine the new element with less time |
| 5  | Final challenge using everything learned |

**Checkpoint 3:** video of clearing Level 1, failing Level 2, and showing that Level 3 unlocks only after Level 2 is cleared and remains unlocked after restarting the game. 

Phase 4 – Offline mode (Week 3\) 

Goal: the full game, including level unlocking, works in airplane mode with no network code running. 

Step 4.1 Choose your offline type 

Pick at least one (more is bonus): 

| Offline type  | Best for  | What to build |
| ----- | :---- | :---- |
| **Solo campaign**  | Puzzle, platformer, maze  | The 5 levels from Phase 3 played alone |
| **Versus computer (AI)**  | Racing, quiz battle, tank, board games | A computer opponent whose skill grows per level |
| **Pass-and-play (same device)** | Turn-based, board and card games | Two players take turns on one phone; show "Player 2's turn"  between turns |

Step 4.2 Mode select screen 

scenes/ui/ModeSelect.tscn with two large buttons, **Play Offline** and **Play Online**: 

Page 14 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

extends Control 

func \_on\_offline\_pressed() \-\> void: 

GameState.mode \= "offline" 

get\_tree().change\_scene\_to\_file("res://scenes/ui/LevelSelect.tscn") 

func \_on\_online\_pressed() \-\> void: 

GameState.mode \= "online" 

get\_tree().change\_scene\_to\_file("res://scenes/ui/Lobby.tscn") 

Connect each button's pressed signal to these functions in the **Node → Signals** panel. 

Step 4.3 A simple computer opponentthat gets harder each level 

This pattern works for quiz, racing and reaction games: the AI "acts" after a delay, and later levels shorten the delay and raise accuracy. 

\# scripts/SimpleAI.gd – add as a child node of the level 

extends Node 

signal ai\_scored(points: int) 

@export var base\_delay: float \= 3.0 \# seconds between AI actions on Level 1 

@export var base\_accuracy: float \= 0.5 \# 50% chance to succeed on Level 1 

var delay: float 

var accuracy: float 

var t := 0.0 

func \_ready() \-\> void: 

var lvl := GameState.current\_level 

delay \= max(0.8, base\_delay \- 0.4 \* (lvl \- 1)) \# faster each level 

accuracy \= min(0.9, base\_accuracy \+ 0.1 \* (lvl \- 1)) \# smarter each level 

func \_process(d: float) \-\> void: 

t \+= d 

Page 15 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

if t \>= delay: 

t \= 0.0 

if randf() \< accuracy: 

ai\_scored.emit(1) 

In a versus level, the player wins if they reach target\_score before the AI does. 

Step 4.4 Airplane-mode test 

1\. Install the game on a phone (Phase 7 shows how; for now, run it on the computer with Wi-Fi off). 

2\. Turn on airplane mode, open the game, choose **Play Offline**, clear Level 1, close the app, reopen it. 

3\. Confirm: no freezing, no error pop-ups, Level 2 still unlocked. 

**Checkpoint 4:** screen recording of the airplane-mode test. 

Phase 5 – Online multiplayer (Week 4\) 

Goal: two players on two phones join the same match and see each other's actions or scores update live. 

All teams must complete **Option A**. Teams aiming for a higher grade also complete **Option B**. 

|  | Option A – Host & Join (same Wi-Fi)  | Option B – Internet matchmaking (Nakama) |
| :---- | ----- | ----- |
| Server  needed | None: one phone is the host  | Nakama server running in Docker (laptop or school server) |
| Players  | Same Wi-Fi network (classroom, home router, phone hotspot) | Anywhere the server can be reached |
| Difficulty  | Moderate – built into Godot  | Harder – adds a server and a client library |
| Cost  | Free  | Free (open source, self-hosted) |

Option A – Host and Join with Godot's High-level Multiplayer 

**A.1 Network manager.** Create autoload/Net.gd and register it as Autoload Net : Page 16 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

extends Node 

const PORT := 7777 

const MAX\_CLIENTS := 1 \# 1 guest \+ the host \= 2 players 

signal match\_ready \# both players connected 

signal net\_error(message: String) 

func \_ready() \-\> void: 

multiplayer.peer\_connected.connect(\_on\_peer\_connected) 

multiplayer.connection\_failed.connect(func(): \_fail("Could not reach the host.")) 

multiplayer.server\_disconnected.connect(func(): \_fail("The host left the game.")) 

multiplayer.peer\_disconnected.connect(func(\_id): \_fail("The other player left.")) 

func host\_game() \-\> void: 

var peer := ENetMultiplayerPeer.new() 

if peer.create\_server(PORT, MAX\_CLIENTS) \!= OK: 

\_fail("Cannot start hosting on port %d." % PORT) 

return 

multiplayer.multiplayer\_peer \= peer 

func join\_game(ip: String) \-\> void: 

var peer := ENetMultiplayerPeer.new() 

if peer.create\_client(ip, PORT) \!= OK: 

\_fail("Invalid address.") 

return 

multiplayer.multiplayer\_peer \= peer 

func my\_ip() \-\> String: \# shown on the host's screen so the guest can type it 

for a in IP.get\_local\_addresses(): 

if a.begins\_with("192.168.") or a.begins\_with("10.") or 

a.begins\_with("172."): 

return a 

return "unknown" 

func leave() \-\> void: 

if multiplayer.multiplayer\_peer: 

multiplayer.multiplayer\_peer.close() 

multiplayer.multiplayer\_peer \= OfflineMultiplayerPeer.new() 

Page 17 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

func \_on\_peer\_connected(\_id: int) \-\> void: 

if multiplayer.is\_server(): 

match\_ready.emit() 

func \_fail(message: String) \-\> void: 

leave() 

net\_error.emit(message) 

**A.2 Lobby screen** ( scenes/ui/Lobby.tscn ): a **Host** button, a LineEdit for the host's IP, a **Join** button, and a status Label . 

1\. Host taps **Host** → the label shows Waiting... your IP is 192.168.1.23 . 2\. Guest types that IP and taps **Join**. 

3\. Start a 5-second Timer when joining; if nothing connects, show *"Cannot reach host. Check that you are on the same Wi-Fi."* (requirement R8). 

4\. When match\_ready fires on the host, the host chooses the level and starts the match on both phones: 

\# in Lobby.gd (host side) 

func \_on\_match\_ready() \-\> void: 

start\_match.rpc(1, randi()) \# level 1, shared random seed 

@rpc("authority", "call\_local", "reliable") 

func start\_match(level: int, seed\_value: int) \-\> void: 

seed(seed\_value) \# both phones generate the same random level 

GameState.current\_level \= level 

get\_tree().change\_scene\_to\_file(GameState.level\_scene\_path(level)) 

**A.3 Send game events.** Keep network messages small: send *events* (scored, answered, moved to cell 4,2), not whole screens. 

Page 18 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

\# in the online level script 

@rpc("any\_peer", "call\_local", "reliable") 

func report\_score(points: int) \-\> void: 

var who := multiplayer.get\_remote\_sender\_id() \# which player sent it 

scores\[who\] \= scores.get(who, 0\) \+ points 

update\_scoreboard() 

if multiplayer.is\_server() and scores\[who\] \>= target\_score: 

announce\_winner.rpc(who) 

@rpc("authority", "call\_local", "reliable") 

func announce\_winner(winner\_id: int) \-\> void: 

var i\_won := winner\_id \== multiplayer.get\_unique\_id() 

show\_online\_result(i\_won) 

For real-time movement (racing, tanks), add a MultiplayerSynchronizer node to the player scene and tick the position property; use a MultiplayerSpawner to create each player's character. 

**A.4 Android permission.** In **Project → Export → Android → Permissions** tick **Internet** and **Access Network State**, or online mode will silently fail on the phone. 

OptionB– Internet matchmaking with Nakama (advanced) 

**B.1 Start the server** on a laptop or the school server with Docker (see the CI/CD lab): 

\# download the official docker-compose file from the Nakama Docker install guide, then: 

docker compose up \-d 

\# API on port 7350, admin console on http\://localhost:7351 (default login admin / password) 

**B.2 Add the client.** In Godot open **AssetLib**, search **Nakama**, install it, and enable it. It adds a Nakama autoload. 

**B.3 Connect, find an opponent and exchange data:** 

extends Node 

var client: NakamaClient 

var socket: NakamaSocket 

var match\_id := "" 

Page 19 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

func connect\_and\_find\_match(host: String) \-\> void: 

client \= Nakama.create\_client("defaultkey", host, 7350, "http") var session := await 

client.authenticate\_device\_async(OS.get\_unique\_id()) 

if session.is\_exception(): 

print("Login failed: ", session) 

return 

socket \= Nakama.create\_socket\_from(client) 

await socket.connect\_async(session) 

socket.received\_matchmaker\_matched.connect(\_on\_matched) 

socket.received\_match\_state.connect(\_on\_match\_state) 

await socket.add\_matchmaker\_async("\*", 2, 2\) \# find exactly 2 players 

func \_on\_matched(matched: NakamaRTAPI.MatchmakerMatched) \-\> void: var m := await socket.join\_matched\_async(matched) 

match\_id \= m.match\_id 

func send\_score(points: int) \-\> void: 

socket.send\_match\_state\_async(match\_id, 1, JSON.stringify({"points": points})) 

func \_on\_match\_state(state: NakamaRTAPI.MatchData) \-\> void: 

if state.op\_code \== 1: 

var data: Dictionary \= JSON.parse\_string(state.data) 

print("Opponent scored ", data\["points"\]) 

Phones and the server must be on the same network, or the server must have an address the phones can reach. Change defaultkey and the console password before putting a server on the internet. 

Online design rules 

Decide in the GDD whether online results affect offline unlocking (simplest: they do not). 

Handle disconnects: if the other player leaves, end the match and return to the menu with a message. 

Never trust the other phone for the final result: let the **host** (Option A) or **server** (Option B) decide the winner. 

**Checkpoint 5:** video showing two phones in one online match, including the result screen on both, and the error message when joining with Wi-Fi off. 

Page 20 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

Phase 6 – UI, audio and polish (Week 4–5) 

Goal: the game looks finished, is easy to use with one thumb, and every asset is credited. 

1\. **Title and menus.** Title screen → Main menu (Play, Settings, Credits) → Mode select → Level select / Lobby. Every screen has a **Back** button; Android's system back gesture should also go back (handle NOTIFICATION\_WM\_GO\_BACK\_REQUEST ). 

2\. **Touch-friendly layout.** Buttons at least about 9 mm wide on a phone (roughly 120 px in a 720-wide layout). Keep important buttons away from the screen edges and the camera notch. Test on the smallest phone in the team. 

3\. **Readable text.** Import a free font (e.g. from Google Fonts, Open Font License) and use at least 28 px for body text at 720 × 1280\. 

4\. **Pause menu.** Pause button in every level: Resume, Restart, Sound on/off, Quit to menu. Use get\_tree().paused \= true and set the pause menu's **Process Mode** to *When Paused*. 

5\. **Sound.** Background music on an AudioStreamPlayer in an Autoload so it continues between scenes; short effects for tap, win, lose, unlock. Save the sound on/off choice in GameState like progress. 

6\. **Feedback juice.** Small touches that make actions feel good: a Tween to scale a button when tapped, screen shake on hit, particles when a level unlocks. 

7\. **App icon and name.** Make a 1024 × 1024 icon in Krita or Inkscape; set it in **Project Settings → Application → Config → Icon** and in the export preset. 

8\. **Credits.** Create docs/CREDITS.md and an in-game Credits screen listing every asset, its author and license. 

| Free asset source  | License to check |
| ----- | ----- |
| Kenney.nl  | CC0 – free for any use, credit appreciated |
| OpenGameArt.org  | Varies per asset (CC0, CC-BY, GPL) |
| Freesound.org  | Varies (CC0, CC-BY, CC-BY-NC) |
| Google Fonts  | Open Font License |

Do not use characters, music or logos from commercial games, films or brands. Original or properly licensed assets only. 

Page 21 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

**Checkpoint 6:** screenshots of every screen on a phone, plus CREDITS.md . 

Phase 7 –Build and install on a phone (Week 4, repeat every week) 

Goal: a team member's phone runs the latest build. Install early (end of Week 2\) and often – phone-only problems are found only on phones. 

Common first step 

In Godot: **Editor → Manage Export Templates → Download and Install** (one time, matches your Godot version). 

Android (Windows, Linux or Mac) 

1\. Install **OpenJDK 17** (e.g. from adoptium.net) and the **Android SDK** (Android Studio, or only the command-line tools). Godot's guide Exporting forAndroid lists the exact SDK packages for your Godot version. 

2\. **Editor → Editor Settings → Export → Android**: set the **Java SDK Path** and **Android SDK Path**. Godot creates a debug keystore automatically for test builds. 

3\. **Project → Export → Add… → Android**. Set: 

Package → Unique Name: com.itsd85.\<teamname\>.\<gamename\> (lowercase, no spaces) 

Package → Name: the game title shown under the icon 

Permissions: **Internet** and **Access Network State** ticked (for online mode) Screen → orientation as in Phase 2 

4\. Click **Export Project**, untick *Export With Debug* only for the final build, and save export/\<game\>.apk . 

5\. Install on the phone, either: 

**Copy the APK** to the phone (USB, Google Drive, Bluetooth), open it, and allow *Install unknown apps* when asked; or 

**One-click deploy**: turn on *Developer options → USB debugging* on the phone, connect USB, and click the Android icon at the top right of the Godot editor. 

iOS (Mac with Xcode required) 

1\. Install **Xcode** from the Mac App Store. In **Xcode → Settings → Accounts**, add your personal Apple ID (free "Personal Team"). 

Page 22 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

2\. In Godot: **Project → Export → Add… → iOS**. Set a unique **Bundle Identifier** ( com.itsd85.teamname.game ) and the **App Store Team ID** from your personal team. Export the Xcode project. 

3\. Open the exported .xcodeproj in Xcode → select the target → **Signing & Capabilities** → Team: your Personal Team. 

4\. Connect the iPhone with a cable. On the iPhone turn on **Settings → Privacy & Security → Developer Mode** and restart when asked. 

5\. Select the iPhone as the run destination in Xcode and press **Run**. The first time, open **Settings → General → VPN & Device Management** on the iPhone and trust your developer certificate. 

6\. Free-account builds stop opening after **7 days**; repeat step 5 to reinstall before demo day. 

Phone test matrix 

Test on at least two different phones (different screen sizes or OS versions) and record: 

| Test  | Phone 1 (model, OS)  | Phone 2 (model, OS) |
| ----- | ----- | ----- |
| App installs and opens |  |  |
| Layout fits the screen, nothing cut off |  |  |
| Touch controls respond correctly |  |  |
| Progress saved after force-close |  |  |
| Offline mode in airplane mode |  |  |
| Online match between the two phones |  |  |
| Frame rate smooth (no visible stutter) |  |  |
| Battery/heat acceptable after 10 minutes |  |  |

**Checkpoint 7:** the APK file (or a video of the app running on the iPhone) and the completed test matrix. 

Page 23 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

Phase 8 – Playtesting and game evaluation feedback (Week 5\) 

Goal: at least **5 players outside the team** play the game, the team collects their feedback with the form below, fixes the top problems, and reports what changed. 

Step 8.1 Run the playtest(15–20 minutes per player) 

1\. **Prepare:** a charged phone with a fresh install (progress reset), a second phone for online mode, and printed or online copies of the forms below (a free Google Form or LibreOffice Calc sheet works). 

2\. **Brief the player in one sentence only:** *"Please play as you normally would and say out loud what you are thinking."* Do **not** explain the controls or the goal – the game must do that. 

3\. **Play:** Levels 1–3 offline, then one online match against a team member. 4\. **Observe silently** and fill in the observation sheet. Help only if the player is stuck for more than 2 minutes, and write down that you helped. 

5\. **Ask the player to fill in the feedback form** right after playing. 

Step 8.2 Observation sheet(filled in by the team) 

| Tester  no. | Level  | Attempts to clear | Time to clear  (min:sec) | Where they got stuck or confused | Quotes said  out loud | Bugs  seen |
| :---- | ----- | :---- | :---- | :---- | :---- | :---- |
| 1  | 1 |  |  |  |  |  |
| 1  | 2 |  |  |  |  |  |
| 1  | 3 |  |  |  |  |  |
| 1  | Online |  |  |  |  |  |

Step 8.3 Player evaluation feedback form (filled in by each tester) 

**Tester information:** Age range □ under 18 □ 18–24 □ 25+ How often do you play mobile games? □ Daily □ Weekly □ Rarely 

**Part A – Rate each statement** (1 \= Strongly disagree, 2 \= Disagree, 3 \= Neutral, 4 \= Agree, 5 \= Strongly agree) 

| \#  | Statement  | 1  | 2  | 3  | 4  | 5 |
| :---- | :---- | :---- | :---- | :---- | :---- | :---- |
| 1  | The game was fun to play. |  |  |  |  |  |

Page 24 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| \#  | Statement  | 1  | 2  | 3  | 4  | 5 |
| :---- | ----- | :---- | :---- | :---- | :---- | :---- |
| 2  | I understood the goal of each level without help. |  |  |  |  |  |
| 3  | The touch controls were easy and responsive. |  |  |  |  |  |
| 4  | Each level felt a little harder than the last, but fair. |  |  |  |  |  |
| 5  | Unlocking the next level made me want to keep playing. |  |  |  |  |  |
| 6  | The win/lose result screen clearly showed how I did. |  |  |  |  |  |
| 7  | Offline mode worked smoothly. |  |  |  |  |  |
| 8  | Joining an online match was easy. |  |  |  |  |  |
| 9  | The online match felt responsive (little or no lag). |  |  |  |  |  |
| 10  | The graphics were clear and attractive. |  |  |  |  |  |
| 11  | The sound and music fit the game. |  |  |  |  |  |
| 12  | Text and buttons were easy to read and tap. |  |  |  |  |  |
| 13  | The game ran without crashes or freezes. |  |  |  |  |  |
| 14  | I would play this game again. |  |  |  |  |  |
| 15  | I would recommend this game to a friend. |  |  |  |  |  |

**Part B – Open questions** 

1\. What did you like most about the game? 

2\. What was the most frustrating or confusing moment? 

3\. Which level was too easy or too hard? Why? 

4\. Did anything not work as you expected (bugs, glitches)? 

5\. If you could change one thing, what would it be? 

6\. Overall rating: ☆ ☆ ☆ ☆ ☆ (circle 1–5 stars) 

Step 8.4 Analyze the results 

1\. Compute the **average score per statement** (Part A). Any statement averaging **below 3.5** is a problem area. 

2\. From the observation sheet, compute per level: **completion rate** (players who cleared ÷ players who tried) and **average attempts**. A level cleared by fewer than 60% of players, or needing more than 4 attempts on average, is probably too hard – unless it is the final level. 

Page 25 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

3\. Group the open-answer comments into themes (controls, difficulty, clarity, bugs, online, art/sound) and count how many testers mentioned each. 

Step 8.5 Feedback summary and action plan 

Fix the issues with the highest severity and most mentions first, then retest with at least 2 new players. 

| Issue found  | Testers who  reported it (of 5+) | Severity  (Critical / Major / Minor) | Planned fix  | Fixed?  | Result after retest |
| :---- | :---- | :---- | :---- | ----- | ----- |
| Example: did not  know how to jump in Level 1 | 4  | Major  | Add a jump hint arrow on first  play | Yes  | 2 of 2 new testers jumped without help |
|  |  |  |  |  |  |
|  |  |  |  |  |  |

Severity guide: **Critical** \= crash, lost progress, cannot finish a level; **Major** \= confusing goal, unfair difficulty, online fails often; **Minor** \= cosmetic, typos, small sound issues. 

**Checkpoint 8:** all completed forms (scans or spreadsheet), the averages table, and the action plan showing at least 3 fixes made. 

Schedule 

The project runs five weeks; each week ends with a checkpoint the instructor reviews in the next lab session. 

| Week  | Phases  | Lab session focus  | Checkpoints due |
| ----- | ----- | :---- | :---- |
| 1  | 1–2  | Brainstorm, GDD, paper prototype, Godot and Git setup | 1 (GDD approved), 2 |
| 2  | 3  | Core mechanic in Level 1, GameState, first phone install | Level 1 playable on a  phone |
| 3  | 3–4  | Levels 2–5, level select, result screen, offline mode | 3, 4 |
| 4  | 5–7  | Online multiplayer, menus and sound, two phone testing | 5, 6, 7 |

Page 26 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Week  | Phases  | Lab session focus  | Checkpoints due |
| ----- | ----- | :---- | :---- |
| 5  | 8  | Playtests with 5+ players, fixes, final build, demo | 8, final deliverables |

Feature freeze at the start of Week 5: no new features, only fixes from playtest feedback. 

Deliverables, guide questions and rubric 

Each team submits one package and gives a 7-minute live demo in Week 5\. 

Deliverables 

Git repository link with the full Godot project, docs/GDD.md , docs/CREDITS.md and a README.md (how to build and play). 

Installable build: Android .apk , or for iOS a video of the app running on an iPhone. Demo video (2–3 minutes): title screen, level unlocking, a win and a loss, offline mode in airplane mode, online match on two phones. 

Publication-ready paper (PDF) written from this project, reporting the playtest results; observation sheets, feedback forms and the action plan go in its appendix (see the paper section below). 

Phone test matrix from Phase 7\. 

Individual contribution log: each member lists what they built and links to their commits. 

Live demo (7 minutes) 

1\. Pitch the game in one sentence (30 s). 

2\. Play Level 1 and show a level unlock (2 min). 

3\. Show offline mode in airplane mode (1 min). 

4\. Play an online match with the instructor or a classmate on a second phone (2 min). 5\. Present the top 3 playtest findings and what you changed (1.5 min). 

Page 27 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

Guide questions (answer in the paper's appendix) 

1\. How does your level-unlocking system decide which levels are open, and where is that information stored on the phone? 

2\. What happens in your game if the internet drops in the middle of an online match? How did you handle it? 

3\. Why should the host or server, not each phone, decide the winner of an online match? 4\. Which playtest finding surprised your team the most, and what did you change because of it? 

5\. Which statement in the feedback form scored lowest, and what would you do with one more week? 

6\. Compare developing forAndroid and iOS: what did your platform choice make easier or harder? 

Lab work rubric (100 points) 

| Criteria  | Excellent  | Satisfactory  | Needs improvement  | Points |
| ----- | :---- | ----- | ----- | ----- |
| Game design  and GDD | Clear, original  idea; GDD  complete and  followed | GDD mostly  complete; game  drifts from it | GDD missing or idea unclear | 10 |
| Core gameplay  | Fun, responsive touch controls;  clear goal per  level | Playable with  minor control or  clarity issues | Hard to play or goal unclear | 15 |
| Levels and  progression  (R1–R5) | 5+ levels with a  good difficulty  curve; locking,  stars and saving all work | 5 levels; unlocking works but curve  uneven or saving buggy | Fewer than 5 levels or unlocking/saving broken | 15 |
| Offline mode  (R6) | Works fully in  airplane mode; AI or pass-and-play included | Solo works offline  | Fails or crashes  offline | 10 |

Page 28 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Criteria  | Excellent  | Satisfactory  | Needs improvement  | Points |
| :---- | :---- | :---- | ----- | ----- |
| Online mode  (R7–R8) | Two phones play a full match;  disconnects  handled; Option B done | Option A match  works; weak error handling | No working online  match | 15 |
| UI, audio and  polish (R10) | All screens,  pause, sound  toggle, credits;  looks finished | Most screens  present; some  rough edges | Missing menus or  unreadable UI | 10 |
| Mobile build  (R9) | Runs smoothly on 2+ phones; test  matrix complete | Runs on 1 phone;  matrix partial | Does not run on a  phone | 10 |
| Playtesting and evaluation  feedback | 5+ testers, forms analyzed, 3+ fixes verified by retest | Fewer testers or  fixes not retested | No real playtest  | 10 |
| Demo,  teamwork and Git use | Confident demo; all members  committed  regularly | Demo works with help; uneven  contributions | Demo fails; one  person did most  work | 5 |
| **Total**  |  |  |  | **100** |

Bonus (up to \+10): star-based world unlocks, online leaderboard, tutorial level, accessibility options, or a working Nakama (Option B) deployment. 

Submission: GitHub and Google Classroom 

Teams upload the **game project and build** to GitHub and turn in the **links, video and paper** on Google Classroom; a submission is complete only when both are done before the deadline. 

Step S1 – Finalize the GitHub repository 

1\. Repository name: itsd85-lab\<no\>-\<section\>-\<teamname\> (e.g. itsd85-lab4- bsit4a-pixelpioneers ). 

2\. Root README.md with these headings: 

Page 29 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

\# \<Game title\> – ITSD 85 Lab \<no\> 

Team: \<full names and roles\> Section: \<section\> Platform: Android / iOS 

\#\# About the game (one-paragraph pitch \+ 2 screenshots) \#\# How to play (controls, goal, how levels unlock) \#\# Offline and online modes (how to host/join or connect to the server) \#\# How to build (Godot version, export steps) 

\#\# Download (link to the v1.0 release APK) 

\#\# Playtest results (top 3 findings and fixes) 

\#\# Credits (link to docs/CREDITS.md) 

\#\# Paper (link to docs/paper.pdf) 

3\. docs/ folder: GDD.md , CREDITS.md , paper.pdf , screenshots/ , and playtest/ (anonymized forms as PDF or CSV – remove testers' names). 

4\. **Never commit** the release keystore ( .keystore , .jks ), its passwords, the Nakama server key, or export/ builds. Godot keeps export passwords in .godot/ , which the .gitignore already excludes. 

5\. Files over 100 MB cannot be pushed to GitHub. Keep the APK out of the repository and attach it to the release instead. 

6\. Every member must have commits under their own GitHub account. Pair-programmed work: add Co-authored-by: Name \<email\> on the last line of the commit message. 7\. Freeze the graded version: 

git switch main && git pull 

git tag \-a v1.0 \-m "ITSD 85 Lab final submission" 

git push origin v1.0 

On GitHub: **Releases → Draft a new release** → tag v1.0 → title \<Game title\> v1.0 → attach the .apk (Android) and paper.pdf → **Publish release**. 

8\. Private repository: add the instructor under **Settings → Collaborators** (GitHub username: \_\_\_\_\_\_\_\_). 

Step S2 –Turn in on Google Classroom 

1\. Open **ITSD 85 → Classwork →** *Lab \<no\>: Mobile Game with Level Progression*. 2\. Under **Your work → \+ Add or create**, attach: 

**Link:** GitHub repository URL. 

**Link:** v1.0 release URL (where the APK can be downloaded). 

Page 30 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

**Link:** demo video (2–3 min) on Google Drive or unlisted YouTube; Drive access set to *Anyone in your school with the link can view*. 

**File:** the paper, ITSD85\_Lab\<no\>\_\<Section\>\_\<TeamName\>\_Paper.pdf . 

**File:** individual contribution log, ITSD85\_Lab\<no\>\_\<Surname\>\_Contribution.pdf (each member submits their own). 

3\. Private comment: team name, member names, latest commit ID, and the phone models the game was tested on. 

4\. Click **Turn in**. **Every member** turns in (the instructor may also create this as a group assignment). 

Rules 

Deadline: \_\_\_\_\_\_\_\_\_\_\_\_ (11:59 PM). Demo day: \_\_\_\_\_\_\_\_\_\_\_\_. The v1.0 tag date is checked. 

Late submission: minus \_\_\_ points per day, up to \_\_\_ days. 

Resubmit before the deadline: **Unsubmit**, replace files, push tag v1.1 , **Turn in** again. Only original or properly licensed assets; uncredited or copyrighted assets lose the polish points and may be graded zero. 

Publication-ready paper 

Each team turns its game and playtest data into a 5–7 page research paper in **IEEE conference format**, written well enough to submit to a student research conference or the school's research journal. 

Format and free tools 

| Item  | Requirement |
| :---- | :---- |
| Template  | IEEE conference template, two columns – free on Overleaf or as a Word/LibreOffice file from the IEEE template page |
| Length  | 5–7 pages including figures and references; appendix does not count |

Page 31 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Item  | Requirement |
| ----- | :---- |
| References  | IEEE numbered style, at least **12** sources, at least **6** from the last 5 years (game design, player experience, mobile games, multiplayer networking, playtesting) |
| Tools  | **Zotero** (references), **draw.io** (diagrams),  **LibreOffice Calc** (Likert averages and charts), **LanguageTool** (grammar) |
| Final file  | PDF with fonts embedded, file name as in Step S2 |

Whatto write in each section 

| Paper section  | What to write from this project  | Evidence to include |
| :---- | :---- | :---- |
| **Title**  | Name the game and what was evaluated, e.g. *"Design and Player Evaluation of \<Game\>: A Level Based Mobile Game with Offline and Online Multiplayer Built with Open-Source Tools"* | — |
| **Abstract** (150–250  words) | Problem, game concept, method, number of testers, key ratings with numbers, conclusion | Overall mean rating |
| **Index Terms**  | 4–6 keywords: mobile game, level design, multiplayer, playtesting, Godot, user experience | — |
| **I. Introduction**  | Why the genre or theme matters; the player problem the game solves (learning, fun, local culture); research questions; contributions | — |
| **II. Related Work**  | 6–10 sources: similar games, level progression and motivation,  mobile usability, peer-to-peer vs server multiplayer, playtesting methods; how your game differs | Citations |

Page 32 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Paper section  | What to write from this project  | Evidence to include |
| :---- | :---- | :---- |
| **III. Game Design**  | Core mechanic, goal, win/lose rules, level plan and difficulty curve, unlocking rule, offline and online modes | Fig. 1 screen-flow diagram; Table I level plan |
| **IV. Implementation**  | Engine and tools; scene and script structure; save/unlock system; networking approach (Option A or B) and how the winner is decided; build for the platform | Fig. 2 architecture; Listing 1 save/unlock code (≤20 lines) |
| **V. Evaluation Method**  | Participants (number, age range, gaming habits), procedure (think aloud, levels played, online match), instrument (15-item feedback form, 5-point scale), analysis (mean, standard deviation,  completion rates), consent | Table II participant profile |
| **VI. Results**  | Likert means and standard  deviations per item; per-level completion rate and attempts; main themes from open answers; issues found and fixes; retest results | Table III Likert results; Fig. 3 completion rate per level; Table IV action plan |
| **VII. Discussion**  | Answer the research questions; compare with related work;  limitations (small sample,  classmates as testers, one  platform) | — |
| **VIII. Conclusion and Future Work** | Main finding in two sentences; next features and a larger study | — |
| **Acknowledgment**  | Instructor, playtesters (not by full name), anyAI tool used and for what | — |
| **References**  | IEEE style, every entry cited  | — |

Page 33 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Paper section  | What to write from this project  | Evidence to include |
| :---- | :---- | :---- |
| **Appendix** (not  counted) | GDD, anonymized forms,  observation sheets, phone test matrix, guide-question answers, repository/release/video links | — |

Suggested research questions: 

1\. **RQ1:** Does the level-unlocking system motivate players to continue? (form items 5 and 14, completion rates) 

2\. **RQ2:** How usable are the offline and online modes on a real phone? (items 3, 7, 8, 9, 12, 13\) 

3\. **RQ3:** Which design changes did playtest feedback lead to, and did they improve the retest results? 

Ethics and data privacy 

Ask every tester for **consent** before playing (a short signed or Google Form consent). Testers under 18 need a parent's or guardian's consent. 

Do not record names, faces or phone numbers in the shared data. Use codes (T1, T2, ...) in the paper and the repository, consistent with the Philippine **Data PrivacyAct of 2012 (RA 10173\)**. 

Report all results honestly, including low scores; do not remove testers who disliked the game. 

Writing rules 

Third person, past tense for methods and results (*"Seven participants played Levels 1– 3..."*). 

Report each Likert item as mean and standard deviation (e.g. *M \= 4.1, SD \= 0.7, n \= 7*); interpret 4.20–5.00 as strongly agree, 3.40–4.19 agree, 2.60–3.39 neutral, 1.80–2.59 disagree, 1.00–1.79 strongly disagree. 

Figures and tables numbered, captioned and mentioned in the text before they appear; screenshots of the game limited to two in the body. 

Paraphrase and cite; quotes from testers in quotation marks with their code (T3). Page 34 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

Publication-ready checklist(tick before turning in) 

IEEE template unchanged; author block with names, section, school and emails. Abstract 150–250 words with the number of testers and at least one rating. Every research question answered in the Discussion or Conclusion. 

Likert table includes mean, SD and n for all 15 items. 

At least 12 references in IEEE style; all cited. 

Consent obtained and data anonymized; statement of this in Section V. Figures readable in black and white; captions complete. 

Spelling and grammar checked; consistent terms ("level", "stage" – pick one). Links in the Appendix open for the instructor. 

Originality checked (Google Classroom originality report, if enabled). 

Grading 

Each student's final grade combines four scores out of 100: **45%** team lab work, **35%** team paper, **10%** submission and GitHub practice, and **10%** individual contribution, so members of the same team can receive different grades. 

| Component  | Rubric used  | Scored  per | Weight |
| :---- | :---- | :---- | ----- |
| Lab work (game, phases 1–8, demo) | Lab work rubric, in Deliverables above | Team  | 45% |
| Publication-ready paper  | Paper rubric (below)  | Team  | 35% |
| Submission and GitHub practice | Submission rubric (below)  | Team  | 10% |
| Individual contribution  | Contribution rubric and peer  evaluation (below) | Student  | 10% |

Final grade \= 0.45 × Lab work \+ 0.35 × Paper \+ 0.10 × Submission \+ 0.10 × Contribution. Example: 85, 80, 90 and 95 give 38.25 \+ 28.0 \+ 9.0 \+ 9.5 \= **84.75**. 

Page 35 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

Paper rubric (100 points) 

| Criteria  | Excellent  | Proficient  | Developing  | Beginning  | Points |
| ----- | :---- | :---- | :---- | ----- | ----- |
| Title and abstract  | Specific title;  abstract gives  concept, method, number of testers, key ratings and  conclusion (9–10) | All parts, results not quantified (7– 8\) | Vague or wrong length (5–6) | Missing (0–4)  | 10 |
| Introduction and research questions | Clear motivation and answerable RQs (9– 10\) | Motivation clear, RQs weak (7–8) | No RQs (5–6)  | Missing (0–4)  | 10 |
| Related work  | 6+ relevant sources synthesized;  differences from this game stated (9–10) | Relevant but  listed one by one (7–8) | Few or weak  sources (5–6) | None (0–4)  | 10 |
| Game design  | Mechanic, rules,  level plan, difficulty curve and both  modes explained  with Fig. 1 and Table I (9–10) | Mostly complete (7–8) | Partial or  unclear (5–6) | Missing (0–4)  | 10 |
| Implementation  | Structure,  save/unlock system, networking and  winner authority  explained with figure and short listing (9– 10\) | Explained, minor gaps (7–8) | Code dump or copied steps  (5–6) | Missing (0–4)  | 10 |
| Evaluation method and ethics | Participants,  procedure,  instrument, analysis and consent fully  described; data  anonymized (14–15) | One element thin (11–13) | Several  elements  missing (8–10) | No method or no consent  (0–7) | 15 |
| Results and analysis  | Likert M/SD/n for all items, completion rate chart, themes, action plan with  retest (18–20) | Results complete but no retest or SD (15–17) | Results without statistics (12– 14\) | No results (0– 11\) | 20 |

Page 36 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Criteria  | Excellent  | Proficient  | Developing  | Beginning  | Points |
| :---- | :---- | :---- | ----- | ----- | ----- |
| Discussion and  conclusion | RQs answered with data; compared to literature; honest  limitations (9–10) | RQs answered, limitations thin (7–8) | Repeats results only (5–6) | Missing (0–4)  | 10 |
| Format, language and references | IEEE template; error free; 12+ IEEE  references, all cited (5) | Few errors (4)  | Many errors (3)  | Not in  template (0– 2\) | 5 |
| **Total**  |  |  |  |  | **100** |

Submission rubric (100 points) 

| Criteria  | Full credit  | Partial credit  | No credit  | Points |
| :---- | :---- | :---- | ----- | ----- |
| Repository  completeness | Correct name;  README with all  headings; docs/  with GDD, credits, paper, screenshots, anonymized playtest data | One or two items missing | README or  docs/ missing | 25 |
| Commit history and release | Every member has meaningful commits across the 5 weeks;  v1.0 release with APK (or iOS video) and paper | Commits uneven or release  incomplete | Single bulk  upload, no  release | 25 |
| Google  Classroom turn in | All links and files  attached and  correctly named;  private comment  complete; every  member *Turned in* | One item missing or misnamed | Not turned in  | 25 |
| Security and  licensing | No keystores,  passwords or server keys committed; all assets credited | Minor credit gaps, or secret removed and rotated | Secret exposed or unlicensed  assets | 15 |

Page 37 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

| Criteria  | Full credit  | Partial credit  | No credit  | Points |
| :---- | :---- | :---- | :---- | ----- |
| Timeliness  | On time  | Late within allowed days (less late  penalty) | Beyond allowed days | 10 |
| **Total**  |  |  |  | **100** |

Individual contribution (100 points) 

**Contribution log (40 points, graded by the instructor):** each student lists the features, levels, assets or paper sections they made, with links to their commits. 36–40 \= clear, substantial and verified by commits; 28–35 \= clear but smaller share; 20–27 \= vague or weakly supported; 0–19 \= missing or not supported by commits. 

**Peer evaluation (60 points):** each member privately rates every teammate (not themselves) on a Google Form, 1 \= poor to 5 \= excellent: 

| Criteria  | Teammate 1  | Teammate 2 |
| ----- | ----- | ----- |
| Did a fair share of the work |  |  |
| Met agreed deadlines |  |  |
| Quality of their work |  |  |
| Communicated and attended meetings |  |  |
| Helped and respected teammates |  |  |
| **Average (1–5)** |  |  |

Peer score \= average rating received ÷ 5 × 60\. A student whose average is below 2.5 meets the instructor before the final grade is released. 

Sources 

Godot release news: Godot 4.6.x maintenance releases in 2026; 4.7 is the current 4.x line. 

Godot download page and Exporting forAndroid. 

Heroic Labs – Nakama multiplayer backend: Nakama is Apache 2.0, runs locally in Docker on ports 7350 (API) and 7351 (console). 

Page 38 of 39  
ITSD 85 Lab: Mobile Game with Level Progression and Offline/Online Multiplayer 

Apple Developer Forums – free provisioning: personal Apple ID builds must be re signed every 7 days. 

Free assets: Kenney.nl, OpenGameArt, Freesound, Google Fonts. 

Page 39 of 39

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAqAAAAJ1CAYAAAAGz0JZAACAAElEQVR4XuydZ5gc13lm99/+8Fr22lpbkuXV2mslK61sRVMiFSmJihRFMWeKOScwggCIRAQiByIDRM4555wmATPIOadBBkgCJO/W+YZfobtmMMDMdA+6gfc8z3mA6aquqq66de9bt251/7cQwn+P7Pixx4IQQgghhBCZhYzZ4WP/+38LFcFTCCGEEEKI+qC9AqgQQgghhKhPLIDqtrsQQgghhKgvjhJAhRBCCCGEqDcUQIUQQgghRL2iACqEEEIIIeoVBVAhhBBCCFGvKIAKIYQQQoh6RQFUCCGEEELUKwqgQgghhBCiXlEAFUIIIYQQ9YoCqBBCCCGEqFcUQIUQQgghRL2iACqEEEIIIeoVBVAhhBBCCFGvKIAKIYQQQoh6RQFUCCGEEELUKwqgQgghhBCiXlEAFUIIIYQQ9UpWA+h7770XunbtGn75y1+av/rVr0LLli3D4cOHTfjNb34T2rVrZ2aDbt26hS9/+cvmBx98kJycddavXx++8pWvmGVlZcnJGWXx4sX2Offv329mitdee8287bbbkpNqzNixY8O//du/mcePH09Ovig++ugjs6SkJGzfvj1t2r//+7+H/v37m7kK5RALCwvD3r17k5Mzzpw5c8zPfvaz9jfHEe+7777EnNnnnnvuCS+++KKZKby8/+xnPwuf+MQnwmOPPWaeD+og/M53vmN/X3311Wbv3r0Tc2aHfv36mf/7f//v8D/+x/8ImzdvNs9H586dzWuvvTY5SQgh8pasBNB3333XvPfee8P/+T//JzzyyCPmM888E/75n/853HDDDeb7778ffvKTn4Q333zTdE6cOGGWl5eHDz/8MGXJwf72AHvq1Km0aWfOnAlnz56N188yZs2aFV544QWT97JODwAnT54Mx44diwONQ3BG1u/LwuS2AMvw7alq+rp168LnPvc5s7S01F7z9bN83u/r5/2sJ3V7eM23h//zOtuMrDN1uxcuXGj7NxlA2S8usJzUdfk09t3p06fDkSNHTP88vv/++Mc/xssE3n/o0KG0ZafCsviMLBeBAPp//+//NQmgqZ/P5+EYob83ic9P2WncuHE8PxDAvYFn+Xi+48u2+/tS8fmZxvZ5eWSfJ2EeloMsE3x/sH8gdXl49OhR8z//8z/tAil1+6uDZXBc/P3+mbw8+XrZb6n7bubMmebf/M3f2N9cFGLPnj1tGanli+VzXiXPLbjQ8QZfDrK/kvv/5ptvDk8//bQJvO7HyT+Tfx4vnw7/9/PQyyb/jh492vyf//N/2kWYl3/fX378fFkTJkwwGzZsaH9zHLB79+7xMlP3Rer2J2G7/XxMzsO2Jss/++1HP/qReffdd4e1a9fG+5P3c06nllvwC/Qf/OAHtl/8ePn01PPZ94sQQuQ6CqAKoPE0BdAKfH4F0HQudLxBAfQcCqBCCHF+shJAJ0+ebP71X/91WLp0adq0adOmhUcffdTk9mMygBJQ/uM//sMkpNBQEWSQSvrxxx8Pn//8501uoS1atChe9htvvGFyKw5feumlMGbMmPCnP/3JBG47+nzf+ta37Nb4oEGDTNiwYYPd6sJ//dd/Dd/73vfCD3/4Q9MDpDNjxgxbxhe+8AXz+eefr9QIJQMoDeFDDz1k8vm+/e1v2z7BAwcOhKuuuioUFxebwG3aX//61+bBgwctWH3961832QepAex8AbRFixYm+wPYDvyv//ova+heffVVs1GjRuH73/9++NKXvmS+9dZbNn8ygK5atcrk2P3Lv/yLvY67d++26RwT5LPwGW+55RZz3759lQLo0KFD4+O1Zs2asHHjRhuWgcxz66232n5Bh+3Ef/iHf7BjdOedd5pAAP3DH/5gso/+3//7f3F5BIZE/OIXvzDZdtazdetW0/FAwO3ipk2bxuXxq1/9ahg1alQ8365du8J1111ny0H2B9vPcUACw8qVK+PjwTF855134lvEf//3f2/l5sknnzQpO6tXr44DpuMBpm3btuGLX/yiDTPADh062PSJEyeaXORxYedDHO644w4LKskASvDC5s2b23b5+UEZ4Lhz3JCyB8nj7ReQe/bsibfR+elPfxp69eplfu1rXwvf+MY3wvjx401IBtA+ffrE5ZnP1KVLl/h4cFucgOasWLHChvJwHiBQjlkPcvudMk2dg23atLHP881vftMcNmyYvYdjgBxfSA2g7C8/H9jXnP+c5+h44GOYB+ulXCAXE+DnL/uLMsx6kPLOOfjJT37S5Bj95S9/iQM/w1w4p31/sI2QGkDZHz//+c9N6hbw84197xc9QgiR62QlgHpgoVJPBrIkqQGUAPOP//iPcQNGIKHh79ixo1lUVBRuuukma9SRBpeg6IHhgQcesKDnDQzjAxnX5Q0E0KixTqSBJdB64KIRYBk33nijyftpQJ977jmT3krwwMf6aUC9gfpf/+t/2XalkgygBF9CHvJ52D4PsDToBKMGDRqYwL8e4Agn7J8RI0aYhAIaMUIcni+AeuAnzMHy5cvNv/qrv7KgQ1BBGlNe98BKg07PTmoA5ULgu9/9rvnwww/bZ/KAzDbS4+NjXmls2WaOGXIMUwPonDlzwqc//ekwYMAAk7JCMPvxj39sUh5YBxcR6GzZssUkHHD8aJQ9qKQGUEIAYx2ZD1k+x59lImGUf3/3u9+Z3nvkx5cGn+NRUFBgPvjgg1YevYf4+uuvt+BLOUUuQAgGlBN86qmnbL1+/Lys+gUA+/v1118PmzZtMundYkyg99A5HqApXwRJ9iHy94IFC+LyTsCkJ9ADH/t23LhxlQIoPW/IZydEMzYU2feUSd//t99+e9rx5hxgn/E6UmaSEKo9oPIZKQMeiCmTqQGUUM0FgAdoLgIp3x5AuSjhAsB7INleLiBTe0DZz1wo4ac+9Snbfi4ikYuDJUuWhNatW5uMuWQ5Pj/HF1IDKD2obAPOmzfPtsnv4Hhd5hdEnNNvv/12WLZsmcn62F9+gdusWTOrY7y8syw+l1/Q+P70Hnv2Ecvx/cHn4XOkBlDKDyEbCdiQejyFECJfyEoA9YdWCCEXuiWUGkAJGYQeQh/SKBCoPMB4L4H3SNL7RQ+k9yAQHmnoU2+ZVRVAPWDB1KlTbZgAEp7uv//++CENAhANBT1N3tsEvvzp06eH3/72t3EPCw08DUcqyQBKL8U//dM/mXw+ejq8R4ThAqk9nIQ/grEHEnpY/vZv/zZeH+//zGc+E/eo1TWAegPmgYrpBJTUAMrn8cBCjxQMGTLEJPDQgPrno/EED3RIcKLnEunxIrT5LVfwhzOQkM6wDXrKUx/W8QBCQKGRT4UA2rdvXxPopfILDG5vEvDo2UL2H//6BQC3lyE1gHovMBDqmJ9eTqQ3kNDgAYZ1s92+vfR4sV6CBPpDaF5e6f3mQsvhM/Xo0SMOYI4/tOMPofgF1zXXXGNBxwMovWfgt5wpu+yHCwVQygwSZuGVV14xuajgePvx4vPxOf0OBJ89yd/93d/FF0hAsKaMIuEuNYB6L6L3SBPIKXOEMqS8cwy4EETO99Q7Hg690ugPWfktah7cIUj78WfZ9BBWF0B37NhhvebIe9hezkv0OsWP3+9///u4Fx3Z13wmv0DmfOMYs0/QyxLrTS1bDFVC9jHb4evnAoPzITWAgm8/dSDHz48HYVsIIfIFBVAFUAVQBVAFUAVQIYSoV7ISQOfMqfjaFxp7bgmmQoPjY8645ZwaQLmNza0vv6XNLVRuPXoDSiVMxcytMXz22WcrBVACZCpVBdBWrVqZwNjL1ADKbS1vMGnwqhqDyFhGpMHjtrJvH9t+oQBKo0Wjhnw+QpwHuJ07d9py/ZYlXxVDSPNbvoQMGjyCAvJ+QpGPOTxfAPUxhj4O1uelQeYWpgdQQir4Le2qAui2bdviAEqjDP5QCyGOr0by/edjCD1AIAHUA+Zdd91lDTTlwMcTEoy9/FB2COIcZ3RSAyi3aFMhJKV+DRO39lOHWBDg27dvb7L/5s+fHwcmbp9CagBlPoeLAAKoDwFgXQRAH/NHOOI4+i149jHBkyCBPkYwNYDyINCF4DOif22Qv5+yzznhAZRtA18/YeZiAqgfDw93PgaSAMrx9gsKwjGf048Pwz6SELSYD4H5uTBBhjGkBlCGkLBfvPwPHz48LYByzjGd2/jIcIaqLmiTAdRvYbNOPrcP4bmYAMo56GOyqWOoT/wChXMQ/KEj6iZCNRdBSNmizPstdsos57e//3wBlGEkyAUF+8uHfLA/qD+SAdS/tomyxQW5Dymq6oE9IYTIVbISQP2hCcY40bPnY8aQRpBeL6QxSQ2gNA40qt6jQKXL2CnvgaTCJhT6GCvGQdHoECIwEwGURsDHjBFKCHg0wuh4DxeNMmPDPMARugh6HmAgGUDp5fUARyPPw0gekOh9oZeFsYbIU70vv/xy3OPK9hEyPMASllnO4MGDzfMFUB9DSQ8L6/TvPWS8IsutSQBlfu+xoZea4+Bj3AjMfG4fg0kPJvvRH9LhAZPUMaA8SELPl485pAeSRtt7uJmfXjE+p493A98fbDMNPQ/TID2c1QVQelkZl+kPrfBQDz3SjOVE74W9UAD1p8x5AIy//XslKbM8JONjOilzPCzFOGEkTBFQvAeT78VlHV7e6LXkwb3kGFA/HoREyoUHSP4mMGUzgKYeb/a1BzesagwoAdTPtyZNmlho9IfMOL9TAygXK4Q2yjiy/9hHfoEA3NHgrgh6r3aSZAD1/ce2UC48oPE3FzXVBVACpZ+vHFP2k4+59AsUP7/odaQe8/1F4CUY+h0KxpGzj6mzkLLOcU8GUH9oikBJneljwKlPqDOSAdTvGHBBSXnxMeBCCJFPZCWAOjTi3OL2CpVeDHoN/BYZ0DB7gASCnlfohDt6Rnx+eh0IPN4jxm1ibrP5QwCEm9SHVYBbYd4DAtzy9B5E4FaqBxyWTyD0W2CENIYR+BfZ01iD98BNmTLFQtvAgQNNAmDya3UIWb58ejdpOPwhEW6bc2vVH0px/KljGnCCTCoEWt+frJuHTDzws+88yKDj0zkWNJge6P229siRI00PPd7jy/rZJ7wPCbngPbKEeI4RvXjox9Tfz7FiG/0hI/YJx8wDAPPTK+oBkh4nhgQQDJFl05PmPX5JGCLRqVOn+AKGbeJzEfK895WHUjzQcMzYL14eWD77K/WpavD9xWcikDjse5bj38rA9nO8/SEVPi/BxHvo+Uxst5dfAjW9Wl5+6EUlWPjnJTQSUhjagY4HbnrTnnjiiTjA0UsGfEb/nODlj15p5vFA7L3FHtgogxxfD8D+pf5+B4JjBv5Uvh8T35/eI5gKIY99gpQ1hrqk9nDzJLo/VMU+4Baz9wByPlEGU7+VgtDpdwRS70KkwtAG9ItKPz7sb/aX9/hTfidNmhQ/Ne69z96DT+8728Q8yDYRjJNfFO/HgzLmxwK9rHArHLnYoZwRtJH9TwD188UDv5cH6kDW6fWb31JPbq9DYOYOiV8QCSFEPqEAqgCqAKoAqgCqACqEEPVKVgNovkFj/bnPfS4egwY0XH6L0r93T4hsQEjlFrWPMcxHCKAEScwE3IL3ITuiAr9A4hY8Y0A9EAshRD6hAJoCY9QYY+djwuj9ZNwbvWxIL4UQ2YJeS3oV8zlQ8AX2qXcY6gI99Iy95MJPF3/n8B5t9jXjxoUQIh9RAE1Aw++3sHmoxX/CL18DgRD1Cbe+U79Wqy6wDJan8y8d37/+UJQQQuQjCqAJFECFqD0KoNlHAVQIcTmgACqEEEIIIeoVBVAhhBBCCFGvKIAKIYQQQoh6RQFUCCGEEELUK1dUAOV7Fk+ePBF/UTXfpSdyD38IzL/MP8mpUydNvhaLL2+vz4dU/OGPfHkAJB8eovMvzudr0JLwRf6ZeqhJCCFE7pCVAMrvU2PHDu1Cu7fahLlzZ5uXinVr15rNmjUJs2fNDEOGDDK3bt2SnFXUA6tXrzYPVvHLNqNGjgwdonKDmzen/wqU49MJJ23atIp/W70+4HsXB74zwLwY+PWrNWvKzPpg8eJFFuQ8zLVu/Wa97p/aUFJcZE6dMjk5KfTu3TP+7XUhhBCXD1kJoIMHDzSLiwqtIZwVhT6kx4pQMXz4UHPRwgX22vJlS8158+aG9evXhcPl5eboUSPDjBnT4gaVeRfMnxdGjhhuEnLpxVwWvRdnzJgeJk2ckNZDRQ/ZW1EIRgLxjh3b4+0jgPITg2PHjjEnThhvvaSFhQUmvUe7d+0KK1YsN4HXU39KlH+nT5tqsr1s96qSEtN/Hs9/iu/48WOhOGpohw0dYpaVVfz8pi9/6ZLFYeXKFWHRooUmvVZ8PkIFOgcPHjBZ34hoP0ydOtk8diz6LGNGh5kzp5uEDrZ/SbRcHDFiWNi0aWOYMmWSOT/al6zjfPvb8f2xMDpe48ePCxs3bjBZ3rZtW20fI/MAxxAPHNhvIXNMtE24cMF8+2qrpk0bmz16dE8LFizr+eeeDiNHDjdZJuVi2LAhpgfS9u3fMgmgqQGLn0plvy6I1oP0mrHN3gO4fPmysHv3rvjzFX38c52pcBy8/FBWCgpWxu9funSJBdDOnTqa48eNtTLrv0xz6NBB24fz5s0xKa99+vSKPy/HO9PlhemO779R0b5D9k+zZm+EadG6cNzY0fa5/Kcf+TzDhg0NW7dsMR3fn3PmzA7Do+mjRo4w9+/fZ/tz1KgR5v4oXPO5vXxx7lFOC1auNPl8nEMXWh/HDUtLV9t6fXsnRGWta5fOcQA9HX2ecdE+nxitB48fPx4d47PRxe0cc3S0TZQvIYQQuY8CqALoefe3owCqAKoAKoQQIpNkJYCuXr3KbPT6axY0abiQRr9xo4Zhw4b15tAhg6IQuSO88vJL5ry5c8PRI0figEGjPHPmjKjRGWMuXrwwDBk8yEIUtmzZ3BrU1159yVy/bp0FMhpOBBq0wYMGmuOjZdCopwbQLp07WjBBAln//n2t4cNVq0osZL366ssmgaZjx/ZpY9JoiAltuGH9+tC+XVtraJEGmQaaYQi4ZfNme/+WqPFFXjt06JCFBJw+fZqFkM6dOpiHDh6MGuXSMGb0KNMhuCGBr3+/vmHypIkm+2pNWVkY0L+fSTghwHEbE/k5wxeefzbe/82jdbL+8+1vh32EfKYRw4eFPtGycOOGDbYMfjIRe0bbBAQzJFDwWklJsUk4JhD79hOSCUkOv3/erGkT2+/I9r/dvZutB5lGKE0G0KNHj5gtWzSz+QZFxxq5wOFW/ZEjh83mzZqGQQPfiX/KcPy4cfG6HY63B2j2Icv032bv8XY3C6CNG79ubt26NXTieEbHFSkzhOTu3bqY/J/P2KtXD5N9nY3y4iT3H2W/QYPnQ2l0LiLLJ7gVFhSY/aKywznwVtvW5okTx205JcXFJucCIb1F86Ym5+q46EKtKCp3yLEhUDds+IrJPmV/eSAkRI4ZPfKi1zdx4vjowmhyHHA5Bk8+8ZgNY0D2v4dv7Nu3tx0PD6xcLPTq2SPeH0IIIXKXrARQ72GicSKIEjqxqKjQAoDjPUveoPJ/AuJTTz5mtonCRas3W4QBA/qZhJY3mjSy15GAS7D1v4GgQy8dOt5ArYhCJqQGUBps78GybYn+9oBL2OrevWt4553+Jr08NIypNH2jcdxA23a0aRUORsER27ZpHcqiQEjPKtJD+2IUCHx7ee+aNWviBtnD2JIli0zCS98+vSqNgSMY4OJFCy1YemAisHXq2CE0eOE5k945AihBBYHA6D1S9t51a8+7vx2CBh44cMBCL0EGoUWLpmHvnj1mVQGUUOuBkePH8fUeznXRupMQ6OjJRS5eCNQOvXHsr2QA3b59m8nyYffu3WbPnm/bMaTnFQnAHB9CFFY1xnTt2jVxD3vPHm9HoalPWLJ4kUlAIvB4wIexY0fHPZj0/tHL/vRTT5iEQPYB8yBko7ykkrr/4M3oePpDPvRac9E3JCr7+HrDV225lHnctWunvYfjgj3e7m6faeDAASYBlyBNyETGVHOOp55/vXv1DHv27Da3bNkcne8DLri+1ADKhY7vD+jatXPYGe1zbNDgOXt/61YtTcI5vey9ouOMlF1eF0IIkftkJYDSS4k0wMeOHo0bLHqMaCS8R4neFUKNN8hAz6I3MNxm3rt3j82HU6dOsVv5NLxIwKJHrG3UiCOwzpoEUBryXTt3mvQ40QD6LWXCFUGEEIHPPvNkFFo2x8sFgqD3+PJkNkMEPND2j8ILy+czIOGGXiDf/pUrVoTDh8vjHi8fNuABgmED3bp1iQOjQyhGQhQ9Z37LlEadW5CEfCTAEED5F4H97MGf28MEqvPtb4eeJyQUcBHhPa7QsmUzO4bYtm0r+5YB7yGlR2xmtF5uTSO3cenF9kBGrzPbnUpqgCLwjx49Mi4vhA96MpMBlF5BbBV9Bm7Lzpo5w+ShFo7bi1FwQQIYFxIcV2TdDHlI3b8cQ4ISTohCID13L730gklgZX+9M6C/CfQUF0TLQAIZQzq6du1ksmyO+aBB75hclGWjvKRCzznBDjmX2CdePrioIoCyTiTksoylS5aY3C4H75GlfEyePNE+E86ePcv2qfegE4jZrtTzr0/vXvH2c34RQC+0vtQAygWDDznhmL/8UoO4h71du7Z2YeFDRigf9DpTDyAPelHPJM8XIYQQuYcCqALoefe3owCqAKoAKoQQIpNkJYD6LbTOUZjjNpk3KIQeGja/ZcaDFWfOvF9pzKGPeWN8Iw09jT5yG5GHK3gdaRBpWFNvCfuDI+j4Qx2bN1Xccl20qOIhH27fceuW24ZIg8uYOg9ohCQacg8ATE82bEeOHIkDN+GC0OHvZ5uHDh0cjxnltWnTpoR+fXubhCtep5FH/95Lfz8hq6y04sETh/k9gHTs0N5u23JrGnkohQAwb+4cc/ToURY6PPAA+9mXzzg9Auv59rfjD5ER7njQhRCKMH782DhA8RVXBEheQ7aV9fota/bFu++ejgMrwwsYm5jKtOgiw/c37x8zZlQ8ZpRjBowTRG7/MqbR1882vR0F5eFRiEHCDhcS/rVJlBVC5OTJk0zo0L5d/H6HcYtI2CEk+RAM3k/Q9YecgOO9Y/t2c05UHhmXyFhmnBIdU7bRv/aLUJyN8pIKIaxvn94moY0Q7Z9v3769dh76LXmGSRB62efoZdsDHQGTQPtmy+YmZYTyRblCHizbs2dP2vk3d86ceMwt5xfjcC+0vu3btpkM76CM+RATyiIXjh6AGYYyIHrdh4gQ0Hft2hV/XsIoF4w+vxBCiNwlKwHU8YbVrer16qhqnot9b02o6zJr8v7Uec83vz9l3yEKoMl5eIq7U6f2JgFp48aN8ZhAuNCyq6O273PO99mqeu1iqel7azI/gZJetIud/2K4mPVfzDxO6rwXM39NON+y/QKHcaCE2C5dOpk8hFTV/BfL+daXpLp5qppW1WtCCCFym6wGUFE7/JZzai+uQw+Y9+DyZPyM6dPSHtoQoq74Q118jRI9zHz9EyZ7/4UQQojaogCagyiAikuJAqgQQohsowAqhBBCCCHqFQVQIYQQQghRryiACiGEEEKIekUBVAghhBBC1CsKoEIIIYQQol5RABVCCCGEEPWKAqgQQgghhKhXFECFEEIIIUS9ogAqhBBCCCHqFQVQIYQQQghRryiACiGEEEKIekUBVAghhBBC1CsKoEIIIYQQol5RABVCCCGEEPWKAmgG+Oijj8wPPjgbzpx5X8rzShnx8pIvqHzLi1XlW17OfvDBB3lXvnMZBdAMoApMXqxqoOXlrMq3vJxVAM0sCqB15PTpU2HD+lVmYeGiUFy8JJQUL5WyksVFS0JhwaKwbm2xefLk8WRxyjlOnToR1q8rMa18F6l8y6ql7qN8r4/qQjx9+mSyOOUcJ04cC2vXFJlFUfkuUf0tz6PV31EZ2bCh1HzvvdPJ4iRqiAJoHTh65FBU4S4Me/fuMCuu/j+Mr5CkTPdDKyMHDuwxaawPHtwbT88VfHvKD+238r1//25T5VtWb0X53rdvl1mwcmE4fPggJepjcwPf3gP7z52DWNG7pfItz+eH4ezZM2HPnu0mdeOxY4eTxUvUAAXQWsCVPRYVLrYe0FyrYEV+8P777wV6XI4fP2rmCvQKIVf87733bnKyEBfFu++eDkVFi8PJkyfMXIHQgPRqnTnzXnKyENXigfT0qZNWvinnKGqOAmgtUAAVmUABVFzOKICKyxEF0MyhAFoLNmxYbXILR4i6cOTIoVBWWmBSqeUCa9YUmeXl+5OThKgRhw7tC+vWlpi5AOdY6eqVpm6firqyb++usGlTmSlqjgJoDWGcED1DyHgQIeoC44pWlSwzc6G3kSc9Kx7EWBI+/PDD5GQhaoTVl1FZwlyoL+mpWrVquZkrF3wifzlz5kycB1Rf1hwF0BpCSFgdVV4oRCbwp+K57X2p4an3NWWFphCZwHv4K4YrXVoY6uLf6iBEJvAOBIZUiZqhAFpDFEBFplEAFZczCqDickYBtPYogNYQbuH4GCIhMoE3iCdy4EEkvpvUvxdRiEzgFzRc3Fxqjh87En9vsxCZwDukcmEIVb6hAFpDFEBFplEAFZczCqDickYBtPYogNYQBVCRaRRAxeWMAqi4nFEArT0KoDVEAVRkGgVQcTmjACouZxRAa48CaA1RABWZRgFUXM4ogIrLGQXQ2qMAWkMupwDK95adPHky/mWHJGfPno1OKj3Zl20UQHMHzgfOC32nX+ZQAM0u1NH4/vvvJyflJZyD3i6dOnUq589HBdDaowBaQ/ItgE6bNi08+uij5v333x8efvjh8MILL5ibNm0Kt912WxxAN27cGA4dOhS/d8WKFaFNmzYpSxPZQAE0MwwdOjS0bt26UoO1atUq86677rpgQ/bnP/85HD161BSZQQG0AgJiixYtwn333WdSVi8UGgmWxcXFprNmzRrz+PHj9nenTp3M8ePHx/NkE9aLHTt2DHfffbe1KTh9+vTkrLWCZSLhk/20bds2k79Xr16dnP2SowBaexRAa4gCqMg0CqCZQQE0N1EArUAB9OJQAL1yUACtIfkWQA8fPhw2b95s3nLLLWHKlClh69atJpXIyJEj4wrl8ccfD/379w8HDx40Fy1aFF577bV4WfysXkFBQdi/f79ZFbxeUlJieuXqgWD9+vUmy0Fu8e/Zsyde3q5du2x+XsPCwsJKgYF5fPksI3X+06dP23v4F/OFSxVA+Rm506dPpr2WzwH05ZdfDl/84hfj8u08+eST5ic/+cm4LOKGDRvCli1b0oagDB8+PL6luXPnTitHRUVFZlXDUSh3XLShl0lfPxd4qbC/uagrLy83gUbV38+20NCmzr9jx474b86X1L/zhUsVQPlicOrrVC5lAB04cKDVp7t37zZbtWoVpk6dGk+nLCxfvjyuj4Hy8pvf/MZcu3atlRs6DXDChAl2obRs2TKTurW68uTroA7HsrIyaxf8fNi3b5+VYcodVgXnCe0Esv2Ux6VLl5o//vGPw7p16+L2g3WVlpbG5xPvJUhTh3tdD7QTyDbxuf3zcht+3Lhx1obh7Nmzw4033mjnlZ9b7777bhzQUztP6hMF0NqjAFpD8i2ApvLAAw+kXUEeO3Ys/PGPf4yvqH/4wx+Gm266yU509ADqY3Luueee8Oyzz4Y//elP5pw5c84tPIIK8Le//W146qmnzIceesgqnZYtW5pczdIL1bBhQ5PK9Ec/+lFcobLOyZMnWyWDLOORRx6xSgapcFmvV4BMo8H3Ht4GDRqEF198Md4+r8RznUsVQPnlpYULpkXrXmXyd74H0GeeeSYub0BDd8MNN5g/+MEPrKHt3r27eeedd4bbb7/dQicC54MHgDvuuCM0btw4PPfccyZlKnlB9Je//MXOK+T/zPP888+bP/3pT8P8+fPjwMkFIK/79hBqFy9ebK8j58Tvfve7MGnSJJNwy/Y5Bw4cCLfeemvK2vODSxVAjxw5FBYtnB42big1Wf+lDKD00D/44IMW0pCQR3nyQEqZ4M6Ulw/uSNFj+tWvftWkbqNO/ta3vmXSS0jw6tChg0kPaHXlifr+D3/4g9WTyMVa06ZNLfQi66TOfeKJJ8yqngvgoo1zBL0DwCEkct749lBWqZcpt8gyuRC8+eabzdGjR9sF3r333msyjfPjqquuMmlz+IzsB2Sbv/nNb4Y333zTBM5R/zw/+9nPbD/WNwqgtUcBtIZcbgGUCsmhsZ07d278twdQrtKRSm3GjBmhb9++Jo1tKkwjSHqPEZUVAcArLL+y5qoZaZQJBVwpI/z6178OgwYNMlkegXbevHkmFczYsWPtVg/+4he/sCt2Gn5knVSaDDVAQnU+4D/FuX3bhrBv3656c/u2jWHB/CmxNNZUpP7TifkGAZRyQRlCGkNuTQ4YMMC85pprrMGnZxM5F/r06ROXH+B88AD6+9//3kKg9xBRFmlkU6G809OE9PJcffXVcTkfNWpUaN++fXjnnXdMLsgo037LlPORwOANPixYsCBuUFl3auCkEafhzje8vtyxfVOlMphNt2xZl1a+Fy+aYeXbL/jqG3r5evXqZccUKV/0QjLMCV966SUrH02aNDEJkPRKeqB0HnvsMZP3AmUM6S2srjzRS0rI8x5/wuHKlSvtwh4Je5wT1NtYVQClTeDCH8+Hf56uXbva397jyjnJ5yOI47XXXmvb5x0KrI8y/r3vfc8kgHKR6OcrvZ7U66lwTtNpgYR63lPfKIDWHgXQGqIAqgCaaRRAM4MCaG6iAFqBAqgCqEhHAbSGXIkBdMiQISa3z70xx4kTJ8bzArdkqAj8ISdu/7A+v8WShADKrfZUuCXvt0h9PT5EgMY9df3ILRcfBM8QAEhW0LmOB9BNG0ujYL653ty0sSytgcaS4qV5W74JoIyZ8yEejG9mLJmPMfYASplGGmVu1ftDD5AMoCdOnLttTFlNjjOjgfQxbSybiyQPrNwSbdeuXXxLkjKZWnZnzpxpgeGVV14xgVuhfv4QQFODB58hnwPo5k1rKpXBbMpt9tSyvXDBVCvf66LwifUNYzgpTx4AGY/PhQ/BEym/qeWD+rc2AfR85Yn69mtf+1o8pMTHWfoYTOpuhlj5+qoKc9u3b4/HaDIsKpWtW7eGvXv3xgGU5cGsWbPM66+/Pu3zjRgxwtqQZs2amcA455/85CfmxQRQ9mnbtm1NAi4dFfWNAmjtUQCtIZdzAH3rrbfsRPYT3gOoP8REg0xPj/eIMn8q9FrSM+rzU4kwGN17QAm3jBv1K/yqAijjnHgQCuklpaKk0kPGJzFWz3uc+Jsr5nwPoJd6DKiP0eNvzOcxoARQf9iNxrZRo0ZxA+sB9LrrrjOZlwcpOAeQXvhsBFAejEMadcoxDS/S+1pdYGCbOYf8jkLPnj3t8+Qbl3oM6Lq1JSbrP3b08CUbA9qjRw/rmfSHZghdjPHkQgQZH0q927t3b3PMmDHW405PIXK3h9BHSERCHAH1YgMo34hCfcpykfBGp4Hf0aKXnnrbAyZ1N/Wxj8EHgrOPseazUK65K4WUferlZAD1MaAERM5Lej2RDg8usgimyD6ho4NnETAZQJmX/eAdElyQpT4lz3jWfv36xfu7vlAArT0KoDUknwMotwS5QnWoVAh6Do1r586d44cyuKKl0vIrdp50JDgyD1L5pUJj3aVLl/iKlkoVPDBSQVBx+d80+FR6qRCKu3XrZjI/t1T9qXm/perL53YOMJgdqeTAK8Tk9uUqlyqAvv/ee9H+PhIfX8jnh5DoUaKh8vJCLzoXMal/EwyXLFli0khz65Hbosi8nA/+1C6NWeqT75TVZK8QtxL9a5tYNiHDAygXQDyE5H/TC0Sj6z38hAsaTr+gA7bBHxoBLgI9cPBezo9841IF0HffPWUXVKnl+1I+hMSwjMGDB8eBkNBHHejlk7JI/cqFCfqXsXsPImGV+tsvyAmd1M8e6Chv1ZUnzg8usPxbIRg+wjL9KXOvc+koQNZNwEt+q4hf0NGe8NCfl0+eeAcfMkXABd//fBUay+eiDPkMQGj24Eww9gs01sH5deTIEZNlMN17PHmNz8UykXPvUnz7iQJo7VEArSEKoAqgmUYBNDMogOYmCqAVKIAqgIp0FEBrSD4HUJGbXKoAWhX5HEBFbnKpAmhVXMoAeqnhK/a4Je8XRNzS52Go1ICeCuGYYVWiehRAa48CaA1RABWZRgFUXM4ogOYGjLHkezb9obunn3467Y5YEkIpQVVUjwJo7VEArSEKoCLTKICKyxkFUHE5owBaexRAa4gCqMg0CqDickYBVFzOKIDWHgXQGqIAKjKNAqi4nFEAFZczCqC1RwG0hiiAikyjACouZxRAxeWMAmjtUQCtIQqgItMogIrLGQVQcTmjAFp7FEBriAKoyDQKoOJyRgFUXM4ogNYeBdAaQiFbFRU2FCITeODjS7MvNYSEsrICU4hM4Bfsp09X/m3x+uZ4dJHnP80pRCYoKVlqvv/+uR+tEBeHAmgN4RcrSoqXmB98cDY5WYgaYb8QUrLMzIUr6DNn3o8rVH0HoKgrH354rr48e/ZMcnK9w68jrV693Kzqy9eFqAmU6eKiJSZlXdQMBdBasGHDavPAgT3JSULUiKNHy0NZaYGZGw3iR3GP7OHDB5MThagRhw7tD+vWlZi5AOdY6eoV5rFjh5OThagR+/fvCps2lpmi5iiA1gIFUJEpFEDF5YwCqLicUQCtGwqgtYCxTFhUuMgeShKiNnC7m1s3x48fMXOFkyeOm0WFizWuSdQahpRQR546ecLMFY4ePWzmyrAAkZ+cPn3q4wxwyhQ1RwG0FnAVjfReESD2799t0ljnRi+WyEUoG4TOQ4f2mSXFS8PBg/vi8pQr+PaUlx+w8n3w4F7zjMq3qAbKBnUgd4aQsnPk8KGcLd9sI+dg+aH9JudmLm2nyC2sfEcXVfv27TIp38eOHcm58p1PKIDWEa6CtmxeZ/pgZCnPZ1HR4rBxY5nJVx7lOjwVv2nTGrM42vbk57mSpfcDk69fyVK+N29eY+bCU+8X4uSJY9G5WGrS45/8PFKmuzhs3bLO1N3PuqMAWkcUQGVNVAC9fFQArawCqLy8VQDNJAqgGYRueMYUcStHysqeyetbNVa+z6h8uzt2bA67dm6p9PqVKnVfvpdvztHk55IS87185yIKoEIIUQt2794W9u7ZkXxZCCHERaAAKoQQtUABVAghao8CqBBC1AIFUCGEqD0KoEIIUQsUQIUQovYogAohRC1QABVCiNqjACqEELVAAVQIIWqPAqgQQtQCBVAhhKg9CqBCCFELFECFEKL2KIAKIUQtUAAVQojaowAqhBC1QAFUCCFqjwKoEELUAgVQIYSoPQqgQghRCxRAhRCi9iiACiFELVAAFUKI2qMAKoQQF8nx40dCYcFCc+nS2WFZpP994sSx5OxCCCHOgwKoEEJcJAqgQgiRGRRAhRDiIvnwww9DSfESc8H8KeaqkmXmRx99mJxdCCHEeVAAFUKIGlBevt+sCKBTw+HDB00hhBAXjwKoEKJaPvroo9gPPvjgivfMmffNwsJF1hN65swZMznflShlRAghLgYFUCFEtSiApqsAen4VQIUQF4sCqBDivBC0tm/fZDLOsbhoifzYFcvnhpUr5lV6/cp1sZWRHTs2m2fPnkkWJyGEiFEAFUJUyfHjRy1U7NixyXzvvdOVerykPOfZ8O67p+MLFsqOvhlACHE+FECFEGm8++4ps6hwcTh58nh8+12Ii8HLC+GzKAqhXLigEEKkogAqhEhDAVTUBQVQIcTFoAAqRIbgQZSTJ05U+vu9994zz549G06dOhXfssxVNm5YbR46tC85SYgacfDAnrB50xozX/DzlXP05MmT9t2vKITILAqgQlyAI0cOm3379g5t27QK3bt3NXfv3m3Td+/eZTZv9kaYOGF8pb8nfGxZWWl4Z0D/sHfvXjMXORuFZn+o5MMPczcki/yAcaFenvh/fVNUVBQ6tH/L5NwdP35c/K0F52P4sCHmtm1bQ88e3ePzXwiRWRRAhagGekHatmltFhUVWsO1ZfNms9HrDa2HpFevHmab1m+GtWvXpP29edOmMG7cGLO0dHVYunRJOH78uFlcXBRWlZSEcWPHmPv377Nbl+vXrzNHjRxh/9bnLfBTp06EstICU4hMULp6hXn69MnkpKyydevW8GbL5qG8vNykV3PsmNFh9KiRJudgYUFBmDRxgrlkyWI7z4YMHmhu3bolLFq0MNruUybn64oVy8P4cePMw4cP2/yrVpWYo0aNsNBan+erEPmMAqgQ1aAAKkTdUAAVQlSFAqgQ1cCtcr+Fl6Rf3z5Rw7o6DpD9+/cNB/bvT/v70KFDaQG0V88eUdDcb3bu3DHMnj3LGjXs1KlD2LVrZ7y+jRs3hA4d2oU9e/aY9QEPHa1dU2QKkQnWlBWaXNzUJyNHDg8FBSvTXmMMduNGDc1du3aFxo1fDxs2rDdbt2oZnWe70wJo166d41vwhFlC6oIFC8w+vXuFdevWhu7dupicr9zmP3LkiCmEqB4FUCGq4cCBA6HdW23MZK8GYZJGZ9mypeb06VPt9eTf5wugBM5jx47GPaLt27UNc+fOCS88/4xJDyoNZElJsVkfKICKTHOpAuiYMaPtPEzlxIkToWnTxiYBlHHdzojhQy1Qni+AMqabOsB7VJk2duzo8MrLL5qcr683fDVs2bLZFEJUjwKoENXA06/ew1FQsMK+aHvTxo1mqzdbhA/Onq0UOJN/VxdAjx8/Zo0i0uu5ds2aMGBAP/P9998PpatXhYMHD5r1gQKoyDSXKoDu27fPztFDhw6a9H4yrGXatKkmAbRfvz7x/CNHDKs2gLZo3tTmO3y43OwWTeM8HzNmlMn5WlhYEF9QCiGqRwFUiGpQABWibiiACiGqQgFUiAtAw4WDo0apY4d2NvYLuQ0HPoasuLiwyr89kG7fvj3MmD49HD161Jw0aeLHDzicNvnKJgLv1KlTzL59eofhw4ZGofddsz5QABWZ5lIFUNiwYUPo0rmj2T66wJs9a2b8PbyMz549e2Y87+JFC20M9oL580weCpwyZXJ0TpwwCa9w4sRxc2o0jYcS/QKT2/mM/b7Q1zwJISpQABXiImH8FwEx20+5+vIvxZdfK4CKTHMpAyhk+3zK9vKFuFxRABVCxORDAPVfqlm4cKF90XjqBQEhYOnSpeaiRYsS77wwY8aMCbNmzTKzRceOHc0tW7YkJ10U/nnpFc/mhVCmuNQBVAiRmyiACiFiFEAVQDONAqgQoioUQIUQMfkQQHm4BD/zmc+Ef/3Xf7WvykJYv359+Md//Efzn//5nxPvvDCPPvpoaN68uZkt/vM//9OcP39+ctJFwdhFvPrqq+3L0HMdBVAhRFUogAohYvItgH7xi18MgwcPNqF169bhS1/6kukBtLS01LzxxhvDL37xizB58mST3sNVq1aF3/3ud+Ztt90W/vznP8cB9OzZs6FNmzbhxz/+sfnkk0+GY8eOpW5K2LlzZ7jzzjvNn/70p6FHjx7WC4v0zrLc3/zmN+bcuXPtPakBlKelX3rpJfNHP/qRrdcfSqOXt3HjxvY63nffffbgGyEZ/+Zv/sbWWVZWZuYqCqBCiKpQABV5BV+DdOTIIZkl9+7ZGQeGXCU1gDZs2DAOkDzZTLB79dVXTQIoQe6HP/yh2blz5zB16tTwla98xdy8eXO46qqr4sC5YsWK8OUvfzn+e8SIEeF73/te/Ms3999/f3jxxRfTbvm3bds2/Pa3vzXnzZtnIZWv98FvfvObFki5rY+f//znA7+QkxpAmzVrFv7whz+Yy5YtC7/85S9Dr169zC5duoRf/epXFmTxiSeeCKNGjQrLly83P/WpT9ky+DlYzFXKSlea+/burFTeZOZ87736+aYMITKFAqjIKxRAs6sCqAJoplEArR8VQEW+oQAq8opdu7aGkpKl5sYNpTLDrl1TGIWFAjNXSQ2gBQUFNg4UBw4cGP793/89TJ8+3SSAEjIJlcjtciBU4siRI8MnPvGJsG3bNhPuvffeOIA+/fTTFhqvvfZakzGXd9xxR9r3PPKw0ze+8Q3z61//enjllVfstj7+1V/9Vfj5z38e++1vf9u2NzWAXnfddfH7WccPfvCD+JY8QwI6dOgQf27Hf8jgs5/9rI0FzXVKV68wKVvJ8ibrbknxEnP37u3JXS9ETqMAKvIKAujevTtMkXnybQwovyDlPZAEsgYNGsRPwRNA+cL/r33ta+aECRPC2rVrwxe+8AWzsLDQAubQoUPNPXv2hO9///txAKXH9Prrr4/K2l5z9uzZYciQIWk9oPSSjh492ly5cmX4u7/7u7jH9HOf+5z1VPIDBNiuXTsLjqkB9PHHH7egizxIxXKmTZtmvvbaa+Gee+6J19+9e/cwc+bMOIDy+YqLi3O+B1RjQLPLnih4ogKoyDcUQEVeoQCaXfIhgHoA40EjgpcHSAIpt6oJgshtdhg+fLjJLXF6GnmwB3nIiEDpgfSaa66xh3u4rY48cHTTTTeF7373u+Z3vvOdSk+uE3QJrcg8DzzwQPzLWQMGDLBez29961vmU089ZT2n/lARXxNFDy29oMj7f/KTn8QPTRGyuQXvPaQMI6Cn1r+G6rHHHrPXUx/CykUUQLOLAqjIVxRARV6hAJpdFEAVQDONAmh2UQAV+YoCqMgrFECzSz4E0NpC+OOhpCR8FRKe7/e7fTqhryr4QnjkK5KSsEyGAeD58Fv6zEMoTk4jCOP5ti/XUQDNLgqgIl9RABV5hQJodrmcA6i4NCiAZhcFUJGvKICKvEIBNLsogIpMowCaXRRARb6iACryCgXQ7KIAKjKNAmh2UQAV+YoCqMgrFECziwKoyDQKoNlFAVTkKwqgIq9QAM0uCqAi0yiAZhcFUJGvKICKvEIBNLsogIpMowCaXRRARb6iACryCgXQ7KIAKjKNAmh2UQAV+YoCqMgrFECzCwHUA4MQmaCstMA8dSp3fy40n1EAFfmKAqjIKxRAs8v7778XVpUsM/33zoWoLR9++GEoKV5qnjnzfnKyyAAKoCJfUQAVeYUCaHYhdJaVFZjHjh5OThaiRhw5ckhDOrKMAqjIVxRARV6hAJpdFEBFJlEAzT4KoCJfUQAVeYUCaPY5erTcLC5eEj74IP23yYW4WM6ePROKCheFY8eOmCI7KICKfEUBVOQVCqDZh15Q3Lt3Z1i9akUUHg6bH374QXJWIdL44IMPoouXw+aqVcvD/n274vIksoMCqMhXFEBFXqEAWr/QE7pmTZFZVLg4lJaujG/RS5lqaekKKyN+y11DOOoHBVCRryiAirxCAbR+UQCVF6sC6KVBAVTkKwqgIq9QAL10nDlzxr7LkS8UlzLp6ahsMO5T1C8KoCJfUQAVeYUCqBBCnEMBVOQrCqAir1AAFUKIcyiAinxFAVTkFQqgQghxDgVQka8ogIq8QgFUCCHOoQAq8hUFUJFXKIAKIcQ5FEBFvqIAKvIKBVAhhDiHAqjIVxRARV6hACqEEOdQABX5igKoyCsUQIUQ4hwKoCJfUQAVeYUCqBBCnEMBVOQrCqAir1AAFUKIcyiAinxFAVTkFQqgQghxDgVQka8ogIq8QgFUCCHOoQAq8hUFUJFXKIAKIcQ5FEBFvqIAKvIKBVAhhDiHAqjIVxRARV6hACqEEOdQABX5igKoyCsUQIUQ4hwKoCJfUQAVeYUCqBBCnEMBVOQrCqAir1AAFUKIcyiAinxFAVTkFQqgQghxDgVQka8ogIq8QgFUCCHOoQAq8hUFUJFXKIAKIcQ5FEBFvlIvAfSjjz4yP/zwQynr5M6dW8KePdvN5DQpayr10qVCdaLMhLt3bTN3RSanSVlTPa/VBwqgMq9UAJWZtL4q2qpQnSgzoQKozKSXTQDlQ5w8eTLs3bvH3LVrZxQgpKy9paVFYc2aEjM5TcqLc8fH7ozqpb3h1KlTZn1UuqzD18e6k9sjZU0tKyuOTU6T8uLdYRnN8xrZLdtkJYB6kj506JB9oIMHD5iHDh0M5eWHpKy1GzaUhk2b1prJaVLWROoj6iUPgOXl5VkNoSybOtErfNWJMhNu3LjmY8sqTZOyJnqd6PWi14nZqhezEkCPHj1qEj6TH1DKuqgAKjMtlS5S4Z44cSLjFa4v79ixY1Yn+vqS2yFlbVQAldmS+op6C7OBAqjMKxVAZaZVAJX5rAKozJZ5F0A/+OCD+JaWKlmZaRVAZTbl1rgPIcoU1IleLybXJ2VdVQCV2dIvzDGTdaKT8QB6+vRpS83q/ZTZUAFUZlMC6HvvvWdminfffddUnSizoQKozKae56jDMk3GA+jx48fjp6iSH0TKuqoAKrPp7t277enPTD4Bym193LNnd6X1SVlXFUBlNqXeQuqwTKMAKvNKBVCZTRVAZb6pACqzad4F0H379prJDyJlXVUAldl0z56K77/LRgDVRbnMhgqgMpt6h6ICqLziVQCV2VQBVOabCqAymyqASvmxCqAymyqAynxTAVRmUwVQKT9WAVRmUwVQmW8qgMpsesUF0AMH9purVpWE4uKiSsvz6QsXzA9jxoyKv6dqy5bNYdLECWHu3NlmYcHKsGTJorB16xZzwvixldaVS86ZMzuUlZVWel2eUwFUZtNcDqD8PN6qVcVRnVhoXmwdu2L5MnPliuVhy+ZNYfLkiSbLS86bC86aNcNcu3ZNpWmysgqgMpteUQF0zZrS8OwzT5oPPnBfeOihv4QnHn/ELCwssHlmz55p3nnHbaFz545hc1Sp4usNXw0vNng+jB490uzbp1d4q23ruMJ+7NGHKq0vl3zl5RfDhAnjKr0uz3kpAui6dWvMSRPHV5qW6vbt28L+/fsqvZ5JWf6OHdvN5LRsOHNmFATWlJnJaVW5aNHCUFCwwkxOywdzMYCuW7fWfP65p61OfDiqE/GRRx6M9vPKSvMn7dqlk9m9W5ewYsWy8NyzT5v799eujs62zz//jDl1yqRK02Rl6xpAvQOntm12TUztMEpOk7npFRNA+db9Jk1eDy1aNDO3bdtqBbVzp/bmc1EFvGHDeguZeO89d1nIHBOFTbzj9lvCa6++HBYtXGB6APUKvG2bVrae/v36mDNnTA9vtmweRgwfatIjwI4ePOgds3nzNyzo8npqb8GQwQPNkSOGR+9vEfcoDBkyKLRq1dJ6XpF5abjbt2tbYfu3wvr16+Kf4iNst47mHzhwgNnghWctgHoP79ixo0PzZm+E8ePHmrnaY1Gf1jWAUi53795lEuL8WCDT6EX3/e/v4TVcvHihvU4IRMon/3r56NatcygpKYr/ZpnM4+vj7+T7k3+nBljmJ9T6FwHzN4GjV68eZvIc2x/9TfnlPejlxZfvn6265fO6f+0G0/r37xv3oNmvYkT7LPlLZ15Bsf2U2Zkzp5vJfZ8P5loAZR+3jOpCfKNJo7hOxG5dO1uQ3L17p0mdxl0U6hQcMniQvT81gJaWrg4dO7Q3KR893u4epkyeZLZs2Sz6d2La+TAgOv6+fupCP+Yu5WP0qJEmden0aVPDwHcGmK1atQglxUXx8oqKCkKrN1uE7t27mNyVYhn06iLbPHTo4PD000+YBFDK66iRI0zqwkmTJlQ6P6906xJAKQPvDOhnLl68yP729ptjRr2Rur/9daSOoDz6375Mnx85xl7/MO2tt1pHdfg6M7WOwtQ6ytfHa16/XMz8/Ms2JetSWXsVQBVAFUA/VgFUATSbKoAqgOabCqAKoNn0igmgFOgb/vj7ULByhemve4C88U/XR5VYYegQBTl86snHwvz5c8OypUvMv9x/T+jdu4eNHUIPoLwH77zjVlveIw8/YDZ9o3EYN26M3crHFSuWhx49uluIxVkzZ9h8CxbMM317GrzwnNm4ccMwKAqOt9x8o9m3by+rxP39HDRumVFJI5X5Y48+HIWnjSb/Z30jRw4zb73lzxZAR48aYT791OPWkD//3DPmuHG5PYa1PqxrAGWYAw03MmRj4cL5dlGDXPxQXrp07mh6pcZYZOzZ820bm0ZDiMzTtGmTeIjHo48+ZGXKy9/Ad/qHNq3fjBvwlVGZZmiI/93j7W5VLs8DoDXqUYNNo42UwY4d28dDUrgoSf1szNO1a6d4eVyU7dq1w4IAduzwlm2PB86qlr+mrDQ0jPYLdorW9fJLL8QBdPr0qbZcloFTp0wOmzdvDI0aNTQ7tG8XGr3+mgJogroE0G3btoS777rdXBIFhPRpW8Mfr/9dXP6efuqJijotughA6rvl0XFLDaDLli0ND/zlXpPG/Oab/mQXxjhyxLBwS1QHbdy43qQscTynTZtiPvTgX8Ly6P2p2/DMM0+GZs2amO9E5f3PN/4xDjS8xjm1MTq38J6777Ty37lTB/PFBs9ZkH70kQfNnj27h+HDh8b1KQF0aHRR7/UfZYo60QNzcl9dqdYlgBIEfcgb9eHq1SXWhiF1RKdO7aM2tadJfchFwrJlS8wmjV+3eoWOF/RlDhs6xKSNbteubbw8LsKp97xDhv+PiMqcB0Y6fNq91cZCKu7duzt6f5toGzqYFfMPPTd/VBdRH7aP5kHOr7e7d7XXkAui5AWTrLlXTADlioWQuXz5UtNfL4saRfzTDX+w4OZjPF9//VWb7ut78olH04Li+QKoj6FaMH+eFdDHH3vE5MElxol6hfjSiy9EAfJ+Ww76cj2AMiaQ4ELwxXVR6KCifvaZp0xC9P333ROP2aPCp2KllwD5PKlXmPTwEkCpCJBGgm145OEHTe/BvZKtawAlKHnAW7FiWXTR0Dvu8eb4Ux66RI018gAc70kGUCpBZBoVpl9Q0GDTq+0VJL04gwcNDN2ihh87dmhn5dZ7tHl/Vcujlwrp3RoUbVevaL1Ihcs2eQ9o8rNRZjgPfHtYFo326w1fMQcPHhhee+3lMG3qFLOq5feJyvniRQtNlkkjQvBBAgM9W3379DZfffUl65maEgUFZP5+0f5UAE2nLgF0x/Zt4Z577jQXLJifNo1x71ywe/kkgFKe4vokOr4zZkyrNoASGNesKTMp+1wEFxRUjOF97LGH7SKZOqiiLrwvCpn90raBAOoBlTLP+31M/sSofnzxxefj6Vw0sQ6/4LvpzzdEF4ALwn333m3u2F5xR+KJxx81CaAvv9TA6mCsqAsfiDsgkvvqSrUuART9goGLFf4eNGiASRvcJmpz/IKWiw/Odw+QtMmUoWZNG5s+rnPQwHfMqVMn2/Hs16+PycV+69Yt4/qJuooLlAnjx5njI1Pnpw6qcv6ojUTuCFCnvfxyA5NQzIWx54P5Ufuuu4Z194oJoPjGG41Ci+ZNTUIbV01+RcNVMAU0UwGU2/T87RUeAYRKbkD/fiaV5Izp0+IeVl+uB9DJkyZEJ/2GuEJfv26t9RJ5AOV2+x233xz34FIp0+OwZMlik//TU+a3TNkmTixOeqSSZRvmzZtjsn3J/XWlWdcASg+j3xIqLFxpZYQQhjSGlC96pZEyw3uSAZTbzMg0jlFqAC0rWx1/6wKBcOXK5RZ0cfXqVVZu58yeZfL+qpbHfEgvOk8u0zOPFT1dRbYdmPxsjaNwzb8eAAiglF96BZAeWCrptWvLzKqW3zsKtr69LIvg4gH0tShw+tPUSEihByM1cHJHQAE0nboEUMpjy5bNTY4vjbwP6aAXn4d1/JY8AXTOnFnxEBDqy4sJoF4/sb7bbr0p7lF94YVnrYH3wMhFM8c/dfsIoNR5SB3G+33ICrfLCaAMXcF777nDLvwIOkhY5db7vVG4Rso8dT4X7UgAbdGiabz9bMPcObPD/HlzzeS+ulLNVAClbPA3/yIhc9jQwXF90zoKd5QTD6A+nMyHzPmDkR5AqduY7vUrbTM9m14/Uv64i8hdSJwypSKw+vy0z9XNz8Wu1Wkft8+UP+pff0iZ+nfTpg2VPq+smQqgCqAKoB+rAKoAmk0VQBVA800FUAXQbHpFBVAaTm674O233WJjMz3QcZuIebIZQPlu0YcffsB84fln7ZZ8UWGB6cu92ADKvJ07d4gq07tNbjP16NEt3l4qVft8zz5l0mAQQAkZyJhCtuHhhx4wGe+a3F9XmtkIoH4Lkts7PaPgSZlBH8R+sQGUB9EYE+WBjjDXp3fP0KljB9PG915EAPXl0fi//XY3Cw44bNgQu81JEEFuh6V+tqoCKI0CY6GQ22rNos/vn7eq5fMQVaNGr5kMT2AMoI8B5RYZ40LZR8jtehoh5kH2JReOCqDp1CWAojfADJ+4/bab4zHr3NLmQsLLc6YCKOMAkfrmwQfvt69/QupCQmLqtl1MAPUGjHGArPe+e+8yGTfINjBOEO+687bw3HNPheeerZAAWlCwMqoHHzRfiMI29SBf9YXJ/XSlWtcA6oGNMZZLly6OO0S8TVu0aIHJMDXmp41FjmfnTh2tnkBfngdQbttTB/ot+l3RRVJVgZLvpkVuqTO0yOsrLrKqnP/j8sXyCarNozoHaYupf/2h3qYpwwJk7b2iAij6+xkgTcXoOyC5Q7xwcdWENLYeGpCrbQZS+5goGm9e9xPM5+V9/l5fDhI6/Glf9OXak8CRbCMnhS+P//Oav595WS8nhss8vhymUaH7+znheL+vj7+Z7idg6jZcqdY1gPrT3sj+p4z430yjRzpZfr38MC+vp5ZHjpE3+EgZ8+m8h16b1AqU1z0w8P4LLY8reK9wvez4Q0Q7dmxL+2x+Pvh7d0fz8Lcvn3OJp6X981a1fF738kh55UEA//xMI9h6QOY1Xy9uiMIo60nuv3wyFwOoS5mhPPn30vrykvVf6t8cB+8xRab78WUeyquXF5bF3368+ZtleCCtqjH3dXhdmLo8Xtu589z31bLu9evXVirPfB8pln7cA+rl28uQ/01dyPL98yW35Uq1rgHUj9f27VvT6kOOhdcTmGxvKUOUx9Tygox7R8Z8crx9zD3TOI6+PJaRWqaYh/o3tT680PycB162eW3fvj12UYz+mqybfjyumAAq5fmsawCVsjpzOYBKWZV1DaCZduiQweayZeeGrcn8VQFUyo9VAJXZVAFU5psKoDKbKoBK+bEKoDKbKoDKfDPXAqi8vFQAlfJjFUBlNlUAlfmmAqjMpgqgUn6sAqjMpgqgMt9UAJXZVAFUyo9VAJXZVAFU5psKoDKbKoBK+bEKoDKbKoDKfFMBVGZTBVB5Rbt7N7/+siOsKSsKBQULQ2HhIpO/9+yu+K5LKTOhAqjMF6n7qAMLCxZ97EL7m+/6xeT8UtZGBVB5RetfVL1k8cywYP6U2CVL+NWXc1+ALGVdVQCV+SJ1H3Vgap24NPrb68vk/FLWRgVQeUWrACrrSwVQmS8qgMr6UAFUysj161enVbaMe0rOI2VdVACV+STjPlPrxA3rSyvNI2VdVACVsrziN9kXL5oRli2dbR44UPF76lJmSgVQmU/u37/Pej1x8eKZab/JLmUmVACtZw8dOmju2rU9rFu3KpSWFlS4eqW8xBI8ly+bayanyUtgdF7QM408KMZ5kzyf8kkF0PPrdeL6datN1Ym54fJlc8xlS+dUmiYvgR/nhfVRdti9e3ucJ5LnU76oAFrPKoDmrgqgOaYC6AVRAJXZVAE0x1QAvWgUQBNyC8ML0soV88OGDWVh+7bN5o4dW+Qldvv26Di4VUyX9eu2bZts3BmuWD4vlJUVhYMHD5jJcysfVACtLHWi1YtRo7pyxTyrE71eTJYHWf9SJ7rJabL+9bzAObIiyhClq7lQK8jbB2YVQOtJrlKKi5fad6lhvhYYKS+FhE4u3FavqjAfr/oVQNPlGK5atdwsLS3M2wsLKS+FZIiyskKzpGRZXtaJCqD15JbN66NCsjyve3CkvJRy3hQXLTW3bt1YaXquqwCa7pYtG0JJ8TJTdaKUNdfzRL7WiQqg9aQCqJR1UwG0MgqgUl65KoCeHwXQcm4zHTBXrlwQ9u7ZVWm6lPLi5UEVLCpcXGlarqsAmi4/8bh71w4zOU1KefHu2bMzFKxcmHcPJSmAZln/5QgeosingiFlLpp6PiWn5boKoOlyDPm+XX3nrpR1k2yxPDqf+O5WTE7PVRVAs6w3mFydJKdJKWsmA+9RAbSCfA+gGpIkZWYsWLkg734qVQE0yyqASpk5FUDTUQCVUqICaDoKoOUpAbRAAVTKuhoH0BUKoKAAKqVEOrkUQM+hAFquAJqrMk4mE432nj27Tf1Ocv2oAJqOAqjMhtSP1GvJh1r87927d+m45ZgKoOkogJYrgNbE1atXhRdeeMHcvn17pemZtEePHuGpp56s9HpNveeeu83hw4dVmnYxenmeM2e2VfrJ6TJdBdB0FEBldRYWFphPP/1UpWnVOXLkiHDHHXdUCqA7dmw3r7vuurB06ZJK75OXTgXQdBRAyxVAa6ICqALohVQATUcBVFanAuiVowJoOgqg5QqgNXHBgvnh85//vLlx44ZK07kltHjxInPr1i322qpVJSaVIn/v3LnDJMzy95Ytm81FixamlZtWrVqFm2++qdI61q9fZ1K5Jhv1kpLi6DiuNL1Svvban5u9e/eyv7dv32YuXLgw7Nq1M+39qdu/YcN6e23+/Hnmpz71qTB79iy7tYXJ7ZIVKoCmowAqq3PatGnmZz/72UrTcNeuXebChQus3vLX+/XrG37yk59YPYzLl1f81KPXb1/5ylfCrFmzonpyqclrXEBTR6KXx82bN5vr1q2ttG6ZWRVA01EALVcArYnVBdBNmzZahXjVVVeZ3/nOd2x+74Fs1Oh1m69Zs2bmI488EmbMmBG+9a1vmddcc3X49a+viyvUqgLoxIkTw9e+9jXz+9//fvjjH6+PA2GrVm+Gb3zjG9Hr3zOff/45q5BTAyihlffh1VdfbdtLEEa2/2c/+2k8/Qtf+EIYM2ZMuOOO281PfOIT4dvf/lb0mRaYyX0jK1QATUcBVFZndQGUC/cf/ega87/+67/Cd7/73fgCmQBKPXzddb8yv/rVr4ZXXnk5vqAngP7mN7+x9+G3v/1tC57Uezhs2FCrH2+99VazXbu3Kq1fZlYF0HQUQMsVQGtidQG0SZPGUQX5nTBw4Dvm7bffFgXEP4ahQ4ea//Ef/2FX4D/84Q/NsWPHhl/96lfhtttuNYcMGWxBlCBZYeUA2qRJk+i9PzDHjx9v6ykuLjI//elPhdatW4UuXbqY9FgWFhamBdA777zTKmUcPHhwFDh/ZkEV2f4bbvhjfMJNmDAhTJo00XoG8DOf+UylzywrqwCajgKorM7qAuizzz5rdRZSdz733HN22x0JoF/+8pfC+vXrTe76/MM//ENYsmSxSQDt2rVrXJ/dcMMN4eWXXw6vv97QvPvuuy3gMh/6HSmZPRVA01EALVcArYkKoAqgF1IBNB0FUFmdCqBXjgqg6SiAliuA1sTqAuijjz5it6490GGbNq3D5s2bTCq5t99+224jIbfNCaVUjOjvIYhiVQGUcZlPPvmkyW2lr3/9a2Hq1CnmX//1X0cV9jNp66dSTg2g1157rQ3OR5+nV6+eJtv/9NNPV/rMCqA1UwE0HQVQWZ3VBVAu4hs2bGjyd5cuncMvfnGtSQD9wQ+uittbvmbu7//+721YE1LfTps2NV7WM888HR588IHovFxu/tu//Vto1qxpuOuuu8zkumXmVQBNRwG0XAG0JhJAqSixcePGFjA7d+5kUiHSgzly5EizQYMG0RX3S/FTmoTDz33uc+HVV181WR5Pfv75z3826dFkLNKgQQPNqgIoFfHDDz9sso5Pf/rTtk3IGKeWLVuGgQMHmr/85S/DmjVr0gIoFS6v47hx48L9999vlToSehlb2rdvH/P3v/9daNGiuY0NxX/5l3+xz+sVeHLfyAoVQNNRAJXV6QH0k5/8pNUvbseOHUP37t3iMfIDBvQP11xzTXjjjSYm9S11EmM3kbqWcaA+pp0Aes8994Q+ffqYX/3qV6wO9N8ipw787Gf/yUJqalCV2VMBNB0F0HIF0JpIxfbIIw+bf/nLX0xCJG7btjW8/Xb3cMstt5iPP/54Wo8hT2kyv98y5zXew63vitvfN4Q332wZP1REQOzUqWPa+jds2BCefPIJ8/rrr7db8N5Asny2ywPtqFEj7T0sE2fNmmlPvfst/htvvNFuRflToyyjW7euFnqR213+OnLL/qGHHgoTJow3k/tGVqgAmo4CqKzOgoIC0+tTl6+go8x06NDBvOWWm6ML7Bbxt4jwjRxcOHsPKfUZdZzXny+99GJUB46KLupvMRs1amTB09fLcCWGQulbPepPBdB0FEDLFUBrogKoAuiFVABNRwFUVqcC6JWjAmg6CqDlCqBSZlIF0HQUQGUu6bfgf//734euXbtUmi6zpwJoOldcAN27Z1coKlxsbtu2KRyKKlYFUCkzpwJoOgqgMpf071lmfCg9qcnpMnsqgKaTFwHUH2LxirAu7tm9IyxcMNVcMH9KKCxYFDZvXm+uXKkvF5eyriqApqMAKqVEBdB0FEAVQKXMqAqg6SiASilRATSdvAigpasLzGVL50QV4vw6uXzZnLBg3pQK56fLtOS6pZQ1UwE0HQVQKSUqgKaTVwF0+/bNlXo0a+pu6wGdZi5aOC2sXrXClovqAZWy7iqApqMAKqVEBdB08iqA7tixpdK0mrp37+5QVlZoEkZ5TQ8hSZk5FUDTUQCVUqICaDoKoOUKoFJmUgXQdBRApZSoAJrOFRdAqzJXAyi/7Vub/bhnz26zNo0G3w+XPH6Z/KJitomLAExOuxjZDn8oLTktWx44sM+s1bGItre6Bnz37p3RZzlgJqflqwqg6SiAXj5eivrnfFJXX6hM8cMbF9pen56pOl6eXwXQdBRAy3M3gC5fviwMHz600usXsnu3ria/X56cdiEXLJgXxo8fa/prb77ZwkzOWxvLykpD3769zeS0i7F9u7ZWqWJyWrZcvHiROWb0qErTLmSXLh3t154wOQ35PDt2bDeT0/JVBdB0FEAvH1u3ftOCX+ovCtVUfq0Ik6/X1GXLllywfWgTba93SCSnuX6B3bpVy0rTLuSqVcVh8uSJ5vr160Kzpk3CW21bm126dIpeW1vpPVeyCqDpKICW524AXbp0SRg06J34CnXJksVh2NAhdqIj82zevCmMHDncnDNnts3XsUM7ky8bXr26JBQWFpg0IpMnTwpjx442/eq4YOUKk8pswoRxYfTokaZvR5PGr5v8f8uWzWHEiGHmvLlz7DgvmD/PZFn02i5cuMCsan2lpavD2293M5l/fvS+sWNGmTt2bEv7/PwM5qhRI8KiRQtN5m/ZolmYOnWySSBM7ZEoKFgZhg4dbOtA9k1xcaFtE06fNtW2yb+Iuaxsta3H388+GhHtg3Xr1pi+HQsWzDeHDxtq8y1atMAcNmyIhXx/P/9nnvnz55qs6623Wts+w5KScz9B6vI5/ATn83IcZ82cYbLNFT9JOsacNGmCLdN/OpQGiOO0cOF8k21IXfalUgE0HQXQy8cmTV6P65/x48ZaEK2ufuani0dGdSVSJ61YsTw88fgjJqEtddksgw6AEcOHmZs3b7Q6YGm0XJw5Y7pdwPv8hLslSxbFx4e6dHj0Pq9vmGfypInxBfvy5Uutfp8W1YPIspnHA+gb0WfjM1DnIhfFLH939F5k3uXLlsY/BcrfS5cuDv379TFXrSoJHdq/FU+nDiSEJvfhlawCaDoKoOUKoAqgCqCZVAE0HQXQy0cFUAXQuqgAmo4CaHnuB9BFUZhDwgyVzBtNGpk7ohDy2qsvh9mzZ5o9e3S3CsEDKJVH82ZvxIHlnQH9LCDNmDHNpLKgUmz6RmOTkNe8WZPzBlAqOSrguVHQxV69eoSZM6fbbR6kwlwehaKBAweY51ufB9DVUYXVps2bUXCeZSZvJ7Vu3dKCld+y37hhfXjl5RetUkUqyT59eobiokKzZctmtp/88xD42rRuFYXJteb9990dNajLbJtw5crlth6vMHv1fNuC5htvNDI90KUGUEJ3x47tTRoL9gvBExs2fNUq3R7RZ0MqfI7Z4mi/YovmTSuNs2rVqkXcYNAAzJk9K67QuaDgONJoIKG/b59eFqrx1VdeshDKbS9MbZwupQqg6SiAXj4+8/STUZ03wxwQ1W+jogvG89XPO6MA1/C1V6wexu7duoQ1a8rCs888ZfJa6rKpA6lXvH5t9PprNkb8uWefMrlI37btXBtIXT9o0IAoTE4xu3XtHObOnR2aNm1sUt6oF/yCu8ELz1k91LlTB5O6huV4AG3Q4LkwJloHF7rIcAOGYvnfjFOnDku9pZ8MoNRJE8aPM1nHyBHDK+3DK1kF0HQUQMtzP4D2i8IXLouuPnm9d++epoW/Nq3iK3BvKHwMzlNPPW5X4v76Sy+9EJo1qwgr+NKLL4RJE8fHFQbLnjZ1ynkDKCHr/vvusVCLjRq9ZhXP9Kjyw3FjR1uIKy1dZVa1vtQAumvXjtA22v727dua9Cqmfn62hXFJ/vkJifSAemCkUuV93sNAo8D76JlEKmPeP2rkCJPeRUJzp6iSR38Qyk+wwYMG2vIff/wRs6oA2r171zgAMq1rdIXvFwCERV7z/Y2s/7lnnzbXrj3Xq+oSQH1/UeGnvp8eitejRsjHnLE9jV5/NRQWrjTZ18zfLzoG6IH6UqsAmo4C6OXjG9GFrbdvBQUr7ILwfPUzvZ28Th2H1Kmcw42jehOTy+4UBTbqR6/PqdsYY9k0uhjG5B0OD6DUQcjdLltOxw4mF6SpAZS2gukeWMePG2N/ewAlLKe2I/zNXaS2UVuC9I4OGTKo0jakBtDGjRpGdeEsk2neyyorVABNRwG0PPcDqN+C5WqUIEJFgtzeIQR6AaEC4grbe0BHjxppV9R+POilXLu2LP6b3jxCH6EMqXSoSM4XQFkHFaevj0qNSth7WAlbhCiv0KpaX2oAJcRx25tKtqKibWzr81vmU6ZMsltHXsFzW/rNls3jW0oEYippD4D0uvI+r5BZNg0BvbZI7+PrUYDr1rWL6Z+Ph72wa9fOYevWLeH5558xvdFNDaAEXbYLWVeLKLAWFRWazZu/Ya+VlBSb3ManV8QDMo1CsiEngG6ILhKQXhP2E8cQfZ/QCOCGDetCqzdbROsqMHtHx4xl9O/f11QArbsKoOkqgKbbNAp0fkHIRSAB9Hz1M3XAjOnT4ocQX2/4ivWKchGJflHpyx4yeKB1Knj92rhxQ6uPWkT1Cia3xQOo33GiDuR93kHAOlMDKCGS902fPtVMBlB6QJmPdSI9sEz39oT6iXo+uQ2pAZR6N3U69arX58ntvxJVAE1HAbRcAVQBVAE0kyqApqMAevmoAKoAWhcVQNNRAC3P3QBKBcZgdx9zw+3f1q0qxuX41yQxttLHYDLGkgrCxzhSifB+BrsjlYtVJh+PYZw6dYpVDD7GkrDEret58+aYvh19okoW+f+sWTOi97KMdrY+xlb6fFSCVKD+d1Xr27BhvY0zQm6jM0jdxyRRgaZ+fipJbpV3797F5CGlge/0j/cHFeywYYPj8sZnYD/456dyZ9A8Y7WQZQ6PPp8/JOTr8QDNNjJOywMdYziZ7g9x8RAAwbdbNA8yRpWHrPyWGZ+PEN6lc0eT7eOWlX/N0qSJE8LUKZPj+X2f+fessk283yt89hWhknGyFVaMZ+VWPvIQBMvwMVqE+9T9d6lUAE1HAfTykaEuHqjWrCkNEyeMq7Z+fmdAf7u1jpzrvEbwQ76CzR/mQeqALp07xPU59cm+fXvCgKguwuS2eADlWQDsHNU5rH9m1CYg8xAMPVAOHlxx+5xb6eh1vH8e6v6+fXvFX7u3eHFFe0idjh5gU6WNol5Dhnsx1Cl1euvoAts7DJLvvRJVAE1HAbQ8dwNoUkILFUVqgEFvIJJjhKoydYxP6mv+enL+qqzr+moy3ddzMevCqvbPxer7N/l6Ul9+VfPWdHuTVvV+3z/n20e5pgJoOgqgV4ZeJyTP35r0AF6oPkSfPiEKuakPbp6vTqqJVa2fdeCSxekPTV1IlkUQT+6PK1kF0HQUQMvzJ4BKmQ8qgKajACozqT+ESe/m9u1V/8BFpiQ48nV3mMk2/UpVATQdBdByBVApM6kCaDoKoDKTKoDmrwqg6SiAliuASplJFUDTUQCVUqICaDoKoOUpAXRl+vdQSilrro95I7wkp+W6CqDpKoBKmTkVQNNRAC0/F0CpbDVYWsr/z957f0dx5Hv//8A9d31373q9Dru21wnnnBMO612vvU7rDc7Yd21snG3AZJBAQkIICQFCQiRJ5CQyIijnnHMOJC/P9zzfc5/n3O9P9e33Z6hmukcSwpoZTc+865zXgemqjqPufk3Vp6rGhr6fKsrzPPICHQqolVAT0O7uTrPXuF7W1dUh2Gcx0+iJKTAsnj0v0MD3eLFOQZiBDXir57oetWOoYeIwAUoo/X1RQK2JAnqOAkqIN6GAWhMF1DlQQCmgvoQCak0U0HMXhtWpripSgwMXxmUjhFw6fX3dQm1NqUdeoEMBtRIMAqoHjh9qiCIsdz8/TBjx3bdfCRi7F8swli8oLSmWzzrERK+zf/9eAeMW27eP98pwwqEHotf7tx/fxYZvcm379IXtDfHOtb+Hk1avkgk8gHsZoKVUj0OMcZzt68t+zl9POXa5Di50vv365OXmCLi29m1hrnj362//Pty3N9K1cAoUUGuigLrR29upqquLPW4oQsjowEsCP+RAf7911hQnQAG14nQBzcnJktnEAGZDwwximDEOLF0arSIjFpoTUaA8JElPfAEJw3m7CygGZ8dsZGDe3NkyQ5m7gGYeOazS01IF1JhiYgnMRgQOHzqouro6zfUxsDtmjsMA9mDO7JlSi6qPD2Uw85yeaU2fU3JSooCZ2+bOnWVOtIHZkjCbkn7/YlKNxZGLZDY9gMk0Pvn4I5nPHmBmta1bN6lFi8IEzHSEweT13PXLYmPkuumJLlCLiRmW9ED1GPgeE4Xoue07OtqGvD7uAlpQkK9S1iQJuLZLY6JMIcYsd3qfANcKk4HozzNnTJdrpCf2sH/XToACak0UUBtNjZgWslzA9GQjNVUQQtwH5j+tampKVGtLveDEe4cCasXpArpg/lxTWDAz2cKFC8ypbKMWL/L4G4Uk6ZnSMOsRpiTebEgdgICiqR1SBCCABw7sMwU0OXm1zG6kZ0bC7EQQMi1wEEQImUxZbIB9Q7ogfQCzzO0w9o8ZlgBmcUuDXNpmQsI+AIQQ0xNrwcR3hKmG9cxqGDgeAo4pNgH2p2s2Acrg+ujaRUybjJnWIIEAMozQA328jY0NIpy6BnTWzB9kPcwuB7KyTgx5fbSAYpYniKkeRgrnErZgrnk8kGUsg0SD/LxcqbGtra0WMPPTUDNCOQkKqDVRQG1QQAm5NCigIycK6PhBAaWABhIUUGuigNrATdrR0SygE0VdbZlxczQJnZ2thBA32tsajZdDmYBxP7uMZVpI7feWE6CAWnG8gBqCo4UJ5wDhqqqqENamJHuUh4Dm5+cJKL9oUbgKD58vQEDXrU1Ra9euESBze/fuMQV09qwZIk76epWVlapIQ6q0oKGJGwKqBRL7w79YJk3VhvTu2L5V7d61U0ATN45x/boUQR+je4wmxA7SCpCHMIOmpkYhzNhfxp7d6vvvvhbsAoomboQA2K+B+/b7+npkPncAAUWzvj4/yCPKQ9JBVtbxIa+PFtCZM6aJpLvHc7oL6HJDbl3fwXYhNydbrmuEIe4g2pBgJ3T0GgkKqDVRQEcAN0lfb5fxcGgWtJiS8aO2pkR+FAB7HvE/nZ0tZqejYIibpoBacbqAItYwPT1VSElJElHTvdYvJqD43NbWqj6d/LEAAY2NjVEHD+wTII+IFc3I2C0cOXJIak21QGVmHpYavK1bNgkzDAGrra25qICuM+QN7Nq5XSWuWqFiDEkE+p16MQGtrCwXUNsIAZ36/bdCsyGlaakbzZhR1LpGRUVcEN6EeONHZNmYBHSo65OddULAuWFO+dSNqNXdIO/XiwnomjWrzRrevRl7VEODq2XFqT9wKaDWRAEljqKtrcGUH3seIWOFAmrF6QKKF31xcaGAZmGIy8mTA0KbIWD28hBB9yZi0NraLGBYIjTj52RnCahBrKmpNgUS02KiplU38eMdiCZ43YkIAocyEEGAbeNfXUOLMAFsB/sBOYaAQYAhrUD3eNfDGmH7eh2APNQQ6hrGysoKVWJIMzobgW7jeBEagKZ90NPdJfvRwo1jxPVx3z62g+MG+PttbWk2BVDXRuphqtCRa6jrozt54Rjxd6SvB84H29C+gH3q7wDg3GJjY9S+fRkCwhhmz55hXh/7d+cEKKDWRAEljoICSnwJBdQKBZQCSgH1HhRQa6KAEkdBASW+hAJqxekCSpwN4mbXpqwRNqWnqtWJq0xht5d1AhRQa6KAEkdBASW+hAJqhQJKxhPU2F7oNNXhWPHUUECtiQJKHAUFlPgSCqgVCigh3oMCak0UUOIoKKDEl1BArVBACfEeFFBrooASR0EBJb6EAmrFJaCcmpgQb1BRnk8BdUsUUOIoKKDEl1BArTjxhUlIIIJWhPKyPMtA/E6AAkoBJeehgBJfQgG1gucuZrcC5845c/BvQsYTPWxVV1er3E/2/ECHAkoBJeehgBJfQgG1QgElZGxQQIdPFFDiKCigxJdQQK2cOjUozYZgYKDXI58QMjK4b0B5WY7hRU58BlBAKaBEoIASX0IB9aS3t0soM16gHe2YIeek8K9/sWc8IXZwXwDcI+3G/YKOfAD3kL2sE6CAUkDJeSigxJdQQIcH01fW11WokuIsAbWiGFaGjDf5btjziL/RLQa4RxrqK4z7pl+w309OgQJKASXnoYASX0IBHR4KaKBCAQ0kKKCjTxRQEvDoGJqmxmpVWVmgqioLBXweHHTujU0CDwroxdGdKjAton7Wk/GjpaX+PHUeecT/6LnqcY/Y7x0nQgGlgIY0OuasuOi4ys87bFJUeMxR46mRwIcCSpwG4gxdNHrkETJWKKAU0JBG17i0NNdaBLTV+MVvL0vIWKCAEqdBASW+hAJKAQ1pKKDEX1BAidOggBJfQgGlgBKDs2dPS7N7cfEJgdMDEm9DASVOgwJKfAkF1M8CqmvcTp0akN7WqHkDzWTcKSvNUWVluYI9j/gf3BednS0CBi2330tOgwJKnAYFlPgSCqgfBRQDyDY31Qhlpdnyb2dHi9DV1UbGnVY37HnE3+C+wGgEoNT4cdDaWm/+gLPfW06AAkqcBgWU+BIKKAWUmFBAAwkK6MUTBZT4Egoo8SUUUD8JKF6adXXlqrGhSvjxRw7xQ8ho+fHsGdf901glOFFCKaDEaVBAiS+hgPpJQFGjU1dbZojnWcGeTwgZGdw3NdUlQk9Ph0d+oEMBJU6DAkp8CQXUxwKqmwwxuw6mm7PnE0JGT39/j1BbU+KRF+hQQInToIASX0IBpYAS4hgooNZEASW+hAJKfAkF1McCquduxTzj9jxCyKVh3k8VzrufKKDEaVBAiS+hgPpcQE8JFFBCxg4674Hy8lyPvECHAkqcBgWU+BIKKAWUEMdAAbUmCijxBQgXQytDSUmWCT4PDvYJ9vKE/BQooBRQQhwDBdSaKKDEF1BAiT+ggFJAHYXu1NXb26POnh3bWKqIJcR2gD3PG3R3d3HYLS9DAbUmCijxFXhn5ecdNqmsyOfzjHgVCigFNCCpqqpUr732msmbb76pli1bpjo7O4Qnn3xCFRSM7ZpmZWWpxx9/XLDneYNbbrlF1dXVCvY88tOggFoTBZT4it7eTkM8j5znsCPH3iWBDQWUAhqQ5ObmqquuukqtWLFCWLlyhbriiivUjh3bhTvuuF3l5OSYNaKVlRXG52ypFQVtba2yTOeD4uIi43vuFbCPo0ePqltvvVXAZ5QpLS0RsrOz5HNHR7tQXl4mZXQNQFlZqfFA7jF7ZZ84cVxVV7tm6NGz9Pznf/6nqqmpFvAZx4X1QH9/n7H/TNXV1SnYz58MDQXUmiigxFfgOVZRke+iPM98rhHiLSigFNCAhAJKhoICak0UUOIrKKDE11BAKaABCQT02muvVfn5eQIEEJ/XrVsraAFdvTpRmDDhFvXII4+ot99+W8jMPCJN4IjDBDU1Neq6665Tra0tAvZhF9BZs2aqu+++W5g4caL64IMPVFbWCQEyDHFtbGwQrrvuWmlaf/XVV4Unn3xS3X//fSo2NlbA9uwCCum8/fbbhT/84QX12GOPmfujhI4OCqg1UUCJrxjo7zHEE/KZb9xveWpgoNfyA5uQsUIBpYAGJBDQf//3f1e33XabCUSvoaFe0AJaVFQoQEpnzpyhfve73wmoAb3rrrvU/v37hDlz5qjJkz+xPEDdBRSS+vOf/1xNnz5dWLo0RgQSZcDTTz+tNm7cqBITE4W//OUNtX37dnXNNdcI0dHR6uuvv1Y333yz0NPTPaSA3njjjcLevRmyz5tuuklAjav9GhBPKKDWRAEl3gLPRUgmqK0tU1WVRRL3CXoNMJtfbW2pADmliJKxQgGlgAYkENDrr79emrUBagjRhK17rWsB/fjjfwp/+tOf1NSpU2Ud0NLSrObOnasmTZok3HvvvSovzyot7gLa1NQoAjp37hwBQgn0/pcti1V//eub6qWXXhLS09PV2rUppkDq8vHxcQKOcSgBnTBhgoBaXfwd68+oZbVfA+IJBdSaKKDEG5w82a9qa0pVZUWh0NPd7iGY+KyFFO8zTIerhdW+PUJGAwWUAhqQUEDJUFBArYkCSrwBBZSMBxRQCmhAAgG94YYbzGGX9HK7gGI4JvDdd98KV155pbBnz25VWloqsZsAMZ32fdhjQBHH+eWXXworV65UDz74oCmgOAZsV4cD4Bhqa2vM9aOiotTMmTPVn//8sjA4OEAB9QEUUGuigJKfysAAnmGuJnW8n3p7Oi8pxhPDNFUZ64Hq6mKzWX606xNCAaWABiRNTU1q8eJI4yHZL+jlJ08OCjExS6TWMi8vT/j222/U+vXrVGpqqnDgwH6pMX3ggfuF5ORkj33U19epJUuiBXxG56KFC8OFzz77THq2uz9QIaWIAwV6GxBlMG3aNKmBdR/3c/78eZZe7rjRdE1pc3OTHJ/+jH3bj494QgG1JgooGS3uMZ51iPGsKjRrNH/q4PJ6VBCR0aoiqRUF/YwRJaOAAkoBDVpQy3jXXXcK7GUeHFBArYkCSkbDyUFXEzs6EoGeHs8m9rGC7UFEXTWjhWyiJxeFAkoBDVp27tyh1q1bJ9jziDOhgFoTBZQMh6s3+09vYh8L2Edfb5fUsoIaNNEPsImeWKGAUkCDFgpo8EEBtSYKKBkOCigJdCigFFBCHAMF1JoooEQDsRs0pBPU1SHG88I4nj81xnOs6BhRyGi1xIiWChxHlAAKKAWUEMdAAbUmCigBMoxSrXuMZ0fACZ41RtQlo4wRDW0ooBRQQhwDBdSaKKChi56xyDVrUaEhdl2OaeJ2ySia6IuEmvMdlpxy/MQ7UEApoIQ4BgqoNVFAQxcKKHE6FFAKKCGOgQJqTRTQ0EFiPAf7hLq6compRMciMF4xnmPFI0b0vFBrGbWXJ8EFBZQCOmrwoLAPDD8SKOft78tbnD7t+sO3LyeBDQXUmiigoQFiPF2Dx7tqDAMxxnOsWGJERUZLTeG2lyXBAQWUAjpqMJj7smUxgj0P1NZWGw+OSgGfN21KV2VlpYK97Hhz7Fim2r9/r8dyEthQQK2JAhq8DA66erNLj/bKQqklDJUmat1Ej1pRV81oqfTuD5XzDxUooBTQUUMBJeMNBdSaKKDBCwWUAhrsUEBDSEArKsrUhvVrXWxYp44fP2rc5D3Cpk1patvWzaq/v0/ATX740AGVmrpBaGlpHlFAUX5x5CIVsShcqKysULm5OaqtrUXIzjqhjh3NVFs2pwuVleVq48Z18i/ANqqrK83jO3r0sLHNs6q4uFDIzj6hDhzYZ9knxBbnAQoL82XZ8ePHhMwjh+S4Ozs7BBzfiePH1cYN64UtWzZ5CGi1Ic6pGzcI+fkuwamurhLWr1sr1+PMmdNCd3eXSjO2v2PHNmFwcEA1NtarPOOcQXraRglZyMo6LqxflyLX3/0B6p6/du0aSz6WHZFzWC+0t7VajrW7u1Olp6eqA/v3CTgmnOemTanC1q2b5HusKC8TcnOy1e7dO8z75+CB/XLdGhvqhWGvf1GhcMK4pihfV1sjuB+LP6GAWhMFNHjAfa+bnOuDJMZzrPzLOG+A93N1VbGEIQDGiAYHFNAQEtAF8+eoqqoKYe7cWSKJcXGxwokTx9QhQ7CSkhKFjvZ2Q2I2q7y8XGF5fOxFBRTSpYUQgrZx43qRKrA0JlqkSgtofPwyQyLKjGOaK0DgFiyYZx5fcvJqVVCQp1avXiVA4Jqbmyz73Gjsp8aQQzBn9gw5hjBjGyA7O0sdOXxQrTG2A2pqqtXixREimWDx4kUeArpoYZiqMq4JgBD29HQbxzRXwLWC0OJfgPWLDDHbty9DWGccH67hwoULBJQpKS5SK1YsF+rqamSdLkMSAfZXbOQvN64DwDmEh883JLJdCAubL9II8QMrjW24H2viqgT5Xvbs3iXU1dWqJdGRIuoA8gox3bwpXViRsFw1NNSJxAOcC4QzIiJccJ2r5/VPMq492LVzhyotLZFrBOzfv7+ggFoTBTQ4OHlyQMRK1/gFY4znWMH10DGiuEa4XoOD/YK97HihKyjOnj1jWY4fECdPDnqUD3UooCEkoAvDF0hNIQg3BAc1ZPPmzhZwc+OmmTdvtgAhSUiIN0RonjDfkNeRBBSI9JwXHHx2F9AYQ0CxTb1/1NJhn/ONfQHUgk757BOzBhUSCUF0F0j3feGGRg0kpA5M+uA9WRYZuUhABygI64oV8cKePbvU0cwj5vqQbbuA4rPe3tqUZFVWVqJS1iQLyHc9AF01xpERC2WZ/rw4cqEIKPYDkLfZEO3p078XcE6QfpyHPhfUOqOmVde2bpbPecL8eXNkf7oGd1ms9ZrjmkYZQh1v/DAA7e1tso5+AOqa1E3paQJqkbFe3LKlwpzZM+WY8HcAUBt+seuP66uF3P1Y/AkF1JoooM5F92YH6HQTSk3sYwXXSPecN5voB10td+Nx/QYG+uQ5Hx8XK/wwfarq6Gg3W/jmGc9mVEzs3LldsK8fqlBAKaAU0PNQQEe+/hTQsUEBJe5QQH86FNDggAIaIgIKeUATL2IfAZpTcaNGRUUIaCIuLy815CRWgHyg2bW8rFSAPEFytIB2dXVIefd9QGK2GtsGaG6wCyhEraioQNi8OU3WQVgAQB4EWQsd5A/N0ilrkoRaW9whpGyRIUo4JvD1V59LMz6a2QH+j7hVLaBoDl+1aoWx7W4h0fi/u4Di+mzfvlXOC0RHR0oTOeJaAUIK8vJypBkb4GGC2NaiwgIBTeIQ0IyM3QK2iaZwhAkACPHRo5nm+SE/K+uEGbLQZyxbEr1YpBkgLEGfp7uA6gfs7l075QfBzh3bBOwz0pBgNMWD+vpaVViQbzbBl5QUyfo6ZnX//n3y0Dx8+KDQ0dF20euP/VJAfzoU0NAG948Z41lfYdxfxUo3KYdqjOdYscSIGtdTC/3ggEtG7eV9BZ6lC433q34+79q1Q/oiaCGtr6+TCh6UAShv30YoQgENEQGFkE2f9r1aunSJAMFBjWBjY4OwyhCo1YmrVFtri4Bfb4mJK6UWD0BaIal79+4R0OEGnVXc9zHQ32cKC2QLN2BLS5OAWkEcgxa4nJwTsg46ywD8H8KmYw4RU4ka2szMwwIk031feGBD7NYY+wL79u1R+Xm5cuMD/FFDGnWNLB4KW7ZsFgkFqAHVUqZBDW5ycqKwbdsWYx8/GseZJaA2GHGTehxUSN7KlcvNGkJIImIntWBje6iJ1MeDuFoIva6h1PmQXpCwPE7OE+cFEH+LMn19vcLejD2WY8Wv6mRjmxs2oEPZWqldxkMOYg1Wr14pAp6TnSXg+8J6+A4AOjDhmA4fOijg+lzs+qMMjksf23hAAbUmCqgzYIyn78H1tMaIlsv4qcBe1ttAKKOjIszPeEceO3ZUKg6A7kSqKzR0JUSoQwENEQE9btwM6w1hbGluEjAM0bq1a8x8/cvNfR29zL4coGd4w/ne095kpH3auZSyoy0/XJmRltmXX0qZi+WPxFDrDrVsKIYrM9r1xwsKqDVRQAMX3Ztd92jHOyaQ761gAtfYVStaJGAoK1820Q8noLoCY8mSxdKxU1eY+OIYnAgFlAIqDHVjjiQjFNDhy15KmYvlj8RQ6w61bCiGKzPa9ccLCqg1UUADFwro+IFrTAENfCigISKg+JJ3795pxoAeOnhAmmLt5QgJZCig1kQBDRwgFScH+wV7jCfG1LWXJ74H1x3g/Y7vA98L0DJqL/9TQdgUQr70Z4RpoR+EFl6EMCEu3z0Ei1BAQ0ZACQkGKKDWRAENDE6dGpBatprqIsElnd4THMR4HzlyRBUU5AvB+H0nJSXJ+MkAn9HKpicW8UbMJL6PCzGixVIz7a8YUTI0FFAKKCGOgQJqTRTQ8cPVm71ccDWxd3u9iTc1daPwm9/8Rj300IPq+uuvF+6++27VZpsdbbzZs2e3+vDDDwV73mh45JFH1NatW4Tk5CR14403qt///vfCrbfe6tERdSxcaKIvFkRGB/u9/v2RkaGAUkAJcQwUUGuigI4fFFArFFByqVBAfS6grpiPivI84zP/sAkZC9b7yTM/kKGAOhv3GM8GifEsUb29XYIvYjwhmBMmTBBWrlwhMYUYag28/vrrau3aFHNYtcjICPXiiy+qqKgowRXzv0stWRItfPbZp+rNN9+U8Z8Bhnb7/PMpKjo6Snj55ZfVunVrTQFDB9MPPvhAvfHGG8KBA/vlmPS4xN9995166aWXjP1GCpDDxx57TF199dXChx9Oku1kZGQIr732qvr4438a220QsK3Dhw+pV199VZg1a5Z64IEH1JYtW4Q1a9aYTe/g7rvvUjt37vC4RmPlQoxot8SI4nsFmN6TIup7KKA+FlB9Q1dVFspYcPZ8Qsjo6e/vEfDyt+cFOhRQ54IYz3qJ8Sw2Oxf5WlAgXLrGE8JozwcxMUuEp556Su3du1c9+eSTQlxcnHDzzTcLW7duVX/965vq3XffFTCJxc9+9jMVHh4mxMfHq+uuu84cF/r5559XM2fOMIXw5ptvMpY3mjWc77zztgguygHI4owZP6h7771XgFyWlZWZAp2Wlqrmzp0rkgwgldhfTEyMAPm97LLLzBpQnBvGop40aZKAbfi6xhffp/5BYdaKGu9svrd9BwXUxwKq6e5uVzU1JdJbjrNeEHLpoOldN5lBAOz5gQ4F1HmgZgwUFR0XITl79rRgL+cLDhw4IJIGIGPueRBS1Hz++c8vC0uXxsjyqKjFwuuvvyYC+sorrwjIS0xMNAUQAnrFFVeYM6+h1/Yvf/lLlZ2dJfzqV79Sjz76qCm0t912m4ihFtpDhw7KNvX7DPK2YcN6NXHiRAF5aEa//PLLBQjyY489qh588EFhx47tIpXoOQ6w/j333GMR0MLCAvXss88KmFTDfn18CWYtwvddWHBUKC3NMYQ6N6QpKc5SjQ1Vgv16/VQooBRQQhwBBdQzUUB9CwWUAkoBdUEBdbCAuuJqKlVTY7WAP3B7GUKIFR3CIi+E+grV3FQr+Lr50xdQQJ2H/vs7dWrQePFWqoqKfKGzo1l+ENnLexMMvYS4SIDmbcRZ5ufnCZC49evXqU8++USYPHmyNGt/9NGHwueffy4CqmMssb3Vq1dbBPTXv/61iB2AzEJAi4uLhFtuuUVCADDlMEhIWC7DIj355BNCfHycbGPJkiUChk7auHGjSCvAsWdk7FG33367UFVVKcNHLV8eL5SXl6krr7zSHFYKEnzVVVdZBBSxrhs2bBDs18YX4BmD7xVUlOeLaOkmeC3aoUx3dwcF1KkCCvAltrTUCeXleSKiHcYfO+jsbCGEuNHR3mQ+8MqNX+BtbQ3SYcAXHT78AQXU+ZwyZAQ0NVbJM1w/v/Fst5f1Blo40QP+mmuuUb/4xS+Et956S2otIXLg/vvvl57iDz30kAAh/CkCis5HIDk5WWo9USsJ0OEIgrt3b4YAQQV/+MMLAjomlZWVmuVvueVmkU4dM3rXXXfJ9ubPny/gen366afSux888cQT6rnnnrMI6LZtW2U9YL8u3kLLVWdHi4ysgUoigJhfe9lQB7GxFFAHCyi4UKNz2ngItKrWlnpBiykZP6qqMIi0q5OBPY/4H9wXXV1tAmonnFjr6Q4FNHjA3+Lp0ycv/EAyZBQ1Z/g79Wbrln5fQJLQDI9aUKDvBfcWAkig+/7da6/0Z52v19HrD/UZve61oOpt6DyMRIHl7jP76OPU+3HfFuQVx6c/6+PR28c7HZ/d8/UxefN6alB7jR8O+N4ApBPfp/v+iRUKKAWU+BAKaGBBAb14ooCOD/hbpIBSQEMJCmgQCCgJXNDEq5vU7HmEjBUKaPChhUXHiFZW5At4hvhCnMhPRyR9mBhPSufFoYBSQIkPoYASX0IBDX4QOwgaESNalqc62psFXYNI/IuukUVMOeLIGeP506GAUkCJD6GAEl9CAQ0dUKNmaaI35EfXirJm1PdIE3s7ajrzBNROs4l9bFBAKaDEh1BAiS+hgIYOFNDxhQLqfSigFFDiQyigxJdQQEMPa4xolTmOqDTLU0S9CsS+o6NFwDVGGIQOiaB0jh0KKAWU+BAKKPElFFBijRHNZYzoGDFjPI1nNq6nFiTGeHofCigFlPgQCijxJRRQojGb6A0RFRk9P6g9m+hHh6u209WbHTQYUsQmdt9CAaWAEh9CASW+hAJKNBTQsUEB9T8UUAoo8SEUUOJLKKDEjiVG1BBRLVSYhpYiakVLpxZPxnj6FwooBZT4EAoo8SUUUHIxIKKgqbH6fM/5JiFUY0R1jCc6FqGWmDGe4wcFlAJKvEx/f7dQkJ+p8vMOmxTkH5EZMuzlCfmpUEDJaNFN9BBRl4y6BrXHFM7AXj7YkNrO9iY5b8CpMscfCigFlHgZCijxFxRQMloooBTQQIMCSgElXuZf/zorVFcVWQS0trbUoywhY4ECSi4VS4xow4UY0fYgjBG1xni6mtsZ4xk4UEApoMRH9PV1mzWfoL+/x6MMIWOBAkrGij1GFCIKnBojeiHGk+N4BjoUUAoo8RH4hV1ZWahqqksE/uIm3oYCSryFbqJvNEQU6EHtnTKM04Um9lyBwygFPhRQCijxERRQ4msooMRbUECJv6GAUkCJl9FB/XgYlpZkq7KyHAFNQj/+GPgPcuIcKKDE2zgpRpTjeDobCigFlHgJxB3hIY2x5WR8uUbXL3D0fAf4RY7el5hjGDg1xooEDhRQ4muGjxEdHxkdPsZz0KMsCWwooBRQMgZ0s49u+mlqqhbp1E0/7mWlict4SEJERUbLIaMtjmniIoEHBZT4C91Ef2EYJzTRo1bUP8M44Rlp+YHPJnbHQwGlgJIxQAEl4wkFlPgLCijxNhRQCii5RMwYTzPuyBW0P9omoAsxVgPyd1JZkS9ARserWYs4Ewoo8Tf6+XX6tKtZHuNrgvb2Rq+LqGeMJ56zjPEMFiigFFAySswYz/Mzaehf4PZyl8qFGNFKs1bUJaOMESUjQwEl4w1EVGS0qcYrMaJYD2C+eonxbKw637lodD/wiXOggFJAyYsxoNYAAFZ3SURBVAhYmtgNOcQv/uGa2MeKq1YUTfSVAmoVOjvZRE+GhwJKAgU8v86gid4Q0Qsy2qjOnDkt2MvbMZvYzw+jpDtxsok9eKGAUkDJCFBASSBDASWBAgWUXCoUUAoosaFjPDFUUkUFhlPSMZ7+mcrNjBFFs3x9xYUY0U7GiBIrFFASaHjGiJ4fR7TNFSPqLpT4rJvsZa52xniGFBRQCig5j4wt59HLcvzjjuwxol2GiALGiBIKKAl0MPIHaD5fK9rW2uDCEFIZOeR8r3rGeIYeFFAKaEhj7WXp+gXuqyb2sWI20ddXCK4m+lYzaN9engQ/FFDiFHQTfW1NiVBTXazOnDnFJvYQhgJKAQ1pKKDEyVBAiVOggBI7FFAKaMihO/VgqCM9f7CeQ9heNhDRD+wLMaIFAmNEQw8KKHEaOuYTHZTseSS0oIBSQEMGPX+wHji5saEyKOKOTp7sF3TP+a7OVoExosEPBZQ4DQoo0VBAKaBBjUcTOzoWnQ+KD7Zmn6Ga6Lu62EQfzFBAidOggBINBZQCGtRQQCmgwQwFlDgNCijRUEApoEGHR4zn+T9wxEzaywYjOkYUQzfVW2JE2SwfbFBAidOggBINBZQCGjRAurR0usQzOGI8x8rJwX7BrBVljGjQQAElToMCSjQUUAqoo0HTMnp/g4oK9GgP3GGUxhtXE72rVhRA0ru62sa9iV7ff62tzaqkpFjV1dUIuia3urpKKC4qHNWUfqEEBZQ4jdEKKO71pqYLZfCDubGxXv4FlZUVqrQUQzldmOoT+SUlRQL/fgMfCigF1NFQQEcPBTT4oIASp0EBJRoKKAXUcWhhgjxVVhaopsYq4dRJNrePhgsxov2WGNHxapZvb28Tpk39TmVk7FbhYfOFurpadfjQQZWwPE5IS92gkpJWmS8g+3ZCEQoocRqjFVDE8YctmGcKBX6Apqenqr179wgrVyao9LSN8lwArS3NKjJyodq6ZZOwbdsWj22SwIICSgF1DJAm9OquMqQTuAaPp3SOFT2OqHutqKtm1D+SpwU0Li5WPu/Yvk3IzclWUYsjjGPpFJAXsSjceGj1CPbthCIUUOI0RiugIDl5taqprhLi4paqnu4uNeOHaQKeBdFRkerLL6YIHcYzJCxsnlq/fq2AH7D27ZHAggJKAQ1oIEFaiKoqC1VTE5vYfYU00Z/vOW9tovdtjaMW0OXL4+Tzzh3bBQho3LKl0gwHUCOyMHyBGhjoF+zbCUUooMRpXIqAVlSUqeXxscKqlQmyDNIJWlqapNVLC2pra4tqbm5ShYX5wsKFYR7bI4EFBZQCGtBQQP0HBdR5UECJ06CAEg0FlAIacOgYz24tnY3VApvb/YMlRrSuXOJsgWtQe++LaEdHu4DmNnzetzdDKCzIN/ZbLnFdAM3xBw/sM4/Pvp1QhAJKnMalCCg6F039/luhqKhQlqHjEVgSvVhiw7dt3Sy0tbWo6OhIlZAQJ+zcud1jeySwoIBSQAMGifHsbDWFBzGep/kSHHcGB/uFC7WircK/fCCjQ6EnFvDmPRosUECJU0CrVZ8hHA0NlSb4rFu07OVd65xSMTHRgn0EDPwYPnPG+kzAMm+/z4nvoIBSQMcV1zBKrQJ6YqOm099N7H19vUJ6eppauDBcpaSsEdraWiV/5swZwqFDBz3W9QfLly8X1qxZIyK2Z89uISJikfErf6dlGBJf4qoVdWuir8hX3edrRX1RM0ouDgWUOAW0YBXkH1H5eYdNCgsyjR+3fYK9PKipqVYHDuwX7HnE+VBAKaDjCgX04lBAyXBQQIlToIASOxRQCqjfuTCOp0s69R8g5MZe1tf09/epP/3pT8K9996rPvnkY3X77bcLTzzxuPwh//73zwtr16bIOlr4uru7RAjdt4fyPT3dgpYy/fcFBgcHLH9v2L8WYC3cOsYReSj/2WefCdOnT1fbtm1Td9xxuzBnzmw1YcIElZaWKtjPzVf4O0aUDA8FlDiJ+roKi4Di+cGY7tCFAkoB9Rv/+tdZy1ztiAEa745FKSkphszdIXR2dsgy3ev6m2++kbHk3AUUPS3feON14bbbblPvv/++KZyoMZ048WlZDqZM+UyELD4+Xvj666/UQw89ZEjkVmHHju0ivZo1a5Jl/wcPHhTuuece9fTTT6nnn39egIBWVJSr4uIiAQ/tV155Rc2cOVOwn5u/MGNE6zCoPWpF2wR/xYiGMhRQ4iTwo7WgINNF/hEZdcNehoQOFFAKqE+RJnZDOrV4NjSgY9GgEAi/eiGJ7777rmDP07gL6JQpU0T6QE5Otnrhhd+rsLAFQl5enoqLW2Y2Gf32t79VhYUFKjw8XLj11gmqvLxMtbQ0C9ddd51KTEw0hfSqq64yhLdOPfDAA8Ly5fHSOxzSCiCgOB49DNGbb/5FylVXVwv24/Y3ZhN9XbkgHZY6W1V/f0/IgqZFX9bwUEBHBj96ITlgYKDX4/sh/ke3mODHqj2P+B/cFwDPbtwv9nvIl1BAKaA+hQJKAbU/8EIJCuj4QgENPCiggQUFdPSJAuow+vt6VFlpjlBdVSRN7r58IV8q4eFh6tlnnxV0PKf+A87Pz5fYTHcBRVO4FsK//OUNEVEtoGg2f+SRR9TLL78sXH755ero0UxTQN9++23ZfllZmfBv//Zv6o033jB56aU/qX379qmbbrpJgLyi/EcffShoAdVTUWLfeorKQAHfq26Sr6oqlO+9rrYsZMH565hn+7XyBhRQT/Tzpa+vW2LMITqgtrbU4/shJNTBfQFc90mBeAvwxzuaAkoB9Tm6lzRqwyrK88xe1OPR6cgOelnefPPNAgTv2LGj6vvvvxd+9atfSVynu4B+/fXXZo0p4kRjYmLU+vXrhcmTPxHy8nKFK6+8Um3atMkU0Pfec9WydnR0CDfccIPavXuXIaOlAjoaNTTUm4I7Z84cVVCQr+6//35BCyg6P4EZM2YE1IxAMosSaj6NBxnA9x3qcaDlZXkUUD+jx6mF/ENCA+kHLyGBDJylvCxXwMg09nxvQwGlgPoVEdHzLwhpkhcR7RfG4yWBfWphfPXVV9V9992nnnnmGUEPu/TZZ58KkEU0iesaSUji3//+d5n+DUBe0WnotddeExYsmK+++uorlZSUJMyePcvcJ9i3b6967rnn1MMPPywsWRItyzMzM4XHHntMeudjaCgQF+eaqrK1tVV45pmJUhNqPyd/gibm+vpywTUsk++n7nQSFFD/gqZE/QJFmI89nxAyMjpEDj/ghhsey1tQQCmgfoUCSgENJSig/oUCSsjYoIAOnyigQYSMBSoD0LtitNB8q0V0vGQU425ebGB3fXwnTw56iJZed6T13UHc6eDgoGDPw/bt44yON67zdv1gwI8HxAzpHxS+kiwnQwH1Lwjt6exsEex5hJDRgyZ43E++fB9TQCmg444ZI3q+VlT3oobk2MuS8ePUKcyC5Ordrnu42wWcWKGA+hfEmGN+cPsc4YSQSwPPLLQkoBLEVxUhFFAKaEABodEDmaNJFyKqp2rz1a8wMjwnMcC8nnoT0skm9kuCAupf8ML80XhZAnseIeTSQMukL3/QUUApoAEFBTSwoICODQqof6GAEuI9KKDWRAENIXSzvGssvwJVN84xoqGANcaz0hXj2dl6vrmdL/VLhQLqX0RA+QOJEK+A5z8F9EKigIYg+oUitaKMEfUZrhhPV00nQBA6X+RjgwLqXyighHgPCqg1UUBDHDbRexfPJnaXdPIF7h0ooP6FAjo8uCZHjhxWixdHCvHxcaq2tvaiLUp6VI/vvvtO5eTkqI0bNwgREREeZccDLRwYCs+eZwfD6H388ccCpkO25xMrFFBrooCGOBRQ70IB9S0UUP9CAR0eCigF9FKhgFoTBZSY4IHqHiPqapYfuOgDNZRxxXgOCK4YT1dTu6u53TeSFMpQQP0LBdQT/TyEMF533XXqgw/eF15++WV14403qtzcHAFlMLWvFk5McoHhd/T78dFHH1U7d+5UqakbhcjISMnHeMUAZXp7ez2uP7YJ+vp6PZ7LKIexlwHW12UAlmE99+e5ax89AtbF8szMIwKmK+7vd1VE6PJ6vwDlGxsb1IQJE4TKygrzHH01zJDToYBaEwWUeKAfeK655lErWiEEwlzzgcSpU4PnazrzBAzWzRe1b6GA+hcKqCcNDfXCVVddZc7uBiBpn3zyicwAB7q7u9Tzzz+v3n33XeGWW25R06dPMwVRC2hCwnLhm2++kRrRv/zlL8Ibb7wh66BmFWAfe/bsVg888IBw9913q+TkJMv3g1pIzAYHXnnlFXXrrbeqGTN+EB555BGZma6oqFBob2+T2d9uv/124fPPP5djfuihB4Wf/exnMjtdW1ursGvXTln/jjvuEObOnSsCesMNNwg4Z4goZqsD/JvxhAJqTRRQMiJaRE0ZHeepPscbPWMRgHSyid2/UED9CwXUk4yMDOGKK67weAZu375d/e53vxOamhpF4iBuICcnW1155ZXGM7RO0AK6aNFC4Z133pEpg6+++mqhoCBfrV2bYgoiaiN/+9vfqri4ZcL+/ftEgisqMG1vuewfQnj99dcLmJo4MjJC3XbbbQLk9MUX/yhTGoO8vDy1bFmsOnBgv4BtFxYWiFQDSCVqPLWAYpuHDh1SJSXFwqefTlY1NdXq2muvFTZtSlfHjx8zhbS2tsbj2oU6FFBrooCSEaGAWqGAji8UUP9CAfWEAkoB/alQQK2JAkpGDV76aGZGZyXpsCQyGtwxojivU8Y5goYGHePpmhvbVxJEhocC6l8ooJ5A0sB//Md/qNbWFktebOxS9eCDDwjooANJRWcegGb3X/7ylyJmYDgBRbM7wDXPzs6yxFhedtll6qWXXhLeeON1QyhfVFlZJwTs3z0mE3KYnp6mnnjiCQH56Cw0e/YsATKJZnm9vcsvv1wdPZopEgkQz4p1ysrKhJ///OcefwfYnz7e6uoqEVW9fy3F5AIUUGuigJJLRr+Q0NGmvDzP7PUdbDGiiPHUNZ2M8QwMKKD+hQLqiX4hv/baaxJnqWsM09LSRNpWr04Uuro61a9//WupeQSjFVAtcPjx6y6g6PiDmtXNmzcJ2MaUKVNUXV2tgGO7FAGdPPkTATWhALWz2C7iUAE+Q7R1jS1qNdPSUlVGxh4BAlxdXW3ZHwV0ZCig1kQBJWNCiyhAEz2+Jyc30UsTe0OF4JJONrEHEhRQ/0IBHZ6enm4ROt1p5/HHH1erVq0ye4GjRzg6IaEmFKBn+zPPPCNN8+D9998X4URHIjBz5kyVn5+vXn/9NQHPTzR16894p6LZ/YUXXhAefPBBFRW12Oxlj2OCAOry2AfKT5o0SUB+WFiY2ekJtZ1PPfWkIdKvCvPmzVNfffWl2ct9ypTPJF/36od0Tpw4UT388MMCjtm+v87ODvOzlmJyAQqoNVFAyZiggBJ/QgH1LxTQ4aGAUkAvFQqoNVFAideQGNGOFhFRLaNoxg7kGFGJ8Tw1ICDGE7GtZownx7ILOCig/oUCOjKu54frBe2vsS/194EmfXvepaLlVQvsxXAfp9SeRy4OBdSaKKDE62hBgMRBGCB2AJJnLzueuGI8K80Yz46OZr5oAxwKqH+hgBLiPSig1kQBJT5Fmug7WsyaUdwYusbRXtYfyIxF54XYvWMRX7DOgALqXyighHgPCqg1UUCJT6GAEm9CAfUvFFBCvAcF1JoooMRvIH4Izdw6RhQ3yWkfx4i6x3g2inTmm0Lsr5gt4j0ooP6FAkqI96CAWhMFlPgdLRCQUbzg9A1z+rR3X9CnTw+aNZ2M8QwOKKD+hQJKiPeggFoTBZSMK1pERUYNSWxsrB5TEz2b2IMbCqh/oYAS4j0ooNZEASXjCgWUXAoUUP9CASXEe1BArYkCSgIGiRFtb7oQI9roapYfKUbUFeM5KKA8xvHUQssYz+CDAupfKKD+Bc+skZ53wYg+3x/PnpV/9UD+9nLBAAXUmiigJODQDyDIKISjqbFasMeI4jNjPEMLCqh/oYD6l7S0DTKDErDnBQMtLc3SSgX0su7uLmHzpjSZTSk9PVWwrxsMUECtiQJKAhppojdE1FUziib6KvPv4UITu++EhAQWFFD/4iQBxTsHglNaWiJAaupqa1RtbbWga9pqZVmNlMEMQO1trYL+fvTUmfjc1dWhCgvzBWwP+QMDfUJJcZFMPel+DNh+Y2O9UFZWIsekf1C3t7epyspyc//6ulZXVQo1NVUqblmMsc9OQW+zublJKC0ttrxXse+i88eljw3iqo9XHxv+BTinmprqC/utrlLl5WVyDfRMSBDAsrJSwf6DH9ejtKRYrjHAMqxXYWwDVBnngPMf6O8TcL64RvgXYPakmJhodfjwQUHP5KSvd8LyOJnetKiwQHD/TgC2gc/6fN2/E6dAAbUmCigJaCigxB0KqH+hgFJANRTQsUMBtSYKKHEMZ8+eVvV1ZWYno2CNEyLDQwH1L04S0MbGBjVr5g9qy5ZNwswZ09X2bVtUeNg8AYKUeeSQio+PFTZsWKfWJK9Wu3fvFI4YeRCoJUsWC01NDSo8fL6xja1CxKIwkai4uKXCjh3b1LJlSw3Z6hdwDA0N9SJSICUlWW3elC5SBWb8ME3t3LldRUYsFCBzBw/uV8tiY4TNm9PVN19/YRHQlpYmFR0VKWzfvlWlpW00BTBswTy1detm47jCBUjmwvAFaouxHRAWNl+W4RzBUkP+jh3LVPv3ZQgJCfFq48b1ZpN3a2uLcVzhatOmNGGbce3cr29SUqJczzjjnEFHe7tKS92o1qxJMtm3N0Pl5eYIOJZdxvnOnzdHgJTPmDFNJa5aIUAosV13AcX1S1q9Sti/f686cGCf+fcXtThCzltfvx3G9YhavEj1GBIK7H8PgQgF1JoooMRRtLU1mJ2M7Hkk+KGA+henCSjERh/vgvlzZPnuXTuErKzjIjGo1QTIW2SIW11djQBBgwBBHMEBQ4Cmfv+tWro0Wvj6qy9ErJKSVgmrViUYQnfU0mlmYKDfENPtQsySKLVoYZgpoEuiF0uZzMzDwr69e9TiyEXW41m4wCKgHR1tpnBtNIQZx6mFOfPIYSmDmkSQk50l4qivB4R6z55dKtkQR1BRUS7LIYEA+0aN5Fdffi5ACMMNaU01pBTU19dari+2vWJFvEghOG38PX8+ZbKKNs4L4HxnzZyucnKyBS2wq1YmCBB6SKquAdbbHU5AcU4RhhA3NzcKq4zvFuf03XdfC/hOvv3mK3Xi+DHB/VgDFQqoNVFAiaOggIY2FFD/4jQBXZ240jzesAVzZbkWNggoau50kzakcaEhfP39fQIENDl5tYgaOHHimEiXFjzU4KHJt6KiTGgxtrE4cqEhhbWC7GvXTqkZBZAsdwFdunSJlDl69IgAAY2NjTGPB8c8e/YMm4C2y3mB8rJSNd+Q6oMH9guQS5TRNaLFxYUizjrUQEtqiiF9QEtfVFSEACGEMKMpHrS1tUoTfH5+rrBoUZiU19ezvLxUJHXliuUChHeBcY07jWMEuIa1NdUq15BPsNO4Blhf13hifzgOvT/9vQ0noMhbkRCvVhv/B8XFRYbYZpmCjO+kybguTuq0RQG1JgoocRQU0NCGAupfKKAUUAqo96CAWhMFlDgKCmhoQwH1L04SUMjTurVrzOONNiQLy/ftyxByc7Ol041u0kZzPGIhtbAhf87smeYLF+8wxGbqJmQ0WUN0kpMThVUrV4i09vX1CNhXXl6uGbMJiVoYPt8U1BWGtKHMiRPHhUMH96uSkmIzRhUChmZl905FEEs03QOsj9jOvr5eAc3n8XGxZkwq4lOXL19mHNMSAc3iWHahSb1OtgmRA8jHPnXMaGtrs4hpQkKcgBhLlNfXBzIO8dQxsigPkY41xBpA7hG2UFiQL+zN2C3rrzWkGKAZvcBYjthQgE5EyNedpBAmANFevy5FQB7KI5YX4PvA+SB2FUBqcZ31+va/h0CEAmpNFFDiKCigoQ0F1L84SUBHi47ZHM07CuIF6QH4v3vecN+nfmHrnuUXQx/PcJ0q9fUf6ngxAYcWRL1suOO1M9Q10PuxL9fgvOz7073ohzt+b6P3P9z1D2QooNZEASWOggIa2lBA/UswCigh4wUF1JoooMRRUEBDGwqof6GAEuI9KKDWRAEljmI0AqoHQsaQKfJ5oF9AYD0C1/fs3iXs2LFVluvmr2NHM2Wcu56eLsG+XTL+UED9CwWUEO9BAbUmCihxFKMRUB0DFRY2T2KFMNgzwOwb6OWKQHmQl5cjA1KjdydAj0t0ItibsUewb5eMPxRQ/0IBJcR7UECtiQJKHMVoBFQHqWOmk9LSYumpClDb+f3338hgywCzh6AnrO5FiR6hGEy5oCBPsG+XjD8UUP8CAR2pgwwhZPRUlOebnbbsed6AAkoBJT6EAhraUED9CwWUEO9BAbUmCihxFKMRUA3GBcS4funpGwUsw3h1eiq4QUNIEfeJsQFdlKqammpzbmX79sj4QwH1L5WVBQpD/QB7HiFk9KDZHQLqy5AWCigFlPiQSxFQ8MP0qSKiAJ8x40jS6pUCBjLGQMd6ppKUlCRZVlxUKNi3RcYfCqh/aWttMO6dGsGeRwi5OLpFDvcQ7id7vjehgFJAiZc5ebJfgHTW1JSoutoyAZ9Hqpk5OTggs4XYf3HqB4J9oOahlpHAggLqX9D0XlVZKHR2tnjkE0KGB++Trs5WobLCVftpL+NNKKAUUOJlKKBEQwH1LxRQQn46FNCREwWUBDwnTw4IhQVHVX7eYZPCwqMjBnM3NNSp0pJij+XEuVBA/Y++/yqMF2h9Xbnq6+0UENPmPo0kIeSMOcxSnyGDuF8w9BI4ZdxD9nvL21BAKaDEy+iayQbjpnIX0OamWo+yJLihgI4fuOadHc2quqpIQK1oTXUxGWcqyvNM7HnE/+gWg6rKImk18OXzyg4FlAJKfMRp4yYoyM9URYXHhNOnnf1CJ5cOBXT8cQ9hIeNPW1vjeRo88sj4Yr93fA0FlAJKfAQFlFBAxx/7S5aMLxTQwMV+7/gaCmgQCOiZsz8KRY2nVFRGj/o+vUv4JpWMN/9cVa0+Xl0j2POI/5m6qUvF7OsRSptPqbM/+vahSwElxEp7e9N5XEPNkdCFAupwAe3oO6M+XtMh3D6jST23uEW9u6pd+CCpgxDixjvGffFMRIuA++XLjZ2qZ/CsYL+3vAEFlBArFFCioYA6WED7T/2o3oxvUxONlynYlNevajpOq4YuF43dZwghbuC+qG53kZbbrx4La1aTktqFgVPel1AKKCFWKKBEQwGlgBISMlBAL54ooMSXUECJhgLqQAHVAcMRe3rUQ/Ob1YHyQcH+siWEjMyuon51/9wmIe5gj8e9NlYooIRYoYASDQXUgQLaPXBGmLioRS3c3e3xUiWEjJ5ZW7sE3E/e7glKASXECgWUaCigDhTQspZTwq0/NKnMKtZ8EjIW9pQMCLifmru9K4oUUEKsUECJhgJKASUkpKGAWhMFlPgSCijRUEAdKKCZVScFvDBLmk95vFAJIaMnq3ZQwP1U2OC95wCggBJihQJKNBRQBwrokcqTAl6YqAm1v1AJIaMnp+6kgPspv957zwFAASXECgWUaCigFNCQoqHrlKpo6hHqO3/atats7hFq2wc88oAeBgtl6jpOeuSPlaqWPqGmbej9k0uDAmpNFFDiSyigREMBpYCGFBRQYocCak0UUOJLKKBEQwGlgDqO8KhlQkLyRsvyOeFRauO2vR7l3cmraFRPPv2scKKoxiN/NLz+5j+ExHWbPPJArSGG4E9/fk2lbd/nkT9WPpr8hRC5NMEj76dQVN0qfPHNNLVh6x6P/GCHAmpNFFDiC3788aw6e/a0am2tP0+dfMZyYC9Pgh8KKAXUcbzxt7eEL7/7wbIcwrcwOk6V1LUL+YZs5pTWqYNZRQJqPHPK6tVNN08QjuZXyHpZxTVCxpEcqSF132ZhVbPafShLKGvokmVaYGNXrFG17YPqcE6JgH0iXwvoAw89otakbje3VVzbpnYdPGHWYGIZjsv9c3FNm8ouqRHwGceP4wLYF5a9ZsgvmDU/wnKs+RVNqqS2XR3NKzdxzwdJG7aqvUfzBHwuqGxS9z3wkPDzX/xChS1e6rFOsEMBtSYKKPEFg4N9Kj/vsJX8I6q/v0ewlyfBDwWUAuo4LiagMctXC48+/pR6/MmJ6trrrhfmhC32ENDI2BXqttvvFO5/8GH12l/+bjaxp+3Yrybcdrt66JHHhZsn3KryyhssAjp9dpghmo8K+YbM4TjsAro144hw+513qSeefkY9/tREIae0Vj018Tm1OHalgHXf+eC/1A9zw4WVKWnqlgm3qceeeEr4w5/+rKoNUR1OQD//Zqp6+pnn1WNPPi1cddXVKjl1m4QBgLzyRvW3t99XYVGxAuQ617geKek7hGeef4ECSgGlgBKfgEkeamvLLAJaW1NizuxnL0+CHwooBdRxUEApoN6EAmpNFFDiCyigxA4FlALqOLSAfvHtdMvyF19+VQQ0Om6VcPe994uwhUUuFZ565jmLgGbmlamrr/mN2rgtQ0Az+M233KqSNm4RnnjqGRVubK+mtV9YuTZNnSisMgX03Q/+qX53401qz+FsQR+HXUBfePFlAYK8bGWKiC6YOmOeIXyx6vkXXhSqjX1cf8ONZpP/Xffcpz74r0/VkvhE4XdGHuJehxPQT7/8Vv359TelcxL48OMp6v3/mixiDNDMfsWvf61+a8g4+OPLr1jWf844Bgqo954DgAJKyAUGBnpVQX6mAAHFZ3sZEjpQQCmgjuPtD/5LeHfSP+UzYiPBY088LbWSWkCfef4Pkh+fuE6QWkc3AT2UVawuu+wyQ0TLBZR99PEn1aIl8cKdd9+r1m/e7bF/LaB33HW3evDhx1RpXbug8+0C+uDDjwovv/oX9fW0WSar129W2SW16qZbJggLDEl+9vd/VAWVzQJk9N0PP7ass2XP4REF9MNPppifv54607xGmg8MIV22KkWwnxcFlAKKFGwCevbsGeHUyQHjevWT8WSwX1VW5AsV5Xme+cTv4L4AuEfs946voYBSQB1H0oYtwq+u+LX6/Jtp6h1DssA11/xG5ZTWj1pA0QQP6UKzNIAA/vba69SR3FLhn59+oZ41trEoJl6YcNsdavu+o6aAYh9/fOkVqXUEaLbH/uwCChEE2BeO+5U3/irErlwjwzW99ubfhV9feZVampCk6jtPCm/87W311vsfSlM8wPlsyRibgKZuy1CHsosF+3WlgFJAkZwuoLpJF51eqquKjO8gV6gy/l9TXUzGmaqqQhN7HvE/uC9AmXGP4PPgQJ9gv698AQWUAuo4KKAUUG9CAbUmCijxJRTQwIICOvpEAT1HAdWdaiBzb7//kYgiwBBHyIckAsRX4rOOqZy3KFqV1neob6fPEQqrW2SYoy+/nS6gA1D6zgPmQPIVjd1q+uwFIoJgaUKyLJ+/aImw68AJGeppytdTBezT/fggiAeOF8p2ANZB7Oq8hdGCHnpJH+9Hkz9X5Y2uoZ5AcW2r+mbabMv+MZRUdPxqIdU25ima9FesSTU/p6RtV/Gr13lcv+HA2Kqbdx/0WB7sUECtyekC2tPTIUA6e7rb1Y9nzwj2coSQC6AJvrurTZWX5wm4h+xlvA0FlAJKSEhDAbUmJwvoqVODZowh/m/PJ4SMDO4bAAk9fdq3zwAKKAWUkJCGAmpNThbQhvoKqfUE9jxCyOjpNu4heIwvh8migFJACQlpKKDWRAElhFBAPRMF9BwFlBBvQgG1JicLKJoNz5w5JdjzCCGj51//OivPLz2MmT3fG1BAKaCEhDQUUGtytICW5fr0ehMSSmCsVl/+oKOAUkAJCWkooNbkfAE9K9jzCCGXRmVFAQXULVFAz1FACfEmFFBrooASQgAF1JoooOcooIR4EwqoNVFACSGAAmpNFNBzFFBCvAkF1JoooMFNZ2eHkJ2dpWpqqi+pl/O6dWtVS0uzsHfvXpWVdcKjTKCyc+dOVV5e5rGcDA8F1JoooOeCW0BLatvMmYjseeNB8oZ0Vdc+KNjziAvMzgSS1qV55DkBCqg1UUCDl5UrV6gbbrhBuO++++Tfd999V+jvv/j0ixMmTFCZmUeEr776SkVHR3mUCVReeukltXp1ovFe7hX+8Y9/qOpq74lPMEIBtSYK6DkKqD+hgF4cCujwUED9CwV0ZCigFNBLgQJqTRTQc8EjoLWG1JXUtsq/oKatX82eN1/mQ9dzote09ouUAsyvrpeBqpZeVdnUrWrbBgT3MhqIrN5eeUOnfNbChP2V1rWramM7QMoby/X+MFf7nPkLzO0jH9vXx1tS06qqjePQwozt1Rjlyuo7BNl3Q5fsAzR0nZJlOG6Ac8fx13UMClhfnxPAMRbXoEyPoPeDbYIK45z0MoB9VjZfKGde52GuT237gJyDnrsen635g6re7XyLqpvlGN2vLc4LxwFmzZ1nufZOgQJqTRTQ4KSxsUFdeeWVKjU1VTh5clBVVJSre+65R4iLW2Z8rlAREYsEyOXbb7+tjh07KmAb7gK6bFmsSktLU4WFBcLSpUvVvHlz1XvvvSvk5ubKOjp/0qQP1JQpn6n6+jpBH1dHR7swa9ZMlZKyRoWFLRDwHa5YkaD+9re/CXFxcTIeZU9Pt/DDDz+ot956yziGVAFhBF9++YWEFQBs+5///C/V1tYqaAGNjIwULr/8cvX666+r7OxswX69CAXUniig55wvoC5R61cRUUvU0rgEFbU0Tti8a5/68MMP1LIViQJkbu78MLXIKAeWr0qW9X+YOUsIi1is9h7JVuHGvwDbijGo7zwpoOy+zBwzf8as2epwdpE6UVghTPthhloav0JNN7YFIHDr0raquWHhQvSyeCnjLqA792eqBYsihejYeNlmcU2LEBEVoyKil6rUbbuFvZnZImULFkYI69O3icTNnDNXQPkPP5qkjhjHBOYuCDO2GyHnBFYmr1OLFker+eGLhCM5xSrj0HEVZuwbzAtbqDLzStX2vYeF8MjFctxZRVUCjhfHbb8+WmgXRkarSON4sQxs23NQbdi03fyecH7ZxTXm9Y+KiVXzjX1qoU7fnqHmzFtglIsTvvjyS4/v2glQQK2JAhqcxMfHq4cffth8QevlYWFhwnPPPWeIZaa6+uqrhejoaPX551PUQw89JOCaugvohx9OUvPnz1e7du0UrrjiCrVy5Ur10UcfCs8++6zEit55551CTMwS2c/TTz8tQICxfy2kkONJk4zn4ZHDQlLSajnerVu3CDi+hITlIsrgiSeeUOvXr1Nvvvmm0N3dpa677jqVk5MtYNs///nPpZYTaAHdt2+f8Jvf/EbOsampUbBfL0IBtScK6DnnC6iucYRApRmiduhEgYAatVlz55o1cmj23mUI36o164Xvp02T9adO/0GobumTGsO5C8IFbOtwdrFZw4myhVVNaoshtgASlWhsRwso5BNllieuETJzS0RssV2AWr9vv5/qIaArktYKON6tuw+IWILwiCiVW1pr1kDOnD1Hjk8LN7a9/1iueT7Y5sw588zt45xQC6kF7/MvvlCJKevVkmXLhcglS+U8tDBCOktr29TGLbuEZQmr1M59R8waWBzvUNcHYg8yDmep5PVp6suvvhJwjBDK0roOYaEhv4eyCtU3338vJKZskBrqDZu3CzgffE9VzT3Ct0YZ+3ftBCig1kQBDU4gdPfff78aHBwQ9HLUPIIXX3xRBPSWW24RUNuITkb6M/4eRhLQe++9V7Z34MB+AdKZkZEhEgiee+5ZEc/bbrtNqKyskPJaQC+77DJLGMDf/vZX2e/zzz8v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>