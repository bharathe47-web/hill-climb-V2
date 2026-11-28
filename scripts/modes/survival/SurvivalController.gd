class_name SurvivalController
extends Node2D

## SurvivalController: Master controller for the Survival game mode.
## Owns authoritative run states, 3-life system, hit debouncing, extra-life reward gating,
## progressive difficulty scaling, spawner coordination for food obstacles, and Shared HUD binding.

const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const SurvivalRewardProvider = preload("res://scripts/modes/survival/SurvivalRewardProvider.gd")
const GroundShadowClass = preload("res://scripts/components/survival_obstacles/ground_shadow.gd")
const ObstacleWarningClass = preload("res://scripts/components/survival_obstacles/obstacle_warning.gd")
const SurvivalDifficultyConfig = preload("res://scripts/modes/survival/SurvivalDifficultyConfig.gd")
const CollectibleSpawnerClass = preload("res://scripts/modes/survival/collectibles/SurvivalCollectibleSpawner.gd")
const PotholeHazardClass = preload("res://scripts/components/survival_obstacles/pothole_hazard.gd")

const DEFAULT_OBSTACLES: Array[PackedScene] = [
	preload("res://scenes/modes/survival/obstacles/idli_obstacle.tscn"),
	preload("res://scenes/modes/survival/obstacles/dosa_obstacle.tscn"),
	preload("res://scenes/modes/survival/obstacles/vada_obstacle.tscn"),
	preload("res://scenes/modes/survival/obstacles/samosa_obstacle.tscn"),
	preload("res://scenes/modes/survival/obstacles/murukku_obstacle.tscn"),
	preload("res://scenes/modes/survival/obstacles/pani_puri_obstacle.tscn"),
	preload("res://scenes/modes/survival/obstacles/jalebi_obstacle.tscn"),
	preload("res://scenes/modes/survival/obstacles/coconut_obstacle.tscn")
]
const DEFAULT_WARNING: PackedScene = preload("res://scenes/modes/survival/warnings/obstacle_warning.tscn")
const DEFAULT_UNBURNED_ASTEROID: PackedScene = preload("res://scenes/modes/survival/obstacles/unburned_asteroid_obstacle.tscn")
const DEFAULT_BURNING_ASTEROID: PackedScene = preload("res://scenes/modes/survival/obstacles/burning_asteroid_obstacle.tscn")
const DEFAULT_POTHOLE: PackedScene = preload("res://scenes/modes/survival/hazards/pothole_hazard.tscn")

enum RunState {
	READY,
	PLAYING,
	PAUSED,
	FINISHED
}

signal return_to_main_menu_requested
signal run_started
signal run_paused(is_paused: bool)
signal run_finished(final_time: float, final_distance: float, reason: String)
signal lives_changed(current_lives: int, max_lives: int)
signal warning_requested(target_position: Vector2, duration: float)

@export var selected_difficulty: int = 0
@export var max_lives: int = 3
@export var invulnerability_duration: float = 0.8
@export var base_spawn_interval: float = 2.4
@export var min_spawn_interval: float = 0.9
@export var difficulty_scale_rate: float = 0.012
@export var spawn_interval: float = 2.4
@export var spawn_height_offset: float = -450.0
@export var warning_lead_time: float = 1.0

## Dedicated configuration to enable/disable obstacle spawning pipeline
@export var enable_obstacle_spawning: bool = false
## Spawns coin and fuel-can collectibles along the route (not required to survive).
@export var enable_collectibles: bool = true
## Survival fuel burn while accelerating, as a fraction of the vehicle's own fuel_burn_rate (0 = fuel never drains).
@export_range(0.0, 2.0) var fuel_burn_scale: float = 0.6
@export var use_default_food_obstacles: bool = false

## Slots for food obstacle scenes (Idli, Dosa, Vada, Samosa, Murukku, Pani Puri, Jalebi, Coconut)
@export var obstacle_scenes: Array[PackedScene] = []
## Slot for ground warning indicator scene
@export var warning_scene: PackedScene = null
## Slot for unburned asteroid scene (Medium and Hard)
@export var unburned_asteroid_scene: PackedScene = null
## Slot for burning asteroid scene (Hard)
@export var burning_asteroid_scene: PackedScene = null
## Slot for pothole road hazard scene (Hard)
@export var pothole_scene: PackedScene = null

@onready var vehicle_slot: Node2D = get_node_or_null("VehicleSlot")
@onready var terrain_generator: TerrainGenerator = get_node_or_null("TerrainGenerator")
@onready var obstacle_container: Node2D = get_node_or_null("ObstacleContainer")
@onready var follow_camera: Camera2D = get_node_or_null("FollowCamera")
@onready var hud: Control = get_node_or_null("UILayer/SurvivalHUD")
@onready var heart_container: HBoxContainer = get_node_or_null("%HeartContainer")
@onready var game_over_panel: Control = get_node_or_null("%GameOverPanel")
@onready var ad_offer_panel: Control = get_node_or_null("%AdOfferPanel")
@onready var time_label: Label = get_node_or_null("%TimeLabel")
@onready var distance_label: Label = get_node_or_null("%DistanceLabel")
@onready var music_player: AudioStreamPlayer = get_node_or_null("%SurvivalMusicPlayer")
@onready var pause_menu: PauseMenuController = get_node_or_null("%PauseMenu")

