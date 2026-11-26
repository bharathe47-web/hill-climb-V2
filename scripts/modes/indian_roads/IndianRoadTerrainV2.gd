class_name IndianRoadTerrainV2
extends IndianRoadTerrain

## IndianRoadTerrainV2: Advanced procedural highway generator for Indian Roads mode.
## Renders multi-tiered asphalt cross-section, authentic regional roadside buildings, shops,
## trees, and culturally authentic props across 5-7 distinct visual environment zones per state.

const CheckpointV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/CheckpointV2.tscn")
const LandmarkV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/LandmarkV2.tscn")
const FinishArchV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/FinishArchV2.tscn")
const RoadsideLandmarkScene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/RoadsideLandmark.tscn")
const RoadsideLandmarkRegistry = preload("res://scripts/modes/indian_roads/RoadsideLandmarkRegistry.gd")
const RoadsideLandmarkScript = preload("res://scripts/modes/indian_roads/RoadsideLandmark.gd")
const KanyakumariGlassBridgeScene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/KanyakumariGlassBridge.tscn")
const KanyakumariGlassBridgeScript = preload("res://scripts/modes/indian_roads/KanyakumariGlassBridge.gd")
const CoinScene = preload("res://scenes/pickups/Coin.tscn")
const FuelPickupScene = preload("res://scenes/pickups/FuelPickup.tscn")

@export var gravel_color: Color = Color(0.45, 0.42, 0.38, 1.0) # Graded aggregate shoulder
@export var edge_line_color: Color = Color(0.95, 0.95, 0.98, 0.85) # Reflective white edge line

var landmark_x_positions: Array[float] = []

func _ready() -> void:
	road_surface_color = Color(0.18, 0.20, 0.23, 1.0)
	shoulder_color = Color(0.65, 0.45, 0.30, 1.0)
	stripe_color = Color(0.98, 0.85, 0.15, 1.0)
	bottom_depth = 650.0

func _apply_state_theme(state_id: String) -> void:
	match state_id:
		"goa":
			road_surface_color = Color(0.22, 0.23, 0.26, 1.0)
			shoulder_color = Color(0.85, 0.75, 0.50, 1.0) # Golden coastal beach sand
			gravel_color = Color(0.70, 0.65, 0.52, 1.0)
			stripe_color = Color(1.0, 1.0, 1.0, 0.95)
			terrain_wave_amp = 0.8
			terrain_freq_mult = 0.85
		"kerala":
			road_surface_color = Color(0.16, 0.18, 0.20, 1.0) # Monsoon washed asphalt
			shoulder_color = Color(0.45, 0.30, 0.16, 1.0) # Western Ghats wet humus
			gravel_color = Color(0.38, 0.35, 0.30, 1.0)
			stripe_color = Color(0.98, 0.85, 0.15, 1.0)
			terrain_wave_amp = 1.25
			terrain_freq_mult = 1.15
		"rajasthan":
			road_surface_color = Color(0.26, 0.27, 0.28, 1.0) # Sun-baked desert asphalt
			shoulder_color = Color(0.86, 0.72, 0.44, 1.0) # Thar Desert golden sand
			gravel_color = Color(0.72, 0.64, 0.45, 1.0)
			stripe_color = Color(0.95, 0.80, 0.15, 1.0)
			terrain_wave_amp = 0.65
			terrain_freq_mult = 0.65
		"gujarat":
			road_surface_color = Color(0.21, 0.22, 0.24, 1.0)
			shoulder_color = Color(0.78, 0.76, 0.72, 1.0) # Rann salt-crusted pale clay
			gravel_color = Color(0.65, 0.64, 0.60, 1.0)
			stripe_color = Color(0.98, 0.85, 0.15, 1.0)
			terrain_wave_amp = 0.6
			terrain_freq_mult = 0.75
		"telangana":
			road_surface_color = Color(0.20, 0.21, 0.23, 1.0)
			shoulder_color = Color(0.52, 0.46, 0.40, 1.0) # Deccan plateau granite grit
			gravel_color = Color(0.42, 0.40, 0.38, 1.0)
			stripe_color = Color(0.98, 0.85, 0.15, 1.0)
			terrain_wave_amp = 1.1
			terrain_freq_mult = 1.05
		_: # tamil_nadu
			road_surface_color = Color(0.18, 0.20, 0.23, 1.0)
			shoulder_color = Color(0.65, 0.44, 0.28, 1.0) # South Indian red laterite
			gravel_color = Color(0.48, 0.44, 0.38, 1.0)
			stripe_color = Color(0.98, 0.85, 0.15, 1.0)
			terrain_wave_amp = 1.0
			terrain_freq_mult = 1.0

