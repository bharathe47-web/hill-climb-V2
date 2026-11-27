class_name SurvivalDifficultyMenu
extends Control

## SurvivalDifficultyMenu: Three-difficulty selection interface for Survival Mode.
## Features three authentic wooden hanging signboards (EASY, MEDIUM, HARD) suspended by metal chains,
## golden highlight outlines, gentle scale and hanging sway/bounce animation on selection,
## distinct themed info cards beneath each signboard with Level, Multiplier, Description & Hazards,
## dynamic status text displaying full difficulty details beneath, and Start Survival / Back navigation.

signal difficulty_selected(difficulty: int)
signal start_survival_pressed(difficulty: int)
signal back_pressed

const SaveManager = preload("res://scripts/core/SaveManager.gd")
const SurvivalDifficultyConfig = preload("res://scripts/modes/survival/SurvivalDifficultyConfig.gd")

@onready var easy_card: Control = get_node_or_null("%EasyCard")
@onready var medium_card: Control = get_node_or_null("%MediumCard")
@onready var hard_card: Control = get_node_or_null("%HardCard")

@onready var easy_button: BaseButton = get_node_or_null("%EasyButton")
@onready var medium_button: BaseButton = get_node_or_null("%MediumButton")
@onready var hard_button: BaseButton = get_node_or_null("%HardButton")

@onready var easy_highlight: TextureRect = get_node_or_null("%EasyHighlight")
@onready var medium_highlight: TextureRect = get_node_or_null("%MediumHighlight")
@onready var hard_highlight: TextureRect = get_node_or_null("%HardHighlight")

@onready var easy_info_panel: PanelContainer = get_node_or_null("%EasyInfoPanel")
@onready var medium_info_panel: PanelContainer = get_node_or_null("%MediumInfoPanel")
@onready var hard_info_panel: PanelContainer = get_node_or_null("%HardInfoPanel")

@onready var selected_status_label: Label = get_node_or_null("%SelectedStatusLabel")
@onready var start_button: BaseButton = get_node_or_null("%StartSurvivalButton")
@onready var back_button: BaseButton = get_node_or_null("%BackButton")

var current_difficulty: int = 0
var _card_tweens: Dictionary = {}
var _sign_tweens: Dictionary = {}
var _button_tweens: Dictionary = {}

var _style_normal: StyleBoxFlat
var _style_easy_sel: StyleBoxFlat
var _style_med_sel: StyleBoxFlat
var _style_hard_sel: StyleBoxFlat

func _ready() -> void:
	_init_styles()
	_init_card_pivots()
	_connect_signals()
	# Load previously selected or default difficulty
	var saved_diff: int = SaveManager.get_survival_difficulty()
	select_difficulty(saved_diff, false)

func _init_styles() -> void:
	_style_normal = _create_panel_style(Color(0.25, 0.35, 0.48, 0.7), 1, Color(0.07, 0.1, 0.15, 0.92))
	_style_easy_sel = _create_panel_style(Color(0.35, 0.9, 0.45, 0.95), 2, Color(0.08, 0.14, 0.12, 0.95))
	_style_med_sel = _create_panel_style(Color(1.0, 0.82, 0.25, 0.95), 2, Color(0.14, 0.12, 0.08, 0.95))
	_style_hard_sel = _create_panel_style(Color(1.0, 0.35, 0.35, 0.95), 2, Color(0.14, 0.08, 0.09, 0.95))

