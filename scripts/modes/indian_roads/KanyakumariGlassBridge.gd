class_name KanyakumariGlassBridge
extends Node2D

## KanyakumariGlassBridge: High-definition playable glass bridge spanning the Indian Ocean.
## Connects mainland Kanyakumari across the sea between Vivekananda Rock Memorial and
## Thiruvalluvar Statue with continuous physics road collision, translucent cyan glass deck,
## deep ocean water beneath, structural steel piers, and 3D layered front/rear safety balustrades.

@export var bridge_start_x: float = 2500.0 # 25m
@export var bridge_ramp_end_x: float = 3500.0 # 35m
@export var bridge_deck_end_x: float = 7500.0 # 75m
@export var bridge_end_x: float = 8500.0 # 85m

@export var vivekananda_island_x: float = 4000.0 # 40m (matching LOC-TN-02 Vivekananda Rock Memorial)
@export var thiruvalluvar_island_x: float = 7000.0 # 70m (matching LOC-TN-01 Thiruvalluvar Statue)

# Color Palette
var ocean_deep_color := Color(0.04, 0.16, 0.28, 1.0)
var ocean_surface_color := Color(0.10, 0.46, 0.60, 0.95)
var ocean_wave_color := Color(0.80, 0.95, 1.0, 0.60)
var glass_panel_color := Color(0.32, 0.86, 0.94, 0.68)
var glass_glint_color := Color(0.92, 0.98, 1.0, 0.80)
var steel_pylon_color := Color(0.68, 0.72, 0.76, 1.0)
var steel_box_girder_color := Color(0.22, 0.26, 0.32, 0.95) # Dark maritime structural box girder
var steel_truss_color := Color(0.36, 0.42, 0.50, 0.95) # Marine architectural steel bracing
var steel_flange_color := Color(0.55, 0.62, 0.70, 1.0) # Polished structural flange highlights
var chrome_rail_color := Color(0.92, 0.95, 0.98, 0.95)
var granite_rock_color := Color(0.38, 0.35, 0.32, 1.0)
var stone_pedestal_color := Color(0.48, 0.44, 0.40, 1.0)

var terrain_ref: Node2D = null

# Sub-nodes for precise Z-layer rendering
var _ocean_node: Node2D = null
var _island_node: Node2D = null
var _pylons_node: Node2D = null
var _rear_rail_node: Node2D = null
var _glass_deck_node: Node2D = null
var _front_rail_node: Node2D = null
var _portal_node: Node2D = null

func _ready() -> void:
	_setup_sub_layers()

func setup_bridge(terrain: Node2D) -> void:
	terrain_ref = terrain
	queue_redraw_all()

func _setup_sub_layers() -> void:
	# 1. Ocean Water (-6)
	_ocean_node = Node2D.new()
	_ocean_node.name = "OceanWaterPass"
	_ocean_node.z_index = -6
	_ocean_node.draw.connect(_draw_ocean_water)
	add_child(_ocean_node)

	# 2. Island Platforms (-4)
	_island_node = Node2D.new()
	_island_node.name = "IslandPlatformsPass"
	_island_node.z_index = -4
	_island_node.draw.connect(_draw_island_platforms)
	add_child(_island_node)

	# 3. Pylons and Structural Trusses (-2)
	_pylons_node = Node2D.new()
	_pylons_node.name = "PylonsTrussesPass"
	_pylons_node.z_index = -2
	_pylons_node.draw.connect(_draw_pylons_and_trusses)
	add_child(_pylons_node)

	# 4. Rear Railings (-1) - Behind vehicle
	_rear_rail_node = Node2D.new()
	_rear_rail_node.name = "RearRailingsPass"
	_rear_rail_node.z_index = -1
	_rear_rail_node.draw.connect(_draw_rear_railings)
	add_child(_rear_rail_node)

	# 5. Glass Deck (0) - Road surface
	_glass_deck_node = Node2D.new()
	_glass_deck_node.name = "GlassDeckPass"
	_glass_deck_node.z_index = 0
	_glass_deck_node.draw.connect(_draw_glass_deck)
	add_child(_glass_deck_node)

	# 6. Front Railings (+1) - In front of vehicle tires
	_front_rail_node = Node2D.new()
	_front_rail_node.name = "FrontRailingsPass"
	_front_rail_node.z_index = 1
	_front_rail_node.draw.connect(_draw_front_railings)
	add_child(_front_rail_node)

	# 7. Gateway Portals (+2) - Foreground entrance/exit arches
	_portal_node = Node2D.new()
	_portal_node.name = "PortalArchesPass"
	_portal_node.z_index = 2
	_portal_node.draw.connect(_draw_gateway_portals)
	add_child(_portal_node)

