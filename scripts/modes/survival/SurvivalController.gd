class_name SurvivalController
extends Node2D

## SurvivalController: Master controller for the Survival game mode.
## Owns authoritative run states, 3-life system, hit debouncing, extra-life reward gating,
## and spawner coordination for Joel's obstacle components.

const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const SurvivalRewardProvider = preload("res://scripts/modes/survival/SurvivalRewardProvider.gd")

enum RunState {
	READY,
	PLAYING,
	PAUSED,
	FINISHED
}

signal return_to_main_menu_requested
signal run_started
signal run_finished(final_time: float, final_distance: float, reason: String)
signal lives_changed(current_lives: int, max_lives: int)
signal warning_requested(target_position: Vector2, duration: float)

@export var max_lives: int = 3
@export var invulnerability_duration: float = 0.8
@export var spawn_interval: float = 2.5
@export var spawn_height_offset: float = -450.0
@export var warning_lead_time: float = 1.0

## Slot for Joel's obstacle scenes (e.g. Chilli, Rice, Sweets, Vada Pav)
@export var obstacle_scenes: Array[PackedScene] = []
## Slot for Joel's warning indicator scene
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

var vehicle: Node = null
var reward_provider: SurvivalRewardProvider = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if reward_provider == null:
		reward_provider = SurvivalRewardProvider.new()

	_setup_vehicle()
	_setup_camera()
	_setup_ui()
	start_run()

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
	_update_heart_display()

func start_run() -> void:
	current_state = RunState.PLAYING
	current_lives = max_lives
	extra_life_used = false
	is_invulnerable = false
	_invulnerability_timer = 0.0
	survival_time = 0.0
	survival_distance = 0.0
	_spawn_timer = 0.0

	if is_instance_valid(game_over_panel):
		game_over_panel.visible = false
	if is_instance_valid(ad_offer_panel):
		ad_offer_panel.visible = false

	_clear_active_obstacles()
	_update_heart_display()
	lives_changed.emit(current_lives, max_lives)
	run_started.emit()

func _process(delta: float) -> void:
	if current_state != RunState.PLAYING:
		return

	survival_time += delta
	if is_instance_valid(vehicle):
		var dx: float = vehicle.global_position.x - _start_x
		survival_distance = maxf(survival_distance, dx * 0.01)

	if is_instance_valid(time_label):
		time_label.text = "TIME: %.1fs" % survival_time
	if is_instance_valid(distance_label):
		distance_label.text = "DIST: %dm" % int(survival_distance)

	# Update invulnerability cooldown
	if is_invulnerable:
		_invulnerability_timer -= delta
		if _invulnerability_timer <= 0.0:
			is_invulnerable = false

	# Spawner tick
	_spawn_timer += delta
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		_trigger_obstacle_spawn()

func _trigger_obstacle_spawn() -> void:
	if obstacle_scenes.is_empty():
		# Joel's obstacles pending delivery
		return

	var target_x: float = 0.0
	if is_instance_valid(vehicle):
		target_x = vehicle.global_position.x + randf_range(-100.0, 300.0)

	var projected_ground_pos := Vector2(target_x, 382.0)
	warning_requested.emit(projected_ground_pos, warning_lead_time)

	if is_instance_valid(warning_scene):
		var w_inst := warning_scene.instantiate() as Node2D
		if is_instance_valid(w_inst):
			w_inst.global_position = projected_ground_pos
			if w_inst.has_method("start_warning"):
				w_inst.start_warning(warning_lead_time)
			add_child(w_inst)

	# Schedule obstacle drop
	get_tree().create_timer(warning_lead_time).timeout.connect(func():
		_spawn_obstacle_at(target_x)
	)

func _spawn_obstacle_at(target_x: float) -> void:
	if current_state != RunState.PLAYING:
		return
	if obstacle_scenes.is_empty():
		return

	var scene_idx := randi() % obstacle_scenes.size()
	var selected_scene: PackedScene = obstacle_scenes[scene_idx]
	if selected_scene == null:
		return

	var obs := selected_scene.instantiate() as Node2D
	if not is_instance_valid(obs):
		return

	obs.global_position = Vector2(target_x, 382.0 + spawn_height_offset)
	if is_instance_valid(obstacle_container):
		obstacle_container.add_child(obs)
	else:
		add_child(obs)

	if obs.has_signal("obstacle_hit"):
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
		# If no UI panel is bound, query provider directly
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
	current_state = RunState.FINISHED
	if is_instance_valid(game_over_panel):
		game_over_panel.visible = true
		var reason_lbl: Label = game_over_panel.get_node_or_null("%ReasonLabel")
		if is_instance_valid(reason_lbl):
			reason_lbl.text = reason
	run_finished.emit(survival_time, survival_distance, reason)

func _update_heart_display() -> void:
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
