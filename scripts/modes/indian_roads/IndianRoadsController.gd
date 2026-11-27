class_name IndianRoadsController
extends Node2D

## IndianRoadsController: Master lifecycle coordinator for Indian Roads Mode.
## Manages state selection, highway terrain generation, vehicle binding,
## checkpoint tracking, destination victory, and return-to-menu navigation.

const RouteData = preload("res://resources/routes/RouteData.gd")
const WaypointData = preload("res://resources/routes/WaypointData.gd")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const StateSelectionScene = preload("res://scenes/modes/indian_roads/StateSelection.tscn")
const IndianRoadTerrainScene = preload("res://scenes/modes/indian_roads/IndianRoadTerrain.tscn")
const IndianRoadsHUDScene = preload("res://scenes/modes/indian_roads/IndianRoadsHUD.tscn")
const RouteCompleteScreenScene = preload("res://scenes/modes/indian_roads/RouteCompleteScreen.tscn")
const RouteMapOverlay = preload("res://scripts/modes/indian_roads/RouteMapOverlay.gd")
const RouteMapOverlayScene = preload("res://scenes/modes/indian_roads/RouteMapOverlay.tscn")
const PauseMenuScene = preload("res://scenes/ui/PauseMenu.tscn")
const LandmarkCatalogueData = preload("res://scripts/modes/indian_roads/LandmarkCatalogueData.gd")

enum ModeState {
	SELECTION,
	PLAYING,
	PAUSED,
	COMPLETED
}

signal return_to_main_menu_requested
signal route_started(state_id: String)
signal route_completed(state_id: String, distance: float, time_s: float, coins: int)

@export var default_state_id: String = "tamil_nadu"
@export var start_with_selection: bool = true

@onready var world_container: Node2D = $WorldContainer
@onready var vehicle_slot: Node2D = $WorldContainer/VehicleSlot
@onready var terrain_slot: Node2D = $WorldContainer/TerrainSlot
@onready var follow_camera: Camera2D = $FollowCamera
@onready var ui_layer: CanvasLayer = $UILayer
@onready var parallax_bg: ParallaxBackground = $ParallaxBackground
@onready var parallax_sky_sprite: Sprite2D = $ParallaxBackground/SkyLayer/SkySprite
@onready var parallax_plains_sprite: Sprite2D = $ParallaxBackground/PlainsLayer/PlainsSprite

var current_state: ModeState = ModeState.SELECTION
var active_route: RouteData = null
var active_vehicle: VehicleController = null
var active_terrain: IndianRoadTerrain = null
var hud: IndianRoadsHUD = null
var victory_screen: RouteCompleteScreen = null
var pause_menu: Control = null
var route_map_overlay: RouteMapOverlay = null
var state_selection_view: StateSelectionController = null

var session_distance_m: float = 0.0
var session_time_s: float = 0.0
var session_coins: int = 0
var checkpoints_cleared_count: int = 0
var _start_vehicle_x: float = 0.0
var _next_waypoint_index: int = 0
var _cleared_waypoint_ids: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if is_instance_valid(ui_layer):
		ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	active_route = RouteRegistry.get_route(default_state_id)

	if start_with_selection:
		open_state_selection()
	else:
		start_route(active_route)

class _IndianPauseBridge:
	extends Node
	var _ctrl: IndianRoadsController
	func _init(ctrl: IndianRoadsController = null) -> void:
		_ctrl = ctrl
	func pause_run(is_paused: bool) -> void:
		if not is_paused and is_instance_valid(_ctrl):
			_ctrl._on_resume_requested()
	func restart_run() -> void:
		if is_instance_valid(_ctrl):
			_ctrl._on_restart_from_pause()

var _pause_bridge: _IndianPauseBridge = null

func open_state_selection() -> void:
	get_tree().paused = false
	current_state = ModeState.SELECTION
	_clear_driving_world()

	if is_instance_valid(parallax_bg):
		parallax_bg.visible = false
	if is_instance_valid(hud):
		hud.visible = false

	if not is_instance_valid(state_selection_view):
		state_selection_view = StateSelectionScene.instantiate() as StateSelectionController
		ui_layer.add_child(state_selection_view)
		state_selection_view.route_selected.connect(_on_route_chosen_from_menu)
		state_selection_view.return_to_main_menu_requested.connect(func(): return_to_main_menu_requested.emit())
	else:
		state_selection_view.visible = true

func _on_route_chosen_from_menu(route: RouteData) -> void:
	if is_instance_valid(state_selection_view):
		state_selection_view.visible = false
	start_route(route)