func queue_redraw_all() -> void:
	if _ocean_node: _ocean_node.queue_redraw()
	if _island_node: _island_node.queue_redraw()
	if _pylons_node: _pylons_node.queue_redraw()
	if _rear_rail_node: _rear_rail_node.queue_redraw()
	if _glass_deck_node: _glass_deck_node.queue_redraw()
	if _front_rail_node: _front_rail_node.queue_redraw()
	if _portal_node: _portal_node.queue_redraw()

func _get_road_y(x: float) -> float:
	if terrain_ref != null and terrain_ref.has_method("get_height_at"):
		return terrain_ref.get_height_at(x)
	# Fallback mathematical curve matching IndianRoadTerrain.gd
	var base_y := 382.0
	if x < bridge_start_x:
		return base_y
	elif x < bridge_ramp_end_x:
		var t := (x - bridge_start_x) / (bridge_ramp_end_x - bridge_start_x)
		var s := t * t * (3.0 - 2.0 * t)
		return base_y - 85.0 * s
	elif x <= bridge_deck_end_x:
		var u := (x - bridge_ramp_end_x) / (bridge_deck_end_x - bridge_ramp_end_x)
		return base_y - 85.0 - sin(u * PI) * 20.0
	elif x <= bridge_end_x:
		var v := (x - bridge_deck_end_x) / (bridge_end_x - bridge_deck_end_x)
		var sv := v * v * (3.0 - 2.0 * v)
		return base_y - 85.0 * (1.0 - sv)
	return base_y

# -----------------------------------------------------------------------------
# 1. OCEAN WATER PASS (Z-index: -6)
# -----------------------------------------------------------------------------
func _draw_ocean_water() -> void:
	var water_start := bridge_start_x - 600.0
	var water_end := bridge_end_x + 600.0
	var water_surface_y := 396.0
	var water_bottom_y := 1100.0

	# Deep ocean basin polygon
	var ocean_poly := PackedVector2Array([
		Vector2(water_start, water_surface_y),
		Vector2(water_end, water_surface_y),
		Vector2(water_end, water_bottom_y),
		Vector2(water_start, water_bottom_y)
	])
	_ocean_node.draw_colored_polygon(ocean_poly, ocean_deep_color)

	# Ocean surface gradient layer (top 160px)
	var surf_poly := PackedVector2Array([
		Vector2(water_start, water_surface_y),
		Vector2(water_end, water_surface_y),
		Vector2(water_end, water_surface_y + 160.0),
		Vector2(water_start, water_surface_y + 160.0)
	])
	_ocean_node.draw_colored_polygon(surf_poly, ocean_surface_color)

	# Animated / layered surface wave ribbons
	var wave_step := 80.0
	var wave_points := PackedVector2Array()
	var x := water_start
	while x <= water_end:
		var wy := water_surface_y + sin(x * 0.015) * 4.0 + cos(x * 0.007) * 2.5
		wave_points.append(Vector2(x, wy))
		x += wave_step
	_ocean_node.draw_polyline(wave_points, ocean_wave_color, 4.0, true)

	# Second subsurface wave band
	var wave2_points := PackedVector2Array()
	x = water_start
	while x <= water_end:
		var wy := water_surface_y + 18.0 + sin(x * 0.012 + 1.8) * 3.5
		wave2_points.append(Vector2(x, wy))
		x += wave_step
	_ocean_node.draw_polyline(wave2_points, ocean_wave_color.darkened(0.2), 2.5, true)

	# Rocky coastal shoreline transitions (Riprap embankment at start and end)
	_draw_shoreline_rocks(water_start + 200.0, true)
	_draw_shoreline_rocks(water_end - 200.0, false)

func _draw_shoreline_rocks(shore_x: float, is_west: bool) -> void:
	var rock_pts := PackedVector2Array()
	var dir := 1.0 if is_west else -1.0
	var y_top := 382.0
	var y_bot := 480.0

	rock_pts.append(Vector2(shore_x - dir * 250.0, y_top))
	rock_pts.append(Vector2(shore_x + dir * 180.0, y_bot))
	rock_pts.append(Vector2(shore_x - dir * 250.0, y_bot))
	_ocean_node.draw_colored_polygon(rock_pts, Color(0.42, 0.36, 0.30, 1.0))

	# Coastal wave spray / foam line along shoreline
	for i in range(5):
		var rx: float = shore_x + dir * float(i * 35)
		var ry: float = y_top + float(i * 20)
		_ocean_node.draw_circle(Vector2(rx, ry), 12.0 - float(i) * 1.5, Color(1.0, 1.0, 1.0, 0.65))