@export var rollover_threshold_degrees: float = 140.0
@export var rollover_grace_duration: float = 1.0
var _rollover_timer: float = 0.0

const BGM_SURVIVAL_LOOP: AudioStream = preload("res://assets/audio/survival/music/survival_main_theme_loop.ogg")
const BGM_SURVIVAL_EASY: AudioStream = preload("res://assets/audio/survival/music/easy-survial.mp3")
const BGM_SURVIVAL_MEDIUM: AudioStream = preload("res://assets/audio/survival/music/survival-mid.mp3")
const BGM_SURVIVAL_HARD: AudioStream = preload("res://assets/audio/survival/music/hard.mp3")

const SFX_ASTEROID_NORMAL: AudioStream = preload("res://assets/audio/survival/sfx/asteroids/normal_asteroid_impact.wav")
const SFX_ASTEROID_FLAMING: AudioStream = preload("res://assets/audio/survival/sfx/asteroids/flaming_asteroid_impact.wav")
const SFX_FOOD_SQUISH: AudioStream = preload("res://assets/audio/survival/sfx/food/food_impact_soft_squish.wav")
const SFX_FOOD_CRISP_THUD: AudioStream = preload("res://assets/audio/survival/sfx/food/food_impact_crisp_thud.wav")
const SFX_FOOD_PANI_PURI: AudioStream = preload("res://assets/audio/survival/sfx/food/food_pani_puri_pop.wav")
const SFX_FOOD_COCONUT: AudioStream = preload("res://assets/audio/survival/sfx/food/food_coconut_bounce.wav")
const SFX_POTHOLE: AudioStream = preload("res://assets/audio/survival/sfx/other/pothole_suspension_thud.wav")
const SFX_WARNING: AudioStream = preload("res://assets/audio/survival/sfx/other/obstacle_warning_blip.wav")

var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_index: int = 0

var current_state: RunState = RunState.READY
var current_lives: int = 3
var extra_life_used: bool = false
var is_invulnerable: bool = false
var _invulnerability_timer: float = 0.0

var survival_time: float = 0.0
var survival_distance: float = 0.0
var _spawn_timer: float = 0.0
var _unburned_asteroid_timer: float = 0.0
var _burning_asteroid_timer: float = 0.0
var _next_unburned_interval: float = 4.0
var _next_burning_interval: float = 3.5
var _active_potholes: Array[Node2D] = []
var difficulty_config: Dictionary = {}
var _start_x: float = 0.0
var _run_generation: int = 0

var vehicle: Node = null
var collectible_spawner: SurvivalCollectibleSpawner = null
var reward_provider: SurvivalRewardProvider = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_audio()
	if reward_provider == null:
		reward_provider = SurvivalRewardProvider.new()

	# When run directly as standalone gameplay scene, enable obstacle spawning
	if get_tree().current_scene == self:
		enable_obstacle_spawning = true
		use_default_food_obstacles = true

	if (use_default_food_obstacles or get_tree().current_scene == self or obstacle_scenes.is_empty()):
		load_default_obstacles()

	_apply_difficulty_config()
	_setup_vehicle()
	_setup_camera()
	_setup_ui()
	_setup_collectibles()
	start_run()

func _get_bgm_for_difficulty(diff: int) -> AudioStream:
	match diff:
		SurvivalDifficultyConfig.Difficulty.EASY:
			return BGM_SURVIVAL_EASY
		SurvivalDifficultyConfig.Difficulty.MEDIUM:
			return BGM_SURVIVAL_MEDIUM
		SurvivalDifficultyConfig.Difficulty.HARD:
			return BGM_SURVIVAL_HARD
		_:
			return BGM_SURVIVAL_EASY

func _init_audio() -> void:
	# Ensure music player is available
	if not is_instance_valid(music_player):
		music_player = get_node_or_null("%SurvivalMusicPlayer")
	if not is_instance_valid(music_player):
		music_player = AudioStreamPlayer.new()
		music_player.name = "SurvivalMusicPlayer"
		music_player.volume_db = -6.0
		music_player.bus = &"Music"
		add_child(music_player)

	if is_instance_valid(music_player):
		music_player.stream = _get_bgm_for_difficulty(selected_difficulty)
		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)

	# Initialize 4-player SFX pool on "SFX" bus
	if _sfx_players.is_empty():
		for i in range(4):
			var asp := AudioStreamPlayer.new()
			asp.name = "SFXPoolPlayer_%d" % i
			asp.bus = &"SFX"
			add_child(asp)
			_sfx_players.append(asp)

func _on_music_finished() -> void:
	if is_inside_tree() and is_instance_valid(music_player) and current_state != RunState.FINISHED:
		music_player.play()