func _create_panel_style(border_col: Color, border_w: int, bg_col: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_width_left = border_w
	sb.border_width_top = border_w
	sb.border_width_right = border_w
	sb.border_width_bottom = border_w
	sb.border_color = border_col
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_right = 10
	sb.corner_radius_bottom_left = 10
	return sb

func _init_card_pivots() -> void:
	# Set top-center pivot so signboards naturally swing from their top hanging chains
	for card in [easy_card, medium_card, hard_card]:
		if is_instance_valid(card):
			var w: float = card.custom_minimum_size.x if card.custom_minimum_size.x > 0 else card.size.x
			card.pivot_offset = Vector2(w * 0.5, 0.0)
			var sc: Control = card.find_child("SignboardContainer", true, false)
			if is_instance_valid(sc):
				var sw: float = sc.custom_minimum_size.x if sc.custom_minimum_size.x > 0 else sc.size.x
				sc.pivot_offset = Vector2(sw * 0.5, 0.0)

func _connect_signals() -> void:
	if is_instance_valid(easy_button):
		if not easy_button.pressed.is_connected(_on_easy_pressed):
			easy_button.pressed.connect(_on_easy_pressed)
		if not easy_button.mouse_entered.is_connected(_on_easy_hover):
			easy_button.mouse_entered.connect(_on_easy_hover)
		if not easy_button.mouse_exited.is_connected(_on_card_unhover):
			easy_button.mouse_exited.connect(_on_card_unhover)

	if is_instance_valid(medium_button):
		if not medium_button.pressed.is_connected(_on_medium_pressed):
			medium_button.pressed.connect(_on_medium_pressed)
		if not medium_button.mouse_entered.is_connected(_on_medium_hover):
			medium_button.mouse_entered.connect(_on_medium_hover)
		if not medium_button.mouse_exited.is_connected(_on_card_unhover):
			medium_button.mouse_exited.connect(_on_card_unhover)

	if is_instance_valid(hard_button):
		if not hard_button.pressed.is_connected(_on_hard_pressed):
			hard_button.pressed.connect(_on_hard_pressed)
		if not hard_button.mouse_entered.is_connected(_on_hard_hover):
			hard_button.mouse_entered.connect(_on_hard_hover)
		if not hard_button.mouse_exited.is_connected(_on_card_unhover):
			hard_button.mouse_exited.connect(_on_card_unhover)

	if is_instance_valid(start_button):
		if not start_button.pressed.is_connected(_on_start_pressed):
			start_button.pressed.connect(_on_start_pressed)
		_setup_wooden_button(start_button)
	if is_instance_valid(back_button):
		if not back_button.pressed.is_connected(_on_back_pressed):
			back_button.pressed.connect(_on_back_pressed)
		_setup_wooden_button(back_button)

## Connects subtle hover and press-down feedback without rotating or shaking the wooden button.
func _setup_wooden_button(btn: BaseButton) -> void:
	btn.pivot_offset = btn.size * 0.5
	if not btn.resized.is_connected(_on_wooden_button_resized.bind(btn)):
		btn.resized.connect(_on_wooden_button_resized.bind(btn))
	if not btn.mouse_entered.is_connected(_on_wooden_button_hover.bind(btn, true)):
		btn.mouse_entered.connect(_on_wooden_button_hover.bind(btn, true))
	if not btn.mouse_exited.is_connected(_on_wooden_button_hover.bind(btn, false)):
		btn.mouse_exited.connect(_on_wooden_button_hover.bind(btn, false))
	if not btn.button_down.is_connected(_on_wooden_button_press.bind(btn, true)):
		btn.button_down.connect(_on_wooden_button_press.bind(btn, true))
	if not btn.button_up.is_connected(_on_wooden_button_press.bind(btn, false)):
		btn.button_up.connect(_on_wooden_button_press.bind(btn, false))

func _on_wooden_button_resized(btn: BaseButton) -> void:
	if is_instance_valid(btn):
		btn.pivot_offset = btn.size * 0.5

func _on_wooden_button_hover(btn: BaseButton, hovered: bool) -> void:
	if not is_instance_valid(btn) or btn.disabled:
		return
	var target_scale := Vector2(1.03, 1.03) if hovered else Vector2.ONE
	var target_mod := Color(1.09, 1.06, 1.02, 1.0) if hovered else Color.WHITE
	_animate_wooden_button(btn, target_scale, target_mod, 0.09)

func _on_wooden_button_press(btn: BaseButton, pressed: bool) -> void:
	if not is_instance_valid(btn) or btn.disabled:
		return
	if pressed:
		_animate_wooden_button(btn, Vector2(0.96, 0.96), Color(0.90, 0.87, 0.84, 1.0), 0.06)
	else:
		var hovered := btn.is_hovered()
		var target_scale := Vector2(1.03, 1.03) if hovered else Vector2.ONE
		var target_mod := Color(1.09, 1.06, 1.02, 1.0) if hovered else Color.WHITE
		_animate_wooden_button(btn, target_scale, target_mod, 0.08)

func _animate_wooden_button(btn: BaseButton, target_scale: Vector2, target_mod: Color, duration: float) -> void:
	btn.pivot_offset = btn.size * 0.5
	if _button_tweens.has(btn) and is_instance_valid(_button_tweens[btn]):
		_button_tweens[btn].kill()
	var tw := create_tween().set_parallel(true)
	_button_tweens[btn] = tw
	tw.tween_property(btn, "scale", target_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(btn, "modulate", target_mod, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func select_difficulty(diff: int, animate: bool = true) -> void:
	current_difficulty = clampi(diff, 0, 2)
	SaveManager.set_survival_difficulty(current_difficulty)
	_update_card_highlights(animate)
	difficulty_selected.emit(current_difficulty)

func get_selected_difficulty() -> int:
	return current_difficulty

func _update_card_highlights(animate: bool = true) -> void:
	var cards_data := [
		{"card": easy_card, "hl": easy_highlight, "panel": easy_info_panel, "sel_style": _style_easy_sel, "diff": SurvivalDifficultyConfig.Difficulty.EASY},
		{"card": medium_card, "hl": medium_highlight, "panel": medium_info_panel, "sel_style": _style_med_sel, "diff": SurvivalDifficultyConfig.Difficulty.MEDIUM},
		{"card": hard_card, "hl": hard_highlight, "panel": hard_info_panel, "sel_style": _style_hard_sel, "diff": SurvivalDifficultyConfig.Difficulty.HARD}
	]

	for data in cards_data:
		var card: Control = data["card"]
		var hl: TextureRect = data["hl"]
		var panel: PanelContainer = data["panel"]
		var sel_style: StyleBoxFlat = data["sel_style"]
		var diff_val: int = data["diff"]
		var is_selected: bool = (current_difficulty == diff_val)

		if is_instance_valid(hl):
			hl.visible = is_selected

		if is_instance_valid(panel) and _style_normal != null:
			panel.add_theme_stylebox_override("panel", sel_style if is_selected else _style_normal)

		if is_instance_valid(card):
			var w: float = card.size.x if card.size.x > 0 else card.custom_minimum_size.x
			card.pivot_offset = Vector2(w * 0.5, 0.0)
			card.z_index = 2 if is_selected else 0

			var sc: Control = card.find_child("SignboardContainer", true, false)
			if is_instance_valid(sc):
				var sw: float = sc.size.x if sc.size.x > 0 else sc.custom_minimum_size.x
				sc.pivot_offset = Vector2(sw * 0.5, 0.0)

			# Kill any existing tweens on this card and its signboard
			if _card_tweens.has(card) and is_instance_valid(_card_tweens[card]):
				_card_tweens[card].kill()
			if is_instance_valid(sc) and _sign_tweens.has(sc) and is_instance_valid(_sign_tweens[sc]):
				_sign_tweens[sc].kill()

			if is_selected:
				if animate:
					var tw := create_tween()
					_card_tweens[card] = tw
					tw.tween_property(card, "scale", Vector2(1.04, 1.04), 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					
					if is_instance_valid(sc):
						var stw := create_tween()
						_sign_tweens[sc] = stw
						stw.tween_property(sc, "rotation_degrees", -1.5, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
						stw.tween_property(sc, "rotation_degrees", 1.1, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
						stw.tween_property(sc, "rotation_degrees", -0.4, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
						stw.tween_property(sc, "rotation_degrees", 0.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				else:
					card.scale = Vector2(1.04, 1.04)
					card.rotation_degrees = 0.0
					if is_instance_valid(sc):
						sc.rotation_degrees = 0.0
			else:
				if animate:
					var tw := create_tween()
					_card_tweens[card] = tw
					tw.tween_property(card, "scale", Vector2(1.0, 1.0), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					card.rotation_degrees = 0.0
					if is_instance_valid(sc):
						var stw := create_tween()
						_sign_tweens[sc] = stw
						stw.tween_property(sc, "rotation_degrees", 0.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				else:
					card.scale = Vector2(1.0, 1.0)
					card.rotation_degrees = 0.0
					if is_instance_valid(sc):
						sc.rotation_degrees = 0.0

	_update_status_label()

func _update_status_label() -> void:
	if not is_instance_valid(selected_status_label):
		return
	var cfg := SurvivalDifficultyConfig.get_config(current_difficulty)
	var mult: float = float(cfg.get("score_multiplier", 1.0))
	match current_difficulty:
		SurvivalDifficultyConfig.Difficulty.EASY:
			selected_status_label.text = "DIFFICULTY: EASY (%.1fx)  —  Survive falling obstacles!  •  Indian Street Foods & Warnings" % mult
			selected_status_label.modulate = Color(0.4, 1.0, 0.5, 1.0)
		SurvivalDifficultyConfig.Difficulty.MEDIUM:
			selected_status_label.text = "DIFFICULTY: MEDIUM (%.1fx)  —  Watch out for unexpected asteroids!  •  Unburned Asteroids" % mult
			selected_status_label.modulate = Color(1.0, 0.85, 0.3, 1.0)
		SurvivalDifficultyConfig.Difficulty.HARD:
			selected_status_label.text = "DIFFICULTY: HARD (%.1fx)  —  Apocalyptic Hell!  •  Burning Asteroids, Fire Craters & Potholes" % mult
			selected_status_label.modulate = Color(1.0, 0.35, 0.35, 1.0)

func _on_easy_hover() -> void:
	if current_difficulty != SurvivalDifficultyConfig.Difficulty.EASY and is_instance_valid(easy_card):
		var tw := create_tween()
		tw.tween_property(easy_card, "scale", Vector2(1.02, 1.02), 0.15)

func _on_medium_hover() -> void:
	if current_difficulty != SurvivalDifficultyConfig.Difficulty.MEDIUM and is_instance_valid(medium_card):
		var tw := create_tween()
		tw.tween_property(medium_card, "scale", Vector2(1.02, 1.02), 0.15)

func _on_hard_hover() -> void:
	if current_difficulty != SurvivalDifficultyConfig.Difficulty.HARD and is_instance_valid(hard_card):
		var tw := create_tween()
		tw.tween_property(hard_card, "scale", Vector2(1.02, 1.02), 0.15)

func _on_card_unhover() -> void:
	# Reset scale for unselected cards
	if current_difficulty != SurvivalDifficultyConfig.Difficulty.EASY and is_instance_valid(easy_card):
		var tw := create_tween()
		tw.tween_property(easy_card, "scale", Vector2(1.0, 1.0), 0.15)
	if current_difficulty != SurvivalDifficultyConfig.Difficulty.MEDIUM and is_instance_valid(medium_card):
		var tw := create_tween()
		tw.tween_property(medium_card, "scale", Vector2(1.0, 1.0), 0.15)
	if current_difficulty != SurvivalDifficultyConfig.Difficulty.HARD and is_instance_valid(hard_card):
		var tw := create_tween()
		tw.tween_property(hard_card, "scale", Vector2(1.0, 1.0), 0.15)

func _on_easy_pressed() -> void:
	select_difficulty(SurvivalDifficultyConfig.Difficulty.EASY)

func _on_medium_pressed() -> void:
	select_difficulty(SurvivalDifficultyConfig.Difficulty.MEDIUM)

func _on_hard_pressed() -> void:
	select_difficulty(SurvivalDifficultyConfig.Difficulty.HARD)

func _on_start_pressed() -> void:
	start_survival_pressed.emit(current_difficulty)

func _on_back_pressed() -> void:
	back_pressed.emit()
