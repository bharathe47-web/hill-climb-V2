class_name RajasthanTerrainHelper
extends RefCounted

## RajasthanTerrainHelper: Spatial-chunked Rajasthan desert road renderer,
## stratified Aravalli/Thar sandstone soil, windblown dust haze, and 5-zone roadside props.

const CHUNK_WIDTH := 4000.0
const MIN_WORLD_X := -1200.0

static var _soft_dust_tex: Texture2D = null

class RajasthanRoadChunk:
	extends Node2D
	var poly_deep: PackedVector2Array
	var poly_mid: PackedVector2Array
	var poly_top: PackedVector2Array
	var top_col: Color
	var mid_col: Color
	var deep_col: Color
	var poly_verge: PackedVector2Array
	var verge_top_line: PackedVector2Array
	var curb_pts: PackedVector2Array
	var asphalt_pts: PackedVector2Array
	var sheen_pts: PackedVector2Array
	var edge_top_pts: PackedVector2Array
	var edge_bot_pts: PackedVector2Array
	var dash_segments: PackedVector2Array
	var stones_dark: Array[PackedVector2Array] = []
	var stones_light: Array[PackedVector2Array] = []
	var potholes: PackedVector2Array = []
	var speed_breakers: Array[float] = []
	var terrain_ref: IndianRoadTerrainV2 = null

	func _draw() -> void:
		if poly_deep.size() >= 3:
			draw_colored_polygon(poly_deep, deep_col)
		if poly_mid.size() >= 3:
			draw_colored_polygon(poly_mid, mid_col)
		if poly_top.size() >= 3:
			draw_colored_polygon(poly_top, top_col)

		for i in range(stones_dark.size()):
			draw_colored_polygon(stones_dark[i], Color(0.42, 0.25, 0.14, 0.88))
			draw_colored_polygon(stones_light[i], Color(0.64, 0.42, 0.25, 0.72))

		# Dry golden-ochre desert sand verge along outer road curb (no green grass)
		if poly_verge.size() >= 3:
			draw_colored_polygon(poly_verge, Color(0.75, 0.56, 0.28, 1.0))
		if verge_top_line.size() >= 2:
			draw_polyline(verge_top_line, Color(0.88, 0.72, 0.40, 1.0), 3.0, true)

		if curb_pts.size() >= 2:
			draw_polyline(curb_pts, Color(0.78, 0.68, 0.50, 1.0), 26.0, true)
		if asphalt_pts.size() >= 2 and terrain_ref:
			draw_polyline(asphalt_pts, terrain_ref.road_surface_color, 20.0, true)
		if sheen_pts.size() >= 2 and terrain_ref:
			draw_polyline(sheen_pts, terrain_ref.road_surface_color.lightened(0.08), 5.0, true)

		if edge_top_pts.size() >= 2:
			draw_polyline(edge_top_pts, Color(0.96, 0.94, 0.88, 0.86), 2.2, true)
		if edge_bot_pts.size() >= 2:
			draw_polyline(edge_bot_pts, Color(0.92, 0.88, 0.78, 0.78), 2.0, true)
		if dash_segments.size() >= 2 and terrain_ref:
			draw_multiline(dash_segments, terrain_ref.stripe_color, 2.8, true)

		for pt in potholes:
			draw_circle(pt + Vector2(0.0, 8.0), 12.0, Color(0.11, 0.10, 0.09, 1.0))
			draw_arc(pt + Vector2(0.0, 8.0), 12.0, 0.0, TAU, 10, Color(0.55, 0.48, 0.38, 0.6), 1.5)

		if terrain_ref:
			for sb_x in speed_breakers:
				for off: float in [-16.0, -8.0, 0.0, 8.0, 16.0]:
					var px := sb_x + off
					var py := terrain_ref.get_height_at(px)
					draw_line(Vector2(px, py + 1.0), Vector2(px, py + 19.0), Color(1.0, 0.82, 0.18, 0.95), 3.0)

