extends Node2D
class_name KanyakumariGameController

@onready var parallax_world: Node = $ParallaxWorld
@onready var terrain: Node = $KanyakumariTerrain
@onready var camera: Camera2D = $FollowCamera
@onready var hud: CanvasLayer = $GameHUD
@onready var checkpoint_banner: Control = $CheckpointBanner
@onready var results_dialog: Control = $ResultsDialog
@onready var pause_dialog: Control = $PauseDialog
@onready var garage_menu: Control = $GarageMenu
@onready var map_menu: Control = $MapMenu

var vehicle_instance: RigidBody2D
var current_vehicle_id: String = ""

const VEHICLE_SCENES: Dictionary = {
	"red_jeep": "res://scenes/vehicles/RedJeep.tscn"
}

func _ready() -> void:
	# Hide overlay dialogs
	garage_menu.visible = false
	map_menu.visible = false
	
	# Connect UI signals
	hud.pause_pressed.connect(_on_pause_requested)
	
	results_dialog.retry_pressed.connect(_on_restart_run)
	results_dialog.revive_pressed.connect(_on_revive_run)
	results_dialog.garage_pressed.connect(_open_garage)
	results_dialog.map_pressed.connect(_open_map)
	
	pause_dialog.resume_pressed.connect(_on_resume_run)
	pause_dialog.restart_pressed.connect(_on_restart_run)
	pause_dialog.garage_pressed.connect(_open_garage)
	pause_dialog.map_pressed.connect(_open_map)
	
	garage_menu.back_pressed.connect(_close_garage)
	garage_menu.drive_pressed.connect(_on_garage_drive)
	
	map_menu.back_pressed.connect(_close_map)
	map_menu.stage_selected.connect(_on_stage_selected)
	
	# Spawn active vehicle & start stage
	start_stage()

func start_stage() -> void:
	if is_instance_valid(vehicle_instance):
		vehicle_instance.queue_free()
		
	GameState.reset_run_state()
	current_vehicle_id = GameState.active_vehicle_id
	
	# Load vehicle scene
	var v_path: String = VEHICLE_SCENES.get(current_vehicle_id, "res://scenes/vehicles/RedJeep.tscn")
	var v_scene: PackedScene = load(v_path)
	vehicle_instance = v_scene.instantiate()
	
	# Initial spawn position on starter flat road
	vehicle_instance.position = Vector2(100.0, 520.0)
	add_child(vehicle_instance)
	
	# Link terrain and camera to vehicle
	terrain.set_target(vehicle_instance)
	terrain.setup_for_stage(StageManager.current_stage)
	terrain.update_chunks(vehicle_instance.global_position.x)
	
	# Connect vehicle crash signal
	if vehicle_instance.has_signal("crashed"):
		vehicle_instance.connect("crashed", _on_vehicle_crashed)
		
	camera.global_position = Vector2(vehicle_instance.global_position.x + 350.0, 540.0)
	AudioManager.start_engine()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(vehicle_instance):
		return
		
	# Smooth dynamic camera following
	var target_x: float = vehicle_instance.global_position.x + 380.0
	var target_y: float = clampf(vehicle_instance.global_position.y - 80.0, 200.0, 750.0)
	
	camera.global_position.x = lerpf(camera.global_position.x, target_x, 6.0 * delta)
	camera.global_position.y = lerpf(camera.global_position.y, target_y, 4.0 * delta)
	
	# Subtle speed zoom
	var speed: float = vehicle_instance.linear_velocity.length()
	var target_zoom: float = clampf(1.0 - (speed / 1200.0) * 0.15, 0.86, 1.0)
	camera.zoom = lerp(camera.zoom, Vector2.ONE * target_zoom, 3.0 * delta)

func _on_vehicle_crashed(reason: String) -> void:
	# Camera shake on crash
	_shake_camera(18.0)

func _shake_camera(intensity: float) -> void:
	var tween := create_tween()
	for i in range(4):
		var offset := Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "offset", offset, 0.04)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

func _on_pause_requested() -> void:
	pause_dialog.open_pause()

func _on_resume_run() -> void:
	pause_dialog.close_pause()

func _on_restart_run() -> void:
	results_dialog.visible = false
	pause_dialog.close_pause()
	start_stage()

func _on_revive_run() -> void:
	results_dialog.visible = false
	if is_instance_valid(vehicle_instance):
		# Upright the vehicle and place on road
		vehicle_instance.rotation = 0.0
		vehicle_instance.angular_velocity = 0.0
		vehicle_instance.linear_velocity = Vector2(50.0, 0.0)
		var road_y: float = float(terrain.call("get_elevation_at", vehicle_instance.global_position.x))
		vehicle_instance.global_position.y = road_y - 60.0

func _open_garage() -> void:
	results_dialog.visible = false
	pause_dialog.close_pause()
	garage_menu.visible = true
	garage_menu._update_view()

func _close_garage() -> void:
	garage_menu.visible = false
	start_stage()

func _on_garage_drive() -> void:
	garage_menu.visible = false
	start_stage()

func _open_map() -> void:
	results_dialog.visible = false
	pause_dialog.close_pause()
	map_menu.visible = true
	map_menu._refresh_view()

func _close_map() -> void:
	map_menu.visible = false

func _on_stage_selected(_stage_id: String) -> void:
	map_menu.visible = false
	start_stage()
