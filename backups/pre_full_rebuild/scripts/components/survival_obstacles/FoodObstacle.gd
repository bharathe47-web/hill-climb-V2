class_name FoodObstacle
extends Area2D

## FoodObstacle: Reusable falling food obstacle component for Survival Mode.
## Falls with physics gravity, rotates naturally, and reports hits to the SurvivalController.

signal obstacle_hit(obstacle_id: String, hit_position: Vector2)

@export var obstacle_id: String = "chilli"
@export var fall_speed: float = 380.0
@export var fall_acceleration: float = 240.0
@export var spin_speed: float = 2.5
@export var horizontal_drift: float = 0.0
@export var ground_y: float = 430.0

@onready var visual_sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _velocity: Vector2 = Vector2.ZERO
var _is_destroyed: bool = false
var _drift_phase: float = 0.0

func _ready() -> void:
	# Hazards layer: Layer 4, detects Vehicles layer: Layer 2
	collision_layer = 8 # Layer 4
	collision_mask = 7  # Detects Layer 1 (World) & Layer 2 (Vehicles)

	# Ensure visual sprite scale matches collision shape geometry
	if is_instance_valid(visual_sprite) and visual_sprite.texture:
		var tex_h := float(visual_sprite.texture.get_height())
		var col_radius := 24.0
		if is_instance_valid(collision_shape) and collision_shape.shape is CircleShape2D:
			col_radius = (collision_shape.shape as CircleShape2D).radius
		var target_diam := col_radius * 2.2 # Slight padding for visual outline
		if tex_h > 0.0:
			var s := target_diam / tex_h
			visual_sprite.scale = Vector2(s, s)

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	_velocity = Vector2(randf_range(-15.0, 15.0), fall_speed)
	_drift_phase = randf_range(0.0, TAU)

func _physics_process(delta: float) -> void:
	if _is_destroyed:
		return

	_velocity.y += fall_acceleration * delta
	if horizontal_drift > 0.0:
		_drift_phase += delta * 4.0
		_velocity.x = sin(_drift_phase) * horizontal_drift

	global_position += _velocity * delta
	rotation += spin_speed * delta

	# Check ground impact
	if global_position.y >= ground_y:
		_destroy_on_ground()

func _on_body_entered(body: Node) -> void:
	if _is_destroyed:
		return

	if body is VehicleController or body.is_in_group("vehicle") or body.name == "Vehicle" or body.get_parent() is VehicleController:
		_trigger_hit()

func _on_area_entered(area: Area2D) -> void:
	if _is_destroyed:
		return

	if area.is_in_group("vehicle") or area.get_parent() is VehicleController:
		_trigger_hit()

func _trigger_hit() -> void:
	if _is_destroyed:
		return
	_is_destroyed = true

	obstacle_hit.emit(obstacle_id, global_position)

	# Pop animation
	if is_instance_valid(visual_sprite):
		var tw := create_tween()
		if is_instance_valid(tw):
			tw.tween_property(visual_sprite, "scale", Vector2(1.3, 1.3), 0.08)
			tw.tween_property(visual_sprite, "scale", Vector2.ZERO, 0.12)
			tw.tween_callback(queue_free)
			return

	queue_free()

func _destroy_on_ground() -> void:
	if _is_destroyed:
		return
	_is_destroyed = true

	# Fade out on ground contact
	if is_instance_valid(visual_sprite):
		var tw := create_tween()
		if is_instance_valid(tw):
			tw.tween_property(visual_sprite, "modulate:a", 0.0, 0.15)
			tw.tween_callback(queue_free)
			return

	queue_free()
