class_name UnburnedAsteroid
extends Node2D

## UnburnedAsteroid: Silent falling rock hazard introduced in Medium Mode.
## Falls without warning signs. Tumbles naturally through rotation frames.
## Damages vehicle on direct impact and kicks up rocky dust on ground contact.

signal obstacle_hit(obstacle_id: String, hit_position: Vector2)
signal ground_reached(hit_position: Vector2)

const TEX_IMPACT_DUST: Texture2D = preload("res://assets/obstacles/survival/unburned_asteroid/asteroid_impact_dust_effect.png")
const SFX_IMPACT: AudioStream = preload("res://assets/audio/survival/sfx/asteroids/normal_asteroid_impact.wav")

const ROTATION_FRAMES: Array[Texture2D] = [
	preload("res://assets/obstacles/survival/unburned_asteroid/rotation_animation_frames/asteroid_rot_01.png"),
	preload("res://assets/obstacles/survival/unburned_asteroid/rotation_animation_frames/asteroid_rot_02.png"),
	preload("res://assets/obstacles/survival/unburned_asteroid/rotation_animation_frames/asteroid_rot_03.png"),
	preload("res://assets/obstacles/survival/unburned_asteroid/rotation_animation_frames/asteroid_rot_04.png"),
	preload("res://assets/obstacles/survival/unburned_asteroid/rotation_animation_frames/asteroid_rot_05.png"),
	preload("res://assets/obstacles/survival/unburned_asteroid/rotation_animation_frames/asteroid_rot_06.png"),
	preload("res://assets/obstacles/survival/unburned_asteroid/rotation_animation_frames/asteroid_rot_07.png"),
	preload("res://assets/obstacles/survival/unburned_asteroid/rotation_animation_frames/asteroid_rot_08.png")
]

@export var obstacle_id: String = "unburned_asteroid"
@export var fall_speed: float = 460.0
@export var horizontal_speed: float = 35.0
@export var ground_y: float = 410.0
@export var can_damage_vehicle: bool = true

var terrain_generator: Node = null
var has_touched_ground: bool = false
var _has_hit: bool = false
var _elapsed: float = 0.0
var _anim_frame: int = 0
var _anim_timer: float = 0.0
var _velocity: Vector2 = Vector2.ZERO
var _bounces_left: int = 1

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var hitbox: Area2D = get_node_or_null("Hitbox")

func _ready() -> void:
	can_damage_vehicle = true
	has_touched_ground = false
	_has_hit = false
	_velocity = Vector2(horizontal_speed, fall_speed)
	
	if is_instance_valid(hitbox):
		if not hitbox.body_entered.is_connected(_on_body_entered):
			hitbox.body_entered.connect(_on_body_entered)
		if not hitbox.area_entered.is_connected(_on_area_entered):
			hitbox.area_entered.connect(_on_area_entered)

func setup_spawn(target_x: float, spawn_y: float, target_ground_y: float, t_gen: Node = null) -> void:
	global_position = Vector2(target_x, spawn_y)
	ground_y = target_ground_y
	terrain_generator = t_gen
	horizontal_speed = randf_range(-30.0, 45.0)
	_velocity = Vector2(horizontal_speed, fall_speed)

func _process(delta: float) -> void:
	_elapsed += delta
	_update_animation(delta)
	
	if not has_touched_ground:
		_process_airborne(delta)
	else:
		_process_ground(delta)

func _update_animation(delta: float) -> void:
	_anim_timer += delta
	if _anim_timer >= 0.08:
		_anim_timer = 0.0
		_anim_frame = (_anim_frame + 1) % ROTATION_FRAMES.size()
		if is_instance_valid(sprite) and not ROTATION_FRAMES.is_empty():
			sprite.texture = ROTATION_FRAMES[_anim_frame]

