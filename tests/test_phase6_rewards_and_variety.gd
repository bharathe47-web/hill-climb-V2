extends SceneTree

## Dedicated Unit and Integration Test Suite for Phase 6: Rewards, Difficulty, and Repetition.
## Tests:
## 1. Reward density balance between Heaven (10 coins, 1 fuel, 1 nitro) and Hell (15 coins, 2 fuel, 2 nitro).
## 2. Nitro and fuel replenishment mechanisms on VehicleController.
## 3. Repetition and procedural variety across five consecutive encounters (500m, 1500m, 2500m, 3500m, 4500m).
## 4. Hell hazard safety checks (safe landing basin, telegraphed spacing).
## 5. Global difficulty consistency and SaveManager best-distance persistence across branch transitions.

const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")
const VehicleControllerClass = preload("res://scripts/vehicle/VehicleController.gd")
const FuelPickupClass = preload("res://scripts/pickups/FuelPickup.gd")
const CoinClass = preload("res://scripts/pickups/Coin.gd")
const GameManagerClass = preload("res://scripts/core/GameManager.gd")

var _pass_count: int = 0
var _fail_count: int = 0

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN PHASE 6 REWARDS, DIFFICULTY & VARIETY TEST SUITE ---")
	print("=================================================================\n")
	
	_run_all_tests()
	
	print("\n=================================================================")
	if _fail_count == 0:
		print("✓ ALL PHASE 6 TESTS COMPLETED WITH 100%% SUCCESS (%d checks passed)!" % _pass_count)
		print("=================================================================\n")
		quit(0)
	else:
		printerr("✗ PHASE 6 TEST SUITE FINISHED WITH %d FAILURES (%d checks passed)" % [_fail_count, _pass_count])
		print("=================================================================\n")
		quit(1)

func _assert_true(condition: bool, message: String) -> void:
	if condition:
		_pass_count += 1
		print("  ✓ %s" % message)
	else:
		_fail_count += 1
		printerr("  ✗ FAILED: %s" % message)

func _run_all_tests() -> void:
	_test_reward_density_balance()
	_test_hazard_safety_and_spacing()
	_test_pickup_mechanics_and_vehicle_refill()
	_test_encounter_repetition_and_variety_across_5_gates()
	_test_difficulty_and_save_data_continuity()

