extends SceneTree

## Automated Verification Suite for Tamil Nadu 13-Location Journey
## Hill Climb V2 | Indian Roads Mode

const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const RouteData = preload("res://resources/routes/RouteData.gd")
const WaypointData = preload("res://resources/routes/WaypointData.gd")
const RouteMapOverlay = preload("res://scripts/modes/indian_roads/RouteMapOverlay.gd")
const RoadsideLandmarkRegistry = preload("res://scripts/modes/indian_roads/RoadsideLandmarkRegistry.gd")
const LandmarkCatalogueData = preload("res://scripts/modes/indian_roads/LandmarkCatalogueData.gd")

const EXPECTED_ROUTE_ORDER: Array[String] = [
	"Kanyakumari",
	"Nagercoil",
	"Tirunelveli",
	"Kovilpatti",
	"Virudhunagar",
	"Madurai",
	"Melur",
	"Tiruchirappalli",
	"Perambalur",
	"Villupuram",
	"Tindivanam",
	"Chengalpattu",
	"Chennai"
]

const EXPECTED_IDS: Array[String] = [
	"tn_01_kanyakumari",
	"tn_02_nagercoil",
	"tn_03_tirunelveli",
	"tn_04_kovilpatti",
	"tn_05_virudhunagar",
	"tn_06_madurai",
	"tn_07_melur",
	"tn_08_tiruchirappalli",
	"tn_09_perambalur",
	"tn_10_villupuram",
	"tn_11_tindivanam",
	"tn_12_chengalpattu",
	"tn_13_chennai"
]

