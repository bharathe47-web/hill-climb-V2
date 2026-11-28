class_name TelanganaTerrainHelper
extends RefCounted

## TelanganaTerrainHelper: Spatial-chunked Hyderabad city road renderer,
## Deccan granite strata, Necklace Road lakefront cues, and 5-zone Hyderabad props.

const CHUNK_WIDTH := 4000.0
const MIN_WORLD_X := -1200.0

static var _soft_glow_tex: Texture2D = null

class TelanganaRoadChunk:
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
			draw_colored_polygon(stones_dark[i], Color(0.32, 0.28, 0.25, 0.88))
			draw_colored_polygon(stones_light[i], Color(0.52, 0.46, 0.42, 0.72))

		if poly_verge.size() >= 3:
			draw_colored_polygon(poly_verge, Color(0.56, 0.50, 0.43, 1.0))
		if verge_top_line.size() >= 2:
			draw_polyline(verge_top_line, Color(0.74, 0.68, 0.58, 1.0), 3.0, true)

		if curb_pts.size() >= 2:
			draw_polyline(curb_pts, Color(0.68, 0.64, 0.58, 1.0), 26.0, true)
		if asphalt_pts.size() >= 2 and terrain_ref:
			draw_polyline(asphalt_pts, terrain_ref.road_surface_color, 20.0, true)
		if sheen_pts.size() >= 2 and terrain_ref:
			draw_polyline(sheen_pts, terrain_ref.road_surface_color.lightened(0.09), 5.0, true)

		if edge_top_pts.size() >= 2:
			draw_polyline(edge_top_pts, Color(0.95, 0.94, 0.90, 0.88), 2.2, true)
		if edge_bot_pts.size() >= 2:
			draw_polyline(edge_bot_pts, Color(0.92, 0.90, 0.86, 0.78), 2.0, true)
		if dash_segments.size() >= 2 and terrain_ref:
			draw_multiline(dash_segments, terrain_ref.stripe_color, 2.8, true)

		for pt in potholes:
			draw_circle(pt + Vector2(0.0, 8.0), 12.0, Color(0.11, 0.11, 0.12, 1.0))
			draw_arc(pt + Vector2(0.0, 8.0), 12.0, 0.0, TAU, 10, Color(0.55, 0.52, 0.48, 0.6), 1.5)

		if terrain_ref:
			for sb_x in speed_breakers:
				for off: float in [-16.0, -8.0, 0.0, 8.0, 16.0]:
					var px := sb_x + off
					var py := terrain_ref.get_height_at(px)
					draw_line(Vector2(px, py + 1.0), Vector2(px, py + 19.0), Color(1.0, 0.82, 0.18, 0.95), 3.0)