func start_route(route: RouteData) -> void:
	get_tree().paused = false
	active_route = route if route != null else RouteRegistry.get_tamil_nadu_route()
	current_state = ModeState.PLAYING
	session_distance_m = 0.0
	session_time_s = 0.0
	session_coins = 0
	checkpoints_cleared_count = 0
	_next_waypoint_index = 0
	_cleared_waypoint_ids.clear()

	if is_instance_valid(state_selection_view):
		state_selection_view.visible = false

	if is_instance_valid(parallax_bg):
		parallax_bg.visible = true
		_setup_parallax_textures()

	_setup_terrain()
	_setup_vehicle()
	_setup_camera()
	_setup_ui()

	route_started.emit(active_route.state_id)

func _setup_parallax_textures() -> void:
	if active_route == null:
		return
	var sky_layer: ParallaxLayer = parallax_bg.get_node_or_null("SkyLayer") if is_instance_valid(parallax_bg) else null
	var plains_layer: ParallaxLayer = parallax_bg.get_node_or_null("PlainsLayer") if is_instance_valid(parallax_bg) else null

	if is_instance_valid(parallax_sky_sprite) and active_route.sky_texture_path != "" and ResourceLoader.exists(active_route.sky_texture_path):
		var tex: Texture2D = load(active_route.sky_texture_path)
		parallax_sky_sprite.texture = tex
		if is_instance_valid(sky_layer):
			sky_layer.motion_mirroring = Vector2(tex.get_width(), 0)
			parallax_sky_sprite.position = Vector2(tex.get_width() * 0.5, tex.get_height() * 0.5)

	if is_instance_valid(parallax_plains_sprite) and active_route.parallax_bg_path != "" and ResourceLoader.exists(active_route.parallax_bg_path):
		var tex: Texture2D = load(active_route.parallax_bg_path)
		parallax_plains_sprite.texture = tex
		if is_instance_valid(plains_layer):
			plains_layer.motion_mirroring = Vector2(tex.get_width(), 0)
			parallax_plains_sprite.position = Vector2(tex.get_width() * 0.5, tex.get_height() * 0.5)

func _setup_terrain() -> void:
	if not is_instance_valid(terrain_slot):
		return

	for child in terrain_slot.get_children():
		child.queue_free()

	active_terrain = IndianRoadTerrainScene.instantiate() as IndianRoadTerrain
	terrain_slot.add_child(active_terrain)
	active_terrain.generate_route(active_route)

	active_terrain.checkpoint_cleared.connect(_on_checkpoint_cleared)
	active_terrain.landmark_reached.connect(_on_landmark_reached)
	active_terrain.destination_reached.connect(_on_destination_reached)

func _setup_vehicle() -> void:
	if not is_instance_valid(vehicle_slot):
		return

	for child in vehicle_slot.get_children():
		child.queue_free()

	var selected_id: String = SaveManager.get_selected_vehicle_id()
	var veh: VehicleController = VehicleRegistry.instantiate_vehicle(selected_id)
	if not is_instance_valid(veh):
		veh = VehicleRegistry.instantiate_vehicle("blue_flame_truck")

	if is_instance_valid(veh):
		veh.name = "Vehicle"
		# Road height at start is 382.0. Vehicle wheel bottom is at +40px.
		# Spawning at y=335.0 places tires 7px above tarmac for a smooth drop without ground clipping.
		veh.global_position = Vector2(0.0, 335.0)
		veh.consumes_fuel = true
		veh.max_fuel = 100.0
		veh.current_fuel = 100.0
		veh.max_nitro = 100.0
		veh.current_nitro = 100.0
		veh.set_active(true)
		vehicle_slot.add_child(veh)
		active_vehicle = veh
		_start_vehicle_x = veh.global_position.x

		if veh.has_signal("crashed") and not veh.crashed.is_connected(_on_vehicle_crashed):
			veh.crashed.connect(_on_vehicle_crashed)
		if veh.has_signal("fuel_changed") and not veh.fuel_changed.is_connected(_on_vehicle_fuel_changed):
			veh.fuel_changed.connect(_on_vehicle_fuel_changed)
		if veh.has_signal("nitro_changed") and not veh.nitro_changed.is_connected(_on_vehicle_nitro_changed):
			veh.nitro_changed.connect(_on_vehicle_nitro_changed)

func _setup_camera() -> void:
	if is_instance_valid(follow_camera) and is_instance_valid(active_vehicle):
		follow_camera.target = active_vehicle
		follow_camera.global_position = active_vehicle.global_position

