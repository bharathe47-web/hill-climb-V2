class_name GoaTerrainHelper
extends RefCounted

## GoaTerrainHelper: Dedicated Goa road, multi-layer soil/laterite/grass embankment,
## Mollem forest stream bridge, and structured non-repetitive roadside & foreground scenery builder.

const BRIDGE_START_X := 74800.0
const BRIDGE_END_X := 78200.0
const BRIDGE_DECK_START_X := 75400.0
const BRIDGE_DECK_END_X := 77600.0

static func spawn_goa_scenery(terrain: IndianRoadTerrainV2, landmark_x_positions: Array[float]) -> void:
	var props_container: Node2D = terrain.props_container
	if not is_instance_valid(props_container):
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = 20261127

	# Load Goa v3 crisp 2D vector props
	var houses := _load_list([
		"res://assets/indian_locations/goa/v3/props/house_portuguese_ochre.png",
		"res://assets/indian_locations/goa/v3/props/house_portuguese_cobalt.png",
		"res://assets/indian_locations/goa/v3/props/house_portuguese_coral.png",
		"res://assets/indian_locations/goa/v3/props/house_laterite_heritage.png",
	])
	var palms := _load_list([
		"res://assets/indian_locations/goa/v3/props/tree_coconut_lean_right.png",
		"res://assets/indian_locations/goa/v3/props/tree_coconut_lean_left.png",
		"res://assets/indian_locations/goa/v3/props/tree_coconut_double.png",
	])
	var inland_trees := _load_list([
		"res://assets/indian_locations/goa/v3/props/tree_banyan_rain.png",
		"res://assets/indian_locations/goa/v3/props/tree_cashew_gulmohar.png",
	])
	var shrubs := _load_list([
		"res://assets/indian_locations/goa/v3/props/bush_hibiscus_cluster.png",
	])
	var coastal_props := _load_list([
		"res://assets/indian_locations/goa/v3/props/prop_beach_shack.png",
		"res://assets/indian_locations/goa/v3/props/prop_fishing_boat.png",
		"res://assets/indian_locations/goa/v3/props/prop_coastal_cliff_rock.png",
	])
	var heritage_props := _load_list([
		"res://assets/indian_locations/goa/v3/props/prop_pao_bakery.png",
		"res://assets/indian_locations/goa/v3/props/prop_stone_culvert.png",
	])
	var forest_props := _load_list([
		"res://assets/indian_locations/goa/v3/props/prop_coastal_cliff_rock.png",
		"res://assets/indian_locations/goa/v3/props/prop_stone_culvert.png",
	])
	var fg_verge := _load_list([
		"res://assets/indian_locations/goa/v3/foreground/fg_grass_flowers_1.png",
		"res://assets/indian_locations/goa/v3/foreground/fg_grass_ferns_2.png",
		"res://assets/indian_locations/goa/v3/foreground/fg_coastal_rocks_3.png",
	])

	var tex_sign_sb := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_speed_breaker.png")
	var tex_sign_curve := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_curve_ahead.png")
	var tex_barricade := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_barricade_yellow_black.png")
	var tex_cone := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_traffic_cone.png")

	var is_clear := func(check_x: float, min_gap: float = 1150.0) -> bool:
		for lx in landmark_x_positions:
			if absf(check_x - lx) < min_gap:
				return false
		if terrain.active_route != null:
			for wp in terrain.active_route.waypoints:
				if absf(check_x - wp.distance_m * 100.0) < min_gap:
					return false
		if check_x >= BRIDGE_START_X - 900.0 and check_x <= BRIDGE_END_X + 900.0:
			return false
		return true

	# Speed breaker warning signs & hazard zones
	if tex_sign_sb:
		for sb_x in terrain.speed_breaker_x_positions:
			var sign_x: float = sb_x - 5000.0
			if sign_x > 600.0 and is_clear.call(sign_x, 900.0):
				_add_sprite(props_container, tex_sign_sb, 90.0, sign_x, terrain.get_height_at(sign_x), -1)

	for hz_x in terrain.hazard_zone_x_positions:
		if is_clear.call(hz_x, 900.0):
			if tex_sign_curve and is_clear.call(hz_x - 2800.0, 700.0):
				_add_sprite(props_container, tex_sign_curve, 90.0, hz_x - 2800.0, terrain.get_height_at(hz_x - 2800.0), -1)
			if tex_cone:
				for cone_off: float in [-1400.0, -700.0, 700.0, 1400.0]:
					var cx: float = hz_x + cone_off
					if is_clear.call(cx, 300.0):
						_add_sprite(props_container, tex_cone, 30.0, cx, terrain.get_height_at(cx), -1)
			if tex_barricade:
				_add_sprite(props_container, tex_barricade, 52.0, hz_x, terrain.get_height_at(hz_x), -1)

	# Roadside environmental asset placement per Goa section (A -> B -> C -> D)
	var current_x := 650.0
	var last_house_idx := -1
	var last_palm_idx := -1
	var last_tree_idx := -1

	while current_x < terrain.total_length_px - 700.0:
		if not is_clear.call(current_x, 1100.0):
			current_x += 750.0
			continue

		var dist_m := current_x * 0.01
		var y := terrain.get_height_at(current_x)
		var roll := rng.randf()

		# Section A: North Goa (0-310m) -> Coastal palms, Portuguese villas, beach shacks, boats
		if dist_m < 310.0:
			if roll < 0.24 and not houses.is_empty():
				last_house_idx = _pick_non_repeat(rng, houses.size(), last_house_idx)
				var h_tex: Texture2D = houses[last_house_idx]
				var spr := _add_sprite(props_container, h_tex, rng.randf_range(155.0, 190.0), current_x, y, -3)
				if spr and rng.randf() < 0.4:
					spr.flip_h = true
				# Companion palm beside house for organic framing
				if not palms.is_empty():
					last_palm_idx = _pick_non_repeat(rng, palms.size(), last_palm_idx)
					_add_sprite(props_container, palms[last_palm_idx], rng.randf_range(210.0, 260.0), current_x + 150.0, terrain.get_height_at(current_x + 150.0), -2)
				current_x += rng.randf_range(1050.0, 1450.0)
			elif roll < 0.68 and not palms.is_empty():
				last_palm_idx = _pick_non_repeat(rng, palms.size(), last_palm_idx)
				var p_h := rng.randf_range(210.0, 275.0)
				_add_sprite(props_container, palms[last_palm_idx], p_h, current_x, y, -2)
				if rng.randf() < 0.55 and not shrubs.is_empty():
					_add_sprite(props_container, shrubs[0], rng.randf_range(62.0, 82.0), current_x + 78.0, terrain.get_height_at(current_x + 78.0), -1)
				current_x += rng.randf_range(760.0, 1180.0)
			else:
				var cp_tex: Texture2D = coastal_props[rng.randi() % coastal_props.size()]
				var cp_h := 115.0 if "shack" in cp_tex.resource_path else 72.0
				_add_sprite(props_container, cp_tex, cp_h, current_x, y, -1)
				current_x += rng.randf_range(850.0, 1200.0)

		# Section B: Central Goa (310-620m) -> Heritage houses, Pao stalls, rain trees, gulmohar
		elif dist_m < 620.0:
			if roll < 0.36 and not houses.is_empty():
				last_house_idx = _pick_non_repeat(rng, houses.size(), last_house_idx)
				var spr := _add_sprite(props_container, houses[last_house_idx], rng.randf_range(160.0, 200.0), current_x, y, -3)
				if spr and rng.randf() < 0.45:
					spr.flip_h = true
				if not shrubs.is_empty() and rng.randf() < 0.65:
					_add_sprite(props_container, shrubs[0], rng.randf_range(60.0, 78.0), current_x - 115.0, terrain.get_height_at(current_x - 115.0), -1)
				current_x += rng.randf_range(950.0, 1350.0)
			elif roll < 0.74 and not inland_trees.is_empty():
				last_tree_idx = _pick_non_repeat(rng, inland_trees.size(), last_tree_idx)
				_add_sprite(props_container, inland_trees[last_tree_idx], rng.randf_range(185.0, 235.0), current_x, y, -2)
				current_x += rng.randf_range(820.0, 1200.0)
			else:
				var hp_tex: Texture2D = heritage_props[rng.randi() % heritage_props.size()]
				var hp_h := 105.0 if "bakery" in hp_tex.resource_path else 56.0
				_add_sprite(props_container, hp_tex, hp_h, current_x, y, -1)
				current_x += rng.randf_range(800.0, 1150.0)

		# Section C: East Goa (620-900m) -> Dense Western Ghats forest trees, flowering trees, rocks, bridge
		elif dist_m < 900.0:
			if roll < 0.62 and not inland_trees.is_empty():
				last_tree_idx = _pick_non_repeat(rng, inland_trees.size(), last_tree_idx)
				var t_h := rng.randf_range(195.0, 255.0)
				_add_sprite(props_container, inland_trees[last_tree_idx], t_h, current_x, y, -2)
				if rng.randf() < 0.45 and not palms.is_empty():
					last_palm_idx = _pick_non_repeat(rng, palms.size(), last_palm_idx)
					_add_sprite(props_container, palms[last_palm_idx], rng.randf_range(200.0, 245.0), current_x + 125.0, terrain.get_height_at(current_x + 125.0), -3)
				current_x += rng.randf_range(700.0, 1080.0)
			elif roll < 0.85 and not shrubs.is_empty():
				_add_sprite(props_container, shrubs[0], rng.randf_range(68.0, 92.0), current_x, y, -1)
				current_x += rng.randf_range(620.0, 920.0)
			else:
				var fp_tex: Texture2D = forest_props[rng.randi() % forest_props.size()]
				_add_sprite(props_container, fp_tex, rng.randf_range(60.0, 82.0), current_x, y, -1)
				current_x += rng.randf_range(650.0, 950.0)

		# Section D: South Goa (900-1200m) -> Coconut plantations, coastal cliffs, beach shacks, fishing boats
		else:
			if roll < 0.56 and not palms.is_empty():
				last_palm_idx = _pick_non_repeat(rng, palms.size(), last_palm_idx)
				var p_h := rng.randf_range(215.0, 285.0)
				_add_sprite(props_container, palms[last_palm_idx], p_h, current_x, y, -2)
				if rng.randf() < 0.45:
					last_palm_idx = _pick_non_repeat(rng, palms.size(), last_palm_idx)
					_add_sprite(props_container, palms[last_palm_idx], p_h * 0.85, current_x + 115.0, terrain.get_height_at(current_x + 115.0), -2)
				current_x += rng.randf_range(800.0, 1180.0)
			elif roll < 0.84 and not coastal_props.is_empty():
				var cp_tex: Texture2D = coastal_props[rng.randi() % coastal_props.size()]
				var cp_h := 118.0 if "shack" in cp_tex.resource_path else 76.0
				_add_sprite(props_container, cp_tex, cp_h, current_x, y, -1)
				current_x += rng.randf_range(820.0, 1150.0)
			else:
				last_house_idx = _pick_non_repeat(rng, houses.size(), last_house_idx)
				_add_sprite(props_container, houses[last_house_idx], rng.randf_range(150.0, 180.0), current_x, y, -3)
				current_x += rng.randf_range(950.0, 1280.0)

	# Foreground roadside verge accents (grass tufts, wildflowers, small coastal rocks)
	# Positioned along the lower road verge (+21px below road top) at z_index=2 so they never block vehicle/wheels!
	if not fg_verge.is_empty():
		var fg_x := 320.0
		var last_fg := -1
		while fg_x < terrain.total_length_px - 300.0:
			if fg_x < BRIDGE_START_X - 100.0 or fg_x > BRIDGE_END_X + 100.0:
				last_fg = _pick_non_repeat(rng, fg_verge.size(), last_fg)
				var fg_tex: Texture2D = fg_verge[last_fg]
				var fy := terrain.get_height_at(fg_x) + 21.0
				var fg_h := rng.randf_range(38.0, 52.0)
				var spr := Sprite2D.new()
				spr.texture = fg_tex
				var th := float(fg_tex.get_height())
				if th > 0.0:
					var s := fg_h / th
					spr.scale = Vector2(s, s)
				spr.centered = true
				spr.flip_h = (rng.randf() < 0.5)
				spr.position = Vector2(fg_x, fy - fg_h * 0.25)
				spr.z_index = 2
				props_container.add_child(spr)
			fg_x += rng.randf_range(440.0, 760.0)