static func spawn_rajasthan_scenery(terrain: IndianRoadTerrainV2, landmark_x_positions: Array[float]) -> void:
	var props_container: Node2D = terrain.props_container
	if not is_instance_valid(props_container):
		return

	if is_instance_valid(terrain.road_canvas):
		for rc in terrain.road_canvas.get_children():
			rc.queue_free()

	var max_world_x := terrain.total_length_px + 1200.0
	var num_chunks := int(ceilf((max_world_x - MIN_WORLD_X) / CHUNK_WIDTH)) + 1
	var road_chunks: Array[RajasthanRoadChunk] = []
	var prop_chunks: Array[Node2D] = []

	for c in range(num_chunks):
		var c_min := MIN_WORLD_X + float(c) * CHUNK_WIDTH
		var c_max := c_min + CHUNK_WIDTH
		var rc := _build_road_chunk(terrain, c_min, c_max)
		terrain.road_canvas.add_child(rc)
		road_chunks.append(rc)

		var pc := Node2D.new()
		pc.name = "RajasthanPropChunk_%02d" % c
		props_container.add_child(pc)
		prop_chunks.append(pc)

	terrain.set_meta("_rj_road_chunks", road_chunks)
	terrain.set_meta("_rj_prop_chunks", prop_chunks)
	terrain.set_meta("_rj_last_chunk", -999)

	var get_prop_chunk := func(x: float) -> Node2D:
		var idx := clampi(int(floorf((x - MIN_WORLD_X) / CHUNK_WIDTH)), 0, prop_chunks.size() - 1)
		return prop_chunks[idx]

	var rng := RandomNumberGenerator.new()
	rng.seed = 20261128

	# Load Rajasthan v3 desert props + authentic regional buildings
	var haveli_pink := _load_tex("res://assets/indian_locations/rajasthan/v3/props/house_rj_pink_haveli.png")
	var bhunga_hut := _load_tex("res://assets/indian_locations/rajasthan/v3/props/house_rj_desert_bhunga.png")
	var house_jodhpur := _load_tex("res://assets/indian_locations/rajasthan/v3/props/house_rj_jodhpur_blue.png")
	var house_golden := _load_tex("res://assets/indian_locations/rajasthan/v3/props/house_rj_golden_haveli.png")
	var shop_chai := _load_tex("res://assets/indian_locations/rajasthan/v3/props/shop_rj_chai_dhaba.png")

	var tree_khejri := _load_tex("res://assets/indian_locations/rajasthan/v3/props/tree_rj_khejri.png")
	var tree_acacia := _load_tex("res://assets/indian_locations/rajasthan/v3/props/tree_rj_acacia.png")
	var tree_palm := _load_tex("res://assets/indian_locations/rajasthan/v3/props/tree_rj_date_palm.png")
	var bush_thorn := _load_tex("res://assets/indian_locations/rajasthan/v3/props/bush_rj_thorn_scrub.png")
	var bush_grass := _load_tex("res://assets/indian_locations/rajasthan/v3/props/bush_rj_dry_grass.png")
	var wall_sandstone := _load_tex("res://assets/indian_locations/rajasthan/v3/props/prop_rj_sandstone_wall.png")
	var prop_camel := _load_tex("res://assets/indian_locations/rajasthan/v3/props/prop_rj_camel.png")

	var fg_verge := _load_list([
		"res://assets/indian_locations/rajasthan/v3/foreground/fg_rj_dry_scrub_1.png",
		"res://assets/indian_locations/rajasthan/v3/foreground/fg_rj_sandstone_rocks_2.png",
	])

	var tex_sign_sb := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_speed_breaker.png")
	var tex_sign_curve := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_curve_ahead.png")
	var tex_barricade := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_barricade_yellow_black.png")
	var tex_cone := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_traffic_cone.png")

	var is_clear := func(check_x: float, min_gap: float = 1250.0) -> bool:
		for lx in landmark_x_positions:
			if absf(check_x - lx) < min_gap:
				return false
		if terrain.active_route != null:
			for wp in terrain.active_route.waypoints:
				if absf(check_x - wp.distance_m * 100.0) < min_gap:
					return false
		return true

	# Speed breaker warning signs & desert hazard zones
	if tex_sign_sb:
		for sb_x in terrain.speed_breaker_x_positions:
			var sign_x: float = sb_x - 4200.0
			if sign_x > 650.0 and is_clear.call(sign_x, 900.0):
				_add_sprite(get_prop_chunk.call(sign_x), tex_sign_sb, 86.0, sign_x, terrain.get_height_at(sign_x), -1)

	for hz_x in terrain.hazard_zone_x_positions:
		if is_clear.call(hz_x, 900.0):
			if tex_sign_curve and is_clear.call(hz_x - 2400.0, 700.0):
				var sx: float = hz_x - 2400.0
				_add_sprite(get_prop_chunk.call(sx), tex_sign_curve, 86.0, sx, terrain.get_height_at(sx), -1)
			if tex_cone:
				for cone_off: float in [-1200.0, -600.0, 600.0, 1200.0]:
					var cx: float = hz_x + cone_off
					if is_clear.call(cx, 300.0):
						_add_sprite(get_prop_chunk.call(cx), tex_cone, 30.0, cx, terrain.get_height_at(cx), -1)
			if tex_barricade:
				_add_sprite(get_prop_chunk.call(hz_x), tex_barricade, 50.0, hz_x, terrain.get_height_at(hz_x), -1)

	# Roadside zone-authentic scenery across all 5 Rajasthan regions (0..1200m)
	var current_x := 700.0
	while current_x < terrain.total_length_px - 750.0:
		if not is_clear.call(current_x, 1250.0):
			current_x += 700.0
			continue

		var dist_m := current_x * 0.01
		var y := terrain.get_height_at(current_x)
		var roll := rng.randf()
		var parent_chunk: Node2D = get_prop_chunk.call(current_x)

		# Zone 1: Jaipur Heritage (0 - 240m) -> Pink havelis, sandstone walls, Khejri trees
		if dist_m < 240.0:
			if roll < 0.36 and haveli_pink:
				_add_sprite(parent_chunk, haveli_pink, rng.randf_range(150.0, 180.0), current_x, y, -3)
				if wall_sandstone:
					_add_sprite(get_prop_chunk.call(current_x + 140.0), wall_sandstone, 54.0, current_x + 140.0, terrain.get_height_at(current_x + 140.0), -1)
				current_x += rng.randf_range(1050.0, 1400.0)
			elif roll < 0.72 and tree_khejri:
				_add_sprite(parent_chunk, tree_khejri, rng.randf_range(165.0, 205.0), current_x, y, -2)
				if bush_thorn:
					_add_sprite(get_prop_chunk.call(current_x + 90.0), bush_thorn, 52.0, current_x + 90.0, terrain.get_height_at(current_x + 90.0), -1)
				current_x += rng.randf_range(850.0, 1180.0)
			elif shop_chai:
				_add_sprite(parent_chunk, shop_chai, 96.0, current_x, y, -1)
				current_x += rng.randf_range(900.0, 1250.0)
			else:
				current_x += 900.0

		# Zone 2: Aravalli Outskirts (240 - 480m) -> Acacia, Khejri, stony scrub, walls
		elif dist_m < 480.0:
			if roll < 0.44 and tree_acacia:
				_add_sprite(parent_chunk, tree_acacia, rng.randf_range(155.0, 195.0), current_x, y, -2)
				if bush_grass:
					_add_sprite(get_prop_chunk.call(current_x - 85.0), bush_grass, 44.0, current_x - 85.0, terrain.get_height_at(current_x - 85.0), -1)
				current_x += rng.randf_range(840.0, 1180.0)
			elif roll < 0.76 and tree_khejri:
				_add_sprite(parent_chunk, tree_khejri, rng.randf_range(160.0, 198.0), current_x, y, -2)
				current_x += rng.randf_range(860.0, 1200.0)
			elif wall_sandstone:
				_add_sprite(parent_chunk, wall_sandstone, 56.0, current_x, y, -1)
				current_x += rng.randf_range(880.0, 1180.0)
			else:
				current_x += 900.0

		# Zone 3: Desert Heritage (480 - 720m) -> Bhunga huts, camels, date palms, thorn scrub
		elif dist_m < 720.0:
			if roll < 0.30 and bhunga_hut:
				_add_sprite(parent_chunk, bhunga_hut, rng.randf_range(135.0, 165.0), current_x, y, -3)
				if prop_camel and rng.randf() < 0.65:
					_add_sprite(get_prop_chunk.call(current_x + 135.0), prop_camel, 86.0, current_x + 135.0, terrain.get_height_at(current_x + 135.0), -2)
				current_x += rng.randf_range(1020.0, 1380.0)
			elif roll < 0.60 and tree_palm:
				_add_sprite(parent_chunk, tree_palm, rng.randf_range(185.0, 225.0), current_x, y, -2)
				if bush_grass:
					_add_sprite(get_prop_chunk.call(current_x + 82.0), bush_grass, 46.0, current_x + 82.0, terrain.get_height_at(current_x + 82.0), -1)
				current_x += rng.randf_range(860.0, 1200.0)
			elif roll < 0.82 and prop_camel:
				_add_sprite(parent_chunk, prop_camel, 88.0, current_x, y, -2)
				current_x += rng.randf_range(900.0, 1240.0)
			elif bush_thorn:
				_add_sprite(parent_chunk, bush_thorn, 56.0, current_x, y, -1)
				current_x += rng.randf_range(760.0, 1080.0)
			else:
				current_x += 880.0

		# Zone 4: Jodhpur Blue City (720 - 960m) -> Blue City houses, Acacia, chai dhaba
		elif dist_m < 960.0:
			if roll < 0.38 and house_jodhpur:
				_add_sprite(parent_chunk, house_jodhpur, rng.randf_range(145.0, 175.0), current_x, y, -3)
				if tree_acacia and rng.randf() < 0.55:
					_add_sprite(get_prop_chunk.call(current_x + 130.0), tree_acacia, 155.0, current_x + 130.0, terrain.get_height_at(current_x + 130.0), -2)
				current_x += rng.randf_range(980.0, 1340.0)
			elif roll < 0.76 and tree_acacia:
				_add_sprite(parent_chunk, tree_acacia, rng.randf_range(155.0, 190.0), current_x, y, -2)
				current_x += rng.randf_range(850.0, 1180.0)
			elif shop_chai:
				_add_sprite(parent_chunk, shop_chai, 96.0, current_x, y, -1)
				current_x += rng.randf_range(900.0, 1220.0)
			else:
				current_x += 900.0

		# Zone 5: Jaisalmer Golden City (960 - 1200m) -> Golden sandstone havelis, date palms, camels
		else:
			if roll < 0.36 and house_golden:
				_add_sprite(parent_chunk, house_golden, rng.randf_range(150.0, 180.0), current_x, y, -3)
				if tree_palm and rng.randf() < 0.60:
					_add_sprite(get_prop_chunk.call(current_x + 135.0), tree_palm, 195.0, current_x + 135.0, terrain.get_height_at(current_x + 135.0), -2)
				current_x += rng.randf_range(980.0, 1340.0)
			elif roll < 0.68 and tree_palm:
				_add_sprite(parent_chunk, tree_palm, rng.randf_range(185.0, 225.0), current_x, y, -2)
				current_x += rng.randf_range(850.0, 1180.0)
			elif prop_camel:
				_add_sprite(parent_chunk, prop_camel, 88.0, current_x, y, -2)
				current_x += rng.randf_range(900.0, 1240.0)
			else:
				current_x += 880.0

	# Highlight carved Osian Sandstone Temple Pillar in Zone 3 open stretch (~605m)
	var osian_pillar := _load_tex("res://assets/indian_locations/rajasthan/v3/landmarks/osian_temple_pillar.png")
	if osian_pillar:
		_add_sprite(get_prop_chunk.call(60500.0), osian_pillar, 195.0, 60500.0, terrain.get_height_at(60500.0), -2)

	# Subtle warm desert sand-dust particles inside Thar Desert & Jaisalmer chunks (active ONLY when visible!)
	for dx in range(49500, 118000, 6500):
		var dxf := float(dx)
		_spawn_desert_dust_haze(get_prop_chunk.call(dxf), dxf, terrain.get_height_at(dxf) - 70.0)

	# Foreground desert dry grass tufts & sandstone rocks along lower verge (z_index=2)
	if not fg_verge.is_empty():
		var fg_x := 420.0
		var last_fg := -1
		while fg_x < terrain.total_length_px - 320.0:
			last_fg = _pick_non_repeat(rng, fg_verge.size(), last_fg)
			var fg_tex: Texture2D = fg_verge[last_fg]
			var fy := terrain.get_height_at(fg_x) + 21.0
			var fg_h := rng.randf_range(36.0, 50.0)
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
			get_prop_chunk.call(fg_x).add_child(spr)
			fg_x += rng.randf_range(500.0, 820.0)

	update_visible_chunks(terrain, 0.0)

