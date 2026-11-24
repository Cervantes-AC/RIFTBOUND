extends Node
## Two-process ENet test (real sockets, real RPCs, real Match scene). Roles via user args:
##   godot --headless --path . res://tests/NetTest.tscn -- host
##   godot --headless --path . res://tests/NetTest.tscn -- join 127.0.0.1
##   godot --headless --path . res://tests/NetTest.tscn -- fail            (join with nobody listening)
##   godot --headless --path . res://tests/NetTest.tscn -- badip           (invalid address)
## Each process prints NETTEST lines and exits 0 on success, 1 on failure.

var role := ""
var ip := "127.0.0.1"
var _ok := true


func say(text: String) -> void:
	print("NETTEST[%s] %s" % [role, text])


func fail(text: String) -> void:
	_ok = false
	print("NETTEST[%s] FAIL: %s" % [role, text])


func _ready() -> void:
	SaveManager.save_path = "user://net_test_save.cfg"
	SaveManager.reset_to_defaults()
	var args := OS.get_cmdline_user_args()
	role = args[0] if args.size() > 0 else "host"
	if args.size() > 1:
		ip = args[1]
	AudioManager.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().process_frame
	get_tree().current_scene = null   # keep this test node alive when the game changes scenes
	match role:
		"host":
			await _run_host()
		"join":
			await _run_guest()
		"fail":
			await _run_fail()
		"badip":
			await _run_badip()
	get_tree().quit(0 if _ok else 1)


func _run_badip() -> void:
	var failed := [false, ""]
	NetworkManager.connection_failed.connect(func(m): failed[0] = true; failed[1] = m)
	var started := NetworkManager.join_game("not.an.ip")
	say("join_game(bad ip) returned %s message='%s'" % [started, failed[1]])
	if started or not failed[0] or failed[1] == "":
		fail("invalid IP must be rejected with a readable message")
	else:
		say("OK invalid address rejected with message")


func _run_fail() -> void:
	var result := [false, ""]
	NetworkManager.connection_failed.connect(func(m): result[0] = true; result[1] = m)
	var t0 := Time.get_ticks_msec()
	NetworkManager.join_game("127.0.0.1")   # nothing is listening on this machine's port 7777
	var timeout := 15.0
	while not result[0] and timeout > 0.0:
		await get_tree().create_timer(0.25).timeout
		timeout -= 0.25
	say("connection failure reported=%s after %.1fs: '%s'" % [result[0], (Time.get_ticks_msec() - t0) / 1000.0, result[1]])
	if not result[0] or result[1] == "":
		fail("no readable failure message when host is unreachable")
	elif NetworkManager.is_online():
		fail("manager should be back to offline after failure")
	else:
		say("OK failure message shown and manager reset (user stays in lobby)")


func _run_host() -> void:
	var joined := [false]
	NetworkManager.guest_joined.connect(func(): joined[0] = true)
	if not NetworkManager.host_game():
		fail("host_game failed")
		return
	say("hosting, local ip guess = '%s'" % NetworkManager.get_local_ip())
	var timeout := 40.0
	while not joined[0] and timeout > 0.0:
		await get_tree().create_timer(0.25).timeout
		timeout -= 0.25
	if not joined[0]:
		fail("guest never joined")
		return
	say("guest joined (peer %d)" % NetworkManager.guest_peer_id)
	while not NetworkManager.host_can_start() and timeout > 0.0:
		await get_tree().create_timer(0.25).timeout
		timeout -= 0.25
	if not NetworkManager.host_can_start():
		fail("guest never became ready")
		return
	say("guest class=%s ready=%s" % [NetworkManager.guest_class, NetworkManager.guest_ready])
	if NetworkManager.guest_class != "ranger":
		fail("guest class selection did not sync (expected ranger)")
	NetworkManager.host_class = "vanguard"
	NetworkManager.arena = "cavern"
	NetworkManager.match_should_start.connect(func(cfg):
		cfg["time"] = 30.0
		GameState.start_match(cfg))
	NetworkManager.host_start_match()
	await get_tree().create_timer(1.5).timeout
	var m: MatchManager = get_tree().current_scene
	if m == null or not (m is MatchManager):
		fail("host did not enter the match scene")
		return
	m.fighters[0].controller = AIController.new(GameState.AI_PRESETS["normal"])
	say("host match started: role=%s authority=%s fighters=%d" % [m.online_role, m.is_authority, m.fighters.size()])
	var guest_acted := false
	var limit := 70.0
	while m.phase != MatchManager.Phase.ENDED and limit > 0.0:
		await get_tree().create_timer(0.25).timeout
		limit -= 0.25
		var g: Fighter = m.fighters[1]
		for i in 4:
			if g.skills.cooldown_total[i] > 0.0:
				guest_acted = true
	say("match ended phase=%s winner_team=%d guest_input_reached_host=%s" % [m.phase, m.winner_team, guest_acted])
	if m.phase != MatchManager.Phase.ENDED:
		fail("host match never ended")
	if not guest_acted:
		fail("guest input (attacks/skills) never reached the host simulation")
	await get_tree().create_timer(3.0).timeout
	if m.result_screen == null:
		fail("host has no result screen")
	check_campaign_untouched()
	NetworkManager.leave()


