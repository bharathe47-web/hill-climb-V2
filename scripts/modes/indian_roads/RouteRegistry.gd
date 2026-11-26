class_name RouteRegistry
extends RefCounted

## RouteRegistry: Authoritative catalog of Indian Roads state routes.
## Implements sequential route progression, unlock persistence, and full route data for all 6 states.

const RouteData = preload("res://resources/routes/RouteData.gd")
const WaypointData = preload("res://resources/routes/WaypointData.gd")
const SaveManager = preload("res://scripts/core/SaveManager.gd")

const STATE_ORDER: Array[String] = [
	"tamil_nadu",
	"goa",
	"kerala",
	"rajasthan",
	"gujarat",
	"telangana"
]

const STATE_NAMES: Dictionary = {
	"tamil_nadu": "Tamil Nadu",
	"goa": "Goa",
	"kerala": "Kerala",
	"rajasthan": "Rajasthan",
	"gujarat": "Gujarat",
	"telangana": "Telangana"
}

static func get_state_order() -> Array[String]:
	return STATE_ORDER

## Debug/QA flag to test all 6 state routes without requiring sequential save unlocks
static var dev_unlock_all_routes: bool = false

static func is_state_unlocked(state_id: String) -> bool:
	if dev_unlock_all_routes:
		return true
	# In Version 1.0, all 6 canonical Indian Roads states are unlocked by default
	if state_id in STATE_ORDER:
		return true

	var data := SaveManager.load_save()
	var unlocked: Array = data.get("unlocked_routes", STATE_ORDER)
	return state_id in unlocked

static func unlock_state(state_id: String) -> bool:
	var data := SaveManager.load_save()
	var unlocked: Array = data.get("unlocked_routes", STATE_ORDER.duplicate())
	if not (state_id in unlocked):
		unlocked.append(state_id)
		data["unlocked_routes"] = unlocked
		return SaveManager.save_game(data)
	return true

static func get_required_state_for(state_id: String) -> String:
	var idx := STATE_ORDER.find(state_id)
	if idx > 0:
		var prev_id := STATE_ORDER[idx - 1]
		return STATE_NAMES.get(prev_id, prev_id)
	return ""

static func complete_route(state_id: String) -> String:
	var idx := STATE_ORDER.find(state_id)
	var next_unlocked_id := ""

	if idx >= 0 and idx + 1 < STATE_ORDER.size():
		next_unlocked_id = STATE_ORDER[idx + 1]
		unlock_state(next_unlocked_id)

	var data := SaveManager.load_save()
	var completed: Array = data.get("completed_routes", [])
	if not (state_id in completed):
		completed.append(state_id)
		data["completed_routes"] = completed
		SaveManager.save_game(data)

	return next_unlocked_id

static func get_all_routes() -> Array[RouteData]:
	var routes: Array[RouteData] = [
		get_tamil_nadu_route(),
		get_goa_route(),
		get_kerala_route(),
		get_rajasthan_route(),
		get_gujarat_route(),
		get_telangana_route()
	]

	# Synchronize active unlock status from persistence
	for r in routes:
		r.is_unlocked = is_state_unlocked(r.state_id)

	return routes

static func get_route(state_id: String) -> RouteData:
	for route in get_all_routes():
		if route.state_id == state_id:
			return route
	return get_tamil_nadu_route()

