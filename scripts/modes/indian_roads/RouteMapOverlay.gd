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
var _current_dist_m: float = 0.0
var _route_canvas: Control = null

const STATE_ROUTE_GEOMETRY := {
	"tamil_nadu": [
		{"pos": Vector2(0.42, 0.94), "dist_m": 0.0, "label": "1. Kanyakumari"},
		{"pos": Vector2(0.40, 0.88), "dist_m": 100.0, "label": "2. Nagercoil"},
		{"pos": Vector2(0.43, 0.81), "dist_m": 200.0, "label": "3. Tirunelveli CP"},
		{"pos": Vector2(0.45, 0.74), "dist_m": 300.0, "label": "4. Kovilpatti"},
		{"pos": Vector2(0.46, 0.67), "dist_m": 400.0, "label": "5. Virudhunagar"},
		{"pos": Vector2(0.48, 0.59), "dist_m": 500.0, "label": "6. Madurai CP"},
		{"pos": Vector2(0.53, 0.52), "dist_m": 600.0, "label": "7. Melur"},
		{"pos": Vector2(0.56, 0.44), "dist_m": 700.0, "label": "8. Trichy CP"},
		{"pos": Vector2(0.61, 0.37), "dist_m": 800.0, "label": "9. Perambalur"},
		{"pos": Vector2(0.66, 0.30), "dist_m": 900.0, "label": "10. Villupuram CP"},
		{"pos": Vector2(0.70, 0.24), "dist_m": 1000.0, "label": "11. Tindivanam"},
		{"pos": Vector2(0.74, 0.20), "dist_m": 1100.0, "label": "12. Chengalpattu CP"},
		{"pos": Vector2(0.78, 0.16), "dist_m": 1200.0, "label": "13. Chennai"}
	],
	"goa": [
		{"pos": Vector2(0.38, 0.32), "dist_m": 0.0, "label": "Panaji"},
		{"pos": Vector2(0.28, 0.26), "dist_m": 250.0, "label": "Calangute"},
		{"pos": Vector2(0.44, 0.42), "dist_m": 500.0, "label": "Mandovi CP"},
		{"pos": Vector2(0.52, 0.58), "dist_m": 750.0, "label": "Old Goa"},
		{"pos": Vector2(0.55, 0.74), "dist_m": 950.0, "label": "Margao"}
	],
	"kerala": [
		{"pos": Vector2(0.38, 0.52), "dist_m": 0.0, "label": "Kochi"},
		{"pos": Vector2(0.36, 0.65), "dist_m": 280.0, "label": "Alleppey"},
		{"pos": Vector2(0.58, 0.50), "dist_m": 550.0, "label": "Ghats CP"},
		{"pos": Vector2(0.66, 0.42), "dist_m": 820.0, "label": "Tea Gardens"},
		{"pos": Vector2(0.70, 0.35), "dist_m": 1050.0, "label": "Munnar"}
	],
	"rajasthan": [
		{"pos": Vector2(0.68, 0.42), "dist_m": 0.0, "label": "Jaipur"},
		{"pos": Vector2(0.72, 0.36), "dist_m": 300.0, "label": "Amber Fort"},
		{"pos": Vector2(0.55, 0.46), "dist_m": 600.0, "label": "Thar CP"},
		{"pos": Vector2(0.38, 0.48), "dist_m": 900.0, "label": "Mehrangarh"},
		{"pos": Vector2(0.18, 0.45), "dist_m": 1200.0, "label": "Jaisalmer"}
	],
	"gujarat": [
		{"pos": Vector2(0.54, 0.44), "dist_m": 0.0, "label": "Ahmedabad"},
		{"pos": Vector2(0.60, 0.52), "dist_m": 300.0, "label": "Saurashtra"},
		{"pos": Vector2(0.45, 0.46), "dist_m": 600.0, "label": "Kutch Gate CP"},
		{"pos": Vector2(0.36, 0.38), "dist_m": 880.0, "label": "Flamingo Pass"},
		{"pos": Vector2(0.24, 0.28), "dist_m": 1150.0, "label": "White Desert"}
	],
	"telangana": [
		{"pos": Vector2(0.44, 0.62), "dist_m": 0.0, "label": "Hyderabad"},
		{"pos": Vector2(0.38, 0.60), "dist_m": 260.0, "label": "Golconda"},
		{"pos": Vector2(0.56, 0.48), "dist_m": 520.0, "label": "ORR Toll CP"},
		{"pos": Vector2(0.68, 0.38), "dist_m": 780.0, "label": "Torana Arch"},
		{"pos": Vector2(0.72, 0.30), "dist_m": 1000.0, "label": "Thousand Pillar"}
	]
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if is_instance_valid(close_button):
		close_button.pressed.connect(_on_close_pressed)
	if is_instance_valid(resume_button):
		resume_button.pressed.connect(_on_close_pressed)

	_setup_route_canvas()

func _setup_route_canvas() -> void:
	if is_instance_valid(state_map_rect) and _route_canvas == null:
		_route_canvas = Control.new()
		_route_canvas.name = "RouteCanvas"
		_route_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_route_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_route_canvas.draw.connect(_draw_route_overlay)
		state_map_rect.add_child(_route_canvas)

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
	_current_dist_m = current_dist_m
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

	if is_instance_valid(_route_canvas):
		_route_canvas.queue_redraw()

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

func _draw_route_overlay() -> void:
	if _route_canvas == null or _active_route == null:
		return

	var state_id := _active_route.state_id
	var geom_list: Array = STATE_ROUTE_GEOMETRY.get(state_id, [])
	if geom_list.size() < 2:
		return

	var canvas_sz := _route_canvas.size
	if canvas_sz.x <= 10.0 or canvas_sz.y <= 10.0:
		canvas_sz = Vector2(340.0, 400.0)

	# Calculate exact aspect-fitted rect of state map image inside TextureRect (KEEP_ASPECT_CENTERED)
	var map_rect := Rect2(Vector2.ZERO, canvas_sz)
	if is_instance_valid(state_map_rect) and state_map_rect.texture:
		var tex_sz := state_map_rect.texture.get_size()
		if tex_sz.x > 0.0 and tex_sz.y > 0.0:
			var scale_f := minf(canvas_sz.x / tex_sz.x, canvas_sz.y / tex_sz.y)
			var fitted_sz := tex_sz * scale_f
			var fitted_pos := (canvas_sz - fitted_sz) * 0.5
			map_rect = Rect2(fitted_pos, fitted_sz)

	var screen_points := PackedVector2Array()
	for item in geom_list:
		var norm_pos: Vector2 = item["pos"]
		screen_points.append(map_rect.position + Vector2(norm_pos.x * map_rect.size.x, norm_pos.y * map_rect.size.y))

	# 1. Glow route underlay
	_route_canvas.draw_polyline(screen_points, Color(0.15, 0.75, 1.0, 0.35), 8.0, true)

	# 2. Highway route line
	_route_canvas.draw_polyline(screen_points, Color(0.25, 0.88, 1.0, 0.95), 3.5, true)

	# 3. Calculate player position along path based on waypoint distances
	var total_m := maxf(_active_route.total_distance_m, 1.0)
	var player_screen_pos := screen_points[0]
	var active_seg_idx := 0

	for k in range(geom_list.size() - 1):
		var d0: float = geom_list[k].get("dist_m", float(k) / float(geom_list.size() - 1) * total_m)
		var d1: float = geom_list[k + 1].get("dist_m", float(k + 1) / float(geom_list.size() - 1) * total_m)
		if _current_dist_m <= d1 or k == geom_list.size() - 2:
			active_seg_idx = k
			var seg_t := clampf((_current_dist_m - d0) / maxf(d1 - d0, 0.001), 0.0, 1.0)
			player_screen_pos = screen_points[k].lerp(screen_points[k + 1], seg_t)
			break

	# 4. Completed route highlight (bright lime green)
	var completed_pts := PackedVector2Array()
	for k in range(active_seg_idx + 1):
		completed_pts.append(screen_points[k])
	completed_pts.append(player_screen_pos)
	if completed_pts.size() >= 2:
		_route_canvas.draw_polyline(completed_pts, Color(0.3, 0.95, 0.4, 0.95), 4.0, true)

	# 5. Draw Waypoint Pins along route
	var font_narrow: Font = load("res://assets/fonts/Kenney_Future_Narrow.ttf") as Font
	for i in range(screen_points.size()):
		var pt: Vector2 = screen_points[i]
		var label_str: String = geom_list[i].get("label", "")

		var pin_col := Color(0.2, 0.85, 1.0, 1.0)
		var pin_rad := 4.5
		if i == 0:
			pin_col = Color(0.3, 0.95, 0.4, 1.0) # Start (Green)
			pin_rad = 6.0
		elif i == screen_points.size() - 1:
			pin_col = Color(1.0, 0.35, 0.3, 1.0) # Destination (Red)
			pin_rad = 6.0
		elif "CP" in label_str:
			pin_col = Color(1.0, 0.85, 0.2, 1.0) # Checkpoint (Gold)
			pin_rad = 5.5

		_route_canvas.draw_circle(pt, pin_rad + 2.0, Color(0.05, 0.08, 0.12, 0.85))
		_route_canvas.draw_circle(pt, pin_rad, pin_col)

		if font_narrow and label_str != "":
			var txt_offset := Vector2(8, 4)
			if pt.x > map_rect.position.x + map_rect.size.x * 0.65:
				txt_offset = Vector2(-75, 4)
			_route_canvas.draw_string(font_narrow, pt + txt_offset, label_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 1, 1, 0.85))

	# 6. Draw Player Marker (Pulsing glowing target pin)
	_route_canvas.draw_circle(player_screen_pos, 11.0, Color(1.0, 0.85, 0.2, 0.4))
	_route_canvas.draw_circle(player_screen_pos, 7.5, Color(1.0, 0.92, 0.25, 1.0))
	_route_canvas.draw_circle(player_screen_pos, 3.5, Color(0.08, 0.12, 0.18, 1.0))

	if font_narrow:
		_route_canvas.draw_string(font_narrow, player_screen_pos + Vector2(12, -4), "YOU (%dm)" % int(_current_dist_m), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(1.0, 0.95, 0.35, 1.0))

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