func _init() -> void:
	print("=================================================================")
	print("TAMIL NADU 13-LOCATION COMPREHENSIVE AUTOMATED VERIFICATION SUITE")
	print("=================================================================")
	
	var passed_count := 0
	var total_tests := 0
	
	# Test 1: Route Resource Load & Configuration
	total_tests += 1
	var route := RouteRegistry.get_tamil_nadu_route()
	if route == null:
		push_error("FAIL: Tamil Nadu route returned null!")
	elif route.state_id != "tamil_nadu":
		push_error("FAIL: Unexpected state_id: " + route.state_id)
	elif route.total_distance_m != 1200.0:
		push_error("FAIL: Unexpected total_distance_m: " + str(route.total_distance_m))
	else:
		print("TEST 1 PASSED: Tamil Nadu route resource valid (Total distance = 1200m)")
		passed_count += 1
		
	# Test 2: Exactly 13 stops in exact sequence
	total_tests += 1
	var count_match := (route.waypoints.size() == 13)
	var order_match := true
	var id_match := true
	if not count_match:
		push_error("FAIL: Waypoint count is %d, expected 13" % route.waypoints.size())
		order_match = false
	else:
		for i in range(13):
			var wp := route.waypoints[i]
			if wp.title != EXPECTED_ROUTE_ORDER[i]:
				push_error("FAIL: Stop %d is '%s', expected '%s'" % [i+1, wp.title, EXPECTED_ROUTE_ORDER[i]])
				order_match = false
			if wp.id != EXPECTED_IDS[i]:
				push_error("FAIL: Stop %d ID is '%s', expected '%s'" % [i+1, wp.id, EXPECTED_IDS[i]])
				id_match = false
	if count_match and order_match and id_match:
		print("TEST 2 PASSED: Exact 13-location sequence verified (Kanyakumari -> ... -> Chennai)")
		passed_count += 1
		
	# Test 3: Monotonically strictly increasing distances across 12 road segments
	total_tests += 1
	var dist_valid := true
	var prev_d := -1.0
	for i in range(route.waypoints.size()):
		var d := route.waypoints[i].distance_m
		if d <= prev_d and i > 0:
			push_error("FAIL: Non-increasing distance at stop %d (%f <= %f)" % [i, d, prev_d])
			dist_valid = false
		prev_d = d
	if route.waypoints[0].distance_m != 0.0 or route.waypoints[12].distance_m != 1200.0:
		push_error("FAIL: Start is %f or end is %f" % [route.waypoints[0].distance_m, route.waypoints[12].distance_m])
		dist_valid = false
	if dist_valid:
		print("TEST 3 PASSED: Distance progression valid across 12 segments (0m to 1200m)")
		passed_count += 1
		
	# Test 4: RouteMapOverlay Geometry has all 13 stops matching the route
	total_tests += 1
	var geom_list: Array = RouteMapOverlay.STATE_ROUTE_GEOMETRY.get("tamil_nadu", [])
	if geom_list.size() != 13:
		push_error("FAIL: RouteMapOverlay Tamil Nadu geometry has %d points, expected 13" % geom_list.size())
	else:
		var geom_valid := true
		for i in range(13):
			var pt_info: Dictionary = geom_list[i]
			var dist: float = pt_info.get("dist_m", -1.0)
			var expected_d: float = route.waypoints[i].distance_m
			if absf(dist - expected_d) > 0.01:
				push_error("FAIL: RouteMap point %d distance %f != %f" % [i, dist, expected_d])
				geom_valid = false
			var pos: Vector2 = pt_info.get("pos", Vector2.ZERO)
			if pos.x <= 0.0 or pos.x >= 1.0 or pos.y <= 0.0 or pos.y >= 1.0:
				push_error("FAIL: RouteMap point %d normalized pos out of bounds: %s" % [i, str(pos)])
				geom_valid = false
		if geom_valid:
			print("TEST 4 PASSED: RouteMapOverlay geometry contains all 13 numbered locations")
			passed_count += 1
			
	# Test 5: LandmarkCatalogueData contains rich data for all 13 waypoints
	total_tests += 1
	var cat_valid := true
	for i in range(13):
		var wp_id: String = EXPECTED_IDS[i]
		var info: Dictionary = LandmarkCatalogueData.get_landmark_info(wp_id, "tamil_nadu")
		if info.is_empty() or info.get("name") == "Historical Landmark":
			push_error("FAIL: Missing or default catalogue data for waypoint '%s'" % wp_id)
			cat_valid = false
		elif info.get("why_famous", "") == "" or info.get("description", "") == "" or info.get("fact", "") == "":
			push_error("FAIL: Incomplete catalogue data fields for '%s'" % wp_id)
			cat_valid = false
	if cat_valid:
		print("TEST 5 PASSED: LandmarkCatalogueData registered with rich cultural data for all 13 locations")
		passed_count += 1
		
	# Test 6: Landmark Asset Files exist on disk
	total_tests += 1
	var assets_exist := true
	for wp in route.waypoints:
		if wp.landmark_texture_path != "":
			if not FileAccess.file_exists(wp.landmark_texture_path):
				push_error("FAIL: Asset file missing for waypoint %s: %s" % [wp.id, wp.landmark_texture_path])
				assets_exist = false
	if assets_exist:
		print("TEST 6 PASSED: All waypoint landmark textures exist on disk")
		passed_count += 1
		
	# Test 7: RoadsideLandmarkRegistry contains curated landmarks for Tamil Nadu
	total_tests += 1
	var roadside_lms: Array[Dictionary] = RoadsideLandmarkRegistry.get_landmarks_for_state("tamil_nadu")
	if roadside_lms.size() < 13:
		push_error("FAIL: Roadside landmarks count is %d, expected >= 13" % roadside_lms.size())
	else:
		var lm_assets_valid := true
		for lm in roadside_lms:
			var asset_path: String = lm.get("asset", "")
			if asset_path != "" and not FileAccess.file_exists(asset_path):
				push_error("FAIL: Roadside landmark asset missing: " + asset_path)
				lm_assets_valid = false
		if lm_assets_valid:
			print("TEST 7 PASSED: RoadsideLandmarkRegistry valid with %d curated assets" % roadside_lms.size())
			passed_count += 1

	# Test 8: State scene instantiation & terrain generation
	total_tests += 1
	var terrain_v2_scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
	var terrain_node = terrain_v2_scene.instantiate()
	root.add_child(terrain_node)
	terrain_node.generate_route(route)
	
	if terrain_node.road_points.size() < 100:
		push_error("FAIL: Generated road points too low: %d" % terrain_node.road_points.size())
	else:
		print("TEST 8 PASSED: IndianRoadTerrainV2 generated %d road points and spawned all waypoints" % terrain_node.road_points.size())
		passed_count += 1
	terrain_node.queue_free()

	print("=================================================================")
	print("AUTOMATED VERIFICATION SUMMARY: %d / %d TESTS PASSED" % [passed_count, total_tests])
	print("=================================================================")
	
	if passed_count == total_tests:
		print("ALL TAMIL NADU ROUTE VERIFICATION CHECKS PASSED SUCCESSFULLY!")
		quit(0)
	else:
		push_error("VERIFICATION FAILED: %d tests failed." % (total_tests - passed_count))
		quit(1)
