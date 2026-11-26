extends SceneTree

const IndianRoadTerrainV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
const IndianRoadsControllerV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("=================================================================")
	print("TAMIL NADU TOLL PLAZA & ENVIRONMENT REBUILD VERIFICATION SUITE")
	print("=================================================================")

	var passed := 0
	var total := 0

	# 1. Test Route Waypoints & Subtitles
	total += 1
	var route: RouteData = RouteRegistry.get_tamil_nadu_route()
	var wp_subtitles_clean := true
	for wp in route.waypoints:
		if wp.id in ["tn_03_tirunelveli", "tn_06_madurai", "tn_08_tiruchirappalli", "tn_10_villupuram"]:
			if "toll" in wp.subtitle.to_lower():
				print("FAIL: Waypoint %s still contains 'toll' in subtitle: %s" % [wp.id, wp.subtitle])
				wp_subtitles_clean = false
	if wp_subtitles_clean:
		print("TEST 1 PASSED: 'Toll' eliminated from city checkpoint subtitles (Tirunelveli, Madurai, Trichy, Villupuram)")
		passed += 1

	# 2. Test Checkpoint vs Toll Plaza Flags
	total += 1
	var flags_valid := true
	for wp in route.waypoints:
		if wp.id in ["tn_03_tirunelveli", "tn_06_madurai", "tn_08_tiruchirappalli", "tn_10_villupuram"]:
			if wp.get_meta("is_toll_plaza", false) != false:
				print("FAIL: Waypoint %s has is_toll_plaza=true" % wp.id)
				flags_valid = false
		elif wp.id == "tn_12_chengalpattu":
			if wp.get_meta("is_toll_plaza", false) != true:
				print("FAIL: Waypoint tn_12_chengalpattu does not have is_toll_plaza=true")
				flags_valid = false
	if flags_valid:
		print("TEST 2 PASSED: Only Chengalpattu Paranur Toll has is_toll_plaza=true; landmark checkpoints are city arches")
		passed += 1

	# 3. Test In-Engine Checkpoint and Landmark Separation in IndianRoadTerrainV2
	total += 1
	var terr := IndianRoadTerrainV2Scene.instantiate() as IndianRoadTerrainV2
	root.add_child(terr)
	await process_frame
	terr.generate_route(route)
	await process_frame

	var checkpoints: Array[Node] = []
	var waypoints_container: Node = terr.get_node_or_null("WaypointsContainer")
	if is_instance_valid(waypoints_container):
		for child in waypoints_container.get_children():
			if child is IndianCheckpointV2:
				checkpoints.append(child)

	if checkpoints.size() == 5:
		print("TEST 3 PASSED: Exactly 5 checkpoints spawned along Tamil Nadu route")
		passed += 1
	else:
		print("FAIL: Expected 5 checkpoints, got %d" % checkpoints.size())

	# 4. Verify gate_sprite and barrier_pivot visibility per checkpoint
	total += 1
	var toll_isolation_ok := true
	for cp in checkpoints:
		var icp := cp as IndianCheckpointV2
		var wp_id := icp.waypoint.id if icp.waypoint else ""
		var gate_spr: Sprite2D = icp.get_node_or_null("GateSprite")
		var is_toll: bool = icp.is_toll_plaza

		if wp_id in ["tn_03_tirunelveli", "tn_06_madurai", "tn_08_tiruchirappalli", "tn_10_villupuram"]:
			if is_toll:
				print("FAIL: Checkpoint %s has is_toll=true" % wp_id)
				toll_isolation_ok = false
			if is_instance_valid(gate_spr) and gate_spr.visible:
				print("FAIL: GateSprite (Toll Booth) is visible at %s" % wp_id)
				toll_isolation_ok = false
			if is_instance_valid(icp.barrier_pivot):
				print("FAIL: BarrierPivot (Boom barrier arm) created at %s" % wp_id)
				toll_isolation_ok = false
		elif wp_id == "tn_12_chengalpattu":
			if not is_toll:
				print("FAIL: Chengalpattu toll plaza has is_toll=false")
				toll_isolation_ok = false
			if is_instance_valid(gate_spr) and not gate_spr.visible:
				print("FAIL: GateSprite is hidden at Chengalpattu toll plaza")
				toll_isolation_ok = false
			if not is_instance_valid(icp.barrier_pivot):
				print("FAIL: BarrierPivot missing at Chengalpattu toll plaza")
				toll_isolation_ok = false

	if toll_isolation_ok:
		print("TEST 4 PASSED: Industrial toll booth & boom barrier completely absent from temples; present ONLY at Paranur Toll")
		passed += 1

	# 5. Verify Checkpoint-to-Landmark Spatial Clearance (Zero Overlap)
	total += 1
	var clearance_ok := true
	for cp in checkpoints:
		var icp := cp as IndianCheckpointV2
		var cp_x: float = icp.global_position.x
		var wp_id := icp.waypoint.id if icp.waypoint else ""

		if wp_id == "tn_03_tirunelveli":
			var dist_to_monument: float = absf(cp_x - 20000.0)
			if dist_to_monument < 2500.0:
				print("FAIL: Tirunelveli CP too close to monument: %f px" % dist_to_monument)
				clearance_ok = false
		elif wp_id == "tn_06_madurai":
			var dist_to_monument: float = absf(cp_x - 50000.0)
			if dist_to_monument < 2500.0:
				print("FAIL: Madurai CP too close to monument: %f px" % dist_to_monument)
				clearance_ok = false
		elif wp_id == "tn_08_tiruchirappalli":
			var dist_to_monument: float = absf(cp_x - 70000.0)
			if dist_to_monument < 2500.0:
				print("FAIL: Trichy CP too close to monument: %f px" % dist_to_monument)
				clearance_ok = false
		elif wp_id == "tn_10_villupuram":
			var dist_to_monument: float = absf(cp_x - 90000.0)
			if dist_to_monument < 2500.0:
				print("FAIL: Villupuram CP too close to monument: %f px" % dist_to_monument)
				clearance_ok = false
		elif wp_id == "tn_12_chengalpattu":
			var dist_to_monument: float = absf(cp_x - 113500.0)
			if dist_to_monument < 4000.0:
				print("FAIL: Chengalpattu toll plaza too close to Shore Temple: %f px" % dist_to_monument)
				clearance_ok = false

	if clearance_ok:
		print("TEST 5 PASSED: Minimum 28m-55m spatial separation verified between checkpoints and monuments (Zero overlap)")
		passed += 1

	# 6. Verify Background Assets on Disk for all 6 Regional Zones
	total += 1
	var bgs := [
		"assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_01_cape_comorin.png",
		"assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_02_western_ghats.png",
		"assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_03_palmyra_plains.png",
		"assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_04_granite_hills.png",
		"assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_05_cauvery_paddy.png",
		"assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_06_coromandel_coast.png",
		"assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_01_coastal_groves.png",
		"assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_02_thamirabarani_plains.png",
		"assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_03_palmyra_countryside.png",
		"assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_04_granite_boulders.png",
		"assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_05_coromandel_suburb.png"
	]
	var all_bgs_exist := true
	for bg in bgs:
		if not FileAccess.file_exists(bg):
			print("FAIL: Background file missing: %s" % bg)
			all_bgs_exist = false

	if all_bgs_exist:
		print("TEST 6 PASSED: All 6 regional distant panoramas and 5 midground panoramas verified on disk")
		passed += 1

	# 7. Verify Controller Dynamic Environment System in IndianRoadsControllerV2
	total += 1
	var controller := IndianRoadsControllerV2Scene.instantiate() as IndianRoadsControllerV2
	var has_env_method := controller.has_method("_update_tamil_nadu_environment_zones")
	if has_env_method:
		print("TEST 7 PASSED: IndianRoadsControllerV2._update_tamil_nadu_environment_zones() pipeline verified")
		passed += 1
	else:
		print("FAIL: Controller missing _update_tamil_nadu_environment_zones")

	terr.queue_free()
	controller.free()

	print("=================================================================")
	print("AUTOMATED VERIFICATION SUMMARY: %d / %d TESTS PASSED" % [passed, total])
	print("=================================================================")
	if passed == total:
		print("ALL TOLL PLAZA & ENVIRONMENT REBUILD CHECKS PASSED SUCCESSFULLY!")
	quit(0 if passed == total else 1)