func _run_guest() -> void:
	var joined := [false]
	NetworkManager.guest_joined.connect(func(): joined[0] = true)
	GameState.selected_class = "ranger"
	var t := 20.0
	while t > 0.0 and not joined[0]:
		if not NetworkManager.is_online():
			NetworkManager.join_game(ip)
		await get_tree().create_timer(1.0).timeout
		t -= 1.0
	if not joined[0]:
		fail("could not join host")
		return
	say("connected to host")
	NetworkManager.guest_set_class("ranger")
	await get_tree().create_timer(0.5).timeout
	NetworkManager.guest_set_ready(true)
	NetworkManager.match_should_start.connect(func(cfg): GameState.start_match(cfg))
	var timeout := 30.0
	while not (get_tree().current_scene is MatchManager) and timeout > 0.0:
		await get_tree().create_timer(0.25).timeout
		timeout -= 0.25
	var m: MatchManager = get_tree().current_scene as MatchManager
	if m == null:
		fail("guest never entered the match")
		return
	say("guest in match: role=%s authority=%s arena=%s lobby host class=%s" % [m.online_role, m.is_authority, m.config["arena"], NetworkManager.host_class])
	if m.is_authority:
		fail("guest must not be authoritative")
	if m.config["arena"] != "cavern" or NetworkManager.host_class != "vanguard":
		fail("guest did not receive host's arena/class choice")
	# drive the guest's local fighter: walk toward the host and attack / use skills via the real Input actions
	var elapsed := 0.0
	var snapshots_seen := false
	var saw_fight := false
	while m.phase != MatchManager.Phase.ENDED and elapsed < 75.0:
		await get_tree().create_timer(0.15).timeout
		elapsed += 0.15
		if m.phase == MatchManager.Phase.FIGHTING:
			saw_fight = true
			var me: Fighter = m.fighters[1]
			var host_f: Fighter = m.fighters[0]
			var dx := host_f.global_position.x - me.global_position.x
			Input.action_release("move_left")
			Input.action_release("move_right")
			if absf(dx) > 260.0:
				Input.action_press("move_right" if dx > 0 else "move_left")
			for a in ["attack", "skill1", "skill2", "skill3", "dodge", "jump"]:
				if randf() < 0.35:
					Input.action_press(a)
				else:
					Input.action_release(a)
		if m.fighters[0].health.current < m.fighters[0].health.max_health or m.fighters[1].global_position.x != 0.0:
			snapshots_seen = true
	for a in ["attack", "skill1", "skill2", "skill3", "dodge", "jump", "move_left", "move_right"]:
		Input.action_release(a)
	say("guest sees phase=%s time_left=%.1f fighters hp=[%.0f,%.0f] saw_fight=%s" % [m.phase, m.time_left, m.fighters[0].health.current, m.fighters[1].health.current, saw_fight])
	if not saw_fight or not snapshots_seen:
		fail("guest never received snapshots of the fight")
	if m.phase != MatchManager.Phase.ENDED:
		fail("guest never received the match result from the host")
	await get_tree().create_timer(3.0).timeout
	if m.result_screen == null:
		fail("guest has no result screen")
	else:
		say("guest result screen shown: %s" % GameState.last_result.get("outcome", "?"))
	if not m.fighters[0].is_puppet or not m.fighters[1].is_puppet:
		fail("guest fighters must be puppets (no local combat simulation)")
	check_campaign_untouched()
	NetworkManager.leave()


func check_campaign_untouched() -> void:
	if SaveManager.highest_unlocked != 1 or SaveManager.total_stars() != 0 or SaveManager.matches_played != 0:
		fail("online match changed offline campaign progression!")
	else:
		say("OK online match left campaign progress untouched (online matches counted separately: %d)" % SaveManager.online_matches)
