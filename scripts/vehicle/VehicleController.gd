class_name VehicleController
extends RigidBody2D

const NitroFlameScript = preload("res://scripts/vehicle/NitroFlame.gd")

## VehicleController: 2D physics-based vehicle controller.
## Dual-wheel suspension joints, dynamic RPM audio, air tilt flips, stunts & airtime detection, and upgrade tiers.

signal crashed
signal fuel_changed(current: float, max_fuel: float)
signal nitro_changed(current: float, max_nitro: float)
signal nitro_state_changed(is_boosting: bool)
signal pothole_assist_hint(should_hint: bool)
signal upgraded(stat_name: String, level: int)
signal trick_performed(trick_name: String, reward_coins: int)
signal airtime_landed(duration: float, reward_coins: int)
signal hard_landed(severity: float)
signal clean_landed(bonus_coins: int)
signal monster_surge_state_changed(is_active: bool)
signal monster_surge_shake_requested(trauma_amount: float)

@export_group("Real-Life Physics")
## Drive layout: "RWD" (Rear-Wheel Drive), "AWD" (All-Wheel Drive / 4x4), "FWD" (Front-Wheel Drive)
@export var drive_type: String = "RWD"
## Physical mass of each wheel (kg)
@export var wheel_mass: float = 25.0
## Rolling resistance coefficient (e.g. 0.015 - 0.025)
@export var rolling_resistance_coeff: float = 0.02
## Aerodynamic air drag coefficient
@export var air_drag_coeff: float = 0.018
## Engine braking resistance factor when releasing throttle (0.10 - 0.15)
@export var engine_brake_strength: float = 0.12
## Weight distribution fraction on front axle (e.g. 0.55 for cars, 0.40 for bikes, 0.50 for Bigfoot)
@export var front_weight_ratio: float = 0.50
## Weight distribution fraction on rear axle (e.g. 0.45 for cars, 0.60 for bikes, 0.50 for Bigfoot)
@export var rear_weight_ratio: float = 0.50

@export_group("Upgrade Levels (1-5)")
## Engine Power level (1 to 5)
@export_range(1, 5) var engine_level: int = 1:
	set(val):
		engine_level = clampi(val, 1, 5)
		_recalculate_upgrades()

## Tire Grip level (1 to 5)
@export_range(1, 5) var grip_level: int = 1:
	set(val):
		grip_level = clampi(val, 1, 5)
		_recalculate_upgrades()

## Suspension Dampening level (1 to 5)
@export_range(1, 5) var suspension_level: int = 1:
	set(val):
		suspension_level = clampi(val, 1, 5)
		_recalculate_upgrades()

## Fuel Tank Capacity level (1 to 5)
@export_range(1, 5) var fuel_tank_level: int = 1:
	set(val):
		fuel_tank_level = clampi(val, 1, 5)
		_recalculate_upgrades()

@export_group("Base Stats (Level 1)")
@export var base_motor_torque: float = 75000.0
@export var base_brake_torque: float = 45000.0
@export var base_max_wheel_speed: float = 80.0
@export var base_wheel_friction: float = 1.6
@export var base_suspension_softness: float = 0.45
@export var base_max_fuel: float = 100.0

@export_group("Active Suspension Physics")
## Physical radius of the wheels
@export var wheel_radius: float = 22.0
## Natural oscillation frequency of the vehicle body on the suspension (Hz)
@export var body_frequency_hz: float = 2.0
## Damping ratio: 0.7 is well-damped, 1.0 is critically damped (no bounce)
@export var damping_ratio: float = 0.7
## Maximum wheel travel as fraction of wheel radius
@export var max_travel_fraction: float = 0.25
## Hard bump-stop limit fraction
@export var bump_stop_fraction: float = 0.25
## Rebound speed limit factor
@export var rebound_limit_fraction: float = 0.25
## Vehicle mass m used to compute spring rate k and damping rate c
@export var vehicle_mass: float = 8.0
## Rest sag fraction of max travel (25% sag at rest)
@export var rest_sag_fraction: float = 0.25
## Spring stiffness rate along strut axis (N/pixel)
@export var suspension_stiffness: float = 950.0
## Shock absorber damping rate along strut axis (N/(pixel/sec))
@export var suspension_damping: float = 70.0
## Maximum allowed physical suspension travel before bump-stop
@export var suspension_max_travel: float = 16.0

@export_group("Current Active Physics")
## Effective motor drive torque applied to wheels
@export var motor_torque: float = 75000.0
## Effective braking torque applied when reversing
@export var brake_torque: float = 45000.0
## Maximum rotational wheel velocity in radians/sec
@export var max_wheel_speed: float = 80.0
## Rotational torque applied for mid-air flips and tilt balancing
@export var air_tilt_torque: float = 24000.0
## Maximum rotational velocity in the air to prevent uncontrolled spinning
@export var max_air_angular_velocity: float = 6.5
## Angular damping applied when airborne without tilt input to assist clean landings
@export var airborne_angular_damping: float = 2.0

@export_group("Fuel")
## Whether acceleration consumes fuel
@export var consumes_fuel: bool = true
## Maximum fuel capacity
@export var max_fuel: float = 100.0
## Fuel burn rate in units per second of acceleration
@export var fuel_burn_rate: float = 4.0

@export_group("Nitro Boost")
## Maximum nitro capacity
@export var max_nitro: float = 100.0
## Current available nitro
@export var current_nitro: float = 100.0
## Nitro burn rate in units per second of boost
@export var nitro_consumption_rate: float = 25.0
## Nitro passive recharge rate in units per second when inactive
@export var nitro_recharge_rate: float = 14.0
## Forward thrust applied directly along vehicle forward heading (transform.x)
@export var nitro_boost_force: float = 18000.0
## Motor torque multiplier while nitro is engaged (balanced for 10-15% speed increase)
@export var nitro_torque_multiplier: float = 1.14
## Max wheel rotational speed multiplier while nitro is engaged (balanced for 10-15% speed increase)
@export var nitro_max_speed_multiplier: float = 1.12
## Traction friction increase while nitro is engaged to climb steep pothole dips
@export var nitro_traction_boost: float = 0.5
## Minimum nitro energy required to start activation
@export var nitro_min_activation_energy: float = 8.0

@onready var rear_wheel: RigidBody2D = get_node_or_null("RearWheel")
@onready var front_wheel: RigidBody2D = get_node_or_null("FrontWheel")
@onready var rear_wheel_mount: Marker2D = get_node_or_null("RearWheelMount")
@onready var front_wheel_mount: Marker2D = get_node_or_null("FrontWheelMount")
@onready var rear_strut_mount: Marker2D = get_node_or_null("RearStrutMount")
@onready var front_strut_mount: Marker2D = get_node_or_null("FrontStrutMount")
@onready var rear_joint: PinJoint2D = get_node_or_null("RearJoint")
@onready var front_joint: PinJoint2D = get_node_or_null("FrontJoint")
@onready var crash_detector: Area2D = get_node_or_null("CrashDetector")
@onready var exhaust_particles: CPUParticles2D = get_node_or_null("ExhaustParticles")
@onready var boost_particles: CPUParticles2D = get_node_or_null("BoostParticles")
@onready var rear_dust: CPUParticles2D = get_node_or_null("RearDust")
@onready var engine_audio: AudioStreamPlayer2D = get_node_or_null("EngineAudio")
@onready var landing_audio: AudioStreamPlayer2D = get_node_or_null("LandingAudio")
@onready var skid_audio: AudioStreamPlayer2D = get_node_or_null("SkidAudio")
@onready var nitro_audio: AudioStreamPlayer2D = get_node_or_null("NitroAudio")
@onready var rear_strut: Line2D = get_node_or_null("RearStrutVisual")
@onready var front_strut: Line2D = get_node_or_null("FrontStrutVisual")

var nitro_flame: Node2D = null
var nitro_burst: Sprite2D = null
var nitro_sparks: CPUParticles2D = null

var current_fuel: float = 100.0
var is_nitro_active: bool = false
var is_nitro_requested: bool = false
var _nitro_blend: float = 0.0
var is_grounded: bool = false
var is_grounded_override: bool = false
var was_grounded: bool = false
var rear_contact: bool = false
var front_contact: bool = false
var _rear_contact_timer: float = 0.0
var _front_contact_timer: float = 0.0
var is_active: bool = true
var _previous_linear_velocity: Vector2 = Vector2.ZERO
var _current_base_friction: float = 1.6
var _pothole_stuck_timer: float = 0.0
var _pothole_hint_active: bool = false
var _rear_stiffness: float = 475.0
var _rear_damping: float = 35.0
var _front_stiffness: float = 475.0
var _front_damping: float = 35.0
var _dynamic_pitch_weight_transfer: float = 0.0

## Unified Boost Configuration
const BOOST_POWER_MULTIPLIER: float = 1.25

@export_group("Engine Boost Settings")
@export var boost_power_multiplier: float = BOOST_POWER_MULTIPLIER

var engine_offset: Vector2 = Vector2.ZERO
var body_scale: float = 1.0
var crash_reason: String = ""

## Smoke Configuration Constants
const SMOKE_SCALE: float = 0.40 # 0.4 of current size
const SMOKE_MAX_PARTICLES: int = 12 # Maximum 12 particles at one time
const SMOKE_MAX_ALPHA: float = 0.35 # Maximum opacity 35%

@export_group("Engine Smoke Configuration")
@export var smoke_scale: float = SMOKE_SCALE
@export var smoke_max_particles: int = SMOKE_MAX_PARTICLES
@export var smoke_max_alpha: float = SMOKE_MAX_ALPHA

var is_damaged: bool = false

var _orig_body_pos: Vector2 = Vector2.ZERO
var _monster_dirt_particles: CPUParticles2D = null
var _monster_rock_particles: CPUParticles2D = null

func is_bigfoot_truck() -> bool:
	return vehicle_id == "car_08" or name.to_lower().contains("monster")