# -----------------------------------------------------------------------------
# 2. ISLAND PLATFORMS PASS (Z-index: -4)
# -----------------------------------------------------------------------------
func _draw_island_platforms() -> void:
	# Vivekananda Rock Granite Island (x = 31500)
	_draw_vivekananda_rock_island(vivekananda_island_x)

	# Thiruvalluvar Statue Stone Pedestal Island (x = 41500)
	_draw_thiruvalluvar_pedestal_island(thiruvalluvar_island_x)

func _draw_vivekananda_rock_island(center_x: float) -> void:
	# Massive natural granite rock platform rising from the ocean
	var rock_width := 560.0
	var rock_top_y := 272.0
	var rock_base_y := 440.0

	var rock_poly := PackedVector2Array([
		Vector2(center_x - rock_width * 0.50, rock_base_y),
		Vector2(center_x - rock_width * 0.44, rock_base_y - 45.0),
		Vector2(center_x - rock_width * 0.36, rock_top_y + 25.0),
		Vector2(center_x - rock_width * 0.22, rock_top_y + 5.0),
		Vector2(center_x - rock_width * 0.08, rock_top_y),
		Vector2(center_x + rock_width * 0.12, rock_top_y - 2.0),
		Vector2(center_x + rock_width * 0.28, rock_top_y + 12.0),
		Vector2(center_x + rock_width * 0.42, rock_base_y - 40.0),
		Vector2(center_x + rock_width * 0.50, rock_base_y)
	])
	_island_node.draw_colored_polygon(rock_poly, granite_rock_color)

	# Natural granite rock strata / cracks and shading
	var inner_shade_poly := PackedVector2Array([
		Vector2(center_x - rock_width * 0.35, rock_base_y),
		Vector2(center_x - rock_width * 0.20, rock_top_y + 35.0),
		Vector2(center_x + rock_width * 0.15, rock_top_y + 30.0),
		Vector2(center_x + rock_width * 0.35, rock_base_y)
	])
	_island_node.draw_colored_polygon(inner_shade_poly, granite_rock_color.darkened(0.22))

	# Granite top plateau highlight rim
	var plateau_pts := PackedVector2Array([
		Vector2(center_x - rock_width * 0.36, rock_top_y + 25.0),
		Vector2(center_x - rock_width * 0.22, rock_top_y + 5.0),
		Vector2(center_x - rock_width * 0.08, rock_top_y),
		Vector2(center_x + rock_width * 0.12, rock_top_y - 2.0),
		Vector2(center_x + rock_width * 0.28, rock_top_y + 12.0)
	])
	_island_node.draw_polyline(plateau_pts, granite_rock_color.lightened(0.25), 4.0)

	# Waterline crashing waves and foam collar around island base
	for step in range(-8, 9):
		var fx: float = center_x + float(step) * 32.0
		var fy := 402.0 + sin(float(step) * 0.8) * 3.0
		_island_node.draw_circle(Vector2(fx, fy), 14.0, Color(1.0, 1.0, 1.0, 0.75))

