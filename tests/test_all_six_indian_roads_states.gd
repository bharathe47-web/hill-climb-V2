extends SceneTree

const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const StateSelectionScene = preload("res://scenes/modes/indian_roads/StateSelection.tscn")

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n========================================================")
	print("TESTING ALL 6 INDIAN ROADS STATES (PHASE 11 VERIFICATION)")
	print("========================================================")

	# Enable dev unlock to verify full lifecycle on all 6 states
	RouteRegistry.dev_unlock_all_routes = true

	var state_order = RouteRegistry.get_state_order()

	for state_id in state_order:
		print("\n>>> Testing State Route: %s <<<" % state_id)
		var route = RouteRegistry.get_route(state_id)
		
		# 1. Route Data Validation
		assert(route != null, "Route data is null for %s" % state_id)
		assert(route.waypoints.size() >= 4, "Route has too few waypoints: %d" % route.waypoints.size())
		print("  ✓ Route data: %s -> %s (%d m, %d waypoints)" % [
			route.start_city, route.destination_city, int(route.total_distance_m), route.waypoints.size()
		])

		# 2. Asset Integrity Check
		for wp in route.waypoints:
			if wp.landmark_texture_path != "":
				var exists = ResourceLoader.exists(wp.landmark_texture_path)
				assert(exists, "Missing texture for waypoint %s: %s" % [wp.title, wp.landmark_texture_path])
		print("  ✓ All waypoint textures verified on disk.")

		# 3. Instantiate Game Scene
		var mode = IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
		mode.start_with_selection = false
		mode.default_state_id = state_id
		root.add_child(mode)

		# Wait for scene tree frame
		await process_frame

		# 4. Verification of Scene Components
		var terr = mode.active_terrain
		var veh = mode.active_vehicle
		var hud = mode.hud
		var cam = mode.follow_camera
		var p_bg = mode.parallax_bg

		assert(terr != null, "Active terrain is null for %s" % state_id)
		assert(veh != null, "Vehicle failed to spawn for %s" % state_id)
		assert(hud != null, "HUD failed to instantiate for %s" % state_id)
		assert(cam != null, "FollowCamera missing for %s" % state_id)
		assert(p_bg != null, "ParallaxBackground missing for %s" % state_id)

		print("  ✓ Scene instantiation: Terrain points=%d, Props=%d, Waypoints=%d" % [
			terr.road_points.size(),
			terr.props_container.get_child_count(),
			terr.waypoints_container.get_child_count()
		])
		print("  ✓ Vehicle spawned at position: %s" % str(veh.global_position))
		print("  ✓ HUD next milestone: '%s' (%s)" % [hud.next_wp_label.text, hud.distance_label.text])

		# 5. Clean up
		mode.queue_free()
		await process_frame

	# Re-test StateSelection UI interaction
	print("\n>>> Verifying StateSelection UI Hub Integration <<<")
	var selection = StateSelectionScene.instantiate() as StateSelectionController
	root.add_child(selection)
	selection.refresh_routes()
	assert(selection.all_routes.size() == 6, "Expected 6 routes in selection UI, got %d" % selection.all_routes.size())
	print("  ✓ StateSelection cards successfully populated: 6/6 states.")
	selection.queue_free()

	# Reset dev flag
	RouteRegistry.dev_unlock_all_routes = false

	print("\n========================================================")
	print("ALL 6 INDIAN ROADS STATES TESTED AND FULLY OPERATIONAL!")
	print("========================================================")
	quit(0)
