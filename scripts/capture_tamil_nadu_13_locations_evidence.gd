extends SceneTree

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const LandmarkCatalogueData = preload("res://scripts/modes/indian_roads/LandmarkCatalogueData.gd")

func _init() -> void:
	call_deferred("_capture_all_locations")

func _capture_all_locations() -> void:
	print("=================================================================")
	print("CAPTURING IN-ENGINE RUNTIME EVIDENCE FOR ALL 13 TAMIL NADU STOPS")
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

	# Allow engine to initialize textures and shaders
	for i in range(6):
		await process_frame

	var terr := mode.active_terrain
	var veh := mode.active_vehicle
	var cam := mode.follow_camera
	var hud := mode.hud
	var route := mode.active_route

	var base_out_dir := "res://docs/screenshots/tamil_nadu_13_locations/"
	var artifact_dir := "/home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50/"

	# Ensure target directories exist
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base_out_dir))

	var shots := [
		{
			"file": "01_kanyakumari_start.png",
			"dist": 35.0,
			"wp_id": "tn_01_kanyakumari",
			"name": "TN-01: Kanyakumari Start & Thiruvalluvar Ocean Coast"
		},
		{
			"file": "02_nagercoil_palace.png",
			"dist": 100.0,
			"wp_id": "tn_02_nagercoil",
			"name": "TN-02: Nagercoil Padmanabhapuram Wooden Palace"
		},
		{
			"file": "03_tirunelveli_checkpoint.png",
			"dist": 200.0,
			"wp_id": "tn_03_tirunelveli",
			"name": "TN-03: Tirunelveli Checkpoint 1 & Nellaiappar Gopuram"
		},
		{
			"file": "04_kovilpatti_junction.png",
			"dist": 300.0,
			"wp_id": "tn_04_kovilpatti",
			"name": "TN-04: Kovilpatti Kadalai Mittai Sweet Corridor"
		},
		{
			"file": "05_virudhunagar_temple.png",
			"dist": 400.0,
			"wp_id": "tn_05_virudhunagar",
			"name": "TN-05: Virudhunagar Srivilliputhur Andal Temple"
		},
		{
			"file": "06_madurai_checkpoint.png",
			"dist": 500.0,
			"wp_id": "tn_06_madurai",
			"name": "TN-06: Madurai Checkpoint 2 & Meenakshi Amman Temple"
		},
		{
			"file": "07_melur_hills.png",
			"dist": 600.0,
			"wp_id": "tn_07_melur",
			"name": "TN-07: Melur Transition & Samanar Hills"
		},
		{
			"file": "08_tiruchirappalli_checkpoint.png",
			"dist": 700.0,
			"wp_id": "tn_08_tiruchirappalli",
			"name": "TN-08: Tiruchirappalli Checkpoint 3 & Rockfort Temple"
		},
		{
			"file": "09_perambalur_highway.png",
			"dist": 800.0,
			"wp_id": "tn_09_perambalur",
			"name": "TN-09: Perambalur Agricultural Highway"
		},
		{
			"file": "10_villupuram_checkpoint.png",
			"dist": 900.0,
			"wp_id": "tn_10_villupuram",
			"name": "TN-10: Villupuram Checkpoint 4 & Whitewashed Gopuram"
		},
		{
			"file": "11_tindivanam_junction.png",
			"dist": 1000.0,
			"wp_id": "tn_11_tindivanam",
			"name": "TN-11: Tindivanam Tamarind Highway Belt"
		},
		{
			"file": "12_chengalpattu_checkpoint.png",
			"dist": 1100.0,
			"wp_id": "tn_12_chengalpattu",
			"name": "TN-12: Chengalpattu Checkpoint 5 & Shore Temple Gateway"
		},
		{
			"file": "13_chennai_destination.png",
			"dist": 1200.0,
			"wp_id": "tn_13_chennai",
			"name": "TN-13: Chennai Grand Destination & Finish Arch"
		}
	]

	var user_args := OS.get_cmdline_user_args()
	var start_idx := 0
	var count := shots.size()
	if user_args.size() >= 2:
		start_idx = int(user_args[0])
		count = int(user_args[1])
	var active_shots := shots.slice(start_idx, start_idx + count)

	for shot in active_shots:
		var dist: float = shot["dist"]
		var px := dist * 100.0
		var py := terr.get_height_at(px)
		mode.session_distance_m = dist

		if veh:
			veh.global_position = Vector2(px, py - 32.0)
			veh.linear_velocity = Vector2(120.0, 0.0)
		if cam:
			cam.global_position = Vector2(px + 100.0, py - 50.0)

		mode._update_next_waypoint_hud()

		if hud:
			hud.update_progress(dist, route.total_distance_m, int(dist * 0.5))
			var info: Dictionary = LandmarkCatalogueData.get_landmark_info(shot["wp_id"], "tamil_nadu")
			hud.show_landmark_info(info)

		mode._update_tamil_nadu_environment_zones()
		for f in range(4):
			await process_frame

		print("-> Capturing %s (%s at %dm)..." % [shot["file"], shot["name"], int(dist)])
		_save_screenshot(vp, shot["file"], base_out_dir, artifact_dir)

	# -------------------------------------------------------------------------
	# SHOT 14: Route Map Overlay with all 13 locations
	# -------------------------------------------------------------------------
	if start_idx + count >= 13:
		print("\n-> Capturing Shot 14: Interactive Route Map Overlay (13 numbered markers)...")
		if hud and hud.has_signal("map_pressed"):
			mode._on_map_requested()
			await process_frame
			await process_frame
			_save_screenshot(vp, "14_tamil_nadu_route_map_overlay.png", base_out_dir, artifact_dir)

	print("\n=================================================================")
	print("ALL 14 RUNTIME GAMEPLAY SCREENSHOTS CAPTURED SUCCESSFULLY!")
	print("=================================================================")
	quit(0)

func _save_screenshot(vp: SubViewport, filename: String, base_out_dir: String, artifact_dir: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		var proj_path := ProjectSettings.globalize_path(base_out_dir.path_join(filename))
		img.save_png(proj_path)
		var art_path := artifact_dir.path_join(filename)
		img.save_png(art_path)
		print("   Saved to: %s & %s" % [proj_path, art_path])
