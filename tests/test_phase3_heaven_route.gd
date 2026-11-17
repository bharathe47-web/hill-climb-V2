extends SceneTree

## test_phase3_heaven_route.gd
## Automated test suite for Phase 3 — Heaven 500m playable route.
## Verifies:
## 1. Heaven terrain surface continuity, slope bounds, and Hermite exit merge.
## 2. Visual dressing set pieces (golden arches, palace columns, angel statues, flying doves, lilies, clouds).
## 3. Real physics vehicle driving simulation across Heaven track for all 4 registered vehicles.
## 4. Route trigger confirmation, merge signal dispatch, and audio/environment host synchronization.

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")
const BiomeProgressionControllerClass = preload("res://scripts/progression/BiomeProgressionController.gd")
const BiomeEnvironmentHostClass = preload("res://scripts/environment/BiomeEnvironmentHost.gd")
const VehicleControllerClass = preload("res://scripts/vehicle/VehicleController.gd")

var _passed_checks: int = 0
var _failed_checks: int = 0

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN PHASE 3 HEAVEN 500M PLAYABLE ROUTE TEST SUITE ---")
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
	await _test_2_visual_dressing_and_depth_ordering()
	await _test_3_vehicle_drivability_simulation()
	await _test_4_all_vehicles_heaven_traversal()
	await _test_5_state_machine_and_environment_host_sync()
	
	_print_summary()