func _plan_road_features() -> void:
	speed_breaker_x_positions.clear()
	hazard_zone_x_positions.clear()
	pothole_x_positions.clear()

	var state_id := active_route.state_id if active_route != null else ""
	var is_tamil_nadu := (state_id == "tamil_nadu")

	# Safe speed breaker placement: roughly every 320m, avoiding waypoints and landmarks by at least 35m (3500px)
	var sb_cursor := 24000.0
	while sb_cursor < total_length_px - 8000.0:
		var safe := true
		if active_route != null:
			for wp in active_route.waypoints:
				var wp_x := wp.distance_m * 100.0
				if absf(sb_cursor - wp_x) < 3500.0:
					safe = false
					break
		# In Tamil Nadu, strictly avoid the Kanyakumari Glass Bridge span (20m to 90m)
		if is_tamil_nadu and sb_cursor >= 2000.0 and sb_cursor <= 9000.0:
			safe = false
		if safe:
			speed_breaker_x_positions.append(sb_cursor)
		sb_cursor += 32000.0

	# Road work / construction zones: ONLY place in safe open highway stretches far away from all landmarks/checkpoints
	if is_tamil_nadu:
		# Tamil Nadu safe open stretches: 360m (between Kovilpatti & Virudhunagar) and 820m (between Trichy & Perambalur)
		hazard_zone_x_positions.append(36000.0)
		hazard_zone_x_positions.append(82000.0)
	else:
		if total_length_px > 60000.0:
			hazard_zone_x_positions.append(50000.0)
		if total_length_px > 130000.0:
			hazard_zone_x_positions.append(115000.0)

	# Gentle asphalt potholes in open stretches
	if total_length_px > 40000.0:
		if is_tamil_nadu:
			pothole_x_positions.append(26000.0)
			pothole_x_positions.append(68000.0)
		else:
			pothole_x_positions.append(34000.0)
	if total_length_px > 90000.0 and not is_tamil_nadu:
		pothole_x_positions.append(88000.0)

func _build_collision() -> void:
	if not is_instance_valid(collision_poly) or road_points.is_empty():
		return

	var poly := PackedVector2Array()
	# Top surface matches road_points exactly (wheels roll with pixel-perfect contact on road surface)
	poly.append_array(road_points)
	# Bottom closing polygon with generous containment margin
	var last_x := road_points[road_points.size() - 1].x
	var first_x := road_points[0].x
	poly.append(Vector2(last_x, base_y + bottom_depth + 500.0))
	poly.append(Vector2(first_x, base_y + bottom_depth + 500.0))
	collision_poly.polygon = poly

func _spawn_waypoints() -> void:
	if active_route == null or not is_instance_valid(waypoints_container):
		return

	for wp in active_route.waypoints:
		var wp_x := wp.distance_m * 100.0
		var wp_y := _calculate_road_height(wp_x)
		var spawn_pos := Vector2(wp_x, wp_y)

		match wp.waypoint_type:
			WaypointData.WaypointType.CHECKPOINT:
				var is_tn: bool = active_route != null and active_route.state_id == "tamil_nadu"
				var is_toll: bool = wp.get_meta("is_toll_plaza", false) if wp.has_meta("is_toll_plaza") else false
				if is_tn and not wp.has_meta("is_toll_plaza"):
					is_toll = ("toll" in wp.title.to_lower()) or ("toll" in wp.subtitle.to_lower())

				var cp := CheckpointV2Scene.instantiate() as IndianCheckpointV2
				cp.waypoint = wp
				cp.is_toll_plaza = is_toll

				var cp_x := wp_x
				if is_tn:
					if not is_toll:
						# Place city checkpoint arch 28m (2800px) before landmark so there is zero overlap
						cp_x = maxf(wp_x - 2800.0, 500.0)
					else:
						# Paranur Highway Toll Plaza at 1080m (before Mahabalipuram Shore Temple at 1135m)
						cp_x = 108000.0

				var cp_y := _calculate_road_height(cp_x)
				cp.global_position = Vector2(cp_x, cp_y)
				cp.checkpoint_cleared.connect(func(id, w): checkpoint_cleared.emit(id, w))
				waypoints_container.add_child(cp)

			WaypointData.WaypointType.LANDMARK, WaypointData.WaypointType.START:
				var lm := LandmarkV2Scene.instantiate() as IndianLandmarkV2
				lm.waypoint = wp
				lm.global_position = spawn_pos
				lm.landmark_reached.connect(func(id, w): landmark_reached.emit(id, w))
				waypoints_container.add_child(lm)

			WaypointData.WaypointType.DESTINATION:
				var fin := FinishArchV2Scene.instantiate() as IndianFinishArchV2
				fin.waypoint = wp
				fin.global_position = spawn_pos
				fin.destination_reached.connect(func(id, w): destination_reached.emit(id, w))
				waypoints_container.add_child(fin)