func _process_airborne(delta: float) -> void:
	_velocity.y += 420.0 * delta # Gravity acceleration
	global_position += _velocity * delta
	
	# Proactively detect vehicle overlap during descent
	if is_instance_valid(hitbox):
		for body in hitbox.get_overlapping_bodies():
			_check_vehicle_collision(body)
			if _has_hit:
				return

	# Sample dynamic terrain surface Y if available
	var current_ground_y := ground_y
	if is_instance_valid(terrain_generator) and terrain_generator.has_method("get_surface_y_at_world_x"):
		current_ground_y = terrain_generator.get_surface_y_at_world_x(global_position.x)
	
	if global_position.y >= current_ground_y:
		_on_impact_ground(current_ground_y)

func _on_impact_ground(impact_y: float) -> void:
	has_touched_ground = true
	can_damage_vehicle = false # Disarm once it strikes the ground
	global_position.y = impact_y
	ground_reached.emit(global_position)
	
	_spawn_impact_dust()
	_play_impact_sound()
	
	if _bounces_left > 0:
		_bounces_left -= 1
		_velocity = Vector2(horizontal_speed * 0.6, -180.0)
	else:
		_fade_out_and_free()

func _process_ground(delta: float) -> void:
	_velocity.y += 600.0 * delta
	_velocity.x = move_toward(_velocity.x, 0.0, 150.0 * delta)
	global_position += _velocity * delta
	
	var current_ground_y := ground_y
	if is_instance_valid(terrain_generator) and terrain_generator.has_method("get_surface_y_at_world_x"):
		current_ground_y = terrain_generator.get_surface_y_at_world_x(global_position.x)
	
	if global_position.y >= current_ground_y:
		global_position.y = current_ground_y
		_fade_out_and_free()

func _spawn_impact_dust() -> void:
	var dust := Sprite2D.new()
	dust.texture = TEX_IMPACT_DUST
	dust.scale = Vector2(0.38, 0.38)
	dust.global_position = Vector2(global_position.x, global_position.y - 12.0)
	dust.modulate = Color(1.0, 1.0, 1.0, 0.85)
	
	var parent_node := get_parent()
	if is_instance_valid(parent_node):
		parent_node.add_child(dust)
		var tw := dust.create_tween()
		tw.set_parallel(true)
		tw.tween_property(dust, "scale", Vector2(0.55, 0.55), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(dust, "modulate:a", 0.0, 0.35).set_delay(0.1)
		tw.chain().tween_callback(dust.queue_free)

func _play_impact_sound() -> void:
	if SFX_IMPACT:
		var asp := AudioStreamPlayer2D.new()
		asp.stream = SFX_IMPACT
		asp.volume_db = -4.0
		asp.global_position = global_position
		var parent_node := get_parent()
		if is_instance_valid(parent_node):
			parent_node.add_child(asp)
			asp.play()
			asp.finished.connect(asp.queue_free)

func _on_body_entered(body: Node2D) -> void:
	_check_vehicle_collision(body)

func _on_area_entered(area: Area2D) -> void:
	_check_vehicle_collision(area)

func _check_vehicle_collision(node: Node) -> void:
	if _has_hit or not can_damage_vehicle or has_touched_ground:
		return
	if not is_instance_valid(node):
		return
		
	var is_vehicle: bool = false
	if node is VehicleController or node.get_parent() is VehicleController:
		is_vehicle = true
	elif node.name == "Vehicle" or node.name.begins_with("Wheel") or "Wheel" in node.name or node.name == "Chassis":
		is_vehicle = true
	elif node.has_method("apply_torque") or node.has_method("refuel"):
		is_vehicle = true
	elif node.is_in_group("vehicle"):
		is_vehicle = true
		
	if is_vehicle:
		_has_hit = true
		obstacle_hit.emit(obstacle_id, global_position)
		can_damage_vehicle = false
		_spawn_impact_dust()
		queue_free()

func _fade_out_and_free() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.4).set_delay(0.2)
	tw.tween_callback(queue_free)
