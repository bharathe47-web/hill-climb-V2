@tool
class_name TerrainSegment
extends StaticBody2D

## TerrainSegment: Reusable terrain slice with synchronized visual and collision geometry.
## Provides multiple terrain shapes (flat, gentle hills, steep climb, valley dip, jump ramp)
## with smooth continuous transitions between consecutive segments.

enum SegmentType {
	FLAT,
	GENTLE_HILLS,
	STEEP_CLIMB,
	VALLEY_DIP,
	JUMP_RAMP,
	ROLLING_WAVES,
	PLATEAU_DROP,
	BUMPY_WASHBOARD,
	DOUBLE_CREST,
	CUSTOM,
	RAMP_NORMAL_TO_HEAVEN,
	RAMP_HEAVEN_TO_NORMAL,
	RAMP_NORMAL_TO_HELL,
	RAMP_HELL_TO_NORMAL
}

@export var segment_type: SegmentType = SegmentType.GENTLE_HILLS:
	set(val):
		segment_type = val
		if Engine.is_editor_hint():
			rebuild_segment()

@export var segment_length: float = 1200.0:
	set(val):
		segment_length = maxf(200.0, val)
		if Engine.is_editor_hint():
			rebuild_segment()

@export var start_height: float = 0.0:
	set(val):
		start_height = val
		if Engine.is_editor_hint():
			rebuild_segment()

@export var end_height: float = 0.0:
	set(val):
		end_height = val
		if Engine.is_editor_hint():
			rebuild_segment()

@export var start_slope: float = 0.0:
	set(val):
		start_slope = val
		if Engine.is_editor_hint():
			rebuild_segment()

@export var end_slope: float = 0.0:
	set(val):
		end_slope = val
		if Engine.is_editor_hint():
			rebuild_segment()

@export var amplitude: float = 80.0:
	set(val):
		amplitude = val
		if Engine.is_editor_hint():
			rebuild_segment()

@export var ground_depth: float = 900.0:
	set(val):
		ground_depth = maxf(400.0, val)
		if Engine.is_editor_hint():
			rebuild_segment()

@export var samples_count: int = 36:
	set(val):
		samples_count = clampi(val, 8, 120)
		if Engine.is_editor_hint():
			rebuild_segment()

@export_group("Visual Styling")
@export var terrain_profile: Resource = null:
	set(val):
		terrain_profile = val
		if val != null and "surface_friction" in val:
			surface_friction = val.get("surface_friction")
			_update_physics_material()
		if Engine.is_editor_hint():
			rebuild_segment()
@export var ground_color: Color = Color(0.28, 0.19, 0.13, 1.0)
@export var subsoil_color: Color = Color(0.18, 0.12, 0.08, 1.0)
@export var grass_color: Color = Color(0.30, 0.68, 0.22, 1.0)
@export var grass_highlight_color: Color = Color(0.46, 0.82, 0.30, 1.0)
@export var grass_thickness: float = 8.0
@export var add_decorations: bool = true

@export_group("Physics")
@export var surface_friction: float = 1.0:
	set(val):
		surface_friction = val
		_update_physics_material()

@export_group("Platform Mode")
@export var is_floating_platform: bool = false:
	set(val):
		is_floating_platform = val
		if Engine.is_editor_hint():
			rebuild_segment()

@export var platform_thickness: float = 120.0:
	set(val):
		platform_thickness = maxf(20.0, val)
		if Engine.is_editor_hint():
			rebuild_segment()

var custom_surface_points: PackedVector2Array = PackedVector2Array()
var generated_surface_points: PackedVector2Array = PackedVector2Array()

## Runtime depth of the visible top crust; collision remains full-depth.
var visual_surface_band_depth: float = 0.0

@onready var collision_polygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var ground_polygon: Polygon2D = $GroundPolygon
@onready var subsoil_polygon: Polygon2D = get_node_or_null("SubsoilPolygon")
@onready var grass_line: Line2D = $GrassLine
@onready var grass_highlight_line: Line2D = get_node_or_null("GrassHighlightLine")
@onready var decorations_root: Node2D = get_node_or_null("DecorationsRoot")

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	_update_physics_material()
	rebuild_segment()

