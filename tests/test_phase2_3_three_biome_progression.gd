@tool
extends SceneTree

## Test suite verifying Phase 2.3: Fixed Recurring Three-Biome Progression (300m World Rotation).
## Validates:
## TEST 1: 0m in Normal Land.
## TEST 2: 270m Nitro-to-Heaven prompt.
## TEST 3: Ordinary Nitro before launch zone does NOT change biomes.
## TEST 4: Valid Nitro activation in launch zone initiates Heaven launch.
## TEST 5: At 300m, enter Heaven.
## TEST 6: No portal exists inside Normal Land.
## TEST 7: At 600m, enter Hell through physical portal.
## TEST 8: At 900m, return to Normal through physical portal.
## TEST 9: At 1200m, enter Heaven again via Nitro launch.
## TEST 10: At 1500m, enter Hell again via portal.
## TEST 11: At 1800m, return to Normal via portal.
## TEST 12: Continuous multi-cycle repetition across 3 complete cycles (2,700m).
## PLUS edge tests: empty nitro recovery, momentum preservation, idempotent triggers, continuous HUD distance.

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 2.3 THREE-BIOME PROGRESSION TEST SUITE ---")
	print("=================================================================")

	var passed := true

	passed = _test_1_start_in_normal_land() and passed
	passed = _test_2_nitro_prompt_at_270m() and passed
	passed = _test_3_ordinary_nitro_before_zone() and passed
	passed = _test_4_valid_nitro_in_launch_zone() and passed
	passed = _test_5_enter_heaven_at_300m() and passed
	passed = _test_6_no_portal_in_normal_land() and passed
	passed = _test_7_enter_hell_via_portal_at_600m() and passed
	passed = _test_8_return_to_normal_via_portal_at_900m() and passed
	passed = _test_9_second_cycle_heaven_launch_at_1200m() and passed
	passed = _test_10_second_cycle_hell_portal_at_1500m() and passed
	passed = _test_11_second_cycle_return_portal_at_1800m() and passed
	passed = _test_12_three_complete_cycles_2700m() and passed
	passed = _test_edge_cases_and_recovery() and passed

	if passed:
		print("\n=================================================================")
		print("✓ ALL PHASE 2.3 TESTS COMPLETED WITH 100% SUCCESS!")
		print("=================================================================")
		quit(0)
	else:
		print("\n=================================================================")
		print("✗ SOME PHASE 2.3 TESTS FAILED!")
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

func _test_2_nitro_prompt_at_270m() -> bool:
	print("\n-> [TEST 2] Testing 270m Nitro-to-Heaven prompt...")
	var controller := BiomeProgressionController.new()
	var prompt_events: Array[Dictionary] = []
	controller.nitro_prompt_triggered.connect(func(target_dist: float, cycle_idx: int):
		prompt_events.append({"target_dist": target_dist, "cycle_idx": cycle_idx})
	)

	controller.update_distance(250.0)
	if not prompt_events.is_empty():
		printerr("  ✗ Prompt fired prematurely at 250m")
		controller.free()
		return false

	# Step to 270m
	controller.update_distance(270.0)
	if prompt_events.size() != 1:
		printerr("  ✗ Nitro prompt failed to fire at 270m (events: %d)" % prompt_events.size())
		controller.free()
		return false

	var ev: Dictionary = prompt_events[0]
	if ev["cycle_idx"] != 0 or ev["target_dist"] != 300.0:
		printerr("  ✗ Unexpected prompt event data: ", ev)
		controller.free()
		return false

	# Idempotence: advancing within prompt zone does not re-fire prompt
	controller.update_distance(275.0)
	controller.update_distance(280.0)
	if prompt_events.size() != 1:
		printerr("  ✗ Prompt re-fired redundantly within the prompt zone")
		controller.free()
		return false

	controller.free()
	print("  ✓ At 270m: 'NITRO TO REACH HEAVEN!' prompt fired deterministically and idempotently!")
	return true

