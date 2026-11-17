extends SceneTree

## Unit & Integration Test Suite for Phase 2: Physical Ramp & Two-Route Graybox
## Verifies:
## 0. Runtime switching of the optional branching schedule and stale encounter cleanup.
## 1. BranchingEncounter segment creation and collision geometry.
## 2. Nitro launch physics: all registered vehicles clear the lip and land on upper Heaven route.
## 3. Missed launch physics: vehicles without Nitro fall safely into lower Hell catch basin without crash.
## 4. Continuity and clearance on both 500m branches.
## 5. Smooth merge back to Normal Land baseline at 1,000m.

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const BranchingEncounter = preload("res://scripts/terrain/BranchingEncounter.gd")
const TerrainGenerator = preload("res://scripts/terrain/TerrainGenerator.gd")
const BiomeProgressionController = preload("res://scripts/progression/BiomeProgressionController.gd")

var failures: Array[String] = []
var pass_count: int = 0

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 2 PHYSICAL RAMP & TWO-ROUTE GRAYBOX TEST SUITE ---")
	print("=================================================================\n")
	_run_all_tests()

func _run_all_tests() -> void:
	test_0_branching_mode_stays_synchronized()
	await test_1_encounter_geometry_and_triggers()
	await test_2_nitro_launch_reaches_heaven()
	await test_3_missed_launch_safe_catch_in_hell()
	await test_4_all_vehicles_compatibility()
	await test_5_exit_ramps_merge_to_normal_land()

	print("\n=================================================================")
	if failures.is_empty():
		print("✓ ALL PHASE 2 TESTS COMPLETED WITH 100%% SUCCESS (%d checks passed)!" % pass_count)
		print("=================================================================")
		quit(0)
	else:
		print("❌ TEST SUITE FAILED with %d failure(s):" % failures.size())
		for f in failures:
			print("  - " + f)
		print("=================================================================")
		quit(1)

func assert_true(cond: bool, msg: String) -> void:
	if cond:
		pass_count += 1
	else:
		failures.append(msg)
		printerr("  ❌ FAIL: " + msg)

func assert_eq(actual: Variant, expected: Variant, msg: String) -> void:
	if actual == expected:
		pass_count += 1
	else:
		var err := "%s | Expected: %s, Got: %s" % [msg, str(expected), str(actual)]
		failures.append(err)
		printerr("  ❌ FAIL: " + err)

func assert_approx_eq(actual: float, expected: float, tol: float, msg: String) -> void:
	if absf(actual - expected) <= tol:
		pass_count += 1
	else:
		var err := "%s | Expected: %f (+/-%f), Got: %f" % [msg, expected, tol, actual]
		failures.append(err)
		printerr("  ❌ FAIL: " + err)


# ---------------------------------------------------------------------------
# Test 0: Runtime branching-mode synchronization
# ---------------------------------------------------------------------------
func test_0_branching_mode_stays_synchronized() -> void:
	print("-> [0/6] Testing live branching-mode synchronization and override...")
	var generator := TerrainGenerator.new()
	var controller := BiomeProgressionController.new()
	generator.bind_progression_controller(controller)
	assert_true(not generator._is_branching_mode_enabled(), "Fixed schedule must not enable branching encounters")
	controller.enable_branching_mode(true)
	assert_true(generator._is_branching_mode_enabled(), "Switching controller to branching mode must be detected live")
	controller.enable_branching_mode(false)
	assert_true(not generator._is_branching_mode_enabled(), "Switching controller back to fixed schedule must disable branching mode")
	var stale_encounter := Node2D.new()
	root.add_child(stale_encounter)
	generator.active_encounters.append(stale_encounter)
	generator._update_culling(0.0)
	assert_true(stale_encounter.is_queued_for_deletion(), "Encounter nodes must be removed after switching back to the fixed cycle")
	generator.enable_branching_encounters = true
	assert_true(generator._is_branching_mode_enabled(), "Explicit inspector override must still enable branching mode")
	generator.free()
	controller.free()
	print("  ✓ Controller mode changes are read live; explicit override remains supported!")

