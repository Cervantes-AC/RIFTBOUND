extends Control
## Same-Wi-Fi lobby: host, or join (the host is found automatically; typing the IP is only a fallback).
## Real ENet connection, no simulation.
## All failures show a readable message and keep the player in the lobby (lab requirement R8).

enum View { CHOOSE, HOST, JOIN }

const QUERY_EVERY := 0.7
const COLLECT_TIME := 1.0      # after the first reply, wait this long in case a second host also answers
const GIVE_UP_HINT := 6.0

var _view: View = View.CHOOSE
var _body: VBoxContainer
var _status: Label
var _ip_edit: LineEdit
var _picker: ClassPicker
var _ready_btn: Button
var _start_btn: Button
var _guest_info: Label
var _host_info: Label
var _arena_label: Label
var _error_text := ""
var _search := LanDiscovery.new()
var _searching := false
var _search_age := 0.0
var _query_wait := 0.0
var _first_found_at := -1.0
var _found := PackedStringArray()
var _host_list: VBoxContainer


func _ready() -> void:
	var m := PixelUI.screen(self, 14)
	AudioManager.play_music("menu")
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	m.add_child(v)
	v.add_child(PixelUI.label("ONLINE - SAME WI-FI", 28, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	_body = VBoxContainer.new()
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 12)
	v.add_child(_body)
	_status = PixelUI.wrap_label("", 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_status.custom_minimum_size = Vector2(1000, 44)
	v.add_child(_status)
	var back := PixelUI.button("BACK", PixelUI.C_PANEL_LIGHT, 18, Vector2(220, 56))
	back.pressed.connect(_on_back)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(back)
	var nm := NetworkManager
	nm.status_changed.connect(_on_status)
	nm.connection_failed.connect(_on_failed)
	nm.guest_joined.connect(_on_guest_joined)
	nm.lobby_changed.connect(_refresh_room)
	nm.disconnected.connect(_on_disconnected)
	nm.match_should_start.connect(_on_match_start)
	UIManager.back_requested.connect(_on_back)
	# coming back from a finished/aborted online match: always start clean
	if nm.is_online():
		nm.leave()
	_show_choose()


func _exit_tree() -> void:
	_stop_search()
	var nm := NetworkManager
	for pair in [[nm.status_changed, _on_status], [nm.connection_failed, _on_failed], [nm.guest_joined, _on_guest_joined],
			[nm.lobby_changed, _refresh_room], [nm.disconnected, _on_disconnected], [nm.match_should_start, _on_match_start],
			[UIManager.back_requested, _on_back]]:
		if pair[0].is_connected(pair[1]):
			pair[0].disconnect(pair[1])


func _clear_body() -> void:
	_stop_search()
	_host_list = null
	for c in _body.get_children():
		_body.remove_child(c)
		c.queue_free()
	_picker = null
	_ready_btn = null
	_start_btn = null
	_guest_info = null
	_host_info = null
	_arena_label = null
	_ip_edit = null


# ------------------------------------------------------------------ views
func _show_choose() -> void:
	_view = View.CHOOSE
	_clear_body()
	_body.alignment = BoxContainer.ALIGNMENT_CENTER
	var note := PixelUI.wrap_label("Both phones must be on the same Wi-Fi network (or one phone's hotspot).\nOne player hosts, the other taps Join - the match is found automatically.", 12, PixelUI.C_DIM, HORIZONTAL_ALIGNMENT_CENTER)
	note.custom_minimum_size = Vector2(900, 0)
	_body.add_child(note)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 30)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	_body.add_child(row)
	var host := PixelUI.button("HOST MATCH", Color("#2f7a4a"), 24, Vector2(420, 150))
	host.pressed.connect(_on_host_pressed)
	row.add_child(host)
	var join := PixelUI.button("JOIN MATCH", Color("#3a5aa8"), 24, Vector2(420, 150))
	join.pressed.connect(func():
		AudioManager.play_sfx("click")
		_show_join())
	row.add_child(join)
	if _error_text != "":
		_status.text = _error_text
		_status.add_theme_color_override("font_color", PixelUI.C_RED)
	else:
		_status.text = "Choose Host or Join."
		_status.add_theme_color_override("font_color", PixelUI.C_TEXT)


func _on_host_pressed() -> void:
	AudioManager.play_sfx("click")
	_error_text = ""
	if NetworkManager.get_local_ip() == "":
		_error_text = "No Wi-Fi network found. Turn on Wi-Fi (or a hotspot) and try again."
		_show_choose()
		return
	if not NetworkManager.host_game():
		return  # connection_failed already reported the reason
	_show_host()


func _show_host() -> void:
	_view = View.HOST
	_clear_body()
	_body.alignment = BoxContainer.ALIGNMENT_BEGIN
	var ip_panel := PixelUI.panel(PixelUI.C_PANEL, PixelUI.C_GOLD)
	_body.add_child(ip_panel)
	var sb := ip_panel.get_theme_stylebox("panel") as StyleBoxFlat
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	ip_panel.add_child(PixelUI.label("YOUR IP: %s   PORT: %d" % [NetworkManager.get_local_ip(), NetworkManager.PORT], 26, PixelUI.C_GOLD, HORIZONTAL_ALIGNMENT_CENTER))
	_build_room(true)
	_on_status(NetworkManager.status)


## Join: search the Wi-Fi for hosts. One host -> connect straight away; several -> pick one.
func _show_join() -> void:
	_view = View.JOIN
	_error_text = ""
	_clear_body()
	_body.alignment = BoxContainer.ALIGNMENT_CENTER
	_body.add_child(PixelUI.label("Looking for a match on this Wi-Fi...", 20, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER))
	_host_list = VBoxContainer.new()
	_host_list.add_theme_constant_override("separation", 12)
	_host_list.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_body.add_child(_host_list)
	var manual := PixelUI.button("ENTER IP MANUALLY", PixelUI.C_PANEL_LIGHT, 16, Vector2(420, 60))
	manual.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	manual.pressed.connect(func():
		AudioManager.play_sfx("click")
		_show_manual_join())
	_body.add_child(manual)
	_status.text = "Ask the other player to tap HOST MATCH."
	_status.add_theme_color_override("font_color", PixelUI.C_TEXT)
	_found = PackedStringArray()
	_search_age = 0.0
	_query_wait = 0.0
	_first_found_at = -1.0
	_searching = _search.start_search()
	if not _searching:
		_status.text = "Could not search the network. Use ENTER IP MANUALLY."


func _stop_search() -> void:
	_searching = false
	_search.stop()


func _process(delta: float) -> void:
	if not _searching:
		return
	_search_age += delta
	_query_wait -= delta
	if _query_wait <= 0.0:
		_query_wait = QUERY_EVERY
		_search.send_query()
	for ip in _search.poll_search():
		if not _found.has(ip):
			_found.append(ip)
			if _first_found_at < 0.0:
				_first_found_at = _search_age
			elif _search_age - _first_found_at > COLLECT_TIME:
				_add_host_button(ip)
	if _first_found_at >= 0.0 and _search_age - _first_found_at >= COLLECT_TIME and _host_list.get_child_count() == 0:
		if _found.size() == 1:
			_join_found(_found[0])
		else:
			_status.text = "More than one match found. Pick one."
			for ip in _found:
				_add_host_button(ip)
	elif _found.is_empty() and _search_age > GIVE_UP_HINT:
		_status.text = "No match yet. Same Wi-Fi? Host waiting? Otherwise use ENTER IP MANUALLY."


func _add_host_button(ip: String) -> void:
	var b := PixelUI.button("JOIN %s" % ip, Color("#3a5aa8"), 20, Vector2(520, 66))
	b.pressed.connect(func():
		AudioManager.play_sfx("click")
		_join_found(ip))
	_host_list.add_child(b)


func _join_found(ip: String) -> void:
	_stop_search()
	if NetworkManager.join_game(ip):
		_status.add_theme_color_override("font_color", PixelUI.C_TEXT)


func _show_manual_join() -> void:
	_view = View.JOIN
	_error_text = ""
	_clear_body()
	_body.alignment = BoxContainer.ALIGNMENT_CENTER
	var note := PixelUI.label("Enter the host's IP address:", 20, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_body.add_child(note)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	_body.add_child(row)
	_ip_edit = LineEdit.new()
	_ip_edit.placeholder_text = "192.168.1.23"
	_ip_edit.text = SaveManager.last_ip
	_ip_edit.max_length = 15
	_ip_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_URL   # the decimal keypad allows only one "."
	_ip_edit.custom_minimum_size = Vector2(520, 72)
	_ip_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ip_edit.add_theme_font_override("font", PixelUI.FONT)
	_ip_edit.add_theme_font_size_override("font_size", 28)
	_ip_edit.add_theme_color_override("font_color", PixelUI.C_TEXT)
	_ip_edit.add_theme_stylebox_override("normal", PixelUI.box(Color("#0d0a1a"), PixelUI.C_EDGE))
	_ip_edit.add_theme_stylebox_override("focus", PixelUI.box(Color("#0d0a1a"), PixelUI.C_GOLD))
	_ip_edit.text_submitted.connect(func(_t): _on_connect_pressed())
	row.add_child(_ip_edit)
	var connect_btn := PixelUI.button("CONNECT", Color("#3a5aa8"), 22, Vector2(260, 72))
	connect_btn.pressed.connect(_on_connect_pressed)
	row.add_child(connect_btn)
	_status.text = "Type the IP shown on the host's screen, then press CONNECT."
	_status.add_theme_color_override("font_color", PixelUI.C_TEXT)


func _on_connect_pressed() -> void:
	AudioManager.play_sfx("click")
	var ip := _ip_edit.text.strip_edges()
	if NetworkManager.get_local_ip() == "" and not ip.begins_with("127."):
		_error_text = "No Wi-Fi network found. Turn on Wi-Fi and try again."
		_show_choose()
		return
	SaveManager.set_setting("last_ip", ip)
	if NetworkManager.join_game(ip):
		_status.add_theme_color_override("font_color", PixelUI.C_TEXT)


func _build_room(is_host: bool) -> void:
	_body.alignment = BoxContainer.ALIGNMENT_BEGIN
	var info := HBoxContainer.new()
	info.add_theme_constant_override("separation", 30)
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	_body.add_child(info)
	_host_info = PixelUI.label("", 16, PixelUI.C_TEXT)
	info.add_child(_host_info)
	_guest_info = PixelUI.label("", 16, PixelUI.C_TEXT)
	info.add_child(_guest_info)
	_picker = ClassPicker.new()
	_picker.compact = true
	_picker.selected = GameState.selected_class if Library.class_ids().has(GameState.selected_class) else "vanguard"
	_picker.alignment = BoxContainer.ALIGNMENT_CENTER
	_picker.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_picker.class_selected.connect(_on_class_selected)
	_body.add_child(_picker)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	_body.add_child(row)
	if is_host:
		var prev := PixelUI.button("<", PixelUI.C_PANEL_LIGHT, 18, Vector2(56, 56))
		prev.pressed.connect(func(): _cycle_arena(-1))
		row.add_child(prev)
		_arena_label = PixelUI.label("", 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
		_arena_label.custom_minimum_size = Vector2(380, 0)
		row.add_child(_arena_label)
		var next := PixelUI.button(">", PixelUI.C_PANEL_LIGHT, 18, Vector2(56, 56))
		next.pressed.connect(func(): _cycle_arena(1))
		row.add_child(next)
		_start_btn = PixelUI.button("START MATCH", Color("#2f7a4a"), 18, Vector2(360, 62))
		_start_btn.pressed.connect(func():
			AudioManager.play_sfx("click")
			NetworkManager.host_start_match())
		row.add_child(_start_btn)
		GameState.selected_class = _picker.selected
		NetworkManager.host_set_class(_picker.selected)
	else:
		_arena_label = PixelUI.label("", 16, PixelUI.C_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
		_arena_label.custom_minimum_size = Vector2(440, 0)
		row.add_child(_arena_label)
		_ready_btn = PixelUI.button("READY", Color("#2f7a4a"), 20, Vector2(360, 62))
		_ready_btn.pressed.connect(func():
			AudioManager.play_sfx("click")
			NetworkManager.guest_set_ready(not NetworkManager.guest_ready)
			_refresh_room())
		row.add_child(_ready_btn)
		GameState.selected_class = _picker.selected
		NetworkManager.guest_set_class(_picker.selected)
	_refresh_room()


func _cycle_arena(dir: int) -> void:
	var i := posmod(GameState.ARENA_IDS.find(NetworkManager.arena) + dir, GameState.ARENA_IDS.size())
	AudioManager.play_sfx("click")
	NetworkManager.host_set_arena(GameState.ARENA_IDS[i])


func _on_class_selected(id: String) -> void:
	GameState.selected_class = id
	SaveManager.set_setting("player_class", id)
	if NetworkManager.is_host():
		NetworkManager.host_set_class(id)
	elif NetworkManager.role == "guest":
		NetworkManager.guest_set_class(id)


func _refresh_room() -> void:
	var nm := NetworkManager
	if _host_info:
		_host_info.text = "HOST: %s" % Library.get_class_data(nm.host_class).display_name.to_upper()
	if _guest_info:
		if nm.is_host():
			_guest_info.text = "GUEST: %s - %s" % [Library.get_class_data(nm.guest_class).display_name.to_upper(), "READY" if nm.guest_ready else ("choosing..." if nm.guest_connected() else "not connected")]
		else:
			_guest_info.text = "YOU: %s - %s" % [Library.get_class_data(nm.guest_class).display_name.to_upper(), "READY" if nm.guest_ready else "not ready"]
	if _arena_label:
		_arena_label.text = "ARENA: %s" % GameState.ARENA_NAMES.get(nm.arena, nm.arena)
	if _start_btn:
		_start_btn.disabled = not nm.host_can_start()
		_start_btn.text = "START MATCH" if nm.host_can_start() else ("WAITING: NOT READY" if nm.guest_connected() else "WAITING FOR PLAYER")
	if _ready_btn:
		_ready_btn.text = "READY! (TAP: CANCEL)" if nm.guest_ready else "READY"


# ------------------------------------------------------------------ network callbacks
func _on_status(text: String) -> void:
	_status.text = text
	_status.add_theme_color_override("font_color", PixelUI.C_TEXT)


func _on_failed(message: String) -> void:
	_error_text = message
	_show_choose()  # readable error + back in the lobby, as required


func _on_guest_joined() -> void:
	if NetworkManager.role == "guest":
		_view = View.JOIN
		_clear_body()
		_build_room(false)
	else:
		_refresh_room()


func _on_disconnected(message: String) -> void:
	if NetworkManager.role == "host":
		_refresh_room()
		_status.text = message + " Waiting for a new player..."
		_status.add_theme_color_override("font_color", PixelUI.C_RED)
	else:
		_error_text = message + " Host or join again."
		_show_choose()


func _on_match_start(config: Dictionary) -> void:
	GameState.start_match(config)


func _on_back() -> void:
	AudioManager.play_sfx("back")
	if _view == View.CHOOSE:
		UIManager.go("res://scenes/ui/MainMenu.tscn")
	else:
		NetworkManager.leave()
		_error_text = ""
		_show_choose()
