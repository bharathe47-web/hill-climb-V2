class_name IndianRoadsHUD
extends CanvasLayer

const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

## IndianRoadsHUD: Specialized HUD for Indian Roads mode.
## Displays route progress, upcoming checkpoints, landmark discovery toasts,
## milestone distance, coins, and mobile driving touch controls.

signal pause_pressed
signal map_pressed
signal restart_pressed
signal return_to_menu_pressed

@onready var route_title_label: Label = %RouteTitleLabel
@onready var progress_bar: ProgressBar = %RouteProgressBar
@onready var distance_label: Label = %DistanceLabel
@onready var next_wp_label: Label = %NextWaypointLabel
@onready var section_badge_label: Label = get_node_or_null("%SectionBadgeLabel")
@onready var coins_label: Label = %CoinsLabel
@onready var fuel_label: Label = get_node_or_null("%FuelLabel")
@onready var fuel_bar: ProgressBar = get_node_or_null("%FuelBar")
@onready var nitro_label: Label = get_node_or_null("%NitroLabel")
@onready var nitro_bar: ProgressBar = get_node_or_null("%NitroBar")
@onready var toast_panel: PanelContainer = %ToastPanel
@onready var toast_label: Label = %ToastLabel
@onready var toast_sub_label: Label = %ToastSubLabel
@onready var map_button: Button = get_node_or_null("%MapButton")
@onready var pause_button: Button = %PauseButton
@onready var gas_button: TouchScreenButton = get_node_or_null("%GasButton")
@onready var brake_button: TouchScreenButton = get_node_or_null("%BrakeButton")
@onready var nitro_button: TouchScreenButton = get_node_or_null("%NitroButton")

# Dedicated Bottom Famous Place Information Panel
@onready var landmark_info_panel: PanelContainer = get_node_or_null("%LandmarkInfoPanel")
@onready var info_category_label: Label = get_node_or_null("%InfoCategoryLabel")
@onready var info_close_button: Button = get_node_or_null("%InfoCloseButton")
@onready var info_title_label: Label = get_node_or_null("%InfoTitleLabel")
@onready var info_location_label: Label = get_node_or_null("%InfoLocationLabel")
@onready var info_description_label: Label = get_node_or_null("%InfoDescriptionLabel")
@onready var info_why_famous_label: Label = get_node_or_null("%InfoWhyFamousLabel")

var _toast_tween: Tween = null
var _info_tween: Tween = null

func _ready() -> void:
	if is_instance_valid(toast_panel):
		toast_panel.visible = false
	if is_instance_valid(landmark_info_panel):
		landmark_info_panel.visible = false
	if is_instance_valid(info_close_button):
		info_close_button.pressed.connect(dismiss_landmark_info)
	if is_instance_valid(pause_button):
		pause_button.pressed.connect(func(): pause_pressed.emit())
	if is_instance_valid(map_button):
		map_button.pressed.connect(func(): map_pressed.emit())

func setup_route_info(state_name: String, start_city: String, dest_city: String) -> void:
	if is_instance_valid(route_title_label):
		if state_name.to_lower() == "telangana":
			route_title_label.text = "TELANGANA: HYDERABAD CITY EXPLORER"
		else:
			route_title_label.text = "%s: %s → %s" % [state_name.to_upper(), start_city.to_upper(), dest_city.to_upper()]
	if is_instance_valid(section_badge_label):
		section_badge_label.visible = (state_name.to_lower() in ["goa", "kerala", "rajasthan", "telangana", "tamil nadu"])

func set_section_badge(section_text: String) -> void:
	if not is_instance_valid(section_badge_label):
		section_badge_label = get_node_or_null("%SectionBadgeLabel")
	if is_instance_valid(section_badge_label):
		if section_text == "":
			section_badge_label.visible = false
		else:
			section_badge_label.visible = true
			section_badge_label.text = "• " + section_text.to_upper()

func update_progress(current_m: float, total_m: float, coins: int) -> void:
	if is_instance_valid(progress_bar) and total_m > 0.0:
		# PERF: only update max_value when it actually changes
		if progress_bar.max_value != total_m:
			progress_bar.max_value = total_m
		progress_bar.value = clampf(current_m, 0.0, total_m)

	if is_instance_valid(distance_label):
		var dist_int: int = int(current_m)
		var total_int: int = int(total_m)
		# PERF: skip string formatting when displayed integer hasn't changed
		if distance_label.text == "" or not distance_label.text.begins_with("DIST: %d" % dist_int):
			distance_label.text = "DIST: %dm / %dm" % [dist_int, total_int]

	if is_instance_valid(coins_label):
		var coins_str: String = str(coins)
		if coins_label.text != coins_str:
			coins_label.text = coins_str

func update_fuel(current: float, max_val: float) -> void:
	if is_instance_valid(fuel_bar) and max_val > 0.0:
		if fuel_bar.max_value != max_val:
			fuel_bar.max_value = max_val
		fuel_bar.value = clampf(current, 0.0, max_val)
		var pct := int((current / max_val) * 100.0)
		if is_instance_valid(fuel_label):
			# PERF: skip text + color override when integer percent hasn't changed
			var fuel_text: String = "FUEL: %d%%" % pct
			if fuel_label.text != fuel_text:
				fuel_label.text = fuel_text
				if pct <= 20:
					fuel_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2, 1.0))
				else:
					fuel_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))