static func get_tamil_nadu_route() -> RouteData:
	var r := RouteData.new()
	r.state_id = "tamil_nadu"
	r.state_name = "Tamil Nadu"
	r.start_city = "Kanyakumari"
	r.destination_city = "Chennai"
	r.total_distance_m = 1200.0
	r.description = "Complete 13-location grand road journey from Kanyakumari to Chennai on NH44 and NH45."
	r.state_map_path = "res://assets/indian_locations/tamil_nadu_state_map.svg"
	r.state_card_icon_path = "res://assets/indian_locations/state_select_tamil_nadu.png"
	r.sky_texture_path = "res://assets/indian_roads/indian_sky_tropical.png"
	r.parallax_bg_path = "res://assets/indian_roads/indian_parallax_tamil_nadu_coast.png"
	r.is_unlocked = true
	r.completion_reward_coins = 500

	# 1. TN-01: Kanyakumari (0m - START)
	var wp0 := WaypointData.new()
	wp0.id = "tn_01_kanyakumari"
	wp0.title = "Kanyakumari"
	wp0.subtitle = "Cape Comorin & Coastal Starting Point"
	wp0.distance_m = 0.0
	wp0.waypoint_type = WaypointData.WaypointType.START
	wp0.landmark_texture_path = "res://assets/indian_locations/tamil_nadu_thiruvalluvar_statue.png"
	wp0.announcement_text = "ROUTE STARTED: KANYAKUMARI (TN-01)"
	wp0.coins_reward = 0
	r.waypoints.append(wp0)

	# 2. TN-02: Nagercoil (100m - LANDMARK)
	var wp1 := WaypointData.new()
	wp1.id = "tn_02_nagercoil"
	wp1.title = "Nagercoil"
	wp1.subtitle = "Padmanabhapuram Palace & Coconut Groves"
	wp1.distance_m = 100.0
	wp1.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp1.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/landmarks/tamil_nadu_padmanabhapuram_palace.png"
	wp1.announcement_text = "TOWN REACHED: NAGERCOIL (TN-02)"
	wp1.coins_reward = 50
	r.waypoints.append(wp1)

	# 3. TN-03: Tirunelveli (200m - CHECKPOINT 1)
	var wp2 := WaypointData.new()
	wp2.id = "tn_03_tirunelveli"
	wp2.title = "Tirunelveli"
	wp2.subtitle = "Nellaiappar Temple & Thamirabarani Plains"
	wp2.distance_m = 200.0
	wp2.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp2.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/landmarks/tamil_nadu_nellaiappar_temple.png"
	wp2.announcement_text = "CHECKPOINT 1 CLEARED: TIRUNELVELI (TN-03)"
	wp2.coins_reward = 100
	wp2.set_meta("is_toll_plaza", false)
	r.waypoints.append(wp2)

	# 4. TN-04: Kovilpatti (300m - LANDMARK)
	var wp3 := WaypointData.new()
	wp3.id = "tn_04_kovilpatti"
	wp3.title = "Kovilpatti"
	wp3.subtitle = "Peanut Candy Town & Palmyra Belt"
	wp3.distance_m = 300.0
	wp3.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp3.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/shops/shop_tamil_potti_kadai.png"
	wp3.announcement_text = "TOWN REACHED: KOVILPATTI (TN-04)"
	wp3.coins_reward = 50
	r.waypoints.append(wp3)

	# 5. TN-05: Virudhunagar (400m - LANDMARK)
	var wp4 := WaypointData.new()
	wp4.id = "tn_05_virudhunagar"
	wp4.title = "Virudhunagar"
	wp4.subtitle = "Srivilliputhur Andal Temple Gateway"
	wp4.distance_m = 400.0
	wp4.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp4.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/landmarks/tamil_nadu_srivilliputhur_andal_temple.png"
	wp4.announcement_text = "TOWN REACHED: VIRUDHUNAGAR (TN-05)"
	wp4.coins_reward = 60
	r.waypoints.append(wp4)

	# 6. TN-06: Madurai (500m - CHECKPOINT 2)
	var wp5 := WaypointData.new()
	wp5.id = "tn_06_madurai"
	wp5.title = "Madurai"
	wp5.subtitle = "Meenakshi Amman Temple & Pandyan Capital"
	wp5.distance_m = 500.0
	wp5.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp5.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/landmarks/madurai_meenakshi_amman_temple_supplied.png"
	wp5.announcement_text = "CHECKPOINT 2 CLEARED: MADURAI (TN-06)"
	wp5.coins_reward = 120
	wp5.set_meta("is_toll_plaza", false)
	r.waypoints.append(wp5)

	# 7. TN-07: Melur (600m - LANDMARK)
	var wp6 := WaypointData.new()
	wp6.id = "tn_07_melur"
	wp6.title = "Melur"
	wp6.subtitle = "Granite Hills & Samanar Malai Transition"
	wp6.distance_m = 600.0
	wp6.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp6.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/scenery/tamil_nadu_samanar_hills.png"
	wp6.announcement_text = "TOWN REACHED: MELUR (TN-07)"
	wp6.coins_reward = 50
	r.waypoints.append(wp6)

	# 8. TN-08: Tiruchirappalli (700m - CHECKPOINT 3)
	var wp7 := WaypointData.new()
	wp7.id = "tn_08_tiruchirappalli"
	wp7.title = "Tiruchirappalli"
	wp7.subtitle = "Rockfort & Srirangam Temple Town"
	wp7.distance_m = 700.0
	wp7.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp7.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/landmarks/tamil_nadu_rockfort_trichy.png"
	wp7.announcement_text = "CHECKPOINT 3 CLEARED: TIRUCHIRAPPALLI (TN-08)"
	wp7.coins_reward = 120
	wp7.set_meta("is_toll_plaza", false)
	r.waypoints.append(wp7)

	# 9. TN-09: Perambalur (800m - LANDMARK)
	var wp8 := WaypointData.new()
	wp8.id = "tn_09_perambalur"
	wp8.title = "Perambalur"
	wp8.subtitle = "Temple Gopuram & Agricultural Highway"
	wp8.distance_m = 800.0
	wp8.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp8.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/landmarks/tamil_nadu_perambalur_temple_gopuram.png"
	wp8.announcement_text = "TOWN REACHED: PERAMBALUR (TN-09)"
	wp8.coins_reward = 50
	r.waypoints.append(wp8)

	# 10. TN-10: Villupuram (900m - CHECKPOINT 4)
	var wp9 := WaypointData.new()
	wp9.id = "tn_10_villupuram"
	wp9.title = "Villupuram"
	wp9.subtitle = "Whitewashed Gopuram & GST Highway Corridor"
	wp9.distance_m = 900.0
	wp9.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp9.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/landmarks/tamil_nadu_villupuram_gopuram.png"
	wp9.announcement_text = "CHECKPOINT 4 CLEARED: VILLUPURAM (TN-10)"
	wp9.coins_reward = 100
	wp9.set_meta("is_toll_plaza", false)
	r.waypoints.append(wp9)

	# 11. TN-11: Tindivanam (1000m - LANDMARK)
	var wp10 := WaypointData.new()
	wp10.id = "tn_11_tindivanam"
	wp10.title = "Tindivanam"
	wp10.subtitle = "Tamarind Groves & NH45 Highway Junction"
	wp10.distance_m = 1000.0
	wp10.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp10.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/shops/shop_tamil_tender_coconut_stall.png"
	wp10.announcement_text = "TOWN REACHED: TINDIVANAM (TN-11)"
	wp10.coins_reward = 50
	r.waypoints.append(wp10)

	# 12. TN-12: Chengalpattu (1100m - CHECKPOINT 5)
	var wp11 := WaypointData.new()
	wp11.id = "tn_12_chengalpattu"
	wp11.title = "Chengalpattu"
	wp11.subtitle = "Paranur NH45 Toll Plaza & Gateway to Chennai"
	wp11.distance_m = 1100.0
	wp11.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp11.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/landmarks/tamil_nadu_mahabalipuram_shore_temple.png"
	wp11.announcement_text = "CHECKPOINT 5 CLEARED: CHENGALPATTU (TN-12)"
	wp11.coins_reward = 120
	wp11.set_meta("is_toll_plaza", true)
	r.waypoints.append(wp11)

	# 13. TN-13: Chennai (1200m - DESTINATION)
	var wp12 := WaypointData.new()
	wp12.id = "tn_13_chennai"
	wp12.title = "Chennai"
	wp12.subtitle = "San Thome, Fort St. George & Marina Beach"
	wp12.distance_m = 1200.0
	wp12.waypoint_type = WaypointData.WaypointType.DESTINATION
	wp12.landmark_texture_path = "res://assets/indian_locations/tamil_nadu/landmarks/tamil_nadu_san_thome_basilica.png"
	wp12.announcement_text = "DESTINATION REACHED: CHENNAI (TN-13)!"
	wp12.coins_reward = 500
	r.waypoints.append(wp12)

	return r

