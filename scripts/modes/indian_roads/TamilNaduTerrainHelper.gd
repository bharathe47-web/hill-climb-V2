class_name TamilNaduTerrainHelper
extends RefCounted

## TamilNaduTerrainHelper: Spatial-chunked Tamil Nadu road renderer & 6-zone regional props.
## Preserves the Kanyakumari Glass Bridge (25m..85m) unobstructed while baking zone-accurate soil
## strata (coastal sand -> red laterite -> terra-cotta -> Cauvery alluvial -> paddy silt -> urban)
## to eliminate runtime redraws and mobile stalls.

const CHUNK_WIDTH := 4000.0
const MIN_WORLD_X := -1200.0
const BRIDGE_MIN_X := 2500.0
const BRIDGE_MAX_X := 8500.0

static var _soft_glow_tex: Texture2D = null

class TamilNaduRoadChunk:
	extends Node2D
	var strips: Array[Dictionary] = []
	var stones_dark: Array[PackedVector2Array] = []
	var stones_light: Array[PackedVector2Array] = []
	var potholes: PackedVector2Array = []
	var speed_breakers: Array[float] = []
	var terrain_ref: IndianRoadTerrainV2 = null

	func _draw() -> void:
		for s in strips:
			var p_deep: PackedVector2Array = s["deep"]
			var p_mid: PackedVector2Array = s["mid"]
			var p_top: PackedVector2Array = s["top"]
			var p_verge: PackedVector2Array = s["verge"]
			var v_line: PackedVector2Array = s["verge_line"]
			var top_col: Color = s["top_col"]
			var mid_col: Color = s["mid_col"]
			var deep_col: Color = s["deep_col"]

			if p_deep.size() >= 3:
				draw_colored_polygon(p_deep, deep_col)
			if p_mid.size() >= 3:
				draw_colored_polygon(p_mid, mid_col)
			if p_top.size() >= 3:
				draw_colored_polygon(p_top, top_col)

			for i in range(stones_dark.size()):
				draw_colored_polygon(stones_dark[i], Color(0.32, 0.25, 0.20, 0.85))
				draw_colored_polygon(stones_light[i], Color(0.54, 0.44, 0.36, 0.70))

			if p_verge.size() >= 3:
				draw_colored_polygon(p_verge, top_col.lightened(0.08))
			if v_line.size() >= 2:
				draw_polyline(v_line, top_col.lightened(0.22), 2.8, true)

			var curb: PackedVector2Array = s["curb"]
			var asphalt: PackedVector2Array = s["asphalt"]
			var sheen: PackedVector2Array = s["sheen"]
			var edge_t: PackedVector2Array = s["edge_t"]
			var edge_b: PackedVector2Array = s["edge_b"]
			var dashes: PackedVector2Array = s["dashes"]

			if curb.size() >= 2:
				draw_polyline(curb, Color(0.62, 0.56, 0.48, 1.0), 26.0, true)
			if asphalt.size() >= 2 and terrain_ref:
				draw_polyline(asphalt, terrain_ref.road_surface_color, 20.0, true)
			if sheen.size() >= 2 and terrain_ref:
				draw_polyline(sheen, terrain_ref.road_surface_color.lightened(0.09), 5.0, true)
			if edge_t.size() >= 2:
				draw_polyline(edge_t, Color(0.95, 0.94, 0.90, 0.88), 2.2, true)
			if edge_b.size() >= 2:
				draw_polyline(edge_b, Color(0.92, 0.90, 0.86, 0.78), 2.0, true)
			if dashes.size() >= 2 and terrain_ref:
				draw_multiline(dashes, terrain_ref.stripe_color, 2.8, true)

		for pt in potholes:
			draw_circle(pt + Vector2(0.0, 8.0), 12.0, Color(0.11, 0.11, 0.12, 1.0))
			draw_arc(pt + Vector2(0.0, 8.0), 12.0, 0.0, TAU, 10, Color(0.55, 0.52, 0.48, 0.6), 1.5)

		if terrain_ref:
			for sb_x in speed_breakers:
				for off: float in [-16.0, -8.0, 0.0, 8.0, 16.0]:
					var px := sb_x + off
					var py := terrain_ref.get_height_at(px)
					draw_line(Vector2(px, py + 1.0), Vector2(px, py + 19.0), Color(1.0, 0.82, 0.18, 0.95), 3.0)

