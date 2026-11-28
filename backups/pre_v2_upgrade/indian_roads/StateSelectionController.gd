class_name StateSelectionController
extends Control

## StateSelectionController: Hub for selecting an Indian state route.
## Displays the map of India, sequential lock statuses, and details for the six Version 1 states.

const RouteData = preload("res://resources/routes/RouteData.gd")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

signal route_selected(route: RouteData)
signal return_to_main_menu_requested

@onready var map_texture_rect: TextureRect = %MapTextureRect
@onready var route_cards_container: HBoxContainer = %RouteCardsContainer
@onready var back_button: Button = %BackButton
@onready var state_title_label: Label = %StateTitleLabel
@onready var route_desc_label: Label = %RouteDescLabel
@onready var start_button: Button = %StartButton

var all_routes: Array[RouteData] = []
var selected_route: RouteData = null
var _click_sfx: AudioStreamPlayer = null

func _ready() -> void:
	refresh_routes()

	if is_instance_valid(back_button):
		back_button.pressed.connect(func():
			_play_click_sfx()
			return_to_main_menu_requested.emit()
		)
	if is_instance_valid(start_button):
		start_button.pressed.connect(_on_start_pressed)

func _play_click_sfx() -> void:
	if _click_sfx == null:
		_click_sfx = AudioStreamPlayer.new()
		if ResourceLoader.exists("res://assets/audio/sfx/ui/ui_button_click.wav"):
			_click_sfx.stream = load("res://assets/audio/sfx/ui/ui_button_click.wav")
		add_child(_click_sfx)
	if is_instance_valid(_click_sfx) and _click_sfx.stream != null:
		_click_sfx.play()

func refresh_routes() -> void:
	all_routes = RouteRegistry.get_all_routes()
	if selected_route == null:
		selected_route = all_routes[0] # Default to Tamil Nadu
	else:
		# Keep current selection refreshed
		selected_route = RouteRegistry.get_route(selected_route.state_id)

	_populate_state_cards()
	_update_details_panel()

func _populate_state_cards() -> void:
	if not is_instance_valid(route_cards_container):
		return

	for child in route_cards_container.get_children():
		child.queue_free()

	var font_future = load("res://assets/fonts/Kenney_Future.ttf")
	var font_narrow = load("res://assets/fonts/Kenney_Future_Narrow.ttf")

	for r in all_routes:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(175, 250)

		var style := StyleBoxFlat.new()
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_right = 10
		style.corner_radius_bottom_left = 10

		var is_current := (selected_route != null and r.state_id == selected_route.state_id)

		if is_current:
			style.bg_color = Color(0.14, 0.22, 0.35, 0.95)
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.border_color = Color(1, 0.85, 0.2, 1.0)
			style.shadow_color = Color(1, 0.85, 0.2, 0.3)
			style.shadow_size = 6
		else:
			style.bg_color = Color(0.09, 0.12, 0.18, 0.9)
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
			style.border_color = Color(0.25, 0.35, 0.48, 0.7)

		card.add_theme_stylebox_override("panel", style)

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		card.add_child(margin)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 6)
		margin.add_child(vbox)

		# State Icon
		var icon_rect := TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(0, 85)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if r.state_card_icon_path != "" and ResourceLoader.exists(r.state_card_icon_path):
			icon_rect.texture = load(r.state_card_icon_path)
		if not r.is_unlocked:
			icon_rect.modulate = Color(0.5, 0.5, 0.55, 0.6)
		vbox.add_child(icon_rect)

		# State Title
		var title_lbl := Label.new()
		title_lbl.text = r.state_name
		title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_lbl.add_theme_font_override("font", font_future)
		title_lbl.add_theme_font_size_override("font_size", 12)
		title_lbl.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1) if r.is_unlocked else Color(0.7, 0.75, 0.8, 0.7))
		vbox.add_child(title_lbl)

		# Subtitle / Route or Lock condition
		var sub_lbl := Label.new()
		if r.is_unlocked:
			sub_lbl.text = "%s → %s" % [r.start_city, r.destination_city]
			sub_lbl.add_theme_color_override("font_color", Color(0.85, 0.95, 0.9, 0.9))
		else:
			var req := RouteRegistry.get_required_state_for(r.state_id)
			sub_lbl.text = "🔒 Complete %s" % req
			sub_lbl.add_theme_color_override("font_color", Color(0.9, 0.5, 0.4, 0.85))

		sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub_lbl.add_theme_font_override("font", font_narrow)
		sub_lbl.add_theme_font_size_override("font_size", 10)
		vbox.add_child(sub_lbl)

		# Select / Locked Button
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 32)
		btn.add_theme_font_override("font", font_future)
		btn.add_theme_font_size_override("font_size", 11)

		var btn_style := StyleBoxFlat.new()
		btn_style.corner_radius_top_left = 6
		btn_style.corner_radius_top_right = 6
		btn_style.corner_radius_bottom_right = 6
		btn_style.corner_radius_bottom_left = 6

		if r.is_unlocked:
			if is_current:
				btn.text = "ACTIVE"
				btn_style.bg_color = Color(0.85, 0.65, 0.15, 1.0)
			else:
				btn.text = "SELECT"
				btn_style.bg_color = Color(0.18, 0.42, 0.65, 1.0)
		else:
			btn.text = "INSPECT" if not is_current else "VIEWING"
			btn_style.bg_color = Color(0.2, 0.22, 0.28, 0.7)

		btn.add_theme_stylebox_override("normal", btn_style)
		var target_route := r
		btn.pressed.connect(func(): _on_card_selected(target_route))
		vbox.add_child(btn)

		route_cards_container.add_child(card)

