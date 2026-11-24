class_name LanDiscovery
extends RefCounted
## Finds a hosted match on the same Wi-Fi so nobody has to type an IP address.
## The guest broadcasts a query on UDP port 7778; a waiting host answers directly to the sender,
## and the guest takes the host's address from that reply. Call poll() every frame.
## (On Android, enabling broadcast makes Godot take the Wi-Fi multicast lock, which needs the
## CHANGE_WIFI_MULTICAST_STATE permission in the export preset.)

const PORT := 7778
const QUERY := "RIFTBOUND?1"
const REPLY := "RIFTBOUND!1"

var _udp: PacketPeerUDP


func start_host() -> bool:
	stop()
	_udp = PacketPeerUDP.new()
	if _udp.bind(PORT, "0.0.0.0") != OK:
		_udp = null
		return false
	_udp.set_broadcast_enabled(true)
	return true


func start_search() -> bool:
	stop()
	_udp = PacketPeerUDP.new()
	if _udp.bind(0, "0.0.0.0") != OK:
		_udp = null
		return false
	_udp.set_broadcast_enabled(true)
	return true


func stop() -> void:
	if _udp != null:
		_udp.close()
		_udp = null


## The global broadcast address plus each local /24 broadcast (some phone hotspots only pass the latter).
static func broadcast_targets() -> PackedStringArray:
	var out := PackedStringArray(["255.255.255.255"])
	for a in IP.get_local_addresses():
		if a.contains(":") or a.begins_with("127.") or a.begins_with("169.254"):
			continue
		var directed := a.substr(0, a.rfind(".")) + ".255"
		if not out.has(directed):
			out.append(directed)
	return out


func send_query(targets: PackedStringArray = broadcast_targets()) -> void:
	if _udp == null:
		return
	for t in targets:
		_udp.set_dest_address(t, PORT)
		_udp.put_packet(QUERY.to_utf8_buffer())


## Host side: answer every valid query while `open` (a full match stays silent).
func poll_host(open: bool) -> void:
	while _udp != null and _udp.get_available_packet_count() > 0:
		var text := _udp.get_packet().get_string_from_ascii()
		var ip := _udp.get_packet_ip()
		var port := _udp.get_packet_port()
		if open and text == QUERY:
			_udp.set_dest_address(ip, port)
			_udp.put_packet(REPLY.to_utf8_buffer())


## Guest side: returns the addresses of hosts that answered since the last call.
func poll_search() -> PackedStringArray:
	var found := PackedStringArray()
	while _udp != null and _udp.get_available_packet_count() > 0:
		var text := _udp.get_packet().get_string_from_ascii()
		var ip := _udp.get_packet_ip()
		if text == REPLY and not found.has(ip):
			found.append(ip)
	return found