static func spawn_tamil_nadu_scenery(terrain: IndianRoadTerrainV2, landmark_x_positions: Array[float]) -> void:
	var props_container: Node2D = terrain.props_container
	if not is_instance_valid(props_container):
		return

	if is_instance_valid(terrain.road_canvas):
		for rc in terrain.road_canvas.get_children():
			rc.queue_free()

	var max_world_x := terrain.total_length_px + 1200.0
	var num_chunks := int(ceilf((max_world_x - MIN_WORLD_X) / CHUNK_WIDTH)) + 1
	var road_chunks: Array[TamilNaduRoadChunk] = []
	var prop_chunks: Array[Node2D] = []

	for c in range(num_chunks):
		var c_min := MIN_WORLD_X + float(c) * CHUNK_WIDTH
		var c_max := c_min + CHUNK_WIDTH
		var rc := _build_road_chunk(terrain, c_min, c_max)
		terrain.road_canvas.add_child(rc)
		road_chunks.append(rc)

		var pc := Node2D.new()
		pc.name = "TamilNaduPropChunk_%02d" % c
		props_container.add_child(pc)
		prop_chunks.append(pc)

	terrain.set_meta("_tn_road_chunks", road_chunks)
	terrain.set_meta("_tn_prop_chunks", prop_chunks)
	terrain.set_meta("_tn_last_chunk", -999)

	var get_prop_chunk := func(x: float) -> Node2D:
		var idx := clampi(int(floorf((x - MIN_WORLD_X) / CHUNK_WIDTH)), 0, prop_chunks.size() - 1)
		return prop_chunks[idx]

	var rng := RandomNumberGenerator.new()
	rng.seed = 20261129

	# Load regional South Indian buildings, shops, vegetation, and v3 props
	var h_cottage := _load_tex("res://assets/indian_locations/tamil_nadu/buildings/house_tamil_coastal_cottage.png")
	var h_thatched := _load_tex("res://assets/indian_locations/tamil_nadu/buildings/house_tamil_thatched_hut.png")
	var h_temple := _load_tex("res://assets/indian_locations/tamil_nadu/buildings/house_tamil_temple_residence.png")
	var h_chettinad := _load_tex("res://assets/indian_locations/tamil_nadu/buildings/house_tamil_chettinad_mansion.png")
	var h_agraharam := _load_tex("res://assets/indian_locations/tamil_nadu/buildings/house_tamil_agraharam.png")
	var h_modern := _load_tex("res://assets/indian_locations/tamil_nadu/buildings/house_tamil_modern_terrace.png")

	var s_tea := _load_tex("res://assets/indian_locations/tamil_nadu/shops/shop_tamil_tea_kadai.png")
	var s_potti := _load_tex("res://assets/indian_locations/tamil_nadu/shops/shop_tamil_potti_kadai.png")
	var s_flower := _load_tex("res://assets/indian_locations/tamil_nadu/shops/shop_tamil_flower_poo_kadai.png")
	var s_coconut := _load_tex("res://assets/indian_locations/tamil_nadu/shops/shop_tamil_tender_coconut_stall.png")

	var t_coconut := _load_tex("res://assets/indian_locations/tamil_nadu/vegetation/tree_tamil_coconut_curved.png")
	var t_palmyra := _load_tex("res://assets/indian_locations/tamil_nadu/vegetation/tree_tamil_palmyra_tall.png")
	var t_banana := _load_tex("res://assets/indian_locations/tamil_nadu/v3/props/prop_tn_banana_clump.png")
	var t_banyan := _load_tex("res://assets/indian_locations/tamil_nadu/vegetation/tree_tamil_banyan_sprawling.png")
	var t_neem := _load_tex("res://assets/indian_locations/tamil_nadu/vegetation/tree_tamil_neem_shade.png")
	var shrub_pink := _load_tex("res://assets/indian_locations/tamil_nadu/vegetation/shrub_tamil_bougainvillea_pink.png")

	var p_boats := _load_tex("res://assets/indian_locations/tamil_nadu/roadside_props/prop_tamil_boat_nets.png")
	var p_cart := _load_tex("res://assets/indian_locations/tamil_nadu/roadside_props/prop_tamil_bullock_cart.png")
	var p_kolam := _load_tex("res://assets/indian_locations/tamil_nadu/roadside_props/prop_tamil_kolam_welcome.png")
	var p_turbine := _load_tex("res://assets/indian_locations/tamil_nadu/v3/props/prop_tn_wind_turbine.png")
	var p_mandapam := _load_tex("res://assets/indian_locations/tamil_nadu/v3/props/prop_tn_mandapam.png")
	var p_signal := _load_tex("res://assets/indian_locations/tamil_nadu/v3/props/prop_tn_traffic_signal.png")

	var tex_sign_sb := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_speed_breaker.png")
	var tex_sign_curve := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_curve_ahead.png")
	var tex_barricade := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_barricade_yellow_black.png")
	var tex_cone := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_traffic_cone.png")

	var is_clear := func(check_x: float, min_gap: float = 1150.0) -> bool:
		if check_x >= BRIDGE_MIN_X - 400.0 and check_x <= BRIDGE_MAX_X + 400.0:
			return false
		for lx in landmark_x_positions:
			if absf(check_x - lx) < min_gap:
				return false
		if terrain.active_route != null:
			for wp in terrain.active_route.waypoints:
				if absf(check_x - wp.distance_m * 100.0) < 1200.0:
					return false
		return true

	# Ambient warm sunlight & sea-breeze dust motes (placed carefully per chunk)
	for mote_m: float in [95.0, 275.0, 480.0, 725.0, 915.0, 1110.0]:
		var mx: float = mote_m * 100.0
		_spawn_ambient_motes(get_prop_chunk.call(mx), mx, terrain.get_height_at(mx) - 90.0)

	# Road warning signs & hazard zones (excluding bridge & monument buffers)
	if tex_sign_sb:
		for sb_x in terrain.speed_breaker_x_positions:
			var sx := sb_x - 6500.0
			if sx > 600.0 and is_clear.call(sx, 950.0):
				_add_sprite(get_prop_chunk.call(sx), tex_sign_sb, 90.0, sx, terrain.get_height_at(sx), -1)

	for hz_x in terrain.hazard_zone_x_positions:
		if is_clear.call(hz_x, 950.0):
			if tex_sign_curve and is_clear.call(hz_x - 3200.0, 900.0):
				_add_sprite(get_prop_chunk.call(hz_x - 3200.0), tex_sign_curve, 90.0, hz_x - 3200.0, terrain.get_height_at(hz_x - 3200.0), -1)
			if tex_cone:
				for off: float in [-1600.0, -800.0, 800.0, 1600.0]:
					var cx: float = hz_x + off
					if is_clear.call(cx, 300.0):
						_add_sprite(get_prop_chunk.call(cx), tex_cone, 32.0, cx, terrain.get_height_at(cx), -1)
			if tex_barricade:
				_add_sprite(get_prop_chunk.call(hz_x), tex_barricade, 54.0, hz_x, terrain.get_height_at(hz_x), -1)

	# Populate distinct zone-by-zone Tamil architecture, trees, wind turbines & shops
	var cursor := 10800.0 # Safely inland after Kanyakumari Glass Bridge & Padmanabhapuram
	var last_bldg := -1
	var last_tree := -1
	while cursor < terrain.total_length_px - 3000.0:
		if not is_clear.call(cursor, 1200.0):
			cursor += 820.0
			continue

		var d_m := cursor * 0.01
		var ry := terrain.get_height_at(cursor)
		var chunk: Node2D = get_prop_chunk.call(cursor) as Node2D

		var bldg_pool: Array[Texture2D] = []
		var tree_pool: Array[Texture2D] = []
		var shop_pool: Array[Texture2D] = []
		var prop_pool: Array[Texture2D] = []

		if d_m < 160.0:
			# Zone 1: Kanyakumari Coast
			bldg_pool = [h_cottage, h_thatched]
			tree_pool = [t_coconut, t_banana, shrub_pink]
			shop_pool = [s_coconut, s_tea]
			prop_pool = [p_boats]
		elif d_m < 420.0:
			# Zone 2: Tirunelveli Countryside & Muppandal Wind Farms
			bldg_pool = [h_thatched, h_temple, p_turbine]
			tree_pool = [t_palmyra, t_neem, shrub_pink]
			shop_pool = [s_potti, s_tea]
			prop_pool = [p_cart]
		elif d_m < 625.0:
			# Zone 3: Madurai Heritage City
			bldg_pool = [h_chettinad, h_temple, p_mandapam]
			tree_pool = [t_banyan, t_coconut, t_neem]
			shop_pool = [s_flower, s_tea]
			prop_pool = [p_kolam]
		elif d_m < 785.0:
			# Zone 4: Trichy Heritage & Cauvery Basin
			bldg_pool = [h_temple, p_mandapam, h_agraharam]
			tree_pool = [t_banyan, t_coconut, t_banana]
			shop_pool = [s_flower, s_coconut]
			prop_pool = [p_cart, p_kolam]
		elif d_m < 1020.0:
			# Zone 5: Thanjavur Cultural Landscape & Paddy Canals
			bldg_pool = [h_agraharam, h_chettinad, h_thatched]
			tree_pool = [t_banana, t_coconut, t_neem]
			shop_pool = [s_coconut, s_tea]
			prop_pool = [p_cart, p_kolam]
		else:
			# Zone 6: Chennai Metropolitan Coast
			bldg_pool = [h_modern, h_chettinad]
			tree_pool = [t_coconut, shrub_pink, t_neem]
			shop_pool = [s_tea, s_flower]
			prop_pool = [p_signal, p_kolam]

		var roll := rng.randf()
		if roll < 0.34 and not bldg_pool.is_empty():
			last_bldg = _pick_non_repeat(rng, bldg_pool.size(), last_bldg)
			var btex := bldg_pool[last_bldg]
			var th := 185.0 if btex == p_turbine else (130.0 if btex == p_mandapam else rng.randf_range(128.0, 158.0))
			_add_sprite(chunk, btex, th, cursor, ry, -3)
			if not tree_pool.is_empty() and rng.randf() < 0.55:
				last_tree = _pick_non_repeat(rng, tree_pool.size(), last_tree)
				var tt := tree_pool[last_tree]
				var tx := cursor + rng.randf_range(140.0, 195.0)
				_add_sprite(get_prop_chunk.call(tx), tt, _tree_height(tt, rng), tx, terrain.get_height_at(tx), -2)
			cursor += rng.randf_range(760.0, 1080.0)
		elif roll < 0.74 and not tree_pool.is_empty():
			last_tree = _pick_non_repeat(rng, tree_pool.size(), last_tree)
			var ttex := tree_pool[last_tree]
			_add_sprite(chunk, ttex, _tree_height(ttex, rng), cursor, ry, -2)
			if rng.randf() < 0.40 and not prop_pool.is_empty():
				var pt := prop_pool[rng.randi() % prop_pool.size()]
				var p_h := 145.0 if pt == p_signal else (56.0 if pt == p_kolam else 78.0)
				_add_sprite(get_prop_chunk.call(cursor + 120.0), pt, p_h, cursor + 120.0, terrain.get_height_at(cursor + 120.0), -1)
			cursor += rng.randf_range(520.0, 780.0)
		elif not shop_pool.is_empty():
			var stex := shop_pool[rng.randi() % shop_pool.size()]
			_add_sprite(chunk, stex, rng.randf_range(88.0, 106.0), cursor, ry, -2)
			cursor += rng.randf_range(640.0, 920.0)
		else:
			cursor += 580.0

	# Extra coastal boats & palms just before Kanyakumari bridge (0m..24m)
	if is_clear.call(1350.0, 400.0):
		_add_sprite(get_prop_chunk.call(1350.0), p_boats, 68.0, 1350.0, terrain.get_height_at(1350.0), -2)
		_add_sprite(get_prop_chunk.call(1800.0), t_coconut, 175.0, 1800.0, terrain.get_height_at(1800.0), -2)

	update_visible_chunks(terrain, 0.0)