func _update_physics_material() -> void:
	if physics_material_override:
		physics_material_override.friction = surface_friction
		physics_material_override.rough = true
	else:
		var phys_mat := PhysicsMaterial.new()
		phys_mat.friction = surface_friction
		phys_mat.rough = true
		physics_material_override = phys_mat

## Returns the starting surface point of this segment in local coordinates
func get_entry_point() -> Vector2:
	if generated_surface_points.is_empty():
		return Vector2(0.0, start_height)
	return generated_surface_points[0]

## Returns the exit surface point of this segment in local coordinates
func get_exit_point() -> Vector2:
	if generated_surface_points.is_empty():
		return Vector2(segment_length, end_height)
	return generated_surface_points[generated_surface_points.size() - 1]

## Returns the tangent slope (dy/dx) at the exit of this segment for seamless C1 joins
func get_exit_slope() -> float:
	if generated_surface_points.size() < 2:
		return end_slope
	var n := generated_surface_points.size()
	var p_last := generated_surface_points[n - 1]
	var p_prev := generated_surface_points[n - 2]
	var dx := p_last.x - p_prev.x
	if is_zero_approx(dx):
		return end_slope
	return (p_last.y - p_prev.y) / dx

## Returns the interpolated surface Y at local x coordinate (top ground contour)
func get_surface_y_at(local_x: float) -> float:
	if generated_surface_points.is_empty():
		return 0.0
	var first_pt := generated_surface_points[0]
	var last_pt := generated_surface_points[generated_surface_points.size() - 1]
	if local_x <= first_pt.x:
		return first_pt.y
	if local_x >= last_pt.x:
		return last_pt.y

	var idx := 0
	for i in range(generated_surface_points.size() - 1):
		if generated_surface_points[i + 1].x >= local_x:
			idx = i
			break

	var p1 := generated_surface_points[idx]
	var p2 := generated_surface_points[mini(idx + 1, generated_surface_points.size() - 1)]
	var span_x := p2.x - p1.x
	if is_zero_approx(span_x):
		return p1.y
	var alpha := (local_x - p1.x) / span_x
	return lerpf(p1.y, p2.y, alpha)

## Returns the interpolated surface position and upward-pointing surface normal at local x
func get_surface_point_and_normal_at(local_x: float) -> Dictionary:
	if generated_surface_points.is_empty():
		return {"point": Vector2(local_x, 0.0), "normal": Vector2.UP}

	var first_pt := generated_surface_points[0]
	var last_pt := generated_surface_points[generated_surface_points.size() - 1]
	var clamped_x := clampf(local_x, first_pt.x, last_pt.x)
	var idx := 0
	for i in range(generated_surface_points.size() - 1):
		if generated_surface_points[i + 1].x >= clamped_x:
			idx = i
			break

	var p1 := generated_surface_points[idx]
	var p2 := generated_surface_points[mini(idx + 1, generated_surface_points.size() - 1)]
	var span_x := p2.x - p1.x
	var alpha := 0.0 if is_zero_approx(span_x) else (clamped_x - p1.x) / span_x
	var pt := Vector2(clamped_x, lerpf(p1.y, p2.y, alpha))
	var dir := (p2 - p1).normalized() if p1.distance_squared_to(p2) > 0.0001 else Vector2.RIGHT
	var normal := Vector2(-dir.y, dir.x)
	if normal.y > 0.0:
		normal = -normal # Ensure pointing up into the air
	return {"point": pt, "normal": normal}

## Rebuilds the surface geometry and synchronizes collision + visual polygons
func rebuild_segment() -> void:
	if terrain_profile != null and "surface_friction" in terrain_profile:
		surface_friction = terrain_profile.get("surface_friction")
	_ensure_child_nodes()
	_update_physics_material()
	_generate_surface_points()
	_apply_geometry()

func set_custom_points(points: PackedVector2Array) -> void:
	segment_type = SegmentType.CUSTOM
	custom_surface_points = points.duplicate()
	rebuild_segment()

