class_name FoodObstacle
extends Node2D

## FoodObstacle: Base controller for all 8 Indian food falling hazards in Survival mode.
## Emits authoritative collision signal to SurvivalController without mutating lives directly.
## Supports distinct movement identities: straight fall, rotation, spinning, wobble, and bounce.
## Integrates GroundShadow warning prediction, subtle falling effects, and ground impact bursts.

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

const GroundShadowScene: PackedScene = preload("res://scenes/modes/survival/shadows/ground_shadow.tscn")
const GroundShadowClass = preload("res://scripts/components/survival_obstacles/ground_shadow.gd")
const LandingDustEffectScene: PackedScene = preload("res://scenes/components/effects/landing_dust_effect.tscn")
const LandingDustEffectClass = preload("res://scripts/components/effects/landing_dust_effect.gd")
const TEX_IMPACT_BURST: Texture2D = preload("res://assets/obstacles/survival/support/impact_effects/ground_contact_impact_burst.png")
const TEX_DUST_PARTICLE: Texture2D = preload("res://assets/obstacles/survival/support/impact_effects/small_dust_impact_particles.png")
const TEX_VEHICLE_IMPACT: Texture2D = preload("res://assets/obstacles/survival/support/impact_effects/generic_collision_impact_effect.png")

@export var obstacle_id: String = "idli"
@export var movement_type: MovementType = MovementType.STRAIGHT
@export var fall_speed: float = 400.0
@export var rotation_speed: float = 0.0
@export var ground_y: float = 410.0
@export var ground_bounce_count: int = 0
@export var max_bounces: int = 2
@export var bounce_velocity: float = -280.0
@export var can_damage_vehicle: bool = true
@export var landing_effect_scale: float = 0.26
@export var landing_animation: String = "mushroom_cloud"
@export var enable_secondary_ring: bool = false
@export var enable_airborne_trail: bool = true

var terrain_generator: Node = null
var has_touched_ground: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var hitbox: Area2D = get_node_or_null("Hitbox")
@onready var ground_shadow: Node2D = get_node_or_null("GroundShadow")

var _current_velocity: Vector2 = Vector2.ZERO
var _has_hit: bool = false
var _elapsed: float = 0.0
var _initial_scale: Vector2 = Vector2.ONE
var _bounces_left: int = 0
var _spawn_y: float = 0.0
var _total_fall_distance: float = 600.0
var _predicted_landing: Vector2 = Vector2.ZERO

func _ready() -> void:
	can_damage_vehicle = true
	has_touched_ground = false
	_current_velocity = Vector2(0.0, fall_speed)
	_bounces_left = max_bounces
	_spawn_y = global_position.y
	
	if is_instance_valid(sprite):
		_initial_scale = sprite.scale
	
	if is_instance_valid(hitbox):
		if not hitbox.area_entered.is_connected(_on_area_entered):
			hitbox.area_entered.connect(_on_area_entered)
		if not hitbox.body_entered.is_connected(_on_body_entered):
			hitbox.body_entered.connect(_on_body_entered)
		
	# Fallback/Backward compatibility for ground shadow
	if not is_instance_valid(ground_shadow):
		var existing_shadow := get_node_or_null("Shadow")
		if is_instance_valid(existing_shadow) and (existing_shadow is GroundShadowClass or existing_shadow.has_method("update_landing_state")):
			ground_shadow = existing_shadow
		elif existing_shadow is Sprite2D:
			# Replace legacy Sprite2D shadow with GroundShadow
			existing_shadow.visible = false
			ground_shadow = GroundShadowScene.instantiate() as Node2D
			add_child(ground_shadow)
		else:
			ground_shadow = GroundShadowScene.instantiate() as Node2D
			add_child(ground_shadow)

	# Ensure GroundShadow base scale reflects obstacle geometry
	if is_instance_valid(ground_shadow):
		match movement_type:
			MovementType.ROTATING: # Dosa elongated
				ground_shadow.base_scale = Vector2(0.55, 0.38)
			MovementType.CLUSTER:  # Pani Puri cluster
				ground_shadow.base_scale = Vector2(0.60, 0.42)
			_:
				ground_shadow.base_scale = Vector2(0.42, 0.38)

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

	# Initial landing prediction
	_update_predicted_landing()
	if is_instance_valid(ground_shadow):
		var alt := maxf(0.0, _predicted_landing.y - (global_position.y + get_bottom_offset()))
		_total_fall_distance = maxf(alt, 100.0)
		ground_shadow.update_landing_state(_predicted_landing, alt, _total_fall_distance)

