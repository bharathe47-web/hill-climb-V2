@tool
extends SceneTree

## Test suite verifying Phase 4 World-Cycle Configuration and Biome Progression.
## Validates the 5,150m schedule continuity, exact boundary resolution,
## multi-cycle repetition, signal determinism, pause/resume, and reset semantics.

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 4 BIOME PROGRESSION TEST SUITE ---")
	print("=================================================================")

	var passed := true

	passed = _test_schedule_validation() and passed
	passed = _test_boundary_resolution() and passed
	passed = _test_multi_cycle_progression() and passed
	passed = _test_controller_signal_determinism() and passed
	passed = _test_large_distance_jump() and passed
	passed = _test_pause_and_reset_semantics() and passed
	passed = _test_difficulty_scaling_decision() and passed

	if passed:
		print("\n=================================================================")
		print("✓ ALL PHASE 4 TESTS COMPLETED WITH 100% SUCCESS!")
		print("=================================================================")
		quit(0)
	else:
		print("\n=================================================================")
		print("✗ SOME PHASE 4 TESTS FAILED!")
		print("=================================================================")
		quit(1)

func _test_schedule_validation() -> bool:
	print("\n-> [1/7] Testing WorldCycleSchedule validation...")
	var schedule := WorldCycleSchedule.new()
	var val: Dictionary = schedule.validate_schedule()
	if not val["valid"]:
		printerr("  ✗ Default schedule failed validation: ", val["errors"])
		return false

	if schedule.cycle_length_m != 5150.0:
		printerr("  ✗ Cycle length != 5150.0m (got %f)" % schedule.cycle_length_m)
		return false

	if schedule.entries.size() != 8:
		printerr("  ✗ Schedule entry count != 8 (got %d)" % schedule.entries.size())
		return false

	print("  ✓ Schedule validation passed (8 contiguous non-overlapping entries, 5150.0m cycle)!")
	return true

func _test_boundary_resolution() -> bool:
	print("\n-> [2/7] Testing exact boundary resolution (just before, exactly at, and inside)...")
	var schedule := WorldCycleSchedule.new()

	var test_points := [
		# [distance_m, expected_state, expected_is_transition, expected_approx_prog]
		[0.0, WorldCycleSchedule.WorldState.NORMAL_LAND_1, false, 0.0],
		[500.0, WorldCycleSchedule.WorldState.NORMAL_LAND_1, false, 0.0],
		[999.9, WorldCycleSchedule.WorldState.NORMAL_LAND_1, false, 0.0],
		[1000.0, WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HEAVEN, true, 0.0],
		[1075.0, WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HEAVEN, true, 0.5],
		[1149.9, WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HEAVEN, true, 0.9993],
		[1150.0, WorldCycleSchedule.WorldState.HEAVEN, false, 0.0],
		[1675.0, WorldCycleSchedule.WorldState.HEAVEN, false, 0.0],
		[2199.9, WorldCycleSchedule.WorldState.HEAVEN, false, 0.0],
		[2200.0, WorldCycleSchedule.WorldState.TRANSITION_HEAVEN_TO_NORMAL, true, 0.0],
		[2275.0, WorldCycleSchedule.WorldState.TRANSITION_HEAVEN_TO_NORMAL, true, 0.5],
		[2350.0, WorldCycleSchedule.WorldState.NORMAL_LAND_2, false, 0.0],
		[3000.0, WorldCycleSchedule.WorldState.NORMAL_LAND_2, false, 0.0],
		[3499.9, WorldCycleSchedule.WorldState.NORMAL_LAND_2, false, 0.0],
		[3500.0, WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HELL, true, 0.0],
		[3575.0, WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HELL, true, 0.5],
		[3650.0, WorldCycleSchedule.WorldState.HELL, false, 0.0],
		[4325.0, WorldCycleSchedule.WorldState.HELL, false, 0.0],
		[4999.9, WorldCycleSchedule.WorldState.HELL, false, 0.0],
		[5000.0, WorldCycleSchedule.WorldState.TRANSITION_HELL_TO_NORMAL, true, 0.0],
		[5075.0, WorldCycleSchedule.WorldState.TRANSITION_HELL_TO_NORMAL, true, 0.5],
		[5149.9, WorldCycleSchedule.WorldState.TRANSITION_HELL_TO_NORMAL, true, 0.9993]
	]

	for tp in test_points:
		var dist: float = tp[0]
		var exp_state: int = tp[1]
		var exp_trans: bool = tp[2]
		var exp_prog: float = tp[3]

		var res := schedule.resolve_distance(dist)
		if res["state"] != exp_state:
			printerr("  ✗ At dist %f: expected state %d (%s), got %d (%s)" % [
				dist, exp_state, WorldCycleSchedule.get_state_name(exp_state),
				res["state"], res["state_name"]
			])
			return false

		if res["is_transition"] != exp_trans:
			printerr("  ✗ At dist %f: expected is_transition=%s, got %s" % [dist, exp_trans, res["is_transition"]])
			return false

		if exp_trans and not is_equal_approx(res["transition_progress"], exp_prog):
			if absf(res["transition_progress"] - exp_prog) > 0.01:
				printerr("  ✗ At dist %f: expected progress ~%f, got %f" % [dist, exp_prog, res["transition_progress"]])
				return false

	print("  ✓ All 22 boundary and transition test points resolved with exact precision!")
	return true