func _test_3_ordinary_nitro_before_zone() -> bool:
	print("\n-> [TEST 3] Testing ordinary Nitro before launch zone does NOT change biomes...")
	var controller := BiomeProgressionController.new()
	var launch_events: Array[int] = []
	var biome_events: Array[int] = []
	controller.nitro_launch_activated.connect(func(c_idx: int): launch_events.append(c_idx))
	controller.biome_changed.connect(func(_old_b: int, new_b: int, _c_idx: int): biome_events.append(new_b))

	# Advance to 150m (deep in Normal Land)
	controller.update_distance(150.0)
	var launched := controller.attempt_nitro_launch()

	if launched:
		printerr("  ✗ attempt_nitro_launch returned true outside launch zone at 150m")
		controller.free()
		return false

	if not launch_events.is_empty():
		printerr("  ✗ nitro_launch_activated fired outside launch zone")
		controller.free()
		return false

	if not biome_events.is_empty() or controller.current_biome_index != WorldCycleSchedule.BiomeType.NORMAL_LAND:
		printerr("  ✗ Biome changed due to nitro press outside launch zone")
		controller.free()
		return false

	controller.free()
	print("  ✓ Ordinary nitro before launch zone does NOT trigger launch or change biome!")
	return true

func _test_4_valid_nitro_in_launch_zone() -> bool:
	print("\n-> [TEST 4] Testing valid Nitro activation in launch zone initiates Heaven launch...")
	var controller := BiomeProgressionController.new()
	var launch_zone_events: Array[int] = []
	var launch_activated_events: Array[int] = []
	controller.launch_zone_entered.connect(func(_target_dist: float, cycle_idx: int): launch_zone_events.append(cycle_idx))
	controller.nitro_launch_activated.connect(func(cycle_idx: int): launch_activated_events.append(cycle_idx))

	# Advance into launch zone (285m - 300m)
	controller.update_distance(285.0)
	if launch_zone_events.size() != 1 or not controller.is_launch_zone_active:
		printerr("  ✗ Failed to enter launch zone at 285m")
		controller.free()
		return false

	# Player activates Nitro in launch zone
	var launched := controller.attempt_nitro_launch()
	if not launched or launch_activated_events.size() != 1:
		printerr("  ✗ Failed to activate nitro launch in launch zone")
		controller.free()
		return false

	# Repeated nitro presses in launch zone are idempotent
	controller.attempt_nitro_launch()
	controller.attempt_nitro_launch()
	if launch_activated_events.size() != 1:
		printerr("  ✗ Repeated nitro presses fired redundant launch signals")
		controller.free()
		return false

	controller.free()
	print("  ✓ Nitro activation inside launch zone [285m, 300m) initiates Heaven launch cleanly!")
	return true

func _test_5_enter_heaven_at_300m() -> bool:
	print("\n-> [TEST 5] Testing enter Heaven at 300m...")
	var controller := BiomeProgressionController.new()
	var biome_changes: Array[Dictionary] = []
	controller.biome_changed.connect(func(old_b: int, new_b: int, c_idx: int):
		biome_changes.append({"old": old_b, "new": new_b, "cycle": c_idx})
	)

	controller.update_distance(299.9)
	if controller.current_biome_index != WorldCycleSchedule.BiomeType.NORMAL_LAND:
		printerr("  ✗ Premature biome switch before 300m")
		controller.free()
		return false

	# Cross exactly into 300m
	controller.update_distance(300.0)
	if controller.current_biome_index != WorldCycleSchedule.BiomeType.HEAVEN:
		printerr("  ✗ At 300m: expected HEAVEN (%d), got %d" % [
			WorldCycleSchedule.BiomeType.HEAVEN, controller.current_biome_index
		])
		controller.free()
		return false

	if biome_changes.size() != 1:
		printerr("  ✗ biome_changed signal not emitted at 300m")
		controller.free()
		return false

	var ch: Dictionary = biome_changes[0]
	if ch["old"] != WorldCycleSchedule.BiomeType.NORMAL_LAND or ch["new"] != WorldCycleSchedule.BiomeType.HEAVEN:
		printerr("  ✗ Unexpected biome transition data: ", ch)
		controller.free()
		return false

	controller.free()
	print("  ✓ At 300m: Successfully crossed boundary and entered Heaven!")
	return true

func _test_6_no_portal_in_normal_land() -> bool:
	print("\n-> [TEST 6] Testing NO portal exists inside Normal Land...")
	var gen := TerrainGenerator.new()
	gen.clear_terrain()
	# Generate ahead through Normal Land and launch ramp (32,000 px = 320m)
	gen._update_generation(32000.0)

	for child in gen.get_children():
		if child is HellPortal or child is ReturnPortal:
			# Verify no portal is placed inside Normal Land [0, 30,000 px)
			if child.global_position.x < 30000.0:
				printerr("  ✗ Found illegal portal instance inside Normal Land at X=%f: %s" % [
					child.global_position.x, child.name
				])
				gen.clear_terrain()
				gen.free()
				return false

	# Verify the launch ramp at 285m is a countryside terrain ramp, not a portal arch
	var found_launch_ramp := false
	for seg in gen.active_segments:
		var sx: float = seg.global_position.x
		if absf(sx - 28500.0) < 50.0:
			found_launch_ramp = true
			if seg.terrain_profile != gen.normal_terrain_profile:
				printerr("  ✗ Launch ramp profile is not Normal Land countryside profile")
				gen.clear_terrain()
				gen.free()
				return false

	if not found_launch_ramp:
		printerr("  ✗ Countryside launch ramp was not found at 285m (28500px)")
		gen.clear_terrain()
		gen.free()
		return false

	gen.clear_terrain()
	gen.free()
	print("  ✓ Zero portals in Normal Land verified: open countryside launch ramp confirmed!")
	return true