func _draw_thiruvalluvar_pedestal_island(center_x: float) -> void:
	# Monumental tiered Dravidian stone pedestal platform rising from the ocean
	var base_width := 460.0
	var mid_width := 380.0
	var top_width := 300.0

	var ocean_base_y := 440.0
	var tier1_y := 360.0
	var tier2_y := 305.0
	var tier3_y := 250.0 # Statue base level, aligned with offshore monument offset

	# Tier 1 (Lowest stone foundation platform)
	var t1 := PackedVector2Array([
		Vector2(center_x - base_width * 0.5, ocean_base_y),
		Vector2(center_x - base_width * 0.48, tier1_y),
		Vector2(center_x + base_width * 0.48, tier1_y),
		Vector2(center_x + base_width * 0.5, ocean_base_y)
	])
	_island_node.draw_colored_polygon(t1, stone_pedestal_color.darkened(0.20))

	# Tier 2 (Middle architectural plinth)
	var t2 := PackedVector2Array([
		Vector2(center_x - mid_width * 0.5, tier1_y),
		Vector2(center_x - mid_width * 0.47, tier2_y),
		Vector2(center_x + mid_width * 0.47, tier2_y),
		Vector2(center_x + mid_width * 0.5, tier1_y)
	])
	_island_node.draw_colored_polygon(t2, stone_pedestal_color)

	# Tier 3 (Upper carved pedestal support for the 133-ft statue)
	var t3 := PackedVector2Array([
		Vector2(center_x - top_width * 0.5, tier2_y),
		Vector2(center_x - top_width * 0.48, tier3_y),
		Vector2(center_x + top_width * 0.48, tier3_y),
		Vector2(center_x + top_width * 0.5, tier2_y)
	])
	_island_node.draw_colored_polygon(t3, stone_pedestal_color.lightened(0.12))

	# Cornice molding lines and architectural Dravidian joints
	_island_node.draw_line(Vector2(center_x - base_width * 0.48, tier1_y), Vector2(center_x + base_width * 0.48, tier1_y), stone_pedestal_color.lightened(0.35), 4.0)
	_island_node.draw_line(Vector2(center_x - mid_width * 0.47, tier2_y), Vector2(center_x + mid_width * 0.47, tier2_y), stone_pedestal_color.lightened(0.35), 4.0)
	_island_node.draw_line(Vector2(center_x - top_width * 0.48, tier3_y), Vector2(center_x + top_width * 0.48, tier3_y), stone_pedestal_color.lightened(0.35), 5.0)

	# Foam collar around pedestal base
	for step in range(-7, 8):
		var fx: float = center_x + float(step) * 30.0
		var fy := 402.0 + cos(float(step) * 0.9) * 3.0
		_island_node.draw_circle(Vector2(fx, fy), 15.0, Color(1.0, 1.0, 1.0, 0.75))

# -----------------------------------------------------------------------------
# 3. PYLONS AND TRUSSES PASS (Z-index: -2)
# -----------------------------------------------------------------------------
func _draw_pylons_and_trusses() -> void:
	var pylon_positions: Array[float] = [
		2600.0, 3200.0, 4000.0, 4800.0, 5600.0, 6400.0, 7000.0, 7800.0, 8400.0
	]

	for px in pylon_positions:
		var deck_y := _get_road_y(px)
		var pylon_base_y := 440.0
		var pier_w := 64.0

		# Reinforced concrete twin pier
		var pylon_rect := Rect2(px - pier_w * 0.5, deck_y + 14.0, pier_w, pylon_base_y - deck_y - 14.0)
		_pylons_node.draw_rect(pylon_rect, steel_pylon_color)

		# Flared concrete pier capital (deck support head)
		var cap_poly := PackedVector2Array([
			Vector2(px - pier_w * 0.75, deck_y + 12.0),
			Vector2(px + pier_w * 0.75, deck_y + 12.0),
			Vector2(px + pier_w * 0.5, deck_y + 36.0),
			Vector2(px - pier_w * 0.5, deck_y + 36.0)
		])
		_pylons_node.draw_colored_polygon(cap_poly, steel_pylon_color.lightened(0.15))

		# Underwater footing collar
		_pylons_node.draw_rect(Rect2(px - pier_w * 0.7, 390.0, pier_w * 1.4, 30.0), steel_pylon_color.darkened(0.3))

	# Under-deck structural steel box girders & architectural support trusses
	var step := 120.0
	var cur_x := bridge_start_x
	while cur_x < bridge_end_x:
		var next_x := cur_x + step
		var y1 := _get_road_y(cur_x) + 14.0
		var y2 := _get_road_y(next_x) + 14.0
		var bot_y1 := y1 + 22.0
		var bot_y2 := y2 + 22.0

		# 1. Solid under-deck structural steel box girder tray (gives real structural substance)
		var girder_poly := PackedVector2Array([
			Vector2(cur_x, y1),
			Vector2(next_x, y2),
			Vector2(next_x, bot_y2),
			Vector2(cur_x, bot_y1)
		])
		_pylons_node.draw_colored_polygon(girder_poly, steel_box_girder_color)

		# 2. Upper and lower longitudinal structural flange chords
		_pylons_node.draw_line(Vector2(cur_x, y1), Vector2(next_x, y2), steel_flange_color, 2.5)
		_pylons_node.draw_line(Vector2(cur_x, bot_y1), Vector2(next_x, bot_y2), steel_box_girder_color.darkened(0.2), 2.5)

		# 3. Vertical engineering stiffener plate ribs at each bay
		_pylons_node.draw_line(Vector2(cur_x, y1), Vector2(cur_x, bot_y1), steel_flange_color.lightened(0.1), 2.0)

		# 4. Subtle internal web bracing (in architectural steel, not glaring red hazard crosshatch)
		_pylons_node.draw_line(Vector2(cur_x, y1), Vector2(next_x, bot_y2), steel_truss_color, 1.5)
		_pylons_node.draw_line(Vector2(cur_x, bot_y1), Vector2(next_x, y2), steel_truss_color, 1.5)

		cur_x = next_x