static func _tree_height(tex: Texture2D, rng: RandomNumberGenerator) -> float:
	if not tex:
		return 135.0
	var p := tex.resource_path.to_lower()
	if "palmyra" in p:
		return rng.randf_range(175.0, 210.0)
	if "coconut" in p or "banyan" in p:
		return rng.randf_range(155.0, 188.0)
	if "shrub" in p:
		return rng.randf_range(62.0, 78.0)
	return rng.randf_range(115.0, 145.0)

static func finalize_pickup_chunks(terrain: IndianRoadTerrainV2) -> void:
	if not terrain.has_meta("_tn_prop_chunks") or not is_instance_valid(terrain.props_container):
		return
	var prop_chunks: Array = terrain.get_meta("_tn_prop_chunks")
	if prop_chunks.is_empty():
		return

	var to_move: Array[Node2D] = []
	for child in terrain.props_container.get_children():
		if child is Coin or child is FuelPickup:
			to_move.append(child)

	for item in to_move:
		var idx := clampi(int(floorf((item.global_position.x - MIN_WORLD_X) / CHUNK_WIDTH)), 0, prop_chunks.size() - 1)
		var target_chunk: Node2D = prop_chunks[idx]
		var saved_pos := item.position
		terrain.props_container.remove_child(item)
		target_chunk.add_child(item)
		item.position = saved_pos

	terrain.set_meta("_tn_last_chunk", -999)
	update_visible_chunks(terrain, 0.0)

