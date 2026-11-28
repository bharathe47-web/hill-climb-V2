class_name HomeWindController
extends Node2D

## HomeWindController: Lightweight, state-driven outdoor wind system for the Home Menu only.
## Coordinates periodic wind gusts across flying leaves, low ground dust, subtle wind streaks,
## all four hanging wooden signboards, and seamless ambience/gust audio using one shared
## wind_intensity value in [0.0, 1.0].

enum WindState {
	IDLE = 0,
	APPROACHING = 1,
	ACTIVE = 2,
	FADING = 3,
}

signal wind_state_changed(new_state: int)
signal wind_gust_started(peak_intensity: float)

const DESIGN_WIDTH := 1920.0
const MAX_DELTA_STEP := 0.05
const HISTORY_WINDOW := 1.2

# Collected leaf textures (6 variations)
const LEAF_TEXTURES: Array[Texture2D] = [
	preload("res://assets/effects/wind/leaves/leaf_01_oval.png"),
	preload("res://assets/effects/wind/leaves/leaf_02_teardrop.png"),
	preload("res://assets/effects/wind/leaves/leaf_03_lobed.png"),
	preload("res://assets/effects/wind/leaves/leaf_04_maple.png"),
	preload("res://assets/effects/wind/leaves/leaf_05_heart.png"),
	preload("res://assets/effects/wind/leaves/leaf_06_serrated.png"),
]

# Collected dust textures (2 variations)
const DUST_TEXTURES: Array[Texture2D] = [
	preload("res://assets/effects/wind/dust/dust_01_soft_puff.png"),
	preload("res://assets/effects/wind/dust/dust_02_wispy_cloud.png"),
]

# Collected wind streak textures (2 variations)
const STREAK_TEXTURES: Array[Texture2D] = [
	preload("res://assets/effects/wind/streaks/wind_streak_01_single_wave.png"),
	preload("res://assets/effects/wind/streaks/wind_streak_02_double_stream.png"),
]

# Collected audio assets
const AUDIO_AMBIENCE: AudioStreamOggVorbis = preload("res://assets/effects/wind/audio/ambience/wind_ambience_loop.ogg")
const AUDIO_GUSTS: Array[AudioStream] = [
	preload("res://assets/effects/wind/audio/gusts/wind_gust_01_soft.ogg"),
	preload("res://assets/effects/wind/audio/gusts/wind_gust_02_breeze.ogg"),
]

@export var signboard_paths: Array[NodePath] = []

@export_group("Gust Timing (Seconds)")
@export var initial_gust_delay_min: float = 2.0
@export var initial_gust_delay_max: float = 4.0
@export var gust_interval_min: float = 8.0
@export var gust_interval_max: float = 16.0
@export var fade_in_duration_min: float = 0.5
@export var fade_in_duration_max: float = 0.8
@export var active_duration_min: float = 1.5
@export var active_duration_max: float = 3.0
@export var fade_out_duration_min: float = 0.6
@export var fade_out_duration_max: float = 1.2

@export_group("Wind Strength")
@export_range(0.2, 1.0, 0.05) var peak_intensity_min: float = 0.72
@export_range(0.2, 1.0, 0.05) var peak_intensity_max: float = 1.0

@export_group("Audio")
@export var enable_audio: bool = true
@export var ambience_volume_db: float = 2.0
@export var gust_volume_db: float = 4.0

var current_state: WindState = WindState.IDLE
var wind_intensity: float = 0.0

var _rng := RandomNumberGenerator.new()
var _time: float = 0.0
var _state_timer: float = 0.0
var _state_duration: float = 3.0
var _target_peak_intensity: float = 0.85
var _fade_start_intensity: float = 0.0

var _signboards: Array[HomeSignboard] = []
var _leaf_emitters: Array[CPUParticles2D] = []
var _dust_emitters: Array[CPUParticles2D] = []
var _streak_pool: Array[Dictionary] = []
var _streak_cooldown: float = 0.0

var _intensity_history: Array[Vector2] = [] # x = timestamp, y = wind_intensity

var _ambience_player: AudioStreamPlayer = null
var _gust_player: AudioStreamPlayer = null
var _gust_index: int = 0
var _was_visible: bool = true

func _ready() -> void:
	_rng.randomize()
	_resolve_signboards()
	_build_leaf_emitters()
	_build_dust_emitters()
	_build_streak_pool()
	_build_audio_players()
	visibility_changed.connect(_on_visibility_changed)
	_enter_idle(true)
	_start_ambience_if_visible()

func _exit_tree() -> void:
	_stop_all_effects()