## Debug overlay toggle for body & wheel alignment verification (wheel = green circle, arch centre = red dot)
@export var debug_draw_alignment: bool = false
static var debug_alignment_enabled: bool = false

var _orig_body_texture: Texture2D = null
var _orig_rear_wheel_texture: Texture2D = null
var _orig_front_wheel_texture: Texture2D = null
var _burnt_body_texture: Texture2D = null
var _burnt_wheel_texture: Texture2D = null

var _initial_rear_wheel_offset: Vector2 = Vector2(-36, 18)
var _initial_front_wheel_offset: Vector2 = Vector2(36, 18)
var is_bike: bool = false

@export var vehicle_id: String = ""

# Stunt and airtime tracking
var air_time: float = 0.0
var air_rotation_accum: float = 0.0
var _last_air_rotation: float = 0.0
var wheelie_time: float = 0.0

func _infer_vehicle_id() -> String:
	var n_lower: String = name.to_lower()
	for id in VehicleRegistry.ORDERED_IDS:
		if n_lower == id.replace("_", "") or n_lower == id:
			return id
	var body_sprite = get_node_or_null("BodySprite") as Sprite2D
	if body_sprite and body_sprite.texture:
		var path = body_sprite.texture.resource_path
		for id in VehicleRegistry.ORDERED_IDS:
			if path.contains(id):
				return id
		if path.contains("truck_side") or path.contains("blue_flame"):
			return "blue_flame_truck"
		if path.contains("orc_racer"):
			return "orc_racer"
		if path.contains("trophy_truck"):
			return "trophy_truck"
		if path.contains("girl_buggy") or path.contains("buggy"):
			return "dune_buggy"
	return ""

func _apply_vehicle_config() -> void:
	if vehicle_id.is_empty():
		vehicle_id = _infer_vehicle_id()
	if vehicle_id.is_empty():
		return
	var cfg: Dictionary = VehicleRegistry.get_vehicle_config(vehicle_id)
	if cfg.is_empty():
		return
		
	var b_scale: float = cfg.get("body_scale", 1.0)
	body_scale = b_scale
	engine_offset = cfg.get("engine_offset", cfg.get("engineOffset", Vector2.ZERO))
	boost_power_multiplier = VehicleRegistry.get_boost_power_multiplier(vehicle_id)
	body_frequency_hz = float(cfg.get("bodyFrequencyHz", cfg.get("body_frequency_hz", 2.0)))
	damping_ratio = float(cfg.get("dampingRatio", cfg.get("damping_ratio", 0.7)))
	max_travel_fraction = float(cfg.get("maxTravel", cfg.get("max_travel", 0.25)))
	bump_stop_fraction = float(cfg.get("bumpStop", cfg.get("bump_stop", max_travel_fraction)))
	rebound_limit_fraction = float(cfg.get("reboundLimit", cfg.get("rebound_limit", 0.25)))
	vehicle_mass = float(cfg.get("mass", VehicleRegistry.VEHICLES.get(vehicle_id, {}).get("mass", 8.0)))
	mass = vehicle_mass
	var body_pos := Vector2.ZERO
	var body_sprite: Sprite2D = get_node_or_null("BodySprite")
	if body_sprite:
		body_pos = body_sprite.position
	var rw_off: Vector2 = body_pos + cfg.get("rear_wheel_offset", Vector2(-36, 18)) * b_scale
	var fw_off: Vector2 = body_pos + cfg.get("front_wheel_offset", Vector2(36, 18)) * b_scale
	var w_radius: float = cfg.get("wheel_radius", 22.0) * b_scale
	wheel_radius = w_radius
	suspension_max_travel = max_travel_fraction * w_radius
	is_bike = cfg.get("is_bike", false)
	# Real-Life Physics Parameters
	drive_type = cfg.get("drive_type", cfg.get("driveType", "RWD"))
	wheel_mass = float(cfg.get("wheel_mass", 25.0))
	rolling_resistance_coeff = float(cfg.get("rolling_resistance", 0.02))
	air_drag_coeff = float(cfg.get("air_drag_coeff", 0.018))
	front_weight_ratio = float(cfg.get("front_weight_ratio", 0.50))
	rear_weight_ratio = float(cfg.get("rear_weight_ratio", 0.50))
	
	if cfg.has("base_torque"):
		base_motor_torque = float(cfg.get("base_torque"))
	if cfg.has("base_brake_torque"):
		base_brake_torque = float(cfg.get("base_brake_torque"))
	if cfg.has("wheel_friction"):
		base_wheel_friction = float(cfg.get("wheel_friction"))
		
	# Center of mass placement
	var com: Vector2 = cfg.get("center_of_mass", Vector2.ZERO)
	center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = com
	
	if rear_wheel:
		rear_wheel.mass = wheel_mass
	if front_wheel:
		front_wheel.mass = wheel_mass
	
	_initial_rear_wheel_offset = rw_off
	_initial_front_wheel_offset = fw_off
	
	if rear_wheel_mount:
		rear_wheel_mount.position = rw_off
	if front_wheel_mount:
		front_wheel_mount.position = fw_off
		
	if rear_wheel:
		rear_wheel.position = rw_off
		var col_node = rear_wheel.get_node_or_null("CollisionShape2D")
		if not col_node:
			col_node = rear_wheel.get_node_or_null("WheelCollision")
		if col_node and col_node.shape is CircleShape2D:
			col_node.shape.radius = w_radius
		var tire = rear_wheel.get_node_or_null("TireSprite") as Sprite2D
		if tire and tire.texture:
			tire.scale = Vector2.ONE * (w_radius / (tire.texture.get_width() * 0.5))
			
	if front_wheel:
		front_wheel.position = fw_off
		var f_col_node = front_wheel.get_node_or_null("CollisionShape2D")
		if not f_col_node:
			f_col_node = front_wheel.get_node_or_null("WheelCollision")
		if f_col_node and f_col_node.shape is CircleShape2D:
			f_col_node.shape.radius = w_radius
		var tire = front_wheel.get_node_or_null("TireSprite") as Sprite2D
		if tire and tire.texture:
			tire.scale = Vector2.ONE * (w_radius / (tire.texture.get_width() * 0.5))
			
	if rear_strut_mount:
		rear_strut_mount.position = Vector2(rw_off.x, rear_strut_mount.position.y)
	if front_strut_mount:
		front_strut_mount.position = Vector2(fw_off.x, front_strut_mount.position.y)

	if rear_joint:
		rear_joint.position = rw_off
		rear_joint.node_a = NodePath("..")
		if rear_wheel:
			rear_joint.node_b = NodePath("../" + rear_wheel.name)
	if front_joint:
		front_joint.position = fw_off
		front_joint.node_a = NodePath("..")
		if front_wheel:
			front_joint.node_b = NodePath("../" + front_wheel.name)
		
	# Completely remove any character/driver so no unwanted character appears during gameplay
	var driver_sprite: Sprite2D = get_node_or_null("DriverSprite")
	if driver_sprite:
		driver_sprite.visible = false
		driver_sprite.queue_free()

	if is_bike:
		if rear_wheel:
			rear_wheel.z_index = -1
		if front_wheel:
			front_wheel.z_index = -1
		if body_sprite:
			body_sprite.z_index = 0
	else:
		if rear_wheel:
			rear_wheel.z_index = -1
		if front_wheel:
			front_wheel.z_index = -1
		if body_sprite:
			body_sprite.z_index = 1
			
	# Remove any artificial spring wobble/bounce pictures
	var rear_shock: Sprite2D = get_node_or_null("RearShock")
	if is_instance_valid(rear_shock):
		rear_shock.visible = false
	var front_shock: Sprite2D = get_node_or_null("FrontShock")
	if is_instance_valid(front_shock):
		front_shock.visible = false
			
	_update_struts()
	_recalculate_upgrades()

func _ready() -> void:
	if rear_wheel_mount:
		_initial_rear_wheel_offset = rear_wheel_mount.position
		if rear_joint:
			rear_joint.position = rear_wheel_mount.position
	elif rear_wheel:
		_initial_rear_wheel_offset = rear_wheel.position

	if front_wheel_mount:
		_initial_front_wheel_offset = front_wheel_mount.position
		if front_joint:
			front_joint.position = front_wheel_mount.position
	elif front_wheel:
		_initial_front_wheel_offset = front_wheel.position

	_apply_vehicle_config()

	current_fuel = max_fuel
	current_nitro = max_nitro
	_recalculate_upgrades()
	nitro_changed.emit(current_nitro, max_nitro)
	
	if crash_detector and not crash_detector.body_entered.is_connected(_on_crash_detector_body_entered):
		crash_detector.body_entered.connect(_on_crash_detector_body_entered)
	
	if is_inside_tree() and engine_audio and not engine_audio.playing:
		engine_audio.play()
	
	add_to_group("vehicle")
	if rear_wheel:
		if not rear_wheel.is_in_group("vehicle"):
			rear_wheel.add_to_group("vehicle")
		rear_wheel.contact_monitor = true
		rear_wheel.max_contacts_reported = maxi(rear_wheel.max_contacts_reported, 4)
	if front_wheel:
		if not front_wheel.is_in_group("vehicle"):
			front_wheel.add_to_group("vehicle")
		front_wheel.contact_monitor = true
		front_wheel.max_contacts_reported = maxi(front_wheel.max_contacts_reported, 4)
	
	_ensure_nitro_visuals()
	if boost_particles:
		boost_particles.modulate.a = 0.0
		boost_particles.color = Color(1.0, 1.0, 1.0, 0.0)
	if rear_strut:
		rear_strut.visible = false
		rear_strut.points = PackedVector2Array()
	if front_strut:
		front_strut.visible = false
		front_strut.points = PackedVector2Array()
	
	var body_sprite: Sprite2D = get_node_or_null("BodySprite")
	if body_sprite:
		_orig_body_texture = body_sprite.texture
		if _orig_body_texture and not _orig_body_texture.resource_path.is_empty():
			var b_path: String = _orig_body_texture.resource_path.get_base_dir() + "/body_burnt.png"
			if ResourceLoader.exists(b_path):
				_burnt_body_texture = load(b_path)
				
	var rear_tire: Sprite2D = rear_wheel.get_node_or_null("TireSprite") if rear_wheel else null
	if rear_tire:
		_orig_rear_wheel_texture = rear_tire.texture
		if _orig_rear_wheel_texture and not _orig_rear_wheel_texture.resource_path.is_empty():
			var w_path: String = _orig_rear_wheel_texture.resource_path.get_base_dir() + "/wheel_burnt.png"
			if ResourceLoader.exists(w_path):
				_burnt_wheel_texture = load(w_path)
				
	var front_tire: Sprite2D = front_wheel.get_node_or_null("TireSprite") if front_wheel else null
	if front_tire:
		_orig_front_wheel_texture = front_tire.texture
		
	var body_node = get_node_or_null("BodySprite") as Sprite2D
	if body_node:
		_orig_body_pos = body_node.position

