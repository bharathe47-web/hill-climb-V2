extends SceneTree

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const IndianRoadsControllerV2 = preload("res://scripts/modes/indian_roads/IndianRoadsControllerV2.gd")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_capture_all_evidence")

func _capture_all_evidence() -> void:
	print("=================================================================")
	print("--- CAPTURING ALL 12 GAMEPLAY REFINEMENT SCREENSHOTS ---")
	print("=================================================================")

	RouteRegistry.dev_unlock_all_routes = true

	var out_dir := "docs/screenshots/gameplay_refinement"
	DirAccess.make_dir_recursive_absolute(out_dir)

	var artifact_dir := "/home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50"
	DirAccess.make_dir_recursive_absolute(artifact_dir)

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	# --- PART 1: Six State Gameplay Screenshots ---
	var states = [
		{"id": "tamil_nadu", "dist": 40.0, "file": "tn_start_gameplay.png", "desc": "Tamil Nadu Start: Vehicle, HUD, Compact Nitro & Map Buttons"},
		{"id": "goa", "dist": 350.0, "file": "goa_gameplay.png", "desc": "Goa Coastal Highway: Calangute Beach & Fort Aguada"},
		{"id": "kerala", "dist": 320.0, "file": "kerala_gameplay.png", "desc": "Kerala Backwaters: Alleppey Wharf & Palm Scenery"},
		{"id": "rajasthan", "dist": 350.0, "file": "rajasthan_gameplay.png", "desc": "Rajasthan Highway: Amber Fort Gateway & Desert Terrain"},
		{"id": "gujarat", "dist": 320.0, "file": "gujarat_gameplay.png", "desc": "Gujarat Highway: Saurashtra Oasis & Savanna"},
		{"id": "telangana", "dist": 300.0, "file": "telangana_gameplay.png", "desc": "Telangana Highway: Golconda Fort Bastion & Deccan Rocks"}
	]

	var shot_num := 0
	for s in states:
		shot_num += 1
		var mode := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
		mode.start_with_selection = false
		vp.add_child(mode)

		var route := RouteRegistry.get_route(s["id"])
		mode.start_route(route)

		var px: float = s["dist"] * 100.0
		var terr = mode.active_terrain
		var py: float = terr.get_height_at(px) if terr else 382.0

		if is_instance_valid(mode.active_vehicle):
			mode.active_vehicle.global_position = Vector2(px, py - 35.0)
			mode.active_vehicle.linear_velocity = Vector2.ZERO
		if is_instance_valid(mode.follow_camera):
			mode.follow_camera.global_position = Vector2(px + 120.0, py - 20.0)

		for i in range(12):
			await process_frame

		_save_shot(vp, s["file"], out_dir, artifact_dir, shot_num, s["desc"])
		mode.queue_free()
		for i in range(4):
			await process_frame

	# --- PART 2: Specialized Feature Verification Screenshots ---
	# Shot 7: Compact Nitro Button (Focused View / In-Game HUD)
	shot_num += 1
	var mode_nitro := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode_nitro.start_with_selection = false
	vp.add_child(mode_nitro)
	mode_nitro.start_route(RouteRegistry.get_route("tamil_nadu"))
	for i in range(10): await process_frame
	_save_shot(vp, "compact_nitro_button.png", out_dir, artifact_dir, shot_num, "Compact 80x80 Nitro Button & HUD Controls")
	mode_nitro.queue_free()
	for i in range(4): await process_frame

	# Shot 8: Route Map Opened Modal
	shot_num += 1
	var mode_map := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode_map.start_with_selection = false
	vp.add_child(mode_map)
	mode_map.start_route(RouteRegistry.get_route("tamil_nadu"))
	mode_map.active_vehicle.global_position.x = 42000.0
	mode_map.session_distance_m = 420.0
	for i in range(8): await process_frame
	mode_map._on_map_requested()
	for i in range(10): await process_frame
	_save_shot(vp, "route_map_opened.png", out_dir, artifact_dir, shot_num, "In-Game Tourism Route Map Modal with SVG State Map & Waypoints")
	mode_map.queue_free()
	for i in range(4): await process_frame

	# Shot 9: Pause Menu Active (Bug Fix Verified)
	shot_num += 1
	var mode_pause := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode_pause.start_with_selection = false
	vp.add_child(mode_pause)
	mode_pause.start_route(RouteRegistry.get_route("tamil_nadu"))
	for i in range(8): await process_frame
	mode_pause._on_pause_requested()
	for i in range(10): await process_frame
	_save_shot(vp, "pause_menu_active.png", out_dir, artifact_dir, shot_num, "Pause Menu Active Overlay with Resume/Restart/Main Menu (Bug Fixed)")

	# Shot 10: Resume Gameplay
	shot_num += 1
	mode_pause._on_resume_requested()
	for i in range(10): await process_frame
	_save_shot(vp, "resume_gameplay.png", out_dir, artifact_dir, shot_num, "Seamless Gameplay Resumed Post-Pause without Reset")
	mode_pause.queue_free()
	for i in range(4): await process_frame

	# Shot 11: Correct Landmark & Signboard Positioning (Behind car, z_index = -1)
	shot_num += 1
	var mode_lm := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode_lm.start_with_selection = false
	vp.add_child(mode_lm)
	mode_lm.start_route(RouteRegistry.get_route("tamil_nadu"))
	# Position vehicle right at Vivekananda Rock Memorial / Thiruvalluvar landmark (x = 415m = 41500px)
	var lm_px := 41500.0
	var lm_py: float = mode_lm.active_terrain.get_height_at(lm_px)
	mode_lm.active_vehicle.global_position = Vector2(lm_px - 80.0, lm_py - 35.0)
	mode_lm.follow_camera.global_position = Vector2(lm_px, lm_py - 40.0)
	for i in range(12): await process_frame
	_save_shot(vp, "correct_landmark_positioning.png", out_dir, artifact_dir, shot_num, "Landmark & Signboard Correctly Positioned Behind Car (z_index=-1)")
	mode_lm.queue_free()
	for i in range(4): await process_frame

	# Shot 12: Destination Completion & Finish Arch
	shot_num += 1
	var mode_dest := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode_dest.start_with_selection = false
	vp.add_child(mode_dest)
	var tn_route := RouteRegistry.get_route("tamil_nadu")
	mode_dest.start_route(tn_route)
	var dest_px: float = tn_route.total_distance_m * 100.0
	var dest_py: float = mode_dest.active_terrain.get_height_at(dest_px)
	mode_dest.active_vehicle.global_position = Vector2(dest_px - 20.0, dest_py - 35.0)
	mode_dest.follow_camera.global_position = Vector2(dest_px, dest_py - 40.0)
	for i in range(8): await process_frame
	# Trigger destination arrival
	var dest_wp := tn_route.waypoints[tn_route.waypoints.size() - 1]
	mode_dest._on_destination_reached(dest_wp.id, dest_wp)
	for i in range(12): await process_frame
	_save_shot(vp, "destination_completion.png", out_dir, artifact_dir, shot_num, "Destination Finish Arch & Victory Celebration Screen")
	mode_dest.queue_free()
	for i in range(4): await process_frame

	vp.queue_free()
	print("\n=================================================================")
	print("✓ ALL 12 GAMEPLAY REFINEMENT SCREENSHOTS CAPTURED SUCCESSFULLY!")
	print("=================================================================")
	quit(0)

func _save_shot(vp: SubViewport, file_name: String, out_dir: String, art_dir: String, num: int, desc: String) -> void:
	var img: Image = vp.get_texture().get_image()
	var fpath := out_dir.path_join(file_name)
	img.save_png(fpath)

	var apath := art_dir.path_join(file_name)
	img.save_png(apath)

	print("[%2d/12] ✓ Captured %s (%s)" % [num, file_name, desc])