func _ensure_child_nodes() -> void:
	if not collision_polygon:
		collision_polygon = CollisionPolygon2D.new()
		collision_polygon.name = "CollisionPolygon2D"
		add_child(collision_polygon)

	if not ground_polygon:
		ground_polygon = Polygon2D.new()
		ground_polygon.name = "GroundPolygon"
		add_child(ground_polygon)

	if not subsoil_polygon:
		subsoil_polygon = Polygon2D.new()
		subsoil_polygon.name = "SubsoilPolygon"
		add_child(subsoil_polygon)
		move_child(subsoil_polygon, 0) # Base under ground

	if not grass_line:
		grass_line = Line2D.new()
		grass_line.name = "GrassLine"
		grass_line.visible = false
		add_child(grass_line)
	else:
		grass_line.visible = false

	if not grass_highlight_line:
		grass_highlight_line = Line2D.new()
		grass_highlight_line.name = "GrassHighlightLine"
		grass_highlight_line.visible = false
		add_child(grass_highlight_line)
	else:
		grass_highlight_line.visible = false

	if not decorations_root:
		decorations_root = Node2D.new()
		decorations_root.name = "DecorationsRoot"
		add_child(decorations_root)

func _generate_surface_points() -> void:
	generated_surface_points.clear()

	if segment_type == SegmentType.CUSTOM and not custom_surface_points.is_empty():
		generated_surface_points = custom_surface_points.duplicate()
		return

	var pts := PackedVector2Array()

	for i in range(samples_count + 1):
		var t := float(i) / float(samples_count) # 0.0 to 1.0
		var x := t * segment_length
		var y := 0.0

		# Hermite cubic spline baseline matching start_height, start_slope, end_height, end_slope
		var h00 := 2.0 * t * t * t - 3.0 * t * t + 1.0
		var h10 := t * t * t - 2.0 * t * t + t
		var h01 := -2.0 * t * t * t + 3.0 * t * t
		var h11 := t * t * t - t * t
		var base_y := h00 * start_height + h10 * segment_length * start_slope + h01 * end_height + h11 * segment_length * end_slope

		# Hann-squared window guarantees zero first-derivative at t=0 and t=1, preserving exact C1 slope joins
		var window_hann := sin(t * PI)
		var window_hann_sq := window_hann * window_hann

		match segment_type:
			SegmentType.FLAT:
				y = base_y

			SegmentType.GENTLE_HILLS:
				# Smooth sine wave hill with Hann-squared window
				var wave := sin(t * TAU) * window_hann_sq * amplitude
				y = base_y - wave

			SegmentType.STEEP_CLIMB:
				# Steeper climb with subtle natural terrain ripple
				var ripple := sin(t * TAU * 1.5) * window_hann_sq * (amplitude * 0.25)
				y = base_y - ripple

			SegmentType.VALLEY_DIP:
				# Smooth rounded dip in the middle
				var dip := window_hann_sq * amplitude
				y = base_y + dip

			SegmentType.JUMP_RAMP:
				# Smooth launch crest with continuous slope
				var crest := sin(t * PI) * window_hann_sq * (amplitude * 1.1)
				y = base_y - crest

			SegmentType.ROLLING_WAVES:
				# Multiple rolling hills with seamless boundary tangency
				var wave1 := sin(t * TAU * 1.5) * 0.65
				var wave2 := sin(t * TAU * 3.0) * 0.35
				var wave_val := (wave1 + wave2) * window_hann_sq * amplitude
				y = base_y - wave_val

			SegmentType.PLATEAU_DROP:
				# Natural rounded mesa / rolling ridge (never a rectangular box or sharp cliff)
				var ridge := sin(t * PI) * window_hann_sq * (amplitude * 0.8)
				y = base_y - ridge

			SegmentType.BUMPY_WASHBOARD:
				# Small rhythmic ripples to exercise suspension
				var bumps := sin(t * TAU * 4.0) * window_hann_sq * (amplitude * 0.22)
				y = base_y - bumps

			SegmentType.DOUBLE_CREST:
				# Two rounded peaks with smooth saddle dip in between
				var crests := sin(t * TAU * 2.0) * window_hann_sq * (amplitude * 0.6)
				y = base_y - crests

			SegmentType.RAMP_NORMAL_TO_HEAVEN:
				# Ascending launch curve with parabolic crest
				var launch_shape := (sin(t * PI * 0.5) * 0.75 + sin(t * PI) * 0.25) * window_hann_sq * (amplitude * 1.25)
				y = base_y - launch_shape

			SegmentType.RAMP_HEAVEN_TO_NORMAL:
				# Smooth return descent slide banking gently to base
				var slide_shape := (sin(t * PI) * 0.7 + sin(t * TAU) * 0.2) * window_hann_sq * (amplitude * 0.95)
				y = base_y - slide_shape

			SegmentType.RAMP_NORMAL_TO_HELL:
				# Dramatic volcanic chasm plunge trough with parabolic catch
				var plunge_depth := window_hann_sq * (amplitude * 1.4)
				y = base_y + plunge_depth

			SegmentType.RAMP_HELL_TO_NORMAL:
				# High-velocity magma geyser escape ramp
				var kick := sin(t * PI) * window_hann_sq * (amplitude * 1.3)
				y = base_y - kick

		pts.append(Vector2(x, y))

	generated_surface_points = pts