static func update_visible_chunks(terrain: IndianRoadTerrainV2, cam_x: float) -> void:
	if not is_instance_valid(terrain) or not terrain.has_meta("_tn_road_chunks"):
		return
	var road_chunks: Array = terrain.get_meta("_tn_road_chunks")
	var prop_chunks: Array = terrain.get_meta("_tn_prop_chunks")
	var num_chunks := road_chunks.size()
	if num_chunks == 0:
		return

	var center_chunk := clampi(int(floorf((cam_x - MIN_WORLD_X) / CHUNK_WIDTH)), 0, num_chunks - 1)
	var last_chunk := int(terrain.get_meta("_tn_last_chunk", -999))
	if center_chunk == last_chunk:
		return
	terrain.set_meta("_tn_last_chunk", center_chunk)

	var min_c := maxi(0, center_chunk - 1)
	var max_c := mini(num_chunks - 1, center_chunk + 1)

	for i in range(num_chunks):
		var active := (i >= min_c and i <= max_c)
		var rc: Node2D = road_chunks[i]
		if is_instance_valid(rc) and rc.visible != active:
			rc.visible = active
		var pc: Node2D = prop_chunks[i]
		if is_instance_valid(pc) and pc.visible != active:
			pc.visible = active

static func draw_tamil_nadu_world(_terrain: IndianRoadTerrainV2) -> void:
	# Rendered entirely via spatial-culled TamilNaduRoadChunk nodes under terrain.road_canvas
	pass

