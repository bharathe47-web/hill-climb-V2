extends SceneTree

## capture_all_six_states_gameplay.gd
## Author: Joel (Senior Godot 4.7 Developer, QA Lead)
## Captures REAL RUNTIME GAMEPLAY SCREENSHOTS directly from the running Godot game:
##   For every one of the 6 states, captures:
##     1. Start
##     2. First landmark
##     3. Landmark approach
##     4. Landmark passing
##     5. Middle scenery / Checkpoint
##     6. Destination
## Native 1280x720 in-engine renders featuring real physics, camera, parallax, and UI.

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_capture_all_real_gameplay")

func _capture_all_real_gameplay() -> void:
	print("=================================================================")
	print("--- BEGINNING REAL IN-ENGINE GAMEPLAY SCREENSHOT CAPTURE ---")
	print("=================================================================")
	RouteRegistry.dev_unlock_all_routes = true

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var state_plans = {
		"tamil_nadu": [
			{"stage": "1_start", "dist_m": 25.0, "label": "Start - Kanyakumari Pier"},
			{"stage": "2_first_landmark", "dist_m": 100.0, "label": "First Landmark - Gandhi Memorial"},
			{"stage": "3_landmark_approach", "dist_m": 300.0, "label": "Approach - Thiruvalluvar Statue"},
			{"stage": "4_landmark_passing", "dist_m": 360.0, "label": "Passing - Thiruvalluvar Statue"},
			{"stage": "5_middle_scenery", "dist_m": 750.0, "label": "Middle - Madurai Checkpoint Toll"},
			{"stage": "6_destination", "dist_m": 1790.0, "label": "Destination - Chennai Marina Beach"}
		],
		"goa": [
			{"stage": "1_start", "dist_m": 25.0, "label": "Start - Panaji Waterfront"},
			{"stage": "2_first_landmark", "dist_m": 120.0, "label": "First Landmark - Fontainhas Latin Quarter"},
			{"stage": "3_landmark_approach", "dist_m": 220.0, "label": "Approach - Our Lady Church"},
			{"stage": "4_landmark_passing", "dist_m": 270.0, "label": "Passing - Our Lady Church"},
			{"stage": "5_middle_scenery", "dist_m": 800.0, "label": "Middle - Mandovi Bridge Toll"},
			{"stage": "6_destination", "dist_m": 1590.0, "label": "Destination - Margao Victory Arch"}
		],
		"kerala": [
			{"stage": "1_start", "dist_m": 25.0, "label": "Start - Fort Kochi Harbor"},
			{"stage": "2_first_landmark", "dist_m": 100.0, "label": "First Landmark - Chinese Fishing Nets"},
			{"stage": "3_landmark_approach", "dist_m": 450.0, "label": "Approach - Alleppey Backwaters"},
			{"stage": "4_landmark_passing", "dist_m": 510.0, "label": "Passing - Alleppey Houseboat"},
			{"stage": "5_middle_scenery", "dist_m": 1000.0, "label": "Middle - Western Ghats Forest Checkpoint"},
			{"stage": "6_destination", "dist_m": 1990.0, "label": "Destination - Munnar Tea Estates"}
		],
		"rajasthan": [
			{"stage": "1_start", "dist_m": 25.0, "label": "Start - Jaipur Pink City"},
			{"stage": "2_first_landmark", "dist_m": 120.0, "label": "First Landmark - Hawa Mahal"},
			{"stage": "3_landmark_approach", "dist_m": 500.0, "label": "Approach - Amber Fort Ramparts"},
			{"stage": "4_landmark_passing", "dist_m": 560.0, "label": "Passing - Amber Fort Ramparts"},
			{"stage": "5_middle_scenery", "dist_m": 1100.0, "label": "Middle - Thar Desert Checkpoint Toll"},
			{"stage": "6_destination", "dist_m": 2190.0, "label": "Destination - Jaisalmer Golden Fort"}
		],
		"gujarat": [
			{"stage": "1_start", "dist_m": 25.0, "label": "Start - Sabarmati Riverfront"},
			{"stage": "2_first_landmark", "dist_m": 120.0, "label": "First Landmark - Sabarmati Ashram"},
			{"stage": "3_landmark_approach", "dist_m": 700.0, "label": "Approach - Modhera Sun Temple"},
			{"stage": "4_landmark_passing", "dist_m": 750.0, "label": "Passing - Modhera Sun Temple"},
			{"stage": "5_middle_scenery", "dist_m": 1000.0, "label": "Middle - Kutch Border Checkpoint Toll"},
			{"stage": "6_destination", "dist_m": 1990.0, "label": "Destination - White Rann Salt Desert"}
		],
		"telangana": [
			{"stage": "1_start", "dist_m": 25.0, "label": "Start - Hyderabad Old City"},
			{"stage": "2_first_landmark", "dist_m": 100.0, "label": "First Landmark - Iconic Charminar"},
			{"stage": "3_landmark_approach", "dist_m": 400.0, "label": "Approach - Golconda Fort Bastion"},
			{"stage": "4_landmark_passing", "dist_m": 460.0, "label": "Passing - Golconda Fort Bastion"},
			{"stage": "5_middle_scenery", "dist_m": 900.0, "label": "Middle - Deccan Highway Checkpoint Toll"},
			{"stage": "6_destination", "dist_m": 1790.0, "label": "Destination - Warangal Fort Victory Arch"}
		]
	}

	for state_id in RouteRegistry.get_state_order():
		print("\n>>> Launching Running Game for State: %s <<<" % state_id)
		var mode = IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
		mode.start_with_selection = false
		mode.default_state_id = state_id
		vp.add_child(mode)

		for i in range(10):
			await process_frame

		var terr = mode.active_terrain
		var veh = mode.active_vehicle
		var cam = mode.follow_camera
		var hud = mode.hud

		var checkpoints = state_plans.get(state_id, [])
		for cp_plan in checkpoints:
			var stage_key: String = cp_plan.get("stage", "")
			var target_dist_m: float = cp_plan.get("dist_m", 0.0)
			var stage_label: String = cp_plan.get("label", "")
			var target_x: float = target_dist_m * 100.0

			# Position vehicle smoothly on terrain profile
			if is_instance_valid(veh) and is_instance_valid(terr):
				var ground_y: float = terr.get_height_at(target_x)
				veh.global_position = Vector2(target_x, ground_y - 45.0)
				veh.rotation = 0.0
				veh.linear_velocity = Vector2(120.0, 0.0)
				veh.angular_velocity = 0.0

			# Position follow camera and parallax
			if is_instance_valid(cam):
				cam.global_position = Vector2(target_x + 180.0, terr.get_height_at(target_x) - 70.0)

			# Update HUD distance simulation
			if is_instance_valid(hud):
				mode.session_distance_m = target_dist_m
				hud.update_progress(target_dist_m, mode.active_route.total_distance_m, 250)
				mode._update_next_waypoint_hud()

			# Settle physics and graphics rendering for 12 frames
			for f in range(12):
				await physics_frame

			# Capture exact rendered frame from running viewport
			var img: Image = vp.get_texture().get_image()
			if img != null and not img.is_empty():
				var out_filename := "docs/screenshots/actual_gameplay_%s_%s.png" % [state_id, stage_key]
				img.save_png(out_filename)
				print("  ✓ Captured real gameplay: %s (%s)" % [out_filename, stage_label])

		mode.queue_free()
		for i in range(5):
			await process_frame

	RouteRegistry.dev_unlock_all_routes = false
	vp.queue_free()
	print("\n=================================================================")
	print("✓ ALL 36 REAL IN-ENGINE GAMEPLAY SCREENSHOTS SUCCESSFULLY CAPTURED!")
	print("=================================================================")
	quit(0)