static func spawn_telangana_scenery(terrain: IndianRoadTerrainV2, landmark_x_positions: Array[float]) -> void:
	var props_container: Node2D = terrain.props_container
	if not is_instance_valid(props_container):
		return

	if is_instance_valid(terrain.road_canvas):
		for rc in terrain.road_canvas.get_children():
			rc.queue_free()

	var max_world_x := terrain.total_length_px + 1200.0
	var num_chunks := int(ceilf((max_world_x - MIN_WORLD_X) / CHUNK_WIDTH)) + 1
	var road_chunks: Array[TelanganaRoadChunk] = []
	var prop_chunks: Array[Node2D] = []

	for c in range(num_chunks):
		var c_min := MIN_WORLD_X + float(c) * CHUNK_WIDTH
		var c_max := c_min + CHUNK_WIDTH
		var rc := _build_road_chunk(terrain, c_min, c_max)
		terrain.road_canvas.add_child(rc)
		road_chunks.append(rc)

		var pc := Node2D.new()
		pc.name = "HyderabadPropChunk_%02d" % c
		props_container.add_child(pc)
		prop_chunks.append(pc)

	terrain.set_meta("_tg_road_chunks", road_chunks)
	terrain.set_meta("_tg_prop_chunks", prop_chunks)
	terrain.set_meta("_tg_last_chunk", -999)

	var get_prop_chunk := func(x: float) -> Node2D:
		var idx := clampi(int(floorf((x - MIN_WORLD_X) / CHUNK_WIDTH)), 0, prop_chunks.size() - 1)
		return prop_chunks[idx]

	var rng := RandomNumberGenerator.new()
	rng.seed = 20261128

	# Load Hyderabad city props & flora
	var house_old := _load_tex("res://assets/indian_locations/telangana/v3/props/house_hyd_oldcity_haveli.png")
	var house_heritage := _load_tex("res://assets/indian_locations/telangana/v3/props/house_hyd_heritage_mansion.png")
	var shop_chai := _load_tex("res://assets/indian_locations/telangana/v3/props/shop_hyd_irani_chai.png")
	var gate_old := _load_tex("res://assets/indian_locations/telangana/v3/props/prop_hyd_oldcity_gate.png")
	var wall_golconda := _load_tex("res://assets/indian_locations/telangana/v3/props/prop_hyd_golconda_wall.png")
	var boulder_tor := _load_tex("res://assets/indian_locations/telangana/v3/props/prop_hyd_granite_tor.png")
	var lamp := _load_tex("res://assets/indian_locations/telangana/v3/props/prop_hyd_streetlight.png")
	var tree_gulmohar := _load_tex("res://assets/indian_locations/telangana/v3/props/tree_hyd_gulmohar.png")
	var tree_neem := _load_tex("res://assets/indian_locations/telangana/v3/props/tree_hyd_neem.png")
	var tree_palm := _load_tex("res://assets/indian_locations/telangana/v3/props/tree_hyd_palm.png")
	var bush_bougain := _load_tex("res://assets/indian_locations/telangana/v3/props/bush_hyd_bougainvillea.png")
	var bush_scrub := _load_tex("res://assets/indian_locations/telangana/v3/props/bush_hyd_scrub.png")
	var fg_verge := _load_tex("res://assets/indian_locations/telangana/v3/foreground/fg_hyd_road_verge.png")

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
				if absf(check_x - wp.distance_m * 100.0) < 1200.0:
					return false
		return true

	# Streetlights along Hussain Sagar & City Heritage boulevards + golden-hour motes
	var light_x := 23000.0
	while light_x < 68000.0:
		if is_clear.call(light_x, 750.0) and lamp:
			_add_sprite(get_prop_chunk.call(light_x), lamp, 128.0, light_x, terrain.get_height_at(light_x), -2)
		light_x += 3400.0

	for mote_m: float in [110.0, 360.0, 560.0, 770.0, 955.0]:
		var mx: float = mote_m * 100.0
		_spawn_golden_hour_motes(get_prop_chunk.call(mx), mx, terrain.get_height_at(mx) - 95.0)

	# Zone-specific Hyderabad urban & heritage architecture (placed strictly clear of landmarks)
	var cursor := 5200.0
	var last_bldg := -1
	while cursor < terrain.total_length_px - 3600.0:
		if is_clear.call(cursor, 1250.0):
			var d_m := cursor * 0.01
			var ry := terrain.get_height_at(cursor)
			var pool: Array[Texture2D] = []
			if d_m < 225.0:
				pool = [house_old, shop_chai, gate_old]
			elif d_m < 430.0:
				pool = [house_heritage, shop_chai, house_old]
			elif d_m < 685.0:
				pool = [shop_chai, house_heritage]
			else:
				pool = [wall_golconda, boulder_tor]

			if not pool.is_empty():
				last_bldg = _pick_non_repeat(rng, pool.size(), last_bldg)
				var btex := pool[last_bldg]
				var target_h := rng.randf_range(108.0, 142.0)
				if btex == wall_golconda or btex == boulder_tor:
					target_h = rng.randf_range(86.0, 118.0)
				var bspr := _add_sprite(get_prop_chunk.call(cursor), btex, target_h, cursor, ry, -4)
				if bspr and btex != shop_chai:
					bspr.flip_h = (rng.randf() < 0.45)

				if rng.randf() < 0.55 and tree_gulmohar and tree_neem:
					var tr := tree_palm if (d_m >= 430.0 and d_m < 685.0 and tree_palm) else (tree_gulmohar if rng.randf() < 0.55 else tree_neem)
					_add_sprite(get_prop_chunk.call(cursor), tr, rng.randf_range(122.0, 152.0), cursor + rng.randf_range(240.0, 320.0), terrain.get_height_at(cursor + 260.0), -3)

			cursor += rng.randf_range(3400.0, 4800.0)
		else:
			cursor += 750.0

	# Organic Hyderabad avenue trees & granite/bougainvillea clusters
	var veg_cursor := 3400.0
	while veg_cursor < terrain.total_length_px - 2200.0:
		if is_clear.call(veg_cursor, 1000.0):
			var d_m := veg_cursor * 0.01
			var vy := terrain.get_height_at(veg_cursor)
			if rng.randf() < 0.62:
				var tr := tree_palm if (d_m >= 430.0 and d_m < 685.0 and tree_palm) else (tree_gulmohar if rng.randf() < 0.55 else tree_neem)
				var ts := _add_sprite(get_prop_chunk.call(veg_cursor), tr, rng.randf_range(115.0, 152.0), veg_cursor, vy, -3)
				if ts:
					ts.flip_h = (rng.randf() < 0.5)
			else:
				var bs := bush_scrub if (d_m >= 685.0 and bush_scrub) else bush_bougain
				if bs:
					_add_sprite(get_prop_chunk.call(veg_cursor), bs, rng.randf_range(50.0, 72.0), veg_cursor, vy, -2)
		veg_cursor += rng.randf_range(1400.0, 2200.0)

	# Speed breaker warning signs & hazard barricades
	if tex_sign_sb:
		for sb_x in terrain.speed_breaker_x_positions:
			var sy := terrain.get_height_at(sb_x - 360.0)
			_add_sprite(get_prop_chunk.call(sb_x - 360.0), tex_sign_sb, 92.0, sb_x - 360.0, sy, -1)

	for hz_x in terrain.hazard_zone_x_positions:
		if tex_sign_curve:
			_add_sprite(get_prop_chunk.call(hz_x - 320.0), tex_sign_curve, 92.0, hz_x - 320.0, terrain.get_height_at(hz_x - 320.0), -1)
		if tex_barricade:
			_add_sprite(get_prop_chunk.call(hz_x), tex_barricade, 58.0, hz_x, terrain.get_height_at(hz_x), -2)
		if tex_cone:
			_add_sprite(get_prop_chunk.call(hz_x + 160.0), tex_cone, 40.0, hz_x + 160.0, terrain.get_height_at(hz_x + 160.0), 1)

	# Foreground urban verge clusters
	if fg_verge:
		var fg_x := 460.0
		while fg_x < terrain.total_length_px - 320.0:
			var fy := terrain.get_height_at(fg_x) + 21.0
			var fg_h := rng.randf_range(34.0, 46.0)
			var spr := Sprite2D.new()
			spr.texture = fg_verge
			var th := float(fg_verge.get_height())
			if th > 0.0:
				var s := fg_h / th
				spr.scale = Vector2(s, s)
			spr.centered = true
			spr.flip_h = (rng.randf() < 0.5)
			spr.position = Vector2(fg_x, fy - fg_h * 0.25)
			spr.z_index = 2
			get_prop_chunk.call(fg_x).add_child(spr)
			fg_x += rng.randf_range(580.0, 880.0)

	update_visible_chunks(terrain, 0.0)