func _setup_ui() -> void:
	if not is_instance_valid(ui_layer):
		ui_layer = get_node_or_null("UILayer")
	if not is_instance_valid(hud):
		hud = IndianRoadsHUDScene.instantiate() as IndianRoadsHUD
		if is_instance_valid(ui_layer):
			ui_layer.add_child(hud)
		else:
			add_child(hud)
		hud.pause_pressed.connect(_on_pause_requested)
		hud.map_pressed.connect(_on_map_requested)
	else:
		hud.visible = true

	hud.setup_route_info(active_route.state_name, active_route.start_city, active_route.destination_city)
	hud.update_progress(0.0, active_route.total_distance_m, session_coins)
	if is_instance_valid(active_vehicle):
		hud.update_fuel(active_vehicle.current_fuel, active_vehicle.max_fuel)
		hud.update_nitro(active_vehicle.current_nitro, active_vehicle.max_nitro)

	if is_instance_valid(victory_screen):
		victory_screen.visible = false

	_update_next_waypoint_hud()

func _process(delta: float) -> void:
	if current_state != ModeState.PLAYING:
		return

	session_time_s += delta

	if is_instance_valid(active_vehicle):
		var dx: float = active_vehicle.global_position.x - _start_vehicle_x
		session_distance_m = clampf(dx * 0.01, 0.0, active_route.total_distance_m)

		# Landmark Discovery Zone: detect approach within ±450px of major landmarks
		var in_discovery_zone := false
		for wp in active_route.waypoints:
			if wp.waypoint_type == WaypointData.WaypointType.CHECKPOINT or wp.waypoint_type == WaypointData.WaypointType.DESTINATION:
				var lm_px: float = wp.distance_m * 100.0
				if absf(active_vehicle.global_position.x - lm_px) < 450.0:
					in_discovery_zone = true
					break

		if in_discovery_zone:
			# Limit nitro activation inside discovery zone so player experiences the landmark
			if active_vehicle.is_nitro_active:
				active_vehicle.set_nitro_active(false)
			if is_instance_valid(hud) and hud.has_node("%NitroButton"):
				hud.get_node("%NitroButton").modulate = Color(0.5, 0.5, 0.5, 0.4)
		else:
			if is_instance_valid(hud) and hud.has_node("%NitroButton"):
				hud.get_node("%NitroButton").modulate = Color(1.0, 1.0, 1.0, 1.0)

	if is_instance_valid(hud):
		hud.update_progress(session_distance_m, active_route.total_distance_m, session_coins)
		_update_next_waypoint_hud()

func _on_vehicle_fuel_changed(current: float, max_f: float) -> void:
	if is_instance_valid(hud):
		hud.update_fuel(current, max_f)
	if current <= 0.0 and current_state == ModeState.PLAYING:
		if is_instance_valid(hud):
			hud.show_announcement_toast("OUT OF PETROL!", "Collect petrol to restore power")

func _on_vehicle_nitro_changed(current: float, max_n: float) -> void:
	if is_instance_valid(hud):
		hud.update_nitro(current, max_n)

func _on_coin_collected(val: int) -> void:
	session_coins += val
	if is_instance_valid(hud):
		hud.update_progress(session_distance_m, active_route.total_distance_m, session_coins)

func _on_fuel_collected(amt: float) -> void:
	if is_instance_valid(active_vehicle):
		active_vehicle.refuel(amt)
	if is_instance_valid(hud):
		hud.show_announcement_toast("PETROL COLLECTED!", "+%d%% Fuel Refilled" % int(amt))

func _update_next_waypoint_hud() -> void:
	if active_route == null or not is_instance_valid(hud):
		return

	# Find next upcoming waypoint that has not been reached or passed
	var next_wp: WaypointData = null
	for wp in active_route.waypoints:
		if wp.waypoint_type == WaypointData.WaypointType.START:
			continue
		if _cleared_waypoint_ids.has(wp.id):
			continue
		# Also consider reached if player is within 3 meters or has passed it
		if wp.distance_m > session_distance_m + 3.0:
			next_wp = wp
			break

	if next_wp != null:
		var dist_rem := maxf(0.0, next_wp.distance_m - session_distance_m)
		hud.set_next_waypoint_info(next_wp.title, dist_rem)
	else:
		hud.set_next_waypoint_info("FINISH LINE", 0.0)