# Preloaded ground and subsurface textures
const TEX_SOIL_SUBSURFACE: Texture2D = preload("res://assets/terrain/surfaces/countryside_earth_strata.png")
const TEX_GRASS_EDGE: Texture2D = preload("res://assets/terrain/surfaces/countryside_grass_top.png")

# Preloaded countryside scenery textures
const TEX_BUSHES: Array = [
	preload("res://assets/environment/countryside/bushes/bush_cozy_green.png"),
	preload("res://assets/environment/countryside/bushes/bush_berry.png"),
	preload("res://assets/environment/countryside/bushes/bush_lavender.png"),
	preload("res://assets/environment/countryside/bushes/bush_round_green.png")
]
const TEX_FLOWERS: Array = [
	preload("res://assets/environment/countryside/plants/fern_wild.png"),
	preload("res://assets/environment/countryside/plants/grass_clump_dense.png"),
	preload("res://assets/environment/countryside/plants/flower_yellow.png"),
	preload("res://assets/environment/countryside/plants/flower_purple.png"),
	preload("res://assets/environment/countryside/plants/grass_tuft_01.png")
]
const TEX_HEAVEN_FLOWERS: Array = [
	preload("res://assets/environments/heaven/decorations/flowers/flower_01.png"),
	preload("res://assets/environments/heaven/decorations/flowers/flower_02.png"),
	preload("res://assets/environments/heaven/decorations/flowers/flower_03.png"),
	preload("res://assets/environments/heaven/decorations/flowers/flower_04.png"),
	preload("res://assets/environments/heaven/decorations/flowers/flower_05.png"),
	preload("res://assets/environments/heaven/decorations/flowers/flower_06.png"),
	preload("res://assets/environments/heaven/decorations/flowers/flower_07.png"),
	preload("res://assets/environments/heaven/decorations/flowers/flower_08.png")
]
const TEX_ROCKS: Array = [
	preload("res://assets/terrain/rocks/small_stones_pebbles.png"),
	preload("res://assets/terrain/rocks/large_rock_boulder_01.png")
]
const TEX_HELL_ROCKS: Array = [
	preload("res://assets/environments/hell/terrain/hell_volcanic_rock_a.png"),
	preload("res://assets/environments/hell/terrain/hell_volcanic_rock_b.png"),
	preload("res://assets/environments/hell/terrain/hell_volcanic_rock_c.png")
]
const TEX_PROPS: Array = [
	preload("res://assets/environment/countryside/fences/wooden_fence_01.png"),
	preload("res://assets/environment/countryside/fences/wooden_fence_broken.png"),
	preload("res://assets/environment/countryside/props/fallen_log_01.png"),
	preload("res://assets/environment/countryside/props/tree_stump_mossy.png"),
	preload("res://assets/environment/countryside/props/stone_cluster_small.png"),
	preload("res://assets/environment/countryside/props/hay_bale_round.png"),
	preload("res://assets/environment/countryside/signs/wooden_signpost.png")
]

