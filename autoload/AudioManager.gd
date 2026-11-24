extends Node
## All audio is synthesised at runtime (jsfxr-style SFX + a tiny chiptune sequencer),
## so the project ships with no third-party audio files. Replaceable by real assets later.

const RATE := 22050
const MUSIC_RATE := 11025
const SFX_POOL := 10

var _sfx_cache: Dictionary = {}
var _music_cache: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _next_player := 0
var _current_track := ""
var _last_play_time: Dictionary = {}

# name -> [wave, f0, f1, duration, volume, noise_mix]
const SFX := {
	"click": ["sq", 660.0, 880.0, 0.06, 0.35, 0.0],
	"back": ["sq", 520.0, 320.0, 0.08, 0.35, 0.0],
	"lock": ["sq", 180.0, 120.0, 0.18, 0.4, 0.2],
	"swing": ["noise", 900.0, 300.0, 0.12, 0.30, 0.8],
	"hit": ["sq", 260.0, 90.0, 0.12, 0.5, 0.5],
	"hit_heavy": ["sq", 190.0, 50.0, 0.22, 0.6, 0.7],
	"hurt": ["sq", 420.0, 160.0, 0.18, 0.45, 0.2],
	"jump": ["tri", 280.0, 620.0, 0.14, 0.45, 0.0],
	"dodge": ["noise", 500.0, 1200.0, 0.16, 0.30, 0.9],
	"shoot": ["sq", 900.0, 300.0, 0.10, 0.35, 0.1],
	"magic": ["sine", 400.0, 1100.0, 0.20, 0.40, 0.0],
	"explosion": ["noise", 300.0, 40.0, 0.45, 0.65, 0.95],
	"shield": ["tri", 220.0, 440.0, 0.30, 0.5, 0.0],
	"dash": ["noise", 300.0, 900.0, 0.18, 0.35, 0.85],
	"nova": ["sine", 900.0, 180.0, 0.40, 0.5, 0.3],
	"meteor": ["noise", 1000.0, 60.0, 0.60, 0.55, 0.8],
	"death": ["sq", 330.0, 40.0, 0.60, 0.55, 0.3],
	"tick": ["sq", 880.0, 880.0, 0.07, 0.35, 0.0],
	"fight": ["sq", 440.0, 880.0, 0.35, 0.5, 0.0],
	"lava": ["noise", 200.0, 80.0, 0.30, 0.5, 0.9],
	"star": ["tri", 660.0, 1320.0, 0.25, 0.45, 0.0],
}
const JINGLES := {
	"win": [[523.25, 0.12], [659.25, 0.12], [783.99, 0.12], [1046.5, 0.40]],
	"lose": [[392.0, 0.18], [349.23, 0.18], [311.13, 0.18], [261.63, 0.50]],
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus("Music")
	_ensure_bus("SFX")
	for i in SFX_POOL:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	_music_player.finished.connect(_on_music_finished)
	SaveManager.settings_changed.connect(apply_settings)
	apply_settings()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")


func apply_settings() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(SaveManager.master_volume, 0.0001)))
	var sfx_idx := AudioServer.get_bus_index("SFX")
	var mus_idx := AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(maxf(SaveManager.sfx_volume, 0.0001)))
	AudioServer.set_bus_volume_db(mus_idx, linear_to_db(maxf(SaveManager.music_volume, 0.0001)) - 6.0)
	AudioServer.set_bus_mute(sfx_idx, not SaveManager.sound_on)
	AudioServer.set_bus_mute(mus_idx, not SaveManager.music_on)


# ------------------------------------------------------------------ public API
func play_sfx(sfx_name: String, pitch: float = 1.0, volume_db: float = 0.0, broadcast: bool = true) -> void:
	if not SaveManager.sound_on and broadcast:
		_broadcast_sfx(sfx_name, pitch, broadcast)
		return
	if not SaveManager.sound_on:
		return
	# throttle identical sounds so rapid multi-hits do not clip
	var now := Time.get_ticks_msec()
	if now - int(_last_play_time.get(sfx_name, -1000)) < 45:
		return
	_last_play_time[sfx_name] = now
	_broadcast_sfx(sfx_name, pitch, broadcast)
	var stream := _get_sfx(sfx_name)
	if stream == null:
		return
	var p := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = volume_db
	p.play()


func _broadcast_sfx(sfx_name: String, pitch: float, broadcast: bool) -> void:
	# the online host mirrors gameplay sounds to the guest (guest plays them locally)
	if broadcast and NetworkManager.is_host() and NetworkManager.guest_connected() and GameState.pending_match.get("mode", "") == "online":
		NetworkManager.send_sfx(sfx_name, pitch)


func play_music(track: String) -> void:
	if _current_track == track and _music_player.playing:
		return
	_current_track = track
	var stream := _get_music(track)
	_music_player.stream = stream
	_music_player.play()