func _start_bgm() -> void:
	if is_instance_valid(music_player):
		if not music_player.playing:
			music_player.play()

func _stop_bgm() -> void:
	if is_instance_valid(music_player) and music_player.playing:
		music_player.stop()

func play_sfx(stream: AudioStream, vol_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if stream == null or _sfx_players.is_empty():
		return
	var chosen: AudioStreamPlayer = null
	for p in _sfx_players:
		if not p.playing:
			chosen = p
			break
	if chosen == null:
		chosen = _sfx_players[_next_sfx_index]
		_next_sfx_index = (_next_sfx_index + 1) % _sfx_players.size()

	chosen.stream = stream
	chosen.volume_db = vol_db
	chosen.pitch_scale = pitch_scale
	chosen.play()

func _play_obstacle_impact_sfx(obstacle_id: String, obstacle_node: Node = null) -> void:
	var id := obstacle_id.to_lower()
	if id == "" and is_instance_valid(obstacle_node):
		if "obstacle_id" in obstacle_node:
			id = str(obstacle_node.obstacle_id).to_lower()
		elif "burning" in obstacle_node.name.to_lower():
			id = "burning_asteroid"
		elif "unburned" in obstacle_node.name.to_lower():
			id = "unburned_asteroid"

	if "burning" in id or "flaming" in id:
		play_sfx(SFX_ASTEROID_FLAMING, 0.0)
	elif "unburned" in id or "asteroid" in id or "rock" in id:
		play_sfx(SFX_ASTEROID_NORMAL, 0.0)
	elif "idli" in id or "jalebi" in id:
		play_sfx(SFX_FOOD_SQUISH, -1.0)
	elif "pani" in id or "puri" in id:
		play_sfx(SFX_FOOD_PANI_PURI, -1.0)
	elif "coconut" in id:
		play_sfx(SFX_FOOD_COCONUT, -1.0)
	elif "samosa" in id or "dosa" in id or "vada" in id or "murukku" in id:
		play_sfx(SFX_FOOD_CRISP_THUD, -1.0)
	else:
		play_sfx(SFX_FOOD_CRISP_THUD, -2.0)

func set_difficulty(diff: int) -> void:
	selected_difficulty = clampi(diff, 0, 2)
	SaveManager.set_survival_difficulty(selected_difficulty)
	_apply_difficulty_config()

func _apply_difficulty_config() -> void:
	difficulty_config = SurvivalDifficultyConfig.get_config(selected_difficulty)
	_schedule_next_unburned_asteroid()
	_schedule_next_burning_asteroid()
	if is_instance_valid(music_player):
		var target_stream := _get_bgm_for_difficulty(selected_difficulty)
		if music_player.stream != target_stream:
			var was_playing: bool = music_player.playing and not music_player.stream_paused
			music_player.stream = target_stream
			if was_playing or current_state == RunState.PLAYING:
				music_player.play()

func _schedule_next_unburned_asteroid() -> void:
	var min_i: float = float(difficulty_config.get("unburned_asteroid_interval_min", 3.0))
	var max_i: float = float(difficulty_config.get("unburned_asteroid_interval_max", 5.0))
	if max_i > min_i and min_i > 0.0:
		_next_unburned_interval = randf_range(min_i, max_i)
	else:
		_next_unburned_interval = 4.0

func _schedule_next_burning_asteroid() -> void:
	var min_i: float = float(difficulty_config.get("burning_asteroid_interval_min", 2.8))
	var max_i: float = float(difficulty_config.get("burning_asteroid_interval_max", 4.6))
	if max_i > min_i and min_i > 0.0:
		_next_burning_interval = randf_range(min_i, max_i)
	else:
		_next_burning_interval = 3.5

func load_default_obstacles() -> void:
	obstacle_scenes = DEFAULT_OBSTACLES.duplicate()
	if warning_scene == null:
		warning_scene = DEFAULT_WARNING
	if unburned_asteroid_scene == null:
		unburned_asteroid_scene = DEFAULT_UNBURNED_ASTEROID
	if burning_asteroid_scene == null:
		burning_asteroid_scene = DEFAULT_BURNING_ASTEROID
	if pothole_scene == null:
		pothole_scene = DEFAULT_POTHOLE

func get_terrain_surface_y(x: float) -> float:
	if is_instance_valid(terrain_generator) and terrain_generator.has_method("get_surface_y_at_world_x"):
		return terrain_generator.get_surface_y_at_world_x(x)
	return 410.0

func _setup_vehicle() -> void:
	if not is_instance_valid(vehicle_slot):
		return

	for child in vehicle_slot.get_children():
		vehicle_slot.remove_child(child)
		child.queue_free()

	var selected_id: String = SaveManager.get_selected_vehicle_id()
	var veh: VehicleController = VehicleRegistry.instantiate_vehicle(selected_id)
	if not is_instance_valid(veh):
		veh = VehicleRegistry.instantiate_vehicle("blue_flame_truck")

	if is_instance_valid(veh):
		veh.name = "Vehicle"
		veh.nitro_enabled = false # Survival mode has no nitro (no HUD button, keys ignored)
		var spawn_surface_y := get_terrain_surface_y(0.0)
		veh.global_position = Vector2(0.0, spawn_surface_y - 38.0)
		vehicle_slot.add_child(veh)
		vehicle = veh
		if "allow_reverse" in veh:
			veh.allow_reverse = false
		_start_x = veh.global_position.x
		if is_instance_valid(terrain_generator):
			terrain_generator.target = veh
		if veh.has_signal("crashed") and not veh.crashed.is_connected(_on_vehicle_crashed):
			veh.crashed.connect(_on_vehicle_crashed)

## Creates the coin / fuel-can spawner and binds its coin count to the HUD.
func _setup_collectibles() -> void:
	if not enable_collectibles:
		return
	var holder := Node2D.new()
	holder.name = "CollectibleContainer"
	add_child(holder)
	collectible_spawner = CollectibleSpawnerClass.new()
	collectible_spawner.name = "CollectibleSpawner"
	add_child(collectible_spawner)
	collectible_spawner.setup(vehicle, terrain_generator, obstacle_container, self, holder)
	if is_instance_valid(hud) and hud.has_method("set_survival_coins"):
		collectible_spawner.coins_changed.connect(hud.set_survival_coins)

func _setup_camera() -> void:
	if is_instance_valid(follow_camera) and is_instance_valid(vehicle):
		follow_camera.target = vehicle
		if follow_camera.has_method("snap_to_target"):
			follow_camera.snap_to_target()

func _setup_ui() -> void:
	if is_instance_valid(game_over_panel):
		game_over_panel.visible = false
	if is_instance_valid(ad_offer_panel):
		ad_offer_panel.visible = false
	
	if is_instance_valid(hud):
		if hud.has_method("bind_survival_controller"):
			hud.bind_survival_controller(self)
		if is_instance_valid(vehicle) and hud.has_method("bind_vehicle"):
			hud.bind_vehicle(vehicle)

	if is_instance_valid(pause_menu):
		pause_menu.bind_game_manager(self)
		# Survival uses the wooden pause menu (opt-in; PauseMenu.tscn itself is unchanged).
		if pause_menu.has_method("apply_wooden_skin"):
			pause_menu.apply_wooden_skin()
		if not pause_menu.menu_requested.is_connected(_on_menu_pressed):
			pause_menu.menu_requested.connect(_on_menu_pressed)

	_update_heart_display()

func start_run() -> void:
	# 1. Lock the old gameplay state
	current_state = RunState.READY
	lock_vehicle()
	_rollover_timer = 0.0

	# 2. Release held driving and rotation inputs
	Input.action_release("accelerate")
	Input.action_release("brake_reverse")
	Input.action_release("tilt_left")
	Input.action_release("tilt_right")
	Input.action_release("nitro")

	# 3. Invalidate previous delayed obstacle-spawn callbacks
	_run_generation += 1

	# 4. Clear old active obstacles and warning indicators
	_clear_active_obstacles()

	if is_instance_valid(game_over_panel):
		game_over_panel.visible = false
	if is_instance_valid(ad_offer_panel):
		ad_offer_panel.visible = false
	get_tree().paused = false

	# 5 & 6. Reset procedural terrain safely
	if is_instance_valid(terrain_generator):
		terrain_generator.reset_generator(terrain_generator.initial_spawn_point)

	# 7. Calculate new ground surface position
	var spawn_surface_y := get_terrain_surface_y(0.0)
	var spawn_pos := Vector2(0.0, spawn_surface_y - 38.0)

	# 8, 9, 10. Call existing VehicleController.reset_vehicle(spawn_pos)
	if is_instance_valid(vehicle):
		if vehicle.has_method("reset_vehicle"):
			vehicle.reset_vehicle(spawn_pos)
		else:
			vehicle.global_position = spawn_pos
			if vehicle is RigidBody2D:
				vehicle.linear_velocity = Vector2.ZERO
				vehicle.angular_velocity = 0.0
				vehicle.rotation = 0.0
		if "allow_reverse" in vehicle:
			vehicle.allow_reverse = false
		_start_x = vehicle.global_position.x
		if is_instance_valid(terrain_generator):
			terrain_generator.target = vehicle

	# 11 & 12. Restore camera position and clear trauma/shake
	if is_instance_valid(follow_camera):
		follow_camera.target = vehicle
		if follow_camera.has_method("reset_camera"):
			follow_camera.reset_camera()
		elif follow_camera.has_method("snap_to_target"):
			follow_camera.snap_to_target()
		if "trauma" in follow_camera:
			follow_camera.trauma = 0.0

	# 13. Reset HUD and three-life system
	current_lives = max_lives
	extra_life_used = false
	is_invulnerable = false
	_invulnerability_timer = 0.0
	survival_time = 0.0
	survival_distance = 0.0
	_spawn_timer = maxf(0.0, base_spawn_interval - 1.2) if enable_obstacle_spawning else 0.0
	_unburned_asteroid_timer = 0.0
	_burning_asteroid_timer = 0.0
	_apply_difficulty_config()

	_update_heart_display()
	lives_changed.emit(current_lives, max_lives)

	if is_instance_valid(hud):
		if hud.has_method("set_survival_stats"):
			hud.set_survival_stats(survival_time, survival_distance)
		if hud.has_method("hide_message_banner"):
			hud.hide_message_banner()

	if is_instance_valid(time_label):
		time_label.text = "TIME: 0.0s"
	if is_instance_valid(distance_label):
		distance_label.text = "DIST: 0m"

	if is_instance_valid(collectible_spawner):
		collectible_spawner.reset()

	# 14. Unlock gameplay only after reset is complete
	unlock_vehicle()
	current_state = RunState.PLAYING
	_start_bgm()
	run_started.emit()

## Centralized vehicle physics and input locking
func lock_vehicle() -> void:
	if is_instance_valid(vehicle):
		if vehicle.has_method("lock_vehicle"):
			vehicle.lock_vehicle()
		elif vehicle.has_method("set_active"):
			vehicle.set_active(false)
		elif vehicle is RigidBody2D:
			vehicle.linear_velocity = Vector2.ZERO
			vehicle.angular_velocity = 0.0
			vehicle.freeze = true

## Restores vehicle physics and controls
func unlock_vehicle() -> void:
	if is_instance_valid(vehicle):
		if vehicle.has_method("unlock_vehicle"):
			vehicle.unlock_vehicle()
		elif vehicle.has_method("set_active"):
			vehicle.set_active(true)
		elif vehicle is RigidBody2D:
			vehicle.freeze = false

func pause_run(is_paused: bool) -> void:
	if current_state != RunState.PLAYING and current_state != RunState.PAUSED:
		return
	current_state = RunState.PAUSED if is_paused else RunState.PLAYING
	get_tree().paused = is_paused

	# Audio handling: pause or resume background music and sfx
	if is_paused:
		if is_instance_valid(music_player) and music_player.playing:
			music_player.stream_paused = true
		for p in _sfx_players:
			if is_instance_valid(p) and p.playing:
				p.stream_paused = true
	else:
		if is_instance_valid(music_player) and music_player.stream_paused:
			music_player.stream_paused = false
		for p in _sfx_players:
			if is_instance_valid(p) and p.stream_paused:
				p.stream_paused = false

	run_paused.emit(is_paused)

func toggle_pause() -> void:
	if current_state == RunState.PLAYING:
		pause_run(true)
	elif current_state == RunState.PAUSED:
		pause_run(false)

func restart_run() -> void:
	if current_state == RunState.PAUSED:
		pause_run(false)
	start_run()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if current_state != RunState.FINISHED:
			toggle_pause()
		return
	if Input.is_action_just_pressed("restart"):
		start_run()
		return

	if current_state != RunState.PLAYING:
		return

	_check_vehicle_rollover(delta)

	survival_time += delta
	if is_instance_valid(vehicle):
		var dx: float = vehicle.global_position.x - _start_x
		survival_distance = maxf(survival_distance, dx * 0.01)

	if is_instance_valid(hud) and hud.has_method("set_survival_stats"):
		hud.set_survival_stats(survival_time, survival_distance)

	if is_instance_valid(time_label):
		time_label.text = "TIME: %.1fs" % survival_time
	if is_instance_valid(distance_label):
		distance_label.text = "DIST: %dm" % int(survival_distance)

	if is_instance_valid(collectible_spawner):
		collectible_spawner.tick(delta)
	_burn_fuel(delta)

	# Update invulnerability cooldown
	if is_invulnerable:
		_invulnerability_timer -= delta
		if _invulnerability_timer <= 0.0:
			is_invulnerable = false

	# Dynamic difficulty scaling and hazard spawning
	if enable_obstacle_spawning:
		# 1. Food Obstacles (with warning indicators)
		if difficulty_config.get("food_obstacles", true) and not obstacle_scenes.is_empty():
			var current_interval: float = maxf(min_spawn_interval, base_spawn_interval - (survival_time * difficulty_scale_rate))
			_spawn_timer += delta
			if _spawn_timer >= current_interval:
				_spawn_timer = 0.0
				_trigger_obstacle_spawn()

		# 2. Unburned Asteroids (WITHOUT warning indicators - Silent threat)
		if difficulty_config.get("unburned_asteroids", false) and unburned_asteroid_scene != null:
			_unburned_asteroid_timer += delta
			if _unburned_asteroid_timer >= _next_unburned_interval:
				_unburned_asteroid_timer = 0.0
				_schedule_next_unburned_asteroid()
				_trigger_unburned_asteroid_spawn()

		# 3. Burning Asteroids (WITHOUT warning indicators - Fiery threat, craters road)
		if difficulty_config.get("burning_asteroids", false) and burning_asteroid_scene != null:
			_burning_asteroid_timer += delta
			if _burning_asteroid_timer >= _next_burning_interval:
				_burning_asteroid_timer = 0.0
				_schedule_next_burning_asteroid()
				_trigger_burning_asteroid_spawn()

## Minimal Survival fuel use: fuel burns only while the player is accelerating, so the
## collectible fuel cans have a purpose. Running dry only cuts drive power (existing vehicle
## behaviour); it never ends the run.
func _burn_fuel(delta: float) -> void:
	if not enable_collectibles or fuel_burn_scale <= 0.0 or not is_instance_valid(vehicle):
		return
	if vehicle.has_method("consume_fuel") and Input.is_action_pressed("accelerate"):
		vehicle.consume_fuel(float(vehicle.fuel_burn_rate) * fuel_burn_scale * delta)

## Checks whether the vehicle is sustained upside-down beyond the configured grace period.
func _check_vehicle_rollover(delta: float) -> void:
	if current_state != RunState.PLAYING:
		return
	if not is_instance_valid(vehicle):
		_rollover_timer = 0.0
		return

	var rot: float = wrapf(vehicle.global_rotation, -PI, PI)
	var angle_deg: float = rad_to_deg(absf(rot))

	if angle_deg >= rollover_threshold_degrees:
		_rollover_timer += delta
		if _rollover_timer >= rollover_grace_duration:
			finish_run("VEHICLE OVERTURNED")
	else:
		_rollover_timer = 0.0

## Computes safe sky spawn Y above the camera viewport in world coordinates
func get_sky_spawn_y(target_x: float) -> float:
	var surface_y := get_terrain_surface_y(target_x)
	var spawn_y: float = surface_y + spawn_height_offset
	if is_instance_valid(follow_camera):
		var vp_h: float = float(ProjectSettings.get_setting("display/window/size/viewport_height", 720))
		var cam_zoom := follow_camera.zoom
		var half_vp_height := (vp_h * 0.5) / maxf(cam_zoom.y, 0.1)
		var cam_top_world_y := follow_camera.global_position.y - half_vp_height
		# Safe margin above visible top edge
		var offscreen_sky_y := cam_top_world_y - 80.0
		spawn_y = minf(spawn_y, offscreen_sky_y)
		spawn_y = maxf(spawn_y, surface_y - 750.0)
	else:
		spawn_y = minf(spawn_y, surface_y - 520.0)
	return spawn_y

func _trigger_obstacle_spawn() -> void:
	if not enable_obstacle_spawning or obstacle_scenes.is_empty():
		return

	var target_x: float = 0.0
	if is_instance_valid(vehicle):
		var veh_speed: float = 0.0
		if vehicle is RigidBody2D:
			veh_speed = maxf(0.0, (vehicle as RigidBody2D).linear_velocity.x)
		elif "linear_velocity" in vehicle:
			veh_speed = maxf(0.0, vehicle.linear_velocity.x)

		# Forward lead distance based on vehicle forward speed during obstacle fall duration (~0.9s)
		var lead_dist: float = veh_speed * 0.85
		target_x = vehicle.global_position.x + lead_dist + randf_range(140.0, 420.0)
	else:
		target_x = 200.0 + randf_range(50.0, 300.0)

	var surface_y := get_terrain_surface_y(target_x)
	var projected_ground_pos := Vector2(target_x, surface_y)

	# Spawn obstacle visibly from the sky above camera
	var obs := _spawn_obstacle_at(target_x)
	if not is_instance_valid(obs):
		return

	# Query obstacle for actual landing prediction and flight time
	var landing_pos: Vector2 = projected_ground_pos
	var impact_duration: float = warning_lead_time
	if obs.has_method("calculate_predicted_landing"):
		landing_pos = obs.calculate_predicted_landing()
	if obs.has_method("get_time_to_impact"):
		impact_duration = maxf(0.3, obs.get_time_to_impact())

	warning_requested.emit(landing_pos, impact_duration)

	if is_instance_valid(warning_scene):
		var w_inst := warning_scene.instantiate() as Node2D
		if is_instance_valid(w_inst):
			w_inst.global_position = landing_pos
			if w_inst.has_method("start_warning"):
				w_inst.start_warning(impact_duration)
			add_child(w_inst)
			play_sfx(SFX_WARNING, -4.0)

func _spawn_obstacle_at(target_x: float) -> Node2D:
	if not enable_obstacle_spawning or current_state != RunState.PLAYING or obstacle_scenes.is_empty():
		return null

	var scene_idx := randi() % obstacle_scenes.size()
	var selected_scene: PackedScene = obstacle_scenes[scene_idx]
	if selected_scene == null:
		return null

	var obs := selected_scene.instantiate() as Node2D
	if not is_instance_valid(obs):
		return null

	var surface_y := get_terrain_surface_y(target_x)
	var spawn_y := get_sky_spawn_y(target_x)

	if "ground_y" in obs:
		obs.ground_y = surface_y
	if "terrain_generator" in obs:
		obs.terrain_generator = terrain_generator

	obs.global_position = Vector2(target_x, spawn_y)

	if is_instance_valid(obstacle_container):
		obstacle_container.add_child(obs)
	else:
		add_child(obs)

	if obs.has_method("setup_spawn"):
		obs.setup_spawn(target_x, spawn_y, surface_y, terrain_generator)
	else:
		obs.global_position = Vector2(target_x, spawn_y)

	if obs.has_signal("obstacle_hit") and not obs.obstacle_hit.is_connected(_on_obstacle_reported_hit):
		obs.obstacle_hit.connect(_on_obstacle_reported_hit.bind(obs))

	return obs

func _trigger_unburned_asteroid_spawn() -> Node2D:
	if not enable_obstacle_spawning or current_state != RunState.PLAYING or unburned_asteroid_scene == null:
		return null

	var target_x: float = 0.0
	if is_instance_valid(vehicle):
		var veh_speed: float = 0.0
		if vehicle is RigidBody2D:
			veh_speed = maxf(0.0, (vehicle as RigidBody2D).linear_velocity.x)
		elif "linear_velocity" in vehicle:
			veh_speed = maxf(0.0, vehicle.linear_velocity.x)
		var lead_dist: float = veh_speed * 0.8
		target_x = vehicle.global_position.x + lead_dist + randf_range(160.0, 440.0)
	else:
		target_x = 250.0 + randf_range(50.0, 300.0)

	var surface_y := get_terrain_surface_y(target_x)
	var spawn_y := get_sky_spawn_y(target_x)

	var ast := unburned_asteroid_scene.instantiate() as Node2D
	if not is_instance_valid(ast):
		return null

	ast.global_position = Vector2(target_x, spawn_y)
	if is_instance_valid(obstacle_container):
		obstacle_container.add_child(ast)
	else:
		add_child(ast)

	if ast.has_method("setup_spawn"):
		ast.setup_spawn(target_x, spawn_y, surface_y, terrain_generator)

	if ast.has_signal("obstacle_hit") and not ast.obstacle_hit.is_connected(_on_obstacle_reported_hit):
		ast.obstacle_hit.connect(_on_obstacle_reported_hit.bind(ast))

	# CRITICAL: NO WARNING SIGN CREATED FOR ASTEROIDS!
	return ast

func _trigger_burning_asteroid_spawn() -> Node2D:
	if not enable_obstacle_spawning or current_state != RunState.PLAYING or burning_asteroid_scene == null:
		return null

	var target_x: float = 0.0
	if is_instance_valid(vehicle):
		var veh_speed: float = 0.0
		if vehicle is RigidBody2D:
			veh_speed = maxf(0.0, (vehicle as RigidBody2D).linear_velocity.x)
		elif "linear_velocity" in vehicle:
			veh_speed = maxf(0.0, vehicle.linear_velocity.x)
		var lead_dist: float = veh_speed * 0.75
		target_x = vehicle.global_position.x + lead_dist + randf_range(180.0, 460.0)
	else:
		target_x = 300.0 + randf_range(50.0, 300.0)

	var surface_y := get_terrain_surface_y(target_x)
	var spawn_y := get_sky_spawn_y(target_x)

	var b_ast := burning_asteroid_scene.instantiate() as Node2D
	if not is_instance_valid(b_ast):
		return null

	b_ast.global_position = Vector2(target_x, spawn_y)
	if "create_pothole_on_impact" in b_ast:
		b_ast.create_pothole_on_impact = bool(difficulty_config.get("potholes", false))

	if is_instance_valid(obstacle_container):
		obstacle_container.add_child(b_ast)
	else:
		add_child(b_ast)

	if b_ast.has_method("setup_spawn"):
		b_ast.setup_spawn(target_x, spawn_y, surface_y, terrain_generator, follow_camera)

	if b_ast.has_signal("obstacle_hit") and not b_ast.obstacle_hit.is_connected(_on_obstacle_reported_hit):
		b_ast.obstacle_hit.connect(_on_obstacle_reported_hit.bind(b_ast))

	if b_ast.has_signal("burning_impact_occurred") and not b_ast.burning_impact_occurred.is_connected(_on_burning_asteroid_ground_impact):
		b_ast.burning_impact_occurred.connect(_on_burning_asteroid_ground_impact)

	# CRITICAL: NO WARNING SIGN CREATED FOR ASTEROIDS!
	return b_ast

func _on_burning_asteroid_ground_impact(impact_pos: Vector2, surface_angle: float) -> void:
	if bool(difficulty_config.get("potholes", false)):
		create_pothole_at(impact_pos, surface_angle)

func create_pothole_at(pos: Vector2, angle: float = 0.0) -> Node2D:
	if pothole_scene == null:
		return null
	var pot := pothole_scene.instantiate() as Node2D
	if not is_instance_valid(pot):
		return null

	if pot.has_method("setup_pothole"):
		pot.setup_pothole(pos, angle, terrain_generator, follow_camera)
	else:
		pot.global_position = pos
		pot.rotation = angle

	if is_instance_valid(obstacle_container):
		obstacle_container.add_child(pot)
	else:
		add_child(pot)

	_active_potholes.append(pot)
	if pot.has_signal("vehicle_entered_pothole"):
		pot.vehicle_entered_pothole.connect(func(_veh, _pos): play_sfx(SFX_POTHOLE, -2.0))
	return pot

func _on_obstacle_reported_hit(obstacle_id: String, _hit_pos: Vector2, obs_ref: Node = null, _extra: Node = null) -> void:
	var actual_obs: Node = obs_ref if is_instance_valid(obs_ref) else _extra
	if is_instance_valid(actual_obs):
		var can_dmg: Variant = actual_obs.get("can_damage_vehicle")
		if can_dmg != null and not bool(can_dmg):
			return
		var touched_g: Variant = actual_obs.get("has_touched_ground")
		if touched_g != null and bool(touched_g):
			return
	register_obstacle_hit(obstacle_id, actual_obs)

## Authoritative method to register an obstacle hit.
## Enforces debounce so multi-body vehicle collision in the same frame deducts only 1 life.
func register_obstacle_hit(_obstacle_id: String = "", obstacle_node: Node = null) -> bool:
	if current_state != RunState.PLAYING:
		return false
	if is_invulnerable:
		return false
	if is_instance_valid(obstacle_node):
		var can_dmg: Variant = obstacle_node.get("can_damage_vehicle")
		if can_dmg != null and not bool(can_dmg):
			return false
		var touched_g: Variant = obstacle_node.get("has_touched_ground")
		if touched_g != null and bool(touched_g):
			return false

	# Play collision impact SFX for confirmed hit
	_play_obstacle_impact_sfx(_obstacle_id, obstacle_node)

	# Apply debounce invulnerability window
	is_invulnerable = true
	_invulnerability_timer = invulnerability_duration

	current_lives = maxi(0, current_lives - 1)
	_update_heart_display()
	lives_changed.emit(current_lives, max_lives)

	if current_lives <= 0:
		_handle_lives_depleted()

	return true

func _handle_lives_depleted() -> void:
	lock_vehicle()
	if not extra_life_used:
		_prompt_extra_life_ad()
	else:
		finish_run("NO LIVES REMAINING")

func _prompt_extra_life_ad() -> void:
	current_state = RunState.PAUSED
	lock_vehicle()
	if is_instance_valid(ad_offer_panel):
		ad_offer_panel.visible = true
	else:
		request_ad_extra_life()

func request_ad_extra_life() -> void:
	if extra_life_used:
		finish_run("EXTRA LIFE ALREADY USED")
		return

	if reward_provider == null:
		reward_provider = SurvivalRewardProvider.new()

	reward_provider.request_reward("extra_life", _on_reward_result_received)

func _on_reward_result_received(result: Dictionary) -> void:
	var success: bool = bool(result.get("success", false))
	if success and not extra_life_used:
		extra_life_used = true
		current_lives = 1
		current_state = RunState.PLAYING
		if is_instance_valid(ad_offer_panel):
			ad_offer_panel.visible = false
		_update_heart_display()
		lives_changed.emit(current_lives, max_lives)
		unlock_vehicle()
	else:
		if is_instance_valid(ad_offer_panel):
			ad_offer_panel.visible = false
		finish_run("EXTRA LIFE SKIPPED OR FAILED")

func _on_vehicle_crashed() -> void:
	register_obstacle_hit("crash")

func finish_run(reason: String = "GAME OVER") -> void:
	_run_generation += 1
	current_state = RunState.FINISHED
	lock_vehicle()
	if is_instance_valid(ad_offer_panel):
		ad_offer_panel.visible = false
	if is_instance_valid(game_over_panel):
		game_over_panel.visible = true
		var reason_lbl: Label = game_over_panel.get_node_or_null("%ReasonLabel")
		if is_instance_valid(reason_lbl):
			reason_lbl.text = reason
	run_finished.emit(survival_time, survival_distance, reason)

func _update_heart_display() -> void:
	if is_instance_valid(hud) and hud.has_method("set_survival_lives"):
		hud.set_survival_lives(current_lives, max_lives)

	if not is_instance_valid(heart_container):
		return

	var hearts := heart_container.get_children()
	for i in range(hearts.size()):
		var heart_rect = hearts[i] as TextureRect
		if is_instance_valid(heart_rect):
			if i < current_lives:
				heart_rect.texture = GameHUD.HEART_FULL_TEX
			else:
				heart_rect.texture = GameHUD.HEART_EMPTY_TEX

func _clear_active_obstacles() -> void:
	if is_instance_valid(obstacle_container):
		for child in obstacle_container.get_children():
			obstacle_container.remove_child(child)
			child.queue_free()
	for p in _active_potholes:
		if is_instance_valid(p):
			p.queue_free()
	_active_potholes.clear()
	for child in get_children():
		if child is ObstacleWarningClass or child.has_method("start_warning") or child is GroundShadowClass or child.has_method("update_landing_state") or child is PotholeHazardClass:
			remove_child(child)
			child.queue_free()

func _on_retry_pressed() -> void:
	start_run()

func _on_menu_pressed() -> void:
	_stop_bgm()
	return_to_main_menu_requested.emit()

func _exit_tree() -> void:
	_stop_bgm()
