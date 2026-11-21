class_name IndianRoadTerrainV2
extends IndianRoadTerrain

## IndianRoadTerrainV2: Advanced procedural highway generator for Indian Roads mode.
## Renders multi-tiered asphalt cross-section, authentic regional roadside props,
## non-occluding landmarks, and seamless state-specific environments.

const CheckpointV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/CheckpointV2.tscn")
const LandmarkV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/LandmarkV2.tscn")
const FinishArchV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/FinishArchV2.tscn")

@export var gravel_color: Color = Color(0.45, 0.42, 0.38, 1.0) # Graded aggregate shoulder
@export var edge_line_color: Color = Color(0.95, 0.95, 0.98, 0.85) # Reflective white edge line

func _ready() -> void:
	road_surface_color = Color(0.18, 0.20, 0.23, 1.0)
	shoulder_color = Color(0.65, 0.45, 0.30, 1.0)
	stripe_color = Color(0.98, 0.85, 0.15, 1.0)
	bottom_depth = 650.0

func _apply_state_theme(state_id: String) -> void:
	match state_id:
		"goa":
			road_surface_color = Color(0.22, 0.23, 0.26, 1.0)
			shoulder_color = Color(0.85, 0.75, 0.50, 1.0) # Golden coastal beach sand
			gravel_color = Color(0.70, 0.65, 0.52, 1.0)
			stripe_color = Color(1.0, 1.0, 1.0, 0.95)
			terrain_wave_amp = 0.8
			terrain_freq_mult = 0.85
		"kerala":
			road_surface_color = Color(0.16, 0.18, 0.20, 1.0) # Monsoon washed asphalt
			shoulder_color = Color(0.45, 0.30, 0.16, 1.0) # Western Ghats wet humus
			gravel_color = Color(0.38, 0.35, 0.30, 1.0)
			stripe_color = Color(0.98, 0.85, 0.15, 1.0)
			terrain_wave_amp = 1.25
			terrain_freq_mult = 1.15
		"rajasthan":
			road_surface_color = Color(0.26, 0.27, 0.28, 1.0) # Sun-baked desert asphalt
			shoulder_color = Color(0.86, 0.72, 0.44, 1.0) # Thar Desert golden sand
			gravel_color = Color(0.72, 0.64, 0.45, 1.0)
			stripe_color = Color(0.95, 0.80, 0.15, 1.0)
			terrain_wave_amp = 0.65
			terrain_freq_mult = 0.65
		"gujarat":
			road_surface_color = Color(0.21, 0.22, 0.24, 1.0)
			shoulder_color = Color(0.78, 0.76, 0.72, 1.0) # Rann salt-crusted pale clay
			gravel_color = Color(0.65, 0.64, 0.60, 1.0)
			stripe_color = Color(0.98, 0.85, 0.15, 1.0)
			terrain_wave_amp = 0.6
			terrain_freq_mult = 0.75
		"telangana":
			road_surface_color = Color(0.20, 0.21, 0.23, 1.0)
			shoulder_color = Color(0.52, 0.46, 0.40, 1.0) # Deccan plateau granite grit
			gravel_color = Color(0.42, 0.40, 0.38, 1.0)
			stripe_color = Color(0.98, 0.85, 0.15, 1.0)
			terrain_wave_amp = 1.1
			terrain_freq_mult = 1.05
		_: # tamil_nadu
			road_surface_color = Color(0.18, 0.20, 0.23, 1.0)
			shoulder_color = Color(0.65, 0.44, 0.28, 1.0) # South Indian red laterite
			gravel_color = Color(0.48, 0.44, 0.38, 1.0)
			stripe_color = Color(0.98, 0.85, 0.15, 1.0)
			terrain_wave_amp = 1.0
			terrain_freq_mult = 1.0

func _spawn_waypoints() -> void:
	if active_route == null or not is_instance_valid(waypoints_container):
		return

	for wp in active_route.waypoints:
		var wp_x := wp.distance_m * 100.0
		var wp_y := _calculate_road_height(wp_x)
		var spawn_pos := Vector2(wp_x, wp_y)

		match wp.waypoint_type:
			WaypointData.WaypointType.CHECKPOINT:
				var cp := CheckpointV2Scene.instantiate() as IndianCheckpointV2
				cp.waypoint = wp
				cp.global_position = spawn_pos
				cp.checkpoint_cleared.connect(func(id, w): checkpoint_cleared.emit(id, w))
				waypoints_container.add_child(cp)

			WaypointData.WaypointType.LANDMARK, WaypointData.WaypointType.START:
				var lm := LandmarkV2Scene.instantiate() as IndianLandmarkV2
				lm.waypoint = wp
				lm.global_position = spawn_pos
				lm.landmark_reached.connect(func(id, w): landmark_reached.emit(id, w))
				waypoints_container.add_child(lm)

			WaypointData.WaypointType.DESTINATION:
				var fin := FinishArchV2Scene.instantiate() as IndianFinishArchV2
				fin.waypoint = wp
				fin.global_position = spawn_pos
				fin.destination_reached.connect(func(id, w): destination_reached.emit(id, w))
				waypoints_container.add_child(fin)