func _spawn_roadside_props() -> void:
	if not is_instance_valid(props_container):
		return

	var state_id := active_route.state_id if active_route != null else "tamil_nadu"
	landmark_x_positions.clear()

	# 1. Spawn Curated Famous Roadside Landmarks (The Central Tourism Attraction)
	var landmarks: Array[Dictionary] = RoadsideLandmarkRegistry.get_landmarks_for_state(state_id)
	for lm_data in landmarks:
		var lm_dist_m: float = lm_data.get("distance_m", 0.0)
		var lm_x: float = lm_dist_m * 100.0
		if lm_x <= 400.0 or lm_x >= total_length_px - 400.0:
			continue

		var lm_y := _calculate_road_height(lm_x)
		var lm: Node2D = RoadsideLandmarkScene.instantiate()
		if lm:
			lm.landmark_id = lm_data.get("id", "")
			lm.placement_category = lm_data.get("placement_category", "roadside_landmark")
			lm.state_id = state_id
			lm.place_name = lm_data.get("name", "")
			lm.location_district = lm_data.get("district", "")
			lm.landmark_category = lm_data.get("category", "medium_monument")
			lm.route_segment = lm_data.get("route_segment", "")
			lm.classification = lm_data.get("classification", "hero_landmark")
			lm.visual_asset_path = lm_data.get("asset", "")
			lm.target_height = lm_data.get("target_height", 240.0)
			lm.target_width = lm_data.get("target_width", 0.0)
			lm.is_offshore = lm_data.get("is_offshore", false)
			lm.show_signboard = lm_data.get("show_sign", true)
			lm.coins_reward = lm_data.get("coins_reward", 50)
			lm.ground_offset_y = lm_data.get("ground_offset_y", 0.0)
			lm.global_position = Vector2(lm_x, lm_y)
			if lm.has_signal("landmark_discovered"):
				var reward_coins: int = lm.coins_reward
				var lm_dist: float = lm_data.get("distance_m", 0.0)
				lm.landmark_discovered.connect(func(l_id: String, p_name: String):
					var wp_mock := WaypointData.new()
					wp_mock.id = l_id
					wp_mock.title = p_name
					wp_mock.distance_m = lm_dist
					wp_mock.announcement_text = "DISCOVERED: " + p_name.to_upper()
					wp_mock.coins_reward = reward_coins
					landmark_reached.emit(l_id, wp_mock)
				)
			props_container.add_child(lm)
			landmark_x_positions.append(lm_x)

	# 1.5 Spawn Kanyakumari Glass Bridge playable ocean structure (Tamil Nadu Hero Feature)
	if state_id == "tamil_nadu":
		var bridge: Node2D = KanyakumariGlassBridgeScene.instantiate()
		if bridge:
			if bridge.has_method("setup_bridge"):
				bridge.setup_bridge(self)
			props_container.add_child(bridge)

	# Helper check to ensure props/signs never clash with landmarks or bridge spans
	var is_clear := func(check_x: float, min_gap: float = 1200.0) -> bool:
		for lx in landmark_x_positions:
			if absf(check_x - lx) < min_gap:
				return false
		if state_id == "tamil_nadu" and check_x >= 2400.0 and check_x <= 8600.0:
			return false
		return true

	# 2. Advance Speed Breaker warning signs
	var tex_sign_sb := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_speed_breaker.png")
	var tex_sign_curve := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_curve_ahead.png")
	var tex_barricade := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_road_barricade_yellow_black.png")
	var tex_cone := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_traffic_cone.png")
	var tex_guardrail := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_guardrail_concrete.png")
	var tex_milestone := _load_tex("res://assets/indian_roads/visual_upgrade_v2/indian_roadside_milestone_km.png")

	if tex_sign_sb:
		for sb_x in speed_breaker_x_positions:
			var sign_x := sb_x - 6500.0
			if sign_x > 500.0 and is_clear.call(sign_x):
				_add_roadside_sprite(tex_sign_sb, 95.0, sign_x, _calculate_road_height(sign_x), -1)

	# 3. Road Work / Hazard zone markers
	for hz_x in hazard_zone_x_positions:
		if is_clear.call(hz_x):
			if tex_sign_curve and is_clear.call(hz_x - 3500.0):
				_add_roadside_sprite(tex_sign_curve, 95.0, hz_x - 3500.0, _calculate_road_height(hz_x - 3500.0), -1)
			if tex_cone:
				for cone_off: float in [-1800.0, -900.0, 900.0, 1800.0]:
					var cx: float = hz_x + cone_off
					if is_clear.call(cx, 300.0):
						_add_roadside_sprite(tex_cone, 32.0, cx, _calculate_road_height(cx), -1)
			if tex_barricade:
				_add_roadside_sprite(tex_barricade, 55.0, hz_x, _calculate_road_height(hz_x), -1)

	# 4. Load State-Specific Asset Palettes for Supporting Scenery
	var buildings: Array[Texture2D] = _load_textures_in_folder("res://assets/indian_locations/%s/buildings/" % state_id)
	var shops: Array[Texture2D] = _load_textures_in_folder("res://assets/indian_locations/%s/shops/" % state_id)
	var vegetation: Array[Texture2D] = _load_textures_in_folder("res://assets/indian_locations/%s/vegetation/" % state_id)
	var props: Array[Texture2D] = _load_textures_in_folder("res://assets/indian_locations/%s/roadside_props/" % state_id)

	if buildings.is_empty():
		buildings = _load_textures_in_folder("res://assets/indian_locations/tamil_nadu/buildings/")
	if shops.is_empty():
		shops = _load_textures_in_folder("res://assets/indian_locations/tamil_nadu/shops/")
	if vegetation.is_empty():
		vegetation = _load_textures_in_folder("res://assets/indian_locations/tamil_nadu/vegetation/")
	if props.is_empty():
		props = _load_textures_in_folder("res://assets/indian_locations/tamil_nadu/roadside_props/")

	var rng := RandomNumberGenerator.new()
	rng.seed = 20261114 + state_id.hash()

	var current_x := 800.0
	var last_bldg_idx := -1
	var last_tree_idx := -1

	# Organically populate highway with varied architecture, vegetation, and props
	# Landmark proximity clears heavy clumping so monuments stand out grandly
	while current_x < total_length_px - 800.0:
		var norm_pos: float = current_x / total_length_px
		var y := _calculate_road_height(current_x)

		# Ensure clear visual breathing room around all famous landmarks and checkpoint arches
		var is_near_landmark := false
		for lx in landmark_x_positions:
			if absf(current_x - lx) < 1100.0:
				is_near_landmark = true
				break
		if not is_near_landmark and active_route != null:
			for wp in active_route.waypoints:
				var wp_x := wp.distance_m * 100.0
				if absf(current_x - wp_x) < 1100.0 or absf(current_x - (wp_x - 2800.0)) < 900.0:
					is_near_landmark = true
					break

		if is_near_landmark:
			current_x += 1050.0
			continue

		# For Tamil Nadu: Keep ocean glass bridge span clear of terrestrial cottages, shops, and trees
		if state_id == "tamil_nadu" and current_x >= 2400.0 and current_x <= 8600.0:
			current_x += 600.0
			continue

		var roll := rng.randf()

		# Zone-specific texture selection for Tamil Nadu (13 regional environments)
		var active_buildings := buildings
		var active_vegetation := vegetation
		var active_shops := shops
		var active_props := props

		if state_id == "tamil_nadu":
			var zone_idx: int = clampi(int(current_x / 10000.0), 0, 12)
			match zone_idx:
				0: # TN-01 Kanyakumari (Coastal)
					active_buildings = _filter_by_name(buildings, ["coastal", "cottage"])
					active_vegetation = _filter_by_name(vegetation, ["coconut", "bougainvillea"])
					active_props = _filter_by_name(props, ["boat", "kolam"])
				1: # TN-02 Nagercoil (Coconut groves & Travancore)
					active_vegetation = _filter_by_name(vegetation, ["coconut", "banana"])
					active_shops = _filter_by_name(shops, ["coconut", "tea"])
				2: # TN-03 Tirunelveli (Thamirabarani plains)
					active_vegetation = _filter_by_name(vegetation, ["palmyra", "neem"])
					active_props = _filter_by_name(props, ["bullock"])
					active_shops = _filter_by_name(shops, ["tea"])
				3: # TN-04 Kovilpatti (Semi-dry candy junction)
					active_vegetation = _filter_by_name(vegetation, ["palmyra", "neem"])
					active_shops = _filter_by_name(shops, ["potti", "tea"])
				4: # TN-05 Virudhunagar (Agricultural basin)
					active_buildings = _filter_by_name(buildings, ["thatched", "cottage"])
					active_vegetation = _filter_by_name(vegetation, ["neem"])
					active_props = _filter_by_name(props, ["bullock"])
				5: # TN-06 Madurai (Temple city urban)
					active_buildings = _filter_by_name(buildings, ["agraharam", "temple_residence"])
					active_shops = _filter_by_name(shops, ["poo_kadai", "tea"])
				6: # TN-07 Melur (Granite hills & transition)
					active_vegetation = _filter_by_name(vegetation, ["banyan", "bougainvillea"])
					active_shops = _filter_by_name(shops, ["tea", "potti"])
				7: # TN-08 Tiruchirappalli (Cauvery river & mansions)
					active_buildings = _filter_by_name(buildings, ["chettinad", "temple_residence"])
					active_shops = _filter_by_name(shops, ["poo_kadai", "tea"])
				8: # TN-09 Perambalur (Agricultural highway)
					active_vegetation = _filter_by_name(vegetation, ["neem", "banyan"])
					active_buildings = _filter_by_name(buildings, ["thatched"])
				9: # TN-10 Villupuram (Highway junction)
					active_shops = _filter_by_name(shops, ["tea", "potti"])
					active_vegetation = _filter_by_name(vegetation, ["banyan", "neem"])
				10: # TN-11 Tindivanam (Tamarind belt)
					active_vegetation = _filter_by_name(vegetation, ["banyan", "neem"])
					active_shops = _filter_by_name(shops, ["tea"])
				11: # TN-12 Chengalpattu (Suburban & coastal approach)
					active_buildings = _filter_by_name(buildings, ["modern_terrace"])
					active_vegetation = _filter_by_name(vegetation, ["bougainvillea", "coconut"])
				12: # TN-13 Chennai (Metropolitan destination)
					active_buildings = _filter_by_name(buildings, ["modern_terrace", "chettinad"])
					active_props = _filter_by_name(props, ["kolam"])

		# Only spawn village buildings at start/end settlement zones to eliminate repetitive housing
		var is_settlement_zone: bool = (norm_pos < 0.18 or norm_pos > 0.85 or (state_id == "tamil_nadu" and (int(current_x / 10000.0) in [0, 5, 7, 11, 12])))

		if is_settlement_zone and roll < 0.35 and not active_buildings.is_empty():
			# Place architectural building (Z-index -3, behind road) with generous spacing
			var b_idx: int = rng.randi() % active_buildings.size()
			if b_idx == last_bldg_idx and active_buildings.size() > 1:
				b_idx = (b_idx + 1) % active_buildings.size()
			last_bldg_idx = b_idx

			var b_tex: Texture2D = active_buildings[b_idx]
			var b_height: float = rng.randf_range(145.0, 175.0)
			_add_roadside_sprite(b_tex, b_height, current_x, y, -3)

			# Small shrub accent
			if rng.randf() < 0.40 and not active_vegetation.is_empty():
				var shrub_tex: Texture2D = active_vegetation[rng.randi() % active_vegetation.size()]
				_add_roadside_sprite(shrub_tex, 85.0, current_x + 95.0, _calculate_road_height(current_x + 95.0), -2)

			current_x += rng.randf_range(800.0, 1150.0)

		elif roll < 0.72 and not active_vegetation.is_empty():
			# Place regional tree or vegetation variant with organic natural clustering
			var t_idx: int = rng.randi() % active_vegetation.size()
			if t_idx == last_tree_idx and active_vegetation.size() > 1:
				t_idx = (t_idx + 1) % active_vegetation.size()
			last_tree_idx = t_idx

			var t_tex: Texture2D = active_vegetation[t_idx]
			var base_tree_h: float = 215.0 if "tall" in t_tex.resource_path or "palm" in t_tex.resource_path else 170.0
			var tree_height: float = base_tree_h * rng.randf_range(0.85, 1.18)
			_add_roadside_sprite(t_tex, tree_height, current_x, y, -2)

			# 35% chance to spawn an organic companion tree forming a natural grove, followed by a scenic gap
			if rng.randf() < 0.35 and active_vegetation.size() > 1:
				var comp_idx := (t_idx + 1) % active_vegetation.size()
				var comp_tex: Texture2D = active_vegetation[comp_idx]
				var comp_x: float = current_x + rng.randf_range(95.0, 150.0)
				var comp_h: float = tree_height * rng.randf_range(0.78, 0.96)
				_add_roadside_sprite(comp_tex, comp_h, comp_x, _calculate_road_height(comp_x), -2)
				current_x += rng.randf_range(1100.0, 1550.0) # Reveal scenic distant horizon
			else:
				current_x += rng.randf_range(800.0, 1250.0)

		elif roll < 0.88 and not active_shops.is_empty():
			# Place roadside local shop / market kiosk (Z-index -1)
			var s_idx: int = rng.randi() % active_shops.size()
			var s_tex: Texture2D = active_shops[s_idx]
			_add_roadside_sprite(s_tex, 95.0, current_x, y, -1)
			current_x += rng.randf_range(750.0, 1100.0)

		else:
			# Place authentic cultural prop (Z-index -1, behind vehicle)
			# All milestone and mark boards removed for clean scenic roadside view
			if not active_props.is_empty():
				var p_idx: int = rng.randi() % active_props.size()
				var p_tex: Texture2D = active_props[p_idx]
				_add_roadside_sprite(p_tex, 75.0, current_x, y, -1)
			elif not active_shops.is_empty():
				var s_idx: int = rng.randi() % active_shops.size()
				var s_tex: Texture2D = active_shops[s_idx]
				_add_roadside_sprite(s_tex, 85.0, current_x, y, -1)
			current_x += rng.randf_range(650.0, 1000.0)

		# Add guardrail on steep slope variations (Z-index -1)
		if absf(_calculate_road_height(current_x + 60.0) - y) > 2.5 and tex_guardrail:
			_add_roadside_sprite(tex_guardrail, 36.0, current_x, y, -1)

	# 5. Populate structured coins and fuel canister pickups
	_populate_pickups_and_coins(total_length_px, state_id, rng)