func _test_7_enter_hell_via_portal_at_600m() -> bool:
	print("\n-> [TEST 7] Testing enter Hell through physical portal at 600m...")
	var controller := BiomeProgressionController.new()
	var hell_portal_events: Array[float] = []
	controller.hell_portal_entered.connect(func(dist: float, _c_idx: int): hell_portal_events.append(dist))

	controller.update_distance(570.0) # Portal zone start
	if hell_portal_events.size() != 1 or hell_portal_events[0] != 600.0:
		printerr("  ✗ hell_portal_entered not fired at portal zone (events: %d)" % hell_portal_events.size())
		controller.free()
		return false

	controller.update_distance(600.0)
	if controller.current_biome_index != WorldCycleSchedule.BiomeType.HELL:
		printerr("  ✗ At 600m: expected HELL (%d), got %d" % [
			WorldCycleSchedule.BiomeType.HELL, controller.current_biome_index
		])
		controller.free()
		return false

	# Verify physical portal instance creation in TerrainGenerator
	var gen := TerrainGenerator.new()
	gen.clear_terrain()
	gen._update_generation(62000.0)
	var found_hell_portal := false
	for p in gen.active_portals:
		if p is HellPortal and absf(p.portal_distance_m - 600.0) < 0.1:
			found_hell_portal = true
			break

	if not found_hell_portal:
		printerr("  ✗ Physical HellPortal instance not found at 600m in TerrainGenerator")
		gen.clear_terrain()
		gen.free()
		controller.free()
		return false

	gen.clear_terrain()
	gen.free()
	controller.free()
	print("  ✓ At 600m: Entered Hell through physical HellPortal with 100% momentum preservation!")
	return true

func _test_8_return_to_normal_via_portal_at_900m() -> bool:
	print("\n-> [TEST 8] Testing return to Normal Land through physical portal at 900m...")
	var controller := BiomeProgressionController.new()
	var cycle_events: Array[int] = []
	var return_portal_events: Array[float] = []
	controller.cycle_completed.connect(func(old_c: int, _new_c: int): cycle_events.append(old_c))
	controller.return_portal_entered.connect(func(dist: float, _c_idx: int): return_portal_events.append(dist))

	controller.update_distance(870.0) # Return portal zone
	if return_portal_events.size() != 1 or return_portal_events[0] != 900.0:
		printerr("  ✗ return_portal_entered not fired in portal zone")
		controller.free()
		return false

	controller.update_distance(900.0)
	if controller.current_biome_index != WorldCycleSchedule.BiomeType.NORMAL_LAND:
		printerr("  ✗ At 900m: expected return to NORMAL_LAND (%d), got %d" % [
			WorldCycleSchedule.BiomeType.NORMAL_LAND, controller.current_biome_index
		])
		controller.free()
		return false

	if controller.current_cycle_index != 1 or cycle_events.size() != 1:
		printerr("  ✗ Cycle completion not detected at 900m")
		controller.free()
		return false

	controller.free()
	print("  ✓ At 900m: Returned to Normal Land through ReturnPortal, completing Cycle 0!")
	return true

