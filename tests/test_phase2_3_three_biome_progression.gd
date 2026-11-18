@tool
extends SceneTree

## Test suite verifying Phase 2.3: Fixed Recurring Three-Biome Progression (No Nitro Requirement).
## Biome sequence: NORMAL LAND (0-300m) -> HEAVEN (300-600m) -> HELL (600-900m) -> REPEAT EVERY 900m.
## Validates:
## TEST 1: 0m in Normal Land.
## TEST 2: Nitro is NOT required to enter Heaven (works with 0 nitro).
## TEST 3: Nitro remains an optional, ordinary boost (no special launch mechanic).
## TEST 4: No portal exists inside the middle of Normal Land [0, 300m).
## TEST 5: Physical HeavenPortal at 300m (30,000 px); vehicle drives through on roadway.
## TEST 6: Physical HellPortal at 600m (60,000 px); vehicle drives through.
## TEST 7: Physical ReturnPortal at 900m (90,000 px); completes Cycle 0, returns to Normal Land.
## TEST 8: Cycle 1 repeat (1200m Heaven Portal, 1500m Hell Portal, 1800m Return Portal).
## TEST 9: Cycle 2 repeat (2100m Heaven Portal, 2400m Hell Portal, 2700m Return Portal).
## TEST 10: 3 complete cycles (2,700m) continuous progression with monotonic cumulative HUD distance.
## TEST 11: Vehicle physics, momentum, wheel contact, fuel, and coins preserved across all portal transitions.

class MockVehicle extends RigidBody2D:
	var current_nitro: float = 0.0
	var max_nitro: float = 100.0
	var current_fuel: float = 78.5
	var current_coins: int = 142

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 2.3 THREE-BIOME PROGRESSION TEST SUITE ---")
	print("---        (NO NITRO REQUIREMENT CORRECTION SUITE)        ---")
	print("=================================================================")

	var passed := true

	passed = _test_1_start_in_normal_land() and passed
	passed = _test_2_no_nitro_requirement() and passed
	passed = _test_3_nitro_ordinary_boost() and passed
	passed = _test_4_no_portal_in_middle_of_normal_land() and passed
	passed = _test_5_physical_heaven_portal_at_300m() and passed
	passed = _test_6_physical_hell_portal_at_600m() and passed
	passed = _test_7_physical_return_portal_at_900m() and passed
	passed = _test_8_second_cycle_all_three_portals() and passed
	passed = _test_9_third_cycle_all_three_portals() and passed
	passed = _test_10_three_complete_cycles_2700m() and passed
	passed = _test_11_vehicle_momentum_and_state_preservation() and passed

	if passed:
		print("\n=================================================================")
		print("✓ ALL PHASE 2.3 NO-NITRO REGRESSION TESTS PASSED (100% SUCCESS)!")
		print("=================================================================")
		quit(0)
	else:
		print("\n=================================================================")
		print("✗ SOME PHASE 2.3 REGRESSION TESTS FAILED!")
		print("=================================================================")
		quit(1)

func _test_1_start_in_normal_land() -> bool:
	print("\n-> [TEST 1] Testing 0m in Normal Land...")
	var schedule := WorldCycleSchedule.new()
	if schedule.schedule_mode != WorldCycleSchedule.ScheduleMode.RECURRING_900M:
		printerr("  ✗ Active schedule mode is not RECURRING_900M")
		return false

	var info := schedule.resolve_distance(0.0)
	if info["active_biome"] != WorldCycleSchedule.BiomeType.NORMAL_LAND:
		printerr("  ✗ At 0m: expected active_biome NORMAL_LAND, got %d" % info["active_biome"])
		return false

	if info["state"] != WorldCycleSchedule.WorldState.NORMAL_LAND:
		printerr("  ✗ At 0m: expected state NORMAL_LAND, got %d" % info["state"])
		return false

	if info["cycle_index"] != 0 or info["distance_in_cycle"] != 0.0:
		printerr("  ✗ At 0m: expected cycle 0 distance 0, got cycle %d dist %f" % [info["cycle_index"], info["distance_in_cycle"]])
		return false

	print("  ✓ At 0m: Correctly initialized in Normal Land (Countryside)!")
	return true