static func draw_goa_world(terrain: IndianRoadTerrainV2) -> void:
	var pts := terrain.road_points
	if pts.size() < 2:
		return

	var first_x := pts[0].x
	var last_x := pts[pts.size() - 1].x
	var bottom_y := terrain.base_y + terrain.bottom_depth

	# 1. Mollem Forest Ravine & Stream visible underneath the East Goa stone bridge (748m - 782m)
	var stream_y := terrain.base_y + 20.0
	var ravine_poly := PackedVector2Array([
		Vector2(BRIDGE_START_X - 100.0, terrain.base_y - 45.0),
		Vector2(BRIDGE_END_X + 100.0, terrain.base_y - 45.0),
		Vector2(BRIDGE_END_X + 100.0, stream_y + 4.0),
		Vector2(BRIDGE_START_X - 100.0, stream_y + 4.0)
	])
	terrain.draw_colored_polygon(ravine_poly, Color(0.14, 0.32, 0.22, 1.0))
	var stream_poly := PackedVector2Array([
		Vector2(BRIDGE_START_X - 80.0, stream_y),
		Vector2(BRIDGE_END_X + 80.0, stream_y),
		Vector2(BRIDGE_END_X + 80.0, bottom_y),
		Vector2(BRIDGE_START_X - 80.0, bottom_y)
	])
	terrain.draw_colored_polygon(stream_poly, Color(0.11, 0.52, 0.68, 1.0))
	var stream_top := PackedVector2Array([
		Vector2(BRIDGE_START_X - 80.0, stream_y),
		Vector2(BRIDGE_END_X + 80.0, stream_y),
		Vector2(BRIDGE_END_X + 80.0, stream_y + 24.0),
		Vector2(BRIDGE_START_X - 80.0, stream_y + 24.0)
	])
	terrain.draw_colored_polygon(stream_top, Color(0.20, 0.72, 0.84, 1.0))
	# Water highlight ripples
	for wx in range(int(BRIDGE_START_X) + 120, int(BRIDGE_END_X) - 120, 260):
		terrain.draw_line(Vector2(float(wx), stream_y + 10.0), Vector2(float(wx) + 95.0, stream_y + 10.0), Color(0.78, 0.96, 1.0, 0.75), 2.5, true)

	# 2. Split Earth Embankment around the Mollem Stream Bridge
	var pts_west := PackedVector2Array()
	var pts_east := PackedVector2Array()
	for pt in pts:
		if pt.x <= BRIDGE_START_X + 120.0:
			pts_west.append(pt)
		elif pt.x >= BRIDGE_END_X - 120.0:
			pts_east.append(pt)

	if pts_west.size() >= 2:
		_draw_goa_earth_strata(terrain, pts_west, first_x, pts_west[pts_west.size() - 1].x, bottom_y)
	if pts_east.size() >= 2:
		_draw_goa_earth_strata(terrain, pts_east, pts_east[0].x, last_x, bottom_y)

	# 3. Draw Stone Arch Bridge Piers & Parapet across 748m - 782m
	_draw_mollem_bridge_structure(terrain, stream_y, bottom_y)

	# 4. Graded Roadside Gravel Curb & Main Dark Textured Asphalt Road
	var curb_pts := _offset_pts(pts, 14.0)
	var asphalt_pts := _offset_pts(pts, 10.0)
	terrain.draw_polyline(curb_pts, Color(0.76, 0.70, 0.60, 1.0), 26.0, true)
	terrain.draw_polyline(asphalt_pts, terrain.road_surface_color, 20.0, true)
	terrain.draw_polyline(_offset_pts(pts, 4.0), terrain.road_surface_color.lightened(0.08), 5.0, true)

	# Visible lush coastal grass surface verge right along the outer road curb (+23px to +37px)
	var grass_top := _offset_pts(pts, 23.0)
	var poly_grass := PackedVector2Array()
	poly_grass.append_array(grass_top)
	for i in range(pts.size() - 1, -1, -1):
		var gw := 12.0 + sin(pts[i].x * 0.015) * 4.5
		poly_grass.append(Vector2(pts[i].x, pts[i].y + 23.0 + gw))
	terrain.draw_colored_polygon(poly_grass, Color(0.28, 0.58, 0.27, 1.0))
	terrain.draw_polyline(_offset_pts(pts, 24.5), Color(0.43, 0.75, 0.35, 1.0), 3.0, true)

	# 5. Reflective White Edge Stripes & Clean Dashed Center Lane Markings
	var cycle := 72.0
	var stripe_len := 42.0
	for i in range(pts.size() - 1):
		var p1 := pts[i]
		var p2 := pts[i + 1]
		var dir := (p2 - p1).normalized()
		var norm := Vector2(-dir.y, dir.x)
		# Crisp white top & bottom shoulder edges
		terrain.draw_line(p1 + norm * 1.5, p2 + norm * 1.5, Color(0.96, 0.96, 0.94, 0.88), 2.2, true)
		terrain.draw_line(p1 + norm * 19.5, p2 + norm * 19.5, Color(0.92, 0.92, 0.90, 0.80), 2.0, true)
		# Dashed center lane markings
		if fmod(absf(p1.x) + 100000.0, cycle) < stripe_len:
			terrain.draw_line(p1 + norm * 10.5, p2 + norm * 10.5, terrain.stripe_color, 2.8, true)

	# 6. Road Potholes & Speed Breakers
	for pt_x in terrain.pothole_x_positions:
		var py := terrain.get_height_at(pt_x)
		terrain.draw_circle(Vector2(pt_x, py + 8.0), 12.0, terrain.road_surface_color.darkened(0.5))
		terrain.draw_arc(Vector2(pt_x, py + 8.0), 12.0, 0.0, TAU, 12, Color(0.45, 0.48, 0.52, 0.6), 1.5)

	for sb_x in terrain.speed_breaker_x_positions:
		for off: float in [-16.0, -8.0, 0.0, 8.0, 16.0]:
			var px: float = sb_x + off
			var py := terrain.get_height_at(px)
			terrain.draw_line(Vector2(px, py + 1.0), Vector2(px, py + 19.0), Color(1.0, 0.86, 0.18, 0.95), 3.0)