static func _build_road_chunk(terrain: IndianRoadTerrainV2, c_min: float, c_max: float) -> TamilNaduRoadChunk:
	var rc := TamilNaduRoadChunk.new()
	rc.terrain_ref = terrain

	# Collect contiguous non-bridge road segments inside this chunk
	var west_pts := PackedVector2Array()
	var east_pts := PackedVector2Array()
	for pt in terrain.road_points:
		if pt.x >= c_min - 60.0 and pt.x <= c_max + 60.0:
			if pt.x <= BRIDGE_MIN_X:
				west_pts.append(pt)
			elif pt.x >= BRIDGE_MAX_X:
				east_pts.append(pt)

	for pts in [west_pts, east_pts]:
		if pts.size() >= 2:
			rc.strips.append(_build_strip_dict(terrain, pts))

	# Rocks sampled sparsely across chunk
	var rock_step := 350.0
	var rx := ceilf(c_min / rock_step) * rock_step
	while rx < c_max - 80.0:
		if rx < BRIDGE_MIN_X or rx > BRIDGE_MAX_X:
			var base_ry := terrain.get_height_at(rx)
			var sv := absf(sin(rx * 0.0173))
			var sv2 := absf(cos(rx * 0.0291))
			_append_stone_pair(rc, Vector2(rx + sv * 80.0, base_ry + 90.0 + sv2 * 45.0), 12.0 + sv * 10.0)
			_append_stone_pair(rc, Vector2(rx + 130.0 + sv2 * 90.0, base_ry + 215.0 + sv * 60.0), 15.0 + sv2 * 13.0)
		rx += rock_step

	for pt_x in terrain.pothole_x_positions:
		if pt_x >= c_min and pt_x < c_max and (pt_x < BRIDGE_MIN_X or pt_x > BRIDGE_MAX_X):
			rc.potholes.append(Vector2(pt_x, terrain.get_height_at(pt_x)))

	for sb_x in terrain.speed_breaker_x_positions:
		if sb_x >= c_min and sb_x < c_max and (sb_x < BRIDGE_MIN_X or sb_x > BRIDGE_MAX_X):
			rc.speed_breakers.append(sb_x)

	return rc

