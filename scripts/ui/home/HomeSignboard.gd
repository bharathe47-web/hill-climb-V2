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

@export_group("Wind Animation")
@export_range(0.0, 8.0, 0.1) var wind_max_angle_deg: float = 3.0
@export var wind_phase_offset: float = 0.0
@export_range(0.0, 1.5, 0.02) var wind_delay_seconds: float = 0.0
@export var wind_spring_stiffness: float = 28.0
@export var wind_spring_damping: float = 5.6

signal activated

var _tween: Tween = null
var _base_pos_x: float = 0.0
var _wind_intensity: float = 0.0
var _wind_time: float = 0.0
var _wind_angular_vel: float = 0.0

# Gentle idle sway so the board reads as genuinely hanging from its chains rather than
# a static, pinned sprite. Small and slow enough to never interfere with the hover/press reads.
var _idle_time: float = 0.0
@export var idle_sway_degrees: float = 1.4
@export var idle_sway_speed: float = 0.8

func _ready() -> void:
	ignore_texture_size = true
	stretch_mode = TextureButton.STRETCH_SCALE
	focus_mode = Control.FOCUS_ALL
	_base_pos_x = position.x
	# Pivot at the chain suspension point so chains stay anchored while the board swings
	# (used by both the idle sway and the wind swing).
	var hinge_y := minf(chain_top_y - position.y + 8.0, 6.0)
	pivot_offset = Vector2(size.x * 0.5, hinge_y)
	_idle_time = randf() * TAU
	_build_chains()
	if coming_soon:
		modulate = Color(0.72, 0.72, 0.72, 1.0)
		_build_coming_soon_tag()
	mouse_entered.connect(func(): _animate(1.03, Color(1.12, 1.1, 1.05, 1.0)))
	mouse_exited.connect(func(): _animate(1.0, _rest_color()))
	focus_entered.connect(func(): _animate(1.03, Color(1.12, 1.1, 1.05, 1.0)))
	focus_exited.connect(func(): _animate(1.0, _rest_color()))
	button_down.connect(func(): _animate(0.97, Color(0.85, 0.8, 0.75, 1.0)))
	button_up.connect(func(): _animate(1.03 if is_hovered() else 1.0, _rest_color()))
	pressed.connect(func(): activated.emit())

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var has_wind := _wind_intensity > 0.001
	var has_idle := idle_sway_degrees > 0.0
	var at_rest := not has_wind and not has_idle and absf(rotation) < 0.0002 and absf(_wind_angular_vel) < 0.0005
	if at_rest:
		if rotation != 0.0:
			rotation = 0.0
			_wind_angular_vel = 0.0
		return

	var dt := minf(delta, 0.05)
	_wind_time += dt
	_idle_time += dt
	# Combined motion: a gentle idle sway (board hanging from its chains) that fades out as the
	# wind picks up, plus the wind swing. The spring below follows this target, so switching
	# between calm and windy is always smooth.
	var target_angle := 0.0
	if has_idle:
		target_angle += sin(_idle_time * idle_sway_speed) * deg_to_rad(idle_sway_degrees) * (1.0 - _wind_intensity)
	if has_wind:
		# Left-to-right wind swings a bottom-hanging board counter-clockwise (negative angle in 2D).
		var sway := 0.82 + 0.18 * sin(_wind_time * 3.1 + wind_phase_offset)
		target_angle += -deg_to_rad(wind_max_angle_deg) * _wind_intensity * sway

	var accel := (target_angle - rotation) * wind_spring_stiffness - _wind_angular_vel * wind_spring_damping
	_wind_angular_vel += accel * dt
	rotation += _wind_angular_vel * dt

func set_wind_intensity(intensity: float) -> void:
	_wind_intensity = clampf(intensity, 0.0, 1.0)

func reset_wind() -> void:
	_wind_intensity = 0.0
	_wind_angular_vel = 0.0
	rotation = 0.0

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
	_tween = create_tween()
	for dx in [-6.0, 6.0, -4.0, 4.0, 0.0]:
		_tween.tween_property(self, "position:x", _base_pos_x + dx, 0.04)

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
