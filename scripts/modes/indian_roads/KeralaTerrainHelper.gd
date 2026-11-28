class_name KeralaTerrainHelper
extends RefCounted

## KeralaTerrainHelper: High-performance spatial-chunked Kochi-to-Munnar road builder,
## batched earth/asphalt renderer, playable Periyar 10-arch Neriamangalam Bridge,
## soft waterfall mist & mountain fog, and O(1) active-window culling.

const BRIDGE_START_X := 66500.0
const BRIDGE_END_X := 74500.0
const CHUNK_WIDTH := 4000.0
const MIN_WORLD_X := -1200.0

static var _soft_mist_tex: Texture2D = null

class KeralaRoadChunk:
	extends Node2D
	var poly_deep: PackedVector2Array
	var poly_mid: PackedVector2Array
	var poly_top: PackedVector2Array
	var top_col: Color
	var mid_col: Color
	var deep_col: Color
	var poly_grass: PackedVector2Array
	var grass_top_line: PackedVector2Array
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
			draw_colored_polygon(stones_dark[i], Color(0.24, 0.14, 0.09, 0.88))
			draw_colored_polygon(stones_light[i], Color(0.43, 0.25, 0.16, 0.72))

		if poly_grass.size() >= 3:
			draw_colored_polygon(poly_grass, Color(0.22, 0.54, 0.25, 1.0))
		if grass_top_line.size() >= 2:
			draw_polyline(grass_top_line, Color(0.38, 0.72, 0.34, 1.0), 3.0, true)

		if curb_pts.size() >= 2:
			draw_polyline(curb_pts, Color(0.72, 0.68, 0.60, 1.0), 26.0, true)
		if asphalt_pts.size() >= 2 and terrain_ref:
			draw_polyline(asphalt_pts, terrain_ref.road_surface_color, 20.0, true)
		if sheen_pts.size() >= 2 and terrain_ref:
			draw_polyline(sheen_pts, terrain_ref.road_surface_color.lightened(0.09), 5.0, true)

		if edge_top_pts.size() >= 2:
			draw_polyline(edge_top_pts, Color(0.96, 0.96, 0.94, 0.88), 2.2, true)
		if edge_bot_pts.size() >= 2:
			draw_polyline(edge_bot_pts, Color(0.92, 0.92, 0.90, 0.80), 2.0, true)
		if dash_segments.size() >= 2 and terrain_ref:
			draw_multiline(dash_segments, terrain_ref.stripe_color, 2.8, true)

		for pt in potholes:
			draw_circle(pt + Vector2(0.0, 8.0), 12.0, Color(0.08, 0.09, 0.10, 1.0))
			draw_arc(pt + Vector2(0.0, 8.0), 12.0, 0.0, TAU, 10, Color(0.45, 0.48, 0.52, 0.6), 1.5)

		if terrain_ref:
			for sb_x in speed_breakers:
				for off: float in [-16.0, -8.0, 0.0, 8.0, 16.0]:
					var px := sb_x + off
					var py := terrain_ref.get_height_at(px)
					draw_line(Vector2(px, py + 1.0), Vector2(px, py + 19.0), Color(1.0, 0.86, 0.18, 0.95), 3.0)