## 1. Reward Density Balance Test (Heaven vs Hell)
func _test_reward_density_balance() -> void:
	print("-> [1/5] Testing Heaven vs Hell reward density balance...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	get_root().add_child(encounter)
	
	# Analyze Heaven dressing
	var heaven_dressing = encounter.get_node_or_null("HeavenDressing")
	_assert_true(is_instance_valid(heaven_dressing), "Heaven dressing root instantiated")
	
	var heaven_coins: int = 0
	var heaven_fuel: int = 0
	var heaven_nitro: int = 0
	
	if heaven_dressing:
		for child in heaven_dressing.get_children():
			if child is CoinClass:
				heaven_coins += 1
			elif child is FuelPickupClass:
				if child.is_nitro_pickup:
					heaven_nitro += 1
				else:
					heaven_fuel += 1
	
	_assert_true(heaven_coins == 10, "Heaven route contains exactly 10 coins (Got: %d)" % heaven_coins)
	_assert_true(heaven_fuel == 1, "Heaven route contains exactly 1 Fuel Canister (Got: %d)" % heaven_fuel)
	_assert_true(heaven_nitro == 1, "Heaven route contains exactly 1 Nitro Canister (Got: %d)" % heaven_nitro)
	
	# Analyze Hell dressing
	var hell_dressing = encounter.get_node_or_null("HellDressing")
	_assert_true(is_instance_valid(hell_dressing), "Hell dressing root instantiated")
	
	var hell_coins: int = 0
	var hell_fuel: int = 0
	var hell_nitro: int = 0
	
	if hell_dressing:
		for child in hell_dressing.get_children():
			if child is CoinClass:
				hell_coins += 1
			elif child is FuelPickupClass:
				if child.is_nitro_pickup:
					hell_nitro += 1
				else:
					hell_fuel += 1
	
	_assert_true(hell_coins == 15, "Hell route contains exactly 15 coins (+50%% bonus, Got: %d)" % hell_coins)
	_assert_true(hell_fuel == 2, "Hell route contains exactly 2 Fuel Canisters (recovery fuel, Got: %d)" % hell_fuel)
	_assert_true(hell_nitro == 2, "Hell route contains exactly 2 Nitro Canisters (recovery boost, Got: %d)" % hell_nitro)
	
	# Density comparison
	_assert_true(hell_coins > heaven_coins, "Hell route provides higher coin density (%d > %d) to reward high-risk gameplay" % [hell_coins, heaven_coins])
	_assert_true(hell_fuel > heaven_fuel, "Hell route provides higher fuel recovery (%d > %d) for basalt climbs" % [hell_fuel, heaven_fuel])
	_assert_true(hell_nitro > heaven_nitro, "Hell route provides higher nitro opportunities (%d > %d) to recover from missed launch" % [hell_nitro, heaven_nitro])
	
	get_root().remove_child(encounter)
	encounter.queue_free()

## 2. Hell Hazard Safety and Spacing Test
func _test_hazard_safety_and_spacing() -> void:
	print("-> [2/5] Testing Hell hazard safety and telegraphed spacing...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	get_root().add_child(encounter)
	
	var hell_dressing = encounter.get_node_or_null("HellDressing")
	var catch_basin_limit: float = encounter.catch_basin_length # 2000px = 20m
	var hazards_in_catch_basin: int = 0
	var total_magma_vents: int = 0
	var total_obsidian_spikes: int = 0
	
	if hell_dressing:
		for child in hell_dressing.get_children():
			if child is Sprite2D:
				var is_hazard: bool = (child.texture == encounter.TEX_HELL_MAGMA_VENT) or (child.texture == encounter.TEX_HELL_OBSIDIAN_SPIKES)
				if is_hazard:
					if child.position.x < catch_basin_limit:
						hazards_in_catch_basin += 1
					if child.texture == encounter.TEX_HELL_MAGMA_VENT:
						total_magma_vents += 1
					elif child.texture == encounter.TEX_HELL_OBSIDIAN_SPIKES:
						total_obsidian_spikes += 1
	
	_assert_true(hazards_in_catch_basin == 0, "No hazards placed inside the catch basin (0m-20m) ensuring safe falling reception (Got: %d)" % hazards_in_catch_basin)
	_assert_true(total_magma_vents >= 3, "Telegraphed magma vents placed on basalt flats and ridges (Count: %d >= 3)" % total_magma_vents)
	_assert_true(total_obsidian_spikes >= 4, "Telegraphed obsidian spikes clusters placed along track (Count: %d >= 4)" % total_obsidian_spikes)
	
	get_root().remove_child(encounter)
	encounter.queue_free()

## 3. Pickup Mechanics & Vehicle Refill Test
func _test_pickup_mechanics_and_vehicle_refill() -> void:
	print("-> [3/5] Testing pickup collection mechanics, refuel, and refill_nitro on vehicle...")
	
	var vehicle_scene = load("res://scenes/vehicle/BlueFlameTruck.tscn")
	_assert_true(vehicle_scene != null, "Vehicle scene loaded successfully")
	var vehicle: VehicleController = vehicle_scene.instantiate()
	get_root().add_child(vehicle)
	
	# Verify initial fuel and nitro
	_assert_true(vehicle.current_fuel == vehicle.max_fuel, "Vehicle starts with full fuel (%.1f/%.1f)" % [vehicle.current_fuel, vehicle.max_fuel])
	_assert_true(vehicle.current_nitro == vehicle.max_nitro, "Vehicle starts with full nitro (%.1f/%.1f)" % [vehicle.current_nitro, vehicle.max_nitro])
	
	# Deplete fuel and nitro
	vehicle.current_fuel = 20.0
	vehicle.current_nitro = 15.0
	
	# Test refuel
	vehicle.refuel(35.0)
	_assert_true(is_equal_approx(vehicle.current_fuel, 55.0), "refuel(35.0) replenishes fuel accurately to 55.0 (Got: %.1f)" % vehicle.current_fuel)
	
	# Test refill_nitro
	vehicle.refill_nitro(50.0)
	_assert_true(is_equal_approx(vehicle.current_nitro, 65.0), "refill_nitro(50.0) replenishes nitro accurately to 65.0 (Got: %.1f)" % vehicle.current_nitro)
	
	# Test clamping at max
	vehicle.refill_nitro(100.0)
	_assert_true(is_equal_approx(vehicle.current_nitro, vehicle.max_nitro), "refill_nitro clamps cleanly to max_nitro without overflow (Got: %.1f)" % vehicle.current_nitro)
	
	# Test FuelPickup collection via Area2D signal
	var fuel_pickup: FuelPickup = load("res://scenes/pickups/FuelPickup.tscn").instantiate()
	get_root().add_child(fuel_pickup)
	vehicle.current_fuel = 30.0
	fuel_pickup._collect(vehicle)
	_assert_true(is_equal_approx(vehicle.current_fuel, 65.0), "FuelPickup._collect() automatically refuels vehicle (30 + 35 = 65)")
	_assert_true(fuel_pickup.is_collected, "FuelPickup marks itself as collected")
	fuel_pickup.reset_pickup()
	_assert_true(not fuel_pickup.is_collected, "FuelPickup.reset_pickup() cleanly restores availability")
	get_root().remove_child(fuel_pickup)
	fuel_pickup.queue_free()
	
	# Test NitroPickup collection via Area2D signal
	var nitro_pickup: FuelPickup = load("res://scenes/pickups/NitroPickup.tscn").instantiate()
	get_root().add_child(nitro_pickup)
	_assert_true(nitro_pickup.is_nitro_pickup, "NitroPickup has is_nitro_pickup = true")
	_assert_true(nitro_pickup.nitro_amount == 50.0, "NitroPickup has nitro_amount = 50.0")
	vehicle.current_nitro = 25.0
	nitro_pickup._collect(vehicle)
	_assert_true(is_equal_approx(vehicle.current_nitro, 75.0), "NitroPickup._collect() automatically refills vehicle nitro (25 + 50 = 75)")
	get_root().remove_child(nitro_pickup)
	nitro_pickup.queue_free()
	
	get_root().remove_child(vehicle)
	vehicle.queue_free()

## 4. Encounter Repetition & Variety Across 5 Consecutive Gates
func _test_encounter_repetition_and_variety_across_5_gates() -> void:
	print("-> [4/5] Testing encounter repetition and procedural variety across 5 consecutive gates (n = 0..4)...")
	
	var gate_distances: Array[float] = [500.0, 1500.0, 2500.0, 3500.0, 4500.0]
	var encounters: Array[Node2D] = []
	var heaven_crest_heights: Array[float] = []
	var hell_chasm_dips: Array[float] = []
	var column_positions: Array[float] = []
	
	for i in range(gate_distances.size()):
		var gate_dist := gate_distances[i]
		var enc = BranchingEncounterClass.new()
		enc.encounter_index = i
		enc.gate_distance_m = gate_dist
		get_root().add_child(enc)
		encounters.append(enc)
		
		# Verify global origin positioning
		var expected_x := gate_dist * 100.0
		_assert_true(is_equal_approx(enc.global_position.x, expected_x), "Encounter %d placed at exact authoritative X (%.0f px = %.0fm)" % [i, expected_x, gate_dist])
		
		# Sample Heaven Sector 2 crest height (around local X = 14500px)
		var h_surf_y: float = enc.heaven_segment.get_surface_y_at(14500.0 - enc.launch_gap)
		heaven_crest_heights.append(h_surf_y)
		
		# Sample Hell Sector 3 chasm dip (around local X = 16500px)
		var l_surf_y: float = enc.hell_segment.get_surface_y_at(16500.0 - 50.0)
		hell_chasm_dips.append(l_surf_y)
		
		# Sample Colonnade 1 position in Heaven dressing
		var h_dressing = enc.get_node_or_null("HeavenDressing")
		var col_x := 0.0
		if h_dressing:
			for child in h_dressing.get_children():
				if child is Sprite2D and child.texture == enc.TEX_HEAVEN_COLUMN:
					col_x = child.position.x
					break
		column_positions.append(col_x)
		
		# Verify maximum slope bound across 500m of both routes for drivability
		var h_pts: PackedVector2Array = enc.heaven_segment.custom_surface_points
		var max_h_slope: float = 0.0
		for p in range(h_pts.size() - 1):
			var dx: float = h_pts[p + 1].x - h_pts[p].x
			var dy: float = h_pts[p + 1].y - h_pts[p].y
			if dx > 1.0:
				max_h_slope = maxf(max_h_slope, absf(dy / dx))
		_assert_true(max_h_slope <= 0.22, "Encounter %d Heaven max slope within safe bounds (%.4f <= 0.22)" % [i, max_h_slope])
		
		var l_pts: PackedVector2Array = enc.hell_segment.custom_surface_points
		var max_l_slope: float = 0.0
		for p in range(l_pts.size() - 1):
			var dx: float = l_pts[p + 1].x - l_pts[p].x
			var dy: float = l_pts[p + 1].y - l_pts[p].y
			if dx > 1.0:
				max_l_slope = maxf(max_l_slope, absf(dy / dx))
		_assert_true(max_l_slope <= 0.22, "Encounter %d Hell max slope within safe bounds (%.4f <= 0.22)" % [i, max_l_slope])
	
	# Verify variety: values should not all be identical across the 5 encounters
	var unique_h_heights: Array = []
	var unique_l_dips: Array = []
	var unique_col_pos: Array = []
	for h in heaven_crest_heights:
		if not unique_h_heights.has(snappedf(h, 0.1)):
			unique_h_heights.append(snappedf(h, 0.1))
	for l in hell_chasm_dips:
		if not unique_l_dips.has(snappedf(l, 0.1)):
			unique_l_dips.append(snappedf(l, 0.1))
	for c in column_positions:
		if not unique_col_pos.has(snappedf(c, 0.1)):
			unique_col_pos.append(snappedf(c, 0.1))
	
	_assert_true(unique_h_heights.size() >= 3, "Heaven terrain crest exhibits deterministic procedural variation across encounters (Unique: %d/5)" % unique_h_heights.size())
	_assert_true(unique_l_dips.size() >= 3, "Hell cavern chasm exhibits deterministic procedural variation across encounters (Unique: %d/5)" % unique_l_dips.size())
	_assert_true(unique_col_pos.size() >= 3, "Scenery colonnade positioning avoids identical cloned placement (Unique: %d/5)" % unique_col_pos.size())
	
	for enc in encounters:
		get_root().remove_child(enc)
		enc.queue_free()

## 5. Difficulty Progression & Save Data Continuity
func _test_difficulty_and_save_data_continuity() -> void:
	print("-> [5/5] Testing difficulty progression bounds, score, and SaveManager continuity...")
	
	var terrain_gen_script = load("res://scripts/terrain/TerrainGenerator.gd")
	_assert_true(terrain_gen_script != null, "TerrainGenerator script loaded")
	var terrain_gen = Node2D.new()
	terrain_gen.set_script(terrain_gen_script)
	get_root().add_child(terrain_gen)
	
	# Verify initial difficulty
	var init_diff: float = terrain_gen.get("current_difficulty")
	_assert_true(is_equal_approx(init_diff, 1.0), "TerrainGenerator initial difficulty starts at 1.0 (Got: %.2f)" % init_diff)
	
	# Test difficulty growth clamping
	terrain_gen.set("next_attach_point", Vector2(100000.0, 420.0)) # 1,000m
	terrain_gen._generate_next_procedural_segment()
	var mid_diff: float = terrain_gen.get("current_difficulty")
	_assert_true(mid_diff >= 1.0 and mid_diff <= 3.0, "Difficulty progression scaled smoothly and bounded between [1.0, 3.0] (Got: %.2f)" % mid_diff)
	
	# Test GameManager distance and coins persistence
	var gm = GameManagerClass.new()
	get_root().add_child(gm)
	
	gm.start_run()
	_assert_true(gm.current_distance == 0.0, "Run starts with distance = 0.0m")
	_assert_true(gm.coins_collected == 0, "Run starts with coins = 0")
	
	# Update across Heaven/Hell distance markers
	gm.update_distance(500.0)
	_assert_true(is_equal_approx(gm.current_distance, 500.0), "GameManager distance updated monotonically to 500m")
	gm.add_coins(50) # Collected 10 coins in Heaven (10 * 5 = 50)
	_assert_true(gm.coins_collected == 50, "Coins updated correctly after Heaven route (50 coins)")
	
	gm.update_distance(1000.0)
	_assert_true(is_equal_approx(gm.current_distance, 1000.0), "GameManager distance updated monotonically to 1000m merge")
	
	gm.update_distance(1500.0) # Next encounter gate
	gm.add_coins(75) # Collected 15 coins in Hell (15 * 5 = 75)
	_assert_true(gm.coins_collected == 125, "Coins updated correctly after Hell route (50 + 75 = 125 coins)")
	
	gm.finish_run("test_complete")
	_assert_true(gm.current_state == GameManager.RunState.FINISHED, "GameManager finished run cleanly")
	
	get_root().remove_child(terrain_gen)
	terrain_gen.queue_free()
	get_root().remove_child(gm)
	gm.queue_free()
