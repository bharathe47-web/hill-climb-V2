class_name PauseMenuController
extends Control

## PauseMenuController: Handles the pause overlay, resume, and restart actions.

signal menu_requested

@onready var resume_button: Button = %ResumeButton
@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var panel: PanelContainer = get_node_or_null("%Panel")

var _entrance_tween: Tween = null

var game_manager_ref: Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if is_instance_valid(resume_button):
		resume_button.pressed.connect(_on_resume_pressed)
	if is_instance_valid(retry_button):
		retry_button.pressed.connect(_on_retry_pressed)
	if is_instance_valid(main_menu_button):
		main_menu_button.pressed.connect(_on_main_menu_pressed)

func bind_game_manager(gm: Node) -> void:
	game_manager_ref = gm
	if not is_instance_valid(gm):
		return
	
	if gm.has_signal("run_paused") and not gm.run_paused.is_connected(_on_run_paused):
		gm.run_paused.connect(_on_run_paused)
	if gm.has_signal("run_started") and not gm.run_started.is_connected(_on_run_started):
		gm.run_started.connect(_on_run_started)
	if gm.has_signal("run_restarted") and not gm.run_restarted.is_connected(_on_run_started):
		gm.run_restarted.connect(_on_run_started)

func _on_run_paused(is_paused: bool) -> void:
	visible = is_paused
	if visible:
		_play_entrance_animation()
		if is_instance_valid(resume_button):
			resume_button.grab_focus()

## Small scale+fade pop so the pause card arrives with a bit of weight instead of snapping
## instantly to full size.
func _play_entrance_animation() -> void:
	if not is_instance_valid(panel):
		return
	if _entrance_tween and _entrance_tween.is_valid():
		_entrance_tween.kill()
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.82, 0.82)
	panel.modulate.a = 0.0
	_entrance_tween = create_tween().set_parallel(true)
	_entrance_tween.tween_property(panel, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_entrance_tween.tween_property(panel, "modulate:a", 1.0, 0.18)

func _on_run_started() -> void:
	visible = false

func _on_resume_pressed() -> void:
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("pause_run"):
		game_manager_ref.pause_run(false)
	else:
		visible = false
		get_tree().paused = false

func _on_retry_pressed() -> void:
	visible = false
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("restart_run"):
		game_manager_ref.restart_run()

func _on_main_menu_pressed() -> void:
	visible = false
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("pause_run"):
		game_manager_ref.pause_run(false)
	else:
		get_tree().paused = false
	menu_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_on_resume_pressed()
	elif event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		_on_retry_pressed()

# =========================================================================
# WOODEN PAUSE MENU SKIN (opt-in)
# Called only by Endless (Game.gd) and Survival (SurvivalController.gd). PauseMenu.tscn itself is
# unchanged, so other users (Indian Roads, tests) keep the original look.
# The real Resume/Retry/Main Menu Buttons are kept (same nodes, signals and focus); they are only
# restyled with the wooden plank art and placed exactly over the panel art's button slots.
# =========================================================================

const WOOD_PAUSE_DIR := "res://assets/ui/pause_wood/"
const WOOD_PAUSE_FONT: FontFile = preload("res://assets/fonts/Kenney_Future.ttf")
## Source-pixel geometry of pause_panel.png (537x527): plank slots incl. outline.
const WOOD_PANEL_SRC := Vector2(537.0, 527.0)
const WOOD_SLOTS_TOP := 150.0
const WOOD_SLOTS_BOTTOM := 449.0
const WOOD_SLOTS_LEFT := 78.0
const WOOD_SLOTS_RIGHT := 462.0
const WOOD_SLOT_GAP := 13.0
const WOOD_PLANK_H := 89.0
## On-screen width of the wooden panel.
const WOOD_PANEL_WIDTH := 400.0

var wooden_skin_applied: bool = false

func _wood_pause_tex(n: String) -> Texture2D:
	return load(WOOD_PAUSE_DIR + n + ".png") as Texture2D

func _wood_plank_style(tex_name: String) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = _wood_pause_tex(tex_name)
	return sb

func apply_wooden_skin() -> void:
	if wooden_skin_applied or not is_instance_valid(panel):
		return
	wooden_skin_applied = true
	var s := WOOD_PANEL_WIDTH / WOOD_PANEL_SRC.x

	var panel_style := StyleBoxTexture.new()
	panel_style.texture = _wood_pause_tex("pause_panel")
	panel.add_theme_stylebox_override("panel", panel_style)
	panel.custom_minimum_size = WOOD_PANEL_SRC * s

	var margin := panel.get_node_or_null("Margin") as MarginContainer
	var vbox: VBoxContainer = null
	if margin:
		margin.add_theme_constant_override("margin_left", int(round(WOOD_SLOTS_LEFT * s)))
		margin.add_theme_constant_override("margin_right", int(round((WOOD_PANEL_SRC.x - WOOD_SLOTS_RIGHT) * s)))
		margin.add_theme_constant_override("margin_top", int(round(WOOD_SLOTS_TOP * s)))
		margin.add_theme_constant_override("margin_bottom", int(round((WOOD_PANEL_SRC.y - WOOD_SLOTS_BOTTOM) * s)))
		vbox = margin.get_node_or_null("VBox") as VBoxContainer
	if vbox:
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", int(round(WOOD_SLOT_GAP * s)))
		# "PAUSED", "GAME PAUSED" and the key hint are painted on the wooden panel.
		for n in ["Title", "HSeparator", "Hint"]:
			var c := vbox.get_node_or_null(n) as CanvasItem
			if c:
				c.visible = false

	var normal := _wood_plank_style("pause_button_plank")
	var hover := _wood_plank_style("pause_button_plank_hover")
	var pressed_sb := _wood_plank_style("pause_button_plank_pressed")
	for btn in [resume_button, retry_button, main_menu_button]:
		if not is_instance_valid(btn):
			continue
		btn.custom_minimum_size = Vector2(0.0, WOOD_PLANK_H * s)
		btn.add_theme_stylebox_override("normal", normal)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", pressed_sb)
		btn.add_theme_stylebox_override("hover_pressed", pressed_sb)
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		btn.add_theme_font_override("font", WOOD_PAUSE_FONT)
		btn.add_theme_font_size_override("font_size", 24)
		for key in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
			btn.add_theme_color_override(key, Color(1.0, 0.98, 0.93))
		btn.add_theme_color_override("font_outline_color", Color(0.13, 0.06, 0.02))
		btn.add_theme_constant_override("outline_size", 10)