func _process(_delta: float) -> void:
	_update_struts()
	if debug_draw_alignment or debug_alignment_enabled:
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
		debug_alignment_enabled = not debug_alignment_enabled
		print("[DEBUG] Vehicle alignment overlay toggled: %s" % ("ON" if debug_alignment_enabled else "OFF"))
		queue_redraw()

func _get_engine_local_pos() -> Vector2:
	var b_pos := _orig_body_pos
	var b_scale: float = body_scale if body_scale > 0.0001 else 1.0
	return b_pos + (engine_offset * b_scale)

func _draw() -> void:
	if not (debug_draw_alignment or debug_alignment_enabled):
		return
	
	var rear_arch_local := _initial_rear_wheel_offset
	var front_arch_local := _initial_front_wheel_offset
	var wheel_rad := 33.4
	if rear_wheel and rear_wheel.has_node("CollisionShape2D"):
		var shape = rear_wheel.get_node("CollisionShape2D").shape
		if shape is CircleShape2D:
			wheel_rad = shape.radius
	
	# 1. Arch centres (red dots)
	draw_circle(rear_arch_local, 5.0, Color(1.0, 0.0, 0.0, 0.95))
	draw_circle(front_arch_local, 5.0, Color(1.0, 0.0, 0.0, 0.95))
	
	# 2. Wheel circles (green circles) around current wheel positions
	if is_instance_valid(rear_wheel):
		var cur_rear_local := to_local(rear_wheel.global_position)
		draw_arc(cur_rear_local, wheel_rad, 0, TAU, 36, Color(0.0, 1.0, 0.0, 0.95), 2.5)
		draw_circle(cur_rear_local, 2.5, Color(0.0, 1.0, 0.0, 0.95))
		
	if is_instance_valid(front_wheel):
		var cur_front_local := to_local(front_wheel.global_position)
		draw_arc(cur_front_local, wheel_rad, 0, TAU, 36, Color(0.0, 1.0, 0.0, 0.95), 2.5)
		draw_circle(cur_front_local, 2.5, Color(0.0, 1.0, 0.0, 0.95))
		
	# 3. Engine point (orange dot)
	var eng_local: Vector2 = _get_engine_local_pos()
	draw_circle(eng_local, 5.0, Color(1.0, 0.55, 0.0, 0.95))

func _physics_process(delta: float) -> void:
	_check_ground_contact()
	_apply_suspension(delta)
	_constrain_wheel_alignment()
	_enforce_wheel_attachment()
	if not is_active:
		_stop_effects()
		return
	
	_track_stunts(delta)
	_update_nitro(delta)
	_check_pothole_assist(delta)
	_handle_input(delta)
	_sync_wheel_rotations(delta, Input.get_axis("brake_reverse", "accelerate"))
	_update_struts()
	_update_audio(delta)
	_update_particles()
	
	# Bigfoot Monster Surge handling
	if is_bigfoot_truck():
		if is_nitro_active:
			_ensure_monster_surge_particles()
			var on_slope: bool = is_grounded and absf(rotation) > 0.08
			if on_slope:
				# Crusher grip: +20% traction on slopes while boosting
				_apply_wheel_friction((_current_base_friction + nitro_traction_boost) * 1.20)
			else:
				_apply_wheel_friction(_current_base_friction + nitro_traction_boost)
			
			if _monster_dirt_particles:
				_monster_dirt_particles.emitting = false
			if _monster_rock_particles:
				_monster_rock_particles.emitting = false
		else:
			if _monster_dirt_particles and _monster_dirt_particles.emitting:
				_monster_dirt_particles.emitting = false
			if _monster_rock_particles and _monster_rock_particles.emitting:
				_monster_rock_particles.emitting = false
	
		# Aerodynamic air drag & rolling resistance
	var forward_vel: float = linear_velocity.dot(transform.x)
	var grav_setting: float = ProjectSettings.get_setting("physics/2d/default_gravity", 666.4)
	
	# Rolling resistance: opposing force when wheels are touching ground
	if is_grounded and absf(forward_vel) > 1.0:
		var f_roll_mag: float = rolling_resistance_coeff * vehicle_mass * grav_setting
		apply_central_force(-transform.x * signf(forward_vel) * f_roll_mag)
		
	# Aerodynamic air drag: 0.5 * Cd * v^2
	if absf(forward_vel) > 5.0:
		var f_drag_mag: float = 0.5 * air_drag_coeff * pow(forward_vel, 2)
		apply_central_force(-transform.x * signf(forward_vel) * f_drag_mag)
	
	was_grounded = is_grounded
	_previous_linear_velocity = linear_velocity

func set_nitro_active(active: bool) -> void:
	is_nitro_requested = active

func _update_nitro(delta: float) -> void:
	var action_pressed: bool = is_nitro_requested or Input.is_action_pressed("nitro")
	if not action_pressed and (Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_SPACE)):
		action_pressed = true
	
	var can_boost: bool = is_active and action_pressed and (is_nitro_active or current_nitro >= nitro_min_activation_energy) and current_nitro > 0.0
	
	if can_boost:
		if not is_nitro_active:
			_activate_nitro()
		current_nitro = maxf(0.0, current_nitro - nitro_consumption_rate * delta)
		nitro_changed.emit(current_nitro, max_nitro)
		
		if current_nitro <= 0.0:
			_deactivate_nitro()
	else:
		if is_nitro_active:
			_deactivate_nitro()
		if current_nitro < max_nitro:
			current_nitro = minf(max_nitro, current_nitro + nitro_recharge_rate * delta)
			nitro_changed.emit(current_nitro, max_nitro)

func _ensure_nitro_visuals() -> void:
	if is_instance_valid(nitro_flame):
		return
	
	var exhaust_pos := Vector2(-54, 4)
	if boost_particles:
		exhaust_pos = boost_particles.position
	elif rear_wheel_mount:
		exhaust_pos = rear_wheel_mount.position + Vector2(-20, -10)
	
	# 1. Main Nitro Flame container
	var flame_root := Node2D.new()
	flame_root.name = "NitroFlame"
	flame_root.position = exhaust_pos
	flame_root.visible = false
	flame_root.modulate.a = 0.0
	add_child(flame_root)
	nitro_flame = flame_root
	
	var flame_spr := Sprite2D.new()
	flame_spr.name = "FlameSprite"
	flame_spr.offset = Vector2(-150, 0)
	flame_spr.visible = false
	flame_spr.modulate.a = 0.0
	flame_root.add_child(flame_spr)
	
	# Dynamic flickering orange and blue flame from exhaust (NitroFlame.gd)
	var dyn_flame: Node2D = NitroFlameScript.new()
	dyn_flame.name = "DynamicNitroFlame"
	dyn_flame.flame_scale_mult = body_scale / 0.18 if body_scale > 0.01 else 1.0
	dyn_flame.visible = false
	flame_root.add_child(dyn_flame)
	
	# 2. Nitro Flame Burst (activation flare node)
	var burst_spr := Sprite2D.new()
	burst_spr.name = "NitroBurst"
	burst_spr.position = exhaust_pos
	burst_spr.scale = Vector2(0.38, 0.38)
	burst_spr.offset = Vector2(-140, 0)
	burst_spr.visible = false
	burst_spr.modulate.a = 0.0
	add_child(burst_spr)
	nitro_burst = burst_spr
	
	# 3. Nitro Spark Particles (zero-emission clean default)
	var sparks := CPUParticles2D.new()
	sparks.name = "NitroSparks"
	sparks.position = exhaust_pos
	sparks.emitting = false
	sparks.amount = 1
	sparks.lifetime = 0.4
	sparks.direction = Vector2(-1, 0)
	sparks.color = Color(0.2, 0.85, 1.0, 0.0)
	add_child(sparks)
	nitro_sparks = sparks

