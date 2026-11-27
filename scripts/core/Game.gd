class_name GameScene
extends Node2D

## GameScene: Integration hub bringing together Vehicle, Terrain, Camera, and HUD.
## Owns vehicle spawn positioning, distance metric tracking, game-over detection, and local scene resets.

const GameManagerScript = preload("res://scripts/core/GameManager.gd")
const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

signal return_to_main_menu_requested

@export var spawn_position: Vector2 = Vector2(0.0, 382.0)
## Whether to use endless procedural terrain (true) or fixed TestTrack (false)
@export var use_procedural_terrain: bool = false

@onready var game_manager: Node = $GameManager
@onready var terrain_slot: Node2D = $TerrainSlot
@onready var vehicle_slot: Node2D = $VehicleSlot
@onready var follow_camera: Camera2D = $FollowCamera
@onready var ui_layer: CanvasLayer = $UILayer
@onready var hud: Node = get_node_or_null("UILayer/HUD")
@onready var results_screen: Control = get_node_or_null("UILayer/ResultsScreen")
@onready var pause_menu: Control = get_node_or_null("UILayer/PauseMenu")
@onready var music_player: AudioStreamPlayer = get_node_or_null("MusicPlayer")
@onready var ambience_player: AudioStreamPlayer = get_node_or_null("AmbiencePlayer")
@onready var biome_environment_host: Node2D = get_node_or_null("BiomeEnvironmentHost")

var vehicle: Node  # VehicleController — typed as Node to avoid parse-time class dependency
var start_x: float = 0.0
var _stopped_timer: float = 0.0
var _is_executing_restart: bool = false

func _ready() -> void:
	_setup_vehicle()
	_setup_camera()
	setup_terrain()
	_setup_environment_host()
	_setup_ui()
	_setup_audio()
	
	var snowfall = get_node_or_null("SnowfallManager")
	if is_instance_valid(snowfall) and is_instance_valid(game_manager):
		snowfall.bind_game_manager(game_manager)
	
	if is_instance_valid(game_manager):
		game_manager.set("game_ref", self)
		game_manager.run_restarted.connect(_on_run_restarted)
		game_manager.run_finished.connect(_on_run_finished)
		game_manager.start_run()

func _setup_vehicle() -> void:
	var selected_id: String = SaveManager.get_selected_vehicle_id()
	for child in vehicle_slot.get_children():
		vehicle_slot.remove_child(child)
		child.queue_free()
	
	var chosen_vehicle: VehicleController = VehicleRegistry.instantiate_vehicle(selected_id)
	if not is_instance_valid(chosen_vehicle):
		chosen_vehicle = VehicleRegistry.instantiate_vehicle("blue_flame_truck")
	
	if is_instance_valid(chosen_vehicle):
		chosen_vehicle.name = "Vehicle"
		vehicle_slot.add_child(chosen_vehicle)
		vehicle = chosen_vehicle
	elif vehicle_slot.get_child_count() > 0:
		vehicle = vehicle_slot.get_child(0)
	
	if is_instance_valid(vehicle):
		vehicle.global_position = spawn_position
		start_x = spawn_position.x
		if "is_reverse_blocked" in vehicle:
			vehicle.is_reverse_blocked = true
		if not vehicle.crashed.is_connected(_on_vehicle_crashed):
			vehicle.crashed.connect(_on_vehicle_crashed)
		if vehicle.has_signal("hard_landed") and not vehicle.hard_landed.is_connected(_on_vehicle_hard_landed):
			vehicle.hard_landed.connect(_on_vehicle_hard_landed)
		if is_instance_valid(game_manager) and game_manager.has_method("bind_vehicle"):
			game_manager.bind_vehicle(vehicle)

func setup_terrain() -> void:
	if not is_instance_valid(terrain_slot):
		return
	
	if use_procedural_terrain:
		# Remove static track if present
		var static_track = terrain_slot.get_node_or_null("TestTrack")
		if is_instance_valid(static_track):
			static_track.queue_free()
		
		var existing_gen = terrain_slot.get_node_or_null("TerrainGenerator")
		if not is_instance_valid(existing_gen):
			var gen: Node2D = Node2D.new()
			# Instantiate via preload to avoid parse-time class_name dependency
			var gen_script = load("res://scripts/terrain/TerrainGenerator.gd")
			gen.set_script(gen_script)
			gen.name = "TerrainGenerator"
			gen.set("target", vehicle)
			gen.set("auto_find_target", true)
			terrain_slot.add_child(gen)
	else:
		# Ensure TestTrack is present for controlled regression tests
		var existing_gen = terrain_slot.get_node_or_null("TerrainGenerator")
		if is_instance_valid(existing_gen):
			existing_gen.queue_free()
		
		var static_track = terrain_slot.get_node_or_null("TestTrack")
		if not is_instance_valid(static_track):
			var track_packed: PackedScene = preload("res://scenes/terrain/TestTrack.tscn")
			if track_packed:
				var track = track_packed.instantiate()
				track.name = "TestTrack"
				terrain_slot.add_child(track)

