class_name SurvivalController
extends Node2D

## SurvivalController: Master controller for the Survival game mode.
## Owns authoritative run states, 3-life system, hit debouncing, extra-life reward gating,
## progressive difficulty scaling, spawner coordination for food obstacles, and Shared HUD binding.

const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const SurvivalRewardProvider = preload("res://scripts/modes/survival/SurvivalRewardProvider.gd")

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

@export var max_lives: int = 3
@export var invulnerability_duration: float = 0.8
@export var base_spawn_interval: float = 2.4
@export var min_spawn_interval: float = 0.9
@export var difficulty_scale_rate: float = 0.012
@export var spawn_interval: float = 2.4
@export var spawn_height_offset: float = -450.0
@export var warning_lead_time: float = 1.0

@export var use_default_food_obstacles: bool = false

## Slots for food obstacle scenes (Idli, Dosa, Vada, Samosa, Murukku, Pani Puri, Jalebi, Coconut)
@export var obstacle_scenes: Array[PackedScene] = []
## Slot for ground warning indicator scene
@export var warning_scene: PackedScene = null

@onready var vehicle_slot: Node2D = get_node_or_null("VehicleSlot")
@onready var obstacle_container: Node2D = get_node_or_null("ObstacleContainer")
@onready var follow_camera: Camera2D = get_node_or_null("FollowCamera")
@onready var hud: Control = get_node_or_null("UILayer/SurvivalHUD")
@onready var heart_container: HBoxContainer = get_node_or_null("%HeartContainer")
@onready var game_over_panel: Control = get_node_or_null("%GameOverPanel")
@onready var ad_offer_panel: Control = get_node_or_null("%AdOfferPanel")
@onready var time_label: Label = get_node_or_null("%TimeLabel")
@onready var distance_label: Label = get_node_or_null("%DistanceLabel")

var current_state: RunState = RunState.READY
var current_lives: int = 3
var extra_life_used: bool = false
var is_invulnerable: bool = false
var _invulnerability_timer: float = 0.0

var survival_time: float = 0.0
var survival_distance: float = 0.0
var _spawn_timer: float = 0.0
var _start_x: float = 0.0
var _run_generation: int = 0

var vehicle: Node = null
var reward_provider: SurvivalRewardProvider = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if reward_provider == null:
		reward_provider = SurvivalRewardProvider.new()

	if (use_default_food_obstacles or get_tree().current_scene == self) and obstacle_scenes.is_empty():
		load_default_obstacles()

	_setup_vehicle()
	_setup_camera()
	_setup_ui()
	start_run()

func load_default_obstacles() -> void:
	obstacle_scenes = DEFAULT_OBSTACLES.duplicate()
	if warning_scene == null:
		warning_scene = DEFAULT_WARNING

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
		veh.global_position = Vector2(0.0, 382.0)
		vehicle_slot.add_child(veh)
		vehicle = veh
		_start_x = veh.global_position.x
		if veh.has_signal("crashed") and not veh.crashed.is_connected(_on_vehicle_crashed):
			veh.crashed.connect(_on_vehicle_crashed)

func _setup_camera() -> void:
	if is_instance_valid(follow_camera) and is_instance_valid(vehicle):
		follow_camera.target = vehicle

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
			
	_update_heart_display()

func start_run() -> void:
	_run_generation += 1
	current_state = RunState.PLAYING
	current_lives = max_lives
	extra_life_used = false
	is_invulnerable = false
	_invulnerability_timer = 0.0
	survival_time = 0.0
	survival_distance = 0.0
	_spawn_timer = 0.0
	get_tree().paused = false

	if is_instance_valid(game_over_panel):
		game_over_panel.visible = false
	if is_instance_valid(ad_offer_panel):
		ad_offer_panel.visible = false

	_clear_active_obstacles()
	_update_heart_display()
	
	if is_instance_valid(hud) and hud.has_method("set_survival_stats"):
		hud.set_survival_stats(survival_time, survival_distance)
		
	lives_changed.emit(current_lives, max_lives)
	run_started.emit()

