class_name IndianRoadTerrain
extends Node2D

## IndianRoadTerrain: Generates smooth, continuous asphalt highway with roadside scenery,
## landmarks, checkpoints, and finish arch for Indian Roads mode.

const RouteData = preload("res://resources/routes/RouteData.gd")
const WaypointData = preload("res://resources/routes/WaypointData.gd")
const CheckpointScene = preload("res://scenes/modes/indian_roads/Checkpoint.tscn")
const LandmarkScene = preload("res://scenes/modes/indian_roads/Landmark.tscn")
const FinishArchScene = preload("res://scenes/modes/indian_roads/FinishArch.tscn")

signal checkpoint_cleared(checkpoint_id: String, waypoint: WaypointData)
signal landmark_reached(landmark_id: String, waypoint: WaypointData)
signal destination_reached(destination_id: String, waypoint: WaypointData)
signal coin_collected(value: int)
signal fuel_collected(amount: float)

@export var road_surface_color: Color = Color(0.22, 0.23, 0.26, 1.0) # Highway asphalt
@export var shoulder_color: Color = Color(0.68, 0.52, 0.36, 1.0) # Indian red-brown roadside dirt
@export var stripe_color: Color = Color(0.95, 0.85, 0.20, 1.0) # Yellow highway center stripe
@export var bottom_depth: float = 600.0

@onready var static_body: StaticBody2D = $StaticBody2D
@onready var collision_poly: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var road_canvas: Node2D = $RoadCanvas
@onready var props_container: Node2D = $PropsContainer
@onready var waypoints_container: Node2D = $WaypointsContainer

var active_route: RouteData = null
var road_points: PackedVector2Array = []
var road_normals: PackedVector2Array = []
var base_y: float = 382.0
var total_length_px: float = 180000.0 # 1800m * 100px
var terrain_wave_amp: float = 1.0
var terrain_freq_mult: float = 1.0
var speed_breaker_x_positions: Array[float] = []
var hazard_zone_x_positions: Array[float] = []
var pothole_x_positions: Array[float] = []

func _ready() -> void:
	pass

func generate_route(route: RouteData) -> void:
	active_route = route
	_clear_existing()
	_apply_state_theme(route.state_id if route != null else "tamil_nadu")

	var total_meters := route.get_total_distance_m() if route != null else 1800.0
	# In Indian Roads, 1 meter = 100 px (consistent with core vehicle telemetry)
	total_length_px = total_meters * 100.0

	_plan_road_features()
	_generate_highway_profile()
	_build_collision()
	_spawn_waypoints()
	_spawn_roadside_props()
	queue_redraw()

func _apply_state_theme(state_id: String) -> void:
	match state_id:
		"goa":
			road_surface_color = Color(0.24, 0.25, 0.27, 1.0)
			shoulder_color = Color(0.86, 0.76, 0.52, 1.0) # Golden coastal beach sand
			stripe_color = Color(1.0, 1.0, 1.0, 0.95) # White coastal stripes
			terrain_wave_amp = 0.8
			terrain_freq_mult = 0.85
		"kerala":
			road_surface_color = Color(0.19, 0.21, 0.23, 1.0) # Dark monsoon asphalt
			shoulder_color = Color(0.48, 0.32, 0.18, 1.0) # Western Ghats laterite loam
			stripe_color = Color(0.95, 0.85, 0.20, 1.0)
			terrain_wave_amp = 1.25
			terrain_freq_mult = 1.15
		"rajasthan":
			road_surface_color = Color(0.28, 0.29, 0.30, 1.0) # Sun-baked desert asphalt
			shoulder_color = Color(0.85, 0.72, 0.44, 1.0) # Thar Desert golden sand
			stripe_color = Color(0.95, 0.80, 0.15, 1.0)
			terrain_wave_amp = 0.65
			terrain_freq_mult = 0.65
		"gujarat":
			road_surface_color = Color(0.23, 0.24, 0.26, 1.0)
			shoulder_color = Color(0.76, 0.74, 0.70, 1.0) # Rann salt-tinged pale clay
			stripe_color = Color(0.95, 0.85, 0.20, 1.0)
			terrain_wave_amp = 0.6
			terrain_freq_mult = 0.75
		"telangana":
			road_surface_color = Color(0.21, 0.22, 0.25, 1.0)
			shoulder_color = Color(0.55, 0.48, 0.42, 1.0) # Deccan plateau granite grey-brown
			stripe_color = Color(0.95, 0.85, 0.20, 1.0)
			terrain_wave_amp = 1.1
			terrain_freq_mult = 1.05
		_: # tamil_nadu and default
			road_surface_color = Color(0.22, 0.23, 0.26, 1.0)
			shoulder_color = Color(0.68, 0.46, 0.30, 1.0) # Red-brown tropical soil
			stripe_color = Color(0.95, 0.85, 0.20, 1.0)
			terrain_wave_amp = 1.0
			terrain_freq_mult = 1.0