func _process(delta: float) -> void:
	var visible_now := is_visible_in_tree()
	if not visible_now:
		if _was_visible:
			_was_visible = false
			_stop_all_effects()
		return
	if not _was_visible:
		_was_visible = true
		_start_ambience_if_visible()

	var dt := minf(delta, MAX_DELTA_STEP)
	_time += dt
	_update_state_machine(dt)
	_record_intensity_sample()
	_update_particles()
	_update_streaks(dt)
	_update_signboards()
	_update_gust_audio()

## Starts a gust immediately (useful for verification or scripted triggers); ignores if already in a gust.
func trigger_gust(peak_override: float = -1.0) -> void:
	if current_state != WindState.IDLE:
		return
	_enter_approaching(peak_override)

func _resolve_signboards() -> void:
	_signboards.clear()
	for path in signboard_paths:
		var board := get_node_or_null(path) as HomeSignboard
		if is_instance_valid(board):
			_signboards.append(board)

func _build_leaf_emitters() -> void:
	var leaf_container := Node2D.new()
	leaf_container.name = "LeafParticles"
	add_child(leaf_container)

	var shared_alpha_ramp := _make_fade_ramp(0.12, 0.82, Color(1.0, 1.0, 1.0, 0.92))
	for i in range(LEAF_TEXTURES.size()):
		var emitter := CPUParticles2D.new()
		emitter.name = "LeafEmitter_%02d" % (i + 1)
		emitter.texture = LEAF_TEXTURES[i]
		emitter.position = Vector2(-95.0, 500.0)
		emitter.emitting = false
		emitter.amount = 3
		emitter.lifetime = 5.4 + float(i % 3) * 0.45
		emitter.preprocess = 0.0
		emitter.explosiveness = 0.0
		emitter.randomness = 0.55
		emitter.lifetime_randomness = 0.25
		emitter.local_coords = false
		emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		emitter.emission_rect_extents = Vector2(36.0, 310.0)
		emitter.direction = Vector2(1.0, 0.06)
		emitter.spread = 14.0
		emitter.gravity = Vector2(20.0, 12.0)
		emitter.initial_velocity_min = 310.0 + float(i % 2) * 35.0
		emitter.initial_velocity_max = 490.0 + float(i % 3) * 30.0
		emitter.angular_velocity_min = -150.0
		emitter.angular_velocity_max = 150.0
		emitter.angle_min = -180.0
		emitter.angle_max = 180.0
		emitter.tangential_accel_min = -26.0
		emitter.tangential_accel_max = 26.0
		emitter.damping_min = 6.0
		emitter.damping_max = 14.0
		emitter.scale_amount_min = 0.09
		emitter.scale_amount_max = 0.16
		emitter.color_ramp = shared_alpha_ramp
		leaf_container.add_child(emitter)
		_leaf_emitters.append(emitter)

func _build_dust_emitters() -> void:
	var dust_container := Node2D.new()
	dust_container.name = "DustParticles"
	add_child(dust_container)

	var dust_ramp := _make_fade_ramp(0.24, 0.72, Color(0.93, 0.89, 0.79, 0.18))
	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.65))
	scale_curve.add_point(Vector2(0.55, 1.0))
	scale_curve.add_point(Vector2(1.0, 1.3))

	for i in range(DUST_TEXTURES.size()):
		var emitter := CPUParticles2D.new()
		emitter.name = "DustEmitter_%02d" % (i + 1)
		emitter.texture = DUST_TEXTURES[i]
		emitter.position = Vector2(560.0, 845.0)
		emitter.emitting = false
		emitter.amount = 6
		emitter.lifetime = 2.6 + float(i) * 0.35
		emitter.randomness = 0.5
		emitter.lifetime_randomness = 0.2
		emitter.local_coords = false
		emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		emitter.emission_rect_extents = Vector2(760.0, 52.0)
		emitter.direction = Vector2(1.0, -0.04)
		emitter.spread = 8.0
		emitter.gravity = Vector2(14.0, -2.0)
		emitter.initial_velocity_min = 155.0
		emitter.initial_velocity_max = 265.0
		emitter.damping_min = 10.0
		emitter.damping_max = 20.0
		emitter.scale_amount_min = 0.28
		emitter.scale_amount_max = 0.52
		emitter.scale_amount_curve = scale_curve
		emitter.color_ramp = dust_ramp
		dust_container.add_child(emitter)
		_dust_emitters.append(emitter)

func _build_streak_pool() -> void:
	var streak_container := Node2D.new()
	streak_container.name = "WindStreaks"
	add_child(streak_container)

	for i in range(5):
		var sprite := Sprite2D.new()
		sprite.name = "WindStreak_%02d" % (i + 1)
		sprite.texture = STREAK_TEXTURES[i % STREAK_TEXTURES.size()]
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		sprite.visible = false
		sprite.modulate = Color(0.95, 0.98, 1.0, 0.0)
		streak_container.add_child(sprite)
		_streak_pool.append({
			"node": sprite,
			"active": false,
			"progress": 0.0,
			"duration": 1.6,
			"start_x": -300.0,
			"travel_x": 2400.0,
			"y": 300.0,
			"peak_alpha": 0.18,
		})