static func finalize_pickup_chunks(terrain: IndianRoadTerrainV2) -> void:
	if not terrain.has_meta("_rj_prop_chunks") or not is_instance_valid(terrain.props_container):
		return
	var prop_chunks: Array = terrain.get_meta("_rj_prop_chunks")
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

	terrain.set_meta("_rj_last_chunk", -999)
	update_visible_chunks(terrain, 0.0)

static func update_visible_chunks(terrain: IndianRoadTerrainV2, cam_x: float) -> void:
	if not terrain.has_meta("_rj_road_chunks"):
		return
	var road_chunks: Array = terrain.get_meta("_rj_road_chunks")
	var prop_chunks: Array = terrain.get_meta("_rj_prop_chunks")
	var num_chunks := road_chunks.size()
	if num_chunks == 0:
		return

	var center_chunk := clampi(int(floorf((cam_x - MIN_WORLD_X) / CHUNK_WIDTH)), 0, num_chunks - 1)
	var last_chunk := int(terrain.get_meta("_rj_last_chunk", -999))
	if center_chunk == last_chunk:
		return
	terrain.set_meta("_rj_last_chunk", center_chunk)

	var min_c := maxi(0, center_chunk - 1)
	var max_c := mini(num_chunks - 1, center_chunk + 1)

	for i in range(num_chunks):
		var active := (i >= min_c and i <= max_c)
		var rc: Node2D = road_chunks[i]
		if is_instance_valid(rc) and rc.visible != active:
			rc.visible = active
		var pc: Node2D = prop_chunks[i]
		if is_instance_valid(pc):
			if pc.visible != active:
				pc.visible = active
			var pmode := Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
			if pc.process_mode != pmode:
				pc.process_mode = pmode

