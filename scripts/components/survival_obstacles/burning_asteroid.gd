class_name BurningAsteroid
extends Node2D

## BurningAsteroid: Fiery meteor hazard exclusive to Hard Mode.
## Falls without warning signs. Blazes with full 3-layer flame trail (yellow, orange, red-orange).
## On ground impact, triggers explosive burst and excavates a permanent road pothole!

signal obstacle_hit(obstacle_id: String, hit_position: Vector2)
signal burning_impact_occurred(impact_position: Vector2, terrain_angle: float)

const TEX_IMPACT_EXPLOSION: Texture2D = preload("res://assets/obstacles/survival/burning_asteroid/burning_asteroid_impact_effect.png")
const SFX_IMPACT: AudioStream = preload("res://assets/audio/survival/sfx/asteroids/flaming_asteroid_impact.wav")
const PotholeScene: PackedScene = preload("res://scenes/modes/survival/hazards/pothole_hazard.tscn")
const LandingBurstScene: PackedScene = preload("res://scenes/modes/survival/hazards/landing_burst.tscn")

@export var obstacle_id: String = "burning_asteroid"
@export var fall_speed: float = 330.0
@export var horizontal_speed: float = -45.0
@export var fall_acceleration: float = 160.0
@export var ground_y: float = 410.0
@export var can_damage_vehicle: bool = true
@export var create_pothole_on_impact: bool = true

var terrain_generator: Node = null
var follow_camera: Node = null
var has_touched_ground: bool = false
var _has_hit: bool = false
var _elapsed: float = 0.0
var _velocity: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var glow_sprite: Sprite2D = get_node_or_null("AsteroidGlow")
@onready var flame_trail: AnimatedSprite2D = get_node_or_null("AnimatedFlameTrail")
@onready var sparks_emitter: CPUParticles2D = get_node_or_null("SparksEmitter")
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

func setup_spawn(target_x: float, spawn_y: float, target_ground_y: float, t_gen: Node = null, cam: Node = null) -> void:
	global_position = Vector2(target_x, spawn_y)
	ground_y = target_ground_y
	terrain_generator = t_gen
	follow_camera = cam
	horizontal_speed = randf_range(-65.0, -25.0)
	_velocity = Vector2(horizontal_speed, fall_speed)

func _process(delta: float) -> void:
	_elapsed += delta
	_update_flames(delta)
	
	if not has_touched_ground:
		_process_airborne(delta)

func _update_flames(delta: float) -> void:
	# Keep trailing flames pointing upper-right along trajectory with subtle atmospheric flutter
	var flutter := sin(_elapsed * 14.0) * 0.035
	if is_instance_valid(sprite):
		sprite.rotation = flutter
	if is_instance_valid(flame_trail):
		flame_trail.rotation = flutter * 0.8
	if is_instance_valid(glow_sprite):
		# Gentle pulsing glow intensity
		glow_sprite.modulate.a = 0.40 + sin(_elapsed * 8.0) * 0.08

func _process_airborne(delta: float) -> void:
	_velocity.y += fall_acceleration * delta # Moderate, readable descent acceleration
	global_position += _velocity * delta

	# Proactively detect vehicle overlap during descent
	if is_instance_valid(hitbox):
		for body in hitbox.get_overlapping_bodies():
			_check_vehicle_collision(body)
			if _has_hit:
				return

	# Sample dynamic terrain surface Y
	var current_ground_y := ground_y
	if is_instance_valid(terrain_generator) and terrain_generator.has_method("get_surface_y_at_world_x"):
		current_ground_y = terrain_generator.get_surface_y_at_world_x(global_position.x)

	if global_position.y >= current_ground_y:
		_on_impact_ground(current_ground_y)

func _on_impact_ground(impact_y: float) -> void:
	has_touched_ground = true
	can_damage_vehicle = false
	global_position.y = impact_y

	# Calculate ground tangent slope angle for road alignment
	var surface_angle: float = 0.0
	if is_instance_valid(terrain_generator) and terrain_generator.has_method("get_surface_y_at_world_x"):
		var y_left: float = terrain_generator.get_surface_y_at_world_x(global_position.x - 30.0)
		var y_right: float = terrain_generator.get_surface_y_at_world_x(global_position.x + 30.0)
		surface_angle = atan2(y_right - y_left, 60.0)

	burning_impact_occurred.emit(global_position, surface_angle)
	
	_spawn_explosion_burst()
	_play_impact_sound()

	if create_pothole_on_impact:
		_create_pothole(global_position, surface_angle)

	# Free the asteroid after impact effects trigger
	visible = false
	set_process(false)
	get_tree().create_timer(1.0).timeout.connect(queue_free)

func _create_pothole(pos: Vector2, angle: float) -> void:
	if PotholeScene == null:
		return
	var pothole: Node2D = PotholeScene.instantiate() as Node2D
	if not is_instance_valid(pothole):
		return
	
	if pothole.has_method("setup_pothole"):
		pothole.setup_pothole(pos, angle, terrain_generator, follow_camera)
	else:
		pothole.global_position = pos
		pothole.rotation = angle
	
	var target_parent: Node = get_parent()
	if is_instance_valid(target_parent):
		target_parent.add_child(pothole)
	else:
		get_tree().current_scene.add_child(pothole)

func _spawn_explosion_burst() -> void:
	# Instantiate animated 8-frame landing burst VFX if available
	if LandingBurstScene:
		var burst: Node2D = LandingBurstScene.instantiate() as Node2D
		if is_instance_valid(burst):
			burst.global_position = global_position
			var parent_node := get_parent()
			if is_instance_valid(parent_node):
				parent_node.add_child(burst)
			else:
				get_tree().current_scene.add_child(burst)
			return

	# Fallback burst
	var fallback_burst := Sprite2D.new()
	fallback_burst.texture = TEX_IMPACT_EXPLOSION
	fallback_burst.scale = Vector2(0.4, 0.4)
	fallback_burst.global_position = Vector2(global_position.x, global_position.y - 20.0)
	var parent_node := get_parent()
	if is_instance_valid(parent_node):
		parent_node.add_child(fallback_burst)
		var tw := fallback_burst.create_tween()
		tw.set_parallel(true)
		tw.tween_property(fallback_burst, "scale", Vector2(0.75, 0.65), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(fallback_burst, "modulate:a", 0.0, 0.4).set_delay(0.15)
		tw.chain().tween_callback(fallback_burst.queue_free)

func _play_impact_sound() -> void:
	if SFX_IMPACT:
		var asp := AudioStreamPlayer2D.new()
		asp.stream = SFX_IMPACT
		asp.volume_db = -1.0
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
		_spawn_explosion_burst()
		queue_free()
