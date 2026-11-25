class_name FollowCamera
extends Camera2D

## FollowCamera: Smoothly tracks the vehicle with velocity-based lookahead and vertical damping.

@export var target: Node2D
@export var follow_offset: Vector2 = Vector2(180.0, -50.0)
@export var lookahead_factor: float = 0.25
@export var max_lookahead: float = 300.0
@export var follow_smoothing_speed: float = 8.0

## Subtle speed-sensitive zoom: camera eases out slightly at high speed for a sense of velocity,
## and eases back in near a stop so close-quarters driving still reads clearly.
@export var base_zoom: float = 1.0
@export var max_zoom_out: float = 0.085
@export var zoom_speed_reference: float = 420.0
@export var zoom_smoothing_speed: float = 2.4

var trauma: float = 0.0
var _trauma_time: float = 0.0
var target_vertical_offset: float = -50.0
var current_realm_state: int = 0

func _ready() -> void:
	position_smoothing_enabled = false # Custom lerp in physics process gives more responsive vehicle feel
	zoom = Vector2(base_zoom, base_zoom)
	if is_instance_valid(target):
		snap_to_target()
	call_deferred("_auto_discover_progression")

func _auto_discover_progression() -> void:
	var tree_root := get_tree().root
	if tree_root:
		var pc = tree_root.find_child("BiomeProgressionController", true, false)
		if is_instance_valid(pc) and pc.has_signal("state_changed") and not pc.state_changed.is_connected(_on_progression_state_changed):
			pc.state_changed.connect(_on_progression_state_changed)

func _on_progression_state_changed(_old_st: int, new_st: int, _info: Dictionary) -> void:
	set_realm_state(new_st)

## Adjusts vertical framing and damping for celestial ascent vs subterranean descent (Phase 5)
func set_realm_state(new_state: int) -> void:
	current_realm_state = new_state
	match new_state:
		WorldCycleSchedule.WorldState.HEAVEN_ENTRY, WorldCycleSchedule.WorldState.HEAVEN_ACTIVE:
			# Slightly elevated lookahead for upper celestial flight terrace
			target_vertical_offset = -35.0
			set_heaven_ambient_float(true)
			set_hell_ambient_unrest(false)
		WorldCycleSchedule.WorldState.HELL_ENTRY, WorldCycleSchedule.WorldState.HELL_ACTIVE:
			# Lower lookahead for subterranean chasm and catch basin
			target_vertical_offset = -70.0
			set_heaven_ambient_float(false)
			set_hell_ambient_unrest(true)
		_:
			target_vertical_offset = -50.0
			set_heaven_ambient_float(false)
			set_hell_ambient_unrest(false)

## Atmospheric camera rumble during Hell descent
func trigger_hell_rumble() -> void:
	add_trauma(0.20)

## Tactile impact trauma on landing in catch basin or terrace
func trigger_landing_thud() -> void:
	add_trauma(0.25)

## Euphoric surge the instant the player successfully nitro-launches into Heaven or physically
## crosses the Heaven portal: reuses the same forward "yank" as a regular Nitro punch (so the
## two feel like a family of effects) but with extra trauma layered on top, since clearing into
## another realm should read as a bigger beat than routine boosting.
func trigger_heaven_launch_surge() -> void:
	trigger_nitro_punch()
	add_trauma(0.12)

## Harder, heavier hit for crossing into Hell: more trauma than a hard landing, no zoom kick
## (this is a fall/slam, not a forward surge), so it reads distinctly from the Heaven launch.
func trigger_hell_portal_slam() -> void:
	add_trauma(0.38)

## A gentler settle for crossing the Return portal back to Normal Land: a small bump rather
## than a slam or a surge, matching the calmer, "back to baseline" character of that moment.
func trigger_return_portal_settle() -> void:
	add_trauma(0.15)

## Sustained ambient unrest while actually driving through Hell (as opposed to the one-off
## entry rumble above): a small persistent shake floor that holds for as long as the player
## is in the biome, so the realm feels oppressive throughout rather than just at the gate.
var _hell_ambient_unrest: float = 0.0
func set_hell_ambient_unrest(active: bool) -> void:
	_hell_ambient_unrest = 0.045 if active else 0.0

## Sustained gentle float while driving through Heaven: a slow additional sway layered on top
## of normal following, giving the realm a serene, weightless character that contrasts with
## Hell's unrest rather than Heaven just looking different and otherwise feeling the same.
var _heaven_ambient_float: bool = false
var _heaven_float_time: float = 0.0
func set_heaven_ambient_float(active: bool) -> void:
	_heaven_ambient_float = active
	if active:
		_heaven_float_time = 0.0