static func _draw_goa_earth_strata(terrain: IndianRoadTerrainV2, pts: PackedVector2Array, start_x: float, end_x: float, bottom_y: float) -> void:
	# Deep bedrock (#4b2718)
	var poly_deep := PackedVector2Array()
	poly_deep.append_array(pts)
	poly_deep.append(Vector2(end_x, bottom_y))
	poly_deep.append(Vector2(start_x, bottom_y))
	terrain.draw_colored_polygon(poly_deep, Color(0.30, 0.16, 0.10, 1.0))

	# Mid weathered laterite subsoil (+48px to +175px)
	var poly_mid := PackedVector2Array()
	poly_mid.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		var wave := sin(pts[i].x * 0.0045) * 14.0
		poly_mid.append(Vector2(pts[i].x, minf(pts[i].y + 170.0 + wave, bottom_y)))
	terrain.draw_colored_polygon(poly_mid, Color(0.49, 0.26, 0.16, 1.0))

	# Upper topsoil / coastal sand (+16px to +62px, smoothly transitioning with terrain.shoulder_color)
	var poly_top := PackedVector2Array()
	poly_top.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		var wave := cos(pts[i].x * 0.0065) * 8.0
		poly_top.append(Vector2(pts[i].x, minf(pts[i].y + 62.0 + wave, bottom_y)))
	terrain.draw_colored_polygon(poly_top, terrain.shoulder_color)

	# Subsurface angular laterite stones & geological texture (eliminates any flat brown rectangle look!)
	var rock_step := 280.0
	var rx := ceilf(start_x / rock_step) * rock_step
	while rx < end_x - 100.0:
		var base_ry := terrain.get_height_at(rx)
		var seed_v := absf(sin(rx * 0.0173))
		var seed_v2 := absf(cos(rx * 0.0291))

		# Upper stratum irregular rock
		var r1_pos := Vector2(rx + seed_v * 80.0, base_ry + 88.0 + seed_v2 * 45.0)
		var r1_rad := 12.0 + seed_v * 11.0
		_draw_irregular_stone(terrain, r1_pos, r1_rad, Color(0.38, 0.19, 0.12, 0.90), Color(0.56, 0.30, 0.19, 0.75))

		# Deeper bedrock stone
		var r2_pos := Vector2(rx + 125.0 + seed_v2 * 95.0, base_ry + 215.0 + seed_v * 65.0)
		var r2_rad := 16.0 + seed_v2 * 14.0
		_draw_irregular_stone(terrain, r2_pos, r2_rad, Color(0.21, 0.11, 0.07, 0.88), Color(0.35, 0.19, 0.12, 0.65))

		rx += rock_step