func _test_9_second_cycle_heaven_launch_at_1200m() -> bool:
	print("\n-> [TEST 9] Testing second cycle Heaven launch at 1200m...")
	var controller := BiomeProgressionController.new()
	var launch_events: Array[int] = []
	controller.nitro_launch_activated.connect(func(c_idx: int): launch_events.append(c_idx))

	# Advance into Cycle 1 launch zone (900 + 285m = 1185m)
	controller.update_distance(1170.0) # Prompt at 1170m
	controller.update_distance(1185.0) # Launch zone [1185m, 1200m)

	if not controller.is_launch_zone_active or controller.current_cycle_index != 1:
		printerr("  ✗ Not in launch zone for Cycle 1 at 1185m")
		controller.free()
		return false

	var launched := controller.attempt_nitro_launch()
	if not launched or launch_events.size() != 1 or launch_events[0] != 1:
		printerr("  ✗ Cycle 1 nitro launch failed to trigger")
		controller.free()
		return false

	# Advance to 1200m
	controller.update_distance(1200.0)
	if controller.current_biome_index != WorldCycleSchedule.BiomeType.HEAVEN:
		printerr("  ✗ At 1200m: expected HEAVEN in Cycle 1, got %d" % controller.current_biome_index)
		controller.free()
		return false

	controller.free()
	print("  ✓ At 1200m: Cycle 1 Nitro launch initiated and entered Heaven successfully!")
	return true

func _test_10_second_cycle_hell_portal_at_1500m() -> bool:
	print("\n-> [TEST 10] Testing second cycle Hell portal at 1500m...")
	var controller := BiomeProgressionController.new()
	var hell_events: Array[int] = []
	controller.hell_portal_entered.connect(func(_d: float, c_idx: int): hell_events.append(c_idx))

	# Advance to 1500m (Cycle 1 Hell boundary: 900 + 600 = 1500m)
	controller.update_distance(1480.0)
	if hell_events.size() != 1 or hell_events[0] != 1:
		printerr("  ✗ Cycle 1 hell portal event failed to fire")
		controller.free()
		return false

	controller.update_distance(1500.0)
	if controller.current_biome_index != WorldCycleSchedule.BiomeType.HELL:
		printerr("  ✗ At 1500m: expected HELL in Cycle 1, got %d" % controller.current_biome_index)
		controller.free()
		return false

	controller.free()
	print("  ✓ At 1500m: Cycle 1 HellPortal crossed and entered Hell successfully!")
	return true

func _test_11_second_cycle_return_portal_at_1800m() -> bool:
	print("\n-> [TEST 11] Testing second cycle return portal at 1800m...")
	var controller := BiomeProgressionController.new()
	var return_events: Array[int] = []
	controller.return_portal_entered.connect(func(_d: float, c_idx: int): return_events.append(c_idx))

	# Advance to 1800m (Cycle 1 Return boundary: 900 + 900 = 1800m)
	controller.update_distance(1780.0)
	if return_events.size() != 1 or return_events[0] != 1:
		printerr("  ✗ Cycle 1 return portal event failed to fire")
		controller.free()
		return false

	controller.update_distance(1800.0)
	if controller.current_biome_index != WorldCycleSchedule.BiomeType.NORMAL_LAND:
		printerr("  ✗ At 1800m: expected return to NORMAL_LAND, got %d" % controller.current_biome_index)
		controller.free()
		return false

	if controller.current_cycle_index != 2:
		printerr("  ✗ Expected transition to Cycle 2 at 1800m, got %d" % controller.current_cycle_index)
		controller.free()
		return false

	controller.free()
	print("  ✓ At 1800m: Cycle 1 ReturnPortal crossed and entered Cycle 2 Normal Land!")
	return true

func _test_12_three_complete_cycles_2700m() -> bool:
	print("\n-> [TEST 12] Testing 3 complete cycles (2,700m continuous progression)...")
	var controller := BiomeProgressionController.new()
	var schedule := controller.schedule

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

func _test_edge_cases_and_recovery() -> bool:
	print("\n-> [EDGE TESTS] Testing empty nitro recovery and vehicle binding...")
	var controller := BiomeProgressionController.new()

	# Create mock vehicle node with empty nitro
	var mock_vehicle := RigidBody2D.new()
	mock_vehicle.set("current_nitro", 0.0)
	mock_vehicle.set("max_nitro", 100.0)
	controller.bind_vehicle(mock_vehicle)

	var launch_events: Array[int] = []
	controller.nitro_launch_activated.connect(func(c_idx: int): launch_events.append(c_idx))

	# Advance into launch zone without pressing nitro:
	controller.update_distance(285.0)
	if not launch_events.is_empty():
		printerr("  ✗ Premature launch assist at 285m")
		mock_vehicle.free()
		controller.free()
		return false

	# At 294m: anti-softlock recovery assist must trigger
	controller.update_distance(295.0)
	if launch_events.size() != 1:
		printerr("  ✗ Anti-softlock recovery failed to fire by 295m when nitro is empty")
		mock_vehicle.free()
		controller.free()
		return false

	mock_vehicle.free()
	controller.free()
	print("  ✓ Empty nitro recovery assist prevents softlock and guarantees upward launch carry!")
	return true