## A quick forward "yank" when Nitro engages: a brief extra zoom-out kick on top of the
## regular speed zoom, plus a touch of trauma, so the boost has a tactile punch the instant
## it kicks in rather than only building gradually with speed.
var _nitro_punch_time: float = 0.0
var _nitro_punch_active: float = 0.0
var _last_nitro_punch_offset: float = 0.0
func trigger_nitro_punch() -> void:
	add_trauma(0.12)
	_nitro_punch_time = 0.0
	_nitro_punch_active = 1.0

## Instantly snaps camera to target position with follow offset (no lerp delay on start/reset)
func snap_to_target() -> void:
	if is_instance_valid(target):
		global_position = target.global_position + follow_offset

## Resets camera trauma, shake, and snaps immediately to target
func reset_camera() -> void:
	trauma = 0.0
	_trauma_time = 0.0
	zoom = Vector2(base_zoom, base_zoom)
	snap_to_target()

## Adds subtle screen trauma shake (clamped to 1.0)
func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	
	# Smoothly ease vertical follow offset for celestial ascent vs subterranean descent (Phase 5)
	follow_offset.y = lerpf(follow_offset.y, target_vertical_offset, delta * 3.5)
	
	var target_pos: Vector2 = target.global_position + follow_offset
	
	# Add velocity-based lookahead if target is a physics body with velocity
	var current_speed: float = 0.0
	if target is RigidBody2D:
		var vel: Vector2 = (target as RigidBody2D).linear_velocity
		var lookahead: Vector2 = Vector2(clampf(vel.x * lookahead_factor, -80.0, max_lookahead), clampf(vel.y * 0.08, -60.0, 60.0))
		target_pos += lookahead
		current_speed = vel.length()

	# Ease the lens out at speed (capped, smoothed) so acceleration reads as a sense of velocity
	# rather than a jarring zoom snap; eases back in again when the vehicle slows or stops.
	var speed_ratio: float = clampf(current_speed / zoom_speed_reference, 0.0, 1.0)
	var target_zoom_scalar: float = base_zoom + speed_ratio * max_zoom_out
	var smoothed_zoom_scalar: float = lerpf(zoom.x - _last_nitro_punch_offset, target_zoom_scalar, zoom_smoothing_speed * delta)

	# Nitro punch: a short-lived decaying kick layered directly on top of the smoothed speed
	# zoom (bypassing its slow lerp) so the boost reads as an instant tactile yank, fading
	# back out over roughly a third of a second.
	var punch_offset: float = 0.0
	if _nitro_punch_active > 0.0:
		_nitro_punch_time += delta * 9.0
		_nitro_punch_active = maxf(0.0, _nitro_punch_active - delta * 3.2)
		punch_offset = sin(clampf(_nitro_punch_time, 0.0, PI)) * 0.045 * _nitro_punch_active
	_last_nitro_punch_offset = punch_offset

	var new_zoom_scalar: float = smoothed_zoom_scalar + punch_offset
	zoom = Vector2(new_zoom_scalar, new_zoom_scalar)
	
	# Smoothly track horizontal motion while gently damping vertical terrain movement
	global_position.x = lerpf(global_position.x, target_pos.x, follow_smoothing_speed * delta)
	global_position.y = lerpf(global_position.y, target_pos.y, (follow_smoothing_speed * 0.65) * delta)

	# Heaven's sustained gentle float: a slow sway layered on top of normal following, separate
	# from the trauma shake system below (this is a serene drift, not an impact response).
	if _heaven_ambient_float:
		_heaven_float_time += delta
		global_position.y += sin(_heaven_float_time * 0.7) * 3.0
		global_position.x += cos(_heaven_float_time * 0.5) * 2.0

	# Apply subtle trauma screen shake on hard landing / crash. Hell's ambient unrest sets a
	# floor under the *shake magnitude* (not the decaying trauma value itself), so a landing or
	# portal slam while in Hell still spikes and decays naturally, just settling back down to
	# a persistent low shake instead of all the way to stillness.
	var effective_trauma: float = maxf(trauma, _hell_ambient_unrest)
	if effective_trauma > 0.0:
		_trauma_time += delta * 25.0
		var shake_mag: float = effective_trauma * effective_trauma * 7.0 # Max 7 px subtle shake
		var shake_offset := Vector2(sin(_trauma_time * 1.7) * shake_mag, cos(_trauma_time * 2.3) * shake_mag)
		global_position += shake_offset
		# Eased decay: a hard hit settles down quickly at first, then tapers into a softer,
		# lingering tail instead of a constant linear falloff, which reads more like a real
		# physical jolt than a mechanical shake.
		trauma = maxf(0.0, trauma - delta * lerpf(1.1, 3.6, trauma))