## Explicit spawn initialization to synchronize world position, terrain generator, and shadow state
func setup_spawn(x: float, y: float, surf_y: float, t_gen: Node = null) -> void:
	global_position = Vector2(x, y)
	_spawn_y = y
	ground_y = surf_y
	if t_gen != null:
		terrain_generator = t_gen
	_update_predicted_landing()
	if is_instance_valid(ground_shadow):
		var alt := maxf(0.0, _predicted_landing.y - (global_position.y + get_bottom_offset()))
		_total_fall_distance = maxf(alt, 100.0)
		ground_shadow.update_landing_state(_predicted_landing, alt, _total_fall_distance)

## Computes dynamic distance from obstacle origin to its lowest visual/collision boundary.
## Accurately reflects sprite rotation, scaling, wobbling, and collision geometry.
func get_bottom_offset() -> float:
	var visual_extent: float = 0.0
	if is_instance_valid(sprite) and sprite.texture != null:
		var tex_size := sprite.texture.get_size()
		var s_scale := sprite.scale.abs()
		var hw := tex_size.x * s_scale.x * 0.5
		var hh := tex_size.y * s_scale.y * 0.5
		var rot := sprite.rotation
		visual_extent = absf(hw * sin(rot)) + absf(hh * cos(rot))

	var shape_extent: float = 0.0
	if is_instance_valid(hitbox):
		var col_shape := hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if is_instance_valid(col_shape) and col_shape.shape != null:
			if col_shape.shape is CircleShape2D:
				shape_extent = (col_shape.shape as CircleShape2D).radius
			elif col_shape.shape is CapsuleShape2D:
				var cap := col_shape.shape as CapsuleShape2D
				var cap_half_len := maxf(0.0, (cap.height * 0.5) - cap.radius)
				var rot := col_shape.rotation
				shape_extent = absf(cap_half_len * cos(rot)) + cap.radius
			elif col_shape.shape is RectangleShape2D:
				var rect := col_shape.shape as RectangleShape2D
				var hw := rect.size.x * 0.5
				var hh := rect.size.y * 0.5
				var rot := col_shape.rotation
				shape_extent = absf(hw * sin(rot)) + absf(hh * cos(rot))

	return maxf(shape_extent, visual_extent)

func _physics_process(delta: float) -> void:
	if _has_hit:
		return
		
	_elapsed += delta
	
	# Gravity / acceleration
	_current_velocity.y += 350.0 * delta

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

	# Dynamic bottom boundary of this obstacle accounting for current rotation/scale
	var bottom_offset := get_bottom_offset()

	# Projected next position for this physics step
	var next_x := global_position.x + _current_velocity.x * delta
	var next_y := global_position.y + _current_velocity.y * delta

	# Sample ground surface at next X
	ground_y = get_surface_y_at(next_x)

	# Predictive ground contact check: prevents downward overshooting into terrain
	if _current_velocity.y >= 0.0 and (next_y + bottom_offset) >= ground_y:
		global_position.x = next_x
		global_position.y = ground_y - bottom_offset
		_current_velocity.y = 0.0
		
		# First ground contact marks damage disabled immediately
		if not has_touched_ground:
			has_touched_ground = true
			can_damage_vehicle = false

		if _bounces_left > 0:
			_trigger_bounce()
		elif not _has_hit:
			_handle_ground_impact()
	else:
		global_position.x = next_x
		global_position.y = next_y

	# Subtle falling motion visual feedback
	queue_redraw()

	# Dynamic landing prediction and shadow update
	_update_predicted_landing()
	if is_instance_valid(ground_shadow):
		var altitude := maxf(0.0, _predicted_landing.y - (global_position.y + bottom_offset))
		ground_shadow.update_landing_state(_predicted_landing, altitude, _total_fall_distance)