func _apply_geometry() -> void:
	if generated_surface_points.size() < 2:
		return

	var first_pt := generated_surface_points[0]
	var last_pt := generated_surface_points[generated_surface_points.size() - 1]

	const GLOBAL_DEEP_BOTTOM_Y: float = 2400.0
	var local_bottom_y: float = GLOBAL_DEEP_BOTTOM_Y - global_position.y
	var max_surf_y: float = first_pt.y
	for pt in generated_surface_points:
		if pt.y > max_surf_y:
			max_surf_y = pt.y
	local_bottom_y = maxf(local_bottom_y, max_surf_y + ground_depth)

	# 1. Build ground polygon closed at constant global bottom (or finite platform thickness in platform mode)
	var poly_pts := PackedVector2Array()
	if is_floating_platform:
		for pt in generated_surface_points:
			poly_pts.append(pt)
		for i in range(generated_surface_points.size() - 1, -1, -1):
			var pt := generated_surface_points[i]
			poly_pts.append(Vector2(pt.x, pt.y + platform_thickness))
	else:
		for pt in generated_surface_points:
			poly_pts.append(pt)
		poly_pts.append(Vector2(last_pt.x, local_bottom_y))
		poly_pts.append(Vector2(first_pt.x, local_bottom_y))

	# Synchronize visual polygon and collision polygon exactly
	if collision_polygon:
		collision_polygon.polygon = poly_pts

	# Default colors (Normal Land countryside)
	var active_ground_col: Color = Color(1.0, 1.0, 1.0, 1.0) # Natural warm countryside meadow
	var active_subsoil_col: Color = Color(1.0, 1.0, 1.0, 1.0) # 3 distinct strata: loam, compacted earth, bedrock
	var active_grass_col: Color = Color(0.44, 0.78, 0.28, 0.95) # Natural fresh meadow grass
	var active_grass_hl: Color = Color(0.70, 0.92, 0.45, 0.65) # Subtle sunlit grass crest
	var active_ground_tex: Texture2D = TEX_GRASS_EDGE
	var active_subsoil_tex: Texture2D = TEX_SOIL_SUBSURFACE
	var active_ground_tex_scale: Vector2 = Vector2(0.5, 0.5)
	var active_grass_width: float = 3.2
	var active_grass_hl_width: float = 1.6

	var prof_name: String = str(terrain_profile.get("profile_name")) if terrain_profile else ""
	var is_heaven := prof_name.begins_with("Heaven")
	var is_hell := prof_name.begins_with("Hell")

	if terrain_profile:
		if is_heaven:
			# Warm luminous ivory/gold marble neutralizing native cyan texture cast
			active_ground_col = Color(1.0, 0.95, 0.80, 1.0)
			active_subsoil_col = Color(0.72, 0.60, 0.40, 1.0)
			active_grass_col = Color(0.95, 0.82, 0.35, 1.0) # Celestial gold rim
			active_grass_hl = Color(1.0, 0.95, 0.65, 0.95)
			active_grass_width = 5.0
			active_grass_hl_width = 2.5
			active_ground_tex_scale = Vector2(0.5, 0.75)
			if "ground_texture" in terrain_profile and terrain_profile.ground_texture:
				active_ground_tex = terrain_profile.ground_texture
			if "subsoil_texture" in terrain_profile and terrain_profile.subsoil_texture:
				active_subsoil_tex = terrain_profile.subsoil_texture
		elif prof_name.begins_with("Hell"):
			# Dark volcanic crust over layered ash-rock; the narrow orange edge reads as heat, not a thick outline.
			active_ground_col = Color(0.84, 0.80, 0.77, 1.0)
			active_subsoil_col = Color(0.22, 0.11, 0.09, 1.0)
			active_grass_col = Color(0.90, 0.36, 0.10, 1.0) # Fine molten crust edge
			active_grass_hl = Color(1.0, 0.62, 0.20, 0.88)
			active_grass_width = 2.8
			active_grass_hl_width = 1.4
			active_ground_tex_scale = Vector2(0.5, 0.75)
			if "ground_texture" in terrain_profile and terrain_profile.ground_texture:
				active_ground_tex = terrain_profile.ground_texture
			if "subsoil_texture" in terrain_profile and terrain_profile.subsoil_texture:
				active_subsoil_tex = terrain_profile.subsoil_texture
		else:
			if "ground_texture" in terrain_profile and terrain_profile.ground_texture:
				active_ground_tex = terrain_profile.ground_texture
			if "subsoil_texture" in terrain_profile and terrain_profile.subsoil_texture:
				active_subsoil_tex = terrain_profile.subsoil_texture
			if "ground_color" in terrain_profile and terrain_profile.ground_color != Color.WHITE:
				active_ground_col = terrain_profile.ground_color
			if "subsoil_color" in terrain_profile and terrain_profile.subsoil_color != Color(0.9, 0.9, 0.9, 1.0):
				active_subsoil_col = terrain_profile.subsoil_color

	# Keep the biome texture on a shallow, readable surface crust. The old code
	# assigned the full 900px-deep collision polygon to GroundPolygon and then
	# drew it after SubsoilPolygon, hiding almost the entire underground layer.
	# The Heaven/Hell 1920x99 strips were consequently repeated down the whole
	# world depth, creating the giant flat slab visible in the supplied captures.
	var texture_height := active_ground_tex.get_height() if active_ground_tex else 70
	if is_heaven or is_hell:
		visual_surface_band_depth = clampf(float(texture_height) * active_ground_tex_scale.y, 30.0, 104.0)
	else:
		# Clean, slim countryside grass crest (38px depth) seamlessly transitioning to the earth body
		visual_surface_band_depth = 38.0
	if is_floating_platform:
		visual_surface_band_depth = minf(visual_surface_band_depth, platform_thickness * 0.42)

	var ground_band_pts := PackedVector2Array()
	for pt in generated_surface_points:
		ground_band_pts.append(pt)
	for i in range(generated_surface_points.size() - 1, -1, -1):
		var pt := generated_surface_points[i]
		ground_band_pts.append(Vector2(pt.x, pt.y + visual_surface_band_depth))

	if ground_polygon:
		ground_polygon.polygon = ground_band_pts
		ground_polygon.color = active_ground_col
		ground_polygon.texture = active_ground_tex
		ground_polygon.texture_scale = Vector2(1.0, 1.0)
		ground_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		ground_polygon.z_index = 0

		# Explicit UV mapping guarantees grass blades exist ONLY along the top surface,
		# pointing upward into the air, with pure soil at the bottom (zero downward/internal grass).
		var ground_uv := PackedVector2Array()
		var g_tex_h: float = float(active_ground_tex.get_height()) if active_ground_tex else 128.0
		for pt in generated_surface_points:
			ground_uv.append(Vector2((position.x + pt.x) * active_ground_tex_scale.x, 0.0))
		for i in range(generated_surface_points.size() - 1, -1, -1):
			var pt := generated_surface_points[i]
			ground_uv.append(Vector2((position.x + pt.x) * active_ground_tex_scale.x, g_tex_h))
		ground_polygon.uv = ground_uv

	# 2. Build the visible underground body below the top crust. Collision stays
	# on poly_pts above, so visual material changes cannot alter vehicle physics.
	if subsoil_polygon:
		var subsoil_pts := PackedVector2Array()
		for pt in generated_surface_points:
			subsoil_pts.append(Vector2(pt.x, pt.y + visual_surface_band_depth))
		if is_floating_platform:
			for i in range(generated_surface_points.size() - 1, -1, -1):
				var pt := generated_surface_points[i]
				subsoil_pts.append(Vector2(pt.x, pt.y + platform_thickness))
		else:
			subsoil_pts.append(Vector2(last_pt.x, local_bottom_y))
			subsoil_pts.append(Vector2(first_pt.x, local_bottom_y))
		subsoil_polygon.polygon = subsoil_pts
		subsoil_polygon.color = active_subsoil_col
		subsoil_polygon.texture = active_subsoil_tex
		subsoil_polygon.texture_scale = Vector2(1.0, 1.0)
		subsoil_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		subsoil_polygon.z_index = 0

		# Planar world-space UV mapping guarantees zero fan distortion, zero shearing,
		# and 100% continuous earth texture across all hills, valleys and segment seams.
		var subsoil_uv := PackedVector2Array()
		var subsoil_colors := PackedColorArray()
		for v in subsoil_pts:
			var world_x: float = position.x + v.x
			var world_y: float = position.y + v.y
			subsoil_uv.append(Vector2(world_x, world_y))
			if is_heaven or is_hell:
				subsoil_colors.append(Color.WHITE)
			else:
				var depth: float = clampf((v.y - visual_surface_band_depth) / 1600.0, 0.0, 1.0)
				var shade: float = lerpf(1.0, 0.68, depth)
				subsoil_colors.append(Color(shade, shade, shade, 1.0))
		subsoil_polygon.uv = subsoil_uv
		subsoil_polygon.vertex_colors = subsoil_colors

	# 3. Grass contour line following collision surface exactly
	if grass_line:
		grass_line.visible = true
		grass_line.points = generated_surface_points
		grass_line.width = 2.0
		grass_line.default_color = active_grass_col
		grass_line.joint_mode = Line2D.LINE_JOINT_ROUND
		grass_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		grass_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		grass_line.antialiased = true
		grass_line.z_index = 2

	if grass_highlight_line:
		grass_highlight_line.visible = false

	# 4. Optional procedural surface details (props, flora, rocks)
	if decorations_root:
		_build_decorations()