static func get_goa_route() -> RouteData:
	var r := RouteData.new()
	r.state_id = "goa"
	r.state_name = "Goa"
	r.start_city = "Panaji"
	r.destination_city = "Margao"
	r.total_distance_m = 950.0
	r.description = "Scenic coastal highway along Calangute Beach, Mandovi River, and Portuguese heritage churches."
	r.state_map_path = "res://assets/indian_locations/goa_state_map.svg"
	r.state_card_icon_path = "res://assets/indian_locations/state_select_goa.png"
	r.sky_texture_path = "res://assets/indian_roads/indian_sky_tropical.png"
	r.parallax_bg_path = "res://assets/indian_roads/indian_parallax_western_ghats.png"
	r.is_unlocked = is_state_unlocked("goa")
	r.completion_reward_coins = 600

	# Waypoints
	var wp0 := WaypointData.new()
	wp0.id = "goa_start"
	wp0.title = "Panaji Waterfront"
	wp0.subtitle = "Mandovi River Promenade"
	wp0.distance_m = 0.0
	wp0.waypoint_type = WaypointData.WaypointType.START
	wp0.announcement_text = "ROUTE STARTED: PANAJI"
	r.waypoints.append(wp0)

	var wp1 := WaypointData.new()
	wp1.id = "goa_calangute"
	wp1.title = "Calangute Beach Road"
	wp1.subtitle = "Golden Sands & Palm Groves"
	wp1.distance_m = 250.0
	wp1.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp1.landmark_texture_path = "res://assets/indian_locations/goa/north_goa/calangute_beach.png"
	wp1.announcement_text = "LANDMARK: CALANGUTE COAST"
	wp1.coins_reward = 60
	r.waypoints.append(wp1)

	var wp2 := WaypointData.new()
	wp2.id = "goa_mandovi_cp"
	wp2.title = "Mandovi Bridge Toll"
	wp2.subtitle = "NH66 Coastal Highway Gate"
	wp2.distance_m = 500.0
	wp2.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp2.landmark_texture_path = "res://assets/indian_roads/indian_checkpoint_toll_booth.png"
	wp2.announcement_text = "CHECKPOINT 1 CLEARED: MANDOVI TOLL"
	wp2.coins_reward = 120
	r.waypoints.append(wp2)

	var wp3 := WaypointData.new()
	wp3.id = "goa_bom_jesus"
	wp3.title = "Old Goa Heritage Site"
	wp3.subtitle = "Basilica & Colonial Architecture"
	wp3.distance_m = 750.0
	wp3.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp3.landmark_texture_path = "res://assets/indian_locations/goa/old_goa/basilica_of_bom_jesus.png"
	wp3.announcement_text = "LANDMARK: OLD GOA HERITAGE"
	wp3.coins_reward = 80
	r.waypoints.append(wp3)

	var wp4 := WaypointData.new()
	wp4.id = "goa_destination"
	wp4.title = "Margao City"
	wp4.subtitle = "Destination: South Goa Victory Arch"
	wp4.distance_m = 950.0
	wp4.waypoint_type = WaypointData.WaypointType.DESTINATION
	wp4.announcement_text = "DESTINATION REACHED: MARGAO!"
	wp4.coins_reward = 350
	r.waypoints.append(wp4)

	return r