func _setup_camera() -> void:
	if is_instance_valid(follow_camera) and is_instance_valid(vehicle):
		follow_camera.set("target", vehicle)
		if follow_camera.has_method("snap_to_target"):
			follow_camera.snap_to_target()
		else:
			follow_camera.global_position = vehicle.global_position + Vector2(180.0, -50.0)

func _setup_ui() -> void:
	if is_instance_valid(hud):
		# Endless mode uses the wooden arcade HUD look (opt-in; HUD.tscn itself is unchanged).
		if hud.has_method("apply_wooden_skin"):
			hud.apply_wooden_skin()
	# Endless uses the wooden pause menu too (opt-in; PauseMenu.tscn itself is unchanged).
	if is_instance_valid(pause_menu) and pause_menu.has_method("apply_wooden_skin"):
		pause_menu.apply_wooden_skin()
	# Endless uses the wooden game-over results panel (opt-in; ResultsScreen.tscn unchanged).
	if is_instance_valid(results_screen) and results_screen.has_method("apply_wooden_skin"):
		results_screen.apply_wooden_skin()
	if is_instance_valid(hud):
		if is_instance_valid(game_manager):
			hud.bind_game_manager(game_manager)
		if is_instance_valid(vehicle):
			hud.bind_vehicle(vehicle)
		var prog_ctrl: Node = get_node_or_null("BiomeProgressionController")
		if is_instance_valid(prog_ctrl):
			if is_instance_valid(vehicle) and prog_ctrl.has_method("bind_vehicle"):
				prog_ctrl.bind_vehicle(vehicle)
			if hud.has_method("bind_progression_controller"):
				hud.bind_progression_controller(prog_ctrl)
			
	if is_instance_valid(results_screen) and results_screen.has_method("bind_game_manager"):
		results_screen.bind_game_manager(game_manager)
		
	if is_instance_valid(pause_menu):
		if pause_menu.has_method("bind_game_manager"):
			pause_menu.bind_game_manager(game_manager)
		if pause_menu.has_signal("menu_requested") and not pause_menu.menu_requested.is_connected(exit_to_main_menu):
			pause_menu.menu_requested.connect(exit_to_main_menu)

func _setup_audio() -> void:
	if is_instance_valid(biome_environment_host):
		# BiomeEnvironmentHost coordinates dynamic multi-world audio crossfades
		if is_instance_valid(music_player):
			music_player.stop()
		if is_instance_valid(ambience_player):
			ambience_player.stop()
		return

	if is_instance_valid(music_player):
		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)
	if is_instance_valid(ambience_player):
		if not ambience_player.finished.is_connected(_on_ambience_finished):
			ambience_player.finished.connect(_on_ambience_finished)

func _setup_environment_host() -> void:
	if not is_instance_valid(biome_environment_host):
		biome_environment_host = get_node_or_null("BiomeEnvironmentHost")
	
	if not is_instance_valid(biome_environment_host) and use_procedural_terrain:
		var prog_ctrl: Node = get_node_or_null("BiomeProgressionController")
		if not is_instance_valid(prog_ctrl):
			var prog_script: GDScript = load("res://scripts/progression/BiomeProgressionController.gd")
			prog_ctrl = prog_script.new()
			prog_ctrl.name = "BiomeProgressionController"
			add_child(prog_ctrl)
			if is_instance_valid(game_manager) and prog_ctrl.has_method("connect_to_game_manager"):
				prog_ctrl.connect_to_game_manager(game_manager)

		var host_script: GDScript = load("res://scripts/environment/BiomeEnvironmentHost.gd")
		var host: Node2D = host_script.new()
		host.name = "BiomeEnvironmentHost"
		host.set("progression_controller", prog_ctrl)
		var gen = terrain_slot.get_node_or_null("TerrainGenerator")
		if is_instance_valid(gen):
			host.set("terrain_generator", gen)
			if gen.has_method("bind_progression_controller"):
				gen.bind_progression_controller(prog_ctrl)
		if is_instance_valid(vehicle) and prog_ctrl.has_method("bind_vehicle"):
			prog_ctrl.bind_vehicle(vehicle)
		var normal_env = get_node_or_null("ParallaxEnvironment")
		if is_instance_valid(normal_env):
			host.set("normal_environment", normal_env)
		if is_instance_valid(follow_camera):
			host.set("follow_camera", follow_camera)
		add_child(host)
		biome_environment_host = host
		
		if is_instance_valid(hud) and hud.has_method("bind_progression_controller"):
			hud.bind_progression_controller(prog_ctrl)