func _ensure_monster_surge_particles() -> void:
	if not is_bigfoot_truck() or is_instance_valid(_monster_dirt_particles):
		return
	
	# 1. Dirt Particles (chunky dark earth thrown by huge tires)
	_monster_dirt_particles = CPUParticles2D.new()
	_monster_dirt_particles.name = "MonsterSurgeDirt"
	_monster_dirt_particles.z_index = -1
	_monster_dirt_particles.emitting = false
	_monster_dirt_particles.amount = 18
	_monster_dirt_particles.lifetime = 0.55
	_monster_dirt_particles.direction = Vector2(-1.0, -0.45)
	_monster_dirt_particles.spread = 30.0
	_monster_dirt_particles.gravity = Vector2(0, 380)
	_monster_dirt_particles.initial_velocity_min = 160.0
	_monster_dirt_particles.initial_velocity_max = 320.0
	_monster_dirt_particles.scale_amount_min = 3.0
	_monster_dirt_particles.scale_amount_max = 6.0
	_monster_dirt_particles.color = Color(0.38, 0.24, 0.14, 0.85) # Earth dirt
	
	var r_mount: Vector2 = _initial_rear_wheel_offset + Vector2(-15, 20)
	_monster_dirt_particles.position = r_mount
	add_child(_monster_dirt_particles)
	
	# 2. Small Rock Particles (pebbles / stones thrown by treads)
	_monster_rock_particles = CPUParticles2D.new()
	_monster_rock_particles.name = "MonsterSurgeRocks"
	_monster_rock_particles.z_index = -1
	_monster_rock_particles.emitting = false
	_monster_rock_particles.amount = 10
	_monster_rock_particles.lifetime = 0.65
	_monster_rock_particles.direction = Vector2(-1.0, -0.6)
	_monster_rock_particles.spread = 45.0
	_monster_rock_particles.gravity = Vector2(0, 480)
	_monster_rock_particles.initial_velocity_min = 180.0
	_monster_rock_particles.initial_velocity_max = 350.0
	_monster_rock_particles.scale_amount_min = 2.0
	_monster_rock_particles.scale_amount_max = 4.5
	_monster_rock_particles.color = Color(0.55, 0.52, 0.48, 0.95) # Small rocks / stones
	_monster_rock_particles.position = r_mount
	add_child(_monster_rock_particles)

func _activate_nitro() -> void:
	is_nitro_active = true
	nitro_state_changed.emit(true)
	var on_slope: bool = is_bigfoot_truck() and is_grounded and absf(rotation) > 0.08
	var friction_bonus: float = nitro_traction_boost * (1.20 if on_slope else 1.0)
	_apply_wheel_friction(_current_base_friction + friction_bonus)
	if boost_particles:
		boost_particles.emitting = true
	if not is_instance_valid(nitro_flame):
		_ensure_nitro_visuals()
	if boost_particles:
		boost_particles.modulate.a = 0.0
		boost_particles.color = Color(1.0, 1.0, 1.0, 0.0)
	if rear_strut:
		rear_strut.visible = false
		rear_strut.points = PackedVector2Array()
	if front_strut:
		front_strut.visible = false
		front_strut.points = PackedVector2Array()
	if nitro_flame:
		nitro_flame.visible = true
		nitro_flame.modulate.a = 1.0
		var dyn_flame = nitro_flame.get_node_or_null("DynamicNitroFlame")
		if is_instance_valid(dyn_flame) and dyn_flame.has_method("set_flame_active"):
			dyn_flame.set_flame_active(true)
	if nitro_sparks:
		nitro_sparks.emitting = true
	if nitro_burst:
		nitro_burst.visible = false
		nitro_burst.modulate.a = 0.0
	if not is_instance_valid(nitro_audio):
		nitro_audio = get_node_or_null("NitroAudio")
	if nitro_audio:
		if is_bigfoot_truck():
			nitro_audio.pitch_scale = 0.65 # Deep monster engine roar
		else:
			nitro_audio.pitch_scale = 1.0
		if is_inside_tree() and not nitro_audio.playing:
			nitro_audio.play()
	if is_bigfoot_truck():
		monster_surge_state_changed.emit(true)

func _deactivate_nitro() -> void:
	if is_nitro_active:
		is_nitro_active = false
		nitro_state_changed.emit(false)
		_apply_wheel_friction(_current_base_friction)
		if boost_particles:
			boost_particles.emitting = false
		if nitro_flame:
			nitro_flame.visible = false
			nitro_flame.modulate.a = 0.0
			var dyn_flame = nitro_flame.get_node_or_null("DynamicNitroFlame")
			if is_instance_valid(dyn_flame) and dyn_flame.has_method("set_flame_active"):
				dyn_flame.set_flame_active(false)
		if nitro_burst:
			nitro_burst.visible = false
		if nitro_sparks:
			nitro_sparks.emitting = false
		if _monster_dirt_particles:
			_monster_dirt_particles.emitting = false
		if _monster_rock_particles:
			_monster_rock_particles.emitting = false
		if not is_instance_valid(nitro_audio):
			nitro_audio = get_node_or_null("NitroAudio")
		if nitro_audio:
			nitro_audio.pitch_scale = 1.0
			if nitro_audio.playing:
				nitro_audio.stop()
		if is_bigfoot_truck():
			monster_surge_state_changed.emit(false)

func _check_pothole_assist(delta: float) -> void:
	var accel_input: float = Input.get_axis("brake_reverse", "accelerate")
	var is_trying_to_move: bool = accel_input > 0.1 or Input.get_action_strength("accelerate") > 0.1
	var is_struggling_speed: bool = absf(linear_velocity.x) < 45.0
	var is_tilted_up: bool = rotation < -0.12 or absf(rotation) > 0.18
	
	if is_grounded and is_trying_to_move and is_struggling_speed and is_tilted_up:
		_pothole_stuck_timer += delta
		if _pothole_stuck_timer >= 0.35 and not _pothole_hint_active:
			_pothole_hint_active = true
			pothole_assist_hint.emit(true)
	else:
		if _pothole_hint_active and (linear_velocity.x > 70.0 or not is_grounded or not is_trying_to_move):
			_pothole_hint_active = false
			pothole_assist_hint.emit(false)
		_pothole_stuck_timer = maxf(0.0, _pothole_stuck_timer - delta * 2.0)

func lock_vehicle() -> void:
	is_active = false
	is_nitro_requested = false
	_deactivate_nitro()
	_stop_effects()
	air_time = 0.0
	air_rotation_accum = 0.0
	wheelie_time = 0.0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	set_deferred("freeze", true)
	if is_instance_valid(rear_wheel):
		rear_wheel.linear_velocity = Vector2.ZERO
		rear_wheel.angular_velocity = 0.0
		rear_wheel.set_deferred("freeze", true)
	if is_instance_valid(front_wheel):
		front_wheel.linear_velocity = Vector2.ZERO
		front_wheel.angular_velocity = 0.0
		front_wheel.set_deferred("freeze", true)

func unlock_vehicle() -> void:
	set_deferred("freeze", false)
	if is_instance_valid(rear_wheel):
		rear_wheel.set_deferred("freeze", false)
	if is_instance_valid(front_wheel):
		front_wheel.set_deferred("freeze", false)
	is_active = true
	if is_inside_tree() and engine_audio and not engine_audio.playing:
		engine_audio.play()

func set_active(active: bool) -> void:
	if active:
		unlock_vehicle()
	else:
		lock_vehicle()

func _check_ground_contact() -> void:
	if is_grounded_override:
		rear_contact = true
		front_contact = true
		is_grounded = true
		return
	var dt: float = get_physics_process_delta_time() if is_inside_tree() else 0.016667
	var r_raw: bool = (rear_wheel.contact_monitor and rear_wheel.get_colliding_bodies().size() > 0) if rear_wheel else false
	var f_raw: bool = (front_wheel.contact_monitor and front_wheel.get_colliding_bodies().size() > 0) if front_wheel else false
	if r_raw:
		_rear_contact_timer = 0.08
	else:
		_rear_contact_timer = maxf(0.0, _rear_contact_timer - dt)
	if f_raw:
		_front_contact_timer = 0.08
	else:
		_front_contact_timer = maxf(0.0, _front_contact_timer - dt)
	rear_contact = _rear_contact_timer > 0.0
	front_contact = _front_contact_timer > 0.0
	is_grounded = rear_contact or front_contact
	
	# Detect hard landing thud
	if not was_grounded and is_grounded:
		var impact_y: float = _previous_linear_velocity.y
		if impact_y > 140.0:
			_play_landing_sound()
			hard_landed.emit(clampf((impact_y - 140.0) / 300.0, 0.2, 1.0))

func _track_stunts(delta: float) -> void:
	if not is_grounded:
		air_time += delta
		var delta_rot: float = wrapf(rotation - _last_air_rotation, -PI, PI)
		air_rotation_accum += delta_rot
		_last_air_rotation = rotation
		
		# Check completed 360 degree flips (TAU radians)
		if air_rotation_accum >= TAU * 0.95:
			air_rotation_accum -= TAU
			trick_performed.emit("Backflip", 20)
		elif air_rotation_accum <= -TAU * 0.95:
			air_rotation_accum += TAU
			trick_performed.emit("Frontflip", 20)
		wheelie_time = 0.0
	else:
		# Vehicle just landed from airborne
		if not was_grounded and is_active:
			if air_time >= 1.2:
				var air_reward: int = int(air_time * 10)
				airtime_landed.emit(air_time, air_reward)
			elif air_time >= 0.75 and absf(rotation) < 0.25:
				# Clean landing bonus when touching down flat after jump
				clean_landed.emit(5)
		
		air_time = 0.0
		air_rotation_accum = 0.0
		_last_air_rotation = rotation
		
		# Wheelie detection: rear wheel grounded, front wheel in the air, driving forward
		if rear_contact and not front_contact and linear_velocity.x > 50.0 and is_active:
			wheelie_time += delta
			if wheelie_time >= 1.0:
				wheelie_time = 0.0
				trick_performed.emit("Wheelie", 10)
		else:
			wheelie_time = 0.0