func _populate_pickups_and_coins(total_len: float, state_id: String, rng: RandomNumberGenerator) -> void:
	var pickup_x := 1000.0
	var next_fuel_x := 6500.0

	while pickup_x < total_len - 1200.0:
		# Don't place inside ocean bridge span on Tamil Nadu
		if state_id == "tamil_nadu" and pickup_x >= 2400.0 and pickup_x <= 8600.0:
			pickup_x += 600.0
			continue

		# Check if near landmark
		var near_lm := false
		for lx in landmark_x_positions:
			if absf(pickup_x - lx) < 550.0:
				near_lm = true
				break
		if near_lm:
			pickup_x += 500.0
			continue

		# Check if time to spawn fuel
		if pickup_x >= next_fuel_x:
			var fuel_inst: Area2D = FuelPickupScene.instantiate()
			var fy := _calculate_road_height(pickup_x) - 24.0
			fuel_inst.position = Vector2(pickup_x, fy)
			if fuel_inst.has_signal("collected"):
				fuel_inst.collected.connect(func(amt): fuel_collected.emit(amt))
			props_container.add_child(fuel_inst)
			next_fuel_x = pickup_x + rng.randf_range(6500.0, 8500.0)
			pickup_x += 450.0
			continue

		# Otherwise spawn a coin pattern (straight line or gentle parabolic arch)
		var pattern_type := rng.randi() % 2
		var coin_count := rng.randi_range(3, 5)
		var spacing := 45.0

		for ci in range(coin_count):
			var cx := pickup_x + ci * spacing
			var cy := _calculate_road_height(cx) - 26.0
			if pattern_type == 1:
				# Gentle parabolic arch
				var norm: float = float(ci) / float(coin_count - 1)
				cy -= sin(norm * PI) * 22.0

			var coin_inst: Area2D = CoinScene.instantiate()
			coin_inst.position = Vector2(cx, cy)
			if coin_inst.has_signal("collected"):
				coin_inst.collected.connect(func(val): coin_collected.emit(val))
			props_container.add_child(coin_inst)

		pickup_x += rng.randf_range(1800.0, 2600.0)