func _on_music_finished() -> void:
	if is_instance_valid(music_player):
		music_player.play()

func _on_ambience_finished() -> void:
	if is_instance_valid(ambience_player):
		ambience_player.play()

func _on_run_finished(_dist: float, _coins: int = 0, _reason: String = "") -> void:
	if is_instance_valid(music_player):
		music_player.volume_db = -22.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		restart_game()
		return
	if Input.is_action_just_pressed("pause") and is_instance_valid(game_manager):
		if game_manager.current_state != GameManagerScript.RunState.FINISHED:
			game_manager.toggle_pause()
			if is_instance_valid(biome_environment_host) and biome_environment_host.has_method("set_audio_paused"):
				biome_environment_host.set_audio_paused(game_manager.current_state == GameManagerScript.RunState.PAUSED)
		return
		
	if not is_instance_valid(vehicle) or not is_instance_valid(game_manager):
		return
	
	if game_manager.current_state == GameManagerScript.RunState.PLAYING and vehicle.is_active:
		# Distance in meters (100 pixels = 1 meter), strictly monotonic from spawn_x
		var dist_meters: float = maxf(0.0, (vehicle.global_position.x - start_x) / 100.0)
		if dist_meters < 0.005:
			dist_meters = 0.0
		game_manager.update_distance(dist_meters)
		if "is_reverse_blocked" in vehicle:
			vehicle.is_reverse_blocked = dist_meters < 10.0
		
		# Check Out of Fuel game-over condition:
		# When fuel is depleted and vehicle has naturally coasted to a halt
		if vehicle.current_fuel <= 0.0:
			if vehicle.linear_velocity.length() < 18.0:
				_stopped_timer += delta
				if _stopped_timer >= 1.0:
					game_manager.finish_run("out_of_fuel")
			else:
				_stopped_timer = 0.0
		else:
			_stopped_timer = 0.0

func _on_vehicle_hard_landed(severity: float) -> void:
	if is_instance_valid(follow_camera) and follow_camera.has_method("add_trauma"):
		follow_camera.add_trauma(severity * 0.4)

func _on_vehicle_crashed() -> void:
	if is_instance_valid(follow_camera) and follow_camera.has_method("add_trauma"):
		follow_camera.add_trauma(0.7)
	if is_instance_valid(game_manager) and game_manager.current_state == GameManagerScript.RunState.PLAYING:
		game_manager.finish_run("crashed")

func _on_run_restarted() -> void:
	# When BiomeEnvironmentHost is active, IT owns music for the whole run (it crossfades
	# between Normal/Heaven/Hell tracks). This standalone player was only ever meant to be the
	# simple default for modes without a biome host, so it must stay silent here too — resuming
	# it unconditionally on every restart was exactly what caused Normal Land's music to keep
	# playing underneath Heaven/Hell forever after the first retry of a run.
	if not is_instance_valid(biome_environment_host):
		if is_instance_valid(music_player):
			music_player.volume_db = -12.0
			if not music_player.playing:
				music_player.play()
	_stopped_timer = 0.0

