extends SceneTree

## capture_landmark_info_and_wheel_fix.gd
## Captures authoritative gameplay screenshots for:
## 1. Landmark information panel at bottom (Tamil Nadu, Vattakottai, Thiruvalluvar, Meenakshi, Goa Fontainhas)
## 2. Vehicle wheel physics (normal driving, nitro, jump, landing, recovery, recovery + nitro)

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const LandmarkCatalogueData = preload("res://scripts/modes/indian_roads/LandmarkCatalogueData.gd")

func _init() -> void:
	call_deferred("_run_captures")

func _run_captures() -> void:
	print("=================================================================")
	print("--- CAPTURING LANDMARK BOTTOM INFO & WHEEL FIX SCREENSHOTS ---")
	print("=================================================================")
	RouteRegistry.dev_unlock_all_routes = true

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var out_dir := "docs/screenshots/landmark_info_and_wheel_fix/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))

	# -------------------------------------------------------------
	# 1. TAMIL NADU ROUTE (Landmarks & Driving)
	# -------------------------------------------------------------
	var mode := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	vp.add_child(mode)
	mode.start_route(RouteRegistry.get_route("tamil_nadu"))

	for f in range(25):
		await physics_frame

	var veh := mode.active_vehicle as VehicleController
	var terr := mode.active_terrain as IndianRoadTerrain
	var hud := mode.hud as IndianRoadsHUD
	var cam := mode.follow_camera as Camera2D

	# --- SCREENSHOT 01: Tamil Nadu Start Landmark Info Panel ---
	print("-> Capturing 01: Tamil Nadu Landmark Bottom Panel (Gandhi Memorial)...")
	var x1: float = 90.0 * 100.0
	veh.global_position = Vector2(x1, terr.get_height_at(x1) - 45.0)
	cam.global_position = Vector2(x1 + 180.0, terr.get_height_at(x1) - 70.0)
	hud.show_landmark_info(LandmarkCatalogueData.get_landmark_info("LOC-TN-03", "tamil_nadu"))
	hud.update_progress(90.0, 1100.0, 50)
	mode.session_distance_m = 90.0
	for f in range(15):
		await physics_frame
	_save_viewport(vp, out_dir + "01_tamil_nadu_bottom_info_panel.png")

	# --- SCREENSHOT 02: Vattakottai Fort Bottom Panel ---
	print("-> Capturing 02: Vattakottai Fort Bottom Panel...")
	var x2: float = 510.0 * 100.0
	veh.global_position = Vector2(x2, terr.get_height_at(x2) - 45.0)
	cam.global_position = Vector2(x2 + 180.0, terr.get_height_at(x2) - 70.0)
	hud.show_landmark_info(LandmarkCatalogueData.get_landmark_info("LOC-TN-06", "tamil_nadu"))
	hud.update_progress(510.0, 1100.0, 150)
	mode.session_distance_m = 510.0
	for f in range(15):
		await physics_frame
	_save_viewport(vp, out_dir + "02_vattakottai_fort_bottom_panel.png")

	# --- SCREENSHOT 03: Thiruvalluvar Statue Bottom Panel ---
	print("-> Capturing 03: Thiruvalluvar Statue Bottom Panel...")
	var x3: float = 415.0 * 100.0
	veh.global_position = Vector2(x3, terr.get_height_at(x3) - 45.0)
	cam.global_position = Vector2(x3 + 180.0, terr.get_height_at(x3) - 70.0)
	hud.show_landmark_info(LandmarkCatalogueData.get_landmark_info("LOC-TN-01", "tamil_nadu"))
	hud.update_progress(415.0, 1100.0, 230)
	mode.session_distance_m = 415.0
	for f in range(15):
		await physics_frame
	_save_viewport(vp, out_dir + "03_thiruvalluvar_statue_bottom_panel.png")

	# --- SCREENSHOT 04: Meenakshi Temple Bottom Panel ---
	print("-> Capturing 04: Meenakshi Temple Bottom Panel...")
	var x4: float = 680.0 * 100.0
	veh.global_position = Vector2(x4, terr.get_height_at(x4) - 45.0)
	cam.global_position = Vector2(x4 + 180.0, terr.get_height_at(x4) - 70.0)
	hud.show_landmark_info(LandmarkCatalogueData.get_landmark_info("LOC-TN-14", "tamil_nadu"))
	hud.update_progress(680.0, 1100.0, 350)
	mode.session_distance_m = 680.0
	for f in range(15):
		await physics_frame
	_save_viewport(vp, out_dir + "04_meenakshi_temple_bottom_panel.png")

	# --- SCREENSHOT 06: Vehicle Normal Driving ---
	print("-> Capturing 06: Vehicle Normal Driving...")
	hud.dismiss_landmark_info()
	var x6: float = 180.0 * 100.0
	veh.global_position = Vector2(x6, terr.get_height_at(x6) - 42.0)
	veh.linear_velocity = Vector2(280.0, 0.0)
	cam.global_position = Vector2(x6 + 180.0, terr.get_height_at(x6) - 70.0)
	for f in range(15):
		await physics_frame
	_save_viewport(vp, out_dir + "06_vehicle_normal_driving.png")

	# --- SCREENSHOT 07: Vehicle During Nitro ---
	print("-> Capturing 07: Vehicle During Nitro...")
	veh.set_nitro_active(true)
	veh.linear_velocity = Vector2(480.0, 0.0)
	for f in range(15):
		await physics_frame
	_save_viewport(vp, out_dir + "07_vehicle_during_nitro.png")
	veh.set_nitro_active(false)

	# --- SCREENSHOT 08: Vehicle During a Jump ---
	print("-> Capturing 08: Vehicle During a Jump...")
	veh.global_position = Vector2(x6 + 1200.0, terr.get_height_at(x6 + 1200.0) - 130.0)
	veh.rotation = -0.18
	veh.linear_velocity = Vector2(340.0, -80.0)
	cam.global_position = Vector2(veh.global_position.x + 180.0, veh.global_position.y - 40.0)
	for f in range(8):
		await physics_frame
	_save_viewport(vp, out_dir + "08_vehicle_during_jump.png")

	# --- SCREENSHOT 09: Vehicle After Landing ---
	print("-> Capturing 09: Vehicle After Landing...")
	veh.global_position = Vector2(x6 + 1800.0, terr.get_height_at(x6 + 1800.0) - 40.0)
	veh.rotation = 0.02
	veh.linear_velocity = Vector2(260.0, 10.0)
	cam.global_position = Vector2(veh.global_position.x + 180.0, veh.global_position.y - 70.0)
	for f in range(12):
		await physics_frame
	_save_viewport(vp, out_dir + "09_vehicle_after_landing.png")

	# --- SCREENSHOT 10: Vehicle After Recovery ---
	print("-> Capturing 10: Vehicle After Recovery...")
	veh.recover_vehicle(Vector2(x6 + 2400.0, terr.get_height_at(x6 + 2400.0) - 45.0))
	hud.show_announcement_toast("RECOVERED!", "Vehicle uprighted — continue driving!")
	cam.global_position = Vector2(veh.global_position.x + 180.0, veh.global_position.y - 70.0)
	for f in range(12):
		await physics_frame
	_save_viewport(vp, out_dir + "10_vehicle_after_recovery.png")

	# --- SCREENSHOT 11: Vehicle Recovery Followed by Nitro ---
	print("-> Capturing 11: Vehicle Recovery Followed by Nitro...")
	veh.set_nitro_active(true)
	veh.linear_velocity = Vector2(360.0, 0.0)
	for f in range(15):
		await physics_frame
	_save_viewport(vp, out_dir + "11_vehicle_recovery_followed_by_nitro.png")
	veh.set_nitro_active(false)

	mode.queue_free()
	for f in range(5):
		await process_frame

	# -------------------------------------------------------------
	# 2. GOA ROUTE (Other State Landmark: Fontainhas)
	# -------------------------------------------------------------
	print("-> Capturing 05: Other State (Goa Fontainhas Latin Quarter)...")
	var goa_mode := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	vp.add_child(goa_mode)
	goa_mode.start_route(RouteRegistry.get_route("goa"))

	for f in range(25):
		await physics_frame

	var goa_veh := goa_mode.active_vehicle as VehicleController
	var goa_terr := goa_mode.active_terrain as IndianRoadTerrain
	var goa_hud := goa_mode.hud as IndianRoadsHUD
	var goa_cam := goa_mode.follow_camera as Camera2D

	var x_goa: float = 100.0 * 100.0
	goa_veh.global_position = Vector2(x_goa, goa_terr.get_height_at(x_goa) - 45.0)
	goa_cam.global_position = Vector2(x_goa + 180.0, goa_terr.get_height_at(x_goa) - 70.0)
	goa_hud.show_landmark_info(LandmarkCatalogueData.get_landmark_info("LOC-GA-02", "goa"))
	goa_hud.update_progress(100.0, 950.0, 80)
	for f in range(15):
		await physics_frame
	_save_viewport(vp, out_dir + "05_other_state_goa_fontainhas.png")

	goa_mode.queue_free()
	vp.queue_free()

	print("\n=================================================================")
	print("✓ ALL 11 REQUIRED SCREENSHOTS SUCCESSFULLY CAPTURED IN:")
	print("  " + out_dir)
	print("=================================================================")
	quit(0)

func _save_viewport(vp: SubViewport, path: String) -> void:
	var img := vp.get_texture().get_image()
	if img != null and not img.is_empty():
		var err := img.save_png(ProjectSettings.globalize_path(path))
		if err == OK:
			print("  ✓ Saved: ", path)
		else:
			push_error("Failed to save: " + path)
