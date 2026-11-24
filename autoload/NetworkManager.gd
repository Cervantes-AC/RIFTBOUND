extends Node
## Same-Wi-Fi multiplayer on Godot's High-level Multiplayer API (ENetMultiplayerPeer), port 7777, one guest.
##
## HOST-AUTHORITATIVE: the guest only ever sends its *input* (`_srv_input`, `_srv_press`) and lobby choices.
## The host simulates the match, calculates damage and decides the winner, then pushes snapshots/results.
## `_cli_*` RPCs use mode "authority", so only the host (peer 1) is allowed to call them on the guest.

signal status_changed(text: String)
signal connection_failed(message: String)
signal guest_joined
signal disconnected(message: String)
signal lobby_changed
signal match_should_start(config: Dictionary)
signal snapshot_received(data: Array)
signal fx_received(kind: String, pos: Vector2, data: Dictionary)
signal projectile_received(spec: Dictionary)
signal area_received(spec: Dictionary)
signal projectile_ended_received(net_id: int, pos: Vector2, explode: bool)
signal result_received(result: Dictionary)
signal guest_loaded

const PORT := 7777
const JOIN_TIMEOUT := 8.0

var role := ""                     # "" | "host" | "guest"
var status := "Offline"
var guest_peer_id := 0
var guest_is_loaded := false
var remote_controller := RemoteController.new()

# lobby state (host is the source of truth, mirrored to the guest)
var host_class := "vanguard"
var guest_class := "duelist"
var arena := "forest"
var guest_ready := false
var _join_token := 0
var _peer: ENetMultiplayerPeer


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func is_online() -> bool:
	return role != ""


func is_host() -> bool:
	return role == "host"


func guest_connected() -> bool:
	return guest_peer_id != 0


# ------------------------------------------------------------------ addresses
## Best guess of this device's Wi-Fi/LAN IPv4 address (what the other phone must type).
static func get_local_ip() -> String:
	var best := ""
	for a in IP.get_local_addresses():
		if a.contains(":") or a.begins_with("127.") or a.begins_with("169.254"):
			continue
		if a.begins_with("192.168."):
			return a
		if a.begins_with("10.") or (a.begins_with("172.") and int(a.split(".")[1]) >= 16 and int(a.split(".")[1]) <= 31):
			if best == "":
				best = a
	return best


static func is_valid_ipv4(text: String) -> bool:
	var parts := text.strip_edges().split(".")
	if parts.size() != 4:
		return false
	for p in parts:
		if not p.is_valid_int() or int(p) < 0 or int(p) > 255:
			return false
	return true


# ------------------------------------------------------------------ host / join / leave
func host_game() -> bool:
	leave()
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_server(PORT, 1)
	if err != OK:
		_peer = null
		var msg := "Could not host a match (port %d may be in use). Error %d." % [PORT, err]
		_set_status(msg)
		connection_failed.emit(msg)
		return false
	multiplayer.multiplayer_peer = _peer
	role = "host"
	guest_peer_id = 0
	guest_ready = false
	guest_is_loaded = false
	arena = GameState.online_arena
	host_class = GameState.selected_class
	_set_status("Hosting on %s:%d - waiting for a player..." % [get_local_ip() if get_local_ip() != "" else "no Wi-Fi address", PORT])
	return true


func join_game(ip: String) -> bool:
	leave()
	ip = ip.strip_edges()
	if not is_valid_ipv4(ip):
		var msg := "That is not a valid IP address. Example: 192.168.1.23"
		_set_status(msg)
		connection_failed.emit(msg)
		return false
	_peer = ENetMultiplayerPeer.new()
	var err := _peer.create_client(ip, PORT)
	if err != OK:
		_peer = null
		var msg2 := "Could not start connecting (error %d). Is Wi-Fi turned on?" % err
		_set_status(msg2)
		connection_failed.emit(msg2)
		return false
	multiplayer.multiplayer_peer = _peer
	role = "guest"
	guest_class = GameState.selected_class
	guest_ready = false
	_set_status("Connecting to %s:%d ..." % [ip, PORT])
	_join_token += 1
	_start_join_timeout(_join_token, ip)
	return true