static func get_kerala_route() -> RouteData:
	var r := RouteData.new()
	r.state_id = "kerala"
	r.state_name = "Kerala"
	r.start_city = "Kochi"
	r.destination_city = "Munnar"
	r.total_distance_m = 1050.0
	r.description = "From Kochi coastal backwaters through misty Western Ghats tea plantations to Munnar."
	r.state_map_path = "res://assets/indian_locations/kerala_state_map.svg"
	r.state_card_icon_path = "res://assets/indian_locations/state_select_kerala.png"
	r.sky_texture_path = "res://assets/indian_roads/indian_sky_tropical.png"
	r.parallax_bg_path = "res://assets/indian_roads/indian_parallax_western_ghats.png"
	r.is_unlocked = is_state_unlocked("kerala")
	r.completion_reward_coins = 700

	var wp0 := WaypointData.new()
	wp0.id = "ker_start"
	wp0.title = "Kochi Harbour"
	wp0.subtitle = "Queen of Arabian Sea Starting Point"
	wp0.distance_m = 0.0
	wp0.waypoint_type = WaypointData.WaypointType.START
	wp0.announcement_text = "ROUTE STARTED: KOCHI"
	r.waypoints.append(wp0)

	var wp1 := WaypointData.new()
	wp1.id = "ker_alleppey"
	wp1.title = "Alleppey Backwaters"
	wp1.subtitle = "Serene Canals & Houseboat Vista"
	wp1.distance_m = 280.0
	wp1.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp1.landmark_texture_path = "res://assets/indian_locations/kerala/alleppey_houseboat_backwaters.png"
	wp1.announcement_text = "LANDMARK: ALLEPPEY BACKWATERS"
	wp1.coins_reward = 70
	r.waypoints.append(wp1)

	var wp2 := WaypointData.new()
	wp2.id = "ker_ghat_cp"
	wp2.title = "Western Ghats Checkpoint"
	wp2.subtitle = "Mountain Pass Toll Plaza"
	wp2.distance_m = 550.0
	wp2.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp2.landmark_texture_path = "res://assets/indian_roads/indian_checkpoint_gate.png"
	wp2.announcement_text = "CHECKPOINT 1 CLEARED: GHATS ENTRY"
	wp2.coins_reward = 140
	r.waypoints.append(wp2)

	var wp3 := WaypointData.new()
	wp3.id = "ker_tea_estate"
	wp3.title = "Munnar Tea Gardens"
	wp3.subtitle = "High Elevation Tea Plantations"
	wp3.distance_m = 820.0
	wp3.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp3.landmark_texture_path = "res://assets/indian_locations/kerala/munnar_tea_plantations.png"
	wp3.announcement_text = "LANDMARK: TEA ESTATES"
	wp3.coins_reward = 80
	r.waypoints.append(wp3)

	var wp4 := WaypointData.new()
	wp4.id = "ker_destination"
	wp4.title = "Munnar Hill Station"
	wp4.subtitle = "Destination: Anamudi Valley Finish Arch"
	wp4.distance_m = 1050.0
	wp4.waypoint_type = WaypointData.WaypointType.DESTINATION
	wp4.announcement_text = "DESTINATION REACHED: MUNNAR!"
	wp4.coins_reward = 400
	r.waypoints.append(wp4)

	return r

