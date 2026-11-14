class_name FoodObstacle
extends Node2D

## FoodObstacle: Base controller for all 8 Indian food falling hazards in Survival mode.
## Emits authoritative collision signal to SurvivalController without mutating lives directly.
## Supports distinct movement identities: straight fall, rotation, spinning, wobble, and bounce.

signal obstacle_hit(obstacle_id: String, hit_position: Vector2)

enum MovementType {
	STRAIGHT,    # Idli
	ROTATING,    # Dosa
	SPINNING,    # Vada, Murukku
	TUMBLING,    # Samosa
	CLUSTER,     # Pani Puri
	WOBBLE,      # Jalebi
	BOUNCE       # Coconut
}

@export var obstacle_id: String = "idli"
@export var movement_type: MovementType = MovementType.STRAIGHT
@export var fall_speed: float = 400.0
@export var rotation_speed: float = 0.0
@export var ground_y: float = 410.0
@export var ground_bounce_count: int = 0
@export var max_bounces: int = 2
@export var bounce_velocity: float = -260.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var hitbox: Area2D = get_node_or_null("Hitbox")
@onready var shadow: Sprite2D = get_node_or_null("Shadow")

var _current_velocity: Vector2 = Vector2.ZERO
var _has_hit: bool = false
var _elapsed: float = 0.0
var _initial_scale: Vector2 = Vector2.ONE
var _bounces_left: int = 0

func _ready() -> void:
	_current_velocity = Vector2(0.0, fall_speed)
	_bounces_left = max_bounces if movement_type == MovementType.BOUNCE else 0
	
	if is_instance_valid(sprite):
		_initial_scale = sprite.scale
	
	if is_instance_valid(hitbox):
		hitbox.area_entered.connect(_on_area_entered)
		hitbox.body_entered.connect(_on_body_entered)
		
	# Apply movement identity parameters if not overridden
	match movement_type:
		MovementType.STRAIGHT:
			rotation_speed = 0.0
		MovementType.ROTATING: # Dosa
			rotation_speed = 1.8
		MovementType.SPINNING: # Vada, Murukku
			rotation_speed = 7.5
		MovementType.TUMBLING: # Samosa
			rotation_speed = 4.2
		MovementType.CLUSTER:  # Pani Puri
			rotation_speed = 2.0
		MovementType.WOBBLE:   # Jalebi
			rotation_speed = 3.5
		MovementType.BOUNCE:   # Coconut
			rotation_speed = 1.5

func _physics_process(delta: float) -> void:
	if _has_hit:
		return
		
	_elapsed += delta
	
	# Gravity / acceleration
	_current_velocity.y += 350.0 * delta
	global_position += _current_velocity * delta
	
	# Movement identity mechanics
	match movement_type:
		MovementType.ROTATING, MovementType.SPINNING, MovementType.TUMBLING:
			if is_instance_valid(sprite):
				sprite.rotation += rotation_speed * delta
		MovementType.WOBBLE:
			if is_instance_valid(sprite):
				sprite.rotation += rotation_speed * delta
				var wobble := 1.0 + sin(_elapsed * 12.0) * 0.12
				sprite.scale = Vector2(_initial_scale.x * wobble, _initial_scale.y * (2.0 - wobble))
		MovementType.CLUSTER:
			# Gentle lateral drift
			global_position.x += sin(_elapsed * 4.0) * 30.0 * delta
			if is_instance_valid(sprite):
				sprite.rotation += rotation_speed * delta
		MovementType.BOUNCE:
			if is_instance_valid(sprite):
				sprite.rotation += rotation_speed * delta
	
	# Update ground shadow projection
	if is_instance_valid(shadow):
		var dist_to_ground := maxf(0.0, ground_y - global_position.y)
		var shadow_alpha: float = clampf(1.0 - (dist_to_ground / 500.0), 0.1, 0.7)
		var shadow_scale: float = clampf(1.0 - (dist_to_ground / 700.0), 0.4, 1.0)
		shadow.global_position = Vector2(global_position.x, ground_y + 8.0)
		shadow.modulate.a = shadow_alpha
		shadow.scale = Vector2(shadow_scale, shadow_scale * 0.35)
	
	# Ground impact check
	if global_position.y >= ground_y:
		if movement_type == MovementType.BOUNCE and _bounces_left > 0:
			_trigger_bounce()
		else:
			_handle_ground_impact()

func _trigger_bounce() -> void:
	_bounces_left -= 1
	global_position.y = ground_y - 2.0
	_current_velocity.y = bounce_velocity * (0.65 ** (max_bounces - _bounces_left))
	_current_velocity.x = randf_range(-60.0, 60.0)

func _handle_ground_impact() -> void:
	_has_hit = true
	_spawn_impact_visual(global_position)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	_check_vehicle_collision(body)

func _on_area_entered(area: Area2D) -> void:
	_check_vehicle_collision(area)

func _check_vehicle_collision(node: Node) -> void:
	if _has_hit:
		return
	if not is_instance_valid(node):
		return
		
	# Detect vehicle, chassis, or wheel collision
	var is_vehicle: bool = false
	if node is VehicleController or node.get_parent() is VehicleController:
		is_vehicle = true
	elif node.name == "Vehicle" or node.name.begins_with("Wheel") or node.name == "Chassis":
		is_vehicle = true
	elif node.has_method("apply_torque") or node.has_method("refuel"):
		is_vehicle = true
		
	if is_vehicle:
		_has_hit = true
		obstacle_hit.emit(obstacle_id, global_position)
		_spawn_impact_visual(global_position)
		queue_free()

func _spawn_impact_visual(pos: Vector2) -> void:
	var effect := Sprite2D.new()
	effect.texture = preload("res://assets/obstacles/survival/support/impact_effects/generic_collision_impact_effect.png")
	effect.global_position = pos
	effect.scale = Vector2(0.4, 0.4)
	
	var parent_node := get_parent()
	if is_instance_valid(parent_node):
		parent_node.add_child(effect)
		var tw := effect.create_tween()
		tw.set_parallel(true)
		tw.tween_property(effect, "scale", Vector2(0.7, 0.7), 0.2)
		tw.tween_property(effect, "modulate:a", 0.0, 0.25)
		tw.chain().tween_callback(effect.queue_free)