static func _draw_irregular_stone(terrain: IndianRoadTerrainV2, center: Vector2, rad: float, dark_col: Color, light_col: Color) -> void:
	var stone_poly := PackedVector2Array([
		center + Vector2(-rad * 1.15, rad * 0.15),
		center + Vector2(-rad * 0.65, -rad * 0.68),
		center + Vector2(rad * 0.25, -rad * 0.82),
		center + Vector2(rad * 1.10, -rad * 0.22),
		center + Vector2(rad * 0.95, rad * 0.58),
		center + Vector2(-rad * 0.25, rad * 0.72)
	])
	terrain.draw_colored_polygon(stone_poly, dark_col)
	var facet_poly := PackedVector2Array([
		center + Vector2(-rad * 0.65, -rad * 0.58),
		center + Vector2(rad * 0.22, -rad * 0.72),
		center + Vector2(rad * 0.82, -rad * 0.18),
		center + Vector2(rad * 0.05, rad * 0.08)
	])
	terrain.draw_colored_polygon(facet_poly, light_col)

static func _draw_mollem_bridge_structure(terrain: IndianRoadTerrainV2, stream_y: float, bottom_y: float) -> void:
	# Stone laterite bridge piers standing in the stream
	var pier_xs := [BRIDGE_START_X + 320.0, BRIDGE_START_X + 1150.0, BRIDGE_START_X + 2050.0, BRIDGE_END_X - 320.0]
	for px in pier_xs:
		var py := terrain.get_height_at(px) + 18.0
		var pier := PackedVector2Array([
			Vector2(px - 36.0, py),
			Vector2(px + 36.0, py),
			Vector2(px + 48.0, bottom_y),
			Vector2(px - 48.0, bottom_y)
		])
		terrain.draw_colored_polygon(pier, Color(0.56, 0.31, 0.21, 1.0))
		terrain.draw_rect(Rect2(px - 42.0, stream_y - 6.0, 84.0, 12.0), Color(0.26, 0.45, 0.26, 0.7))

	# Under-deck stone arch girder line
	var deck_pts := PackedVector2Array()
	var x := BRIDGE_START_X
	while x <= BRIDGE_END_X:
		deck_pts.append(Vector2(x, terrain.get_height_at(x) + 24.0))
		x += 60.0
	if deck_pts.size() >= 2:
		terrain.draw_polyline(deck_pts, Color(0.52, 0.28, 0.19, 1.0), 14.0, true)
		terrain.draw_polyline(_offset_pts(deck_pts, -6.0), Color(0.76, 0.52, 0.36, 1.0), 3.0, true)

	# Low scenic stone bridge balustrade posts along the bridge deck (behind vehicle, at road back edge)
	var rail_pts := PackedVector2Array()
	var post_x := BRIDGE_START_X + 80.0
	while post_x <= BRIDGE_END_X - 80.0:
		var py := terrain.get_height_at(post_x)
		rail_pts.append(Vector2(post_x, py - 20.0))
		terrain.draw_rect(Rect2(post_x - 6.0, py - 24.0, 12.0, 24.0), Color(0.68, 0.36, 0.24, 1.0))
		terrain.draw_rect(Rect2(post_x - 8.0, py - 27.0, 16.0, 5.0), Color(0.86, 0.72, 0.54, 1.0))
		post_x += 220.0
	if rail_pts.size() >= 2:
		terrain.draw_polyline(rail_pts, Color(0.78, 0.52, 0.36, 0.9), 4.0, true)

