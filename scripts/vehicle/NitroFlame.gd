class_name NitroFlame
extends Node2D

## Dynamic flickering Nitro Flame (Orange outer fire + Intense Blue inner jet core)
## Shoots backward (-X) from vehicle exhaust while nitro is active.

@export var flame_color_outer: Color = Color(1.0, 0.42, 0.05, 0.95) # Fiery orange
@export var flame_color_inner: Color = Color(0.18, 0.72, 1.0, 0.95) # Electric blue
@export var flame_color_core: Color = Color(0.85, 0.95, 1.0, 1.0)  # High-temp ignition root

var is_flickering: bool = false
var flame_scale_mult: float = 1.0

func _ready() -> void:
	z_index = -1
	visible = false

func _process(_delta: float) -> void:
	if visible and is_flickering:
		queue_redraw()

func set_flame_active(active: bool) -> void:
	visible = active
	is_flickering = active
	if active:
		queue_redraw()

func _draw() -> void:
	if not visible:
		return
		
	# Randomized frame-by-frame flicker in length, width, and tip deflection
	var s_mult: float = maxf(flame_scale_mult, 0.5)
	var flame_len: float = randf_range(38.0, 62.0) * s_mult
	var flame_w: float = randf_range(8.0, 15.0) * s_mult
	var tip_y: float = randf_range(-3.0, 3.0) * s_mult
	
	# 1. Outer Flame (Orange) shooting backward along local -X
	var mid_x: float = -flame_len * 0.42
	var outer_pts := PackedVector2Array([
		Vector2(0, -flame_w * 0.45),
		Vector2(mid_x, -flame_w),
		Vector2(-flame_len, tip_y),
		Vector2(mid_x, flame_w),
		Vector2(0, flame_w * 0.45)
	])
	draw_colored_polygon(outer_pts, flame_color_outer)
	
	# 2. Inner Jet Flame (Electric Blue)
	var core_len: float = flame_len * randf_range(0.55, 0.70)
	var core_w: float = flame_w * 0.55
	var core_tip_y: float = tip_y * 0.5
	var core_mid_x: float = -core_len * 0.38
	var inner_pts := PackedVector2Array([
		Vector2(0, -core_w * 0.5),
		Vector2(core_mid_x, -core_w),
		Vector2(-core_len, core_tip_y),
		Vector2(core_mid_x, core_w),
		Vector2(0, core_w * 0.5)
	])
	draw_colored_polygon(inner_pts, flame_color_inner)
	
	# 3. Ignition Root (White-Blue hot nozzle core)
	var root_len: float = core_len * 0.35
	var root_w: float = core_w * 0.45
	var root_pts := PackedVector2Array([
		Vector2(0, -root_w * 0.5),
		Vector2(-root_len * 0.4, -root_w),
		Vector2(-root_len, core_tip_y * 0.3),
		Vector2(-root_len * 0.4, root_w),
		Vector2(0, root_w * 0.5)
	])
	draw_colored_polygon(root_pts, flame_color_core)