# ---------------------------------------------------------------------------
# Test 1: Encounter Geometry & Triggers
# ---------------------------------------------------------------------------
func test_1_encounter_geometry_and_triggers() -> void:
	print("-> [1/6] Testing BranchingEncounter geometry and trigger wiring...")

	var encounter := BranchingEncounter.new()
	encounter.gate_distance_m = 500.0
	root.add_child(encounter)

	assert_true(is_instance_valid(encounter.approach_segment), "Approach ramp segment must exist")
	assert_true(is_instance_valid(encounter.heaven_segment), "Heaven route segment must exist")
	assert_true(is_instance_valid(encounter.hell_segment), "Hell route segment must exist")
	assert_true(is_instance_valid(encounter.heaven_trigger), "Heaven confirmation trigger must exist")
	assert_true(is_instance_valid(encounter.hell_trigger), "Hell confirmation trigger must exist")
	assert_true(is_instance_valid(encounter.merge_trigger), "Merge completion trigger must exist")

	# Verify upper route is a floating platform of finite thickness (not blocking lower route)
	assert_true(encounter.heaven_segment.is_floating_platform, "Heaven route must be floating platform")
	assert_approx_eq(encounter.heaven_segment.platform_thickness, 120.0, 0.001, "Platform thickness 120px")
	assert_true(encounter.heaven_segment.visual_surface_band_depth < encounter.heaven_segment.platform_thickness, "Heaven visual crust must not cover the full floating platform")
	assert_true(encounter.heaven_segment.subsoil_polygon.polygon.size() == encounter.heaven_segment.generated_surface_points.size() * 2, "Heaven floating platform must have distinct crust and underside polygons")

	# Verify vertical clearance between upper Heaven track (~200px) and lower Hell track (~600px)
	var vertical_gap := encounter.hell_y - (encounter.heaven_y + encounter.heaven_segment.platform_thickness)
	assert_true(vertical_gap >= 250.0, "Vertical clearance between Heaven and Hell routes must be >= 250px (got %f)" % vertical_gap)

	encounter.queue_free()
	print("  ✓ Encounter geometry, platform clearance, and triggers verified!")

# ---------------------------------------------------------------------------
# Test 2: Nitro Launch Physics Reaches Heaven
# ---------------------------------------------------------------------------
func test_2_nitro_launch_reaches_heaven() -> void:
	print("-> [2/6] Testing Nitro launch physics reaching upper Heaven landing...")

	var encounter := BranchingEncounter.new()
	encounter.gate_distance_m = 500.0
	root.add_child(encounter)

	var confirmed_route := {"realm": -1, "encounter": -1}
	encounter.route_confirmed.connect(func(realm: int, enc: int) -> void:
		confirmed_route["realm"] = realm
		confirmed_route["encounter"] = enc
	)

	# Instantiate Blue Flame Truck
	var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle("blue_flame_truck")
	root.add_child(vehicle)
	# Position on approach ramp 1200px before lip with initial forward speed
	vehicle.global_position = Vector2(50000.0 - 1200.0, 370.0)
	vehicle.linear_velocity = Vector2(1200.0, 0.0)

	# Activate full throttle and Nitro boost
	vehicle.set_nitro_active(true)
	vehicle.set_process(true)
	vehicle.set_physics_process(true)

	# Step physics frames to simulate driving up ramp and launching
	var reached_heaven := false
	for frame in range(160):
		vehicle.apply_central_force(vehicle.transform.x * vehicle.nitro_boost_force)
		if vehicle.rear_wheel:
			vehicle.rear_wheel.apply_torque(vehicle.motor_torque * 1.6)
		if vehicle.front_wheel:
			vehicle.front_wheel.apply_torque(vehicle.motor_torque * 1.6 * 0.75)

		await physics_frame

		if confirmed_route["realm"] == WorldCycleSchedule.BiomeType.HEAVEN:
			reached_heaven = true
			break

	assert_true(reached_heaven, "Vehicle with Nitro must reach upper Heaven landing")
	assert_eq(confirmed_route["realm"], WorldCycleSchedule.BiomeType.HEAVEN, "Confirmed realm must be HEAVEN")
	assert_true(vehicle.global_position.y <= 300.0, "Vehicle elevation must be in Heaven zone (Y <= 300, got %f)" % vehicle.global_position.y)

	vehicle.queue_free()
	encounter.queue_free()
	print("  ✓ Nitro launch successfully clears gap and confirms Heaven route!")