func _handle_input(delta: float) -> void:
	var accel_input: float = Input.get_axis("brake_reverse", "accelerate")
	var tilt_input: float = Input.get_axis("tilt_left", "tilt_right")
	
	# Smooth nitro blend transition (gradual speed increase and smooth return)
	if is_nitro_active:
		_nitro_blend = move_toward(_nitro_blend, 1.0, delta * 1.8)
	else:
		_nitro_blend = move_toward(_nitro_blend, 0.0, delta * 1.8)
	
	# Determine effective power & speed multipliers (10–15% higher than normal engine speed)
	var b_mult := boost_power_multiplier
	var speed_bonus: float = (nitro_max_speed_multiplier - 1.0) * (1.0 + (b_mult - 1.0) * 0.4)
	var torque_bonus: float = (nitro_torque_multiplier - 1.0) * (1.0 + (b_mult - 1.0) * 0.4)
	var speed_mult: float = 1.0 + speed_bonus * _nitro_blend
	var torque_mult: float = 1.0 + torque_bonus * _nitro_blend
	
	if _nitro_blend > 0.05:
		# Anti-flip pitch stabilization during nitro boost: prevents pitch flips onto driver head / CrashDetector
		if is_grounded and rotation < -0.25 and angular_velocity < 0.0:
			apply_torque(vehicle_mass * 2400.0)
		elif not is_grounded and rotation < -0.40 and angular_velocity < 0.0:
			apply_torque(vehicle_mass * 1800.0)
	
	# Low fuel sputtering physical warning when tank < 15%
	var sputter_mult: float = 1.0
	if consumes_fuel and current_fuel < 15.0 and current_fuel > 0.0:
		sputter_mult = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.015)
	
	var active_motor_torque: float = motor_torque * torque_mult
	var active_max_speed: float = max_wheel_speed * speed_mult
	
	# Dynamic pitch weight transfer (acceleration moves weight rearward, braking moves weight forward)
	if accel_input > 0.05 and is_grounded:
		_dynamic_pitch_weight_transfer = lerpf(_dynamic_pitch_weight_transfer, vehicle_mass * 666.4 * 0.15 * accel_input, 8.0 * delta)
	elif accel_input < -0.05 and is_grounded:
		_dynamic_pitch_weight_transfer = lerpf(_dynamic_pitch_weight_transfer, -vehicle_mass * 666.4 * 0.20 * absf(accel_input), 8.0 * delta)
	else:
		_dynamic_pitch_weight_transfer = lerpf(_dynamic_pitch_weight_transfer, 0.0, 10.0 * delta)
	
	# Torque distribution based on drive_type (RWD vs AWD vs FWD)
	var rear_torque_share: float = 1.0
	var front_torque_share: float = 0.0
	if drive_type == "AWD" or drive_type == "4WD":
		rear_torque_share = 0.55
		front_torque_share = 0.45
	elif drive_type == "FWD":
		rear_torque_share = 0.0
		front_torque_share = 1.0
	else: # "RWD" (Cars, Bikes)
		rear_torque_share = 1.0
		front_torque_share = 0.0
	
	# Engine torque curve: strong at low speed, weaker at high speed, zero at top speed
	var rear_w: float = absf(rear_wheel.angular_velocity) if rear_wheel else 0.0
	var front_w: float = absf(front_wheel.angular_velocity) if front_wheel else 0.0
	
	var rear_speed_ratio: float = clampf(rear_w / active_max_speed, 0.0, 1.0)
	var front_speed_ratio: float = clampf(front_w / active_max_speed, 0.0, 1.0)
	
	var rear_torque_factor: float = maxf(1.0 - pow(rear_speed_ratio, 1.3), 0.0)
	var front_torque_factor: float = maxf(1.0 - pow(front_speed_ratio, 1.3), 0.0)
	
	var effective_throttle: float = accel_input
	if _nitro_blend > 0.05 and effective_throttle < 1.0 and effective_throttle >= -0.05:
		effective_throttle = maxf(effective_throttle, 1.0 * _nitro_blend)
	
	# Smooth return to normal engine speed when nitro is released or runs out
	if not is_nitro_active and _nitro_blend < 0.90:
		var driven_w: float = front_w if front_torque_share > 0.0 else rear_w
		var normal_ratio: float = driven_w / max_wheel_speed
		if normal_ratio > 0.80:
			var excess: float = normal_ratio - 0.80
			var return_force: float = vehicle_mass * clampf(excess * 350.0, 0.0, 180.0) * (1.0 - _nitro_blend)
			apply_central_force(-transform.x * return_force)
	
	if effective_throttle > 0.05:
		if consumes_fuel and current_fuel <= 0.0:
			pass
		else:
			var effective_accel: float = effective_throttle * sputter_mult
			if rear_wheel and rear_torque_share > 0.0:
				var t_rear: float = active_motor_torque * rear_torque_share * effective_accel * rear_torque_factor
				rear_wheel.apply_torque(t_rear)
			if front_wheel and front_torque_share > 0.0:
				var t_front: float = active_motor_torque * front_torque_share * effective_accel * front_torque_factor
				front_wheel.apply_torque(t_front)
			if is_bike and rear_contact:
				apply_torque(-active_motor_torque * 0.08 * effective_accel)
			if is_grounded:
				var w_rad: float = maxf(wheel_radius, 1.0)
				var slope_boost: float = 1.0 + (absf(rotation) * 0.8)
				var traction_factor: float = 0.45 * (1.0 + (grip_level - 1) * 0.15) * slope_boost
				var nitro_traction_mult: float = 1.0 + 0.24 * _nitro_blend
				var eff_t_factor: float = maxf(rear_torque_factor, front_torque_factor)
				var fwd_traction: float = (motor_torque / w_rad) * effective_accel * traction_factor * nitro_traction_mult * eff_t_factor
				apply_central_force(transform.x * fwd_traction)
				
	elif absf(accel_input) <= 0.05 and _nitro_blend < 0.05 and is_grounded:
		# Standstill drivetrain hold / static parking friction: brings vehicle to a complete dead stop
		if linear_velocity.length() < 1.0 and absf(rotation) < 0.15:
			linear_velocity = Vector2.ZERO
			if rear_wheel:
				rear_wheel.angular_velocity = 0.0
			if front_wheel:
				front_wheel.angular_velocity = 0.0
		# Gentle engine braking when rolling: slows vehicle when throttle is released
		elif linear_velocity.length() > 5.0 and not Input.is_action_pressed("accelerate"):
			if rear_wheel and absf(rear_wheel.angular_velocity) > 1.0 and rear_torque_share > 0.0:
				var eb_rear: float = -signf(rear_wheel.angular_velocity) * active_motor_torque * 0.02 * rear_torque_share
				rear_wheel.apply_torque(eb_rear)
			if front_wheel and absf(front_wheel.angular_velocity) > 1.0 and front_torque_share > 0.0:
				var eb_front: float = -signf(front_wheel.angular_velocity) * active_motor_torque * 0.02 * front_torque_share
				front_wheel.apply_torque(eb_front)
			
	elif accel_input < -0.05:
		var fwd_speed: float = linear_velocity.dot(transform.x)
		var is_braking_forward: bool = fwd_speed > 15.0 or (rear_wheel and rear_wheel.angular_velocity > 2.0)
		
		if is_braking_forward:
			# Braking: apply brake torque against rotation
			if rear_wheel and rear_wheel.angular_velocity > 0.1:
				var b_rear: float = -brake_torque * absf(accel_input) * 0.60
				rear_wheel.apply_torque(b_rear)
				# Check for wheel lockup
				if rear_wheel.angular_velocity < 2.0 and fwd_speed > 35.0:
					if skid_audio and not skid_audio.playing:
						skid_audio.play()
					if rear_dust:
						rear_dust.emitting = true
			if front_wheel and front_wheel.angular_velocity > 0.1:
				var b_front: float = -brake_torque * absf(accel_input) * 0.40
				front_wheel.apply_torque(b_front)
			if is_bike and is_grounded:
				apply_torque(brake_torque * 0.08 * absf(accel_input))
			if is_grounded:
				var w_rad: float = maxf(wheel_radius, 1.0)
				var brake_force: float = (brake_torque / w_rad) * absf(accel_input) * 0.35
				apply_central_force(-transform.x * brake_force)
		else:
			# Reverse gear
			if rear_wheel and rear_wheel.angular_velocity > -active_max_speed * 0.5:
				var rev_factor: float = clampf((active_max_speed * 0.5 + rear_wheel.angular_velocity) / (active_max_speed * 0.2), 0.0, 1.0)
				rear_wheel.apply_torque(brake_torque * accel_input * rev_factor)
			if front_wheel and front_torque_share > 0.0 and front_wheel.angular_velocity > -active_max_speed * 0.5:
				var rev_front_factor: float = clampf((active_max_speed * 0.5 + front_wheel.angular_velocity) / (active_max_speed * 0.2), 0.0, 1.0)
				front_wheel.apply_torque(brake_torque * front_torque_share * accel_input * rev_front_factor)
			if is_grounded:
				var w_rad: float = maxf(wheel_radius, 1.0)
				var rev_traction: float = (brake_torque / w_rad) * accel_input * 0.22
				apply_central_force(transform.x * rev_traction)
	
	# Wheelspin detection & visual feedback
	if is_grounded and accel_input > 0.2:
		var wheel_surf_speed: float = (rear_wheel.angular_velocity * wheel_radius) if rear_wheel else 0.0
		var ground_fwd_speed: float = linear_velocity.dot(transform.x)
		var slip_speed: float = wheel_surf_speed - ground_fwd_speed
		if slip_speed > 60.0:
			if rear_dust:
				rear_dust.emitting = true
			if skid_audio and not skid_audio.playing:
				skid_audio.play()
	
	# Air rotation and flip control
	if not is_grounded:
		if absf(tilt_input) > 0.1:
			var can_spin: bool = (tilt_input > 0.0 and angular_velocity < max_air_angular_velocity) or (tilt_input < 0.0 and angular_velocity > -max_air_angular_velocity)
			if can_spin:
				apply_torque(air_tilt_torque * tilt_input)
			else:
				angular_velocity = lerpf(angular_velocity, signf(tilt_input) * max_air_angular_velocity, 5.0 * delta)
		else:
			# Auto-stabilize when airborne and tilt input is neutral
			angular_velocity = lerpf(angular_velocity, 0.0, airborne_angular_damping * delta)
	elif absf(tilt_input) > 0.1:
		# Minor ground pitch assist
		apply_torque(air_tilt_torque * 0.3 * tilt_input)