func _load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

func _load_textures_in_folder(dir_path: String) -> Array[Texture2D]:
	var result: Array[Texture2D] = []
	var da := DirAccess.open(dir_path)
	if da:
		da.list_dir_begin()
		var file_name := da.get_next()
		while file_name != "":
			if not da.current_is_dir() and file_name.ends_with(".png") and not file_name.ends_with(".import"):
				var full_p := dir_path.path_join(file_name)
				if ResourceLoader.exists(full_p):
					var tex := load(full_p) as Texture2D
					if tex:
						result.append(tex)
			file_name = da.get_next()
		da.list_dir_end()
	return result

func _filter_by_name(list: Array[Texture2D], keywords: Array[String]) -> Array[Texture2D]:
	var filtered: Array[Texture2D] = []
	for tex in list:
		for kw in keywords:
			if kw in tex.resource_path.to_lower():
				filtered.append(tex)
				break
	return filtered if not filtered.is_empty() else list

func _add_roadside_sprite(tex: Texture2D, target_height: float, pos_x: float, road_y: float, z_idx: int) -> Sprite2D:
	if not tex:
		return null
	var spr := Sprite2D.new()
	spr.texture = tex
	var th := float(tex.get_height())
	if th > 0.0:
		var s := target_height / th
		spr.scale = Vector2(s, s)
	spr.centered = true
	spr.position = Vector2(pos_x, road_y - (target_height * 0.5))
	spr.z_index = z_idx
	props_container.add_child(spr)
	return spr

