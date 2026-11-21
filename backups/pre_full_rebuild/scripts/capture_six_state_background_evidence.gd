extends SceneTree

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const SaveManager = preload("res://scripts/core/SaveManager.gd")

func _init() -> void:
	call_deferred("_capture_all_background_evidence")

func _capture_all_background_evidence() -> void:
	print("=================================================================")
	print("--- CAPTURING ALL 30 SIX-STATE REALISTIC BACKGROUND SCREENSHOTS ---")
	print("=================================================================")

	RouteRegistry.dev_unlock_all_routes = true

	var out_dir := "docs/screenshots/backgrounds"
	DirAccess.make_dir_recursive_absolute(out_dir)

	var artifact_dir := "/home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50"
	DirAccess.make_dir_recursive_absolute(artifact_dir)

	var state_plans = [
		{
			"state_id": "tamil_nadu",
			"shots": [
				{"name": "tn_1_start.png", "dist_m": 0.0, "desc": "Start: Kanyakumari Coastal Morning Sky, Ocean Waves"},
				{"name": "tn_2_middle_scenery.png", "dist_m": 200.0, "desc": "Middle: Coastal Highway, Gandhi Memorial, Palmyra Trees"},
				{"name": "tn_3_main_landmark.png", "dist_m": 310.0, "desc": "Main Landmark: Kanyakumari Glass Bridge Ocean Span & Thiruvalluvar"},
				{"name": "tn_4_terrain_transition.png", "dist_m": 900.0, "desc": "Terrain Transition: Emerald Paddy Fields & Madurai Meenakshi Temple"},
				{"name": "tn_5_destination.png", "dist_m": 1800.0, "desc": "Destination: Chennai Marina Beach Finish Arch"}
			]
		},
		{
			"state_id": "goa",
			"shots": [
				{"name": "goa_1_start.png", "dist_m": 0.0, "desc": "Start: Panaji Fontainhas Latin Quarter, Warm Tropical Sky"},
				{"name": "goa_2_middle_scenery.png", "dist_m": 400.0, "desc": "Middle: Calangute Beach Promenade, Leaning Palms, Red Laterite"},
				{"name": "goa_3_main_landmark.png", "dist_m": 800.0, "desc": "Main Landmark: Fort Aguada & 1864 Lighthouse on Arabian Sea"},
				{"name": "goa_4_terrain_transition.png", "dist_m": 1200.0, "desc": "Terrain Transition: Old Goa Basilica of Bom Jesus, Layered Western Ghats"},
				{"name": "goa_5_destination.png", "dist_m": 1600.0, "desc": "Destination: Margao Destination Arch"}
			]
		},
		{
			"state_id": "kerala",
			"shots": [
				{"name": "kerala_1_start.png", "dist_m": 0.0, "desc": "Start: Fort Kochi Chinese Fishing Nets, Soft Monsoon Sky"},
				{"name": "kerala_2_middle_scenery.png", "dist_m": 500.0, "desc": "Middle: Alleppey Backwaters, Thatched Houseboats, Coconut Lagoons"},
				{"name": "kerala_3_main_landmark.png", "dist_m": 1000.0, "desc": "Main Landmark: Bekal Fort Coastal Bastion & Misty Ghats Peaks"},
				{"name": "kerala_4_terrain_transition.png", "dist_m": 1500.0, "desc": "Terrain Transition: Munnar Terraced Tea Plantation Slopes & Waterfall"},
				{"name": "kerala_5_destination.png", "dist_m": 2000.0, "desc": "Destination: Munnar Tea Estates Finish Arch"}
			]
		},
		{
			"state_id": "rajasthan",
			"shots": [
				{"name": "rajasthan_1_start.png", "dist_m": 0.0, "desc": "Start: Jaipur Pink City Hawa Mahal, Dramatic Desert Dawn Sky"},
				{"name": "rajasthan_2_middle_scenery.png", "dist_m": 550.0, "desc": "Middle: Amber Fort Gateway, Aravalli Sandstone Hills, Camel Caravans"},
				{"name": "rajasthan_3_main_landmark.png", "dist_m": 1100.0, "desc": "Main Landmark: Jodhpur Mehrangarh Fort Cliff Bastion & Thar Dunes"},
				{"name": "rajasthan_4_terrain_transition.png", "dist_m": 1650.0, "desc": "Terrain Transition: Patwon Ki Haveli Jharokhas & Sweeping Sand Dunes"},
				{"name": "rajasthan_5_destination.png", "dist_m": 2200.0, "desc": "Destination: Jaisalmer Golden Dunes Finish Arch"}
			]
		},
		{
			"state_id": "gujarat",
			"shots": [
				{"name": "gujarat_1_start.png", "dist_m": 0.0, "desc": "Start: Ahmedabad Sabarmati Ashram, Pale Azure Sky"},
				{"name": "gujarat_2_middle_scenery.png", "dist_m": 500.0, "desc": "Middle: Saurashtra Savanna Highway, Acacia Trees, Bhunga Huts"},
				{"name": "gujarat_3_main_landmark.png", "dist_m": 1000.0, "desc": "Main Landmark: Modhera Sun Temple Surya Kund & Narmada Valley Hills"},
				{"name": "gujarat_4_terrain_transition.png", "dist_m": 1500.0, "desc": "Terrain Transition: Somnath Temple & Shimmering Rann White Salt Flats"},
				{"name": "gujarat_5_destination.png", "dist_m": 2000.0, "desc": "Destination: Great Rann of Kutch Finish Arch"}
			]
		},
		{
			"state_id": "telangana",
			"shots": [
				{"name": "telangana_1_start.png", "dist_m": 0.0, "desc": "Start: Hyderabad Charminar, Deccan Indigo-Amber Twilight Sky"},
				{"name": "telangana_2_middle_scenery.png", "dist_m": 450.0, "desc": "Middle: Golconda Fort Stone Bastion, Ancient Balancing Boulders"},
				{"name": "telangana_3_main_landmark.png", "dist_m": 900.0, "desc": "Main Landmark: Hussain Sagar Monolithic Buddha & Deccan Lake"},
				{"name": "telangana_4_terrain_transition.png", "dist_m": 1350.0, "desc": "Terrain Transition: Birla Mandir White Marble & Red Gulmohar Trees"},
				{"name": "telangana_5_destination.png", "dist_m": 1800.0, "desc": "Destination: Warangal Kakatiya Kirti Torana Finish Arch"}
			]
		}
	]

	# One persistent viewport for smooth hardware rendering
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var shot_counter := 0
	for state_plan in state_plans:
		var state_id: String = state_plan["state_id"]
		var shots: Array = state_plan["shots"]

		# Check if all shots for this state already exist
		var all_exist := true
		for shot in shots:
			var s_path: String = out_dir.path_join(shot["name"])
			if not FileAccess.file_exists(s_path):
				all_exist = false
				break

		if all_exist:
			for shot in shots:
				shot_counter += 1
				print("[%2d/30] (Cached) %s" % [shot_counter, shot["name"]])
			continue

		print("\n>>> Setting up environment viewport for state: %s..." % state_id)
		var mode := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
		mode.start_with_selection = false
		vp.add_child(mode)

		var route := RouteRegistry.get_route(state_id)
		mode.start_route(route)

		for i in range(12):
			await process_frame

		for shot in shots:
			shot_counter += 1
			var shot_name: String = shot["name"]
			var dist_m: float = shot["dist_m"]
			var desc: String = shot["desc"]

			var px := dist_m * 100.0
			var terr := mode.active_terrain
			var py: float = terr._calculate_road_height(px) if terr else 382.0

			if is_instance_valid(mode.active_vehicle):
				mode.active_vehicle.global_position = Vector2(px, py - 35.0)
				mode.active_vehicle.linear_velocity = Vector2.ZERO
				mode.active_vehicle.angular_velocity = 0.0

			if is_instance_valid(mode.follow_camera):
				mode.follow_camera.global_position = Vector2(px + 120.0, py - 20.0)

			for i in range(8):
				await process_frame

			var img: Image = vp.get_texture().get_image()
			var file_path := out_dir.path_join(shot_name)
			img.save_png(file_path)

			var art_path := artifact_dir.path_join(shot_name)
			img.save_png(art_path)

			print("[%2d/30] ✓ Captured %s at %dm (%s)" % [shot_counter, shot_name, int(dist_m), desc])

		mode.queue_free()
		for i in range(4):
			await process_frame

	vp.queue_free()
	print("\n=================================================================")
	print("✓ ALL 30 SIX-STATE REALISTIC BACKGROUND SCREENSHOTS CAPTURED!")
	print("=================================================================")
	quit(0)
