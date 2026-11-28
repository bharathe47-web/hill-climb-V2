extends SceneTree

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const LandmarkCatalogueData = preload("res://scripts/modes/indian_roads/LandmarkCatalogueData.gd")

func _init() -> void:
	call_deferred("_capture_evidence")

func _capture_evidence() -> void:
	print("=================================================================")
	print("CAPTURING TAMIL NADU TOLL PLAZA & ENVIRONMENT FIX EVIDENCE")
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

	for i in range(8):
		await process_frame

	var terr := mode.active_terrain
	var veh := mode.active_vehicle
	var cam := mode.follow_camera
	var hud := mode.hud
	var route := mode.active_route

	var base_out_dir := "res://docs/screenshots/tamil_nadu_toll_and_env_fix/"
	var artifact_dir := "/home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base_out_dir))

	var scenes_to_capture := [
		{
			"file": "01_tirunelveli_clean_monument_no_toll.png",
			"dist": 200.0,
			"wp_id": "tn_03_tirunelveli",
			"desc": "Tirunelveli Nellaiappar Gopuram - NO Toll Booth, NO Barrier"
		},
		{
			"file": "02_madurai_clean_meenakshi_no_toll.png",
			"dist": 500.0,
			"wp_id": "tn_06_madurai",
			"desc": "Madurai Meenakshi Temple - NO Toll Booth, NO Barrier"
		},
		{
			"file": "03_trichy_clean_rockfort_no_toll.png",
			"dist": 700.0,
			"wp_id": "tn_08_tiruchirappalli",
			"desc": "Rockfort Trichy - NO Toll Booth, NO Barrier"
		},
		{
			"file": "04_villupuram_clean_gopuram_no_toll.png",
			"dist": 900.0,
			"wp_id": "tn_10_villupuram",
			"desc": "Villupuram Gopuram - NO Toll Booth, NO Barrier"
		},
		{
			"file": "05_paranur_highway_toll_plaza.png",
			"dist": 1080.0,
			"wp_id": "tn_12_chengalpattu",
			"desc": "Paranur NH45 GST Highway Toll Plaza (Authentic single toll location)"
		},
		{
			"file": "06_mahabalipuram_shore_temple_clear.png",
			"dist": 1135.0,
			"wp_id": "tn_12_chengalpattu",
			"desc": "Mahabalipuram Shore Temple - Clean Coastal View (Zero overlap with toll)"
		},
		{
			"file": "07_cape_comorin_ocean_horizon.png",
			"dist": 40.0,
			"wp_id": "tn_01_kanyakumari",
			"desc": "Zone 1: Cape Comorin Azure Ocean Seascape & Golden Sand Verge"
		},
		{
			"file": "08_western_ghats_agasthiyar_peaks.png",
			"dist": 220.0,
			"wp_id": "tn_03_tirunelveli",
			"desc": "Zone 2: Western Ghats Mountain Horizon & River Basin"
		},
		{
			"file": "09_palmyra_belt_red_soil.png",
			"dist": 350.0,
			"wp_id": "tn_04_kovilpatti",
			"desc": "Zone 3: Palmyra Palm Silhouettes & South Indian Red Laterite Soil"
		},
		{
			"file": "10_melur_granite_tors.png",
			"dist": 620.0,
			"wp_id": "tn_07_melur",
			"desc": "Zone 4: Melur Granite Boulders & Samanar Malai Ridge"
		},
		{
			"file": "11_cauvery_paddy_terraces.png",
			"dist": 780.0,
			"wp_id": "tn_08_tiruchirappalli",
			"desc": "Zone 5: Cauvery Emerald Paddy Horizon & Dark Fertile Loam"
		},
		{
			"file": "12_coromandel_coast_marina_finish.png",
			"dist": 1180.0,
			"wp_id": "tn_13_chennai",
			"desc": "Zone 6: Coromandel Coastline, Marina Lighthouse & Urban Approach"
		}
	]

	for s in scenes_to_capture:
		var dist: float = s["dist"]
		var px := dist * 100.0
		var py := terr.get_height_at(px)
		mode.session_distance_m = dist

		if veh:
			veh.global_position = Vector2(px, py - 32.0)
			veh.linear_velocity = Vector2.ZERO
		if cam:
			cam.global_position = Vector2(px + 80.0, py - 40.0)

		mode._update_next_waypoint_hud()
		mode._update_tamil_nadu_environment_zones()

		if hud:
			hud.update_progress(dist, route.total_distance_m, int(dist * 0.5))
			var info: Dictionary = LandmarkCatalogueData.get_landmark_info(s["wp_id"], "tamil_nadu")
			hud.show_landmark_info(info)

		for f in range(5):
			await process_frame

		print("-> Capturing %s (%s)..." % [s["file"], s["desc"]])
		var img: Image = vp.get_texture().get_image()
		if img:
			var proj_path := ProjectSettings.globalize_path(base_out_dir.path_join(s["file"]))
			img.save_png(proj_path)
			var art_path := artifact_dir.path_join(s["file"])
			img.save_png(art_path)
			print("   Saved: %s & %s" % [proj_path, art_path])

	print("\n=================================================================")
	print("ALL EVIDENCE SCREENSHOTS CAPTURED SUCCESSFULLY!")
	print("=================================================================")
	quit(0)
