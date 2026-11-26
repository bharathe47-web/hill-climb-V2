extends SceneTree

const MainScene = preload("res://scenes/main/Main.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

var passed: int = 0
var total: int = 0

func _check(cond: bool, msg: String) -> void:
	total += 1
	assert(cond, "FAIL: " + msg)
	passed += 1
	print("  [PASS] " + msg)

func _init() -> void:
	call_deferred("_run_all")

func _run_all() -> void:
	print("\n=================================================================")
	print("HILL CLIMB + INDIAN ROADS V2 FULL INTEGRATION TEST SUITE")
	print("=================================================================")

	# Isolate save path so test does not mutate user's real save
	SaveManager.custom_save_path = "user://test_indian_roads_integration_save.json"
	SaveManager.reset_save()

	# 1. Boot Main scene -> MainMenu
	var main := MainScene.instantiate() as MainController
	root.add_child(main)
	for i in range(3):
		await process_frame

	_check(main.current_scene_node is MainMenuController, "Main boots into MainMenuController")
	var menu := main.current_scene_node as MainMenuController
	var roads_sign: TextureButton = menu.get_node_or_null("%IndianRoadsSign")
	_check(roads_sign != null, "MainMenu contains %IndianRoadsSign")

	# 2. Click IndianRoadsSign -> transitions to IndianRoadsControllerV2 in Selection state
	roads_sign.emit_signal("pressed")
	for i in range(4):
		await process_frame

	_check(main.current_scene_node is IndianRoadsControllerV2, "Clicking IndianRoadsSign switches scene to IndianRoadsControllerV2")
	var ir: IndianRoadsControllerV2 = main.current_scene_node as IndianRoadsControllerV2
	_check(ir.current_state == IndianRoadsController.ModeState.SELECTION, "IndianRoadsControllerV2 starts in State Selection")
	_check(is_instance_valid(ir.state_selection_view), "StateSelectionView is instantiated")

	# 3. Verify all 6 states exist & are selectable
	var routes := RouteRegistry.get_all_routes()
	_check(routes.size() == 6, "All 6 Indian states registered (TN, GA, KL, RJ, GJ, TG)")
	for r in routes:
		_check(r.is_unlocked, "Route '%s' is unlocked" % r.state_id)

	# 4. Launch each state route cleanly and verify driving + terrain + HUD
	for r in routes:
		ir.state_selection_view._on_card_selected(r)
		ir.state_selection_view._on_start_pressed()
		for f in range(5):
			await process_frame
		_check(ir.current_state == IndianRoadsController.ModeState.PLAYING, "Route '%s' enters PLAYING state" % r.state_id)
		_check(is_instance_valid(ir.active_terrain) and ir.active_terrain.road_points.size() > 100, "Route '%s' generated road terrain" % r.state_id)
		_check(is_instance_valid(ir.active_vehicle), "Route '%s' spawned selected VehicleController" % r.state_id)
		_check(is_instance_valid(ir.hud), "Route '%s' initialized IndianRoadsHUD" % r.state_id)

		if r.state_id == "tamil_nadu":
			_check(r.waypoints.size() == 13, "Tamil Nadu has exact 13 waypoints")
			var meenakshi_wp := r.waypoints[5]
			_check(meenakshi_wp.id == "tn_06_madurai" and "madurai_meenakshi_amman_temple_supplied.png" in meenakshi_wp.landmark_texture_path, "Tamil Nadu Madurai uses supplied Meenakshi Amman Temple asset")
			_check(ResourceLoader.exists(meenakshi_wp.landmark_texture_path), "Supplied Meenakshi Amman Temple asset exists in hill climb")

		# Drive briefly with throttle + nitro
		Input.action_press("accelerate")
		ir.active_vehicle.set_nitro_active(true)
		for pf in range(15):
			await physics_frame
		Input.action_release("accelerate")
		ir.active_vehicle.set_nitro_active(false)
		_check(ir.active_vehicle.global_position.x > 5.0, "Vehicle drives smoothly forward in '%s' (x=%.1f)" % [r.state_id, ir.active_vehicle.global_position.x])

		# Return to selection for next state
		ir.open_state_selection()
		await process_frame

	# 5. Test Tamil Nadu PauseMenu (Pause -> Resume -> Pause -> Restart -> Pause -> Main Menu) & Crash Recovery
	var tn_route := RouteRegistry.get_route("tamil_nadu")
	ir.start_route(tn_route)
	for f in range(4):
		await process_frame

	# Test crash recovery fuel/nitro preservation
	ir.active_vehicle.current_fuel = 62.5
	ir.active_vehicle.current_nitro = 48.0
	ir._on_vehicle_crashed()
	await process_frame
	_check(absf(ir.active_vehicle.current_fuel - 62.5) < 0.1, "Crash recovery preserves vehicle fuel in hill climb")
	_check(absf(ir.active_vehicle.current_nitro - 48.0) < 0.1, "Crash recovery preserves vehicle nitro in hill climb")

	# Test Map Overlay
	ir._on_map_requested()
	await process_frame
	_check(ir.current_state == IndianRoadsController.ModeState.PAUSED and paused, "Opening Route Map pauses cleanly")
	ir._on_map_closed()
	await process_frame
	_check(ir.current_state == IndianRoadsController.ModeState.PLAYING and not paused, "Closing Route Map resumes cleanly")

	# Test Pause Menu Resume & Restart & Return to MainMenu
	ir._on_pause_requested()
	await process_frame
	_check(ir.current_state == IndianRoadsController.ModeState.PAUSED and is_instance_valid(ir.pause_menu) and ir.pause_menu.visible, "Pause opens PauseMenu cleanly")
	ir.pause_menu._on_resume_pressed()
	await process_frame
	_check(ir.current_state == IndianRoadsController.ModeState.PLAYING and not paused and not ir.pause_menu.visible, "PauseMenu Resume unpauses IndianRoadsControllerV2")

	ir._on_pause_requested()
	await process_frame
	ir.pause_menu._on_retry_pressed()
	for f in range(4):
		await process_frame
	_check(ir.current_state == IndianRoadsController.ModeState.PLAYING and not paused, "PauseMenu Retry cleanly restarts route")

	ir._on_pause_requested()
	await process_frame
	ir.pause_menu._on_main_menu_pressed()
	for f in range(4):
		await process_frame
	_check(main.current_scene_node is MainMenuController and not paused, "PauseMenu MainMenu button returns cleanly to MainMenu")

	# 6. Enter IndianRoads -> press BackButton -> verify clean return to MainMenu
	menu = main.current_scene_node as MainMenuController
	menu.get_node("%IndianRoadsSign").emit_signal("pressed")
	for f in range(4):
		await process_frame
	var ir2 := main.current_scene_node as IndianRoadsControllerV2
	ir2.state_selection_view.back_button.emit_signal("pressed")
	for f in range(4):
		await process_frame
	_check(main.current_scene_node is MainMenuController, "StateSelection BackButton returns cleanly to MainMenu")

	# 7. Verify existing Endless mode still launches cleanly from MainMenu
	menu = main.current_scene_node as MainMenuController
	menu.get_node("%EndlessSign").emit_signal("pressed")
	for f in range(4):
		await process_frame
	_check(main.current_scene_node is GameScene, "EndlessSign still launches GameScene cleanly with zero conflict")

	main.queue_free()
	await process_frame
	SaveManager.reset_save()
	SaveManager.custom_save_path = ""

	print("\n=================================================================")
	print("INTEGRATION VERIFICATION SUMMARY: %d / %d CHECKS PASSED" % [passed, total])
	print("=================================================================\n")
	quit(0)