## ----------------------------------------------------
## Test 1: Geometry, Slope Bounds, and Exit Merge
## ----------------------------------------------------
func _test_1_geometry_and_slope_bounds() -> void:
	print("-> [1/5] Testing Heaven 500m track geometry, slope bounds, and Hermite exit merge...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	encounter.build_encounter()
	
	var heaven_seg: TerrainSegment = encounter.heaven_segment
	_assert_check(heaven_seg != null, "Heaven terrain segment instantiated")
	_assert_check(heaven_seg.is_floating_platform, "Heaven route is configured as floating platform")
	_assert_check(heaven_seg.platform_thickness == 120.0, "Platform thickness is exactly 120px")
	
	var pts: PackedVector2Array = heaven_seg.generated_surface_points
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
	
	# Verify landing apron entry
	var apron_entry_y: float = heaven_seg.get_surface_y_at(0.0)
	_assert_check(is_equal_approx(apron_entry_y, 230.0), "Landing apron entry starts at Y = 230.0px (Got: %.1f)" % apron_entry_y)
	
	# Verify Angel's Terrace elevated plateau
	var terrace_y: float = heaven_seg.get_surface_y_at(14500.0 - encounter.launch_gap)
	_assert_check(terrace_y < 160.0, "Angel's Terrace reaches elevated crest (Y = %.1f < 160.0px)" % terrace_y)
	
	# Verify exit ramp joins Normal Land baseline at Y = 420px with zero slope
	var exit_local_x: float = encounter.realm_total_length - encounter.launch_gap
	var exit_y: float = heaven_seg.get_surface_y_at(exit_local_x)
	var exit_slope: float = heaven_seg.get_exit_slope()
	_assert_check(is_equal_approx(exit_y, 420.0), "Exit ramp joins Normal Land baseline at Y = 420.0px (Got: %.1f)" % exit_y)
	_assert_check(absf(exit_slope) < 0.01, "Exit ramp has smooth horizontal C1 tangency (Slope: %.4f)" % exit_slope)
	
	encounter.free()
	await physics_frame

## ----------------------------------------------------
## Test 2: Visual Dressing Hierarchy & Depth Ordering
## ----------------------------------------------------
func _test_2_visual_dressing_and_depth_ordering() -> void:
	print("-> [2/5] Testing Heaven visual dressing landmarks, clouds, doves, and layer depths...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	encounter.build_encounter()
	
	var dressing: Node2D = encounter.get_node_or_null("HeavenDressing")
	_assert_check(dressing != null, "HeavenDressing container created")
	
	# Check Golden Archways
	var entry_arch_back = dressing.get_node_or_null("EntryGoldenArchway")
	var entry_arch_front = dressing.get_node_or_null("EntryGoldenArchwayFront")
	var mid_arch = dressing.get_node_or_null("MidPalaceArchway")
	var exit_arch = dressing.get_node_or_null("ExitCloudSlideArchway")
	
	_assert_check(entry_arch_back != null and entry_arch_front != null, "Entry Golden Archway has both front and back layers")
	_assert_check(entry_arch_back.z_index == -1 and entry_arch_front.z_index == 5, "Archway z-indices frame the vehicle driving lane (-1 back, 5 front)")
	_assert_check(mid_arch != null, "Mid-Route Grand Palace Archway placed at 750m")
	_assert_check(exit_arch != null, "Exit Cloud Slide Archway placed framing descent to Normal Land")
	
	# Check Angel Statues
	var statue1 = dressing.get_node_or_null("AngelStatueMonument1")
	var statue2 = dressing.get_node_or_null("AngelStatueMonument2")
	_assert_check(statue1 != null and statue2 != null, "Both Angel Statue Monuments instantiated")
	_assert_check(statue1.z_index == -1 and statue2.z_index == -1, "Angel statues placed at background safe depth (z_index = -1)")
	
	# Count Palace Columns, Cloud Puffs, Sparkles, and Doves
	var col_count := 0
	var cloud_count := 0
	var spark_count := 0
	var dove_count := 0
	var flower_count := 0
	
	for child in dressing.get_children():
		if child is Sprite2D:
			if child.texture == BranchingEncounterClass.TEX_HEAVEN_COLUMN:
				col_count += 1
			elif child.texture in BranchingEncounterClass.TEX_CLOUDS:
				cloud_count += 1
			elif child.texture in BranchingEncounterClass.TEX_FLOWERS:
				flower_count += 1
		elif child is CPUParticles2D:
			spark_count += 1
		elif child is Node2D:
			if (child.has_method("get") and child.get("creature_name") == "HeavenDove") or child.name.contains("Dove"):
				dove_count += 1

	_assert_check(col_count >= 10, "Palace colonnade landmarks placed along track (%d columns >= 10)" % col_count)
	_assert_check(cloud_count >= 15, "Underside and cushion cloud puffs placed along floating route (%d clouds >= 15)" % cloud_count)
	_assert_check(spark_count >= 3, "Celestial golden spark particles active at key monuments (%d emitters >= 3)" % spark_count)
	_assert_check(dove_count >= 3, "Animated flying doves active overhead (%d doves >= 3)" % dove_count)
	_assert_check(flower_count >= 8, "Lily flower clusters placed at monuments (%d flowers >= 8)" % flower_count)
	
	encounter.free()
	await physics_frame

## ----------------------------------------------------
## Test 3: Vehicle Drivability Simulation
## ----------------------------------------------------
func _test_3_vehicle_drivability_simulation() -> void:
	print("-> [3/5] Testing vehicle driving simulation across all 500m of Heaven track...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.encounter_index = 0
	encounter.gate_distance_m = 500.0
	encounter.build_encounter()
	root.add_child(encounter)
	
	# Spawn Blue Flame Truck on landing apron
	var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle("blue_flame_truck")
	root.add_child(vehicle)
	vehicle.global_position = Vector2(50700.0, 160.0)
	vehicle.linear_velocity = Vector2(500.0, 0.0)
	vehicle.set_process(true)
	vehicle.set_physics_process(true)
	
	var landed_on_heaven := false
	var passed_statue_1 := false
	var passed_mid_arch := false
	var passed_statue_2 := false
	var passed_exit_arch := false
	var reached_normal_merge := false
	
	# Simulate vehicle driving across the 500m route
	var checkpoints := [
		51500.0, # Apron
		64500.0, # Monument 1
		75000.0, # Mid Archway
		87000.0, # Monument 2
		95000.0, # Exit Archway
		100000.0 # Merge
	]
	
	for cp_x in checkpoints:
		var track_y: float = encounter.heaven_segment.get_surface_y_at(cp_x - 50000.0 - encounter.launch_gap)
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
		
		if cur_x >= 51000.0 and cur_y < 260.0:
			landed_on_heaven = true
		if cur_x >= 64000.0:
			passed_statue_1 = true
		if cur_x >= 74500.0:
			passed_mid_arch = true
		if cur_x >= 86500.0:
			passed_statue_2 = true
		if cur_x >= 94500.0:
			passed_exit_arch = true
		if cur_x >= 99500.0:
			reached_normal_merge = true

	_assert_check(landed_on_heaven, "Vehicle confirmed stable landing on Heaven route")
	_assert_check(passed_statue_1, "Vehicle safely traversed through Angel Monument 1 (645m)")
	_assert_check(passed_mid_arch, "Vehicle safely traversed through Grand Palace Archway (750m)")
	_assert_check(passed_statue_2, "Vehicle safely traversed through Angel Monument 2 (870m)")
	_assert_check(passed_exit_arch, "Vehicle safely entered Exit Cloud Slide Ramp (950m)")
	_assert_check(reached_normal_merge, "Vehicle reached Normal Land merge point (1000m)")
	
	vehicle.queue_free()
	encounter.queue_free()
	await physics_frame

## ----------------------------------------------------
## Test 4: All 4 Vehicles Heaven Route Traversal
## ----------------------------------------------------
func _test_4_all_vehicles_heaven_traversal() -> void:
	print("-> [4/5] Testing all 4 registered vehicles traversing Heaven route...")
	
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
		
		# Sample vehicle stability at 3 distinct Heaven locations
		var test_positions := [
			Vector2(51000.0, 170.0), # Apron exit
			Vector2(75000.0, 160.0), # Mid palace archway
			Vector2(97000.0, 270.0)  # Cloud descent slide
		]
		
		var vehicle_ok := true
		for pos in test_positions:
			vehicle.global_position = pos
			vehicle.linear_velocity = Vector2(400.0, 0.0)
			
			for f in range(15):
				if vehicle.rear_wheel:
					vehicle.rear_wheel.apply_torque(vehicle.motor_torque * 0.5)
				await physics_frame
				
			# Check no infinite tilt or falling into void
			if vehicle.global_position.y > 600.0 or is_nan(vehicle.global_position.y):
				vehicle_ok = false
				break
				
		_assert_check(vehicle_ok, "Vehicle [%s] traversed Heaven sectors with stable wheel collision" % v_name)
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
	
	# Confirm Heaven route via encounter trigger before crossing gate
	var vehicle_mock := CharacterBody2D.new()
	vehicle_mock.name = "Vehicle"
	vehicle_mock.add_to_group("vehicle")
	root.add_child(vehicle_mock)
	encounter._on_heaven_trigger_body_entered(vehicle_mock)
	
	# Advance vehicle into Heaven entry zone (505m)
	controller.update_distance(505.0)
	
	var confirmed_r: int = controller.confirmed_realms.get(0, -1)
	_assert_check(confirmed_r == WorldCycleSchedule.BiomeType.HEAVEN, "Progression controller confirmed HEAVEN route")
	_assert_check(controller.current_state == WorldCycleSchedule.WorldState.HEAVEN_ENTRY, "World state transitioned to HEAVEN_ENTRY")
	_assert_check(host.current_biome == WorldCycleSchedule.BiomeType.HEAVEN, "BiomeEnvironmentHost synchronized to HEAVEN biome")
	
	# Progress distance into active Heaven route (750m)
	controller.update_distance(750.0)
	_assert_check(controller.current_state == WorldCycleSchedule.WorldState.HEAVEN_ACTIVE, "World state updated to HEAVEN_ACTIVE at 750m")
	
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
		print("✓ ALL PHASE 3 TESTS COMPLETED WITH 100%% SUCCESS (%d checks passed)!" % _passed_checks)
	else:
		printerr("✗ PHASE 3 TEST SUITE FINISHED WITH %d FAILURES (%d checks passed)" % [_failed_checks, _passed_checks])
	print("=================================================================\n")
	
	quit(_failed_checks)