static func _build_strip_dict(terrain: IndianRoadTerrainV2, pts: PackedVector2Array) -> Dictionary:
	var mid_m := ((pts[0].x + pts[pts.size() - 1].x) * 0.5) * 0.01
	var top_col := _zone_soil_color(mid_m)
	var mid_col := top_col.darkened(0.24)
	var deep_col := top_col.darkened(0.46)

	var bottom_y := terrain.base_y + terrain.bottom_depth
	var start_x := pts[0].x
	var last_x := pts[pts.size() - 1].x

	var poly_deep := PackedVector2Array()
	poly_deep.append_array(pts)
	poly_deep.append(Vector2(last_x, bottom_y))
	poly_deep.append(Vector2(start_x, bottom_y))

	var poly_mid := PackedVector2Array()
	poly_mid.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		poly_mid.append(Vector2(pts[i].x, minf(pts[i].y + 160.0 + sin(pts[i].x * 0.0045) * 12.0, bottom_y)))

	var poly_top := PackedVector2Array()
	poly_top.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		poly_top.append(Vector2(pts[i].x, minf(pts[i].y + 56.0 + cos(pts[i].x * 0.0065) * 7.0, bottom_y)))

	var poly_verge := PackedVector2Array()
	poly_verge.append_array(_offset_pts(pts, 23.0))
	for i in range(pts.size() - 1, -1, -1):
		poly_verge.append(Vector2(pts[i].x, pts[i].y + 23.0 + 12.0 + sin(pts[i].x * 0.015) * 4.0))

	var dashes := PackedVector2Array()
	for i in range(pts.size() - 1):
		var p1 := pts[i]
		var p2 := pts[i + 1]
		if fmod(absf(p1.x) + 100000.0, 72.0) < 42.0:
			dashes.append(Vector2(p1.x, p1.y + 10.5))
			dashes.append(Vector2(p2.x, p2.y + 10.5))

	return {
		"deep": poly_deep,
		"mid": poly_mid,
		"top": poly_top,
		"top_col": top_col,
		"mid_col": mid_col,
		"deep_col": deep_col,
		"verge": poly_verge,
		"verge_line": _offset_pts(pts, 24.5),
		"curb": _offset_pts(pts, 14.0),
		"asphalt": _offset_pts(pts, 10.0),
		"sheen": _offset_pts(pts, 4.0),
		"edge_t": _offset_pts(pts, 1.5),
		"edge_b": _offset_pts(pts, 19.5),
		"dashes": dashes,
	}

