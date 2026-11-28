class_name HomeSignChains
extends Control

## HomeSignChains: draws the steel chains the home-screen signboards hang from.
## This layer sits in the Stage BEHIND the timber frames, crossbars and signboards, so the
## wood always covers the chains and only the links in the gaps between boards are visible:
## beam -> upper board -> crossbar -> lower board -> short dangling end below the lower board.

## Chain anchor columns inside the 352px-wide plank (match the bolt holes in the plank art).
const CHAIN_X := [45.0, 307.0]
## Visible plank bottom inside the 134px-tall signboard rect (plank art alpha ends at 256/268).
const PLANK_BOTTOM := 128.0
## How far the chain starts above the sign's chain_top_y (hidden behind the beam).
const TOP_OVERLAP := 14.0
## Length of the loose chain end hanging below the lower board.
const DANGLE := 28.0

const LINK_W := 11.0
const LINK_H := 17.0
const LINK_PITCH := 12.5
const OUTLINE := Color(0.13, 0.13, 0.14, 1.0)
const STEEL := Color(0.66, 0.68, 0.70, 1.0)
const STEEL_SHADE := Color(0.43, 0.45, 0.48, 1.0)
const STEEL_HI := Color(0.92, 0.93, 0.95, 1.0)
const SHADOW := Color(0.05, 0.04, 0.03, 0.30)

var _columns: Array = [] # [x, top_y, bottom_y] in this node's local space

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_collect_columns.call_deferred()

func _collect_columns() -> void:
	_columns.clear()
	var parent := get_parent()
	if parent == null:
		return
	var boards: Array = []
	for n in parent.get_children():
		if n is HomeSignboard:
			boards.append(n)
	for top_board in boards:
		var tb := top_board as HomeSignboard
		# A top board hangs from a beam, i.e. its chain_top_y is not inside another board.
		var is_top := true
		for other in boards:
			var o := other as Control
			if o != tb and absf(o.position.x - tb.position.x) < 1.0 and tb.chain_top_y > o.position.y and tb.chain_top_y < o.position.y + o.size.y:
				is_top = false
		if not is_top:
			continue
		# Lowest board in the same column ends the chain.
		var bottom_board: Control = tb
		for other in boards:
			var o := other as Control
			if absf(o.position.x - tb.position.x) < 1.0 and o.position.y > bottom_board.position.y:
				bottom_board = o
		var top_y := tb.chain_top_y - TOP_OVERLAP - position.y
		var bottom_y := bottom_board.position.y + PLANK_BOTTOM + DANGLE - position.y
		for cx in CHAIN_X:
			_columns.append([tb.position.x + cx - position.x, top_y, bottom_y])
	queue_redraw()

func _draw() -> void:
	var off := Vector2(1.5, 2.0)
	for col in _columns:
		var x: float = col[0]
		var links: Array = []
		var y: float = col[1]
		var face_on := true
		while y + LINK_H <= col[2]:
			links.append([face_on, Vector2(x, y + LINK_H * 0.5)])
			y += LINK_PITCH
			face_on = not face_on
		for l in links:
			_draw_link(l[0], l[1] + off, SHADOW, SHADOW, SHADOW, SHADOW)
		for l in links:
			_draw_link(l[0], l[1], OUTLINE, STEEL, STEEL_SHADE, STEEL_HI)

func _ellipse(center: Vector2, rx: float, ry: float, a0: float, a1: float, steps: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(steps + 1):
		var a := lerpf(a0, a1, float(i) / steps)
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	return pts

func _draw_link(face_on: bool, c: Vector2, outline: Color, fill: Color, shade: Color, hi: Color) -> void:
	if face_on:
		# Oval link seen from the front: thick steel ring with an open centre.
		var rx := LINK_W * 0.5 - 1.8
		var ry := LINK_H * 0.5 - 1.8
		var ring := _ellipse(c, rx, ry, 0.0, TAU, 24)
		draw_polyline(ring, outline, 5.6, true)
		draw_polyline(ring, fill, 3.4, true)
		draw_polyline(_ellipse(c, rx, ry, -PI * 0.1, PI * 0.6, 10), shade, 2.0, true)
		draw_polyline(_ellipse(c, rx - 0.4, ry - 0.4, PI * 0.95, PI * 1.5, 10), hi, 1.3, true)
	else:
		# Link seen edge-on: a narrow rounded bar.
		var a := c + Vector2(0, -LINK_H * 0.5 + 2.5)
		var b := c + Vector2(0, LINK_H * 0.5 - 2.5)
		draw_line(a, b, outline, 6.0, true)
		draw_circle(a, 3.0, outline)
		draw_circle(b, 3.0, outline)
		draw_line(a, b, fill, 3.4, true)
		draw_line(a + Vector2(0.8, 0), b + Vector2(0.8, 0), shade, 1.2, true)
		draw_line(a + Vector2(-0.8, 0), b + Vector2(-0.8, 0), hi, 1.0, true)