func _on_music_finished() -> void:
	if _current_track != "":
		_music_player.play()


func stop_music() -> void:
	_current_track = ""
	_music_player.stop()


# ------------------------------------------------------------------ synthesis
func _get_sfx(sfx_name: String) -> AudioStreamWAV:
	if _sfx_cache.has(sfx_name):
		return _sfx_cache[sfx_name]
	var stream: AudioStreamWAV = null
	if SFX.has(sfx_name):
		var d: Array = SFX[sfx_name]
		stream = _make_stream(_tone(d[0], d[1], d[2], d[3], d[4], d[5]), RATE, false)
	elif JINGLES.has(sfx_name):
		var samples := PackedFloat32Array()
		for note in JINGLES[sfx_name]:
			samples.append_array(_tone("sq", note[0], note[0], note[1], 0.4, 0.0))
		stream = _make_stream(samples, RATE, false)
	_sfx_cache[sfx_name] = stream
	return stream


func _tone(wave: String, f0: float, f1: float, dur: float, vol: float, noise_mix: float) -> PackedFloat32Array:
	var n := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var last_noise := 0.0
	for i in n:
		var t := float(i) / n
		var f := lerpf(f0, f1, t)
		phase += f / RATE
		var ph := fmod(phase, 1.0)
		var v := 0.0
		match wave:
			"sq":
				v = 1.0 if ph < 0.5 else -1.0
			"tri":
				v = 4.0 * absf(ph - 0.5) - 1.0
			"sine":
				v = sin(ph * TAU)
			_:
				v = 0.0
		if noise_mix > 0.0 or wave == "noise":
			if i % maxi(1, int(RATE / maxf(f, 100.0) / 2.0)) == 0:
				last_noise = rng.randf_range(-1.0, 1.0)
			var mix := 1.0 if wave == "noise" else noise_mix
			v = lerpf(v, last_noise, mix)
		var env := minf(float(i) / (RATE * 0.004), 1.0) * pow(1.0 - t, 1.6)
		out[i] = v * env * vol
	return out


func _make_stream(samples: PackedFloat32Array, rate: int, loop: bool) -> AudioStreamWAV:
	# trailing silence: the Android mixer can read a few frames past the end (caused a SIGSEGV with looping streams)
	samples = samples.duplicate()
	for i in 16:
		samples.append(0.0)
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.stereo = false
	s.data = bytes
	return s  # looping is done by replaying the track in _on_music_finished (native loop crashed on Android)


static func _midi(n: int) -> float:
	return 440.0 * pow(2.0, (n - 69) / 12.0)


func _get_music(track: String) -> AudioStreamWAV:
	if _music_cache.has(track):
		return _music_cache[track]
	var battle := track == "battle"
	var bpm := 150.0 if battle else 84.0
	var step_len := 60.0 / bpm / 4.0
	var chords: Array = [[57, 60, 64], [53, 57, 60], [48, 52, 55], [55, 59, 62]]  # Am F C G
	if not battle:
		chords = [[57, 60, 64], [55, 59, 62], [53, 57, 60], [52, 56, 59]]
	var steps_per_chord := 16
	var total_steps := steps_per_chord * chords.size()
	var n := int(total_steps * step_len * MUSIC_RATE)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var arp_pattern := [0, 1, 2, 1, 2, 1, 0, 1] if battle else [0, 2, 1, 2]
	for step in total_steps:
		var chord: Array = chords[step / steps_per_chord]
		var s0 := int(step * step_len * MUSIC_RATE)
		var s1 := mini(int((step + 1) * step_len * MUSIC_RATE), n)
		var arp_note: int = chord[arp_pattern[step % arp_pattern.size()]] + 12
		var bass_note: int = chord[0] - 12
		var lead_f := _midi(arp_note)
		var bass_f := _midi(bass_note)
		for i in range(s0, s1):
			var local := float(i - s0) / maxf(float(s1 - s0), 1.0)
			var tt := float(i) / MUSIC_RATE
			var lead := (1.0 if fmod(tt * lead_f, 1.0) < 0.25 else -1.0) * 0.16 * (1.0 - local * 0.7)
			var bass := (4.0 * absf(fmod(tt * bass_f, 1.0) - 0.5) - 1.0) * 0.30
			var v := lead + bass
			if battle:
				if step % 4 == 0:
					v += sin(local * 40.0 * (1.0 - local)) * 0.35 * (1.0 - local)  # kick
				elif step % 4 == 2:
					v += rng.randf_range(-1.0, 1.0) * 0.07 * (1.0 - local)  # hat
			elif step % 8 == 0:
				v += sin(tt * _midi(chord[2] + 12) * TAU) * 0.08 * (1.0 - local)  # soft bell
			buf[i] = v
	var stream := _make_stream(buf, MUSIC_RATE, false)
	_music_cache[track] = stream
	return stream