## Renders lightweight subtle motion streaks behind the falling obstacle
func _draw() -> void:
	if _has_hit or _current_velocity.y < 280.0:
		return
	# Draw two subtle air stream lines trailing above the food silhouette
	var alpha: float = clampf((_current_velocity.y - 280.0) / 300.0, 0.0, 0.35)
	var streak_color := Color(1.0, 0.95, 0.85, alpha)
	var half_w: float = 14.0
	var streak_len: float = clampf(_current_velocity.y * 0.06, 12.0, 32.0)
	draw_line(Vector2(-half_w, -16.0), Vector2(-half_w, -16.0 - streak_len), streak_color, 1.5)
	draw_line(Vector2(half_w, -16.0), Vector2(half_w, -16.0 - streak_len), streak_color, 1.5)
	
	# Subtle micro dust flecks trailing above high-speed falling obstacle
	if enable_airborne_trail and _current_velocity.y > 380.0:
		var fleck_alpha: float = clampf((_current_velocity.y - 380.0) / 200.0, 0.0, 0.25)
		var fleck_col := Color(1.0, 0.94, 0.82, fleck_alpha)
		var t_off: float = fposmod(_elapsed * 32.0, 22.0)
		draw_circle(Vector2(-half_w * 0.4, -22.0 - t_off), 1.2, fleck_col)
		draw_circle(Vector2(half_w * 0.5, -32.0 - t_off * 0.75), 1.1, fleck_col)

## Query terrain surface height from terrain generator or fall back to ground_y
func get_surface_y_at(x: float) -> float:
	if is_instance_valid(terrain_generator) and terrain_generator.has_method("get_surface_y_at_world_x"):
		return terrain_generator.get_surface_y_at_world_x(x)
	return ground_y

## Solves ballistic trajectory against uneven procedural terrain to find exact landing point.
func _update_predicted_landing() -> void:
	_predicted_landing = calculate_predicted_landing()

func calculate_predicted_landing() -> Vector2:
	var gravity: float = 350.0
	var cur_x: float = global_position.x
	var cur_y: float = global_position.y
	var vy: float = _current_velocity.y
	var vx: float = _current_velocity.x
	var bottom_offset := get_bottom_offset()
	
	# First approximation at current X
	var est_ground_y := get_surface_y_at(cur_x)
	var target_center_y := est_ground_y - bottom_offset
	var delta_y: float = target_center_y - cur_y
	
	if delta_y <= 0.0:
		return Vector2(cur_x, est_ground_y)
		
	# Quadratic formula: 0.5 * g * t^2 + vy * t - delta_y = 0
	var disc: float = (vy * vy) + (2.0 * gravity * delta_y)
	var t: float = 0.0
	if disc >= 0.0:
		t = (-vy + sqrt(disc)) / gravity
	else:
		t = 0.0

	var pred_x := cur_x + (vx * t)
	var pred_ground_y := get_surface_y_at(pred_x)

	# Second refinement pass for uneven terrain height at predicted X
	if absf(pred_ground_y - est_ground_y) > 2.0:
		target_center_y = pred_ground_y - bottom_offset
		delta_y = target_center_y - cur_y
		disc = (vy * vy) + (2.0 * gravity * delta_y)
		if disc >= 0.0:
			t = (-vy + sqrt(disc)) / gravity
			pred_x = cur_x + (vx * t)
			pred_ground_y = get_surface_y_at(pred_x)

	return Vector2(pred_x, pred_ground_y)

