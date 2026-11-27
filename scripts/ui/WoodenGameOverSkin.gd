class_name WoodenGameOverSkin
extends RefCounted

## WoodenGameOverSkin: shared helpers for the wooden "GAME OVER" panel used by Endless
## (ResultsScreenController) and Survival (SurvivalController). Opt-in only: the scenes
## themselves are not changed, so any other user of those scenes keeps its original look.
## Existing labels/buttons are MOVED onto the wooden art (same nodes, signals and unique names).

const DIR := "res://assets/ui/gameover_wood/"
const FONT: FontFile = preload("res://assets/fonts/Kenney_Future.ttf")
const WHITE := Color(1.0, 0.98, 0.93)
const YELLOW := Color(1.0, 0.86, 0.12)
const OUTLINE := Color(0.13, 0.06, 0.02)

## Source-pixel geometry of gameover_panel.png (1000x894).
const PANEL_SRC := Vector2(1000.0, 894.0)
const SUBTITLE_RECT := Rect2(190.0, 130.0, 660.0, 92.0)
const REASON_RECT := Rect2(110.0, 252.0, 780.0, 62.0)
const BADGE_RECT := Rect2(250.0, 312.0, 500.0, 34.0)
const ROW_TOPS := [360.0, 437.0, 512.0, 586.0]
const ROW_H := 66.0
const LABEL_X := Vector2(112.0, 520.0)   # x, width of the left (tag) column
const VALUE_X := Vector2(560.0, 330.0)   # x, width of the right (value) column
const BUTTON_SLOT := Rect2(86.0, 673.0, 828.0, 157.0)
## The plank art's nailed ends (source px) stay undistorted when a plank is resized.
const PLANK_END_MARGIN := 70.0

## Turns `host` (the existing panel) into the wooden panel and returns the art node that
## other nodes are attached to. `width` is the on-screen panel width.
static func build_panel(host: Control, width: float) -> TextureRect:
	var s := width / PANEL_SRC.x
	if host is PanelContainer:
		host.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	for child in host.get_children():
		if child is CanvasItem:
			child.visible = false
	host.custom_minimum_size = PANEL_SRC * s
	var art := TextureRect.new()
	art.name = "WoodGameOverArt"
	art.texture = load(DIR + "gameover_panel.png")
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(art)
	if not (host is Container):
		art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return art

## Re-parents `c` onto the art and places it at `src_rect` (source px).
static func place(c: Control, art: Control, src_rect: Rect2, s: float) -> void:
	if c.get_parent() != art:
		c.reparent(art, false)
	c.visible = true
	c.custom_minimum_size = Vector2.ZERO
	c.anchor_left = 0.0
	c.anchor_top = 0.0
	c.anchor_right = 0.0
	c.anchor_bottom = 0.0
	c.offset_left = src_rect.position.x * s
	c.offset_top = src_rect.position.y * s
	c.offset_right = src_rect.end.x * s
	c.offset_bottom = src_rect.end.y * s

static func style_label(lbl: Label, font_size: int, color: Color, outline: int, align: HorizontalAlignment) -> void:
	lbl.add_theme_font_override("font", FONT)
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", OUTLINE)
	lbl.add_theme_constant_override("outline_size", outline)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	lbl.horizontal_alignment = align
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.uppercase = true
	lbl.clip_text = false
	lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE

static var _scaled_cache: Dictionary = {}

## StyleBoxTexture draws its 9-slice borders at the texture's own pixel size, so the plank art
## is pre-scaled to on-screen size once; the nailed ends then keep their true proportions.
static func _scaled_texture(file_name: String, s: float) -> Texture2D:
	var key := "%s@%.3f" % [file_name, s]
	if _scaled_cache.has(key):
		return _scaled_cache[key]
	var src := load(DIR + file_name + ".png") as Texture2D
	var img := src.get_image()
	img.resize(maxi(1, int(round(img.get_width() * s))), maxi(1, int(round(img.get_height() * s))), Image.INTERPOLATE_LANCZOS)
	var tex := ImageTexture.create_from_image(img)
	_scaled_cache[key] = tex
	return tex

static func _plank(file_name: String, s: float) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = _scaled_texture(file_name, s)
	# 9-slice: keep the nailed ends intact, stretch/shrink only the middle.
	sb.texture_margin_left = PLANK_END_MARGIN * s
	sb.texture_margin_right = PLANK_END_MARGIN * s
	sb.texture_margin_top = 20.0 * s
	sb.texture_margin_bottom = 20.0 * s
	sb.set_content_margin_all(0.0)
	return sb

static func style_button(btn: Button, s: float, font_size: int) -> void:
	btn.add_theme_stylebox_override("normal", _plank("gameover_button_plank", s))
	btn.add_theme_stylebox_override("hover", _plank("gameover_button_plank_hover", s))
	btn.add_theme_stylebox_override("pressed", _plank("gameover_button_plank_pressed", s))
	btn.add_theme_stylebox_override("hover_pressed", _plank("gameover_button_plank_pressed", s))
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_font_override("font", FONT)
	btn.add_theme_font_size_override("font_size", font_size)
	for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		btn.add_theme_color_override(key, WHITE)
	btn.add_theme_color_override("font_outline_color", OUTLINE)
	btn.add_theme_constant_override("outline_size", maxi(6, int(font_size * 0.4)))
	btn.icon = null

## Creates a stat-row tag+value label pair on the art (used by Survival, which has no stat labels).
static func make_row(art: Control, row: int, tag_text: String, s: float, value_color: Color) -> Label:
	var tag := Label.new()
	tag.name = "WoodRowTag%d" % row
	tag.text = tag_text
	style_label(tag, int(round(38.0 * s)), WHITE, int(round(15.0 * s)), HORIZONTAL_ALIGNMENT_LEFT)
	art.add_child(tag)
	place(tag, art, Rect2(LABEL_X.x, ROW_TOPS[row], LABEL_X.y, ROW_H), s)
	var value := Label.new()
	value.name = "WoodRowValue%d" % row
	style_label(value, int(round(46.0 * s)), value_color, int(round(17.0 * s)), HORIZONTAL_ALIGNMENT_RIGHT)
	art.add_child(value)
	place(value, art, Rect2(VALUE_X.x, ROW_TOPS[row], VALUE_X.y, ROW_H), s)
	return value