func _spawn_roadside_props() -> void:
	if not is_instance_valid(props_container):
		return

	# Load textures from visual_upgrade_v2
	var tex_banyan = load("res://assets/indian_roads/visual_upgrade_v2/indian_roadside_banyan_tree.png")
	var tex_coconut = load("res://assets/indian_roads/visual_upgrade_v2/indian_roadside_coconut_tree.png")
	var tex_dhaba = load("res://assets/indian_roads/visual_upgrade_v2/indian_roadside_dhaba_stall.png")
	var tex_rickshaw = load("res://assets/indian_roads/visual_upgrade_v2/indian_roadside_auto_rickshaw.png")
	var tex_tea = load("res://assets/indian_roads/visual_upgrade_v2/indian_roadside_tea_stall.png")
	var tex_sign_nh44 = load("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_nh44.png")
	var tex_sign_speed = load("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_speed_limit.png")
	var tex_milestone = load("res://assets/indian_roads/visual_upgrade_v2/indian_roadside_milestone_km.png")
	var tex_guardrail = load("res://assets/indian_roads/visual_upgrade_v2/indian_guardrail_concrete.png")
	var tex_sign_sb = load("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_speed_breaker.png")
	var tex_sign_curve = load("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_curve_ahead.png")
	var tex_barricade = load("res://assets/indian_roads/visual_upgrade_v2/indian_road_barricade_yellow_black.png")
	var tex_cone = load("res://assets/indian_roads/visual_upgrade_v2/indian_traffic_cone.png")

	# 1. Advance Speed Breaker warning signs
	if tex_sign_sb:
		for sb_x in speed_breaker_x_positions:
			var sign_x := sb_x - 6500.0
			if sign_x > 500.0:
				_add_roadside_sprite(tex_sign_sb, 95.0, sign_x, _calculate_road_height(sign_x), 1)

	# 2. Road Work / Construction hazard zone props
	for hz_x in hazard_zone_x_positions:
		if tex_sign_curve:
			_add_roadside_sprite(tex_sign_curve, 95.0, hz_x - 3500.0, _calculate_road_height(hz_x - 3500.0), 1)

		if tex_cone:
			for cone_off: float in [-1800.0, -900.0, 900.0, 1800.0]:
				var cx: float = hz_x + cone_off
				_add_roadside_sprite(tex_cone, 32.0, cx, _calculate_road_height(cx), 1)

		if tex_barricade:
			_add_roadside_sprite(tex_barricade, 55.0, hz_x, _calculate_road_height(hz_x), 1)

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
					_add_roadside_sprite(tex_sign_nh44, 95.0, current_x, y, 1)
			6:
				if tex_sign_speed:
					_add_roadside_sprite(tex_sign_speed, 95.0, current_x, y, 1)
			7:
				if tex_milestone:
					_add_roadside_sprite(tex_milestone, 50.0, current_x, y, 1)

		# Add guardrails along steeper slopes
		if absf(_calculate_road_height(current_x + 60.0) - y) > 2.5 and tex_guardrail:
			_add_roadside_sprite(tex_guardrail, 36.0, current_x, y, 1)

		current_x += rng.randf_range(250.0, 500.0)

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

	# 1. Foundation polygon (subsurface earth foundation)
	var poly := PackedVector2Array()
	poly.append_array(road_points)
	var last_x := road_points[road_points.size() - 1].x
	var first_x := road_points[0].x
	poly.append(Vector2(last_x, base_y + bottom_depth))
	poly.append(Vector2(first_x, base_y + bottom_depth))
	draw_colored_polygon(poly, shoulder_color)

	# 2. Graded aggregate shoulder strip (thickness 32px below asphalt)
	draw_polyline(road_points, gravel_color, 32.0, true)

	# 3. Main dark stone-mastic asphalt highway surface (thickness 24px)
	draw_polyline(road_points, road_surface_color, 24.0, true)

	# 4. Asphalt edge highlight / top rim (thickness 4px)
	draw_polyline(road_points, road_surface_color.lightened(0.12), 4.0, true)

	# 5. Continuous reflective white road shoulder edge lines
	for i in range(road_points.size() - 1):
		var p1 := road_points[i]
		var p2 := road_points[i + 1]
		var dir := (p2 - p1).normalized()
		var norm := Vector2(-dir.y, dir.x)
		# Top shoulder edge line
		draw_line(p1 + norm * 9.0, p2 + norm * 9.0, edge_line_color, 2.0, true)
		# Bottom shoulder edge line
		draw_line(p1 - norm * 9.0, p2 - norm * 9.0, edge_line_color, 2.0, true)

	# 6. Asphalt potholes (recessed depression with cracked edge)
	for pt_x in pothole_x_positions:
		var py := _calculate_road_height(pt_x)
		draw_circle(Vector2(pt_x, py + 2.0), 16.0, road_surface_color.darkened(0.55))
		draw_arc(Vector2(pt_x, py + 2.0), 16.0, 0.0, TAU, 12, road_surface_color.lightened(0.25), 1.5)

	# 7. Speed breaker yellow stripes
	for sb_x in speed_breaker_x_positions:
		for offset: float in [-18.0, -9.0, 0.0, 9.0, 18.0]:
			var px: float = sb_x + offset
			var py := _calculate_road_height(px)
			draw_line(Vector2(px, py - 9.0), Vector2(px, py + 9.0), Color(1.0, 0.88, 0.2, 0.95), 3.0)

	# 8. Yellow dashed highway center line
	var stripe_len := 40.0
	var gap_len := 30.0
	var cycle := stripe_len + gap_len

	for i in range(road_points.size() - 1):
		var p1 := road_points[i]
		var p2 := road_points[i + 1]
		var dir := (p2 - p1).normalized()
		var normal := Vector2(-dir.y, dir.x)
		var c1 := p1 + normal * 1.5
		var c2 := p2 + normal * 1.5

		var dist_along := fmod(p1.x, cycle)
		if dist_along < stripe_len:
			draw_line(c1, c2, stripe_color, 3.0, true)