static func draw_rajasthan_world(_terrain: IndianRoadTerrainV2) -> void:
	# Batched geometry lives inside spatial RajasthanRoadChunk nodes under RoadCanvas.
	pass

static func _build_road_chunk(terrain: IndianRoadTerrainV2, c_min: float, c_max: float) -> RajasthanRoadChunk:
	var rc := RajasthanRoadChunk.new()
	rc.name = "RajasthanRoadChunk_%d" % int(c_min)
	rc.terrain_ref = terrain

	var pts := PackedVector2Array()
	var step := 40.0
	var x := maxf(c_min, terrain.road_points[0].x if terrain.road_points.size() > 0 else c_min)
	var end_lim := minf(c_max + step, terrain.total_length_px + 1200.0)
	while x <= end_lim:
		pts.append(Vector2(x, terrain.get_height_at(x)))
		x += step
	if pts.size() < 2:
		return rc

	var mid_m := ((c_min + c_max) * 0.5) * 0.01
	rc.top_col = _zone_soil_color(mid_m)
	rc.mid_col = Color(0.62, 0.42, 0.24, 1.0)
	rc.deep_col = Color(0.39, 0.25, 0.14, 1.0)

	var bottom_y := terrain.base_y + terrain.bottom_depth
	var start_x := pts[0].x
	var last_x := pts[pts.size() - 1].x

	rc.poly_deep.append_array(pts)
	rc.poly_deep.append(Vector2(last_x, bottom_y))
	rc.poly_deep.append(Vector2(start_x, bottom_y))

	rc.poly_mid.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		var wave := sin(pts[i].x * 0.0045) * 14.0
		rc.poly_mid.append(Vector2(pts[i].x, minf(pts[i].y + 168.0 + wave, bottom_y)))

	rc.poly_top.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		var wave := cos(pts[i].x * 0.0065) * 8.0
		rc.poly_top.append(Vector2(pts[i].x, minf(pts[i].y + 62.0 + wave, bottom_y)))

	var rock_step := 315.0
	var rx := ceilf(start_x / rock_step) * rock_step
	while rx < last_x - 80.0:
		var base_ry := terrain.get_height_at(rx)
		var seed_v := absf(sin(rx * 0.0173))
		var seed_v2 := absf(cos(rx * 0.0291))
		_append_stone_pair(rc, Vector2(rx + seed_v * 80.0, base_ry + 88.0 + seed_v2 * 45.0), 12.0 + seed_v * 11.0)
		_append_stone_pair(rc, Vector2(rx + 125.0 + seed_v2 * 95.0, base_ry + 218.0 + seed_v * 65.0), 16.0 + seed_v2 * 14.0)
		rx += rock_step

	rc.poly_verge.append_array(_offset_pts(pts, 23.0))
	for i in range(pts.size() - 1, -1, -1):
		var vw := 13.0 + sin(pts[i].x * 0.015) * 4.5
		rc.poly_verge.append(Vector2(pts[i].x, pts[i].y + 23.0 + vw))
	rc.verge_top_line = _offset_pts(pts, 24.5)

	rc.curb_pts = _offset_pts(pts, 14.0)
	rc.asphalt_pts = _offset_pts(pts, 10.0)
	rc.sheen_pts = _offset_pts(pts, 4.0)
	rc.edge_top_pts = _offset_pts(pts, 1.5)
	rc.edge_bot_pts = _offset_pts(pts, 19.5)

	for i in range(pts.size() - 1):
		var p1 := pts[i]
		var p2 := pts[i + 1]
		if fmod(absf(p1.x) + 100000.0, 72.0) < 42.0:
			rc.dash_segments.append(Vector2(p1.x, p1.y + 10.5))
			rc.dash_segments.append(Vector2(p2.x, p2.y + 10.5))

	for pt_x in terrain.pothole_x_positions:
		if pt_x >= c_min and pt_x < c_max:
			rc.potholes.append(Vector2(pt_x, terrain.get_height_at(pt_x)))

	for sb_x in terrain.speed_breaker_x_positions:
		if sb_x >= c_min and sb_x < c_max:
			rc.speed_breakers.append(sb_x)

	return rc

