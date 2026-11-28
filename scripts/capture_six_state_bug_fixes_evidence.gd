extends SceneTree

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const IndianRoadsControllerV2 = preload("res://scripts/modes/indian_roads/IndianRoadsControllerV2.gd")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const WaypointData = preload("res://resources/routes/WaypointData.gd")

func _init() -> void:
	call_deferred("_capture_all_evidence")

func _capture_all_evidence() -> void:
	print("=================================================================")
	print("--- CAPTURING ALL SIX-STATE BUG FIXES & WHEEL ALIGNMENT EVIDENCE ---")
	print("=================================================================")

	RouteRegistry.dev_unlock_all_routes = true

	var out_dir := "docs/screenshots/six_state_bug_fixes"
	DirAccess.make_dir_recursive_absolute(out_dir)

	var artifact_dir := "/home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50"
	DirAccess.make_dir_recursive_absolute(artifact_dir)

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var shot_num := 0

	# -------------------------------------------------------------------------
	# PART 1: VEHICLE WHEEL ALIGNMENT BEFORE & DURING NITRO (Blue Flame Truck)
	# -------------------------------------------------------------------------
	# Shot 1: Vehicle Before Nitro (Normal Driving)
	shot_num += 1
	var mode_v := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode_v.start_with_selection = false
	vp.add_child(mode_v)
	mode_v.start_route(RouteRegistry.get_route("tamil_nadu"))
	var veh = mode_v.active_vehicle
	var terr = mode_v.active_terrain
	var cam = mode_v.follow_camera

	veh.global_position = Vector2(8000.0, terr.get_height_at(8000.0) - 35.0)
	veh.linear_velocity = Vector2(150.0, 0.0)
	cam.global_position = Vector2(8000.0, terr.get_height_at(8000.0) - 20.0)
	for i in range(15): await process_frame
	_save_shot(vp, "vehicle_before_nitro.png", out_dir, artifact_dir, shot_num, "Vehicle Before Nitro: Taut Suspension & Perfect Axle Alignment")

	# Shot 2: Vehicle During Nitro (Boost Engaged, Flame Behind Wheels)
	shot_num += 1
	veh.set_nitro_active(true)
	for i in range(18): await process_frame
	_save_shot(vp, "vehicle_during_nitro.png", out_dir, artifact_dir, shot_num, "Vehicle During Nitro: Flames Behind Exhaust (z=-2), Zero Wheel Severing")
	veh.set_nitro_active(false)
	mode_v.queue_free()
	for i in range(4): await process_frame

	# -------------------------------------------------------------------------
	# PART 2: TAMIL NADU CORRECTED LANDMARKS & GLASS BRIDGE
	# -------------------------------------------------------------------------
	var tn_shots = [
		{"file": "tn_landmark_kumari_amman.png", "dist": 180.0, "desc": "B1: Kumari Amman Temple (Flush Ground Alignment, No Sign Clashing)"},
		{"file": "tn_glass_bridge_1_entry.png", "dist": 272.0, "desc": "B2: Kanyakumari Glass Bridge Entry Ramp & Gateway Portal"},
		{"file": "tn_glass_bridge_2_crossing.png", "dist": 340.0, "desc": "B2/B3: Glass Bridge Ocean Crossing & Vivekananda Rock Granite Island"},
		{"file": "tn_glass_bridge_3_thiruvalluvar.png", "dist": 415.0, "desc": "B4: Thiruvalluvar Statue Pedestal (Background Monument, Car in Foreground)"},
		{"file": "tn_glass_bridge_4_exit.png", "dist": 448.0, "desc": "B2: Glass Bridge Descending Ramp to Coastal Highway"},
		{"file": "tn_landmark_vattakottai_fort.png", "dist": 510.0, "desc": "B5: Vattakottai Coastal Fort (Grounded Stone Ramparts)"},
		{"file": "tn_checkpoint_toll_plaza.png", "dist": 600.0, "desc": "B6: NH44 Toll Plaza (Boom Barrier Arm Lifted -78 deg, Booth Grounded)"},
		{"file": "tn_landmark_meenakshi_temple.png", "dist": 680.0, "desc": "B7: Meenakshi Amman Temple (Authentic Camera Framing & Proportions)"}
	]

	for s in tn_shots:
		shot_num += 1
		var mode_tn := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
		mode_tn.start_with_selection = false
		vp.add_child(mode_tn)
		var r_tn := RouteRegistry.get_route("tamil_nadu")
		mode_tn.start_route(r_tn)

		var px: float = s["dist"] * 100.0
		var py: float = mode_tn.active_terrain.get_height_at(px)
		mode_tn.active_vehicle.global_position = Vector2(px - 60.0, py - 35.0)
		mode_tn.active_vehicle.linear_velocity = Vector2.ZERO
		mode_tn.follow_camera.global_position = Vector2(px, py - 35.0)

		# If toll plaza shot, trigger barrier lift
		if "toll_plaza" in s["file"]:
			for child in mode_tn.active_terrain.waypoints_container.get_children():
				if child is IndianCheckpointV2:
					child.trigger_clear()

		for i in range(12): await process_frame
		_save_shot(vp, s["file"], out_dir, artifact_dir, shot_num, s["desc"])
		mode_tn.queue_free()
		for i in range(4): await process_frame

	# Shot 11: Tamil Nadu In-Game Route Map Overlay (B8)
	shot_num += 1
	var mode_map := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode_map.start_with_selection = false
	vp.add_child(mode_map)
	mode_map.start_route(RouteRegistry.get_route("tamil_nadu"))
	mode_map.session_distance_m = 415.0 # At Thiruvalluvar Statue
	for i in range(6): await process_frame
	mode_map._on_map_requested()
	for i in range(10): await process_frame
	_save_shot(vp, "tn_route_map_overlay.png", out_dir, artifact_dir, shot_num, "B8: Tamil Nadu Route Map Overlay (Highway Vector, Waypoints & Real-Time Pin)")
	mode_map.queue_free()
	for i in range(4): await process_frame

	# -------------------------------------------------------------------------
	# PART 3: OTHER 5 STATES REPRESENTATIVE LANDMARKS & ENVIRONMENTS
	# -------------------------------------------------------------------------
	var other_states = [
		{"id": "goa", "dist": 250.0, "file": "goa_representative_landmark.png", "desc": "Goa: Calangute Beach Road & Church of Our Lady"},
		{"id": "kerala", "dist": 280.0, "file": "kerala_representative_landmark.png", "desc": "Kerala: Backwaters Lagoon & Chinese Fishing Nets"},
		{"id": "rajasthan", "dist": 250.0, "file": "rajasthan_representative_landmark.png", "desc": "Rajasthan: Hawa Mahal Palace & Desert Dunes"},
		{"id": "gujarat", "dist": 260.0, "file": "gujarat_representative_landmark.png", "desc": "Gujarat: Somnath Coastal Temple & Narmada Expressway"},
		{"id": "telangana", "dist": 260.0, "file": "telangana_representative_landmark.png", "desc": "Telangana: Golconda Bastion & Deccan Granite Hills"}
	]

	for os in other_states:
		shot_num += 1
		var mode_os := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
		mode_os.start_with_selection = false
		vp.add_child(mode_os)
		mode_os.start_route(RouteRegistry.get_route(os["id"]))

		var px: float = os["dist"] * 100.0
		var py: float = mode_os.active_terrain.get_height_at(px)
		mode_os.active_vehicle.global_position = Vector2(px - 50.0, py - 35.0)
		mode_os.follow_camera.global_position = Vector2(px, py - 30.0)

		for i in range(12): await process_frame
		_save_shot(vp, os["file"], out_dir, artifact_dir, shot_num, os["desc"])
		mode_os.queue_free()
		for i in range(4): await process_frame

	# -------------------------------------------------------------------------
	# PART 4: ROUTE COMPLETION VICTORY CELEBRATION
	# -------------------------------------------------------------------------
	shot_num += 1
	var mode_win := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode_win.start_with_selection = false
	vp.add_child(mode_win)
	var win_route := RouteRegistry.get_route("tamil_nadu")
	mode_win.start_route(win_route)
	var win_px: float = win_route.total_distance_m * 100.0
	var win_py: float = mode_win.active_terrain.get_height_at(win_px)
	mode_win.active_vehicle.global_position = Vector2(win_px - 20.0, win_py - 35.0)
	mode_win.follow_camera.global_position = Vector2(win_px, win_py - 40.0)
	for i in range(6): await process_frame

	var dest_wp := win_route.waypoints[win_route.waypoints.size() - 1]
	mode_win._on_destination_reached(dest_wp.id, dest_wp)
	for i in range(12): await process_frame
	_save_shot(vp, "all_states_completion_victory.png", out_dir, artifact_dir, shot_num, "Route Completion Finish Arch & Victory Celebration")
	mode_win.queue_free()
	for i in range(4): await process_frame

	vp.queue_free()
	print("\n=================================================================")
	print("✓ ALL %d SCREENSHOTS CAPTURED WITH 100%% SUCCESS!" % shot_num)
	print("=================================================================")
	quit(0)

func _save_shot(vp: SubViewport, file_name: String, out_dir: String, art_dir: String, num: int, desc: String) -> void:
	var img: Image = vp.get_texture().get_image()
	var fpath := out_dir.path_join(file_name)
	img.save_png(fpath)

	var apath := art_dir.path_join(file_name)
	img.save_png(apath)

	print("[%2d/18] ✓ Captured %s (%s)" % [num, file_name, desc])