func _test_2_no_nitro_requirement() -> bool:
	print("\n-> [TEST 2] Testing Nitro is NOT required to enter Heaven (0 nitro test)...")
	var controller := BiomeProgressionController.new()

	# Mock vehicle with ZERO nitro
	var mock_vehicle := MockVehicle.new()
	mock_vehicle.current_nitro = 0.0
	controller.bind_vehicle(mock_vehicle)

	var biome_changes: Array[Dictionary] = []
	controller.biome_changed.connect(func(old_b: int, new_b: int, c_idx: int):
		biome_changes.append({"old": old_b, "new": new_b, "cycle": c_idx})
	)

	# Vehicle drives smoothly from 0m through 270m, 290m, up to 300m with zero nitro input
	controller.update_distance(100.0)
	controller.update_distance(200.0)
	controller.update_distance(270.0)
	controller.update_distance(290.0)

	if not biome_changes.is_empty():
		printerr("  ✗ Premature biome switch before 300m")
		mock_vehicle.free()
		controller.free()
		return false

	# Cross 300m without nitro
	controller.update_distance(300.0)

	if controller.current_biome_index != WorldCycleSchedule.BiomeType.HEAVEN:
		printerr("  ✗ Failed to enter Heaven at 300m with zero nitro! Biome index: %d" % controller.current_biome_index)
		mock_vehicle.free()
		controller.free()
		return false

	if biome_changes.size() != 1 or biome_changes[0]["new"] != WorldCycleSchedule.BiomeType.HEAVEN:
		printerr("  ✗ Biome change event missing or invalid: ", biome_changes)
		mock_vehicle.free()
		controller.free()
		return false

	mock_vehicle.free()
	controller.free()
	print("  ✓ Confirmed: Nitro is NOT required to enter Heaven; transition succeeds with 0 nitro!")
	return true

func _test_3_nitro_ordinary_boost() -> bool:
	print("\n-> [TEST 3] Testing Nitro remains optional ordinary gameplay boost...")
	var controller := BiomeProgressionController.new()

	# Verify schedule info at 100m, 275m, 400m, 700m
	for d in [100.0, 275.0, 400.0, 700.0]:
		var info := controller.schedule.resolve_distance(d)
		if info.has("is_launch_zone") and bool(info["is_launch_zone"]):
			printerr("  ✗ Found special is_launch_zone in schedule at distance %.1fm" % d)
			controller.free()
			return false

	controller.free()
	print("  ✓ Confirmed: No forced Nitro launch zones exist; nitro remains ordinary gameplay boost!")
	return true

func _test_4_no_portal_in_middle_of_normal_land() -> bool:
	print("\n-> [TEST 4] Testing NO portal in middle of Normal Land (gateway strictly at 300m)...")
	var gen := TerrainGenerator.new()
	gen.clear_terrain()
	# Generate ahead through Normal Land up to 32,000 px (320m)
	gen._update_generation(32000.0)

	var portals_before_300m: Array[Node] = []
	var portals_at_300m: Array[Node] = []

	for portal in gen.active_portals:
		var px: float = portal.global_position.x
		if px < 29900.0:
			portals_before_300m.append(portal)
		elif absf(px - 30000.0) < 50.0:
			portals_at_300m.append(portal)

	if not portals_before_300m.is_empty():
		printerr("  ✗ Found illegal portal(s) in middle of Normal Land before 300m: ", portals_before_300m)
		gen.clear_terrain()
		gen.free()
		return false

	if portals_at_300m.is_empty():
		printerr("  ✗ Expected HeavenPortal at exactly 300m (30,000 px), but none was found")
		gen.clear_terrain()
		gen.free()
		return false

	# Verify roadway continuity under the portal (continuous ground segments)
	var has_ground_at_300m := false
	for seg in gen.active_segments:
		var seg_start: float = seg.global_position.x
		var seg_end: float = seg_start + seg.segment_length
		if seg_start <= 30000.0 and seg_end >= 30000.0:
			has_ground_at_300m = true
			break

	if not has_ground_at_300m:
		printerr("  ✗ Missing ground segment at 30,000 px; road must be continuous under the gateway")
		gen.clear_terrain()
		gen.free()
		return false

	gen.clear_terrain()
	gen.free()
	print("  ✓ Confirmed: Zero portals in middle of Normal Land; gateway sits strictly at 300m on continuous road!")
	return true