func _draw_stratified_embankment(pts: PackedVector2Array, start_x: float, end_x: float) -> void:
	if pts.size() < 2:
		return

	# Subsurface Layer 3: Deep bedrock foundation (down to bottom_depth)
	var poly_deep := PackedVector2Array()
	poly_deep.append_array(pts)
	poly_deep.append(Vector2(end_x, base_y + bottom_depth))
	poly_deep.append(Vector2(start_x, base_y + bottom_depth))
	draw_colored_polygon(poly_deep, shoulder_color.darkened(0.42))

	# Subsurface Layer 2: Weathered subsoil & compacted aggregate strata (down to +130px)
	var poly_mid := PackedVector2Array()
	poly_mid.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		poly_mid.append(Vector2(pts[i].x, minf(pts[i].y + 130.0, base_y + bottom_depth)))
	draw_colored_polygon(poly_mid, shoulder_color.darkened(0.20))

	# Subsurface Layer 1: Regional topsoil & roadside verge (down to +42px)
	var poly_top := PackedVector2Array()
	poly_top.append_array(pts)
	for i in range(pts.size() - 1, -1, -1):
		poly_top.append(Vector2(pts[i].x, minf(pts[i].y + 42.0, base_y + bottom_depth)))
	draw_colored_polygon(poly_top, shoulder_color)

	# Subtle geological strata dividing line
	var strata_line := PackedVector2Array()
	for i in range(0, pts.size(), 2):
		strata_line.append(Vector2(pts[i].x, pts[i].y + 42.0))
	if strata_line.size() >= 2:
		draw_polyline(strata_line, shoulder_color.darkened(0.12), 2.0, true)