static func _offset_pts(pts: PackedVector2Array, offset_y: float) -> PackedVector2Array:
	var res := PackedVector2Array()
	res.resize(pts.size())
	for i in range(pts.size()):
		res[i] = Vector2(pts[i].x, pts[i].y + offset_y)
	return res

static func _load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

static func _load_list(paths: Array[String]) -> Array[Texture2D]:
	var out: Array[Texture2D] = []
	for p in paths:
		var t := _load_tex(p)
		if t:
			out.append(t)
	return out

static func _pick_non_repeat(rng: RandomNumberGenerator, size: int, last_idx: int) -> int:
	if size <= 1:
		return 0
	var idx := rng.randi() % size
	if idx == last_idx:
		idx = (idx + 1) % size
	return idx

static func _add_sprite(parent: Node2D, tex: Texture2D, target_height: float, pos_x: float, road_y: float, z_idx: int) -> Sprite2D:
	if not tex:
		return null
	var spr := Sprite2D.new()
	spr.texture = tex
	var th := float(tex.get_height())
	if th > 0.0:
		var s := target_height / th
		spr.scale = Vector2(s, s)
	spr.centered = true
	spr.position = Vector2(pos_x, road_y - target_height * 0.5)
	spr.z_index = z_idx
	parent.add_child(spr)
	return spr