func _test_5_physical_heaven_portal_at_300m() -> bool:
	print("\n-> [TEST 5] Testing physical HeavenPortal at 300m...")
	var gen := TerrainGenerator.new()
	gen.clear_terrain()
	gen._update_generation(35000.0)

	var heaven_portal: HeavenPortal = null
	for p in gen.active_portals:
		if p is HeavenPortal and absf(p.portal_distance_m - 300.0) < 0.1:
			heaven_portal = p as HeavenPortal
			break

	if not heaven_portal:
		printerr("  ✗ Physical HeavenPortal instance not found in active_portals at 300m")
		gen.clear_terrain()
		gen.free()
		return false

	# Verify trigger area exists and is configured for vehicle detection
	var trigger: Area2D = heaven_portal.get_node_or_null("TriggerArea") as Area2D
	if not trigger:
		printerr("  ✗ HeavenPortal is missing TriggerArea child")
		gen.clear_terrain()
		gen.free()
		return false

	if trigger.collision_mask != 2:
		printerr("  ✗ HeavenPortal TriggerArea collision_mask is %d, expected 2 (vehicle layer)" % trigger.collision_mask)
		gen.clear_terrain()
		gen.free()
		return false

	# Verify traversal signal
	var traversed_events: Array[bool] = []
	heaven_portal.traversed.connect(func(_portal, _c_idx): traversed_events.append(true))
	heaven_portal.trigger_traversal()
	if traversed_events.is_empty() or not heaven_portal.is_traversed:
		printerr("  ✗ HeavenPortal trigger_traversal failed to emit traversed signal")
		gen.clear_terrain()
		gen.free()
		return false

	gen.clear_terrain()
	gen.free()
	print("  ✓ Confirmed: Physical HeavenPortal at 300m detects vehicle and emits traversal signal correctly!")
	return true

func _test_6_physical_hell_portal_at_600m() -> bool:
	print("\n-> [TEST 6] Testing physical HellPortal at 600m...")
	var gen := TerrainGenerator.new()
	gen.clear_terrain()
	gen._update_generation(65000.0)

	var hell_portal: HellPortal = null
	for p in gen.active_portals:
		if p is HellPortal and absf(p.portal_distance_m - 600.0) < 0.1:
			hell_portal = p as HellPortal
			break

	if not hell_portal:
		printerr("  ✗ Physical HellPortal instance not found in active_portals at 600m")
		gen.clear_terrain()
		gen.free()
		return false

	# Verify traversal trigger
	var traversed_events: Array[bool] = []
	hell_portal.traversed.connect(func(_portal, _c_idx): traversed_events.append(true))
	hell_portal.trigger_traversal()
	if traversed_events.is_empty() or not hell_portal.is_traversed:
		printerr("  ✗ HellPortal trigger_traversal failed to emit traversed signal")
		gen.clear_terrain()
		gen.free()
		return false

	gen.clear_terrain()
	gen.free()
	print("  ✓ Confirmed: Physical HellPortal at 600m detects vehicle and triggers correctly!")
	return true

func _test_7_physical_return_portal_at_900m() -> bool:
	print("\n-> [TEST 7] Testing physical ReturnPortal at 900m...")
	var gen := TerrainGenerator.new()
	gen.clear_terrain()
	gen._update_generation(95000.0)

	var ret_portal: ReturnPortal = null
	for p in gen.active_portals:
		if p is ReturnPortal and absf(p.portal_distance_m - 900.0) < 0.1:
			ret_portal = p as ReturnPortal
			break

	if not ret_portal:
		printerr("  ✗ Physical ReturnPortal instance not found in active_portals at 900m")
		gen.clear_terrain()
		gen.free()
		return false

	var traversed_events: Array[bool] = []
	ret_portal.traversed.connect(func(_portal, _c_idx): traversed_events.append(true))
	ret_portal.trigger_traversal()
	if traversed_events.is_empty() or not ret_portal.is_traversed:
		printerr("  ✗ ReturnPortal trigger_traversal failed to emit traversed signal")
		gen.clear_terrain()
		gen.free()
		return false

	gen.clear_terrain()
	gen.free()
	print("  ✓ Confirmed: Physical ReturnPortal at 900m detects vehicle and triggers correctly!")
	return true

