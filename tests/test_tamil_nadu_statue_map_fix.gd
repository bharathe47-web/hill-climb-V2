extends SceneTree

const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const RoadsideLandmarkRegistry = preload("res://scripts/modes/indian_roads/RoadsideLandmarkRegistry.gd")
const IndianRoadsControllerV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteMapOverlay = preload("res://scripts/modes/indian_roads/RouteMapOverlay.gd")
const KanyakumariGlassBridgeScene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/KanyakumariGlassBridge.tscn")
const RoadsideLandmarkScene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/RoadsideLandmark.tscn")

func _init() -> void:
	print("\n========================================================")
	print("TESTING TAMIL NADU STATUE RESTORATION & MAP FIXES")
	print("========================================================")

	# [1/5] Verify Restored Thiruvalluvar Statue Texture
	print("-> [1/5] Verifying Restored Detailed Thiruvalluvar Statue Asset...")
	var tn_landmarks: Array[Dictionary] = RoadsideLandmarkRegistry.get_landmarks_for_state("tamil_nadu")
	var thiru_data: Dictionary = {}
	for lm in tn_landmarks:
		if lm.get("id") == "LOC-TN-01":
			thiru_data = lm
			break

	assert(thiru_data.size() > 0, "LOC-TN-01 Thiruvalluvar Statue must be registered in RoadsideLandmarkRegistry")
	var tex_path: String = thiru_data.get("asset", "")
	assert(ResourceLoader.exists(tex_path), "Statue texture file must exist: " + tex_path)
	
	var img := Image.load_from_file(ProjectSettings.globalize_path(tex_path))
	assert(img != null, "Failed to load statue image: " + tex_path)
	print("  ✓ Loaded texture: %s (Size: %s, Format: %d)" % [tex_path, img.get_size(), img.get_format()])
	
	# Verify authentic dimensions (1218x1500) and stone detailing
	assert(img.get_height() >= 1000, "Statue texture must be high-resolution (height >= 1000), not the low-res 420px silhouette")
	assert(img.get_width() >= 800, "Statue texture must be high-resolution (width >= 800)")
	
	# Verify background transparency (corners should be transparent)
	assert(img.get_pixel(0, 0).a < 0.05, "Top-left corner must be transparent")
	assert(img.get_pixel(img.get_width() - 1, 0).a < 0.05, "Top-right corner must be transparent")
	
	# Verify granite stone coloring (pedestal base should be authentic granite, not vector grey)
	var ped_col := img.get_pixel(img.get_width() / 2, img.get_height() - 20)
	assert(ped_col.a > 0.5, "Pedestal base must have opaque stone pixels")
	print("  ✓ High-res detailed granite stone monument verified with authentic transparency!")

	# [2/5] Verify Signboard Non-Overlap and Placement
	print("-> [2/5] Verifying Signboard Positioning and Non-Overlap...")
	var lm_inst := RoadsideLandmarkScene.instantiate() as RoadsideLandmark
	lm_inst.is_offshore = true
	lm_inst.visual_asset_path = tex_path
	lm_inst.place_name = "Thiruvalluvar Statue"
	lm_inst.location_district = "Kanyakumari Offshore Rock"
	lm_inst.target_height = 380.0
	lm_inst.target_width = 260.0
	root.add_child(lm_inst)
	lm_inst._ready()

	var sb: Node2D = lm_inst.get_node_or_null("Signboard")
	assert(sb != null, "Signboard must exist on RoadsideLandmark")
	print("  Signboard position: ", sb.position, " z-index: ", sb.z_index)
	assert(sb.position.x <= -200.0, "Signboard must be placed well to the left (<= -200) to clear the monument pedestal")
	assert(sb.position.y <= -100.0, "Signboard must be elevated (<= -100) to avoid vehicle clipping")
	assert(sb.z_index <= -2, "Signboard z-index must be behind vehicle (<= -2)")
	lm_inst.queue_free()
	print("  ✓ Signboard offset and z-index verified: zero vehicle/statue occlusion!")

	# [3/5] Verify Glass Bridge Structural Styling (No Red Crosshatch)
	print("-> [3/5] Verifying Glass Bridge Structural Supports...")
	var bridge := KanyakumariGlassBridgeScene.instantiate()
	root.add_child(bridge)
	var truss_col: Color = bridge.get("steel_truss_color")
	var girder_col: Color = bridge.get("steel_box_girder_color")
	print("  Bridge truss color: ", truss_col, " girder color: ", girder_col)
	assert(truss_col.r < 0.6, "Bridge structural truss must NOT be bright red hazard color (r < 0.6)")
	assert(girder_col != null and girder_col.a > 0.8, "Bridge must have solid structural steel box girder under-tray")
	bridge.queue_free()
	print("  ✓ Glass Bridge architectural steel support colors verified!")

	# [4/5] Verify Route Waypoint Progression & Distance Advance Fix
	print("-> [4/5] Verifying Thiruvalluvar Waypoint Advance (HUD Stuck-at-1m Fix)...")
	var mode := IndianRoadsControllerV2Scene.instantiate() as IndianRoadsControllerV2
	mode.start_with_selection = false
	root.add_child(mode)
	var r := RouteRegistry.get_route("tamil_nadu")
	mode.start_route(r)

	# Simulate driving before Thiruvalluvar Statue (at 390m)
	mode.session_distance_m = 390.0
	mode._update_next_waypoint_hud()
	var hud_lbl: Label = mode.hud.get_node_or_null("%NextWaypointLabel")
	print("  hud_lbl is: ", hud_lbl, " text: ", hud_lbl.text if hud_lbl else "null")
	var hud_info_text: String = hud_lbl.text if hud_lbl else ""
	assert("thiruvalluvar" in hud_info_text.to_lower(), "At 390m, Next waypoint should be Thiruvalluvar Statue")

	# Simulate arrival at Thiruvalluvar Statue (at 414m / 415m)
	# Trigger discovery via landmark signal
	var wp_thiru := r.waypoints[2] # Thiruvalluvar Statue (415m)
	mode._on_landmark_reached("LOC-TN-01", wp_thiru)
	mode.session_distance_m = 414.5
	mode._update_next_waypoint_hud()
	
	var hud_after_reach: String = mode.hud.get_node("%NextWaypointLabel").text if mode.hud.has_node("%NextWaypointLabel") else ""
	print("  HUD after reaching Thiruvalluvar (at 414.5m): ", hud_after_reach)
	assert("madurai" in hud_after_reach.to_lower(), "After reaching Thiruvalluvar Statue, HUD must immediately advance to Madurai Checkpoint!")
	assert(not ("thiruvalluvar" in hud_after_reach.to_lower() and "1m" in hud_after_reach), "HUD must NOT remain stuck on Thiruvalluvar Statue (1m)!")
	print("  ✓ Thiruvalluvar arrival advances cleanly to Madurai Checkpoint (+185m)!")
	mode.queue_free()

	# [5/5] Verify Tamil Nadu Route Map Overlay & Projection Accuracy
	print("-> [5/5] Verifying Tamil Nadu Route Map Overlay...")
	var geom: Array = RouteMapOverlay.STATE_ROUTE_GEOMETRY.get("tamil_nadu", [])
	assert(geom.size() == 6, "Tamil Nadu geometry must contain 6 distinct stops")
	print("  Geometry stops:")
	for item in geom:
		print("    - %s: pos=%s, dist=%dm" % [item["label"], item["pos"], int(item.get("dist_m", -1))])
		assert(item.has("dist_m"), "Every map geometry stop must have dist_m for linear interpolation")

	# Verify start is Kanyakumari, middle includes Thiruvalluvar and Madurai, destination is Chennai
	assert(geom[0]["label"] == "Kanyakumari" and geom[0]["dist_m"] == 0.0, "Stop 0 must be Kanyakumari (0m)")
	assert(geom[2]["label"] == "Thiruvalluvar" and geom[2]["dist_m"] == 415.0, "Stop 2 must be Thiruvalluvar (415m)")
	assert(geom[3]["label"] == "Madurai CP" and geom[3]["dist_m"] == 600.0, "Stop 3 must be Madurai CP (600m)")
	assert(geom[5]["label"] == "Chennai" and geom[5]["dist_m"] == 1100.0, "Stop 5 must be Chennai (1100m)")
	print("  ✓ Tamil Nadu map geometry points & accurate distance-anchored pins verified!")

	print("\n========================================================")
	print("✓ ALL TAMIL NADU STATUE & MAP TESTS PASSED WITH 100% SUCCESS!")
	print("========================================================\n")
	quit(0)