## Synchronizes wheel rotations so all wheels rotate naturally matching movement,
## unpowered front wheels roll on ground contact, and excessive stationary burnout is clamped.
func _sync_wheel_rotations(delta: float, accel_input: float) -> void:
	var fwd_speed: float = linear_velocity.dot(transform.x)
	var w_rad: float = maxf(wheel_radius, 1.0)
	var roll_w: float = fwd_speed / w_rad
	
	# Torque distribution
	var rear_torque_share: float = 1.0
	var front_torque_share: float = 0.0
	if drive_type == "AWD" or drive_type == "4WD":
		rear_torque_share = 0.55
		front_torque_share = 0.45
	elif drive_type == "FWD":
		rear_torque_share = 0.0
		front_torque_share = 1.0
	else: # "RWD"
		rear_torque_share = 1.0
		front_torque_share = 0.0
		
	# 1. Non-powered front wheel (all RWD cars and bikes)
	if front_wheel and front_torque_share <= 0.0:
		var fw_fwd: float = front_wheel.linear_velocity.dot(transform.x)
		var fw_roll: float = fw_fwd / w_rad
		if front_contact or is_grounded:
			front_wheel.angular_velocity = lerpf(front_wheel.angular_velocity, fw_roll, clampf(35.0 * delta, 0.0, 1.0))
		else:
			# Airborne: spin down gently from air / bearing resistance
			front_wheel.angular_velocity = lerpf(front_wheel.angular_velocity, 0.0, 2.5 * delta)
			
	# 2. Non-powered rear wheel (FWD)
	if rear_wheel and rear_torque_share <= 0.0:
		var rw_fwd: float = rear_wheel.linear_velocity.dot(transform.x)
		var rw_roll: float = rw_fwd / w_rad
		if rear_contact or is_grounded:
			rear_wheel.angular_velocity = lerpf(rear_wheel.angular_velocity, rw_roll, clampf(35.0 * delta, 0.0, 1.0))
		else:
			rear_wheel.angular_velocity = lerpf(rear_wheel.angular_velocity, 0.0, 2.5 * delta)
			
	# 3. Driven wheels: ensure wheels rotate with vehicle movement, and clamp burnout
	var max_slip_w: float = 30.0 * (1.0 + 0.13 * _nitro_blend)
	var slip_window: float = 22.0 * (1.0 + 0.13 * _nitro_blend)
	if is_grounded:
		var allowed_w_max: float = maxf(max_slip_w, roll_w + slip_window)
		var allowed_w_min: float = minf(-max_slip_w, roll_w - slip_window)
		var is_accelerating: bool = (accel_input > 0.05 or _nitro_blend > 0.05)
		var is_reversing: bool = accel_input < -0.05
		
		if rear_wheel and rear_torque_share > 0.0:
			if not is_accelerating and not is_reversing:
				rear_wheel.angular_velocity = lerpf(rear_wheel.angular_velocity, roll_w, clampf(30.0 * delta, 0.0, 1.0))
			else:
				if rear_wheel.angular_velocity > allowed_w_max:
					rear_wheel.angular_velocity = lerpf(rear_wheel.angular_velocity, allowed_w_max, 15.0 * delta)
				elif rear_wheel.angular_velocity < allowed_w_min:
					rear_wheel.angular_velocity = lerpf(rear_wheel.angular_velocity, allowed_w_min, 15.0 * delta)
				
		if front_wheel and front_torque_share > 0.0:
			if not is_accelerating and not is_reversing:
				front_wheel.angular_velocity = lerpf(front_wheel.angular_velocity, roll_w, clampf(30.0 * delta, 0.0, 1.0))
			else:
				if front_wheel.angular_velocity > allowed_w_max:
					front_wheel.angular_velocity = lerpf(front_wheel.angular_velocity, allowed_w_max, 15.0 * delta)
				elif front_wheel.angular_velocity < allowed_w_min:
					front_wheel.angular_velocity = lerpf(front_wheel.angular_velocity, allowed_w_min, 15.0 * delta)
				
	# 4. Coasting / Standstill: wheels roll with movement and stop completely at rest
	if absf(accel_input) <= 0.05 and _nitro_blend < 0.05:
		if is_grounded:
			var cur_speed: float = linear_velocity.length()
			if cur_speed < 1.0 and absf(rotation) < 0.15:
				linear_velocity = Vector2.ZERO
				if rear_wheel:
					rear_wheel.angular_velocity = 0.0
				if front_wheel:
					front_wheel.angular_velocity = 0.0
			elif rear_wheel or front_wheel:
				if rear_wheel and rear_torque_share > 0.0:
					rear_wheel.angular_velocity = lerpf(rear_wheel.angular_velocity, roll_w, clampf(25.0 * delta, 0.0, 1.0))
				if front_wheel and front_torque_share > 0.0:
					front_wheel.angular_velocity = lerpf(front_wheel.angular_velocity, roll_w, clampf(25.0 * delta, 0.0, 1.0))

func _apply_suspension(_delta: float) -> void:
	if is_instance_valid(rear_wheel):
		_apply_wheel_suspension(rear_wheel, _initial_rear_wheel_offset, false)
	if is_instance_valid(front_wheel):
		_apply_wheel_suspension(front_wheel, _initial_front_wheel_offset, true)

func _apply_wheel_suspension(wheel: RigidBody2D, mount_local_pos: Vector2, is_front: bool) -> void:
	var delta: float = get_physics_process_delta_time() if is_inside_tree() else 0.016667
	var target_mount_world: Vector2 = to_global(mount_local_pos)
	var disp_world: Vector2 = wheel.global_position - target_mount_world
	
	# Project displacement onto vehicle local axes (X = forward, Y = down)
	var disp_x: float = disp_world.dot(transform.x)
	var disp_y: float = disp_world.dot(transform.y)
	
	# Relative velocity of wheel compared to the chassis mount point
	var mount_arm: Vector2 = target_mount_world - global_position
	var chassis_vel_at_mount: Vector2 = linear_velocity + Vector2(-mount_arm.y, mount_arm.x) * angular_velocity
	var rel_vel_world: Vector2 = wheel.linear_velocity - chassis_vel_at_mount
	var rel_vel_x: float = rel_vel_world.dot(transform.x)
	var rel_vel_y: float = rel_vel_world.dot(transform.y)
	
	# 1. Strictly lock lateral wheel alignment along X (no forward/backward separation or drifting)
	if absf(disp_x) > 0.001:
		wheel.global_position -= transform.x * disp_x
		disp_x = 0.0
	if absf(rel_vel_x) > 0.001:
		wheel.linear_velocity -= transform.x * rel_vel_x
		rel_vel_x = 0.0
	
	# 2. Wheel travel limits: tight, stable suspension travel without visual detachment or floating
	var w_rad: float = wheel_radius if wheel_radius > 0.0 else 22.0 * body_scale
	var max_travel_px: float = clampf(max_travel_fraction * w_rad, 2.0, 7.0 * body_scale)
	var bump_stop_px: float = clampf(bump_stop_fraction * w_rad, 2.0, 6.0 * body_scale)
	var sag_px: float = rest_sag_fraction * max_travel_px
	var max_droop_px: float = minf(max_travel_px + sag_px, 8.0 * body_scale)
	
	# Bump stop hard limit: wheel cannot move more than bumpStop into arch
	if -disp_y > bump_stop_px:
		wheel.global_position -= transform.y * (disp_y + bump_stop_px)
		disp_y = -bump_stop_px
		if rel_vel_y < 0.0:
			wheel.linear_velocity -= transform.y * rel_vel_y
			rel_vel_y = 0.0
		var chassis_vy_down: float = linear_velocity.dot(transform.y)
		if chassis_vy_down > 0.0:
			linear_velocity -= transform.y * (chassis_vy_down * 0.5)
	
	# Droop limit: wheel cannot fall below arch
	if disp_y > max_droop_px:
		wheel.global_position -= transform.y * (disp_y - max_droop_px)
		disp_y = max_droop_px
		if rel_vel_y > 0.0:
			wheel.linear_velocity -= transform.y * rel_vel_y
			rel_vel_y = 0.0
	
	var is_wheel_grounded: bool = front_contact if is_front else rear_contact
	if not is_wheel_grounded and not is_grounded:
		# Airborne: wheel immediately settles smoothly to resting offset, no floating or bouncing
		disp_y = lerpf(disp_y, 0.0, clampf(30.0 * delta, 0.0, 1.0))
		wheel.global_position = target_mount_world + transform.y * disp_y
		wheel.linear_velocity = chassis_vel_at_mount
		return
	
	# 3. Active Hooke's spring-damper with high damping to prevent bouncing
	var k_val: float = _front_stiffness if is_front else _rear_stiffness
	var c_val: float = _front_damping if is_front else _rear_damping
	
	# Ensure sufficient damping so suspension absorbs shocks cleanly without repeated oscillations
	c_val = maxf(c_val, 2.0 * 0.95 * sqrt(k_val * (vehicle_mass * 0.5)))
	
	var f_spring_y: float = -k_val * disp_y
	var f_damping_y: float = -c_val * rel_vel_y
	var total_susp_force: float = f_spring_y + f_damping_y
	var chassis_susp_force: Vector2 = -transform.y * total_susp_force
	apply_force(chassis_susp_force, mount_arm)
	wheel.apply_central_force(-chassis_susp_force)

func _constrain_wheel_alignment() -> void:
	_enforce_wheel_attachment()