static func _zone_soil_color(dist_m: float) -> Color:
	if dist_m < 160.0:
		return Color(0.84, 0.72, 0.50, 1.0) # Zone 1: Kanyakumari golden coastal sand
	elif dist_m < 420.0:
		return Color(0.72, 0.36, 0.22, 1.0) # Zone 2: Tirunelveli red laterite soil
	elif dist_m < 625.0:
		return Color(0.64, 0.45, 0.32, 1.0) # Zone 3: Madurai warm terra-cotta heritage earth
	elif dist_m < 785.0:
		return Color(0.50, 0.47, 0.36, 1.0) # Zone 4: Trichy Cauvery alluvial silt
	elif dist_m < 1020.0:
		return Color(0.56, 0.56, 0.30, 1.0) # Zone 5: Thanjavur fertile paddy loam
	else:
		return Color(0.42, 0.41, 0.43, 1.0) # Zone 6: Chennai urban coastal shoulder

static func _append_stone_pair(rc: TamilNaduRoadChunk, center: Vector2, rad: float) -> void:
	rc.stones_dark.append(PackedVector2Array([
		center + Vector2(-rad * 1.15, rad * 0.15),
		center + Vector2(-rad * 0.65, -rad * 0.68),
		center + Vector2(rad * 0.25, -rad * 0.82),
		center + Vector2(rad * 1.10, -rad * 0.22),
		center + Vector2(rad * 0.95, rad * 0.58),
		center + Vector2(-rad * 0.25, rad * 0.72)
	]))
	rc.stones_light.append(PackedVector2Array([
		center + Vector2(-rad * 0.65, -rad * 0.58),
		center + Vector2(rad * 0.22, -rad * 0.72),
		center + Vector2(rad * 0.82, -rad * 0.18),
		center + Vector2(rad * 0.05, rad * 0.08)
	]))

static func _get_soft_glow_texture() -> Texture2D:
	if _soft_glow_tex != null:
		return _soft_glow_tex
	var size := 32
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var half := float(size - 1) * 0.5
	for y in range(size):
		for x in range(size):
			var dx := (float(x) - half) / half
			var dy := (float(y) - half) / half
			var dist := sqrt(dx * dx + dy * dy)
			var alpha := clampf(1.0 - dist, 0.0, 1.0)
			alpha = alpha * alpha * (3.0 - 2.0 * alpha)
			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	_soft_glow_tex = ImageTexture.create_from_image(img)
	return _soft_glow_tex

static func _spawn_ambient_motes(parent: Node2D, pos_x: float, pos_y: float) -> void:
	var motes := CPUParticles2D.new()
	motes.texture = _get_soft_glow_texture()
	motes.position = Vector2(pos_x, pos_y)
	motes.z_index = -1
	motes.amount = 8
	motes.lifetime = 3.4
	motes.preprocess = 1.2
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = Vector2(260.0, 42.0)
	motes.direction = Vector2(-1.0, -0.06)
	motes.spread = 20.0
	motes.initial_velocity_min = 10.0
	motes.initial_velocity_max = 22.0
	motes.gravity = Vector2.ZERO
	motes.scale_amount_min = 0.8
	motes.scale_amount_max = 1.5
	motes.color = Color(1.0, 0.90, 0.65, 0.16)
	parent.add_child(motes)

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

static func _pick_non_repeat(rng: RandomNumberGenerator, size: int, last_idx: int) -> int:
	if size <= 1:
		return 0
	var idx := rng.randi() % size
	if idx == last_idx:
		idx = (idx + 1) % size
	return idx

static func _add_sprite(parent: Node2D, tex: Texture2D, target_height: float, pos_x: float, road_y: float, z_idx: int) -> Sprite2D:
	if not tex or not is_instance_valid(parent):
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
	parent.add_child(spr)
	return spr
