class_name RouteMapOverlay
extends Control

## RouteMapOverlay: In-game interactive tourism route map modal dialog for Indian Roads mode.
## Displays state geographical map, journey progress, upcoming landmarks,
## cleared checkpoints, and remaining distance to destination without resetting gameplay.

signal map_closed

@onready var backdrop: ColorRect = $Backdrop
@onready var modal_panel: PanelContainer = $CenterContainer/ModalPanel
@onready var state_title_label: Label = %StateTitleLabel
@onready var route_subtitle_label: Label = %RouteSubtitleLabel
@onready var state_map_rect: TextureRect = %StateMapRect
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_label: Label = %ProgressLabel
@onready var remaining_label: Label = %RemainingLabel
@onready var waypoints_vbox: VBoxContainer = %WaypointsVBox
@onready var close_button: Button = %CloseButton
@onready var resume_button: Button = %ResumeButton

var _active_route: RouteData = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if is_instance_valid(close_button):
		close_button.pressed.connect(_on_close_pressed)
	if is_instance_valid(resume_button):
		resume_button.pressed.connect(_on_close_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ESCAPE or event.keycode == KEY_M)):
		get_viewport().set_input_as_handled()
		_on_close_pressed()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_close_pressed()

func open_map(route: RouteData, current_dist_m: float) -> void:
	_active_route = route
	visible = true
	modulate.a = 0.0

	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(self, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if not route:
		return

	# Header info
	if is_instance_valid(state_title_label):
		state_title_label.text = ("%s HIGHWAY ROUTE MAP" % route.state_name).to_upper()
	if is_instance_valid(route_subtitle_label):
		route_subtitle_label.text = "%s → %s  •  TOTAL: %dm (%.1f KM)" % [
			route.start_city.to_upper(),
			route.destination_city.to_upper(),
			int(route.total_distance_m),
			route.total_distance_m / 1000.0
		]

	# State Map Texture
	if is_instance_valid(state_map_rect):
		var map_path := route.state_map_path
		if map_path != "" and ResourceLoader.exists(map_path):
			state_map_rect.texture = load(map_path)
		elif route.state_card_icon_path != "" and ResourceLoader.exists(route.state_card_icon_path):
			state_map_rect.texture = load(route.state_card_icon_path)

	# Progress statistics
	var total_m := maxf(route.total_distance_m, 1.0)
	var cur_clamped := clampf(current_dist_m, 0.0, total_m)
	var pct := (cur_clamped / total_m) * 100.0
	var remaining_m := maxf(0.0, total_m - cur_clamped)

	if is_instance_valid(progress_bar):
		progress_bar.max_value = total_m
		progress_bar.value = cur_clamped
	if is_instance_valid(progress_label):
		progress_label.text = "PROGRESS: %dm / %dm (%d%%)" % [int(cur_clamped), int(total_m), int(pct)]
	if is_instance_valid(remaining_label):
		remaining_label.text = "REMAINING: %dm (%.1f KM)" % [int(remaining_m), remaining_m / 1000.0]

	# Populate Waypoint Milestones
	_populate_waypoints(route, cur_clamped)

func _populate_waypoints(route: RouteData, cur_dist_m: float) -> void:
	if not is_instance_valid(waypoints_vbox):
		return

	for child in waypoints_vbox.get_children():
		child.queue_free()

	var font_future: Font = load("res://assets/fonts/Kenney_Future.ttf") as Font
	var font_narrow: Font = load("res://assets/fonts/Kenney_Future_Narrow.ttf") as Font

	var found_next := false

	for wp in route.waypoints:
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 32)
		row.add_theme_constant_override("separation", 10)

		var is_passed := (cur_dist_m >= wp.distance_m)
		var is_current := (!is_passed and !found_next)
		if is_current:
			found_next = true

		# Status Badge / Icon
		var status_label := Label.new()
		status_label.custom_minimum_size = Vector2(30, 24)
		if font_future:
			status_label.add_theme_font_override("font", font_future)
		status_label.add_theme_font_size_override("font_size", 12)
		status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		# Distance Pill
		var dist_badge := Label.new()
		dist_badge.custom_minimum_size = Vector2(65, 24)
		if font_narrow:
			dist_badge.add_theme_font_override("font", font_narrow)
		dist_badge.add_theme_font_size_override("font_size", 11)
		dist_badge.text = "%dm" % int(wp.distance_m)
		dist_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		dist_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		# Title & Type
		var info_vbox := VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", 1)

		var title_lbl := Label.new()
		if font_future:
			title_lbl.add_theme_font_override("font", font_future)
		title_lbl.add_theme_font_size_override("font_size", 11)
		title_lbl.text = wp.title.to_upper()

		var type_lbl := Label.new()
		if font_narrow:
			type_lbl.add_theme_font_override("font", font_narrow)
		type_lbl.add_theme_font_size_override("font_size", 9)

		match wp.waypoint_type:
			WaypointData.WaypointType.START:
				type_lbl.text = "DEPARTURE POINT"
			WaypointData.WaypointType.CHECKPOINT:
				type_lbl.text = "TOLL CHECKPOINT (+120 COINS)"
			WaypointData.WaypointType.DESTINATION:
				type_lbl.text = "FINAL DESTINATION FINISH ARCH"
			_:
				type_lbl.text = "FAMOUS ROADSIDE LANDMARK"

		if is_passed:
			status_label.text = "✓"
			status_label.add_theme_color_override("font_color", Color(0.25, 0.95, 0.45, 1.0))
			dist_badge.add_theme_color_override("font_color", Color(0.5, 0.8, 0.6, 0.85))
			title_lbl.add_theme_color_override("font_color", Color(0.7, 0.9, 0.75, 0.9))
			type_lbl.add_theme_color_override("font_color", Color(0.4, 0.7, 0.5, 0.75))
		elif is_current:
			status_label.text = "★"
			status_label.add_theme_color_override("font_color", Color(0.2, 0.85, 1.0, 1.0))
			dist_badge.add_theme_color_override("font_color", Color(0.3, 0.9, 1.0, 1.0))
			title_lbl.add_theme_color_override("font_color", Color(1.0, 0.92, 0.3, 1.0))
			type_lbl.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0, 0.9))
		else:
			status_label.text = "•"
			status_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.65, 0.6))
			dist_badge.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 0.6))
			title_lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75, 0.7))
			type_lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6, 0.5))

		info_vbox.add_child(title_lbl)
		info_vbox.add_child(type_lbl)

		row.add_child(status_label)
		row.add_child(dist_badge)
		row.add_child(info_vbox)

		waypoints_vbox.add_child(row)

func _on_close_pressed() -> void:
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(self, "modulate:a", 0.0, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func():
		visible = false
		map_closed.emit()
	)