class KeralaBridgeCanvas:
	extends Node2D
	var terrain_ref: IndianRoadTerrainV2 = null

	func _draw() -> void:
		if terrain_ref == null:
			return
		var t := terrain_ref
		var bottom_y := t.base_y + t.bottom_depth
		var stream_y := t.base_y + 52.0

		# Periyar forest ravine & lush banks behind arches
		var ravine_poly := PackedVector2Array([
			Vector2(BRIDGE_START_X - 240.0, t.base_y - 56.0),
			Vector2(BRIDGE_END_X + 240.0, t.base_y - 56.0),
			Vector2(BRIDGE_END_X + 240.0, stream_y + 8.0),
			Vector2(BRIDGE_START_X - 240.0, stream_y + 8.0)
		])
		draw_colored_polygon(ravine_poly, Color(0.11, 0.29, 0.20, 1.0))

		var west_bank := PackedVector2Array([
			Vector2(BRIDGE_START_X - 220.0, t.base_y - 30.0),
			Vector2(BRIDGE_START_X + 680.0, stream_y + 10.0),
			Vector2(BRIDGE_START_X + 680.0, bottom_y),
			Vector2(BRIDGE_START_X - 220.0, bottom_y)
		])
		draw_colored_polygon(west_bank, Color(0.16, 0.38, 0.22, 1.0))
		var east_bank := PackedVector2Array([
			Vector2(BRIDGE_END_X - 680.0, stream_y + 10.0),
			Vector2(BRIDGE_END_X + 220.0, t.base_y - 30.0),
			Vector2(BRIDGE_END_X + 220.0, bottom_y),
			Vector2(BRIDGE_END_X - 680.0, bottom_y)
		])
		draw_colored_polygon(east_bank, Color(0.16, 0.38, 0.22, 1.0))

		var river_poly := PackedVector2Array([
			Vector2(BRIDGE_START_X - 60.0, stream_y),
			Vector2(BRIDGE_END_X + 60.0, stream_y),
			Vector2(BRIDGE_END_X + 60.0, bottom_y),
			Vector2(BRIDGE_START_X - 60.0, bottom_y)
		])
		draw_colored_polygon(river_poly, Color(0.08, 0.41, 0.49, 1.0))
		var river_surface := PackedVector2Array([
			Vector2(BRIDGE_START_X - 60.0, stream_y),
			Vector2(BRIDGE_END_X + 60.0, stream_y),
			Vector2(BRIDGE_END_X + 60.0, stream_y + 28.0),
			Vector2(BRIDGE_START_X - 60.0, stream_y + 28.0)
		])
		draw_colored_polygon(river_surface, Color(0.16, 0.60, 0.66, 1.0))
		var ripple_lines := PackedVector2Array()
		for wx in range(int(BRIDGE_START_X) + 180, int(BRIDGE_END_X) - 180, 290):
			ripple_lines.append(Vector2(float(wx), stream_y + 11.0))
			ripple_lines.append(Vector2(float(wx) + 115.0, stream_y + 11.0))
		if ripple_lines.size() >= 2:
			draw_multiline(ripple_lines, Color(0.76, 0.96, 0.98, 0.72), 2.5, true)

		# Historic 1935 Neriamangalam 10-Arch Stone & Concrete Structure
		var span_start := BRIDGE_START_X + 200.0
		var span_end := BRIDGE_END_X - 200.0
		var num_arches := 10
		var span_w := (span_end - span_start) / float(num_arches)

		var col_masonry := Color(0.60, 0.56, 0.49, 1.0)
		var col_masonry_dark := Color(0.42, 0.39, 0.34, 1.0)
		var col_arch_ring := Color(0.76, 0.71, 0.62, 1.0)
		var col_parapet := Color(0.84, 0.81, 0.74, 1.0)
		var col_parapet_cap := Color(0.55, 0.50, 0.44, 1.0)

		for p_i in range(num_arches + 1):
			var px := span_start + float(p_i) * span_w
			var deck_y := t.get_height_at(px) + 18.0
			draw_colored_polygon(PackedVector2Array([
				Vector2(px - 44.0, deck_y), Vector2(px + 44.0, deck_y),
				Vector2(px + 58.0, bottom_y), Vector2(px - 58.0, bottom_y)
			]), col_masonry_dark)
			draw_colored_polygon(PackedVector2Array([
				Vector2(px - 26.0, deck_y + 10.0), Vector2(px + 26.0, deck_y + 10.0),
				Vector2(px + 34.0, bottom_y), Vector2(px - 34.0, bottom_y)
			]), col_masonry)
			draw_rect(Rect2(px - 54.0, stream_y - 6.0, 108.0, 11.0), Color(0.76, 0.94, 0.96, 0.55))

		for a_i in range(num_arches):
			var ax0 := span_start + float(a_i) * span_w + 40.0
			var ax1 := span_start + float(a_i + 1) * span_w - 40.0
			var arch_mid_x := (ax0 + ax1) * 0.5
			var half_w := (ax1 - ax0) * 0.5
			var crown_y := t.get_height_at(arch_mid_x) + 32.0
			var spring_y := stream_y - 8.0

			var spandrel := PackedVector2Array()
			var arc_pts := PackedVector2Array()
			var steps := 12
			for s in range(steps + 1):
				var sx := lerpf(ax0 - 6.0, ax1 + 6.0, float(s) / float(steps))
				spandrel.append(Vector2(sx, t.get_height_at(sx) + 18.0))
			for s in range(steps, -1, -1):
				var sx := lerpf(ax0, ax1, float(s) / float(steps))
				var nx := (sx - arch_mid_x) / maxf(half_w, 1.0)
				var curve := sqrt(maxf(0.0, 1.0 - nx * nx))
				var ay := lerpf(spring_y, crown_y, curve)
				spandrel.append(Vector2(sx, ay))
				arc_pts.append(Vector2(sx, ay))
			draw_colored_polygon(spandrel, col_masonry)
			if arc_pts.size() >= 2:
				draw_polyline(arc_pts, col_arch_ring, 9.0, true)

		# Deck road, coping cornice, white lines, yellow dashes, parapets over bridge
		var bridge_pts := PackedVector2Array()
		var edge_t := PackedVector2Array()
		var edge_b := PackedVector2Array()
		var dashes := PackedVector2Array()
		var cornice := PackedVector2Array()
		var bx := BRIDGE_START_X - 40.0
		while bx <= BRIDGE_END_X + 40.0:
			var by := t.get_height_at(bx)
			bridge_pts.append(Vector2(bx, by))
			edge_t.append(Vector2(bx, by + 1.5))
			edge_b.append(Vector2(bx, by + 19.5))
			cornice.append(Vector2(bx, by + 21.0))
			bx += 40.0
		for i in range(bridge_pts.size() - 1):
			var p1 := bridge_pts[i]
			if fmod(absf(p1.x) + 100000.0, 72.0) < 42.0:
				dashes.append(Vector2(p1.x, p1.y + 10.5))
				dashes.append(Vector2(bridge_pts[i + 1].x, bridge_pts[i + 1].y + 10.5))

		draw_polyline(cornice, col_parapet_cap, 8.0, true)
		var top_rail := PackedVector2Array()
		var mid_rail := PackedVector2Array()
		var rx := BRIDGE_START_X + 60.0
		while rx <= BRIDGE_END_X - 60.0:
			var ry := t.get_height_at(rx)
			top_rail.append(Vector2(rx, ry - 24.0))
			mid_rail.append(Vector2(rx, ry - 12.0))
			var is_major := absf(fmod(rx - span_start, span_w)) < 110.0
			var pw := 16.0 if is_major else 10.0
			var ph := 32.0 if is_major else 26.0
			draw_rect(Rect2(rx - pw * 0.5, ry - ph, pw, ph), col_parapet)
			draw_rect(Rect2(rx - pw * 0.65, ry - ph - 4.0, pw * 1.3, 5.0), col_parapet_cap)
			rx += 190.0
		if top_rail.size() >= 2:
			draw_polyline(top_rail, col_parapet, 4.5, true)
			draw_polyline(mid_rail, col_parapet_cap, 3.0, true)

		draw_polyline(KeralaTerrainHelper._offset_pts(bridge_pts, 14.0), Color(0.72, 0.68, 0.60, 1.0), 26.0, true)
		draw_polyline(KeralaTerrainHelper._offset_pts(bridge_pts, 10.0), t.road_surface_color, 20.0, true)
		draw_polyline(KeralaTerrainHelper._offset_pts(bridge_pts, 4.0), t.road_surface_color.lightened(0.09), 5.0, true)
		draw_polyline(edge_t, Color(0.96, 0.96, 0.94, 0.88), 2.2, true)
		draw_polyline(edge_b, Color(0.92, 0.92, 0.90, 0.80), 2.0, true)
		if dashes.size() >= 2:
			draw_multiline(dashes, t.stripe_color, 2.8, true)