# -----------------------------------------------------------------------------
# 4. REAR RAILINGS PASS (Z-index: -1) - Behind vehicle
# -----------------------------------------------------------------------------
func _draw_rear_railings() -> void:
	var post_spacing := 90.0
	var cur_x := bridge_start_x
	var rail_height := 32.0

	# Continuous rear safety cable lines
	var cable1_pts := PackedVector2Array()
	var cable2_pts := PackedVector2Array()
	var cable3_pts := PackedVector2Array()

	while cur_x <= bridge_end_x:
		var ry := _get_road_y(cur_x)
		cable1_pts.append(Vector2(cur_x, ry - rail_height))
		cable2_pts.append(Vector2(cur_x, ry - rail_height * 0.65))
		cable3_pts.append(Vector2(cur_x, ry - rail_height * 0.30))

		# Vertical stainless steel stanchions
		_rear_rail_node.draw_line(Vector2(cur_x, ry), Vector2(cur_x, ry - rail_height), steel_pylon_color.darkened(0.15), 3.0)
		cur_x += post_spacing

	_rear_rail_node.draw_polyline(cable1_pts, chrome_rail_color.darkened(0.2), 2.5)
	_rear_rail_node.draw_polyline(cable2_pts, chrome_rail_color.darkened(0.3), 1.5)
	_rear_rail_node.draw_polyline(cable3_pts, chrome_rail_color.darkened(0.3), 1.5)

# -----------------------------------------------------------------------------
# 5. GLASS DECK PASS (Z-index: 0) - Road surface
# -----------------------------------------------------------------------------
func _draw_glass_deck() -> void:
	var step := 50.0
	var cur_x := bridge_start_x

	# Build upper and lower deck polyline
	var deck_poly := PackedVector2Array()
	var top_line := PackedVector2Array()
	var bot_line := PackedVector2Array()

	while cur_x <= bridge_end_x:
		var ry := _get_road_y(cur_x)
		top_line.append(Vector2(cur_x, ry - 3.0))
		bot_line.append(Vector2(cur_x, ry + 12.0))
		cur_x += step

	# Construct translucent glass floor polygon
	deck_poly.append_array(top_line)
	for i in range(bot_line.size() - 1, -1, -1):
		deck_poly.append(bot_line[i])

	# 1. Main translucent cyan glass floor (transparency allows ocean below to be seen!)
	_glass_deck_node.draw_colored_polygon(deck_poly, glass_panel_color)

	# 2. Specular glass reflection glint streak along top surface
	_glass_deck_node.draw_polyline(top_line, glass_glint_color, 3.5, true)

	# 3. Deck lower structural steel flange
	_glass_deck_node.draw_polyline(bot_line, steel_pylon_color.darkened(0.25), 3.0, true)

	# 4. Transverse structural steel expansion transoms every 140px
	cur_x = bridge_start_x
	while cur_x <= bridge_end_x:
		var ry := _get_road_y(cur_x)
		_glass_deck_node.draw_line(Vector2(cur_x, ry - 3.0), Vector2(cur_x, ry + 12.0), Color(0.25, 0.35, 0.45, 0.95), 3.0)
		cur_x += 140.0