func _plan_road_features() -> void:
	speed_breaker_x_positions.clear()
	hazard_zone_x_positions.clear()
	pothole_x_positions.clear()

	# Deterministic speed breaker placement roughly every 300m, avoiding waypoints
	var sb_cursor := 24000.0
	while sb_cursor < total_length_px - 8000.0:
		var safe := true
		if active_route != null:
			for wp in active_route.waypoints:
				var wp_x := wp.distance_m * 100.0
				if absf(sb_cursor - wp_x) < 2500.0:
					safe = false
					break
		if safe:
			speed_breaker_x_positions.append(sb_cursor)
		sb_cursor += 32000.0

	# Road work / construction zones
	if total_length_px > 60000.0:
		hazard_zone_x_positions.append(50000.0)
	if total_length_px > 130000.0:
		hazard_zone_x_positions.append(115000.0)

	# Gentle asphalt potholes
	if total_length_px > 40000.0:
		var st := active_route.state_id if active_route != null else ""
		if st == "tamil_nadu":
			pothole_x_positions.append(24000.0)
		else:
			pothole_x_positions.append(34000.0)
	if total_length_px > 90000.0:
		pothole_x_positions.append(88000.0)
	if total_length_px > 150000.0:
		pothole_x_positions.append(142000.0)

func _clear_existing() -> void:
	road_points.clear()
	road_normals.clear()
	speed_breaker_x_positions.clear()
	hazard_zone_x_positions.clear()
	pothole_x_positions.clear()
	if is_instance_valid(waypoints_container):
		for child in waypoints_container.get_children():
			child.queue_free()
	if is_instance_valid(props_container):
		for child in props_container.get_children():
			child.queue_free()

func _generate_highway_profile() -> void:
	# Step size: 60 px per point gives ultra-smooth road physics without jitter
	var step := 60.0
	var min_x := -1200.0
	var max_x := total_length_px + 1200.0
	var count := int((max_x - min_x) / step) + 4
	road_points.resize(count)

	for i in range(count):
		var x := min_x + float(i) * step
		var y := _calculate_road_height(x)
		road_points[i] = Vector2(x, y)

	# Calculate normal tangents for accurate roadside prop alignment
	road_normals.resize(count)
	for i in range(count):
		var p_prev := road_points[maxi(0, i - 1)]
		var p_next := road_points[mini(count - 1, i + 1)]
		var tangent := (p_next - p_prev).normalized()
		road_normals[i] = Vector2(-tangent.y, tangent.x)