static func get_rajasthan_route() -> RouteData:
	var r := RouteData.new()
	r.state_id = "rajasthan"
	r.state_name = "Rajasthan"
	r.start_city = "Jaipur"
	r.destination_city = "Jaisalmer"
	r.total_distance_m = 1200.0
	r.description = "Golden highway crossing from the Pink City of Jaipur through Jodhpur to the Thar desert fort of Jaisalmer."
	r.state_map_path = "res://assets/indian_locations/rajasthan_state_map.svg"
	r.state_card_icon_path = "res://assets/indian_locations/state_select_rajasthan.png"
	r.sky_texture_path = "res://assets/indian_roads/indian_sky_tropical.png"
	r.parallax_bg_path = "res://assets/indian_roads/indian_parallax_thar_desert.png"
	r.is_unlocked = is_state_unlocked("rajasthan")
	r.completion_reward_coins = 800

	var wp0 := WaypointData.new()
	wp0.id = "raj_start"
	wp0.title = "Jaipur Pink City"
	wp0.subtitle = "Hawa Mahal Boulevard"
	wp0.distance_m = 0.0
	wp0.waypoint_type = WaypointData.WaypointType.START
	wp0.announcement_text = "ROUTE STARTED: JAIPUR"
	r.waypoints.append(wp0)

	var wp1 := WaypointData.new()
	wp1.id = "raj_amber"
	wp1.title = "Amber Fort Gateway"
	wp1.subtitle = "Historic Hilltop Citadel"
	wp1.distance_m = 300.0
	wp1.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp1.landmark_texture_path = "res://assets/indian_locations/rajasthan/amber_fort_gateway.png"
	wp1.announcement_text = "LANDMARK: AMBER FORT"
	wp1.coins_reward = 80
	r.waypoints.append(wp1)

	var wp2 := WaypointData.new()
	wp2.id = "raj_desert_cp"
	wp2.title = "Thar Expressway Toll"
	wp2.subtitle = "Desert Highway Checkpoint"
	wp2.distance_m = 600.0
	wp2.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp2.landmark_texture_path = "res://assets/indian_roads/indian_checkpoint_gate.png"
	wp2.announcement_text = "CHECKPOINT 1 CLEARED: THAR EXPRESSWAY"
	wp2.coins_reward = 160
	r.waypoints.append(wp2)

	var wp3 := WaypointData.new()
	wp3.id = "raj_jodhpur"
	wp3.title = "Mehrangarh Fort Vista"
	wp3.subtitle = "Sun City Jodhpur Horizon"
	wp3.distance_m = 900.0
	wp3.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp3.landmark_texture_path = "res://assets/indian_locations/rajasthan/mehrangarh_fort_vista.png"
	wp3.announcement_text = "LANDMARK: MEHRANGARH"
	wp3.coins_reward = 80
	r.waypoints.append(wp3)

	var wp4 := WaypointData.new()
	wp4.id = "raj_destination"
	wp4.title = "Jaisalmer Golden Fort"
	wp4.subtitle = "Destination: Sonar Qila Finish Arch"
	wp4.distance_m = 1200.0
	wp4.waypoint_type = WaypointData.WaypointType.DESTINATION
	wp4.announcement_text = "DESTINATION REACHED: JAISALMER!"
	wp4.coins_reward = 450
	r.waypoints.append(wp4)

	return r