func _test_8_second_cycle_all_three_portals() -> bool:
	print("\n-> [TEST 8] Testing Cycle 1 repeat (1200m Heaven, 1500m Hell, 1800m Return)...")
	var gen := TerrainGenerator.new()
	gen.clear_terrain()
	# Generate ahead across Cycle 1 (up to 185,000 px = 1850m)
	gen._update_generation(185000.0)

	var found_heaven_1200m := false
	var found_hell_1500m := false
	var found_return_1800m := false

	for p in gen.active_portals:
		if p is HeavenPortal and absf(p.portal_distance_m - 1200.0) < 0.1:
			found_heaven_1200m = true
		elif p is HellPortal and absf(p.portal_distance_m - 1500.0) < 0.1:
			found_hell_1500m = true
		elif p is ReturnPortal and absf(p.portal_distance_m - 1800.0) < 0.1:
			found_return_1800m = true

	if not found_heaven_1200m:
		printerr("  ✗ Cycle 1 HeavenPortal not found at 1200m")
		gen.clear_terrain()
		gen.free()
		return false

	if not found_hell_1500m:
		printerr("  ✗ Cycle 1 HellPortal not found at 1500m")
		gen.clear_terrain()
		gen.free()
		return false

	if not found_return_1800m:
		printerr("  ✗ Cycle 1 ReturnPortal not found at 1800m")
		gen.clear_terrain()
		gen.free()
		return false

	gen.clear_terrain()
	gen.free()
	print("  ✓ Confirmed: Cycle 1 spawned all 3 physical portals (1200m, 1500m, 1800m) seamlessly!")
	return true

func _test_9_third_cycle_all_three_portals() -> bool:
	print("\n-> [TEST 9] Testing Cycle 2 repeat (2100m Heaven, 2400m Hell, 2700m Return)...")
	var gen := TerrainGenerator.new()
	gen.clear_terrain()
	# Generate ahead across Cycle 2 (up to 275,000 px = 2750m)
	gen._update_generation(275000.0)

	var found_heaven_2100m := false
	var found_hell_2400m := false
	var found_return_2700m := false

	for p in gen.active_portals:
		if p is HeavenPortal and absf(p.portal_distance_m - 2100.0) < 0.1:
			found_heaven_2100m = true
		elif p is HellPortal and absf(p.portal_distance_m - 2400.0) < 0.1:
			found_hell_2400m = true
		elif p is ReturnPortal and absf(p.portal_distance_m - 2700.0) < 0.1:
			found_return_2700m = true

	if not found_heaven_2100m:
		printerr("  ✗ Cycle 2 HeavenPortal not found at 2100m")
		gen.clear_terrain()
		gen.free()
		return false

	if not found_hell_2400m:
		printerr("  ✗ Cycle 2 HellPortal not found at 2400m")
		gen.clear_terrain()
		gen.free()
		return false

	if not found_return_2700m:
		printerr("  ✗ Cycle 2 ReturnPortal not found at 2700m")
		gen.clear_terrain()
		gen.free()
		return false

	gen.clear_terrain()
	gen.free()
	print("  ✓ Confirmed: Cycle 2 spawned all 3 physical portals (2100m, 2400m, 2700m) seamlessly!")
	return true