## Returns estimated seconds to impact from current state
func get_time_to_impact() -> float:
	var gravity: float = 350.0
	var cur_y: float = global_position.y
	var vy: float = _current_velocity.y
	var bottom_offset := get_bottom_offset()
	var delta_y: float = (_predicted_landing.y - bottom_offset) - cur_y
	if delta_y <= 0.0:
		return 0.0
	var disc: float = (vy * vy) + (2.0 * gravity * delta_y)
	if disc >= 0.0:
		return (-vy + sqrt(disc)) / gravity
	return 0.5

func _trigger_bounce() -> void:
	# Synchronously disable damage before any bounce physics or velocity is applied
	has_touched_ground = true
	can_damage_vehicle = false
	_bounces_left -= 1
	ground_bounce_count += 1
	var bottom_offset := get_bottom_offset()
	global_position.y = ground_y - bottom_offset - 1.0
	_current_velocity.y = bounce_velocity * (0.65 ** (max_bounces - _bounces_left))
	_current_velocity.x = randf_range(-60.0, 60.0)
	
	# Spawn small road-contact dust puff for bounce feedback
	_spawn_bounce_dust(Vector2(global_position.x, ground_y))
	
	# Update flight distance and predicted landing for upcoming bounce
	_update_predicted_landing()
	_total_fall_distance = maxf(absf(_current_velocity.y * 0.5), 80.0)
	if is_instance_valid(ground_shadow):
		ground_shadow.update_landing_state(_predicted_landing, 0.0, _total_fall_distance)

func _handle_ground_impact() -> void:
	has_touched_ground = true
	can_damage_vehicle = false
	_has_hit = true
	var bottom_offset := get_bottom_offset()
	global_position.y = ground_y - bottom_offset
	_spawn_ground_impact_visual(Vector2(global_position.x, ground_y))
	if is_instance_valid(ground_shadow):
		ground_shadow.fade_and_free(0.2)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	_check_vehicle_collision(body)

func _on_area_entered(area: Area2D) -> void:
	_check_vehicle_collision(area)

func _check_vehicle_collision(node: Node) -> void:
	if _has_hit:
		return
	if not can_damage_vehicle or has_touched_ground:
		return
	if not is_instance_valid(node):
		return

	# Collision-order protection: If obstacle reached or passed ground height in the same physics frame,
	# ground contact takes priority; disable damage immediately and ignore vehicle damage.
	var bottom_offset := get_bottom_offset()
	if (global_position.y + bottom_offset) >= ground_y:
		has_touched_ground = true
		can_damage_vehicle = false
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
		can_damage_vehicle = false
		_spawn_vehicle_collision_visual(global_position)
		if is_instance_valid(ground_shadow):
			ground_shadow.fade_and_free(0.15)
		queue_free()