func _on_card_selected(route: RouteData) -> void:
	_play_click_sfx()
	selected_route = route
	_populate_state_cards()
	_update_details_panel()

func _update_details_panel() -> void:
	if selected_route == null:
		return

	if is_instance_valid(state_title_label):
		if selected_route.is_unlocked:
			state_title_label.text = "%s: %s → %s" % [selected_route.state_name.to_upper(), selected_route.start_city.to_upper(), selected_route.destination_city.to_upper()]
		else:
			var req := RouteRegistry.get_required_state_for(selected_route.state_id)
			state_title_label.text = "🔒 %s (LOCKED: COMPLETE %s FIRST)" % [selected_route.state_name.to_upper(), req.to_upper()]

	if is_instance_valid(route_desc_label):
		var lock_msg := ""
		if not selected_route.is_unlocked:
			var req := RouteRegistry.get_required_state_for(selected_route.state_id)
			lock_msg = "\n\n🔒 [LOCKED] Complete %s highway first to unlock this route." % req

		var itinerary_parts: Array[String] = []
		for wp in selected_route.waypoints:
			if wp.waypoint_type == WaypointData.WaypointType.START:
				itinerary_parts.append("🚩 %s (0m)" % wp.title)
			elif wp.waypoint_type == WaypointData.WaypointType.CHECKPOINT:
				itinerary_parts.append("📍 %s (%dm)" % [wp.title, int(wp.distance_m)])
			elif wp.waypoint_type == WaypointData.WaypointType.DESTINATION:
				itinerary_parts.append("🏁 %s (%dm)" % [wp.title, int(wp.distance_m)])

		var itinerary_str: String = " ➔ ".join(itinerary_parts)

		var difficulty_str := "MODERATE"
		match selected_route.state_id:
			"goa": difficulty_str = "EASY (COASTAL CRUISE)"
			"kerala": difficulty_str = "CHALLENGING (HILL CURVES)"
			"rajasthan": difficulty_str = "ENDURANCE (DESERT SPEEDWAY)"
			"gujarat": difficulty_str = "MODERATE (EXPRESSWAY)"
			"telangana": difficulty_str = "CHALLENGING (PLATEAU ROLLS)"
			_: difficulty_str = "STANDARD HIGHWAY (NH44)"

		route_desc_label.text = "%s\n\n🛣 ROUTE JOURNEY:\n%s\n\n⚡ DIFFICULTY: %s | 📏 DISTANCE: %dm | 🚩 CHECKPOINTS: %d%s" % [
			selected_route.description,
			itinerary_str,
			difficulty_str,
			int(selected_route.total_distance_m),
			selected_route.get_checkpoint_count(),
			lock_msg
		]

	if is_instance_valid(map_texture_rect):
		if selected_route.state_map_path != "" and ResourceLoader.exists(selected_route.state_map_path):
			map_texture_rect.texture = load(selected_route.state_map_path)
		else:
			map_texture_rect.texture = load("res://assets/indian_locations/india_map_states.png")

		if not selected_route.is_unlocked:
			map_texture_rect.modulate = Color(0.6, 0.6, 0.65, 0.8)
		else:
			map_texture_rect.modulate = Color(1, 1, 1, 1)

	if is_instance_valid(start_button):
		if selected_route.is_unlocked:
			start_button.disabled = false
			start_button.text = "DRIVE ROUTE"
		else:
			start_button.disabled = true
			var req := RouteRegistry.get_required_state_for(selected_route.state_id)
			start_button.text = "🔒 COMPLETE %s FIRST" % req.to_upper()

func _on_start_pressed() -> void:
	_play_click_sfx()
	if selected_route != null and selected_route.is_unlocked:
		route_selected.emit(selected_route)