func _offset_polyline(pts: PackedVector2Array, offset_y: float) -> PackedVector2Array:
	var res := PackedVector2Array()
	res.resize(pts.size())
	for i in range(pts.size()):
		res[i] = Vector2(pts[i].x, pts[i].y + offset_y)
	return res

func _draw() -> void:
	if road_points.size() < 2:
		return

	var is_tamil_nadu := (active_route != null and active_route.state_id == "tamil_nadu")
	var bridge_min_x := 2500.0
	var bridge_max_x := 8500.0

	# 1. Foundation polygon (multi-tiered subsurface earth foundation)
	if is_tamil_nadu:
		# Split earth foundation so ocean water is visible beneath the glass bridge span!
		var poly_west := PackedVector2Array()
		var poly_east := PackedVector2Array()
		var first_x := road_points[0].x
		var last_x := road_points[road_points.size() - 1].x

		for pt in road_points:
			if pt.x <= bridge_min_x + 50.0:
				poly_west.append(pt)
			elif pt.x >= bridge_max_x - 50.0:
				poly_east.append(pt)

		if poly_west.size() >= 2:
			var w_last_x := poly_west[poly_west.size() - 1].x
			_draw_stratified_embankment(poly_west, first_x, w_last_x)

		if poly_east.size() >= 2:
			var e_first_x := poly_east[0].x
			_draw_stratified_embankment(poly_east, e_first_x, last_x)
	else:
		var last_x := road_points[road_points.size() - 1].x
		var first_x := road_points[0].x
		_draw_stratified_embankment(road_points, first_x, last_x)

	# 2. Graded aggregate shoulder strip & 3. Main dark asphalt
	# Draw asphalt and gravel extending downwards from road_points, so the top contact surface aligns
	# 100% pixel-perfect with road_points (zero wheel sinking, zero vehicle floating).
	if is_tamil_nadu:
		var seg_west := PackedVector2Array()
		var seg_east := PackedVector2Array()
		for pt in road_points:
			if pt.x <= bridge_min_x:
				seg_west.append(pt)
			elif pt.x >= bridge_max_x:
				seg_east.append(pt)

		if seg_west.size() >= 2:
			var gravel_pts := _offset_polyline(seg_west, 14.0)
			var asphalt_pts := _offset_polyline(seg_west, 10.0)
			draw_polyline(gravel_pts, gravel_color, 28.0, true)
			draw_polyline(asphalt_pts, road_surface_color, 20.0, true)
			draw_polyline(seg_west, road_surface_color.lightened(0.12), 2.0, true)
		if seg_east.size() >= 2:
			var gravel_pts := _offset_polyline(seg_east, 14.0)
			var asphalt_pts := _offset_polyline(seg_east, 10.0)
			draw_polyline(gravel_pts, gravel_color, 28.0, true)
			draw_polyline(asphalt_pts, road_surface_color, 20.0, true)
			draw_polyline(seg_east, road_surface_color.lightened(0.12), 2.0, true)
	else:
		var gravel_pts := _offset_polyline(road_points, 14.0)
		var asphalt_pts := _offset_polyline(road_points, 10.0)
		draw_polyline(gravel_pts, gravel_color, 28.0, true)
		draw_polyline(asphalt_pts, road_surface_color, 20.0, true)
		draw_polyline(road_points, road_surface_color.lightened(0.12), 2.0, true)

	# 5. Continuous reflective white road shoulder edge lines
	for i in range(road_points.size() - 1):
		var p1 := road_points[i]
		var p2 := road_points[i + 1]
		if is_tamil_nadu and p1.x >= bridge_min_x and p2.x <= bridge_max_x:
			continue # Handled by glass bridge deck balustrades
		var dir := (p2 - p1).normalized()
		var norm := Vector2(-dir.y, dir.x)
		# Top white shoulder line: flush at top contact surface
		draw_line(p1 + norm * 1.5, p2 + norm * 1.5, edge_line_color, 2.5, true)
		# Bottom shoulder boundary line
		draw_line(p1 + norm * 19.0, p2 + norm * 19.0, edge_line_color, 2.0, true)

	# 6. Asphalt potholes (recessed depression with cracked edge)
	for pt_x in pothole_x_positions:
		var py := _calculate_road_height(pt_x)
		draw_circle(Vector2(pt_x, py + 8.0), 14.0, road_surface_color.darkened(0.55))
		draw_arc(Vector2(pt_x, py + 8.0), 14.0, 0.0, TAU, 12, road_surface_color.lightened(0.25), 1.5)

	# 7. Speed breaker yellow stripes
	for sb_x in speed_breaker_x_positions:
		for offset: float in [-18.0, -9.0, 0.0, 9.0, 18.0]:
			var px: float = sb_x + offset
			var py := _calculate_road_height(px)
			draw_line(Vector2(px, py), Vector2(px, py + 20.0), Color(1.0, 0.88, 0.2, 0.95), 3.0)

	# 8. Yellow dashed highway center line
	var stripe_len := 40.0
	var gap_len := 30.0
	var cycle := stripe_len + gap_len

	for i in range(road_points.size() - 1):
		var p1 := road_points[i]
		var p2 := road_points[i + 1]
		if is_tamil_nadu and p1.x >= bridge_min_x and p2.x <= bridge_max_x:
			continue # Glass bridge has its own expansion transoms instead of yellow highway stripes
		var dir := (p2 - p1).normalized()
		var normal := Vector2(-dir.y, dir.x)
		var c1 := p1 + normal * 10.0
		var c2 := p2 + normal * 10.0

		var dist_along := fmod(p1.x, cycle)
		if dist_along < stripe_len:
			draw_line(c1, c2, stripe_color, 3.0, true)