static func spawn_kerala_scenery(terrain: IndianRoadTerrainV2, landmark_x_positions: Array[float]) -> void:
	var props_container: Node2D = terrain.props_container
	if not is_instance_valid(props_container):
		return

	# Clean any previous chunks on rebuild
	if is_instance_valid(terrain.road_canvas):
		for rc in terrain.road_canvas.get_children():
			rc.queue_free()

	# Build spatial road & prop chunks across [MIN_WORLD_X .. total_length_px + 1200]
	var max_world_x := terrain.total_length_px + 1200.0
	var num_chunks := int(ceilf((max_world_x - MIN_WORLD_X) / CHUNK_WIDTH)) + 1
	var road_chunks: Array[KeralaRoadChunk] = []
	var prop_chunks: Array[Node2D] = []

	for c in range(num_chunks):
		var c_min := MIN_WORLD_X + float(c) * CHUNK_WIDTH
		var c_max := c_min + CHUNK_WIDTH

		var rc := _build_road_chunk(terrain, c_min, c_max)
		terrain.road_canvas.add_child(rc)
		road_chunks.append(rc)

		var pc := Node2D.new()
		pc.name = "KeralaPropChunk_%02d" % c
		props_container.add_child(pc)
		prop_chunks.append(pc)

	var bridge_canvas := KeralaBridgeCanvas.new()
	bridge_canvas.name = "NeriamangalamBridgeCanvas"
	bridge_canvas.terrain_ref = terrain
	terrain.road_canvas.add_child(bridge_canvas)

	terrain.set_meta("_kerala_road_chunks", road_chunks)
	terrain.set_meta("_kerala_prop_chunks", prop_chunks)
	terrain.set_meta("_kerala_bridge_canvas", bridge_canvas)
	terrain.set_meta("_kerala_last_chunk", -999)

	var get_prop_chunk := func(x: float) -> Node2D:
		var idx := clampi(int(floorf((x - MIN_WORLD_X) / CHUNK_WIDTH)), 0, prop_chunks.size() - 1)
		return prop_chunks[idx]

	var rng := RandomNumberGenerator.new()
	rng.seed = 20261129

	var coconuts := _load_list([
		"res://assets/indian_locations/kerala/v3/props/tree_kerala_coconut_1.png",
		"res://assets/indian_locations/kerala/v3/props/tree_kerala_coconut_2.png",
	])
	var rubber_tex := _load_tex("res://assets/indian_locations/kerala/v3/props/tree_kerala_rubber.png")
	var banana_tex := _load_tex("res://assets/indian_locations/kerala/v3/props/tree_kerala_banana.png")
	var bamboo_tex := _load_tex("res://assets/indian_locations/kerala/v3/props/tree_kerala_bamboo.png")
	var eucalyptus_tex := _load_tex("res://assets/indian_locations/kerala/v3/props/tree_kerala_eucalyptus.png")
	var tea_bush_tex := _load_tex("res://assets/indian_locations/kerala/v3/props/bush_kerala_tea_row.png")
	var house_tharavadu := _load_tex("res://assets/indian_locations/kerala/v3/props/house_kerala_tharavadu.png")
	var house_cottage := _load_tex("res://assets/indian_locations/kerala/v3/props/house_tea_estate_cottage.png")
	var shop_chips := _load_tex("res://assets/indian_locations/kerala/v3/props/shop_kerala_banana_chips.png")

	var fg_verge := _load_list([
		"res://assets/indian_locations/kerala/v3/foreground/fg_kerala_ferns_1.png",
		"res://assets/indian_locations/kerala/v3/foreground/fg_kerala_rocks_2.png",
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
		if check_x >= BRIDGE_START_X - 1050.0 and check_x <= BRIDGE_END_X + 1050.0:
			return false
		return true

	# Speed breaker warning signs & ghat hairpin caution barricades
	if tex_sign_sb:
		for sb_x in terrain.speed_breaker_x_positions:
			var sign_x: float = sb_x - 4500.0
			if sign_x > 650.0 and is_clear.call(sign_x, 900.0):
				_add_sprite(get_prop_chunk.call(sign_x), tex_sign_sb, 88.0, sign_x, terrain.get_height_at(sign_x), -1)

	for hz_x in terrain.hazard_zone_x_positions:
		if is_clear.call(hz_x, 900.0):
			if tex_sign_curve and is_clear.call(hz_x - 2600.0, 700.0):
				var sx: float = hz_x - 2600.0
				_add_sprite(get_prop_chunk.call(sx), tex_sign_curve, 88.0, sx, terrain.get_height_at(sx), -1)
			if tex_cone:
				for cone_off: float in [-1300.0, -650.0, 650.0, 1300.0]:
					var cx: float = hz_x + cone_off
					if is_clear.call(cx, 300.0):
						_add_sprite(get_prop_chunk.call(cx), tex_cone, 30.0, cx, terrain.get_height_at(cx), -1)
			if tex_barricade:
				_add_sprite(get_prop_chunk.call(hz_x), tex_barricade, 50.0, hz_x, terrain.get_height_at(hz_x), -1)

	# Structured non-repetitive scenery placed directly into spatial chunks
	var current_x := 650.0
	var last_palm_idx := -1

	while current_x < terrain.total_length_px - 750.0:
		if not is_clear.call(current_x, 1100.0):
			current_x += 700.0
			continue

		var dist_m := current_x * 0.01
		var y := terrain.get_height_at(current_x)
		var roll := rng.randf()
		var parent_chunk: Node2D = get_prop_chunk.call(current_x)

		# 1. Kochi (0 - 200m): Coconut groves & banana clumps (no village clutter next to city landmarks)
		if dist_m < 200.0:
			if roll < 0.78 and not coconuts.is_empty():
				last_palm_idx = _pick_non_repeat(rng, coconuts.size(), last_palm_idx)
				_add_sprite(parent_chunk, coconuts[last_palm_idx], rng.randf_range(215.0, 275.0), current_x, y, -2)
				if banana_tex and rng.randf() < 0.55:
					_add_sprite(get_prop_chunk.call(current_x + 92.0), banana_tex, rng.randf_range(100.0, 128.0), current_x + 92.0, terrain.get_height_at(current_x + 92.0), -1)
				current_x += rng.randf_range(820.0, 1180.0)
			elif banana_tex:
				_add_sprite(parent_chunk, banana_tex, rng.randf_range(110.0, 138.0), current_x, y, -1)
				current_x += rng.randf_range(780.0, 1100.0)
			else:
				current_x += 900.0

		# 2. Muvattupuzha (200 - 400m): Rubber plantations, banana groves, Tharavadu village, chips stall
		elif dist_m < 400.0:
			if roll < 0.36 and rubber_tex:
				var r_spr := _add_sprite(parent_chunk, rubber_tex, rng.randf_range(200.0, 245.0), current_x, y, -2)
				if r_spr and rng.randf() < 0.5:
					r_spr.flip_h = true
				if rng.randf() < 0.45:
					_add_sprite(get_prop_chunk.call(current_x + 165.0), rubber_tex, rng.randf_range(185.0, 225.0), current_x + 165.0, terrain.get_height_at(current_x + 165.0), -3)
				current_x += rng.randf_range(850.0, 1180.0)
			elif roll < 0.58 and house_tharavadu:
				_add_sprite(parent_chunk, house_tharavadu, rng.randf_range(155.0, 185.0), current_x, y, -3)
				if banana_tex:
					_add_sprite(get_prop_chunk.call(current_x - 120.0), banana_tex, rng.randf_range(105.0, 132.0), current_x - 120.0, terrain.get_height_at(current_x - 120.0), -1)
				current_x += rng.randf_range(1020.0, 1360.0)
			elif roll < 0.78 and not coconuts.is_empty():
				last_palm_idx = _pick_non_repeat(rng, coconuts.size(), last_palm_idx)
				_add_sprite(parent_chunk, coconuts[last_palm_idx], rng.randf_range(205.0, 255.0), current_x, y, -2)
				current_x += rng.randf_range(820.0, 1140.0)
			elif shop_chips and rng.randf() < 0.45:
				_add_sprite(parent_chunk, shop_chips, 112.0, current_x, y, -1)
				current_x += rng.randf_range(950.0, 1280.0)
			elif banana_tex:
				_add_sprite(parent_chunk, banana_tex, rng.randf_range(112.0, 140.0), current_x, y, -1)
				current_x += rng.randf_range(760.0, 1080.0)
			else:
				current_x += 900.0

		# 3. Kothamangalam & 4. Neriamangalam (400 - 800m): Tropical forests, bamboo clusters, rubber/rain trees
		elif dist_m < 800.0:
			if roll < 0.48 and bamboo_tex:
				var b_spr := _add_sprite(parent_chunk, bamboo_tex, rng.randf_range(200.0, 255.0), current_x, y, -2)
				if b_spr and rng.randf() < 0.5:
					b_spr.flip_h = true
				current_x += rng.randf_range(740.0, 1060.0)
			elif roll < 0.80 and rubber_tex:
				_add_sprite(parent_chunk, rubber_tex, rng.randf_range(195.0, 240.0), current_x, y, -2)
				if banana_tex and rng.randf() < 0.4:
					_add_sprite(get_prop_chunk.call(current_x + 115.0), banana_tex, rng.randf_range(102.0, 125.0), current_x + 115.0, terrain.get_height_at(current_x + 115.0), -1)
				current_x += rng.randf_range(780.0, 1100.0)
			elif dist_m < 620.0 and house_tharavadu and rng.randf() < 0.45:
				_add_sprite(parent_chunk, house_tharavadu, 162.0, current_x, y, -3)
				current_x += rng.randf_range(980.0, 1300.0)
			elif not coconuts.is_empty():
				last_palm_idx = _pick_non_repeat(rng, coconuts.size(), last_palm_idx)
				_add_sprite(parent_chunk, coconuts[last_palm_idx], rng.randf_range(205.0, 248.0), current_x, y, -2)
				current_x += rng.randf_range(800.0, 1150.0)
			else:
				current_x += 850.0

		# 5 & 6. Valara & Cheeyappara Waterfalls Corridor (800 - 1200m): Evergreen forest, bamboo, wet rocks
		elif dist_m < 1200.0:
			if roll < 0.50 and bamboo_tex:
				_add_sprite(parent_chunk, bamboo_tex, rng.randf_range(205.0, 255.0), current_x, y, -2)
				if rubber_tex and rng.randf() < 0.45:
					_add_sprite(get_prop_chunk.call(current_x + 135.0), rubber_tex, rng.randf_range(190.0, 230.0), current_x + 135.0, terrain.get_height_at(current_x + 135.0), -3)
				current_x += rng.randf_range(720.0, 1020.0)
			elif roll < 0.85 and rubber_tex:
				_add_sprite(parent_chunk, rubber_tex, rng.randf_range(195.0, 240.0), current_x, y, -2)
				current_x += rng.randf_range(740.0, 1020.0)
			else:
				var rk_tex: Texture2D = fg_verge[1] if fg_verge.size() > 1 else null
				if rk_tex:
					_add_sprite(parent_chunk, rk_tex, rng.randf_range(65.0, 88.0), current_x, y, -1)
				current_x += rng.randf_range(700.0, 960.0)

		# 7. Adimali (1200 - 1400m): Spice & cardamom hills, cottages, banana & chips/spice stalls
		elif dist_m < 1400.0:
			if roll < 0.34 and rubber_tex:
				_add_sprite(parent_chunk, rubber_tex, rng.randf_range(195.0, 235.0), current_x, y, -2)
				if tea_bush_tex:
					_add_sprite(get_prop_chunk.call(current_x + 110.0), tea_bush_tex, rng.randf_range(68.0, 88.0), current_x + 110.0, terrain.get_height_at(current_x + 110.0), -1)
				current_x += rng.randf_range(820.0, 1140.0)
			elif roll < 0.60 and banana_tex:
				_add_sprite(parent_chunk, banana_tex, rng.randf_range(108.0, 134.0), current_x, y, -1)
				current_x += rng.randf_range(740.0, 1050.0)
			elif roll < 0.82 and house_cottage:
				_add_sprite(parent_chunk, house_cottage, rng.randf_range(148.0, 178.0), current_x, y, -3)
				current_x += rng.randf_range(950.0, 1280.0)
			elif shop_chips:
				_add_sprite(parent_chunk, shop_chips, 110.0, current_x, y, -1)
				current_x += rng.randf_range(920.0, 1240.0)
			else:
				current_x += 850.0

		# 8. Pallivasal & 9. Munnar (1400 - 1800m): Endless tea bushes, slender eucalyptus, estate cottages
		else:
			if roll < 0.56 and tea_bush_tex:
				var tb := _add_sprite(parent_chunk, tea_bush_tex, rng.randf_range(74.0, 96.0), current_x, y, -1)
				if tb and rng.randf() < 0.5:
					tb.flip_h = true
				_add_sprite(get_prop_chunk.call(current_x + 165.0), tea_bush_tex, rng.randf_range(66.0, 84.0), current_x + 165.0, terrain.get_height_at(current_x + 165.0), -2)
				if eucalyptus_tex and rng.randf() < 0.45:
					_add_sprite(get_prop_chunk.call(current_x + 90.0), eucalyptus_tex, rng.randf_range(220.0, 275.0), current_x + 90.0, terrain.get_height_at(current_x + 90.0), -3)
				current_x += rng.randf_range(680.0, 960.0)
			elif roll < 0.84 and eucalyptus_tex:
				var e_spr := _add_sprite(parent_chunk, eucalyptus_tex, rng.randf_range(225.0, 280.0), current_x, y, -2)
				if e_spr and rng.randf() < 0.5:
					e_spr.flip_h = true
				current_x += rng.randf_range(760.0, 1080.0)
			elif house_cottage:
				_add_sprite(parent_chunk, house_cottage, rng.randf_range(150.0, 180.0), current_x, y, -3)
				if tea_bush_tex:
					_add_sprite(get_prop_chunk.call(current_x - 135.0), tea_bush_tex, 74.0, current_x - 135.0, terrain.get_height_at(current_x - 135.0), -1)
				current_x += rng.randf_range(950.0, 1280.0)
			else:
				current_x += 800.0

	# Animated waterfall spray/mist particles inside Valara & Cheeyappara chunks
	_spawn_waterfall_mist(get_prop_chunk.call(89500.0), 89500.0, terrain.get_height_at(89500.0) - 55.0, 1.0)
	_spawn_waterfall_mist(get_prop_chunk.call(109500.0), 109500.0, terrain.get_height_at(109500.0) - 65.0, 1.25)

	# High-range Munnar drifting valley mist placed cleanly into Munnar/Pallivasal chunks
	for mx in range(143500, 177500, 4200):
		var mxf := float(mx)
		_spawn_mountain_mist_patch(get_prop_chunk.call(mxf), mxf, terrain.get_height_at(mxf) - 105.0)

	# Continuous sculpted tea plantation hedges along Pallivasal & Munnar roadsides
	if tea_bush_tex:
		var tx := 140500.0
		while tx < 178000.0:
			if is_clear.call(tx, 340.0):
				var ty := terrain.get_height_at(tx)
				var tb := _add_sprite(get_prop_chunk.call(tx), tea_bush_tex, rng.randf_range(68.0, 88.0), tx, ty, -1)
				if tb and rng.randf() < 0.5:
					tb.flip_h = true
			tx += rng.randf_range(210.0, 310.0)

	# Foreground roadside verge accents (ferns & wet rocks) placed in spatial chunks
	if not fg_verge.is_empty():
		var fg_x := 360.0
		var last_fg := -1
		while fg_x < terrain.total_length_px - 320.0:
			if fg_x < BRIDGE_START_X - 160.0 or fg_x > BRIDGE_END_X + 160.0:
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
				get_prop_chunk.call(fg_x).add_child(spr)
			fg_x += rng.randf_range(460.0, 760.0)

	# Activate initial window around start x=0
	update_visible_chunks(terrain, 0.0)

static func finalize_pickup_chunks(terrain: IndianRoadTerrainV2) -> void:
	if not terrain.has_meta("_kerala_prop_chunks") or not is_instance_valid(terrain.props_container):
		return
	var prop_chunks: Array = terrain.get_meta("_kerala_prop_chunks")
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

	# Refresh culling immediately so newly chunked coins/fuel offscreen disable their _process & visibility
	terrain.set_meta("_kerala_last_chunk", -999)
	update_visible_chunks(terrain, 0.0)

static func update_visible_chunks(terrain: IndianRoadTerrainV2, cam_x: float) -> void:
	if not terrain.has_meta("_kerala_road_chunks"):
		return
	var road_chunks: Array = terrain.get_meta("_kerala_road_chunks")
	var prop_chunks: Array = terrain.get_meta("_kerala_prop_chunks")
	var num_chunks := road_chunks.size()
	if num_chunks == 0:
		return

	var center_chunk := clampi(int(floorf((cam_x - MIN_WORLD_X) / CHUNK_WIDTH)), 0, num_chunks - 1)
	var last_chunk := int(terrain.get_meta("_kerala_last_chunk", -999))
	if center_chunk == last_chunk:
		return
	terrain.set_meta("_kerala_last_chunk", center_chunk)

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

	var bridge_canvas = terrain.get_meta("_kerala_bridge_canvas", null)
	if is_instance_valid(bridge_canvas):
		bridge_canvas.visible = (cam_x >= BRIDGE_START_X - 4500.0 and cam_x <= BRIDGE_END_X + 4500.0)

static func draw_kerala_world(_terrain: IndianRoadTerrainV2) -> void:
	# Road & bridge geometry for Kerala is pre-batched into spatial KeralaRoadChunk nodes
	# inside RoadCanvas so invisible segments cost zero draw calls or primitives per frame.
	pass

static func _build_road_chunk(terrain: IndianRoadTerrainV2, c_min: float, c_max: float) -> KeralaRoadChunk:
	var rc := KeralaRoadChunk.new()
	rc.name = "KeralaRoadChunk_%d" % int(c_min)
	rc.terrain_ref = terrain

	var pts := PackedVector2Array()
	var step := 40.0
	var x := maxf(c_min, terrain.road_points[0].x if terrain.road_points.size() > 0 else c_min)
	var end_lim := minf(c_max + step, terrain.total_length_px + 1200.0)
	while x <= end_lim:
		# Skip solid earth embankment directly inside Periyar open bridge span
		pts.append(Vector2(x, terrain.get_height_at(x)))
		x += step
	if pts.size() < 2:
		return rc

	var mid_m := ((c_min + c_max) * 0.5) * 0.01
	rc.top_col = _zone_soil_color(mid_m)
	rc.mid_col = Color(0.41, 0.23, 0.14, 1.0)
	rc.deep_col = Color(0.24, 0.14, 0.09, 1.0)

	var bottom_y := terrain.base_y + terrain.bottom_depth
	# Check if this chunk intersects the Periyar open span
	var earth_pts := PackedVector2Array()
	for pt in pts:
		if pt.x <= BRIDGE_START_X + 260.0 or pt.x >= BRIDGE_END_X - 260.0:
			earth_pts.append(pt)

	if earth_pts.size() >= 2 and (c_max <= BRIDGE_START_X + 280.0 or c_min >= BRIDGE_END_X - 280.0):
		var start_x := earth_pts[0].x
		var last_x := earth_pts[earth_pts.size() - 1].x
		rc.poly_deep.append_array(earth_pts)
		rc.poly_deep.append(Vector2(last_x, bottom_y))
		rc.poly_deep.append(Vector2(start_x, bottom_y))

		rc.poly_mid.append_array(earth_pts)
		for i in range(earth_pts.size() - 1, -1, -1):
			var wave := sin(earth_pts[i].x * 0.0045) * 14.0
			rc.poly_mid.append(Vector2(earth_pts[i].x, minf(earth_pts[i].y + 168.0 + wave, bottom_y)))

		rc.poly_top.append_array(earth_pts)
		for i in range(earth_pts.size() - 1, -1, -1):
			var wave := cos(earth_pts[i].x * 0.0065) * 8.0
			rc.poly_top.append(Vector2(earth_pts[i].x, minf(earth_pts[i].y + 62.0 + wave, bottom_y)))

		# Subsurface stones for this chunk
		var rock_step := 310.0
		var rx := ceilf(start_x / rock_step) * rock_step
		while rx < last_x - 80.0:
			if rx <= BRIDGE_START_X + 100.0 or rx >= BRIDGE_END_X - 100.0:
				var base_ry := terrain.get_height_at(rx)
				var seed_v := absf(sin(rx * 0.0173))
				var seed_v2 := absf(cos(rx * 0.0291))
				_append_stone_pair(rc, Vector2(rx + seed_v * 80.0, base_ry + 88.0 + seed_v2 * 45.0), 12.0 + seed_v * 11.0)
				_append_stone_pair(rc, Vector2(rx + 125.0 + seed_v2 * 95.0, base_ry + 218.0 + seed_v * 65.0), 16.0 + seed_v2 * 14.0)
			rx += rock_step

		rc.poly_grass.append_array(_offset_pts(earth_pts, 23.0))
		for i in range(earth_pts.size() - 1, -1, -1):
			var gw := 13.0 + sin(earth_pts[i].x * 0.015) * 4.5
			rc.poly_grass.append(Vector2(earth_pts[i].x, earth_pts[i].y + 23.0 + gw))
		rc.grass_top_line = _offset_pts(earth_pts, 24.5)
	else:
		# Split embankment approach chunks touching West or East abutments
		var west_pts := PackedVector2Array()
		var east_pts := PackedVector2Array()
		for pt in pts:
			if pt.x <= BRIDGE_START_X + 260.0:
				west_pts.append(pt)
			elif pt.x >= BRIDGE_END_X - 260.0:
				east_pts.append(pt)
		for seg in [west_pts, east_pts]:
			if seg.size() >= 2:
				rc.poly_deep.append_array(seg)
				rc.poly_deep.append(Vector2(seg[seg.size() - 1].x, bottom_y))
				rc.poly_deep.append(Vector2(seg[0].x, bottom_y))
				rc.poly_mid.append_array(seg)
				for i in range(seg.size() - 1, -1, -1):
					rc.poly_mid.append(Vector2(seg[i].x, minf(seg[i].y + 168.0, bottom_y)))
				rc.poly_top.append_array(seg)
				for i in range(seg.size() - 1, -1, -1):
					rc.poly_top.append(Vector2(seg[i].x, minf(seg[i].y + 62.0, bottom_y)))
				rc.poly_grass.append_array(_offset_pts(seg, 23.0))
				for i in range(seg.size() - 1, -1, -1):
					rc.poly_grass.append(Vector2(seg[i].x, seg[i].y + 36.0))
				rc.grass_top_line = _offset_pts(seg, 24.5)

	# Continuous road surface strips + batched edge polylines + batched center dashes
	var road_pts := PackedVector2Array()
	for pt in pts:
		if pt.x < BRIDGE_START_X or pt.x > BRIDGE_END_X:
			road_pts.append(pt)

	if road_pts.size() >= 2:
		rc.curb_pts = _offset_pts(road_pts, 14.0)
		rc.asphalt_pts = _offset_pts(road_pts, 10.0)
		rc.sheen_pts = _offset_pts(road_pts, 4.0)
		rc.edge_top_pts = _offset_pts(road_pts, 1.5)
		rc.edge_bot_pts = _offset_pts(road_pts, 19.5)
		for i in range(road_pts.size() - 1):
			var p1 := road_pts[i]
			var p2 := road_pts[i + 1]
			if absf(p2.x - p1.x) > step * 2.5:
				continue
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
	if dist_m < 200.0:
		return Color(0.84, 0.72, 0.48, 1.0)
	elif dist_m < 400.0:
		return Color(0.54, 0.34, 0.19, 1.0)
	elif dist_m < 600.0:
		return Color(0.45, 0.29, 0.16, 1.0)
	elif dist_m < 800.0:
		return Color(0.41, 0.27, 0.15, 1.0)
	elif dist_m < 1200.0:
		return Color(0.36, 0.25, 0.16, 1.0)
	elif dist_m < 1400.0:
		return Color(0.48, 0.30, 0.16, 1.0)
	elif dist_m < 1600.0:
		return Color(0.43, 0.29, 0.17, 1.0)
	else:
		return Color(0.38, 0.27, 0.17, 1.0)

static func _append_stone_pair(rc: KeralaRoadChunk, center: Vector2, rad: float) -> void:
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

static func _get_soft_mist_texture() -> Texture2D:
	if _soft_mist_tex != null:
		return _soft_mist_tex
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
	_soft_mist_tex = ImageTexture.create_from_image(img)
	return _soft_mist_tex

static func _spawn_waterfall_mist(parent: Node2D, pos_x: float, pos_y: float, scale_mult: float) -> void:
	var mist := CPUParticles2D.new()
	mist.texture = _get_soft_mist_texture()
	mist.position = Vector2(pos_x, pos_y)
	mist.z_index = -1
	mist.amount = int(round(18.0 * scale_mult))
	mist.lifetime = 1.65
	mist.preprocess = 1.0
	mist.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	mist.emission_rect_extents = Vector2(95.0 * scale_mult, 40.0 * scale_mult)
	mist.direction = Vector2(-0.15, -1.0)
	mist.spread = 58.0
	mist.initial_velocity_min = 18.0
	mist.initial_velocity_max = 46.0
	mist.gravity = Vector2(0.0, 12.0)
	mist.scale_amount_min = 0.7 * scale_mult
	mist.scale_amount_max = 1.5 * scale_mult
	mist.color = Color(0.94, 0.99, 1.0, 0.42)
	parent.add_child(mist)

static func _spawn_mountain_mist_patch(parent: Node2D, pos_x: float, pos_y: float) -> void:
	var fog := CPUParticles2D.new()
	fog.texture = _get_soft_mist_texture()
	fog.position = Vector2(pos_x, pos_y)
	fog.z_index = -1
	fog.amount = 10
	fog.lifetime = 3.2
	fog.preprocess = 1.5
	fog.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	fog.emission_rect_extents = Vector2(280.0, 48.0)
	fog.direction = Vector2(-1.0, -0.08)
	fog.spread = 22.0
	fog.initial_velocity_min = 14.0
	fog.initial_velocity_max = 28.0
	fog.gravity = Vector2.ZERO
	fog.scale_amount_min = 1.4
	fog.scale_amount_max = 2.6
	fog.color = Color(0.96, 0.99, 1.0, 0.20)
	parent.add_child(fog)

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
