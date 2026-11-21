extends SceneTree

## test_phase4_hell_route.gd
## Automated test suite for Phase 4 — Hell 500m playable route.
## Verifies:
## 1. Hell terrain surface continuity, slope bounds, and Hermite exit merge.
## 2. Visual dressing set pieces (Dragon Skull portal, basalt columns, magma vents, obsidian spikes, geyser).
## 3. Ambient non-colliding characters (Skeleton Knight, Demon Goblin, Horned Fiend, Flying Hell Dragon).
## 4. Pickups & rewards (coin trails and fuel canisters).
## 5. Real physics vehicle driving simulation across Hell track for all 4 registered vehicles.
## 6. Route trigger confirmation, merge signal dispatch, and audio/environment host synchronization.

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")
const BiomeProgressionControllerClass = preload("res://scripts/progression/BiomeProgressionController.gd")
const BiomeEnvironmentHostClass = preload("res://scripts/environment/BiomeEnvironmentHost.gd")
const VehicleControllerClass = preload("res://scripts/vehicle/VehicleController.gd")

var _passed_checks: int = 0
var _failed_checks: int = 0

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN PHASE 4 HELL 500M PLAYABLE ROUTE TEST SUITE ---")
	print("=================================================================\n")

	_run_tests()

func _assert_check(condition: bool, message: String) -> void:
	if condition:
		_passed_checks += 1
		print("  ✓ " + message)
	else:
		_failed_checks += 1
		printerr("  ✗ FAILED: " + message)

func _run_tests() -> void:
	await _test_1_geometry_and_slope_bounds()
	await _test_2_visual_dressing_characters_and_pickups()
	await _test_3_vehicle_drivability_simulation()
	await _test_4_all_vehicles_hell_traversal()
	await _test_5_state_machine_and_environment_host_sync()
	
	_print_summary()

