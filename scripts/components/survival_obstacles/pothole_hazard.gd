class_name PotholeHazard
extends Area2D

## PotholeHazard: Road crater hazard created when a burning asteroid strikes the ground in Hard Mode.
## Features authentic cracked road decal artwork, terrain angle alignment,
## physical suspension compression/bounce impulses, speed penalty, and camera trauma shake.

signal vehicle_entered_pothole(vehicle_ref: Node, impact_pos: Vector2)

const TEX_SMOKE_DUST: Texture2D = preload("res://assets/obstacles/survival/pothole/road_impact_dust_smoke_effect.png")

@export var speed_penalty_factor: float = 0.55 # 45% speed reduction
@export var vertical_bounce_impulse: float = -180.0
@export var camera_trauma_amount: float = 0.35
@export var despawn_behind_distance: float = 2400.0

@onready var decal_sprite: Sprite2D = get_node_or_null("DecalSprite")
@onready var cracks_overlay: Sprite2D = get_node_or_null("CracksOverlay")
@onready var collision_poly: CollisionPolygon2D = get_node_or_null("CollisionPolygon2D")

var terrain_generator: Node = null
var follow_camera: Node = null
var _recent_visitors: Dictionary = {} # Node -> float cooldown

func _ready() -> void:
	collision_layer = 16
	collision_mask = 2
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
		
	_spawn_creation_smoke()

func setup_pothole(pos: Vector2, angle: float = 0.0, t_gen: Node = null, cam: Node = null) -> void:
	global_position = pos
	rotation = angle
	terrain_generator = t_gen
	follow_camera = cam

func _process(delta: float) -> void:
	# Tick cooldowns for recent visitor debounce
	for key in _recent_visitors.keys():
		_recent_visitors[key] -= delta
		if _recent_visitors[key] <= 0.0:
			_recent_visitors.erase(key)
			
	# Cleanup when far behind target / camera
	if is_instance_valid(follow_camera):
		if follow_camera.global_position.x - global_position.x > despawn_behind_distance:
			queue_free()

func _spawn_creation_smoke() -> void:
	var smoke := Sprite2D.new()
	smoke.texture = TEX_SMOKE_DUST
	smoke.scale = Vector2(0.4, 0.4)
	smoke.position = Vector2(0, -10)
	smoke.modulate = Color(1.0, 1.0, 1.0, 0.9)
	add_child(smoke)
	
	var tw := smoke.create_tween()
	tw.set_parallel(true)
	tw.tween_property(smoke, "scale", Vector2(0.65, 0.55), 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(smoke, "position:y", -28.0, 0.6)
	tw.tween_property(smoke, "modulate:a", 0.0, 0.6).set_delay(0.2)
	tw.chain().tween_callback(smoke.queue_free)

func _on_body_entered(body: Node2D) -> void:
	_handle_vehicle_interaction(body)

func _on_area_entered(area: Area2D) -> void:
	var body := area.get_parent()
	if is_instance_valid(body) and body is Node2D:
		_handle_vehicle_interaction(body)

func _handle_vehicle_interaction(node: Node2D) -> void:
	var root_veh: Node2D = null
	if node.is_in_group("vehicle") or node is VehicleController or node.name == "Vehicle":
		root_veh = node
	elif node.owner is VehicleController or (is_instance_valid(node.owner) and node.owner.is_in_group("vehicle")):
		root_veh = node.owner as Node2D
	elif is_instance_valid(node.get_parent()) and node.get_parent() is VehicleController:
		root_veh = node.get_parent() as Node2D

	if not is_instance_valid(root_veh):
		return

	if _recent_visitors.has(root_veh):
		return

	_recent_visitors[root_veh] = 0.7 # 0.7s debounce per vehicle
	vehicle_entered_pothole.emit(root_veh, global_position)

	# Apply speed reduction penalty
	if "linear_velocity" in root_veh:
		root_veh.linear_velocity.x *= speed_penalty_factor

	# Apply chassis physical suspension bounce jolt
	if root_veh is RigidBody2D:
		var jolt := Vector2(0.0, vertical_bounce_impulse).rotated(rotation)
		(root_veh as RigidBody2D).apply_impulse(jolt)
		(root_veh as RigidBody2D).apply_torque_impulse(randf_range(-12000.0, 12000.0))

	# Trigger camera shake trauma
	if is_instance_valid(follow_camera) and follow_camera.has_method("add_trauma"):
		follow_camera.add_trauma(camera_trauma_amount)
	elif root_veh.get_viewport() and root_veh.get_viewport().get_camera_2d():
		var cam := root_veh.get_viewport().get_camera_2d()
		if cam.has_method("add_trauma"):
			cam.add_trauma(camera_trauma_amount)

	# Trigger pothole assist hint on vehicle if supported
	if root_veh.has_signal("pothole_assist_hint"):
		root_veh.emit_signal("pothole_assist_hint", true)