func _build_audio_players() -> void:
	var bus_name := &"Ambience" if AudioServer.get_bus_index(&"Ambience") >= 0 else &"Master"

	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.name = "WindAmbiencePlayer"
	_ambience_player.bus = bus_name
	_ambience_player.volume_db = ambience_volume_db
	var ambience_stream: AudioStreamOggVorbis = AUDIO_AMBIENCE
	ambience_stream.loop = true
	_ambience_player.stream = ambience_stream
	add_child(_ambience_player)

	_gust_player = AudioStreamPlayer.new()
	_gust_player.name = "WindGustPlayer"
	_gust_player.bus = bus_name
	_gust_player.volume_db = -48.0
	add_child(_gust_player)

func _make_fade_ramp(fade_in_t: float, fade_out_t: float, peak_color: Color) -> Gradient:
	var ramp := Gradient.new()
	var zero_color := Color(peak_color.r, peak_color.g, peak_color.b, 0.0)
	ramp.set_offset(0, 0.0)
	ramp.set_color(0, zero_color)
	ramp.set_offset(1, 1.0)
	ramp.set_color(1, zero_color)
	ramp.add_point(fade_in_t, peak_color)
	ramp.add_point(fade_out_t, peak_color)
	return ramp

func _update_state_machine(dt: float) -> void:
	_state_timer += dt
	var t := clampf(_state_timer / maxf(_state_duration, 0.01), 0.0, 1.0)

	match current_state:
		WindState.IDLE:
			wind_intensity = 0.0
			if _state_timer >= _state_duration:
				_enter_approaching()
		WindState.APPROACHING:
			wind_intensity = smoothstep(0.0, 1.0, t) * _target_peak_intensity
			if t >= 1.0:
				_enter_active()
		WindState.ACTIVE:
			var wave := 0.90 + 0.10 * sin(_time * 3.1)
			wind_intensity = _target_peak_intensity * wave
			if _state_timer >= _state_duration:
				_enter_fading()
		WindState.FADING:
			wind_intensity = lerpf(_fade_start_intensity, 0.0, smoothstep(0.0, 1.0, t))
			if t >= 1.0:
				_enter_idle(false)

func _enter_idle(is_initial: bool) -> void:
	current_state = WindState.IDLE
	wind_intensity = 0.0
	_state_timer = 0.0
	if is_initial:
		_state_duration = _rng.randf_range(initial_gust_delay_min, initial_gust_delay_max)
	else:
		_state_duration = _rng.randf_range(gust_interval_min, gust_interval_max)
	wind_state_changed.emit(current_state)

func _enter_approaching(peak_override: float = -1.0) -> void:
	current_state = WindState.APPROACHING
	_state_timer = 0.0
	_state_duration = _rng.randf_range(fade_in_duration_min, fade_in_duration_max)
	_target_peak_intensity = clampf(peak_override, 0.2, 1.0) if peak_override > 0.0 \
			else _rng.randf_range(peak_intensity_min, peak_intensity_max)
	_streak_cooldown = 0.15
	_play_gust_audio()
	wind_state_changed.emit(current_state)
	wind_gust_started.emit(_target_peak_intensity)

func _enter_active() -> void:
	current_state = WindState.ACTIVE
	_state_timer = 0.0
	_state_duration = _rng.randf_range(active_duration_min, active_duration_max)
	wind_state_changed.emit(current_state)

func _enter_fading() -> void:
	current_state = WindState.FADING
	_state_timer = 0.0
	_state_duration = _rng.randf_range(fade_out_duration_min, fade_out_duration_max)
	_fade_start_intensity = wind_intensity
	wind_state_changed.emit(current_state)

func _record_intensity_sample() -> void:
	_intensity_history.append(Vector2(_time, wind_intensity))
	var cutoff := _time - HISTORY_WINDOW
	while _intensity_history.size() > 2 and _intensity_history[1].x < cutoff:
		_intensity_history.remove_at(0)

func _sample_intensity_delayed(delay_sec: float) -> float:
	if delay_sec <= 0.001 or _intensity_history.is_empty():
		return wind_intensity
	var target_t := _time - delay_sec
	if target_t <= _intensity_history[0].x:
		return _intensity_history[0].y
	for i in range(_intensity_history.size() - 1, 0, -1):
		var a := _intensity_history[i - 1]
		var b := _intensity_history[i]
		if target_t >= a.x:
			var frac := clampf((target_t - a.x) / maxf(b.x - a.x, 0.0001), 0.0, 1.0)
			return lerpf(a.y, b.y, frac)
	return wind_intensity