func _surface_slope_angle_from_normal(normal: Vector2) -> float:
	# Surface normals point upward in Godot's +Y-down world coordinates.
	# This returns 0 radians for level terrain and the tangent angle on slopes.
	return atan2(normal.x, -normal.y)

func _build_decorations() -> void:
	if not decorations_root:
		return
	for c in decorations_root.get_children():
		c.queue_free()

	if not add_decorations or generated_surface_points.size() < 4:
		return

	# Transition Ramp specific iconic gateway scenery
	if segment_type == SegmentType.RAMP_NORMAL_TO_HEAVEN:
		var arch_idx := int(generated_surface_points.size() * 0.5)
		var arch_pt := generated_surface_points[arch_idx]
		var arch := Sprite2D.new()
		arch.name = "TransitionGoldenGateway"
		arch.texture = load("res://assets/environments/heaven/architecture/heaven_golden_archway.png")
		arch.scale = Vector2(0.55, 0.55)
		arch.offset = Vector2(0, -arch.texture.get_height() * 0.5)
		arch.position = arch_pt + Vector2(0, 10)
		arch.z_index = -3
		decorations_root.add_child(arch)
		return

	if segment_type == SegmentType.RAMP_NORMAL_TO_HELL:
		var skull := Sprite2D.new()
		skull.name = "TransitionDragonSkullPortal"
		skull.visible = false
		skull.z_index = -3
		decorations_root.add_child(skull)
		return

	if segment_type == SegmentType.RAMP_HEAVEN_TO_NORMAL:
		var col_idx := int(generated_surface_points.size() * 0.3)
		var col_pt := generated_surface_points[col_idx]
		var col := Sprite2D.new()
		col.name = "ReturnPalaceColumn"
		col.texture = load("res://assets/environments/heaven/architecture/heaven_palace_column.png")
		col.scale = Vector2(0.4, 0.4)
		col.offset = Vector2(0, -col.texture.get_height() * 0.5)
		col.position = col_pt + Vector2(0, 10)
		col.z_index = -3
		decorations_root.add_child(col)
		return

	if segment_type == SegmentType.RAMP_HELL_TO_NORMAL:
		var vent_idx := int(generated_surface_points.size() * 0.4)
		var v_pt := generated_surface_points[vent_idx]
		var vent := Sprite2D.new()
		vent.name = "EscapeMagmaVent"
		vent.texture = load("res://assets/environments/hell/terrain/magma_vent_fissure_prop.png")
		vent.scale = Vector2(0.55, 0.55)
		vent.offset = Vector2(0, -vent.texture.get_height() * 0.5)
		vent.position = v_pt + Vector2(0, 5)
		vent.z_index = -3
		decorations_root.add_child(vent)
		return

	if terrain_profile and "decorations_enabled" in terrain_profile and not terrain_profile.decorations_enabled:
		return

	# Deterministic seeded placement anchored to segment position
	var seed_val := int(absf(global_position.x) + 7919)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val

	var prof_name: String = str(terrain_profile.get("profile_name")) if terrain_profile else ""
	var is_heaven := prof_name.begins_with("Heaven")
	var is_hell := prof_name.begins_with("Hell")

	# Five widely spaced dressing zones make the long route feel inhabited
	# without turning the driving line into a cluttered obstacle course.
	var slot_fractions: Array[float] = [
		rng.randf_range(0.12, 0.19),
		rng.randf_range(0.30, 0.38),
		rng.randf_range(0.48, 0.56),
		rng.randf_range(0.68, 0.76),
		rng.randf_range(0.86, 0.94)
	]

	for frac in slot_fractions:
		var local_x := frac * segment_length
		var pt_info := get_surface_point_and_normal_at(local_x)
		var pt: Vector2 = pt_info["point"]
		var normal: Vector2 = pt_info["normal"]
		var slope_angle := _surface_slope_angle_from_normal(normal)
		var slope_deg := absf(rad_to_deg(slope_angle))

		if is_heaven:
			# Heaven celestial flora & marble details
			var flower_tex: Texture2D = TEX_HEAVEN_FLOWERS[rng.randi() % TEX_HEAVEN_FLOWERS.size()]
			var spr := Sprite2D.new()
			spr.texture = flower_tex
			spr.z_index = -1
			var sc := rng.randf_range(0.45, 0.58)
			spr.scale = Vector2(sc, sc)
			spr.offset = Vector2(0, -flower_tex.get_height() * 0.5 + 3)
			spr.position = pt
			spr.rotation = clampf(slope_angle * 0.3, -0.25, 0.25)
			decorations_root.add_child(spr)
		elif is_hell:
			# Hell volcanic rubble & obsidian spikes
			var rock_tex: Texture2D = TEX_HELL_ROCKS[rng.randi() % TEX_HELL_ROCKS.size()]
			var spr := Sprite2D.new()
			spr.texture = rock_tex
			spr.modulate = Color(0.96, 0.91, 0.86, 1.0)
			spr.z_index = 1 # Small foreground boulders sit on the crust, not behind it.
			var sc := rng.randf_range(0.16, 0.22)
			spr.scale = Vector2(sc, sc)
			spr.offset = Vector2(0, -rock_tex.get_height() * 0.5 + 3)
			spr.position = pt
			spr.rotation = clampf(slope_angle * 0.25, -0.22, 0.22)
			decorations_root.add_child(spr)
		else:
			# Normal Land Countryside: balanced blend of flora, props, and bushes
			var choice := rng.randf()
			if slope_deg < 24.0 and choice < 0.35:
				# Countryside wooden fence, broken fence, signpost, stump, stones, hay bale, or log
				var prop_tex: Texture2D = TEX_PROPS[rng.randi() % TEX_PROPS.size()]
				var spr := Sprite2D.new()
				spr.texture = prop_tex
				spr.z_index = -2 # Behind car and flora
				var sc := rng.randf_range(0.48, 0.62)
				spr.scale = Vector2(sc, sc)
				spr.offset = Vector2(0, -prop_tex.get_height() * 0.5 + 2)
				spr.position = pt
				# Keep fences and structures upright with gentle terrain tilt
				spr.rotation = clampf(slope_angle * 0.22, -0.18, 0.18)
				decorations_root.add_child(spr)
			elif choice < 0.70:
				# Rounded green bush, berry bush, or lavender shrub
				var bush_tex: Texture2D = TEX_BUSHES[rng.randi() % TEX_BUSHES.size()]
				var spr := Sprite2D.new()
				spr.texture = bush_tex
				spr.z_index = -1
				var sc := rng.randf_range(0.38, 0.52) if bush_tex.get_height() > 180 else rng.randf_range(0.55, 0.70)
				spr.scale = Vector2(sc, sc)
				spr.offset = Vector2(0, -bush_tex.get_height() * 0.5 + 2)
				spr.position = pt
				spr.rotation = clampf(slope_angle * 0.30, -0.25, 0.25)
				decorations_root.add_child(spr)
			else:
				# Wild ferns, grass clumps, yellow/purple flowers, or small tufts
				var flora_tex: Texture2D = TEX_FLOWERS[rng.randi() % TEX_FLOWERS.size()]
				var spr := Sprite2D.new()
				spr.texture = flora_tex
				spr.z_index = -1
				var sc := rng.randf_range(0.42, 0.58) if flora_tex.get_width() > 180 else rng.randf_range(0.58, 0.76)
				spr.scale = Vector2(sc, sc)
				spr.offset = Vector2(0, -flora_tex.get_height() * 0.5 + 2)
				spr.position = pt
				spr.rotation = clampf(slope_angle * 0.30, -0.25, 0.25)
				decorations_root.add_child(spr)