## Enforces strict physical suspension bounds to prevent wheels from separating under extreme torque or impact
func _enforce_wheel_attachment() -> void:
	var w_rad: float = wheel_radius if wheel_radius > 0.0 else 22.0 * body_scale
	var max_travel: float = clampf(max_travel_fraction * w_rad, 3.0, 8.0 * body_scale)
	var max_droop: float = clampf(max_travel * 1.25, 4.0, 10.0 * body_scale)
	
	if is_instance_valid(rear_wheel):
		var target_rear: Vector2 = to_global(_initial_rear_wheel_offset)
		var rear_disp: Vector2 = rear_wheel.global_position - target_rear
		var r_disp_x: float = rear_disp.dot(transform.x)
		var r_disp_y: float = rear_disp.dot(transform.y)
		
		# Lock X strictly
		if absf(r_disp_x) > 0.001:
			rear_wheel.global_position -= transform.x * r_disp_x
			var r_rel_vx: float = (rear_wheel.linear_velocity - linear_velocity).dot(transform.x)
			rear_wheel.linear_velocity -= transform.x * r_rel_vx
		
		# Clamp Y within suspension bounds
		if r_disp_y < -max_travel:
			rear_wheel.global_position -= transform.y * (r_disp_y + max_travel)
		elif r_disp_y > max_droop:
			rear_wheel.global_position -= transform.y * (r_disp_y - max_droop)

	if is_instance_valid(front_wheel):
		var target_front: Vector2 = to_global(_initial_front_wheel_offset)
		var front_disp: Vector2 = front_wheel.global_position - target_front
		var f_disp_x: float = front_disp.dot(transform.x)
		var f_disp_y: float = front_disp.dot(transform.y)
		
		if absf(f_disp_x) > 0.001:
			front_wheel.global_position -= transform.x * f_disp_x
			var f_rel_vx: float = (front_wheel.linear_velocity - linear_velocity).dot(transform.x)
			front_wheel.linear_velocity -= transform.x * f_rel_vx
			
		if f_disp_y < -max_travel:
			front_wheel.global_position -= transform.y * (f_disp_y + max_travel)
		elif f_disp_y > max_droop:
			front_wheel.global_position -= transform.y * (f_disp_y - max_droop)

func _update_struts() -> void:
	# Silver connectors / struts removed: keep wheels and suspension clean
	if rear_strut:
		rear_strut.visible = false
		rear_strut.points = PackedVector2Array()
	if front_strut:
		front_strut.visible = false
		front_strut.points = PackedVector2Array()
	var rear_shock: Sprite2D = get_node_or_null("RearShock")
	if is_instance_valid(rear_shock):
		rear_shock.visible = false
	var front_shock: Sprite2D = get_node_or_null("FrontShock")
	if is_instance_valid(front_shock):
		front_shock.visible = false

func _update_particles() -> void:
	var accel_input: float = Input.get_axis("brake_reverse", "accelerate")
	var is_accelerating: bool = accel_input > 0.05 and (not consumes_fuel or current_fuel > 0.0)
	
	if exhaust_particles:
		exhaust_particles.emitting = is_accelerating
	
	if rear_dust:
		var wheel_spinning: bool = rear_wheel and absf(rear_wheel.angular_velocity) > 10.0
		rear_dust.emitting = is_grounded and (wheel_spinning or linear_velocity.length() > 30.0)

## Modulate engine pitch (RPM) dynamically based on wheel angular velocity and throttle
func _update_audio(delta: float) -> void:
	if engine_audio:
		if is_inside_tree() and not engine_audio.playing and is_active:
			engine_audio.play()
		
		var rear_ratio: float = absf(rear_wheel.angular_velocity) / max_wheel_speed if rear_wheel else 0.0
		var front_ratio: float = absf(front_wheel.angular_velocity) / max_wheel_speed if front_wheel else 0.0
		var wheel_speed_ratio: float = clampf(maxf(rear_ratio, front_ratio), 0.0, 1.0)
		var throttle_ratio: float = clampf(Input.get_action_strength("accelerate"), 0.0, 1.0)
		
		# Blend physical wheel speed with throttle response for authentic revving
		var speed_ratio: float = clampf((wheel_speed_ratio * 0.65) + (throttle_ratio * 0.35), 0.0, 1.0)
		var target_pitch: float = lerpf(0.8, 2.2, speed_ratio)
		if is_nitro_active:
			target_pitch = maxf(target_pitch, 2.4)
		engine_audio.pitch_scale = lerpf(engine_audio.pitch_scale, target_pitch, 12.0 * delta)
	
	# Tire Skid / Screech audio
	if skid_audio:
		var accel_input: float = Input.get_axis("brake_reverse", "accelerate")
		var is_braking_hard: bool = accel_input < -0.15 and is_grounded and linear_velocity.length() > 60.0
		var is_wheel_spinning: bool = is_grounded and rear_wheel and absf(rear_wheel.angular_velocity) > 40.0 and linear_velocity.length() < 70.0
		
		if (is_braking_hard or is_wheel_spinning) and is_active:
			if is_inside_tree() and not skid_audio.playing:
				skid_audio.play()
			skid_audio.volume_db = lerpf(skid_audio.volume_db, -6.0, 10.0 * delta)
		else:
			skid_audio.volume_db = lerpf(skid_audio.volume_db, -80.0, 10.0 * delta)
			if skid_audio.volume_db < -50.0 and skid_audio.playing:
				skid_audio.stop()

func _play_landing_sound() -> void:
	if is_inside_tree() and landing_audio and not landing_audio.playing:
		landing_audio.play()

func _stop_effects() -> void:
	_deactivate_nitro()
	if exhaust_particles:
		exhaust_particles.emitting = false
	if rear_dust:
		rear_dust.emitting = false
	if engine_audio and engine_audio.playing:
		engine_audio.stop()
	if skid_audio and skid_audio.playing:
		skid_audio.stop()
	if _monster_dirt_particles:
		_monster_dirt_particles.emitting = false
	if _monster_rock_particles:
		_monster_rock_particles.emitting = false
	if is_bigfoot_truck():
		monster_surge_state_changed.emit(false)

func _on_crash_detector_body_entered(body: Node) -> void:
	if not is_active:
		return
	if body == self or body == rear_wheel or body == front_wheel:
		return
	
	is_active = false
	crash_reason = "crashed"
	air_time = 0.0
	air_rotation_accum = 0.0
	wheelie_time = 0.0
	_stop_effects()
	apply_crash_damage()
	crashed.emit()

func _restore_clean_look() -> void:
	var body_sprite: Sprite2D = get_node_or_null("BodySprite")
	var rear_tire: Sprite2D = rear_wheel.get_node_or_null("TireSprite") if rear_wheel else null
	var front_tire: Sprite2D = front_wheel.get_node_or_null("TireSprite") if front_wheel else null
	
	if body_sprite:
		if _orig_body_texture:
			body_sprite.texture = _orig_body_texture
		body_sprite.modulate = Color.WHITE
		body_sprite.position = _orig_body_pos
		
	if rear_tire:
		if _orig_rear_wheel_texture:
			rear_tire.texture = _orig_rear_wheel_texture
		rear_tire.modulate = Color.WHITE
		
	if front_tire:
		if _orig_front_wheel_texture:
			front_tire.texture = _orig_front_wheel_texture
		front_tire.modulate = Color.WHITE

func _apply_damaged_look() -> void:
	var body_sprite: Sprite2D = get_node_or_null("BodySprite")
	var rear_tire: Sprite2D = rear_wheel.get_node_or_null("TireSprite") if rear_wheel else null
	var front_tire: Sprite2D = front_wheel.get_node_or_null("TireSprite") if front_wheel else null
	
	var damage_modulate := Color(0.28, 0.28, 0.28, 1.0)
	
	if body_sprite:
		if _burnt_body_texture:
			body_sprite.texture = _burnt_body_texture
			body_sprite.modulate = Color.WHITE
		else:
			body_sprite.modulate = damage_modulate
			
	if rear_tire:
		if _burnt_wheel_texture:
			rear_tire.texture = _burnt_wheel_texture
			rear_tire.modulate = Color.WHITE
		else:
			rear_tire.modulate = damage_modulate
			
	if front_tire:
		if _burnt_wheel_texture:
			front_tire.texture = _burnt_wheel_texture
			front_tire.modulate = Color.WHITE
		else:
			front_tire.modulate = damage_modulate

## Applies damaged appearance on crash
func apply_crash_damage() -> void:
	is_damaged = true
	_apply_damaged_look()
	var driver_sprite: Sprite2D = get_node_or_null("DriverSprite")
	if driver_sprite:
		driver_sprite.rotation_degrees = -30.0

# --- UPGRADE SYSTEM HELPERS ---

## Recalculates effective physics variables from base values and current upgrade tiers
func _recalculate_upgrades() -> void:
	# 1. Engine Power: +20% torque and +12% top speed per level
	motor_torque = base_motor_torque * (1.0 + (engine_level - 1) * 0.20)
	brake_torque = base_brake_torque * (1.0 + (engine_level - 1) * 0.15)
	max_wheel_speed = base_max_wheel_speed * (1.0 + (engine_level - 1) * 0.12)
	
	# 2. Tire Grip: +22% friction per level
	var eff_friction: float = base_wheel_friction * (1.0 + (grip_level - 1) * 0.22)
	_current_base_friction = eff_friction
	_apply_wheel_friction(_current_base_friction + (nitro_traction_boost if is_nitro_active else 0.0))
	
	# 3. Suspension: active spring-damper rate tuning with upgrade level
	# Step 5: A higher stat gives ~10% better damping and ~10% more travel, never bounces more
	var stat_mod: float = (suspension_level - 3) * 0.05
	var effective_travel: float = suspension_max_travel * (1.0 + stat_mod)
	var effective_damping_ratio: float = damping_ratio * (1.0 + stat_mod)
	
	# Per-wheel mass carried based on weight distribution:
	var rear_mass_carried: float = vehicle_mass * rear_weight_ratio
	var front_mass_carried: float = vehicle_mass * front_weight_ratio
	
	# Hooke's spring stiffness k and damping c per wheel:
	# k = m * (2 * pi * bodyFrequencyHz)^2
	# c = 2 * dampingRatio * sqrt(k * m)
	var rear_k: float = rear_mass_carried * pow(2.0 * PI * body_frequency_hz, 2)
	var rear_c: float = 2.0 * effective_damping_ratio * sqrt(rear_k * rear_mass_carried)
	
	var front_k: float = front_mass_carried * pow(2.0 * PI * body_frequency_hz, 2)
	var front_c: float = 2.0 * effective_damping_ratio * sqrt(front_k * front_mass_carried)
	
	_rear_stiffness = rear_k
	_rear_damping = rear_c
	_front_stiffness = front_k
	_front_damping = front_c
	
	suspension_stiffness = (rear_k + front_k) * 0.5
	suspension_damping = (rear_c + front_c) * 0.5
	
	# PinJoint2D softness: rigid revolute joint transmits 100% drive force and keeps wheels perfectly aligned
	var eff_softness: float = 0.0
	if rear_joint:
		rear_joint.softness = eff_softness
	if front_joint:
		front_joint.softness = eff_softness
	
	# 4. Fuel Tank Capacity: +25% capacity per level
	var old_max: float = max_fuel if max_fuel > 0.0 else base_max_fuel
	max_fuel = base_max_fuel * (1.0 + (fuel_tank_level - 1) * 0.25)
	if old_max > 0.0:
		current_fuel = minf(max_fuel, current_fuel * (max_fuel / old_max))
	else:
		current_fuel = max_fuel