## Ground impact effects: Reusable cartoon landing dust animation and secondary layers
func _spawn_ground_impact_visual(pos: Vector2) -> void:
	var parent_node := get_parent()
	if not is_instance_valid(parent_node):
		return

	# Configure obstacle-specific landing scale and shockwave ring
	var with_ring: bool = enable_secondary_ring or (obstacle_id in ["vada", "samosa", "murukku", "coconut", "pani_puri"])
	var eff_scale: float = landing_effect_scale
	if obstacle_id == "pani_puri":
		eff_scale = 0.30
	elif obstacle_id == "coconut":
		eff_scale = 0.28
	elif obstacle_id in ["vada", "samosa", "murukku"]:
		eff_scale = 0.27

	# 1. Instantiate reusable LandingDustEffect (Candidate 1 Mushroom Cloud & optional ring)
	LandingDustEffectClass.spawn_at(parent_node, pos, landing_animation, eff_scale, with_ring, true)

	# 2. Ground contact impact burst
	var burst := Sprite2D.new()
	burst.texture = TEX_IMPACT_BURST
	burst.global_position = pos + Vector2(0.0, -6.0)
	burst.scale = Vector2(0.12, 0.07)
	burst.modulate = Color(1.0, 0.95, 0.85, 0.9)
	burst.z_index = 1
	parent_node.add_child(burst)

	var burst_tw := burst.create_tween()
	burst_tw.set_parallel(true)
	burst_tw.tween_property(burst, "scale", Vector2(0.24, 0.12), 0.20)
	burst_tw.tween_property(burst, "modulate:a", 0.0, 0.22)
	burst_tw.chain().tween_callback(burst.queue_free)

	# 3. Small secondary dust impact particles
	for i in range(3):
		var dust := Sprite2D.new()
		dust.texture = TEX_DUST_PARTICLE
		dust.global_position = pos + Vector2(randf_range(-14.0, 14.0), -3.0)
		dust.scale = Vector2(0.7, 0.7)
		dust.modulate = Color(0.92, 0.85, 0.72, 0.7)
		dust.z_index = 1
		parent_node.add_child(dust)

		var target_pos := dust.global_position + Vector2(randf_range(-35.0, 35.0), randf_range(-15.0, -40.0))
		var dust_tw := dust.create_tween()
		dust_tw.set_parallel(true)
		dust_tw.tween_property(dust, "global_position", target_pos, 0.28)
		dust_tw.tween_property(dust, "scale", Vector2(1.4, 1.4), 0.28)
		dust_tw.tween_property(dust, "modulate:a", 0.0, 0.28)
		dust_tw.chain().tween_callback(dust.queue_free)

## Vehicle collision effect: Sharp metal collision impact flash
func _spawn_vehicle_collision_visual(pos: Vector2) -> void:
	var parent_node := get_parent()
	if not is_instance_valid(parent_node):
		return

	var effect := Sprite2D.new()
	effect.texture = TEX_VEHICLE_IMPACT
	effect.global_position = pos
	effect.scale = Vector2(0.35, 0.35)
	effect.modulate = Color(1.0, 0.9, 0.7, 0.95)
	effect.z_index = 2
	parent_node.add_child(effect)

	var tw := effect.create_tween()
	tw.set_parallel(true)
	tw.tween_property(effect, "scale", Vector2(0.65, 0.65), 0.2)
	tw.tween_property(effect, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(effect.queue_free)

## Coconut bounce dust feedback: Spawns Candidate 3 (Impact Poof) at road contact point
func _spawn_bounce_dust(pos: Vector2) -> void:
	var parent_node := get_parent()
	if not is_instance_valid(parent_node):
		return

	# Reusable LandingDustEffect using Candidate 3 (impact_poof) for snappy bounce feedback
	LandingDustEffectClass.spawn_at(parent_node, pos, "impact_poof", 0.18, false, true)

	for i in range(2):
		var dust := Sprite2D.new()
		dust.texture = TEX_DUST_PARTICLE
		dust.global_position = pos + Vector2(randf_range(-10.0, 10.0), -2.0)
		dust.scale = Vector2(0.6, 0.6)
		dust.modulate = Color(0.9, 0.82, 0.7, 0.6)
		dust.z_index = 1
		parent_node.add_child(dust)

		var target_pos := dust.global_position + Vector2(randf_range(-25.0, 25.0), randf_range(-12.0, -30.0))
		var dust_tw := dust.create_tween()
		dust_tw.set_parallel(true)
		dust_tw.tween_property(dust, "global_position", target_pos, 0.22)
		dust_tw.tween_property(dust, "scale", Vector2(1.2, 1.2), 0.22)
		dust_tw.tween_property(dust, "modulate:a", 0.0, 0.22)
		dust_tw.chain().tween_callback(dust.queue_free)
