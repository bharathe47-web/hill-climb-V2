class_name HomeSignboard
extends TextureButton

## HomeSignboard: A wooden countryside signboard that doubles as a navigation button.
## The plank art (label + icon baked in) is the button texture; two iron chains are
## hanging chains are generated behind it up to the timber frame (or plank) above. The whole board is clickable.

const CHAIN_TEXTURE: Texture2D = preload("res://assets/ui/home_screen/navigation/chain_link.png")
## Chain anchor columns inside the 352px-wide plank (matches the iron rings in the plank art).
const CHAIN_X := [45.0, 307.0]
const CHAIN_WIDTH := 16.0

## Y (in the parent's coordinate space) where the hanging chains start (behind a beam or plank above).
@export var chain_top_y: float = 430.0
## Unavailable boards are dimmed, show a COMING SOON tag, and do not navigate.
@export var coming_soon: bool = false

signal activated

var _tween: Tween = null

func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_SCALE
	focus_mode = Control.FOCUS_ALL
	pivot_offset = size * 0.5
	_build_chains()
	if coming_soon:
		modulate = Color(0.72, 0.72, 0.72, 1.0)
		_build_coming_soon_tag()
	mouse_entered.connect(func(): _animate(1.04, Color(1.12, 1.1, 1.05, 1.0)))
	mouse_exited.connect(func(): _animate(1.0, _rest_color()))
	focus_entered.connect(func(): _animate(1.04, Color(1.12, 1.1, 1.05, 1.0)))
	focus_exited.connect(func(): _animate(1.0, _rest_color()))
	button_down.connect(func(): _animate(0.96, Color(0.85, 0.8, 0.75, 1.0)))
	button_up.connect(func(): _animate(1.04 if is_hovered() else 1.0, _rest_color()))
	pressed.connect(func(): activated.emit())

func _rest_color() -> Color:
	return Color(0.72, 0.72, 0.72, 1.0) if coming_soon else Color.WHITE

func _animate(target_scale: float, target_color: Color) -> void:
	if coming_soon and target_color.r > 1.0:
		target_color = Color(0.8, 0.8, 0.8, 1.0)
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2(target_scale, target_scale), 0.1)
	_tween.tween_property(self, "modulate", target_color, 0.1)

## Small shake used when a coming-soon board is clicked.
func shake() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	var base_x := position.x
	_tween = create_tween()
	for dx in [-6.0, 6.0, -4.0, 4.0, 0.0]:
		_tween.tween_property(self, "position:x", base_x + dx, 0.04)

func _build_chains() -> void:
	var top := chain_top_y - position.y
	var length := maxf(8.0, -top + 12.0)
	for cx in CHAIN_X:
		var chain := TextureRect.new()
		chain.name = "Chain"
		chain.texture = CHAIN_TEXTURE
		chain.stretch_mode = TextureRect.STRETCH_TILE
		chain.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chain.show_behind_parent = true
		chain.position = Vector2(cx - CHAIN_WIDTH * 0.5, top)
		chain.size = Vector2(CHAIN_WIDTH, length)
		add_child(chain)

func _build_coming_soon_tag() -> void:
	var tag := Label.new()
	tag.name = "ComingSoonTag"
	tag.text = "COMING SOON"
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.add_theme_font_override("font", load("res://assets/fonts/Boxy-Bold.ttf"))
	tag.add_theme_font_size_override("font_size", 22)
	tag.add_theme_color_override("font_color", Color(1.0, 0.93, 0.62))
	tag.add_theme_color_override("font_outline_color", Color(0.18, 0.08, 0.02))
	tag.add_theme_constant_override("outline_size", 8)
	tag.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	tag.offset_top = -40.0
	tag.offset_bottom = -6.0
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tag.offset_right = -26.0
	add_child(tag)