static func get_gujarat_route() -> RouteData:
	var r := RouteData.new()
	r.state_id = "gujarat"
	r.state_name = "Gujarat"
	r.start_city = "Ahmedabad"
	r.destination_city = "Rann of Kutch"
	r.total_distance_m = 1150.0
	r.description = "Travel from the bustling Sabarmati Riverfront past historic stepwells to the endless salt desert of Kutch."
	r.state_map_path = "res://assets/indian_locations/gujarat_state_map.svg"
	r.state_card_icon_path = "res://assets/indian_locations/state_select_gujarat.png"
	r.sky_texture_path = "res://assets/indian_roads/indian_sky_tropical.png"
	r.parallax_bg_path = "res://assets/indian_roads/indian_parallax_rann_kutch.png"
	r.is_unlocked = is_state_unlocked("gujarat")
	r.completion_reward_coins = 900

	var wp0 := WaypointData.new()
	wp0.id = "guj_start"
	wp0.title = "Ahmedabad Riverfront"
	wp0.subtitle = "Sabarmati Starting Point"
	wp0.distance_m = 0.0
	wp0.waypoint_type = WaypointData.WaypointType.START
	wp0.announcement_text = "ROUTE STARTED: AHMEDABAD"
	r.waypoints.append(wp0)

	var wp1 := WaypointData.new()
	wp1.id = "guj_somnath"
	wp1.title = "Saurashtra Highway Dhaba"
	wp1.subtitle = "Traditional Kathiyawadi Oasis"
	wp1.distance_m = 300.0
	wp1.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp1.landmark_texture_path = "res://assets/indian_locations/gujarat/saurashtra_rann_oasis.png"
	wp1.announcement_text = "LANDMARK: SAURASHTRA OASIS"
	wp1.coins_reward = 80
	r.waypoints.append(wp1)

	var wp2 := WaypointData.new()
	wp2.id = "guj_kutch_cp"
	wp2.title = "Kutch Border Gate"
	wp2.subtitle = "White Desert Toll Plaza"
	wp2.distance_m = 600.0
	wp2.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp2.landmark_texture_path = "res://assets/indian_roads/indian_checkpoint_gate.png"
	wp2.announcement_text = "CHECKPOINT 1 CLEARED: KUTCH BORDER"
	wp2.coins_reward = 180
	r.waypoints.append(wp2)

	var wp3 := WaypointData.new()
	wp3.id = "guj_salt_plain"
	wp3.title = "Flamingo Sanctuary Pass"
	wp3.subtitle = "Great Rann Natural Landmark"
	wp3.distance_m = 880.0
	wp3.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp3.landmark_texture_path = "res://assets/indian_locations/gujarat/flamingo_sanctuary_pass.png"
	wp3.announcement_text = "LANDMARK: RANN SANCTUARY"
	wp3.coins_reward = 90
	r.waypoints.append(wp3)

	var wp4 := WaypointData.new()
	wp4.id = "guj_destination"
	wp4.title = "White Desert Rann of Kutch"
	wp4.subtitle = "Destination: Great Rann Finish Arch"
	wp4.distance_m = 1150.0
	wp4.waypoint_type = WaypointData.WaypointType.DESTINATION
	wp4.announcement_text = "DESTINATION REACHED: RANN OF KUTCH!"
	wp4.coins_reward = 500
	r.waypoints.append(wp4)

	return r