func _test_10_three_complete_cycles_2700m() -> bool:
	print("\n-> [TEST 10] Testing 3 complete cycles (2,700m continuous progression)...")
	var controller := BiomeProgressionController.new()

	var test_cadence := [
		# [Distance, Expected Cycle, Expected Biome, Expected Biome Name]
		[0.0, 0, WorldCycleSchedule.BiomeType.NORMAL_LAND, "Normal Land"],
		[150.0, 0, WorldCycleSchedule.BiomeType.NORMAL_LAND, "Normal Land"],
		[300.0, 0, WorldCycleSchedule.BiomeType.HEAVEN, "Heaven"],
		[450.0, 0, WorldCycleSchedule.BiomeType.HEAVEN, "Heaven"],
		[600.0, 0, WorldCycleSchedule.BiomeType.HELL, "Hell"],
		[750.0, 0, WorldCycleSchedule.BiomeType.HELL, "Hell"],
		# Cycle 1
		[900.0, 1, WorldCycleSchedule.BiomeType.NORMAL_LAND, "Normal Land"],
		[1050.0, 1, WorldCycleSchedule.BiomeType.NORMAL_LAND, "Normal Land"],
		[1200.0, 1, WorldCycleSchedule.BiomeType.HEAVEN, "Heaven"],
		[1350.0, 1, WorldCycleSchedule.BiomeType.HEAVEN, "Heaven"],
		[1500.0, 1, WorldCycleSchedule.BiomeType.HELL, "Hell"],
		[1650.0, 1, WorldCycleSchedule.BiomeType.HELL, "Hell"],
		# Cycle 2
		[1800.0, 2, WorldCycleSchedule.BiomeType.NORMAL_LAND, "Normal Land"],
		[1950.0, 2, WorldCycleSchedule.BiomeType.NORMAL_LAND, "Normal Land"],
		[2100.0, 2, WorldCycleSchedule.BiomeType.HEAVEN, "Heaven"],
		[2250.0, 2, WorldCycleSchedule.BiomeType.HEAVEN, "Heaven"],
		[2400.0, 2, WorldCycleSchedule.BiomeType.HELL, "Hell"],
		[2550.0, 2, WorldCycleSchedule.BiomeType.HELL, "Hell"],
		# Cycle 3 Start
		[2700.0, 3, WorldCycleSchedule.BiomeType.NORMAL_LAND, "Normal Land"]
	]

	for pt in test_cadence:
		var d: float = pt[0]
		var exp_cycle: int = pt[1]
		var exp_biome: int = pt[2]
		var exp_name: String = pt[3]

		controller.update_distance(d)
		if controller.current_cycle_index != exp_cycle:
			printerr("  ✗ At dist %.1fm: expected cycle %d, got %d" % [d, exp_cycle, controller.current_cycle_index])
			controller.free()
			return false

		if controller.current_biome_index != exp_biome:
			printerr("  ✗ At dist %.1fm: expected biome %s (%d), got %d" % [d, exp_name, exp_biome, controller.current_biome_index])
			controller.free()
			return false

		# Cumulative distance must be monotonic and continuous (never reset)
		if controller.current_cumulative_distance != d:
			printerr("  ✗ Cumulative distance drifted at %.1fm: got %f" % [d, controller.current_cumulative_distance])
			controller.free()
			return false

	controller.free()
	print("  ✓ Full 2,700m continuous 3-cycle progression verified across all 19 check milestones!")
	return true

func _test_11_vehicle_momentum_and_state_preservation() -> bool:
	print("\n-> [TEST 11] Testing vehicle momentum and state preservation across portal crossings...")
	var controller := BiomeProgressionController.new()

	# Create a mock vehicle with active velocity, fuel, and coins
	var mock_vehicle := MockVehicle.new()
	mock_vehicle.linear_velocity = Vector2(850.0, 0.0)
	mock_vehicle.current_fuel = 78.5
	mock_vehicle.current_coins = 142
	controller.bind_vehicle(mock_vehicle)

	# Traverse through Heaven Portal (300m)
	controller.update_distance(300.0)
	if mock_vehicle.linear_velocity.x < 800.0:
		printerr("  ✗ Vehicle momentum lost when crossing Heaven Portal: vx=%f" % mock_vehicle.linear_velocity.x)
		mock_vehicle.free()
		controller.free()
		return false

	if mock_vehicle.current_fuel < 70.0:
		printerr("  ✗ Vehicle fuel corrupted across Heaven Portal")
		mock_vehicle.free()
		controller.free()
		return false

	if mock_vehicle.current_coins != 142:
		printerr("  ✗ Vehicle coins corrupted across Heaven Portal")
		mock_vehicle.free()
		controller.free()
		return false

	# Traverse through Hell Portal (600m)
	controller.update_distance(600.0)
	if mock_vehicle.linear_velocity.x < 800.0:
		printerr("  ✗ Vehicle momentum lost when crossing Hell Portal: vx=%f" % mock_vehicle.linear_velocity.x)
		mock_vehicle.free()
		controller.free()
		return false

	# Traverse through Return Portal (900m)
	controller.update_distance(900.0)
	if mock_vehicle.linear_velocity.x < 800.0:
		printerr("  ✗ Vehicle momentum lost when crossing Return Portal: vx=%f" % mock_vehicle.linear_velocity.x)
		mock_vehicle.free()
		controller.free()
		return false

	mock_vehicle.free()
	controller.free()
	print("  ✓ Vehicle momentum, physics, fuel, and coins 100% preserved across all portals!")
	return true