## Authoritative 8-Phase atomic restart transaction
func execute_restart_transaction() -> void:
	if _is_executing_restart:
		return
	_is_executing_restart = true

	var prog_ctrl: BiomeProgressionController = get_node_or_null("BiomeProgressionController")
	if not is_instance_valid(prog_ctrl):
		var host_cand = get_node_or_null("BiomeEnvironmentHost")
		if is_instance_valid(host_cand) and host_cand.get("progression_controller"):
			prog_ctrl = host_cand.get("progression_controller") as BiomeProgressionController

	var host: BiomeEnvironmentHost = biome_environment_host as BiomeEnvironmentHost
	var gen: TerrainGenerator = null
	if is_instance_valid(terrain_slot):
		gen = terrain_slot.get_node_or_null("TerrainGenerator") as TerrainGenerator

	# PHASE 1: FREEZE
	get_tree().paused = false
	if is_instance_valid(game_manager):
		game_manager.set("is_restart_in_progress", true)
		game_manager.current_state = GameManagerScript.RunState.READY
	if is_instance_valid(prog_ctrl):
		prog_ctrl.is_restart_in_progress = true
	if is_instance_valid(vehicle):
		if vehicle.has_method("set_active"):
			vehicle.set_active(false)

	# PHASE 2: RESET PROGRESSION
	if is_instance_valid(prog_ctrl):
		prog_ctrl.reset_progression()

	# PHASE 3: CLEAR OLD CONTENT
	if is_instance_valid(gen):
		gen.clear_terrain()
	_reset_pickups()

	# PHASE 4: RESET ENVIRONMENT
	if is_instance_valid(host):
		host._on_progression_reset()
	else:
		var normal_env = get_node_or_null("ParallaxEnvironment")
		if is_instance_valid(normal_env):
			normal_env.visible = true
			if normal_env.has_method("reset_environment_state"):
				normal_env.reset_environment_state()

	# PHASE 5: REBUILD TERRAIN
	if is_instance_valid(gen):
		gen.reset_generator(spawn_position + Vector2(-1200.0, 38.0))

	# PHASE 6: RESET VEHICLE & CAMERA
	_stopped_timer = 0.0
	start_x = spawn_position.x
	if is_instance_valid(vehicle):
		vehicle.reset_vehicle(spawn_position)
		if "is_reverse_blocked" in vehicle:
			vehicle.is_reverse_blocked = true
		if vehicle.has_method("set_active"):
			vehicle.set_active(true)
	if is_instance_valid(follow_camera) and is_instance_valid(vehicle):
		if follow_camera.has_method("snap_to_target"):
			follow_camera.snap_to_target()
		else:
			follow_camera.global_position = vehicle.global_position + Vector2(180.0, -50.0)

	# PHASE 7: RESET RUN STATS & HUD
	if is_instance_valid(game_manager):
		game_manager.current_distance = 0.0
		game_manager.coins_collected = 0
		game_manager.run_time = 0.0
		game_manager.finish_reason = ""
		game_manager.is_new_record = false
		if is_instance_valid(vehicle):
			if "current_fuel" in vehicle:
				game_manager.current_fuel = float(vehicle.current_fuel)
			if "max_fuel" in vehicle:
				game_manager.max_fuel = float(vehicle.max_fuel)
		else:
			game_manager.current_fuel = game_manager.max_fuel
		game_manager.distance_updated.emit(0.0)
		game_manager.fuel_updated.emit(game_manager.current_fuel, game_manager.max_fuel)
		game_manager.coins_updated.emit(0)

	if is_instance_valid(pause_menu):
		pause_menu.visible = false
	if is_instance_valid(results_screen):
		results_screen.visible = false

	# PHASE 8: START GAMEPLAY
	if is_instance_valid(host):
		host.activate_biome_exclusive(WorldCycleSchedule.BiomeType.NORMAL_LAND)
	if is_instance_valid(prog_ctrl):
		prog_ctrl.is_restart_in_progress = false
	if is_instance_valid(game_manager):
		game_manager.set("is_restart_in_progress", false)
		game_manager.current_state = GameManagerScript.RunState.PLAYING
		game_manager.run_restarted.emit()
		game_manager.run_started.emit()

	_is_executing_restart = false

func _reset_pickups() -> void:
	var pickups = get_tree().get_nodes_in_group("pickups")
	for p in pickups:
		if is_instance_valid(p) and p.has_method("reset_pickup"):
			p.reset_pickup()
			
	if is_instance_valid(terrain_slot):
		_reset_pickups_in_node(terrain_slot)

func _reset_pickups_in_node(parent: Node) -> void:
	for child in parent.get_children():
		if is_instance_valid(child):
			if child.has_method("reset_pickup"):
				child.reset_pickup()
			if child.get_child_count() > 0:
				_reset_pickups_in_node(child)

func restart_game() -> void:
	if is_instance_valid(game_manager):
		game_manager.restart_run()
	else:
		execute_restart_transaction()

func exit_to_main_menu() -> void:
	if is_instance_valid(game_manager):
		game_manager.pause_run(false)
	else:
		get_tree().paused = false
	return_to_main_menu_requested.emit()
	if get_parent() == get_tree().root:
		get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