static func finalize_pickup_chunks(terrain: IndianRoadTerrainV2) -> void:
	if not terrain.has_meta("_tg_prop_chunks") or not is_instance_valid(terrain.props_container):
		return
	var prop_chunks: Array = terrain.get_meta("_tg_prop_chunks")
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

	terrain.set_meta("_tg_last_chunk", -999)
	update_visible_chunks(terrain, 0.0)

static func update_visible_chunks(terrain: IndianRoadTerrainV2, cam_x: float) -> void:
	if not terrain.has_meta("_tg_road_chunks"):
		return
	var road_chunks: Array = terrain.get_meta("_tg_road_chunks")
	var prop_chunks: Array = terrain.get_meta("_tg_prop_chunks")
	var num_chunks := road_chunks.size()
	if num_chunks == 0:
		return

	var center_chunk := clampi(int(floorf((cam_x - MIN_WORLD_X) / CHUNK_WIDTH)), 0, num_chunks - 1)
	var last_chunk := int(terrain.get_meta("_tg_last_chunk", -999))
	if center_chunk == last_chunk:
		return
	terrain.set_meta("_tg_last_chunk", center_chunk)

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

static func draw_telangana_world(_terrain: IndianRoadTerrainV2) -> void:
	pass

static func _build_road_chunk(terrain: IndianRoadTerrainV2, c_min: float, c_max: float) -> TelanganaRoadChunk:
	var rc := TelanganaRoadChunk.new()
	rc.name = "TelanganaRoadChunk_%d" % int(c_min)
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
	rc.mid_col = Color(0.45, 0.39, 0.35, 1.0)
	rc.deep_col = Color(0.28, 0.24, 0.22, 1.0)

	var bottom_y := terrain.base_y + terrain.bottom_depth
	var start_x := pts[0].x
	var last_x := pts[pts.size() - 1].x

	rc.poly_deep.append_array(pts)
	rc.poly_deep.append(Vector2(last_x, bottom_y))
	rc.poly_deep.append(Vector2(start_x, bottom_y))

	rc.poly_mid.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		var wave := sin(pts[i].x * 0.0045) * 12.0
		rc.poly_mid.append(Vector2(pts[i].x, minf(pts[i].y + 168.0 + wave, bottom_y)))

	rc.poly_top.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		var wave := cos(pts[i].x * 0.0065) * 7.0
		rc.poly_top.append(Vector2(pts[i].x, minf(pts[i].y + 62.0 + wave, bottom_y)))

	var rock_step := 330.0
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
	if dist_m < 225.0:
		return Color(0.58, 0.50, 0.43, 1.0) # Old Hyderabad limestone & Deccan grit
	elif dist_m < 430.0:
		return Color(0.54, 0.48, 0.44, 1.0) # Urban granite shoulder
	elif dist_m < 685.0:
		return Color(0.50, 0.52, 0.54, 1.0) # Necklace Road lakeside embankment stone
	else:
		return Color(0.56, 0.46, 0.39, 1.0) # Golconda red-brown Deccan granite soil

static func _append_stone_pair(rc: TelanganaRoadChunk, center: Vector2, rad: float) -> void:
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

static func _spawn_golden_hour_motes(parent: Node2D, pos_x: float, pos_y: float) -> void:
	var motes := CPUParticles2D.new()
	motes.texture = _get_soft_glow_texture()
	motes.position = Vector2(pos_x, pos_y)
	motes.z_index = -1
	motes.amount = 8
	motes.lifetime = 3.2
	motes.preprocess = 1.2
	motes.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	motes.emission_rect_extents = Vector2(260.0, 42.0)
	motes.direction = Vector2(-1.0, -0.08)
	motes.spread = 22.0
	motes.initial_velocity_min = 10.0
	motes.initial_velocity_max = 22.0
	motes.gravity = Vector2.ZERO
	motes.scale_amount_min = 0.8
	motes.scale_amount_max = 1.6
	motes.color = Color(1.0, 0.88, 0.62, 0.16)
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
