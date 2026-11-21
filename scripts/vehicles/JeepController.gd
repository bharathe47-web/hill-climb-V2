extends RigidBody2D
class_name JeepController

signal crashed(reason: String)
signal distance_updated(meters: float)
signal nitro_state_changed(is_active: bool)

@export var engine_torque: float = 85000.0
@export var brake_torque: float = 45000.0
@export var air_tilt_torque: float = 24000.0
@export var max_wheel_speed: float = 75.0
@export var nitro_multiplier: float = 2.4

@onready var rear_wheel: RigidBody2D = $RearWheel
@onready var front_wheel: RigidBody2D = $FrontWheel
@onready var rear_spring: DampedSpringJoint2D = $RearSpring
@onready var front_spring: DampedSpringJoint2D = $FrontSpring
@onready var head_area: Area2D = $HeadArea
@onready var nitro_flame: CPUParticles2D = $NitroFlame
@onready var rear_dust: CPUParticles2D = $RearDust
@onready var front_dust: CPUParticles2D = $FrontDust

# Suspension visual struts
@onready var rear_strut: Line2D = $RearStrut
@onready var front_strut: Line2D = $FrontStrut

var is_grounded: bool = false
var is_nitro_active: bool = false
var upside_down_timer: float = 0.0
var out_of_fuel_timer: float = 0.0
var start_x: float = 0.0
var current_speed: float = 0.0

func _ready() -> void:
	start_x = global_position.x
	GameState.reset_run_state()
	
	head_area.body_entered.connect(_on_head_touched_ground)
	AudioManager.start_engine()

func _physics_process(delta: float) -> void:
	if GameState.is_game_over or GameState.is_paused:
		return
		
	# Update distance in meters (100 pixels = 1 meter)
	var distance_m: float = maxf(0.0, (global_position.x - start_x) / 100.0)
	GameState.current_distance = distance_m
	distance_updated.emit(distance_m)
	StageManager.check_progress(distance_m)
	
	# Current speed in km/h
	current_speed = linear_velocity.length() * 0.036
	
	# Engine sound modulation
	var speed_ratio: float = clampf(abs(rear_wheel.angular_velocity) / max_wheel_speed, 0.0, 1.0)
	AudioManager.update_engine_pitch(speed_ratio)
	
	# Suspension visual struts update
	_update_suspension_visuals()
	
	# Ground check (are wheels touching terrain)
	var rear_contacts: int = rear_wheel.get_contact_count()
	var front_contacts: int = front_wheel.get_contact_count()
	is_grounded = (rear_contacts > 0 or front_contacts > 0)
	
	# Dust particle emission
	rear_dust.emitting = (rear_contacts > 0 and abs(rear_wheel.angular_velocity) > 5.0)
	front_dust.emitting = (front_contacts > 0 and abs(front_wheel.angular_velocity) > 5.0)
	
	_handle_input(delta)
	_handle_fuel(delta)
	_handle_nitro(delta)
	_check_flip_and_stop_conditions(delta)

func _update_suspension_visuals() -> void:
	if rear_strut and rear_spring:
		var anchor_pos := to_local(rear_spring.global_position)
		var wheel_pos := to_local(rear_wheel.global_position)
		rear_strut.points = PackedVector2Array([anchor_pos, wheel_pos])
		
	if front_strut and front_spring:
		var anchor_pos := to_local(front_spring.global_position)
		var wheel_pos := to_local(front_wheel.global_position)
		front_strut.points = PackedVector2Array([anchor_pos, wheel_pos])

func _handle_input(_delta: float) -> void:
	var gas_pressed := Input.is_action_pressed("gas") or Input.is_action_pressed("accelerate")
	var brake_pressed := Input.is_action_pressed("brake") or Input.is_action_pressed("brake_reverse")
	
	# Upgrade multipliers
	var engine_mult: float = GameState.get_upgrade_multiplier(GameState.active_vehicle_id, "engine")
	var tire_mult: float = GameState.get_upgrade_multiplier(GameState.active_vehicle_id, "tires")
	var current_engine_torque: float = engine_torque * engine_mult * tire_mult
	
	if is_nitro_active:
		current_engine_torque *= nitro_multiplier
		# Additional linear forward kick
		apply_central_force(Vector2.RIGHT.rotated(rotation) * 8000.0)
		
	if is_grounded:
		# Drive on ground
		if gas_pressed and GameState.current_fuel > 0.0:
			if rear_wheel.angular_velocity < max_wheel_speed:
				rear_wheel.apply_torque_impulse(current_engine_torque * _delta)
				front_wheel.apply_torque_impulse(current_engine_torque * 0.4 * _delta) # 4WD assist
		elif brake_pressed:
			# Braking & reversing
			rear_wheel.apply_torque_impulse(-brake_torque * _delta)
			front_wheel.apply_torque_impulse(-brake_torque * _delta)
	else:
		# In-air tilt balance controls
		if gas_pressed or Input.is_action_pressed("tilt_right"):
			apply_torque_impulse(air_tilt_torque * _delta)
		elif brake_pressed or Input.is_action_pressed("tilt_left"):
			apply_torque_impulse(-air_tilt_torque * _delta)

func _handle_fuel(delta: float) -> void:
	if GameState.current_fuel <= 0.0:
		return
		
	var drain_rate: float = 0.6 # Base idle drain
	var gas_pressed := Input.is_action_pressed("gas") or Input.is_action_pressed("accelerate")
	
	if gas_pressed:
		drain_rate += 2.2
	if is_nitro_active:
		drain_rate += 5.5
		
	GameState.set_fuel(GameState.current_fuel - drain_rate * delta)

func _handle_nitro(delta: float) -> void:
	var nitro_input := Input.is_action_pressed("nitro")
	
	if nitro_input and GameState.current_nitro > 0.0 and GameState.current_fuel > 0.0:
		if not is_nitro_active:
			is_nitro_active = true
			nitro_state_changed.emit(true)
			nitro_flame.emitting = true
			AudioManager.play_sfx("nitro", 1.0, 1.2)
			
		GameState.set_nitro(GameState.current_nitro - 25.0 * delta)
	else:
		if is_nitro_active:
			is_nitro_active = false
			nitro_state_changed.emit(false)
			nitro_flame.emitting = false
			
		# Passive nitro slow recharge over time
		if GameState.current_nitro < GameState.max_nitro:
			GameState.set_nitro(GameState.current_nitro + 4.0 * delta)

func _check_flip_and_stop_conditions(delta: float) -> void:
	# 1. Flip condition: car angle upside down (|rotation| > 2.1 rad ~ 120 degrees)
	var rot_normalized: float = abs(wrapf(rotation, -PI, PI))
	if rot_normalized > 2.1:
		upside_down_timer += delta
		if upside_down_timer > 2.0:
			trigger_crash("Vehicle Flipped!")
	else:
		upside_down_timer = 0.0
		
	# 2. Out of fuel and stopped condition
	if GameState.current_fuel <= 0.0:
		if linear_velocity.length() < 18.0:
			out_of_fuel_timer += delta
			if out_of_fuel_timer > 2.0:
				trigger_crash("Out of Fuel!")
		else:
			out_of_fuel_timer = 0.0

func _on_head_touched_ground(body: Node2D) -> void:
	if body is StaticBody2D or body is TileMap:
		trigger_crash("Driver Injured!")

func trigger_crash(reason: String) -> void:
	if GameState.is_game_over:
		return
	AudioManager.play_sfx("crash", 1.0, 1.5)
	AudioManager.stop_engine()
	crashed.emit(reason)
	GameState.trigger_game_over(reason)