func _test_multi_cycle_progression() -> bool:
	print("\n-> [3/7] Testing multi-cycle repetition (beyond 5,150m, 10,300m, and 15,450m)...")
	var schedule := WorldCycleSchedule.new()

	# Exactly at 5,150.0m -> cycle 1, distance_in_cycle = 0.0 -> NORMAL_LAND_1
	var r1 := schedule.resolve_distance(5150.0)
	if r1["cycle_index"] != 1 or r1["state"] != WorldCycleSchedule.WorldState.NORMAL_LAND_1:
		printerr("  ✗ At 5150m: expected cycle 1 NORMAL_LAND_1, got cycle %d state %d" % [r1["cycle_index"], r1["state"]])
		return false

	# 6,150.0m -> cycle 1, distance_in_cycle = 1000.0 -> TRANSITION_NORMAL_TO_HEAVEN
	var r2 := schedule.resolve_distance(6150.0)
	if r2["cycle_index"] != 1 or r2["state"] != WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HEAVEN:
		printerr("  ✗ At 6150m: expected cycle 1 TRANSITION_NORMAL_TO_HEAVEN, got cycle %d state %d" % [r2["cycle_index"], r2["state"]])
		return false

	# 8,800.0m -> cycle 1 (5150 + 3650) -> HELL
	var r3 := schedule.resolve_distance(8800.0)
	if r3["cycle_index"] != 1 or r3["state"] != WorldCycleSchedule.WorldState.HELL:
		printerr("  ✗ At 8800m: expected cycle 1 HELL, got cycle %d state %d" % [r3["cycle_index"], r3["state"]])
		return false

	# Exactly at 10,300.0m -> cycle 2, distance_in_cycle = 0.0 -> NORMAL_LAND_1
	var r4 := schedule.resolve_distance(10300.0)
	if r4["cycle_index"] != 2 or r4["state"] != WorldCycleSchedule.WorldState.NORMAL_LAND_1:
		printerr("  ✗ At 10300m: expected cycle 2 NORMAL_LAND_1, got cycle %d state %d" % [r4["cycle_index"], r4["state"]])
		return false

	# 17,000.0m -> cycle 3 (3 * 5150 = 15450, 17000 - 15450 = 1550m) -> HEAVEN (1150-2200m)
	var r5 := schedule.resolve_distance(17000.0)
	if r5["cycle_index"] != 3 or r5["state"] != WorldCycleSchedule.WorldState.HEAVEN:
		printerr("  ✗ At 17000m: expected cycle 3 HEAVEN, got cycle %d state %d" % [r5["cycle_index"], r5["state"]])
		return false

	print("  ✓ Multi-cycle repetition verified across Cycles 0, 1, 2, and 3!")
	return true

func _test_controller_signal_determinism() -> bool:
	print("\n-> [4/7] Testing BiomeProgressionController signal determinism and deduplication...")
	var controller := BiomeProgressionController.new()

	var state_changes: Array[Dictionary] = []
	var cycle_completions: Array[Vector2i] = []
	var transition_updates: Array[float] = []

	controller.state_changed.connect(func(old_st: int, new_st: int, info: Dictionary):
		state_changes.append({"old": old_st, "new": new_st, "info": info})
	)

	controller.cycle_completed.connect(func(old_c: int, new_c: int):
		cycle_completions.append(Vector2i(old_c, new_c))
	)

	controller.transition_progress_updated.connect(func(prog: float, _st: int):
		transition_updates.append(prog)
	)

	# Simulate continuous distance increments
	# 0 -> 500m (inside NORMAL_LAND_1, should not emit state_changed again after init)
	controller.update_distance(100.0)
	controller.update_distance(200.0)
	controller.update_distance(500.0)
	controller.update_distance(999.0)

	var changes_in_normal1 := state_changes.size()
	# Step into transition (1000m)
	controller.update_distance(1000.0)
	if state_changes.size() != changes_in_normal1 + 1:
		printerr("  ✗ Failed to emit state_changed upon entering transition at 1000m")
		controller.free()
		return false

	# Advance inside transition
	controller.update_distance(1050.0)
	controller.update_distance(1100.0)
	if state_changes.size() != changes_in_normal1 + 1:
		printerr("  ✗ Duplicate state_changed fired while advancing within transition")
		controller.free()
		return false

	if transition_updates.size() < 3:
		printerr("  ✗ transition_progress_updated did not fire during transition")
		controller.free()
		return false

	# Step into Heaven (1150m)
	controller.update_distance(1150.0)
	if state_changes.size() != changes_in_normal1 + 2:
		printerr("  ✗ Failed to emit state_changed upon entering Heaven at 1150m")
		controller.free()
		return false

	controller.free()
	print("  ✓ Signal determinism verified (zero duplicate state changes, transitions track smoothly)!")
	return true