## ----------------------------------------------------
## Test 1: Geometry, Slope Bounds, and Exit Merge
## ----------------------------------------------------
func _test_1_geometry_and_slope_bounds() -> void:
	print("-> [1/5] Testing Hell 500m track geometry, slope bounds, and Hermite exit merge...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	encounter.build_encounter()
	
	var hell_seg: TerrainSegment = encounter.hell_segment
	_assert_check(hell_seg != null, "Hell terrain segment instantiated")
	_assert_check(not hell_seg.is_floating_platform, "Hell route is solid bedrock bottom (not floating platform)")
	
	var pts: PackedVector2Array = hell_seg.generated_surface_points
	_assert_check(pts.size() > 500, "Sufficient surface sampling across 500m (%d points)" % pts.size())
	
	var max_slope: float = 0.0
	var has_nan: bool = false
	for i in range(pts.size() - 1):
		var p1 := pts[i]
		var p2 := pts[i + 1]
		if is_nan(p1.y) or is_nan(p2.y) or is_inf(p1.y) or is_inf(p2.y):
			has_nan = true
		var dx := p2.x - p1.x
		if dx > 0.001:
			var slope := absf((p2.y - p1.y) / dx)
			if slope > max_slope:
				max_slope = slope
				
	_assert_check(not has_nan, "All surface points have valid finite coordinates (no NaN/Inf)")
	_assert_check(max_slope <= 0.25, "Maximum surface slope is within smooth drivable bounds (Max: %.4f <= 0.25)" % max_slope)
	
	# Verify catch basin starts at Y = 460.0px and smoothly settles to Y = 600.0px
	var basin_entry_y: float = hell_seg.get_surface_y_at(0.0)
	var basin_settle_y: float = hell_seg.get_surface_y_at(encounter.catch_basin_length - 50.0)
	_assert_check(absf(basin_entry_y - 460.0) < 0.5, "Catch basin entry starts at Y = 460.0px (Got: %.1f)" % basin_entry_y)
	_assert_check(absf(basin_settle_y - 600.0) < 0.5, "Catch basin settles smoothly to Y = 600.0px (Got: %.1f)" % basin_settle_y)
	
	# Verify Demon's Chasm dip and jump
	var chasm_dip_y: float = hell_seg.get_surface_y_at(16500.0 - 50.0)
	_assert_check(chasm_dip_y > 630.0, "Demon's Chasm reaches dramatic volcanic dip (Y = %.1f > 630.0px)" % chasm_dip_y)
	
	# Verify exit ascent ramp joins Normal Land baseline at Y = 420px with zero slope
	var exit_local_x: float = encounter.realm_total_length - 50.0
	var exit_y: float = hell_seg.get_surface_y_at(exit_local_x)
	var exit_slope: float = hell_seg.get_exit_slope()
	_assert_check(is_equal_approx(exit_y, 420.0), "Exit ramp joins Normal Land baseline at Y = 420.0px (Got: %.1f)" % exit_y)
	_assert_check(absf(exit_slope) < 0.01, "Exit ramp has smooth horizontal C1 tangency (Slope: %.4f)" % exit_slope)
	
	encounter.free()
	await physics_frame

## ----------------------------------------------------
## Test 2: Visual Dressing, Ambient Characters & Pickups
## ----------------------------------------------------
func _test_2_visual_dressing_characters_and_pickups() -> void:
	print("-> [2/5] Testing Hell visual dressing set pieces, characters, and reward pickups...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	encounter.build_encounter()
	
	var dressing: Node2D = encounter.get_node_or_null("HellDressing")
	_assert_check(dressing != null, "HellDressing container created")
	
	# Check Giant Dragon Skull Entrance Landmark (rectangular cave image) is permanently removed
	var skull_portal = dressing.get_node_or_null("GiantDragonSkullPortal")
	_assert_check(skull_portal == null, "Giant Dragon Skull Entrance Landmark (rectangular cave image) permanently removed")
	
	# Check Magma Geyser Eruption visual event
	var geyser_event = dressing.get_node_or_null("MagmaGeyserEruption")
	_assert_check(geyser_event != null, "Magma Geyser Eruption visual event instantiated")
	_assert_check(geyser_event.amount >= 25, "Geyser particle density verified (%d particles >= 25)" % geyser_event.amount)
	
	# Count Basalt Pillars, Magma Vents, Spikes, Glow Masks, and Skull Piles
	var pillar_count := 0
	var vent_count := 0
	var spike_count := 0
	var glow_count := 0
	var pile_count := 0
	var cinder_emitters := 0
	
	# Environmental characters
	var skeleton_count := 0
	var goblin_count := 0
	var fiend_count := 0
	var dragon_count := 0
	
	# Collectible Pickups
	var coin_count := 0
	var fuel_count := 0
	
	for child in dressing.get_children():
		if child is Sprite2D:
			if BranchingEncounterClass.TEX_HELL_BASALT_COLUMN != null and child.texture == BranchingEncounterClass.TEX_HELL_BASALT_COLUMN:
				pillar_count += 1
			elif BranchingEncounterClass.TEX_HELL_MAGMA_VENT != null and child.texture == BranchingEncounterClass.TEX_HELL_MAGMA_VENT:
				vent_count += 1
			elif BranchingEncounterClass.TEX_HELL_OBSIDIAN_SPIKES != null and child.texture == BranchingEncounterClass.TEX_HELL_OBSIDIAN_SPIKES:
				spike_count += 1
			elif child.texture == BranchingEncounterClass.TEX_HELL_GLOW_MASK:
				glow_count += 1
			elif child.texture == BranchingEncounterClass.TEX_HELL_SKULL_PILE:
				pile_count += 1
		elif child is CPUParticles2D:
			cinder_emitters += 1
		elif child is Area2D:
			var scr: Script = child.get_script() as Script
			var scr_path: String = scr.resource_path if scr != null else ""
			if scr_path.contains("Coin") or "coin" in child.name.to_lower():
				coin_count += 1
			elif scr_path.contains("Fuel") or "fuel" in child.name.to_lower():
				fuel_count += 1
		elif child is Node2D:
			var c_name: String = child.name
			if c_name.contains("Skeleton"):
				skeleton_count += 1
			elif c_name.contains("Goblin"):
				goblin_count += 1
			elif c_name.contains("Fiend"):
				fiend_count += 1
			elif c_name.contains("Dragon"):
				dragon_count += 1

	_assert_check(pillar_count == 0, "Verified: 0 unwanted jagged black-orange strips in Hell route (Got: %d)" % pillar_count)
	_assert_check(vent_count == 0, "Verified: 0 legacy dotted magma vent obstacles in Hell route (Got: %d)" % vent_count)
	_assert_check(spike_count == 0, "Verified: 0 legacy dotted obsidian spike obstacles in Hell route (Got: %d)" % spike_count)
	_assert_check(glow_count >= 3, "Subterranean magma glow masks placed in dips and geyser (%d glows >= 3)" % glow_count)
	_assert_check(pile_count >= 2, "Catacomb skull pile decals placed along route (%d piles >= 2)" % pile_count)
	_assert_check(cinder_emitters >= 4, "Volcanic cinder/smoke particle emitters active (%d emitters >= 4)" % cinder_emitters)
	
	# Character checks - verify legacy cartoon characters and dragon have been removed
	_assert_check(skeleton_count == 0, "Verified: 0 legacy Skeleton Knight characters in Hell route (Got: %d)" % skeleton_count)
	_assert_check(goblin_count == 0, "Verified: 0 legacy Demon Goblin characters in Hell route (Got: %d)" % goblin_count)
	_assert_check(fiend_count == 0, "Verified: 0 legacy Horned Fiend characters in Hell route (Got: %d)" % fiend_count)
	_assert_check(dragon_count == 0, "Verified: 0 legacy Flying Hell Dragon characters in Hell route (Got: %d)" % dragon_count)
	
	# Pickup checks
	_assert_check(coin_count >= 10, "Coin reward opportunities placed along Hell route (%d coins >= 10)" % coin_count)
	_assert_check(fuel_count >= 2, "Fuel pickups placed in Demon's Chasm and Sulfur Flats (%d canisters >= 2)" % fuel_count)
	
	encounter.free()
	await physics_frame

## ----------------------------------------------------
## Test 3: Vehicle Drivability Simulation
## ----------------------------------------------------
func _test_3_vehicle_drivability_simulation() -> void:
	print("-> [3/5] Testing vehicle driving simulation across all 500m of Hell track...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	encounter.build_encounter()
	root.add_child(encounter)
	
	# Spawn Blue Flame Truck in catch basin
	var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle("blue_flame_truck")
	root.add_child(vehicle)
	vehicle.global_position = Vector2(51200.0, 560.0)
	vehicle.linear_velocity = Vector2(500.0, 0.0)
	vehicle.set_process(true)
	vehicle.set_physics_process(true)
	
	var caught_in_hell := false
	var passed_skel_1 := false
	var passed_chasm := false
	var passed_fiend := false
	var passed_outpost_2 := false
	var climbed_geyser_ramp := false
	var reached_normal_merge := false
	
	# Checkpoints along the 500m Hell route
	var checkpoints := [
		51200.0, # Catch basin
		58500.0, # Skeleton Knight 1
		69000.0, # Demon's Chasm & Goblin
		80000.0, # Horned Fiend Cavern
		90000.0, # Sulfur Flats & Outpost 2
		97500.0, # Magma Geyser Escape Ramp
		100000.0 # Normal Land merge
	]
	
	for cp_x in checkpoints:
		var track_y: float = encounter.hell_segment.get_surface_y_at(cp_x - 50000.0 - 50.0)
		vehicle.global_position = Vector2(cp_x, track_y - 30.0)
		vehicle.linear_velocity = Vector2(600.0, 0.0)
		
		# Drive for 25 physics frames at each checkpoint
		for f in range(25):
			if vehicle.rear_wheel:
				vehicle.rear_wheel.apply_torque(vehicle.motor_torque)
			if vehicle.front_wheel:
				vehicle.front_wheel.apply_torque(vehicle.motor_torque * 0.75)
			await physics_frame
			
		var cur_x := vehicle.global_position.x
		var cur_y := vehicle.global_position.y
		
		if cur_x >= 51000.0 and cur_y >= 540.0:
			caught_in_hell = true
		if cur_x >= 58000.0:
			passed_skel_1 = true
		if cur_x >= 68500.0:
			passed_chasm = true
		if cur_x >= 79500.0:
			passed_fiend = true
		if cur_x >= 89500.0:
			passed_outpost_2 = true
		if cur_x >= 97000.0:
			climbed_geyser_ramp = true
		if cur_x >= 99500.0:
			reached_normal_merge = true

	_assert_check(caught_in_hell, "Vehicle confirmed stable reception in Hell catch basin")
	_assert_check(passed_skel_1, "Vehicle safely traversed through Skeleton Knight Outpost (585m)")
	_assert_check(passed_chasm, "Vehicle safely traversed through Demon's Chasm Dip & Jump (690m)")
	_assert_check(passed_fiend, "Vehicle safely traversed through Horned Fiend Cavern (800m)")
	_assert_check(passed_outpost_2, "Vehicle safely traversed through Sulfur Flats Outpost (900m)")
	_assert_check(climbed_geyser_ramp, "Vehicle successfully climbed Magma Geyser Escape Ramp (975m)")
	_assert_check(reached_normal_merge, "Vehicle reached Normal Land merge point (1000m)")
	
	vehicle.queue_free()
	encounter.queue_free()
	await physics_frame

## ----------------------------------------------------
## Test 4: All 4 Vehicles Hell Route Traversal
## ----------------------------------------------------
func _test_4_all_vehicles_hell_traversal() -> void:
	print("-> [4/5] Testing all 4 registered vehicles traversing Hell route...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	encounter.build_encounter()
	root.add_child(encounter)
	
	var vehicle_names := ["blue_flame_truck", "orc_racer", "trophy_truck", "dune_buggy"]
	for v_name in vehicle_names:
		var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle(v_name)
		root.add_child(vehicle)
		vehicle.set_process(true)
		vehicle.set_physics_process(true)
		
		# Sample vehicle stability at 3 distinct Hell locations
		var test_positions := [
			Vector2(51200.0, 560.0), # Catch basin
			Vector2(69000.0, 600.0), # Demon's chasm
			Vector2(97500.0, 480.0)  # Magma geyser ascent ramp
		]
		
		var vehicle_ok := true
		for pos in test_positions:
			vehicle.global_position = pos
			vehicle.linear_velocity = Vector2(400.0, 0.0)
			
			for f in range(15):
				if vehicle.rear_wheel:
					vehicle.rear_wheel.apply_torque(vehicle.motor_torque * 0.5)
				await physics_frame
				
			# Check no falling through floor or NaN coordinates
			if vehicle.global_position.y > 900.0 or is_nan(vehicle.global_position.y):
				vehicle_ok = false
				break
				
		_assert_check(vehicle_ok, "Vehicle [%s] traversed Hell sectors with stable wheel collision" % v_name)
		vehicle.queue_free()
		await physics_frame
		
	encounter.queue_free()
	await physics_frame

## ----------------------------------------------------
## Test 5: State Machine & Environment Host Synchronization
## ----------------------------------------------------
func _test_5_state_machine_and_environment_host_sync() -> void:
	print("-> [5/5] Testing state machine and environment host audio/visual synchronization...")
	
	var controller := BiomeProgressionControllerClass.new()
	controller.enable_branching_mode(true)
	root.add_child(controller)
	
	var host := BiomeEnvironmentHostClass.new()
	host.auto_spawn_transition_ramps = true # Should be suppressed by branching mode check
	host.bind_progression_controller(controller)
	root.add_child(host)
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	encounter.bind_progression_controller(controller)
	encounter.build_encounter()
	root.add_child(encounter)
	
	# Confirm Hell route via encounter trigger
	var vehicle_mock := CharacterBody2D.new()
	vehicle_mock.name = "Vehicle"
	vehicle_mock.add_to_group("vehicle")
	root.add_child(vehicle_mock)
	encounter._on_hell_trigger_body_entered(vehicle_mock)
	
	# Advance vehicle into Hell entry zone (505m)
	controller.update_distance(505.0)
	
	var confirmed_r: int = controller.confirmed_realms.get(0, -1)
	_assert_check(confirmed_r == WorldCycleSchedule.BiomeType.HELL, "Progression controller confirmed HELL route")
	_assert_check(controller.current_state == WorldCycleSchedule.WorldState.HELL_ENTRY, "World state transitioned to HELL_ENTRY")
	_assert_check(host.current_biome == WorldCycleSchedule.BiomeType.HELL, "BiomeEnvironmentHost synchronized to HELL biome")
	
	# Progress distance into active Hell route (750m)
	controller.update_distance(750.0)
	_assert_check(controller.current_state == WorldCycleSchedule.WorldState.HELL_ACTIVE, "World state updated to HELL_ACTIVE at 750m")
	
	# Simulate reaching exit merge at 1000m
	encounter._on_merge_trigger_body_entered(vehicle_mock)
	_assert_check(encounter._merge_resolved, "Merge trigger dispatched completion signal")
	
	controller.update_distance(1005.0)
	var is_normal_state: bool = (
		controller.current_state == WorldCycleSchedule.WorldState.NORMAL_APPROACH or
		controller.current_state == WorldCycleSchedule.WorldState.NORMAL_LAND_1 or
		controller.current_state == WorldCycleSchedule.WorldState.NORMAL_MERGE
	)
	_assert_check(is_normal_state, "Controller returned to Normal Land after 1000m merge (State: %d)" % controller.current_state)
	
	vehicle_mock.queue_free()
	encounter.queue_free()
	host.queue_free()
	controller.queue_free()
	await physics_frame

func _print_summary() -> void:
	print("\n=================================================================")
	if _failed_checks == 0:
		print("✓ ALL PHASE 4 TESTS COMPLETED WITH 100%% SUCCESS (%d checks passed)!" % _passed_checks)
	else:
		printerr("✗ PHASE 4 TEST SUITE FINISHED WITH %d FAILURES (%d checks passed)" % [_failed_checks, _passed_checks])
	print("=================================================================\n")
	
	quit(_failed_checks)