func _calculate_road_height(x: float) -> float:
	# Flat tarmac apron behind start line
	if x <= 0.0:
		return base_y

	# Highway physics profile:
	# Flat stretches near start, smooth blend-in, and flat areas near checkpoints
	var h := base_y

	# Rolling highway elevation with gentle slopes adjusted by state profile
	var wave1 := sin(x * 0.0012 * terrain_freq_mult) * (35.0 * terrain_wave_amp)
	var wave2 := sin(x * 0.0005 * terrain_freq_mult) * (25.0 * terrain_wave_amp)
	var wave3 := cos(x * 0.0022 * terrain_freq_mult) * (12.0 * terrain_wave_amp)

	# Smoothly blend in from flat start (0-3000px)
	var start_blend := clampf(x / 3000.0, 0.0, 1.0)
	start_blend = start_blend * start_blend * (3.0 - 2.0 * start_blend) # smoothstep

	# Flatten around checkpoints to ensure stable vehicle arrival
	var flatten := 1.0
	if active_route != null:
		for wp in active_route.waypoints:
			var wp_x := wp.distance_m * 100.0
			var dist_to_wp := absf(x - wp_x)
			if dist_to_wp < 600.0:
				var local_f := clampf(dist_to_wp / 600.0, 0.0, 1.0)
				local_f = local_f * local_f * (3.0 - 2.0 * local_f)
				flatten = minf(flatten, local_f)

	# Special Feature: Kanyakumari Glass Bridge elevation profile for Tamil Nadu
	var state_id := active_route.state_id if active_route != null else ""
	var bridge_elevation := 0.0
	var bridge_flatten := 1.0

	if state_id == "tamil_nadu" and x >= 26000.0 and x <= 46000.0:
		# Entrance ramp: 27000 to 29500 (rising by 85px with smoothstep)
		if x >= 27000.0 and x < 29500.0:
			var t := (x - 27000.0) / 2500.0
			var s := t * t * (3.0 - 2.0 * t)
			bridge_elevation = -85.0 * s
		# Arched glass bridge deck: 29500 to 42500 (spanning the ocean between Vivekananda & Thiruvalluvar)
		elif x >= 29500.0 and x <= 42500.0:
			var u := (x - 29500.0) / (42500.0 - 29500.0)
			var arch := sin(u * PI) * 20.0
			bridge_elevation = -85.0 - arch
		# Exit ramp: 42500 to 45000 (descending by 85px back to coastal highway level)
		elif x > 42500.0 and x <= 45000.0:
			var v := (x - 42500.0) / 2500.0
			var sv := v * v * (3.0 - 2.0 * v)
			bridge_elevation = -85.0 * (1.0 - sv)

		# Smoothly damp natural terrain waves on and approaching bridge
		if x < 27000.0:
			bridge_flatten = clampf((27000.0 - x) / 1000.0, 0.0, 1.0)
		elif x > 45000.0:
			bridge_flatten = clampf((x - 45000.0) / 1000.0, 0.0, 1.0)
		else:
			bridge_flatten = 0.0

	h += (wave1 + wave2 + wave3) * flatten * start_blend * bridge_flatten + bridge_elevation

	# Add physical speed breaker bump (-7.0 px elevation hump over ~120 px width)
	for sb_x in speed_breaker_x_positions:
		var d := x - sb_x
		if absf(d) < 90.0:
			h -= 7.0 * exp(-pow(d / 40.0, 2.0))

	# Add pothole asphalt depression (+3.5 px dip over ~80 px width)
	for pt_x in pothole_x_positions:
		var d := x - pt_x
		if absf(d) < 70.0:
			h += 3.5 * exp(-pow(d / 32.0, 2.0))

	return h

func get_height_at(x: float) -> float:
	return _calculate_road_height(x)

func _build_collision() -> void:
	if not is_instance_valid(collision_poly) or road_points.is_empty():
		return

	var poly := PackedVector2Array()
	# Top surface
	poly.append_array(road_points)
	# Bottom closing polygon
	var last_x := road_points[road_points.size() - 1].x
	var first_x := road_points[0].x
	poly.append(Vector2(last_x, base_y + bottom_depth))
	poly.append(Vector2(first_x, base_y + bottom_depth))

	collision_poly.polygon = poly

func _spawn_waypoints() -> void:
	if active_route == null or not is_instance_valid(waypoints_container):
		return

	for wp in active_route.waypoints:
		var wp_x := wp.distance_m * 100.0
		var wp_y := _calculate_road_height(wp_x)
		var spawn_pos := Vector2(wp_x, wp_y)

		match wp.waypoint_type:
			WaypointData.WaypointType.CHECKPOINT:
				var cp := CheckpointScene.instantiate() as IndianCheckpoint
				cp.waypoint = wp
				cp.global_position = spawn_pos
				cp.checkpoint_cleared.connect(func(id, w): checkpoint_cleared.emit(id, w))
				waypoints_container.add_child(cp)

			WaypointData.WaypointType.LANDMARK, WaypointData.WaypointType.START:
				var lm := LandmarkScene.instantiate() as IndianLandmark
				lm.waypoint = wp
				lm.global_position = spawn_pos
				lm.landmark_reached.connect(func(id, w): landmark_reached.emit(id, w))
				waypoints_container.add_child(lm)

			WaypointData.WaypointType.DESTINATION:
				var fin := FinishArchScene.instantiate() as IndianFinishArch
				fin.waypoint = wp
				fin.global_position = spawn_pos
				fin.destination_reached.connect(func(id, w): destination_reached.emit(id, w))
				waypoints_container.add_child(fin)