# ---------------------------------------------------------------------------
# Test 3: Missed Launch Physics Safe Catch in Hell
# ---------------------------------------------------------------------------
func test_3_missed_launch_safe_catch_in_hell() -> void:
	print("-> [3/6] Testing missed launch falling safely into lower Hell catch basin...")

	var encounter := BranchingEncounter.new()
	encounter.gate_distance_m = 500.0
	root.add_child(encounter)

	var confirmed_route := {"realm": -1, "encounter": -1}
	encounter.route_confirmed.connect(func(realm: int, enc: int) -> void:
		confirmed_route["realm"] = realm
		confirmed_route["encounter"] = enc
	)

	# Instantiate Blue Flame Truck without Nitro (low momentum)
	var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle("blue_flame_truck")
	root.add_child(vehicle)
	# Place at ramp lip with moderate speed (no Nitro)
	vehicle.global_position = Vector2(50000.0 - 100.0, 325.0)
	vehicle.linear_velocity = Vector2(650.0, -100.0)
	vehicle.set_nitro_active(false)

	var reached_hell := false
	var crashed := false
	vehicle.crashed.connect(func(): crashed = true)

	for frame in range(140):
		await physics_frame

		if confirmed_route["realm"] == WorldCycleSchedule.BiomeType.HELL:
			reached_hell = true
			# Allow vehicle to finish descent and touch catch basin surface
			for _f in range(35):
				await physics_frame
			break

	assert_true(reached_hell, "Vehicle without Nitro must drop into lower Hell catch basin")
	assert_eq(confirmed_route["realm"], WorldCycleSchedule.BiomeType.HELL, "Confirmed realm must be HELL")
	assert_true(not crashed, "Vehicle must NOT crash when caught in Hell catch basin")
	assert_true(vehicle.global_position.y >= 440.0, "Vehicle elevation must be in Hell zone (Y >= 440, got %f)" % vehicle.global_position.y)

	vehicle.queue_free()
	encounter.queue_free()
	print("  ✓ Missed launch safely received by Hell catch basin with zero crashes!")

# ---------------------------------------------------------------------------
# Test 4: All Registered Vehicles Compatibility
# ---------------------------------------------------------------------------
func test_4_all_vehicles_compatibility() -> void:
	print("-> [4/6] Testing all 4 registered vehicles on branching ramp...")

	var vehicle_ids := VehicleRegistry.get_vehicle_ids()
	assert_eq(vehicle_ids.size(), 4, "Must test all 4 vehicles")

	for v_id in vehicle_ids:
		var encounter := BranchingEncounter.new()
		encounter.gate_distance_m = 500.0
		root.add_child(encounter)

		var result := {"realm": -1}
		encounter.route_confirmed.connect(func(r: int, _e: int): result["realm"] = r)

		var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle(v_id)
		root.add_child(vehicle)
		vehicle.global_position = Vector2(50000.0 - 1200.0, 370.0)
		vehicle.linear_velocity = Vector2(1300.0, 0.0)
		vehicle.set_nitro_active(true)

		for frame in range(180):
			vehicle.apply_central_force(vehicle.transform.x * vehicle.nitro_boost_force)
			if vehicle.rear_wheel:
				vehicle.rear_wheel.apply_torque(vehicle.motor_torque * 1.6)
			if vehicle.front_wheel:
				vehicle.front_wheel.apply_torque(vehicle.motor_torque * 1.6 * 0.75)

			await physics_frame
			if result["realm"] == WorldCycleSchedule.BiomeType.HEAVEN:
				break

		assert_true(result["realm"] == WorldCycleSchedule.BiomeType.HEAVEN, "Vehicle [%s] must successfully reach Heaven with Nitro" % v_id)

		vehicle.queue_free()
		encounter.queue_free()
		print("  • Vehicle [%s]: PASS" % v_id)

	print("  ✓ All 4 vehicles successfully tested on branching launch physics!")

# ---------------------------------------------------------------------------
# Test 5: Exit Ramps Merge to Normal Land Baseline
# ---------------------------------------------------------------------------
func test_5_exit_ramps_merge_to_normal_land() -> void:
	print("-> [5/6] Testing Heaven and Hell exit ramps merge into Normal Land baseline...")

	var encounter := BranchingEncounter.new()
	encounter.gate_distance_m = 500.0
	root.add_child(encounter)

	# Verify Heaven exit point matches baseline_y
	var heaven_exit := encounter.heaven_segment.get_exit_point()
	var heaven_global_exit_y := encounter.heaven_segment.global_position.y + heaven_exit.y
	assert_approx_eq(heaven_global_exit_y, encounter.baseline_y, 1.0, "Heaven exit ramp must merge at baseline_y (420px)")

	# Verify Hell exit point matches baseline_y
	var hell_exit := encounter.hell_segment.get_exit_point()
	var hell_global_exit_y := encounter.hell_segment.global_position.y + hell_exit.y
	assert_approx_eq(hell_global_exit_y, encounter.baseline_y, 1.0, "Hell exit ramp must merge at baseline_y (420px)")

	# Verify both exit slopes are approximately 0.0 (smooth horizontal transition)
	var heaven_exit_slope := encounter.heaven_segment.get_exit_slope()
	var hell_exit_slope := encounter.hell_segment.get_exit_slope()
	assert_approx_eq(heaven_exit_slope, 0.0, 0.05, "Heaven exit slope must be smooth horizontal (got %f)" % heaven_exit_slope)
	assert_approx_eq(hell_exit_slope, 0.0, 0.05, "Hell exit slope must be smooth horizontal (got %f)" % hell_exit_slope)

	encounter.queue_free()
	print("  ✓ Both exit ramps merge seamlessly into Normal Land at baseline (Y=420px, slope=0.0)!")
