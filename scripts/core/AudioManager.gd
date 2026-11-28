class_name AudioManager
extends Node

const SaveManager = preload("res://scripts/core/SaveManager.gd")

var sfx_player_pool: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer
var pool_size: int = 8

var sounds: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	engine_player = AudioStreamPlayer.new()
	engine_player.bus = "SFX"
	add_child(engine_player)
	
	for i in range(pool_size):
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_player_pool.append(p)
	
	_generate_procedural_sounds()
	update_volumes()

func update_volumes() -> void:
	var sound_vol: float = SaveManager.get_sound_volume()
	var music_vol: float = SaveManager.get_music_volume()
	var sfx_bus_idx := AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sound_vol))
	var music_bus_idx := AudioServer.get_bus_index("Music")
	if music_bus_idx != -1:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_vol))

func play_sfx(sound_name: String, pitch: float = 1.0, volume_scale: float = 1.0) -> void:
	if not sounds.has(sound_name):
		return
	var stream: AudioStream = sounds[sound_name]
	var sound_vol: float = SaveManager.get_sound_volume()
	for player in sfx_player_pool:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = pitch
			player.volume_db = linear_to_db(sound_vol * volume_scale)
			player.play()
			return

func start_engine() -> void:
	if sounds.has("engine_loop") and engine_player:
		engine_player.stream = sounds["engine_loop"]
		var sound_vol: float = SaveManager.get_sound_volume()
		engine_player.volume_db = linear_to_db(sound_vol * 0.45)
		if not engine_player.playing:
			engine_player.play()

func stop_engine() -> void:
	if engine_player:
		engine_player.stop()

func update_engine_pitch(speed_ratio: float) -> void:
	if engine_player and engine_player.playing:
		# Pitch ranges from 0.8 (idle) to 2.2 (redline)
		engine_player.pitch_scale = lerpf(0.8, 2.2, clampf(speed_ratio, 0.0, 1.0))

func play_music(stream: AudioStream) -> void:
	if music_player:
		music_player.stream = stream
		var music_vol: float = SaveManager.get_music_volume()
		music_player.volume_db = linear_to_db(music_vol)
		music_player.play()


# Generate crisp procedural AudioStreamWAV for immediate standalone functionality
func _generate_procedural_sounds() -> void:
	sounds["coin"] = _create_beep_wav(880.0, 1320.0, 0.15, true)
	sounds["fuel"] = _create_beep_wav(440.0, 660.0, 0.25, false)
	sounds["nitro"] = _create_noise_wav(0.4, 0.8)
	sounds["crash"] = _create_noise_wav(0.5, 0.4)
	sounds["click"] = _create_beep_wav(600.0, 600.0, 0.05, false)
	sounds["engine_loop"] = _create_engine_wav()

func _create_beep_wav(f_start: float, f_end: float, duration: float, sweep: bool) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		var progress := float(i) / float(num_samples)
		var freq := lerpf(f_start, f_end, progress) if sweep else f_start
		var env := 1.0 - progress
		var sample := sin(t * freq * TAU) * env * 0.6
		var byte_val := int((sample + 1.0) * 127.5)
		data[i] = byte_val
		
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func _create_noise_wav(duration: float, decay_rate: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(num_samples)
	
	for i in range(num_samples):
		var progress := float(i) / float(num_samples)
		var env := exp(-progress * decay_rate * 5.0)
		var rnd := (randf() * 2.0 - 1.0) * env * 0.7
		var byte_val := int((rnd + 1.0) * 127.5)
		data[i] = byte_val
		
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func _create_engine_wav() -> AudioStreamWAV:
	var sample_rate := 22050
	var duration := 0.25 # Short loop
	var num_samples := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(num_samples)
	
	var base_freq := 45.0
	for i in range(num_samples):
		var t := float(i) / float(sample_rate)
		# Sawtooth-like motor rumble with harmonics
		var s := 0.5 * sin(t * base_freq * TAU) + 0.3 * sin(t * base_freq * 2.0 * TAU) + 0.15 * (randf() * 2.0 - 1.0)
		var byte_val := int((clampf(s, -1.0, 1.0) + 1.0) * 127.5)
		data[i] = byte_val
		
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = num_samples
	wav.data = data
	return wav