func update_nitro(current: float, max_val: float) -> void:
	if is_instance_valid(nitro_bar) and max_val > 0.0:
		if nitro_bar.max_value != max_val:
			nitro_bar.max_value = max_val
		nitro_bar.value = clampf(current, 0.0, max_val)
		var pct := int((current / max_val) * 100.0)
		if is_instance_valid(nitro_label):
			# PERF: skip text + color override when integer percent hasn't changed
			var nitro_text: String = "NITRO: %d%%" % pct
			if nitro_label.text != nitro_text:
				nitro_label.text = nitro_text
				if pct <= 15:
					nitro_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8, 0.6))
				else:
					nitro_label.add_theme_color_override("font_color", Color(0.2, 0.9, 1.0, 1.0))
	if is_instance_valid(nitro_button):
		var should_dim: bool = current <= 0.05
		var target_mod: Color = Color(0.5, 0.5, 0.5, 0.5) if should_dim else Color(1.0, 1.0, 1.0, 1.0)
		if nitro_button.modulate != target_mod:
			nitro_button.modulate = target_mod

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		pause_pressed.emit()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		pause_pressed.emit()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		get_viewport().set_input_as_handled()
		map_pressed.emit()

func set_next_waypoint_info(wp_title: String, dist_remaining_m: float) -> void:
	if not is_instance_valid(next_wp_label):
		next_wp_label = get_node_or_null("%NextWaypointLabel")
	if is_instance_valid(next_wp_label):
		if dist_remaining_m > 0.0:
			var new_text: String = "NEXT: %s (%dm)" % [wp_title.to_upper(), int(dist_remaining_m)]
			# PERF: skip string formatting when displayed integer distance hasn't changed
			if next_wp_label.text != new_text:
				next_wp_label.text = new_text
		else:
			var arrived_text: String = "ARRIVED: %s" % wp_title.to_upper()
			if next_wp_label.text != arrived_text:
				next_wp_label.text = arrived_text

func show_announcement_toast(main_text: String, sub_text: String = "") -> void:
	if not is_instance_valid(toast_panel):
		return

	if is_instance_valid(_toast_tween):
		_toast_tween.kill()

	if is_instance_valid(toast_label):
		toast_label.text = main_text
	if is_instance_valid(toast_sub_label):
		toast_sub_label.text = sub_text
		toast_sub_label.visible = (sub_text != "")

	toast_panel.visible = true
	toast_panel.modulate.a = 0.0
	toast_panel.position.y = -60.0

	_toast_tween = create_tween()
	# Slide in & fade in
	_toast_tween.parallel().tween_property(toast_panel, "position:y", 4.0, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_toast_tween.parallel().tween_property(toast_panel, "modulate:a", 1.0, 0.25)
	# Hold for 2.4 seconds
	_toast_tween.tween_interval(2.4)
	# Fade out
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.4)
	_toast_tween.tween_callback(func(): toast_panel.visible = false)

func show_landmark_info(info: Dictionary) -> void:
	if not is_instance_valid(landmark_info_panel):
		landmark_info_panel = get_node_or_null("%LandmarkInfoPanel")
	if not is_instance_valid(landmark_info_panel):
		return

	if is_instance_valid(_info_tween):
		_info_tween.kill()

	var state_name: String = str(info.get("state", "India"))
	var resolved_sid: String = str(info.get("state_id", "")).to_lower()
	if resolved_sid == "" and state_name.to_lower() == "telangana":
		resolved_sid = "telangana"
	var discovery_region: String = str(info.get("discovery_region", "")).strip_edges()
	if discovery_region == "":
		discovery_region = str(info.get("city_display_name", "")).strip_edges()
	if discovery_region == "" and resolved_sid != "":
		discovery_region = RouteRegistry.get_discovery_region_display_name(resolved_sid, state_name)
	if discovery_region == "":
		discovery_region = state_name

	if is_instance_valid(info_category_label):
		info_category_label.text = "★ FAMOUS PLACE — %s" % discovery_region.to_upper()
	if is_instance_valid(info_title_label):
		info_title_label.text = info.get("name", "Famous Landmark").to_upper()
	if is_instance_valid(info_location_label):
		info_location_label.text = "Location: %s" % info.get("location", discovery_region)
	if is_instance_valid(info_description_label):
		info_description_label.text = info.get("description", "")
	if is_instance_valid(info_why_famous_label):
		var why: String = info.get("why_famous", "")
		if why != "":
			info_why_famous_label.text = "• " + why
		else:
			info_why_famous_label.text = ""

	landmark_info_panel.visible = true
	landmark_info_panel.modulate.a = 0.0

	# Smoothly slide in from bottom and hold for comfortable reading (6.5s)
	_info_tween = create_tween()
	_info_tween.parallel().tween_property(landmark_info_panel, "modulate:a", 1.0, 0.30)
	_info_tween.tween_interval(6.5)
	_info_tween.tween_property(landmark_info_panel, "modulate:a", 0.0, 0.40)
	_info_tween.tween_callback(func(): landmark_info_panel.visible = false)

func dismiss_landmark_info() -> void:
	if not is_instance_valid(landmark_info_panel):
		return
	if is_instance_valid(_info_tween):
		_info_tween.kill()
	landmark_info_panel.visible = false
	landmark_info_panel.modulate.a = 0.0