func pause_run(is_paused: bool) -> void:
	if current_state != RunState.PLAYING and current_state != RunState.PAUSED:
		return
	current_state = RunState.PAUSED if is_paused else RunState.PLAYING
	get_tree().paused = is_paused
	run_paused.emit(is_paused)

func toggle_pause() -> void:
	if current_state == RunState.PLAYING:
		pause_run(true)
	elif current_state == RunState.PAUSED:
		pause_run(false)

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

	# Update invulnerability cooldown
	if is_invulnerable:
		_invulnerability_timer -= delta
		if _invulnerability_timer <= 0.0:
			is_invulnerable = false

	# Dynamic difficulty scaling: spawn interval shortens over survival time
	var current_interval: float = maxf(min_spawn_interval, base_spawn_interval - (survival_time * difficulty_scale_rate))
	_spawn_timer += delta
	if _spawn_timer >= current_interval:
		_spawn_timer = 0.0
		_trigger_obstacle_spawn()

func _trigger_obstacle_spawn() -> void:
	if obstacle_scenes.is_empty():
		return

	var target_x: float = 0.0
	if is_instance_valid(vehicle):
		target_x = vehicle.global_position.x + randf_range(-80.0, 320.0)

	var projected_ground_pos := Vector2(target_x, 410.0)
	warning_requested.emit(projected_ground_pos, warning_lead_time)

	if is_instance_valid(warning_scene):
		var w_inst := warning_scene.instantiate() as Node2D
		if is_instance_valid(w_inst):
			w_inst.global_position = projected_ground_pos
			if w_inst.has_method("start_warning"):
				w_inst.start_warning(warning_lead_time)
			add_child(w_inst)

	# Schedule obstacle drop with generational validation
	var gen: int = _run_generation
	get_tree().create_timer(warning_lead_time).timeout.connect(func():
		if gen == _run_generation and current_state == RunState.PLAYING:
			_spawn_obstacle_at(target_x)
	)

func _spawn_obstacle_at(target_x: float) -> void:
	if current_state != RunState.PLAYING or obstacle_scenes.is_empty():
		return

	var scene_idx := randi() % obstacle_scenes.size()
	var selected_scene: PackedScene = obstacle_scenes[scene_idx]
	if selected_scene == null:
		return

	var obs := selected_scene.instantiate() as Node2D
	if not is_instance_valid(obs):
		return

	obs.global_position = Vector2(target_x, 410.0 + spawn_height_offset)
	if is_instance_valid(obstacle_container):
		obstacle_container.add_child(obs)
	else:
		add_child(obs)

	if obs.has_signal("obstacle_hit") and not obs.obstacle_hit.is_connected(_on_obstacle_reported_hit):
		obs.obstacle_hit.connect(_on_obstacle_reported_hit)

func _on_obstacle_reported_hit(obstacle_id: String, _hit_pos: Vector2) -> void:
	register_obstacle_hit(obstacle_id)

## Authoritative method to register an obstacle hit.
## Enforces debounce so multi-body vehicle collision in the same frame deducts only 1 life.
func register_obstacle_hit(_obstacle_id: String = "") -> bool:
	if current_state != RunState.PLAYING:
		return false
	if is_invulnerable:
		return false

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
	if not extra_life_used:
		_prompt_extra_life_ad()
	else:
		finish_run("NO LIVES REMAINING")

func _prompt_extra_life_ad() -> void:
	current_state = RunState.PAUSED
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
	else:
		if is_instance_valid(ad_offer_panel):
			ad_offer_panel.visible = false
		finish_run("EXTRA LIFE SKIPPED OR FAILED")

func _on_vehicle_crashed() -> void:
	register_obstacle_hit("crash")

func finish_run(reason: String) -> void:
	_run_generation += 1
	current_state = RunState.FINISHED
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
				heart_rect.texture = load("res://assets/ui/hud/hearts/hud_heart_full.png")
			else:
				heart_rect.texture = load("res://assets/ui/hud/hearts/hud_heart_empty.png")

func _clear_active_obstacles() -> void:
	if is_instance_valid(obstacle_container):
		for child in obstacle_container.get_children():
			child.queue_free()

func _on_retry_pressed() -> void:
	start_run()

func _on_menu_pressed() -> void:
	return_to_main_menu_requested.emit()
