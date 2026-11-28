extends SceneTree

const SaveManager = preload("res://scripts/core/SaveManager.gd")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const RouteData = preload("res://resources/routes/RouteData.gd")
const StateSelectionScene = preload("res://scenes/modes/indian_roads/StateSelection.tscn")
const IndianRoadsControllerScene = preload("res://scenes/modes/indian_roads/IndianRoadsMode.tscn")

func _init() -> void:
	call_deferred("_run_unlock_and_selection_tests")

func _run_unlock_and_selection_tests() -> void:
	print("=================================================================")
	print("--- TESTING SIX-STATE MAP UNLOCK & TELANGANA INTEGRATION ---")
	print("=================================================================")

	var test_save_path := "user://test_unlock_save.json"
	SaveManager.custom_save_path = test_save_path

	# -------------------------------------------------------------
	# TEST 1: Legacy Save Data Migration
	# -------------------------------------------------------------
	print("\n>>> TEST 1: Legacy Save Migration Test <<<")
	var legacy_data := {
		"version": 1,
		"best_distance": 850.0,
		"total_coins": 1250,
		"runs_played": 14,
		"selected_vehicle_id": "blue_flame_truck",
		"unlocked_vehicles": ["blue_flame_truck", "orc_racer"],
		"unlocked_routes": ["tamil_nadu"], # Old save with only Tamil Nadu
		"completed_routes": ["tamil_nadu"],
		"discovered_landmarks": ["tn_glass_bridge"],
		"upgrades": {"engine": 2, "tires": 1, "suspension": 2, "fuel_tank": 1, "nitro": 1}
	}
	var f := FileAccess.open(test_save_path, FileAccess.WRITE)
	f.store_string(JSON.stringify(legacy_data))
	f.close()

	var migrated_data := SaveManager.load_save()
	var expected_states: Array[String] = ["tamil_nadu", "goa", "kerala", "rajasthan", "gujarat", "telangana"]
	var unlocked_after: Array = migrated_data.get("unlocked_routes", [])

	print("  Migrated unlocked_routes: %s" % str(unlocked_after))
	var all_present := true
	for st in expected_states:
		if not (st in unlocked_after):
			all_present = false
			print("  [ERROR] Missing state '%s' in migrated unlocked_routes!" % st)

	assert(all_present, "All 6 states must be present after migration!")
	assert(migrated_data["total_coins"] == 1250, "Player coins must be preserved!")
	assert(migrated_data["best_distance"] == 850.0, "Player best distance must be preserved!")
	assert(migrated_data["upgrades"]["engine"] == 2, "Vehicle upgrades must be preserved!")
	print("  [PASS] Legacy save successfully migrated to all 6 states while 100% preserving coins, upgrades, and player stats!")

	# -------------------------------------------------------------
	# TEST 2: RouteRegistry Querying All Six States
	# -------------------------------------------------------------
	print("\n>>> TEST 2: RouteRegistry Unlock Statuses <<<")
	for st in expected_states:
		var is_unlocked := RouteRegistry.is_state_unlocked(st)
		print("  State '%s' is_unlocked: %s" % [st, str(is_unlocked)])
		assert(is_unlocked, "State '%s' should be unlocked in Version 1.0!" % st)

	var all_routes := RouteRegistry.get_all_routes()
	assert(all_routes.size() == 6, "Expected 6 routes in RouteRegistry!")
	for r in all_routes:
		assert(r.is_unlocked, "Route '%s' is_unlocked flag must be true!" % r.state_id)
	print("  [PASS] All 6 routes in RouteRegistry are unlocked.")

	# -------------------------------------------------------------
	# TEST 3: Telangana Route Verification
	# -------------------------------------------------------------
	print("\n>>> TEST 3: Telangana Route Data Specification <<<")
	var tel_route: RouteData = RouteRegistry.get_route("telangana")
	assert(tel_route != null, "Telangana route must exist!")
	print("  State ID: %s" % tel_route.state_id)
	print("  State Name: %s" % tel_route.state_name)
	print("  Journey: %s -> %s" % [tel_route.start_city, tel_route.destination_city])
	print("  Distance: %.1fm" % tel_route.total_distance_m)
	print("  Waypoints Count: %d" % tel_route.waypoints.size())
	print("  Checkpoints: %d" % tel_route.get_checkpoint_count())
	assert(tel_route.start_city == "Hyderabad", "Telangana start city should be Hyderabad")
	assert(tel_route.destination_city == "Golconda Fort, Hyderabad", "Telangana destination should be Golconda Fort, Hyderabad")
	assert(tel_route.is_unlocked, "Telangana route must be unlocked")
	print("  [PASS] Telangana route verified.")

	# -------------------------------------------------------------
	# TEST 4: StateSelectionController Hub UI & Selection
	# -------------------------------------------------------------
	print("\n>>> TEST 4: StateSelectionController UI & Start Button <<<")
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	root.add_child(vp)

	var selection_ctrl: StateSelectionController = StateSelectionScene.instantiate()
	vp.add_child(selection_ctrl)

	for f_idx in range(5):
		await physics_frame

	selection_ctrl.refresh_routes()

	# Select Telangana
	var emission_box: Array = [null]
	selection_ctrl.route_selected.connect(func(r: RouteData): emission_box[0] = r)

	selection_ctrl._on_card_selected(tel_route)

	print("  Current Selection: %s" % selection_ctrl.selected_route.state_name)
	print("  StartButton disabled: %s" % str(selection_ctrl.start_button.disabled))
	print("  StartButton text: '%s'" % selection_ctrl.start_button.text)
	print("  StateTitleLabel text: '%s'" % selection_ctrl.state_title_label.text)

	assert(selection_ctrl.selected_route.state_id == "telangana", "Telangana must be selected")
	assert(not selection_ctrl.start_button.disabled, "Start button MUST be enabled for Telangana!")
	assert(selection_ctrl.start_button.text == "DRIVE ROUTE", "Start button text must be 'DRIVE ROUTE'!")
	assert(not ("LOCKED" in selection_ctrl.state_title_label.text), "Title label must not indicate LOCKED!")

	# Simulate pressing Start Button
	selection_ctrl._on_start_pressed()
	assert(emission_box[0] != null and emission_box[0].state_id == "telangana", "Pressing start must emit route_selected with Telangana!")
	print("  [PASS] StateSelectionController displays Telangana as unlocked and emits route_selected correctly.")

	selection_ctrl.queue_free()

	# -------------------------------------------------------------
	# TEST 5: Full Route Game Loading into Telangana
	# -------------------------------------------------------------
	print("\n>>> TEST 5: Loading Telangana Route into IndianRoadsController <<<")
	var game_ctrl: IndianRoadsController = IndianRoadsControllerScene.instantiate()
	vp.add_child(game_ctrl)

	for f_idx in range(5):
		await physics_frame

	game_ctrl.start_route(tel_route)

	for f_idx in range(15):
		await physics_frame

	print("  Game Mode State: %s" % str(game_ctrl.current_state))
	print("  Active Route: %s (%s -> %s)" % [game_ctrl.active_route.state_name, game_ctrl.active_route.start_city, game_ctrl.active_route.destination_city])
	print("  Terrain Generated: %s" % str(game_ctrl.active_terrain != null))
	print("  Active Vehicle: %s" % str(game_ctrl.active_vehicle != null))
	print("  Camera Following: %s" % str(game_ctrl.follow_camera != null))

	assert(game_ctrl.active_route.state_id == "telangana", "IndianRoadsController active route must be Telangana")
	assert(game_ctrl.current_state == IndianRoadsController.ModeState.PLAYING, "Game state must be PLAYING")
	assert(game_ctrl.active_terrain != null, "Terrain must be generated for Telangana")
	assert(game_ctrl.active_vehicle != null, "Vehicle must be spawned")
	assert(game_ctrl.follow_camera != null, "Camera must be present")

	# Clean up test save file and nodes
	game_ctrl.queue_free()
	vp.queue_free()
	if FileAccess.file_exists(test_save_path):
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove("test_unlock_save.json")
	SaveManager.custom_save_path = ""

	print("\n=================================================================")
	print("--- ALL SIX-STATE UNLOCK & SELECTION TESTS PASSED (100%) ---")
	print("=================================================================")
	quit(0)