func _on_checkpoint_cleared(checkpoint_id: String, waypoint: WaypointData) -> void:
	checkpoints_cleared_count += 1
	var reward := waypoint.coins_reward if waypoint != null else 100
	session_coins += reward

	_mark_waypoint_reached(checkpoint_id, waypoint)

	var banner_text := waypoint.announcement_text if waypoint != null else "CHECKPOINT CLEARED!"
	if is_instance_valid(hud):
		hud.show_announcement_toast(banner_text, "+%d Coins Reward!" % reward)
		var info: Dictionary = LandmarkCatalogueData.get_landmark_info(checkpoint_id, active_route.state_id if active_route else "")
		if not info.is_empty() and info.get("name") != "Historical Landmark":
			hud.show_landmark_info(info)
	_update_next_waypoint_hud()

func _on_landmark_reached(landmark_id: String, waypoint: WaypointData) -> void:
	var reward := waypoint.coins_reward if waypoint != null else 50
	session_coins += reward

	_mark_waypoint_reached(landmark_id, waypoint)

	var banner_text := waypoint.announcement_text if waypoint != null else "LANDMARK DISCOVERED!"
	if is_instance_valid(hud):
		hud.show_announcement_toast(banner_text, "+%d Coins Reward" % reward)
		if waypoint == null or waypoint.waypoint_type != WaypointData.WaypointType.START:
			var info: Dictionary = LandmarkCatalogueData.get_landmark_info(landmark_id, active_route.state_id if active_route else "")
			hud.show_landmark_info(info)
	_update_next_waypoint_hud()

func _mark_waypoint_reached(target_id: String, waypoint: WaypointData) -> void:
	_cleared_waypoint_ids[target_id] = true
	if waypoint != null and waypoint.id != "":
		_cleared_waypoint_ids[waypoint.id] = true
	# Also match route waypoints by distance proximity (within 35m)
	if active_route != null:
		var target_dist: float = waypoint.distance_m if waypoint != null else session_distance_m
		for wp in active_route.waypoints:
			if absf(wp.distance_m - target_dist) <= 35.0:
				_cleared_waypoint_ids[wp.id] = true

func _on_destination_reached(dest_id: String, waypoint: WaypointData) -> void:
	if current_state == ModeState.COMPLETED:
		return
	current_state = ModeState.COMPLETED

	var final_reward := active_route.completion_reward_coins if active_route != null else 500
	session_coins += final_reward

	# Unlock next sequential state in progression
	var next_unlocked: String = RouteRegistry.complete_route(active_route.state_id)

	# Authoritatively record run and coins in SaveManager
	SaveManager.record_run(session_distance_m, session_coins)

	if is_instance_valid(active_vehicle) and active_vehicle.has_method("set_active"):
		active_vehicle.set_active(false)

	var toast_msg := "ROUTE COMPLETE!"
	var toast_sub := "+%d Grand Bonus Coins!" % final_reward
	if next_unlocked != "":
		var next_r := RouteRegistry.get_route(next_unlocked)
		toast_msg = "UNLOCKED: %s HIGHWAY!" % next_r.state_name.to_upper()
		toast_sub = "New State Unlocked +%d Coins!" % final_reward

	if is_instance_valid(hud):
		hud.show_announcement_toast(toast_msg, toast_sub)
		var info: Dictionary = LandmarkCatalogueData.get_landmark_info(dest_id, active_route.state_id if active_route else "")
		if not info.is_empty() and info.get("name") != "Historical Landmark":
			hud.show_landmark_info(info)

	# Present victory celebration screen after a short delay
	var next_id_copy := next_unlocked
	get_tree().create_timer(1.2).timeout.connect(func(): _show_victory_screen(next_id_copy))

	route_completed.emit(active_route.state_id, session_distance_m, session_time_s, session_coins)

func _show_victory_screen(next_unlocked: String = "") -> void:
	if not is_instance_valid(victory_screen):
		victory_screen = RouteCompleteScreenScene.instantiate() as RouteCompleteScreen
		ui_layer.add_child(victory_screen)
		victory_screen.replay_pressed.connect(func(): start_route(active_route))
		victory_screen.state_selection_pressed.connect(open_state_selection)
		victory_screen.return_to_main_menu_requested.connect(func(): return_to_main_menu_requested.emit())

	var total_cp := active_route.get_checkpoint_count() if active_route != null else 2
	victory_screen.display_results(
		active_route.state_name,
		active_route.destination_city,
		session_distance_m,
		checkpoints_cleared_count,
		total_cp,
		session_time_s,
		session_coins,
		next_unlocked
	)

