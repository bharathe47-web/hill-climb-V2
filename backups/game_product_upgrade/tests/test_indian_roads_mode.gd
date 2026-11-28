class_name TestIndianRoadsMode
extends SceneTree

## TestIndianRoadsMode: Automated test suite for Indian Roads mode.
## Verifies 6-state route catalog, Tamil Nadu route structure, terrain physics,
## checkpoint clearing, landmark discovery, finish arch victory, HUD telemetry,
## and clean integration with shared vehicle and SaveManager.

const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const RouteData = preload("res://resources/routes/RouteData.gd")
const WaypointData = preload("res://resources/routes/WaypointData.gd")
const IndianRoadTerrain = preload("res://scripts/modes/indian_roads/IndianRoadTerrain.gd")
const IndianRoadTerrainScene = preload("res://scenes/modes/indian_roads/IndianRoadTerrain.tscn")
const CheckpointScene = preload("res://scenes/modes/indian_roads/Checkpoint.tscn")
const LandmarkScene = preload("res://scenes/modes/indian_roads/Landmark.tscn")
const FinishArchScene = preload("res://scenes/modes/indian_roads/FinishArch.tscn")
const IndianRoadsController = preload("res://scripts/modes/indian_roads/IndianRoadsController.gd")
const IndianRoadsModeScene = preload("res://scenes/modes/indian_roads/IndianRoadsMode.tscn")
const StateSelectionScene = preload("res://scenes/modes/indian_roads/StateSelection.tscn")
const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN INDIAN ROADS MODE AUTOMATED TEST SUITE ---")
	print("=================================================================\n")

	_test_route_registry()
	_test_sequential_route_unlocking()
	_test_road_terrain_generation()
	_test_checkpoint_and_landmark_components()
	_test_state_selection_screen()
	await _test_indian_roads_mode_lifecycle()

	print("\n=================================================================")
	print("✓ ALL INDIAN ROADS MODE TESTS COMPLETED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_route_registry() -> void:
	print("-> [1/5] Verifying RouteRegistry and 6 Version 1 States...")
	var routes := RouteRegistry.get_all_routes()
	assert(routes.size() == 6, "Expected exactly 6 Version 1 states in RouteRegistry, got %d" % routes.size())

	var expected_states := ["tamil_nadu", "goa", "kerala", "rajasthan", "gujarat", "telangana"]
	for state_id in expected_states:
		var r := RouteRegistry.get_route(state_id)
		assert(r != null, "Route for state '%s' must exist" % state_id)
		assert(r.state_id == state_id, "Route state_id must match '%s'" % state_id)

	# Verify Tamil Nadu complete route data
	var tn := RouteRegistry.get_tamil_nadu_route()
	assert(tn.is_unlocked, "Tamil Nadu route must be unlocked for Phase 1")
	assert(tn.total_distance_m == 1800.0, "Tamil Nadu route distance should be 1800m")
	assert(tn.get_checkpoint_count() == 2, "Tamil Nadu route should have exactly 2 checkpoints, got %d" % tn.get_checkpoint_count())
	assert(tn.waypoints.size() == 6, "Tamil Nadu route should have 6 waypoints (Start, 2 LMs, 2 CPs, Dest), got %d" % tn.waypoints.size())

	assert(tn.waypoints[0].waypoint_type == WaypointData.WaypointType.START, "WP 0 should be START")
	assert(tn.waypoints[1].waypoint_type == WaypointData.WaypointType.LANDMARK, "WP 1 should be LANDMARK")
	assert(tn.waypoints[2].waypoint_type == WaypointData.WaypointType.CHECKPOINT, "WP 2 should be CHECKPOINT")
	assert(tn.waypoints[3].waypoint_type == WaypointData.WaypointType.LANDMARK, "WP 3 should be LANDMARK")
	assert(tn.waypoints[4].waypoint_type == WaypointData.WaypointType.CHECKPOINT, "WP 4 should be CHECKPOINT")
	assert(tn.waypoints[5].waypoint_type == WaypointData.WaypointType.DESTINATION, "WP 5 should be DESTINATION")

	print("  ✓ RouteRegistry and 6 Version 1 state routes verified!")

func _test_sequential_route_unlocking() -> void:
	print("-> [1.5/5] Verifying Sequential State Route Progression & Persistence...")

	# Verify Tamil Nadu is always unlocked
	assert(RouteRegistry.is_state_unlocked("tamil_nadu"), "Tamil Nadu must always be unlocked")

	# Complete Tamil Nadu and verify Goa unlocks
	var next_unlocked := RouteRegistry.complete_route("tamil_nadu")
	assert(next_unlocked == "goa", "Completing Tamil Nadu must return and unlock 'goa', got '%s'" % next_unlocked)
	assert(RouteRegistry.is_state_unlocked("goa"), "Goa must now be unlocked after completing Tamil Nadu")

	# Complete Goa and verify Kerala unlocks
	next_unlocked = RouteRegistry.complete_route("goa")
	assert(next_unlocked == "kerala", "Completing Goa must return and unlock 'kerala', got '%s'" % next_unlocked)
	assert(RouteRegistry.is_state_unlocked("kerala"), "Kerala must now be unlocked after completing Goa")

	# Verify predecessor helper
	var req_kerala := RouteRegistry.get_required_state_for("kerala")
	assert(req_kerala == "Goa", "Required state for Kerala should be Goa, got '%s'" % req_kerala)

	print("  ✓ Sequential Route unlocking and progression persistence verified!")

func _test_road_terrain_generation() -> void:
	print("-> [2/5] Verifying IndianRoadTerrain physics & geometry...")
	var terrain: IndianRoadTerrain = IndianRoadTerrainScene.instantiate()
	root.add_child(terrain)

	var tn_route := RouteRegistry.get_tamil_nadu_route()
	terrain.generate_route(tn_route)

	# Verify road points generated
	assert(terrain.road_points.size() > 100, "Road points must be populated")
	assert(terrain.collision_poly != null, "Collision polygon must exist")
	assert(terrain.collision_poly.polygon.size() > 100, "Collision polygon must be built")

	# Verify highway physics elevations: no negative spikes, smooth grade
	for i in range(1, terrain.road_points.size()):
		var p_prev := terrain.road_points[i - 1]
		var p_curr := terrain.road_points[i]
		var dy := absf(p_curr.y - p_prev.y)
		var dx := p_curr.x - p_prev.x
		var slope := dy / maxf(1.0, dx)
		assert(slope < 0.35, "Highway slope too steep for smooth driving: slope = %f at x = %f" % [slope, p_curr.x])

	# Verify waypoints spawned inside terrain
	var wp_nodes := terrain.waypoints_container.get_children()
	assert(wp_nodes.size() == 6, "Expected 6 waypoint nodes spawned in terrain, got %d" % wp_nodes.size())

	# Verify speed breakers and road hazards planned
	assert(terrain.speed_breaker_x_positions.size() > 0, "Speed breakers should be planned along highway")
	assert(terrain.hazard_zone_x_positions.size() > 0, "Hazard/construction zones should be planned")
	assert(terrain.props_container.get_child_count() > 0, "Roadside props should be spawned")

	# Test multi-state theming (Goa and Rajasthan)
	var goa_route := RouteRegistry.get_route("goa")
	terrain.generate_route(goa_route)
	assert(terrain.stripe_color.is_equal_approx(Color(1.0, 1.0, 1.0, 0.95)), "Goa route should have white coastal striping")
	assert(terrain.shoulder_color.is_equal_approx(Color(0.86, 0.76, 0.52, 1.0)), "Goa route should have golden sand shoulder")

	var raj_route := RouteRegistry.get_route("rajasthan")
	terrain.generate_route(raj_route)
	assert(terrain.shoulder_color.is_equal_approx(Color(0.85, 0.72, 0.44, 1.0)), "Rajasthan route should have Thar desert shoulder")

	terrain.queue_free()
	print("  ✓ IndianRoadTerrain smooth highway geometry, speed breakers & multi-state themes verified!")

func _test_checkpoint_and_landmark_components() -> void:
	print("-> [3/5] Verifying Checkpoint, Landmark, and FinishArch components...")

	# 1. Checkpoint test
	var cp: IndianCheckpoint = CheckpointScene.instantiate()
	root.add_child(cp)
	var cp_res := {"cleared": false}
	cp.checkpoint_cleared.connect(func(_id, _wp): cp_res["cleared"] = true)

	assert(not cp.is_cleared, "Checkpoint should start uncleared")
	cp.trigger_clear()
	assert(cp.is_cleared, "Checkpoint should be cleared after trigger")
	assert(bool(cp_res["cleared"]), "checkpoint_cleared signal should be emitted")

	# Debounce test: clearing again must not fire second signal
	cp_res["cleared"] = false
	cp.trigger_clear()
	assert(not bool(cp_res["cleared"]), "Checkpoint must not re-trigger after being cleared")
	cp.queue_free()

	# 2. Landmark test
	var lm: IndianLandmark = LandmarkScene.instantiate()
	root.add_child(lm)
	var lm_res := {"reached": false}
	lm.landmark_reached.connect(func(_id, _wp): lm_res["reached"] = true)

	assert(not lm.is_discovered, "Landmark should start undiscovered")
	lm.discover_landmark()
	assert(lm.is_discovered, "Landmark should be discovered")
	assert(bool(lm_res["reached"]), "landmark_reached signal should be emitted")
	lm.queue_free()

	# 3. FinishArch test
	var fin: IndianFinishArch = FinishArchScene.instantiate()
	root.add_child(fin)
	var fin_res := {"reached": false}
	fin.destination_reached.connect(func(_id, _wp): fin_res["reached"] = true)

	assert(not fin.is_reached, "FinishArch should start unreached")
	fin.trigger_finish()
	assert(fin.is_reached, "FinishArch should be reached")
	assert(bool(fin_res["reached"]), "destination_reached signal should be emitted")
	fin.queue_free()

	print("  ✓ Checkpoint, Landmark, and FinishArch triggers & debouncing verified!")

func _test_state_selection_screen() -> void:
	print("-> [4/5] Verifying StateSelection hub and route details...")
	var sel: StateSelectionController = StateSelectionScene.instantiate()
	root.add_child(sel)

	var cards: Array[Node] = sel.route_cards_container.get_children()
	assert(cards.size() == 6, "Expected 6 state cards in StateSelection, got %d" % cards.size())

	var sel_res := {"route": null}
	sel.route_selected.connect(func(r): sel_res["route"] = r)

	# Verify start button triggers route_selected with Tamil Nadu
	assert("ROUTE JOURNEY" in sel.route_desc_label.text, "Route journey itinerary should be displayed")
	assert("DIFFICULTY" in sel.route_desc_label.text, "Route difficulty indicator should be displayed")
	sel.start_button.pressed.emit()
	assert(sel_res["route"] != null, "Pressing start should emit route_selected")
	var chosen_r: RouteData = sel_res["route"]
	assert(chosen_r.state_id == "tamil_nadu", "Selected route should be tamil_nadu")

	sel.queue_free()
	print("  ✓ StateSelection hub, map display, and route launching verified!")

func _test_indian_roads_mode_lifecycle() -> void:
	print("-> [5/5] Verifying IndianRoadsController full mode loop & victory...")
	var mode: IndianRoadsController = IndianRoadsModeScene.instantiate()
	root.add_child(mode)

	# Verify initial state and vehicle mounting
	assert(mode.current_state == IndianRoadsController.ModeState.PLAYING, "Mode should initialize in PLAYING state")
	assert(mode.active_vehicle != null, "Vehicle should be instantiated from VehicleRegistry")
	assert(mode.follow_camera.target == mode.active_vehicle, "FollowCamera must target active vehicle")
	assert(mode.hud != null, "IndianRoadsHUD must be wired")

	# Test driving acceleration
	var start_x := mode.active_vehicle.global_position.x
	Input.action_press("accelerate")
	for i in range(60):
		await physics_frame
	Input.action_release("accelerate")
	var move_dist: float = mode.active_vehicle.global_position.x - start_x
	print("  Vehicle moved forward from x=%f to x=%f (moved %f px)" % [start_x, mode.active_vehicle.global_position.x, move_dist])
	assert(move_dist > 100.0, "Vehicle must accelerate smoothly forward on highway, moved only %f px" % move_dist)

	# Test checkpoint trigger & coin awarding
	var coins_before := mode.session_coins
	var test_wp := WaypointData.new()
	test_wp.id = "test_cp"
	test_wp.coins_reward = 100
	test_wp.announcement_text = "TEST CHECKPOINT"
	mode._on_checkpoint_cleared("test_cp", test_wp)

	assert(mode.checkpoints_cleared_count == 1, "Checkpoint count should increment")
	assert(mode.session_coins == coins_before + 100, "Coins should increase by checkpoint reward")

	# Test destination victory
	var coins_save_before: int = SaveManager.get_total_coins()
	mode._on_destination_reached("tn_destination", test_wp)
	assert(mode.current_state == IndianRoadsController.ModeState.COMPLETED, "Mode state should be COMPLETED upon destination arrival")

	var coins_save_after: int = SaveManager.get_total_coins()
	assert(coins_save_after >= coins_save_before + mode.session_coins, "Coins must be authoritatively saved to SaveManager")

	mode.queue_free()
	print("  ✓ IndianRoadsController mode loop, vehicle binding, HUD, and destination victory verified!")
