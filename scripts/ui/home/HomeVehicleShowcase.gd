class_name HomeVehicleShowcase
extends Node2D

## HomeVehicleShowcase: Displays the player's selected Garage vehicle as a static,
## physics-free showcase on the home screen. It reuses the real vehicle scene from
## VehicleRegistry (so every vehicle and the Garage selection stay the single source of
## truth), strips gameplay nodes (physics, joints, audio, scripts), then adds a subtle
## engine-idle vibration and a lightweight exhaust smoke emitter at the rear pipe.
##
## This node's origin is the ground contact point under the vehicle's centre.

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const SMOKE_TEXTURE: Texture2D = preload("res://assets/vehicles/effects/exhaust_smoke_particle_01.png")

@export var vehicle_scale: float = 3.4
## Engine idle vibration (in vehicle-local units, before scaling).
@export var vibration_amplitude: float = 0.22
@export var vibration_frequency: float = 26.0
## Slow suspension bob (in vehicle-local units, before scaling).
@export var suspension_amplitude: float = 0.45
@export var suspension_frequency: float = 2.2

var vehicle_id: String = ""

var _visual: Node2D = null
var _exhaust: CPUParticles2D = null
var _body_nodes: Array[Node2D] = []
var _body_base_y: Array[float] = []
var _time: float = 0.0

func _process(delta: float) -> void:
	if _body_nodes.is_empty():
		return
	_time += delta
	var offset := sin(_time * vibration_frequency) * vibration_amplitude
	offset += sin(_time * TAU * suspension_frequency * 0.5) * suspension_amplitude
	for i in range(_body_nodes.size()):
		if is_instance_valid(_body_nodes[i]):
			_body_nodes[i].position.y = _body_base_y[i] + offset

## Rebuilds the showcase for the given vehicle id. Unknown ids fall back to the default.
func show_vehicle(id: String) -> bool:
	_clear()
	var target_id := id if VehicleRegistry.has_vehicle(id) else "blue_flame_truck"
	var inst: Node = VehicleRegistry.instantiate_vehicle(target_id)
	if inst == null:
		return false
	vehicle_id = target_id
	var root := inst as Node2D

	# Measure from the real vehicle data before stripping anything.
	var wheel_bottom := _measure_wheel_bottom(root)
	var wheel_center_x := _measure_wheel_center_x(root)
	var exhaust_pos := _measure_exhaust_position(root)

	_strip_gameplay(root)

	_visual = Node2D.new()
	_visual.name = "VehicleVisual"
	_visual.scale = Vector2(vehicle_scale, vehicle_scale)
	_visual.position = Vector2(-wheel_center_x * vehicle_scale, -wheel_bottom * vehicle_scale)
	add_child(_visual)
	root.process_mode = Node.PROCESS_MODE_DISABLED
	_visual.add_child(root)

	# Chassis-side nodes vibrate; wheels (and strut lines) stay planted on the ground.
	for child in root.get_children():
		if child is Node2D and not _is_planted(child):
			_body_nodes.append(child)
			_body_base_y.append(child.position.y)

	_create_exhaust((exhaust_pos - Vector2(wheel_center_x, 0.0)) * vehicle_scale
			+ Vector2(0.0, -wheel_bottom * vehicle_scale))
	return true

func _clear() -> void:
	_body_nodes.clear()
	_body_base_y.clear()
	_time = 0.0
	if is_instance_valid(_visual):
		remove_child(_visual)
		_visual.queue_free()
	_visual = null
	if is_instance_valid(_exhaust):
		remove_child(_exhaust)
		_exhaust.queue_free()
	_exhaust = null

func _is_planted(node: Node) -> bool:
	var n := String(node.name)
	return n.ends_with("Wheel") or n.contains("Strut") or n.contains("Shock")

func _measure_wheel_bottom(root: Node2D) -> float:
	var bottom := -INF
	for wheel_name in ["RearWheel", "FrontWheel"]:
		var wheel := root.get_node_or_null(wheel_name) as Node2D
		if wheel == null:
			continue
		var radius := 16.0
		for c in wheel.get_children():
			if c is CollisionShape2D and c.shape is CircleShape2D:
				radius = (c.shape as CircleShape2D).radius
		bottom = maxf(bottom, wheel.position.y + radius)
	return bottom if bottom > -INF else 40.0

func _measure_wheel_center_x(root: Node2D) -> float:
	var rear := root.get_node_or_null("RearWheel") as Node2D
	var front := root.get_node_or_null("FrontWheel") as Node2D
	if rear and front:
		return (rear.position.x + front.position.x) * 0.5
	return 0.0

func _measure_exhaust_position(root: Node2D) -> Vector2:
	var particles := root.get_node_or_null("ExhaustParticles") as Node2D
	if particles:
		return particles.position
	var pipe := root.get_node_or_null("ExhaustPipe") as Node2D
	if pipe:
		return pipe.position + Vector2(-8.0, 0.0)
	return Vector2(-58.0, 6.0)

## Removes everything that would make the vehicle behave like a gameplay object.
func _strip_gameplay(root: Node) -> void:
	root.set_script(null)
	var doomed: Array[Node] = []
	_collect_gameplay_nodes(root, doomed)
	for n in doomed:
		if is_instance_valid(n):
			n.get_parent().remove_child(n)
			n.free()
	_freeze_bodies(root)

func _collect_gameplay_nodes(node: Node, out: Array[Node]) -> void:
	for child in node.get_children():
		if child is AudioStreamPlayer2D or child is CPUParticles2D or child is GPUParticles2D \
				or child is Area2D or child is Joint2D or child is CollisionShape2D:
			out.append(child)
		else:
			_collect_gameplay_nodes(child, out)

func _freeze_bodies(node: Node) -> void:
	if node is RigidBody2D:
		node.freeze = true
		node.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	for child in node.get_children():
		_freeze_bodies(child)

func _create_exhaust(pos: Vector2) -> void:
	_exhaust = CPUParticles2D.new()
	_exhaust.name = "ExhaustSmoke"
	_exhaust.position = pos
	_exhaust.texture = SMOKE_TEXTURE
	_exhaust.amount = 14
	_exhaust.lifetime = 1.1
	_exhaust.local_coords = true
	_exhaust.emitting = true
	_exhaust.direction = Vector2(-1.0, -0.22)
	_exhaust.spread = 10.0
	_exhaust.initial_velocity_min = 22.0
	_exhaust.initial_velocity_max = 44.0
	_exhaust.gravity = Vector2(0.0, -18.0)
	_exhaust.damping_min = 8.0
	_exhaust.damping_max = 16.0
	_exhaust.scale_amount_min = 0.08
	_exhaust.scale_amount_max = 0.14
	var scale_curve := Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.5))
	scale_curve.add_point(Vector2(1.0, 1.5))
	_exhaust.scale_amount_curve = scale_curve
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.95, 0.95, 0.92, 0.75))
	ramp.set_color(1, Color(0.92, 0.92, 0.9, 0.0))
	_exhaust.color_ramp = ramp
	add_child(_exhaust)