func _start_join_timeout(token: int, ip: String) -> void:
	await get_tree().create_timer(JOIN_TIMEOUT).timeout
	if token != _join_token or role != "guest" or multiplayer.multiplayer_peer == null:
		return
	if _peer != null and _peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTING:
		var msg := "Could not reach %s. Check that both phones are on the same Wi-Fi and the host is waiting." % ip
		leave()
		_set_status(msg)
		connection_failed.emit(msg)


func leave() -> void:
	_join_token += 1
	if _peer != null:
		_peer.close()
	_peer = null
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer = null
	role = ""
	guest_peer_id = 0
	guest_ready = false
	guest_is_loaded = false
	remote_controller = RemoteController.new()
	_set_status("Offline")


func _set_status(text: String) -> void:
	status = text
	status_changed.emit(text)


# ------------------------------------------------------------------ connection callbacks
func _on_peer_connected(id: int) -> void:
	if role == "host":
		guest_peer_id = id
		guest_ready = false
		guest_is_loaded = false
		remote_controller = RemoteController.new()
		_set_status("Player connected! Choose a class and press Ready.")
		guest_joined.emit()
		_push_lobby()


func _on_peer_disconnected(id: int) -> void:
	if role == "host" and id == guest_peer_id:
		guest_peer_id = 0
		guest_ready = false
		_set_status("The other player left. Waiting for a new player...")
		disconnected.emit("The other player disconnected.")
		lobby_changed.emit()


func _on_connected_to_server() -> void:
	_set_status("Connected to host! Choose a class and press Ready.")
	_join_token += 1
	_srv_set_class.rpc_id(1, guest_class)
	guest_joined.emit()


func _on_connection_failed() -> void:
	var msg := "Connection failed. Check the host IP address and that both phones share the same Wi-Fi."
	leave()
	_set_status(msg)
	connection_failed.emit(msg)


func _on_server_disconnected() -> void:
	var msg := "The host disconnected."
	leave()
	_set_status(msg)
	disconnected.emit(msg)


# ------------------------------------------------------------------ lobby
func lobby_dict() -> Dictionary:
	return {"host_class": host_class, "guest_class": guest_class, "arena": arena, "guest_ready": guest_ready}


func _push_lobby() -> void:
	lobby_changed.emit()
	if role == "host" and guest_connected():
		_cli_lobby.rpc_id(guest_peer_id, lobby_dict())


func host_set_class(class_id: String) -> void:
	host_class = class_id
	_push_lobby()


func host_set_arena(arena_id: String) -> void:
	arena = arena_id
	GameState.online_arena = arena_id
	_push_lobby()


func guest_set_class(class_id: String) -> void:
	guest_class = class_id
	if role == "guest":
		_srv_set_class.rpc_id(1, class_id)


func guest_set_ready(value: bool) -> void:
	guest_ready = value
	if role == "guest":
		_srv_ready.rpc_id(1, value)


func host_can_start() -> bool:
	return role == "host" and guest_connected() and guest_ready


func host_start_match() -> void:
	if not host_can_start():
		return
	var info := lobby_dict()
	_cli_start.rpc_id(guest_peer_id, info)
	match_should_start.emit(GameState.build_online_config(host_class, guest_class, arena, "host"))


@rpc("any_peer", "call_remote", "reliable")
func _srv_set_class(class_id: String) -> void:
	if role != "host" or multiplayer.get_remote_sender_id() != guest_peer_id:
		return
	if not Library.class_ids().has(class_id):
		return
	guest_class = class_id
	_push_lobby()


@rpc("any_peer", "call_remote", "reliable")
func _srv_ready(value: bool) -> void:
	if role != "host" or multiplayer.get_remote_sender_id() != guest_peer_id:
		return
	guest_ready = value
	_push_lobby()