static func get_telangana_route() -> RouteData:
	var r := RouteData.new()
	r.state_id = "telangana"
	r.state_name = "Telangana"
	r.start_city = "Hyderabad"
	r.destination_city = "Warangal"
	r.total_distance_m = 1000.0
	r.description = "Drive from Charminar along the modern Outer Ring Road to the historic Kakatiya Gate in Warangal."
	r.state_map_path = "res://assets/indian_locations/telangana_state_map.svg"
	r.state_card_icon_path = "res://assets/indian_locations/state_select_telangana.png"
	r.sky_texture_path = "res://assets/indian_roads/indian_sky_tropical.png"
	r.parallax_bg_path = "res://assets/indian_roads/indian_parallax_deccan_plateau.png"
	r.is_unlocked = is_state_unlocked("telangana")
	r.completion_reward_coins = 1000

	var wp0 := WaypointData.new()
	wp0.id = "tel_start"
	wp0.title = "Hyderabad Charminar"
	wp0.subtitle = "Historic Monument Starting Point"
	wp0.distance_m = 0.0
	wp0.waypoint_type = WaypointData.WaypointType.START
	wp0.announcement_text = "ROUTE STARTED: HYDERABAD"
	r.waypoints.append(wp0)

	var wp1 := WaypointData.new()
	wp1.id = "tel_golconda"
	wp1.title = "Golconda Fort Bastion"
	wp1.subtitle = "Ancient Diamond Citadel"
	wp1.distance_m = 260.0
	wp1.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp1.landmark_texture_path = "res://assets/indian_locations/telangana/golconda_fort_bastion.png"
	wp1.announcement_text = "LANDMARK: GOLCONDA FORT"
	wp1.coins_reward = 80
	r.waypoints.append(wp1)

	var wp2 := WaypointData.new()
	wp2.id = "tel_orr_cp"
	wp2.title = "Outer Ring Road Toll"
	wp2.subtitle = "Express Highway Toll Plaza"
	wp2.distance_m = 520.0
	wp2.waypoint_type = WaypointData.WaypointType.CHECKPOINT
	wp2.landmark_texture_path = "res://assets/indian_roads/indian_checkpoint_gate.png"
	wp2.announcement_text = "CHECKPOINT 1 CLEARED: ORR EXPRESSWAY"
	wp2.coins_reward = 180
	r.waypoints.append(wp2)

	var wp3 := WaypointData.new()
	wp3.id = "tel_kakatiya"
	wp3.title = "Kakatiya Dynasty Torana"
	wp3.subtitle = "Warangal Heritage Gateway"
	wp3.distance_m = 780.0
	wp3.waypoint_type = WaypointData.WaypointType.LANDMARK
	wp3.landmark_texture_path = "res://assets/indian_locations/telangana/kakatiya_dynasty_torana.png"
	wp3.announcement_text = "LANDMARK: KAKATIYA TORANA"
	wp3.coins_reward = 90
	r.waypoints.append(wp3)

	var wp4 := WaypointData.new()
	wp4.id = "tel_destination"
	wp4.title = "Thousand Pillar Temple"
	wp4.subtitle = "Destination: Warangal Finish Arch"
	wp4.distance_m = 1000.0
	wp4.waypoint_type = WaypointData.WaypointType.DESTINATION
	wp4.announcement_text = "DESTINATION REACHED: WARANGAL!"
	wp4.coins_reward = 500
	r.waypoints.append(wp4)

	return r