func _on_vehicle_crashed() -> void:
	# Keep gameplay friendly: reset vehicle rotation, place safely on road, and restore driving
	if is_instance_valid(active_vehicle):
		var target_x: float = active_vehicle.global_position.x
		var safe_y: float = (active_terrain.get_height_at(target_x) - 45.0) if is_instance_valid(active_terrain) else 335.0
		var target_pos := Vector2(target_x, safe_y)
		if active_vehicle.has_method("recover_vehicle"):
			active_vehicle.recover_vehicle(target_pos)
		elif active_vehicle.has_method("reset_vehicle"):
			var saved_fuel: float = float(active_vehicle.current_fuel)
			var saved_nitro: float = float(active_vehicle.current_nitro)
			active_vehicle.reset_vehicle(target_pos)
			active_vehicle.current_fuel = saved_fuel
			active_vehicle.current_nitro = saved_nitro
			active_vehicle.fuel_changed.emit(saved_fuel, active_vehicle.max_fuel)
			active_vehicle.nitro_changed.emit(saved_nitro, active_vehicle.max_nitro)
		else:
			active_vehicle.global_position = target_pos
			active_vehicle.rotation = 0.0
			active_vehicle.linear_velocity = Vector2.ZERO
			active_vehicle.angular_velocity = 0.0
			active_vehicle.set_active(true)
		if is_instance_valid(hud):
			hud.show_announcement_toast("RECOVERED!", "Vehicle uprighted — continue driving!")

func _on_pause_requested() -> void:
	if current_state != ModeState.PLAYING:
		return
	current_state = ModeState.PAUSED
	get_tree().paused = true

	# Deactivate vehicle nitro and clear active inputs upon pause
	if is_instance_valid(active_vehicle):
		if active_vehicle.get("is_nitro_active") != null:
			active_vehicle.is_nitro_active = false

	if not is_instance_valid(pause_menu):
		pause_menu = PauseMenuScene.instantiate()
		ui_layer.add_child(pause_menu)
		if pause_menu.has_method("bind_game_manager"):
			_pause_bridge = _IndianPauseBridge.new(self)
			pause_menu.add_child(_pause_bridge)
			pause_menu.bind_game_manager(_pause_bridge)
		if pause_menu.has_signal("menu_requested") and not pause_menu.menu_requested.is_connected(_on_main_menu_from_pause):
			pause_menu.menu_requested.connect(_on_main_menu_from_pause)
		if pause_menu.has_signal("resume_pressed"):
			pause_menu.resume_pressed.connect(_on_resume_requested)
		if pause_menu.has_signal("restart_pressed"):
			pause_menu.restart_pressed.connect(_on_restart_from_pause)
		if pause_menu.has_signal("main_menu_pressed"):
			pause_menu.main_menu_pressed.connect(_on_main_menu_from_pause)

	# Crucial: Unconditionally display pause menu so first pause never freezes
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	if pause_menu.has_method("_on_run_paused"):
		pause_menu._on_run_paused(true)
	else:
		pause_menu.visible = true

func _on_resume_requested() -> void:
	if is_instance_valid(pause_menu):
		pause_menu.visible = false
	get_tree().paused = false
	current_state = ModeState.PLAYING

func _on_restart_from_pause() -> void:
	if is_instance_valid(pause_menu):
		pause_menu.visible = false
	get_tree().paused = false
	start_route(active_route)

func _on_main_menu_from_pause() -> void:
	if is_instance_valid(pause_menu):
		pause_menu.visible = false
	get_tree().paused = false
	return_to_main_menu_requested.emit()

func _on_map_requested() -> void:
	if current_state != ModeState.PLAYING:
		return
	current_state = ModeState.PAUSED
	get_tree().paused = true

	# Clear vehicle active input flags while map modal is open
	if is_instance_valid(active_vehicle):
		if active_vehicle.get("is_nitro_active") != null:
			active_vehicle.is_nitro_active = false

	if not is_instance_valid(route_map_overlay):
		route_map_overlay = RouteMapOverlayScene.instantiate() as RouteMapOverlay
		ui_layer.add_child(route_map_overlay)
		route_map_overlay.map_closed.connect(_on_map_closed)

	route_map_overlay.open_map(active_route, session_distance_m)

func _on_map_closed() -> void:
	get_tree().paused = false
	current_state = ModeState.PLAYING

func _clear_driving_world() -> void:
	if is_instance_valid(route_map_overlay):
		route_map_overlay.visible = false
	if is_instance_valid(pause_menu):
		pause_menu.visible = false
	if is_instance_valid(active_vehicle):
		active_vehicle.queue_free()
		active_vehicle = null
	if is_instance_valid(active_terrain):
		active_terrain.queue_free()
		active_terrain = null
	if is_instance_valid(victory_screen):
		victory_screen.visible = false