@rpc("authority", "call_remote", "reliable")
func _cli_lobby(info: Dictionary) -> void:
	host_class = str(info.get("host_class", host_class))
	arena = str(info.get("arena", arena))
	lobby_changed.emit()


@rpc("authority", "call_remote", "reliable")
func _cli_start(info: Dictionary) -> void:
	host_class = str(info.get("host_class", "vanguard"))
	guest_class = str(info.get("guest_class", "duelist"))
	arena = str(info.get("arena", "forest"))
	match_should_start.emit(GameState.build_online_config(host_class, guest_class, arena, "guest"))


# ------------------------------------------------------------------ in-match: guest -> host (input only)
func send_loaded() -> void:
	if role == "guest":
		_srv_loaded.rpc_id(1)


func send_input(move: float, mask: int) -> void:
	if role == "guest" and multiplayer.multiplayer_peer != null:
		_srv_input.rpc_id(1, move, mask)


func send_press(button: String) -> void:
	if role == "guest" and multiplayer.multiplayer_peer != null:
		_srv_press.rpc_id(1, button)


@rpc("any_peer", "call_remote", "reliable")
func _srv_loaded() -> void:
	if role == "host" and multiplayer.get_remote_sender_id() == guest_peer_id:
		guest_is_loaded = true
		guest_loaded.emit()


@rpc("any_peer", "call_remote", "unreliable_ordered")
func _srv_input(move: float, mask: int) -> void:
	if role == "host" and multiplayer.get_remote_sender_id() == guest_peer_id:
		remote_controller.receive_input(move, mask)


@rpc("any_peer", "call_remote", "reliable")
func _srv_press(button: String) -> void:
	if role == "host" and multiplayer.get_remote_sender_id() == guest_peer_id:
		remote_controller.receive_press(button)


# ------------------------------------------------------------------ in-match: host -> guest
func _can_send() -> bool:
	return role == "host" and guest_connected()


func send_snapshot(data: Array) -> void:
	if _can_send():
		_cli_snapshot.rpc_id(guest_peer_id, data)


func send_fx(kind: String, pos: Vector2, data: Dictionary) -> void:
	if _can_send():
		_cli_fx.rpc_id(guest_peer_id, kind, pos, data)


func send_projectile(spec: Dictionary) -> void:
	if _can_send():
		_cli_projectile.rpc_id(guest_peer_id, spec)


func send_area(spec: Dictionary) -> void:
	if _can_send():
		_cli_area.rpc_id(guest_peer_id, spec)


func send_projectile_end(net_id: int, pos: Vector2, explode: bool) -> void:
	if _can_send():
		_cli_projectile_end.rpc_id(guest_peer_id, net_id, pos, explode)


func send_sfx(sfx_name: String, pitch: float) -> void:
	if _can_send():
		_cli_sfx.rpc_id(guest_peer_id, sfx_name, pitch)


func send_result(result: Dictionary) -> void:
	if _can_send():
		_cli_result.rpc_id(guest_peer_id, result)


@rpc("authority", "call_remote", "unreliable_ordered")
func _cli_snapshot(data: Array) -> void:
	snapshot_received.emit(data)


@rpc("authority", "call_remote", "reliable")
func _cli_fx(kind: String, pos: Vector2, data: Dictionary) -> void:
	fx_received.emit(kind, pos, data)


@rpc("authority", "call_remote", "reliable")
func _cli_projectile(spec: Dictionary) -> void:
	projectile_received.emit(spec)


@rpc("authority", "call_remote", "reliable")
func _cli_area(spec: Dictionary) -> void:
	area_received.emit(spec)


@rpc("authority", "call_remote", "reliable")
func _cli_projectile_end(net_id: int, pos: Vector2, explode: bool) -> void:
	projectile_ended_received.emit(net_id, pos, explode)


@rpc("authority", "call_remote", "unreliable")
func _cli_sfx(sfx_name: String, pitch: float) -> void:
	AudioManager.play_sfx(sfx_name, pitch, 0.0, false)


@rpc("authority", "call_remote", "reliable")
func _cli_result(result: Dictionary) -> void:
	result_received.emit(result)