static func _zone_soil_color(dist_m: float) -> Color:
	if dist_m < 240.0:
		return Color(0.80, 0.58, 0.38, 1.0) # Jaipur warm terracotta-sand
	elif dist_m < 480.0:
		return Color(0.73, 0.54, 0.34, 1.0) # Aravalli dry rocky soil
	elif dist_m < 720.0:
		return Color(0.87, 0.72, 0.42, 1.0) # Thar golden sand
	elif dist_m < 960.0:
		return Color(0.79, 0.62, 0.38, 1.0) # Marwar rocky ochre
	else:
		return Color(0.89, 0.72, 0.39, 1.0) # Jaisalmer golden sandstone dust

static func _append_stone_pair(rc: RajasthanRoadChunk, center: Vector2, rad: float) -> void:
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

static func _get_soft_dust_texture() -> Texture2D:
	if _soft_dust_tex != null:
		return _soft_dust_tex
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
	_soft_dust_tex = ImageTexture.create_from_image(img)
	return _soft_dust_tex

static func _spawn_desert_dust_haze(parent: Node2D, pos_x: float, pos_y: float) -> void:
	var dust := CPUParticles2D.new()
	dust.texture = _get_soft_dust_texture()
	dust.position = Vector2(pos_x, pos_y)
	dust.z_index = -1
	dust.amount = 10
	dust.lifetime = 3.0
	dust.preprocess = 1.4
	dust.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	dust.emission_rect_extents = Vector2(280.0, 44.0)
	dust.direction = Vector2(-1.0, -0.05)
	dust.spread = 18.0
	dust.initial_velocity_min = 16.0
	dust.initial_velocity_max = 32.0
	dust.gravity = Vector2.ZERO
	dust.scale_amount_min = 1.2
	dust.scale_amount_max = 2.4
	dust.color = Color(0.98, 0.86, 0.62, 0.18)
	parent.add_child(dust)

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