# -----------------------------------------------------------------------------
# 6. FRONT RAILINGS PASS (Z-index: +1) - In front of vehicle wheels
# -----------------------------------------------------------------------------
func _draw_front_railings() -> void:
	var post_spacing := 90.0
	var cur_x := bridge_start_x
	var balustrade_height := 28.0

	var handrail_pts := PackedVector2Array()
	var balustrade_top := PackedVector2Array()
	var balustrade_bot := PackedVector2Array()

	while cur_x <= bridge_end_x:
		var ry := _get_road_y(cur_x)
		handrail_pts.append(Vector2(cur_x, ry - balustrade_height))
		balustrade_top.append(Vector2(cur_x, ry - balustrade_height + 2.0))
		balustrade_bot.append(Vector2(cur_x, ry - 2.0))

		# Vertical structural posts
		_front_rail_node.draw_line(Vector2(cur_x, ry), Vector2(cur_x, ry - balustrade_height), steel_pylon_color, 2.5)
		cur_x += post_spacing

	# Translucent tempered safety glass balustrade strip
	var glass_strip := PackedVector2Array()
	glass_strip.append_array(balustrade_top)
	for i in range(balustrade_bot.size() - 1, -1, -1):
		glass_strip.append(balustrade_bot[i])
	_front_rail_node.draw_colored_polygon(glass_strip, Color(0.40, 0.90, 0.98, 0.38))

	# Polished chrome top handrail
	_front_rail_node.draw_polyline(handrail_pts, chrome_rail_color, 3.5, true)
	# Handrail specular reflection highlight
	_front_rail_node.draw_polyline(handrail_pts, Color(1.0, 1.0, 1.0, 0.85), 1.2, true)

# -----------------------------------------------------------------------------
# 7. GATEWAY PORTALS PASS (Z-index: +2) - Entrance & Exit arches
# -----------------------------------------------------------------------------
func _draw_gateway_portals() -> void:
	_draw_portal_arch(bridge_start_x, "KANYAKUMARI GLASS BRIDGE", "WELCOME TO OCEAN SKYWALK")
	_draw_portal_arch(bridge_end_x, "KANYAKUMARI COASTLINE", "THANK YOU FOR VISITING")

	# Observation Viewing Balconies (Cantilevered glass bays)
	_draw_observation_platform(vivekananda_island_x, "VIVEKANANDA ROCK OBSERVATION DECK")
	_draw_observation_platform(thiruvalluvar_island_x, "THIRUVALLUVAR STATUE OBSERVATION DECK")

func _draw_portal_arch(arch_x: float, title_text: String, sub_text: String) -> void:
	var arch_y := _get_road_y(arch_x)
	var arch_w := 90.0
	var arch_h := 115.0

	# Left & Right architectural gateway pillars
	var left_rect := Rect2(arch_x - arch_w * 0.5, arch_y - arch_h, 16.0, arch_h)
	var right_rect := Rect2(arch_x + arch_w * 0.5 - 16.0, arch_y - arch_h, 16.0, arch_h)
	_portal_node.draw_rect(left_rect, steel_pylon_color.darkened(0.1))
	_portal_node.draw_rect(right_rect, steel_pylon_color.darkened(0.1))

	# Crossbeam overhead sign structure
	var sign_rect := Rect2(arch_x - arch_w * 0.5 - 20.0, arch_y - arch_h - 18.0, arch_w + 40.0, 24.0)
	_portal_node.draw_rect(sign_rect, Color(0.08, 0.28, 0.44, 0.95))
	_portal_node.draw_rect(sign_rect, Color(0.35, 0.85, 0.95, 1.0), false, 2.0)

	# Illuminated cyan corner accents
	_portal_node.draw_circle(Vector2(arch_x - arch_w * 0.5 - 16.0, arch_y - arch_h - 6.0), 4.0, Color(0.35, 0.95, 1.0, 0.9))
	_portal_node.draw_circle(Vector2(arch_x + arch_w * 0.5 + 16.0, arch_y - arch_h - 6.0), 4.0, Color(0.35, 0.95, 1.0, 0.9))

func _draw_observation_platform(bay_x: float, sign_text: String) -> void:
	var bay_y := _get_road_y(bay_x)
	var bay_w := 140.0

	# Extended cantilevered glass viewing balcony
	var bay_pts := PackedVector2Array([
		Vector2(bay_x - bay_w * 0.5, bay_y + 10.0),
		Vector2(bay_x + bay_w * 0.5, bay_y + 10.0),
		Vector2(bay_x + bay_w * 0.45, bay_y + 35.0),
		Vector2(bay_x - bay_w * 0.45, bay_y + 35.0)
	])
	_portal_node.draw_colored_polygon(bay_pts, glass_panel_color)
	_portal_node.draw_polyline(bay_pts, glass_glint_color, 2.0)

	# Balcony support steel bracket
	_portal_node.draw_line(Vector2(bay_x, bay_y + 10.0), Vector2(bay_x, bay_y + 55.0), steel_pylon_color.darkened(0.2), 4.0)