func _spawn_roadside_props() -> void:
	if not is_instance_valid(props_container):
		return

	# Load textures
	var tex_banyan = load("res://assets/indian_roads/tropical_roadside_banyan_tree.png") if ResourceLoader.exists("res://assets/indian_roads/tropical_roadside_banyan_tree.png") else load("res://assets/indian_roads/indian_roadside_banyan_tree.png")
	var tex_coconut = load("res://assets/indian_roads/tropical_roadside_coconut_tree.png") if ResourceLoader.exists("res://assets/indian_roads/tropical_roadside_coconut_tree.png") else load("res://assets/indian_roads/indian_roadside_coconut_tree.png")
	var tex_dhaba = load("res://assets/indian_roads/indian_roadside_dhaba_stall.png")
	var tex_rickshaw = load("res://assets/indian_roads/indian_roadside_auto_rickshaw.png")
	var tex_tea = load("res://assets/indian_roads/indian_roadside_tea_stall.png")
	var tex_sign_nh44 = load("res://assets/indian_roads/indian_road_sign_nh44.png")
	var tex_sign_speed = load("res://assets/indian_roads/indian_road_sign_speed_limit.png")
	var tex_milestone = load("res://assets/indian_roads/indian_roadside_milestone_km.png")
	var tex_guardrail = load("res://assets/indian_roads/indian_guardrail_concrete.png")
	var tex_sign_sb = load("res://assets/indian_roads/indian_road_sign_speed_breaker.png")
	var tex_sign_curve = load("res://assets/indian_roads/indian_road_sign_curve_ahead.png")
	var tex_barricade = load("res://assets/indian_roads/indian_road_barricade_yellow_black.png")
	var tex_cone = load("res://assets/indian_roads/indian_traffic_cone.png")

	# 1. Spawn advance Speed Breaker signs
	if tex_sign_sb:
		for sb_x in speed_breaker_x_positions:
			var sign_x := sb_x - 6500.0
			if sign_x > 500.0:
				_add_roadside_sprite(tex_sign_sb, 90.0, sign_x, _calculate_road_height(sign_x), -1)

	# 2. Spawn Road Work / Construction Zone props
	for hz_x in hazard_zone_x_positions:
		if tex_sign_curve:
			_add_roadside_sprite(tex_sign_curve, 90.0, hz_x - 3500.0, _calculate_road_height(hz_x - 3500.0), -1)

		if tex_cone:
			for cone_off: float in [-1800.0, -900.0, 900.0, 1800.0]:
				var cx: float = hz_x + cone_off
				_add_roadside_sprite(tex_cone, 32.0, cx, _calculate_road_height(cx), -1)

		if tex_barricade:
			_add_roadside_sprite(tex_barricade, 55.0, hz_x, _calculate_road_height(hz_x), -1)

	# 3. State-specific prop weighting along the highway
	var state_id := active_route.state_id if active_route != null else "tamil_nadu"
	var allowed_props: Array[int] = []
	match state_id:
		"goa":
			allowed_props = [0, 0, 0, 2, 2, 4, 4, 6, 7]
		"kerala":
			allowed_props = [0, 0, 1, 1, 4, 4, 4, 6, 7]
		"rajasthan":
			allowed_props = [1, 2, 2, 5, 6, 6, 7, 7, 7]
		"gujarat":
			allowed_props = [1, 2, 4, 5, 6, 6, 7, 7]
		"telangana":
			allowed_props = [1, 2, 3, 3, 4, 4, 5, 7]
		_: # tamil_nadu
			allowed_props = [0, 0, 1, 2, 3, 4, 5, 6, 7]

	# Seeded deterministic prop placement along the highway
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261113

	var current_x := 800.0
	while current_x < total_length_px - 800.0:
		var prop_type: int = allowed_props[rng.randi() % allowed_props.size()]
		var y := _calculate_road_height(current_x)

		match prop_type:
			0:
				if tex_coconut:
					_add_roadside_sprite(tex_coconut, 220.0, current_x, y, -1)
			1:
				if tex_banyan:
					_add_roadside_sprite(tex_banyan, 200.0, current_x, y, -2)
			2:
				if tex_dhaba:
					_add_roadside_sprite(tex_dhaba, 105.0, current_x, y, -1)
			3:
				if tex_rickshaw:
					_add_roadside_sprite(tex_rickshaw, 58.0, current_x, y, -1)
			4:
				if tex_tea:
					_add_roadside_sprite(tex_tea, 90.0, current_x, y, -1)
			5:
				if tex_sign_nh44:
					_add_roadside_sprite(tex_sign_nh44, 95.0, current_x, y, -1)
			6:
				if tex_sign_speed:
					_add_roadside_sprite(tex_sign_speed, 95.0, current_x, y, -1)
			7:
				if tex_milestone:
					_add_roadside_sprite(tex_milestone, 50.0, current_x, y, -1)

		# Add guardrails along steeper slopes (Z-index -1)
		if absf(_calculate_road_height(current_x + 60.0) - y) > 2.5 and tex_guardrail:
			_add_roadside_sprite(tex_guardrail, 36.0, current_x, y, -1)

		current_x += rng.randf_range(650.0, 1000.0)

