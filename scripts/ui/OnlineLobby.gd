extends Control
## Same-Wi-Fi lobby: host (shows IP) or join (type the host's IP). Real ENet connection, no simulation.
## All failures show a readable message and keep the player in the lobby (lab requirement R8).

enum View { CHOOSE, HOST, JOIN }

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
	var nm := NetworkManager
	for pair in [[nm.status_changed, _on_status], [nm.connection_failed, _on_failed], [nm.guest_joined, _on_guest_joined],
			[nm.lobby_changed, _refresh_room], [nm.disconnected, _on_disconnected], [nm.match_should_start, _on_match_start],
			[UIManager.back_requested, _on_back]]:
		if pair[0].is_connected(pair[1]):
			pair[0].disconnect(pair[1])


func _clear_body() -> void:
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
	var note := PixelUI.wrap_label("Both phones must be on the same Wi-Fi network (or one phone's hotspot).\nOne player hosts, the other joins with the host's IP address.", 12, PixelUI.C_DIM, HORIZONTAL_ALIGNMENT_CENTER)
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


func _show_join() -> void:
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
	_ip_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER_DECIMAL
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