func _test_large_distance_jump() -> bool:
	print("\n-> [5/7] Testing large multi-boundary distance jump...")
	var controller := BiomeProgressionController.new()

	var state_events: Array[int] = []
	controller.state_changed.connect(func(_old_st: int, new_st: int, _info: Dictionary):
		state_events.append(new_st)
	)

	controller.update_distance(100.0)
	state_events.clear()

	# Jump from 100m directly to 4200m (across 5 boundary transitions into Hell)
	controller.handle_distance_jump(4200.0)

	if controller.current_state != WorldCycleSchedule.WorldState.HELL:
		printerr("  ✗ After jump to 4200m: expected HELL (%d), got %d" % [
			WorldCycleSchedule.WorldState.HELL, controller.current_state
		])
		controller.free()
		return false

	if state_events.size() != 1 or state_events[0] != WorldCycleSchedule.WorldState.HELL:
		printerr("  ✗ Large jump emitted unexpected events: ", state_events)
		controller.free()
		return false

	controller.free()
	print("  ✓ Large multi-boundary distance jump handled cleanly and deterministically!")
	return true

func _test_pause_and_reset_semantics() -> bool:
	print("\n-> [6/7] Testing pause/resume and run restart semantics...")
	var controller := BiomeProgressionController.new()

	controller.update_distance(1500.0) # In Heaven
	if controller.current_state != WorldCycleSchedule.WorldState.HEAVEN:
		printerr("  ✗ Failed setup to Heaven at 1500m")
		controller.free()
		return false

	# Test pause
	controller.set_paused(true)
	controller.update_distance(2500.0) # Would be Normal Land 2 if not paused
	if controller.current_cumulative_distance != 1500.0 or controller.current_state != WorldCycleSchedule.WorldState.HEAVEN:
		printerr("  ✗ Controller updated while paused!")
		controller.free()
		return false

	# Resume
	controller.set_paused(false)
	controller.update_distance(2500.0)
	if controller.current_state != WorldCycleSchedule.WorldState.NORMAL_LAND_2:
		printerr("  ✗ Controller failed to update after resuming from pause")
		controller.free()
		return false

	# Test reset
	var reset_fired := [false]
	controller.progression_reset.connect(func(): reset_fired[0] = true)
	controller.reset_progression()

	if not reset_fired[0]:
		printerr("  ✗ progression_reset signal was not emitted")
		controller.free()
		return false

	if controller.current_cumulative_distance != 0.0 or controller.current_cycle_index != 0 or controller.current_state != WorldCycleSchedule.WorldState.NORMAL_LAND_1:
		printerr("  ✗ Reset state incomplete: dist=%f cycle=%d state=%d" % [
			controller.current_cumulative_distance, controller.current_cycle_index, controller.current_state
		])
		controller.free()
		return false

	controller.free()
	print("  ✓ Pause/resume and reset semantics verified!")
	return true

func _test_difficulty_scaling_decision() -> bool:
	print("\n-> [7/7] Verifying cycle difficulty scaling analysis...")
	var controller := BiomeProgressionController.new()

	# By default, cycle difficulty scaling must be disabled to respect TerrainGenerator's clamp
	if controller.enable_cycle_difficulty_scaling != false:
		printerr("  ✗ enable_cycle_difficulty_scaling should default to false")
		controller.free()
		return false

	if controller.get_cycle_difficulty_multiplier(0) != 1.0:
		printerr("  ✗ Default multiplier should be 1.0")
		controller.free()
		return false

	# When enabled, it calculates +0.15 per cycle
	controller.enable_cycle_difficulty_scaling = true
	var mult0 := controller.get_cycle_difficulty_multiplier(0)
	var mult1 := controller.get_cycle_difficulty_multiplier(1)
	var mult2 := controller.get_cycle_difficulty_multiplier(2)

	if not is_equal_approx(mult0, 1.0) or not is_equal_approx(mult1, 1.15) or not is_equal_approx(mult2, 1.30):
		printerr("  ✗ Cycle difficulty formula error: [c0: %f, c1: %f, c2: %f]" % [mult0, mult1, mult2])
		controller.free()
		return false

	controller.free()
	print("  ✓ Difficulty scaling formula verified and safely default-disabled!")
	return true
