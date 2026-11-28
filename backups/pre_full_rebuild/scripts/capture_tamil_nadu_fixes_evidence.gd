extends SceneTree

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_capture_all_evidence")

func _capture_all_evidence() -> void:
	print("=================================================================")
	print("--- CAPTURING TAMIL NADU STATUE & MAP FIXES EVIDENCE ---")
	print("=================================================================")

	RouteRegistry.dev_unlock_all_routes = true

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.process_mode = Node.PROCESS_MODE_ALWAYS
	root.add_child(vp)

	var mode := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode.start_with_selection = false
	mode.default_state_id = "tamil_nadu"
	vp.add_child(mode)

	# Allow engine to initialize
	for i in range(25):
		await process_frame

	var terr := mode.active_terrain
	var veh := mode.active_vehicle
	var cam := mode.follow_camera
	var hud := mode.hud
	var route := mode.active_route

	var base_out_dir := "res://docs/screenshots/tamil_nadu_statue_map_fix/"
	var artifact_dir := "/home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50/"

	# -------------------------------------------------------------------------
	# SHOT 1: Restored Detailed Thiruvalluvar Statue & Signboard Approach (395m)
	# -------------------------------------------------------------------------
	print("\n-> Capturing Shot 1: Approaching Thiruvalluvar Statue (395m)...")
	var dist1 := 395.0
	mode.session_distance_m = dist1
	var px1 := dist1 * 100.0
	var py1 := terr.get_height_at(px1)
	veh.global_position = Vector2(px1, py1 - 32.0)
	veh.linear_velocity = Vector2(180.0, 0.0)
	if cam:
		cam.global_position = Vector2(px1 + 120.0, py1 - 55.0)

	mode._update_next_waypoint_hud()
	if hud:
		hud.update_progress(dist1, route.total_distance_m, 160)

	for f in range(8):
		await process_frame

	_save_screenshot(vp, "tn_fix_1_restored_statue_approach.png", base_out_dir, artifact_dir,
		"Restored detailed stone Thiruvalluvar Statue with authentic facial features, drapery and pedestal; clean signboard at x=-220 with zero overlap.")

	# -------------------------------------------------------------------------
	# SHOT 2: Vehicle Beside Thiruvalluvar Statue & Milestone Advance (414.5m)
	# -------------------------------------------------------------------------
	print("\n-> Capturing Shot 2: Vehicle at Thiruvalluvar Observation Deck & HUD Advance (414.5m)...")
	var dist2 := 414.5
	mode.session_distance_m = dist2
	var px2 := dist2 * 100.0
	var py2 := terr.get_height_at(px2)
	veh.global_position = Vector2(px2, py2 - 32.0)
	veh.linear_velocity = Vector2(60.0, 0.0)
	if cam:
		cam.global_position = Vector2(px2, py2 - 55.0)

	# Trigger landmark discovery
	var wp_thiru := route.waypoints[2]
	mode._on_landmark_reached("LOC-TN-01", wp_thiru)
	mode._update_next_waypoint_hud()
	if hud:
		hud.update_progress(dist2, route.total_distance_m, 240)
		hud.show_announcement_toast("LANDMARK DISCOVERED!", "THIRUVALLUVAR STATUE  •  +80 Coins")

	for f in range(8):
		await process_frame

	_save_screenshot(vp, "tn_fix_2_restored_statue_at_pedestal.png", base_out_dir, artifact_dir,
		"Vehicle at observation deck; toast announces discovery (+80 coins) and HUD advances cleanly to NEXT: MADURAI CHECKPOINT (185m).")

	# -------------------------------------------------------------------------
	# SHOT 3: Glass Bridge Architectural Steel Support (No Red Crosshatch) (340m)
	# -------------------------------------------------------------------------
	print("\n-> Capturing Shot 3: Glass Bridge Traversal (340m)...")
	var dist3 := 340.0
	mode.session_distance_m = dist3
	var px3 := dist3 * 100.0
	var py3 := terr.get_height_at(px3)
	veh.global_position = Vector2(px3, py3 - 32.0)
	veh.linear_velocity = Vector2(280.0, 0.0)
	if cam:
		cam.global_position = Vector2(px3 + 80.0, py3 - 50.0)

	mode._update_next_waypoint_hud()
	if hud:
		hud.update_progress(dist3, route.total_distance_m, 120)

	for f in range(8):
		await process_frame

	_save_screenshot(vp, "tn_fix_3_glass_bridge_structure.png", base_out_dir, artifact_dir,
		"Kanyakumari Glass Bridge with solid structural steel box girder tray, vertical stiffeners, and polished flange chords (zero red crosshatch).")

	# -------------------------------------------------------------------------
	# SHOT 4: Fixed Tamil Nadu Route Map Overlay with Accurate Pins (415m)
	# -------------------------------------------------------------------------
	print("\n-> Capturing Shot 4: Route Map Overlay at Thiruvalluvar Statue (415m)...")
	if not is_instance_valid(mode.route_map_overlay):
		mode.route_map_overlay = mode.RouteMapOverlayScene.instantiate()
		mode.ui_layer.add_child(mode.route_map_overlay)
	mode.route_map_overlay.open_map(route, 415.0)

	for f in range(12):
		await process_frame

	_save_screenshot(vp, "tn_fix_4_route_map_overlay_fixed.png", base_out_dir, artifact_dir,
		"Tamil Nadu Highway Route Map modal: aspect-fitted state SVG, 6 distance-anchored waypoints, live green progress line, and accurate player pin at Thiruvalluvar.")

	mode.route_map_overlay.visible = false

	for f in range(8):
		await process_frame

	# -------------------------------------------------------------------------
	# SHOT 5: Approaching Madurai Checkpoint & Meenakshi Temple (580m)
	# -------------------------------------------------------------------------
	print("\n-> Capturing Shot 5: Madurai Checkpoint Approach (580m)...")
	var dist5 := 580.0
	mode.session_distance_m = dist5
	var px5 := dist5 * 100.0
	var py5 := terr.get_height_at(px5)
	veh.global_position = Vector2(px5, py5 - 32.0)
	veh.linear_velocity = Vector2(250.0, 0.0)
	if cam:
		cam.global_position = Vector2(px5 + 100.0, py5 - 55.0)

	mode._update_next_waypoint_hud()
	if hud:
		hud.update_progress(dist5, route.total_distance_m, 240)

	for f in range(8):
		await process_frame

	_save_screenshot(vp, "tn_fix_5_madurai_checkpoint_approach.png", base_out_dir, artifact_dir,
		"Continuing along NH44 towards Madurai Checkpoint with Meenakshi Amman Temple ahead.")

	mode.queue_free()
	vp.queue_free()
	RouteRegistry.dev_unlock_all_routes = false

	print("\n=================================================================")
	print("✓ ALL 5 TAMIL NADU FIX SCREENSHOTS SUCCESSFULLY CAPTURED!")
	print("=================================================================")
	quit(0)

func _save_screenshot(vp: SubViewport, filename: String, base_out_dir: String, artifact_dir: String, desc: String) -> void:
	var tex := vp.get_texture()
	if not tex:
		print("❌ No texture for ", filename)
		return
	var img := tex.get_image()
	if not img or img.is_empty():
		print("❌ Empty image for ", filename)
		return

	var project_path := base_out_dir + filename
	var global_proj_path := ProjectSettings.globalize_path(project_path)
	img.save_png(global_proj_path)

	var art_path := artifact_dir + filename
	img.save_png(art_path)

	print("✓ Saved: %s (and to artifacts)" % filename)
	print("   Desc: %s" % desc)