func _update_particles() -> void:
	var tier1_active := wind_intensity > 0.15 and current_state != WindState.FADING
	var tier2_active := wind_intensity > 0.45 and current_state == WindState.ACTIVE
	for i in range(_leaf_emitters.size()):
		var should_emit := tier2_active if (i % 2 == 1) else tier1_active
		if _leaf_emitters[i].emitting != should_emit:
			_leaf_emitters[i].emitting = should_emit

	var dust_tier1 := wind_intensity > 0.22 and current_state != WindState.FADING
	var dust_tier2 := wind_intensity > 0.55 and current_state == WindState.ACTIVE
	if _dust_emitters.size() >= 2:
		if _dust_emitters[0].emitting != dust_tier1:
			_dust_emitters[0].emitting = dust_tier1
		if _dust_emitters[1].emitting != dust_tier2:
			_dust_emitters[1].emitting = dust_tier2

func _update_streaks(dt: float) -> void:
	if wind_intensity >= 0.38 and current_state != WindState.FADING:
		_streak_cooldown -= dt
		if _streak_cooldown <= 0.0:
			_spawn_pooled_streak()
			_streak_cooldown = _rng.randf_range(0.35, 0.72)

	for slot in _streak_pool:
		if not slot["active"]:
			continue
		var sprite: Sprite2D = slot["node"]
		slot["progress"] += dt / slot["duration"]
		var p: float = slot["progress"]
		if p >= 1.0:
			slot["active"] = false
			sprite.visible = false
			continue
		sprite.position.x = slot["start_x"] + slot["travel_x"] * p
		var fade := sin(PI * p)
		var gust_factor := clampf(0.35 + wind_intensity * 0.65, 0.0, 1.0)
		sprite.modulate.a = slot["peak_alpha"] * fade * gust_factor

func _spawn_pooled_streak() -> void:
	for slot in _streak_pool:
		if slot["active"]:
			continue
		var sprite: Sprite2D = slot["node"]
		var sx := _rng.randf_range(0.55, 1.15)
		var sy := _rng.randf_range(0.16, 0.28)
		var start_x := _rng.randf_range(-340.0, 180.0)
		var y := _rng.randf_range(120.0, 680.0)
		slot["active"] = true
		slot["progress"] = 0.0
		slot["duration"] = _rng.randf_range(1.3, 2.1)
		slot["start_x"] = start_x
		slot["travel_x"] = DESIGN_WIDTH - start_x + 360.0
		slot["y"] = y
		slot["peak_alpha"] = _rng.randf_range(0.13, 0.22)
		sprite.position = Vector2(start_x, y)
		sprite.scale = Vector2(sx, sy)
		sprite.modulate.a = 0.0
		sprite.visible = true
		return

func _update_signboards() -> void:
	for board in _signboards:
		if not is_instance_valid(board):
			continue
		var delayed := _sample_intensity_delayed(board.wind_delay_seconds)
		board.set_wind_intensity(delayed)

func _start_ambience_if_visible() -> void:
	if not enable_audio or not is_instance_valid(_ambience_player):
		return
	if not is_visible_in_tree():
		return
	_ambience_player.volume_db = ambience_volume_db
	if not _ambience_player.playing:
		_ambience_player.play()

func _play_gust_audio() -> void:
	if not enable_audio or not is_instance_valid(_gust_player):
		return
	if _gust_player.playing:
		return
	_gust_player.stream = AUDIO_GUSTS[_gust_index % AUDIO_GUSTS.size()]
	_gust_index += 1
	_gust_player.volume_db = -36.0
	_gust_player.play()

func _update_gust_audio() -> void:
	if not is_instance_valid(_gust_player) or not _gust_player.playing:
		return
	var target_db := lerpf(-36.0, gust_volume_db, clampf(wind_intensity, 0.0, 1.0))
	_gust_player.volume_db = target_db
	if current_state == WindState.IDLE and wind_intensity <= 0.001:
		_gust_player.stop()

func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		_was_visible = true
		_start_ambience_if_visible()
	else:
		_was_visible = false
		_stop_all_effects()

func _stop_all_effects() -> void:
	wind_intensity = 0.0
	current_state = WindState.IDLE
	_intensity_history.clear()
	for emitter in _leaf_emitters:
		if is_instance_valid(emitter):
			emitter.emitting = false
	for emitter in _dust_emitters:
		if is_instance_valid(emitter):
			emitter.emitting = false
	for slot in _streak_pool:
		slot["active"] = false
		if is_instance_valid(slot["node"]):
			slot["node"].visible = false
	for board in _signboards:
		if is_instance_valid(board):
			board.reset_wind()
	if is_instance_valid(_ambience_player) and _ambience_player.playing:
		_ambience_player.stop()
	if is_instance_valid(_gust_player) and _gust_player.playing:
		_gust_player.stop()