func _add_roadside_sprite(tex: Texture2D, target_height: float, pos_x: float, road_y: float, z_idx: int) -> Sprite2D:
	if not tex:
		return null
	var spr := Sprite2D.new()
	spr.texture = tex
	var th := float(tex.get_height())
	if th > 0.0:
		var s := target_height / th
		spr.scale = Vector2(s, s)
	spr.centered = true
	spr.position = Vector2(pos_x, road_y - (target_height * 0.5))
	spr.z_index = z_idx
	props_container.add_child(spr)
	return spr

func _draw() -> void:
	if road_points.size() < 2:
		return

	# Draw road foundation polygon (earth subsurface)
	var poly := PackedVector2Array()
	poly.append_array(road_points)
	var last_x := road_points[road_points.size() - 1].x
	var first_x := road_points[0].x
	poly.append(Vector2(last_x, base_y + bottom_depth))
	poly.append(Vector2(first_x, base_y + bottom_depth))
	draw_colored_polygon(poly, shoulder_color)

	# Draw main asphalt road surface line (thickness 24 px)
	draw_polyline(road_points, road_surface_color, 24.0, true)

	# Draw upper asphalt top edge (thickness 6 px)
	draw_polyline(road_points, road_surface_color.lightened(0.1), 6.0, true)

	# Draw asphalt potholes (dark textured depressions with cracked asphalt rim)
	for pt_x in pothole_x_positions:
		var py := _calculate_road_height(pt_x)
		draw_circle(Vector2(pt_x, py + 2.0), 16.0, road_surface_color.darkened(0.45))
		draw_arc(Vector2(pt_x, py + 2.0), 16.0, 0.0, TAU, 10, road_surface_color.lightened(0.2), 1.5)

	# Draw yellow speed breaker stripes
	for sb_x in speed_breaker_x_positions:
		for offset: float in [-18.0, -9.0, 0.0, 9.0, 18.0]:
			var px: float = sb_x + offset
			var py := _calculate_road_height(px)
			draw_line(Vector2(px, py - 9.0), Vector2(px, py + 9.0), Color(1.0, 0.88, 0.2, 0.95), 3.0)

	# Draw yellow dashed highway center stripes
	var stripe_len := 40.0
	var gap_len := 30.0
	var cycle := stripe_len + gap_len

	for i in range(road_points.size() - 1):
		var p1 := road_points[i]
		var p2 := road_points[i + 1]
		var dir := (p2 - p1).normalized()
		var normal := Vector2(-dir.y, dir.x)

		# Center line offset down slightly onto the road surface
		var c1 := p1 + normal * 2.0
		var c2 := p2 + normal * 2.0

		var dist_along := fmod(p1.x, cycle)
		if dist_along < stripe_len:
			draw_line(c1, c2, stripe_color, 3.0, true)