func _apply_wheel_friction(friction_val: float) -> void:
	if rear_wheel:
		if rear_wheel.physics_material_override:
			rear_wheel.physics_material_override = rear_wheel.physics_material_override.duplicate()
			rear_wheel.physics_material_override.friction = friction_val
	if front_wheel:
		if front_wheel.physics_material_override:
			front_wheel.physics_material_override = front_wheel.physics_material_override.duplicate()
			front_wheel.physics_material_override.friction = friction_val

## Returns dictionary containing current upgrade levels and calculated effective stats
func get_stats() -> Dictionary:
	var curr_friction: float = base_wheel_friction
	if rear_wheel and rear_wheel.physics_material_override:
		curr_friction = rear_wheel.physics_material_override.friction
	
	var curr_softness: float = base_suspension_softness
	if rear_joint:
		curr_softness = rear_joint.softness
	
	return {
		"engine_power": {
			"level": engine_level,
			"motor_torque": motor_torque,
			"max_wheel_speed": max_wheel_speed,
			"multiplier": 1.0 + (engine_level - 1) * 0.20
		},
		"tire_grip": {
			"level": grip_level,
			"friction": curr_friction,
			"multiplier": 1.0 + (grip_level - 1) * 0.22
		},
		"suspension": {
			"level": suspension_level,
			"softness": curr_softness,
			"multiplier": 1.0 + (suspension_level - 1) * 0.15
		},
		"fuel_tank": {
			"level": fuel_tank_level,
			"max_fuel": max_fuel,
			"multiplier": 1.0 + (fuel_tank_level - 1) * 0.25
		}
	}

## Applies a tier upgrade (1 to 5) to the specified stat
func apply_upgrade(stat_name: String, level: int) -> void:
	var target_level: int = clampi(level, 1, 5)
	var key: String = stat_name.to_lower().strip_edges()
	var canonical_name: String = ""
	
	match key:
		"engine", "engine_power", "engine power":
			engine_level = target_level
			canonical_name = "engine_power"
		"tire", "tire_grip", "grip", "tire grip":
			grip_level = target_level
			canonical_name = "tire_grip"
		"suspension", "suspension_dampening", "suspension dampening":
			suspension_level = target_level
			canonical_name = "suspension"
		"fuel", "fuel_tank", "fuel_capacity", "fuel tank", "fuel tank capacity":
			fuel_tank_level = target_level
			canonical_name = "fuel_tank"
		_:
			push_warning("VehicleController: Unknown upgrade stat name '%s'" % stat_name)
			return
	
	_recalculate_upgrades()
	upgraded.emit(canonical_name, target_level)

## Serializes current upgrade levels into a Dictionary for SaveManager persistence
func serialize_upgrades() -> Dictionary:
	return {
		"engine_level": engine_level,
		"grip_level": grip_level,
		"suspension_level": suspension_level,
		"fuel_tank_level": fuel_tank_level
	}

## Restores upgrade levels from a Dictionary provided by SaveManager
func deserialize_upgrades(data: Dictionary) -> void:
	if data.has("engine_level"):
		engine_level = clampi(int(data["engine_level"]), 1, 5)
	if data.has("grip_level"):
		grip_level = clampi(int(data["grip_level"]), 1, 5)
	if data.has("suspension_level"):
		suspension_level = clampi(int(data["suspension_level"]), 1, 5)
	if data.has("fuel_tank_level"):
		fuel_tank_level = clampi(int(data["fuel_tank_level"]), 1, 5)
	_recalculate_upgrades()

func consume_fuel(amount: float) -> void:
	if not consumes_fuel:
		return
	if current_fuel <= 0.0:
		return
	current_fuel = maxf(0.0, current_fuel - amount)
	fuel_changed.emit(current_fuel, max_fuel)

func refuel(amount: float) -> void:
	current_fuel = clampf(current_fuel + amount, 0.0, max_fuel)
	fuel_changed.emit(current_fuel, max_fuel)

func get_speed_kmh() -> float:
	return (linear_velocity.length() / 100.0) * 3.6

func reset_vehicle(at_position: Vector2) -> void:
	is_active = true
	is_damaged = false
	crash_reason = ""
	freeze = false
	if is_instance_valid(rear_wheel):
		rear_wheel.freeze = false
	if is_instance_valid(front_wheel):
		front_wheel.freeze = false
	
	_restore_clean_look()
		
	var driver_sprite: Sprite2D = get_node_or_null("DriverSprite")
	if driver_sprite:
		driver_sprite.rotation = 0.0
	current_fuel = max_fuel
	current_nitro = max_nitro
	is_nitro_requested = false
	_deactivate_nitro()
	_nitro_blend = 0.0
	_pothole_stuck_timer = 0.0
	_pothole_hint_active = false
	air_time = 0.0
	air_rotation_accum = 0.0
	_last_air_rotation = 0.0
	wheelie_time = 0.0
	fuel_changed.emit(current_fuel, max_fuel)
	nitro_changed.emit(current_nitro, max_nitro)
	pothole_assist_hint.emit(false)
	
	global_position = at_position
	rotation = 0.0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
	var chassis_transform := Transform2D(0.0, at_position)
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, chassis_transform)
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)
	
	if rear_wheel:
		rear_wheel.position = _initial_rear_wheel_offset
		rear_wheel.rotation = 0.0
		rear_wheel.linear_velocity = Vector2.ZERO
		rear_wheel.angular_velocity = 0.0
		var rear_transform := Transform2D(0.0, at_position + _initial_rear_wheel_offset)
		PhysicsServer2D.body_set_state(rear_wheel.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, rear_transform)
		PhysicsServer2D.body_set_state(rear_wheel.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
		PhysicsServer2D.body_set_state(rear_wheel.get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)
		
	if front_wheel:
		front_wheel.position = _initial_front_wheel_offset
		front_wheel.rotation = 0.0
		front_wheel.linear_velocity = Vector2.ZERO
		front_wheel.angular_velocity = 0.0
		var front_transform := Transform2D(0.0, at_position + _initial_front_wheel_offset)
		PhysicsServer2D.body_set_state(front_wheel.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, front_transform)
		PhysicsServer2D.body_set_state(front_wheel.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
		PhysicsServer2D.body_set_state(front_wheel.get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)
	
	if rear_joint:
		rear_joint.position = _initial_rear_wheel_offset
		rear_joint.node_a = NodePath("..")
		if rear_wheel:
			rear_joint.node_b = NodePath("../" + rear_wheel.name)
	if front_joint:
		front_joint.position = _initial_front_wheel_offset
		front_joint.node_a = NodePath("..")
		if front_wheel:
			front_joint.node_b = NodePath("../" + front_wheel.name)
	
	_update_struts()
	
	if is_inside_tree() and engine_audio and not engine_audio.playing:
		engine_audio.play()
	if skid_audio and skid_audio.playing:
		skid_audio.stop()
	if _monster_dirt_particles:
		_monster_dirt_particles.emitting = false
	if _monster_rock_particles:
		_monster_rock_particles.emitting = false
	if is_bigfoot_truck():
		monster_surge_state_changed.emit(false)

## Returns the maximum vertical distance from the vehicle root origin to the bottom of the wheels.
## Used by game modes to place the vehicle on ground with zero gap and no sinking.
func get_wheel_bottom_offset() -> float:
	var offsets: Array[float] = []
	var rw: RigidBody2D = rear_wheel if rear_wheel else get_node_or_null("RearWheel") as RigidBody2D
	var fw: RigidBody2D = front_wheel if front_wheel else get_node_or_null("FrontWheel") as RigidBody2D
	var rwm: Marker2D = rear_wheel_mount if rear_wheel_mount else get_node_or_null("RearWheelMount") as Marker2D
	var fwm: Marker2D = front_wheel_mount if front_wheel_mount else get_node_or_null("FrontWheelMount") as Marker2D
	
	var r_off_y: float = _initial_rear_wheel_offset.y if _initial_rear_wheel_offset != Vector2(-36, 18) else (rwm.position.y if rwm else (rw.position.y if rw else 18.0))
	var f_off_y: float = _initial_front_wheel_offset.y if _initial_front_wheel_offset != Vector2(36, 18) else (fwm.position.y if fwm else (fw.position.y if fw else 18.0))

	if rw and rw.has_node("CollisionShape2D"):
		var shape = rw.get_node("CollisionShape2D").shape
		if shape is CircleShape2D:
			offsets.append(r_off_y + shape.radius)
	elif rwm:
		offsets.append(rwm.position.y + 22.0)
		
	if fw and fw.has_node("CollisionShape2D"):
		var shape = fw.get_node("CollisionShape2D").shape
		if shape is CircleShape2D:
			offsets.append(f_off_y + shape.radius)
	elif fwm:
		offsets.append(fwm.position.y + 22.0)
		
	if not offsets.is_empty():
		offsets.sort()
		return offsets[-1]
	return 40.0

