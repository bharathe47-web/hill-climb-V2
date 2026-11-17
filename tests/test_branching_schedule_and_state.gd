extends SceneTree

## Unit & Integration Test Suite for Phase 1: Branch Schedule and State-Machine
## Verifies 500m Normal / 500m Realm cadence, route gates at 500m + (n * 1000m),
## idempotent route confirmation, automatic Hell fallback, shared Normal Land merge,
## multi-encounter progression across 5+ encounters (0 - 5,000m), and clean pause/restart.

var failures: Array[String] = []
var pass_count: int = 0

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 1 BRANCHING SCHEDULE & STATE-MACHINE TEST SUITE ---")
	print("=================================================================\n")

	test_1_schedule_configuration_and_validation()
	test_2_encounter_state_cadence_resolution()
	test_3_missed_launch_fallback_to_hell()
	test_4_idempotent_resolution_and_deduplication()
	test_5_multi_encounter_progression_five_cycles()
	test_6_pause_resume_and_restart_semantics()
	test_7_environment_host_branching_coupling()

	print("\n=================================================================")
	if failures.is_empty():
		print("✓ ALL PHASE 1 TESTS COMPLETED WITH 100%% SUCCESS (%d checks passed)!" % pass_count)
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
# Test 1: Schedule Configuration & Parameter Validation
# ---------------------------------------------------------------------------
func test_1_schedule_configuration_and_validation() -> void:
	print("-> [1/7] Testing WorldCycleSchedule branching configuration and validation...")

	var sched := WorldCycleSchedule.new()
	sched.init_branching_schedule()

	assert_eq(sched.schedule_mode, WorldCycleSchedule.ScheduleMode.BRANCHING_1000M, "Schedule mode must be BRANCHING_1000M")
	assert_approx_eq(sched.normal_section_length_m, 500.0, 0.001, "Normal section length must be 500m")
	assert_approx_eq(sched.realm_section_length_m, 500.0, 0.001, "Realm section length must be 500m")
	assert_approx_eq(sched.encounter_cycle_length_m, 1000.0, 0.001, "Encounter cycle length must be 1000m")
	assert_approx_eq(sched.first_gate_distance_m, 500.0, 0.001, "First gate distance must be 500m")
	assert_approx_eq(sched.warning_distance_m, 50.0, 0.001, "Warning distance must be 50m")
	assert_approx_eq(sched.launch_window_distance_m, 25.0, 0.001, "Launch window distance must be 25m")
	assert_approx_eq(sched.transition_blend_distance_m, 50.0, 0.001, "Transition blend distance must be 50m")

	# Validate gate positions for first 5 encounters
	for i in range(5):
		var expected_gate := 500.0 + (float(i) * 1000.0)
		var actual_gate := sched.get_gate_distance_for_encounter(i)
		assert_approx_eq(actual_gate, expected_gate, 0.001, "Encounter %d gate distance must be %fm" % [i, expected_gate])

	var val := sched.validate_branching_schedule()
	assert_true(val["valid"], "Default branching schedule must pass validation")

	# Test invalid configuration detection
	var bad_sched := WorldCycleSchedule.new()
	bad_sched.init_branching_schedule()
	bad_sched.encounter_cycle_length_m = 1200.0 # does not match 500 + 500
	var bad_val := bad_sched.validate_branching_schedule()
	assert_true(not bad_val["valid"], "Validation must reject mismatched encounter cycle length")

	print("  ✓ Schedule branching configuration, gate spacing, and validation rules verified!")

# ---------------------------------------------------------------------------
# Test 2: Encounter State Cadence Resolution (Exact Boundaries)
# ---------------------------------------------------------------------------
func test_2_encounter_state_cadence_resolution() -> void:
	print("-> [2/7] Testing encounter state cadence resolution and exact boundary rules...")

	var sched := WorldCycleSchedule.new()
	sched.init_branching_schedule()

	# Zone A: Normal Approach [0, 450m)
	var res_0 := sched.resolve_branching_encounter(0.0)
	assert_eq(res_0["state"], WorldCycleSchedule.WorldState.NORMAL_APPROACH, "0m must resolve to NORMAL_APPROACH")
	assert_eq(res_0["active_biome"], WorldCycleSchedule.BiomeType.NORMAL_LAND, "0m active biome must be NORMAL_LAND")
	assert_true(not res_0["is_transition"], "0m is not a transition")

	var res_250 := sched.resolve_branching_encounter(250.0)
	assert_eq(res_250["state"], WorldCycleSchedule.WorldState.NORMAL_APPROACH, "250m must resolve to NORMAL_APPROACH")

	var res_449 := sched.resolve_branching_encounter(449.9)
	assert_eq(res_449["state"], WorldCycleSchedule.WorldState.NORMAL_APPROACH, "449.9m must resolve to NORMAL_APPROACH")

	# Zone B: Ramp Warning [450m, 475m)
	var res_450 := sched.resolve_branching_encounter(450.0)
	assert_eq(res_450["state"], WorldCycleSchedule.WorldState.RAMP_WARNING, "450.0m must resolve to RAMP_WARNING")
	assert_eq(res_450["active_biome"], WorldCycleSchedule.BiomeType.NORMAL_LAND, "450.0m active biome must be NORMAL_LAND")

	var res_474 := sched.resolve_branching_encounter(474.9)
	assert_eq(res_474["state"], WorldCycleSchedule.WorldState.RAMP_WARNING, "474.9m must resolve to RAMP_WARNING")

	# Zone C: Launch Window [475m, 500m)
	var res_475 := sched.resolve_branching_encounter(475.0)
	assert_eq(res_475["state"], WorldCycleSchedule.WorldState.LAUNCH_WINDOW, "475.0m must resolve to LAUNCH_WINDOW")
	assert_approx_eq(res_475["transition_progress"], 0.0, 0.01, "475.0m launch window progress starts at 0.0")

	var res_487 := sched.resolve_branching_encounter(487.5)
	assert_eq(res_487["state"], WorldCycleSchedule.WorldState.LAUNCH_WINDOW, "487.5m must resolve to LAUNCH_WINDOW")
	assert_approx_eq(res_487["transition_progress"], 0.5, 0.01, "487.5m launch window progress must be 0.5")

	var res_499 := sched.resolve_branching_encounter(499.9)
	assert_eq(res_499["state"], WorldCycleSchedule.WorldState.LAUNCH_WINDOW, "499.9m must resolve to LAUNCH_WINDOW")

	# Zone D: Gate Crossing with Confirmed HEAVEN
	var res_500_h := sched.resolve_branching_encounter(500.0, WorldCycleSchedule.BiomeType.HEAVEN)
	assert_eq(res_500_h["state"], WorldCycleSchedule.WorldState.HEAVEN_ENTRY, "500.0m with Heaven confirmed must resolve to HEAVEN_ENTRY")
	assert_eq(res_500_h["active_biome"], WorldCycleSchedule.BiomeType.HEAVEN, "500.0m active biome must be HEAVEN")
	assert_true(res_500_h["is_transition"], "500.0m HEAVEN_ENTRY is a transition")
	assert_approx_eq(res_500_h["transition_progress"], 0.0, 0.01, "500.0m entry blend progress starts at 0.0")

	var res_525_h := sched.resolve_branching_encounter(525.0, WorldCycleSchedule.BiomeType.HEAVEN)
	assert_eq(res_525_h["state"], WorldCycleSchedule.WorldState.HEAVEN_ENTRY, "525.0m must be HEAVEN_ENTRY")
	assert_approx_eq(res_525_h["transition_progress"], 0.5, 0.01, "525.0m entry blend progress must be 0.5")

	# Zone E: Heaven Active Route [550m, 950m)
	var res_550_h := sched.resolve_branching_encounter(550.0, WorldCycleSchedule.BiomeType.HEAVEN)
	assert_eq(res_550_h["state"], WorldCycleSchedule.WorldState.HEAVEN_ACTIVE, "550.0m must resolve to HEAVEN_ACTIVE")
	assert_true(not res_550_h["is_transition"], "550.0m HEAVEN_ACTIVE is sustained driving, not transition")

	var res_750_h := sched.resolve_branching_encounter(750.0, WorldCycleSchedule.BiomeType.HEAVEN)
	assert_eq(res_750_h["state"], WorldCycleSchedule.WorldState.HEAVEN_ACTIVE, "750.0m must resolve to HEAVEN_ACTIVE")
	assert_eq(res_750_h["profile_key"], "heaven_core", "750.0m profile key must be heaven_core")

	# Zone F: Exit Transition [950m, 1000m)
	var res_950_h := sched.resolve_branching_encounter(950.0, WorldCycleSchedule.BiomeType.HEAVEN)
	assert_eq(res_950_h["state"], WorldCycleSchedule.WorldState.EXIT_TRANSITION, "950.0m must resolve to EXIT_TRANSITION")
	assert_true(res_950_h["is_transition"], "950.0m EXIT_TRANSITION is a transition")
	assert_eq(res_950_h["from_biome"], WorldCycleSchedule.BiomeType.HEAVEN, "from_biome must be HEAVEN")
	assert_eq(res_950_h["to_biome"], WorldCycleSchedule.BiomeType.NORMAL_LAND, "to_biome must be NORMAL_LAND")
	assert_approx_eq(res_950_h["transition_progress"], 0.0, 0.01, "950.0m exit blend progress starts at 0.0")

	var res_975_h := sched.resolve_branching_encounter(975.0, WorldCycleSchedule.BiomeType.HEAVEN)
	assert_approx_eq(res_975_h["transition_progress"], 0.5, 0.01, "975.0m exit blend progress must be 0.5")

	# Zone G: Normal Merge at 1000m (Encounter 1 start)
	var res_1000 := sched.resolve_branching_encounter(1000.0)
	assert_eq(res_1000["encounter_index"], 1, "1000.0m must be in Encounter 1")
	assert_eq(res_1000["state"], WorldCycleSchedule.WorldState.NORMAL_APPROACH, "1000.0m must return to NORMAL_APPROACH")
	assert_eq(res_1000["active_biome"], WorldCycleSchedule.BiomeType.NORMAL_LAND, "1000.0m active biome must be NORMAL_LAND")

	print("  ✓ Exact encounter intervals and half-open boundaries verified!")

# ---------------------------------------------------------------------------
# Test 3: Missed Launch / No Nitro Fallback to Hell
# ---------------------------------------------------------------------------
func test_3_missed_launch_fallback_to_hell() -> void:
	print("-> [3/7] Testing missed launch and unconfirmed fallback to Hell...")

	var sched := WorldCycleSchedule.new()
	sched.init_branching_schedule()

	# Without confirming Heaven (e.g. unconfirmed -1 or failed launch):
	var res_500_fail := sched.resolve_branching_encounter(500.0, -1)
	assert_eq(res_500_fail["state"], WorldCycleSchedule.WorldState.HELL_ENTRY, "Unconfirmed gate crossing must fall back to HELL_ENTRY")
	assert_eq(res_500_fail["active_biome"], WorldCycleSchedule.BiomeType.HELL, "Active biome must fall back to HELL")
	assert_eq(res_500_fail["profile_key"], "ramp_normal_to_hell", "Profile key must be ramp_normal_to_hell")

	var res_600_fail := sched.resolve_branching_encounter(600.0, -1)
	assert_eq(res_600_fail["state"], WorldCycleSchedule.WorldState.HELL_ACTIVE, "600m must be in HELL_ACTIVE")
	assert_eq(res_600_fail["profile_key"], "hell_core", "Profile key must be hell_core")

	var res_960_fail := sched.resolve_branching_encounter(960.0, -1)
	assert_eq(res_960_fail["state"], WorldCycleSchedule.WorldState.EXIT_TRANSITION, "960m must be EXIT_TRANSITION")
	assert_eq(res_960_fail["from_biome"], WorldCycleSchedule.BiomeType.HELL, "from_biome must be HELL")
	assert_eq(res_960_fail["to_biome"], WorldCycleSchedule.BiomeType.NORMAL_LAND, "to_biome must be NORMAL_LAND")
	assert_eq(res_960_fail["profile_key"], "ramp_hell_to_normal", "Profile key must be ramp_hell_to_normal")

	# Test automatic fallback in BiomeProgressionController
	var ctrl := BiomeProgressionController.new()
	ctrl.enable_branching_mode(true)

	var confirmed_event := {"realm": -1, "encounter": -1}
	ctrl.branch_confirmed.connect(func(realm: int, enc: int) -> void:
		confirmed_event["realm"] = realm
		confirmed_event["encounter"] = enc
	)

	# Drive from 0 to 490m (no confirmation)
	ctrl.update_distance(490.0)
	assert_eq(confirmed_event["realm"], -1, "No branch confirmed before gate")

	# Cross gate at 500m without calling confirm_route
	ctrl.update_distance(500.0)
	assert_eq(confirmed_event["realm"], WorldCycleSchedule.BiomeType.HELL, "Crossing gate unconfirmed must trigger Hell branch_confirmed")
	assert_eq(confirmed_event["encounter"], 0, "Confirmed encounter must be 0")
	assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.HELL_ENTRY, "Controller state must be HELL_ENTRY")

	ctrl.free()
	print("  ✓ Automatic safe fallback to Hell verified!")

# ---------------------------------------------------------------------------
# Test 4: Idempotent Resolution & Deduplication
# ---------------------------------------------------------------------------
func test_4_idempotent_resolution_and_deduplication() -> void:
	print("-> [4/7] Testing idempotent gate resolution and signal deduplication...")

	var ctrl := BiomeProgressionController.new()
	ctrl.enable_branching_mode(true)

	var signal_counts := {
		"warning": 0,
		"launch": 0,
		"branch": 0,
		"merge": 0
	}

	ctrl.ramp_warning_triggered.connect(func(_g: float, _e: int) -> void: signal_counts["warning"] += 1)
	ctrl.launch_window_entered.connect(func(_g: float, _e: int) -> void: signal_counts["launch"] += 1)
	ctrl.branch_confirmed.connect(func(_r: int, _e: int) -> void: signal_counts["branch"] += 1)
	ctrl.route_merge_completed.connect(func(_e: int) -> void: signal_counts["merge"] += 1)

	# Simulate fine-grained distance steps through warning and launch zone
	for d in range(400, 480):
		ctrl.update_distance(float(d))

	assert_eq(signal_counts["warning"], 1, "Ramp warning signal must fire exactly once per encounter")
	assert_eq(signal_counts["launch"], 1, "Launch window signal must fire exactly once per encounter")

	# Confirm Heaven route in launch window
	var first_confirm := ctrl.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	assert_true(first_confirm, "First confirm_route must return true")
	assert_eq(signal_counts["branch"], 1, "branch_confirmed signal fired once")

	# Duplicate confirmation calls must be rejected
	var dup_confirm := ctrl.confirm_route(WorldCycleSchedule.BiomeType.HELL, 0)
	assert_true(not dup_confirm, "Duplicate confirm_route must return false")
	assert_eq(signal_counts["branch"], 1, "branch_confirmed signal must NOT fire on duplicate")

	var dup2 := ctrl.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	assert_true(not dup2, "Third confirm_route must also return false")
	assert_eq(ctrl.confirmed_realms[0], WorldCycleSchedule.BiomeType.HEAVEN, "Recorded realm must remain HEAVEN")

	# Drive through gate to 1000m
	for d in range(480, 1001, 10):
		ctrl.update_distance(float(d))

	assert_eq(signal_counts["merge"], 1, "route_merge_completed must fire once when reaching 1000m merge")

	ctrl.free()
	print("  ✓ Idempotent one-shot resolution and signal deduplication verified!")

# ---------------------------------------------------------------------------
# Test 5: Multi-Encounter Progression Across 5+ Encounters (0 - 5,000m)
# ---------------------------------------------------------------------------
func test_5_multi_encounter_progression_five_cycles() -> void:
	print("-> [5/7] Testing multi-encounter progression across 5 encounters (0m to 5,000m)...")

	var ctrl := BiomeProgressionController.new()
	ctrl.enable_branching_mode(true)

	var recorded_states: Array[int] = []
	var recorded_branches: Array[Dictionary] = []
	var completed_merges: Array[int] = []

	ctrl.state_changed.connect(func(_old: int, new_st: int, _info: Dictionary) -> void:
		recorded_states.append(new_st)
	)
	ctrl.branch_confirmed.connect(func(realm: int, enc: int) -> void:
		recorded_branches.append({"encounter": enc, "realm": realm})
	)
	ctrl.route_merge_completed.connect(func(enc: int) -> void:
		completed_merges.append(enc)
	)

	# Planned encounter outcomes:
	# Enc 0 (0-1000m): Boost launch -> HEAVEN
	# Enc 1 (1000-2000m): Missed launch -> HELL (auto-fallback)
	# Enc 2 (2000-3000m): Low nitro / chosen HELL
	# Enc 3 (3000-4000m): Boost launch -> HEAVEN
	# Enc 4 (4000-5000m): Boost launch -> HEAVEN

	var outcomes := [
		WorldCycleSchedule.BiomeType.HEAVEN,
		-1, # unconfirmed fallback to HELL
		WorldCycleSchedule.BiomeType.HELL,
		WorldCycleSchedule.BiomeType.HEAVEN,
		WorldCycleSchedule.BiomeType.HEAVEN
	]

	for enc in range(5):
		var base_dist := float(enc) * 1000.0
		var gate_dist := base_dist + 500.0
		var target_realm: int = outcomes[enc]

		# Approach (100m)
		ctrl.update_distance(base_dist + 100.0)
		assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.NORMAL_APPROACH, "Enc %d approach state" % enc)

		# Warning (460m)
		ctrl.update_distance(base_dist + 460.0)
		assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.RAMP_WARNING, "Enc %d ramp warning state" % enc)

		# Launch window (480m)
		ctrl.update_distance(base_dist + 480.0)
		assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.LAUNCH_WINDOW, "Enc %d launch window state" % enc)

		# Apply launch outcome before or at gate
		if target_realm != -1:
			var ok := ctrl.confirm_route(target_realm, enc)
			assert_true(ok, "Enc %d confirm_route ok" % enc)

		# Gate entry (510m)
		ctrl.update_distance(base_dist + 510.0)
		var expected_entry: int = WorldCycleSchedule.WorldState.HEAVEN_ENTRY if (target_realm == WorldCycleSchedule.BiomeType.HEAVEN) else WorldCycleSchedule.WorldState.HELL_ENTRY
		assert_eq(ctrl.current_state, expected_entry, "Enc %d entry state" % enc)

		# Active driving (750m)
		ctrl.update_distance(base_dist + 750.0)
		var expected_active: int = WorldCycleSchedule.WorldState.HEAVEN_ACTIVE if (target_realm == WorldCycleSchedule.BiomeType.HEAVEN) else WorldCycleSchedule.WorldState.HELL_ACTIVE
		assert_eq(ctrl.current_state, expected_active, "Enc %d active state" % enc)

		# Exit transition (970m)
		ctrl.update_distance(base_dist + 970.0)
		assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.EXIT_TRANSITION, "Enc %d exit transition state" % enc)

		# End of encounter / merge (next base dist)
		ctrl.update_distance(base_dist + 1000.0)
		assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.NORMAL_APPROACH, "Enc %d merge back to normal approach" % enc)

	# Verify recorded outcomes
	assert_eq(recorded_branches.size(), 5, "Exactly 5 encounters resolved")
	assert_eq(recorded_branches[0]["realm"], WorldCycleSchedule.BiomeType.HEAVEN, "Enc 0 resolved to Heaven")
	assert_eq(recorded_branches[1]["realm"], WorldCycleSchedule.BiomeType.HELL, "Enc 1 resolved to Hell (fallback)")
	assert_eq(recorded_branches[2]["realm"], WorldCycleSchedule.BiomeType.HELL, "Enc 2 resolved to Hell")
	assert_eq(recorded_branches[3]["realm"], WorldCycleSchedule.BiomeType.HEAVEN, "Enc 3 resolved to Heaven")
	assert_eq(recorded_branches[4]["realm"], WorldCycleSchedule.BiomeType.HEAVEN, "Enc 4 resolved to Heaven")

	assert_eq(completed_merges.size(), 5, "5 merges completed")
	assert_eq(ctrl.current_encounter_index, 5, "Reached encounter index 5 at 5,000m")

	ctrl.free()
	print("  ✓ Full 5,000m multi-encounter progression verified across all 5 encounters!")

# ---------------------------------------------------------------------------
# Test 6: Pause / Resume & Run Restart Semantics
# ---------------------------------------------------------------------------
func test_6_pause_resume_and_restart_semantics() -> void:
	print("-> [6/7] Testing pause/resume and restart semantics...")

	var ctrl := BiomeProgressionController.new()
	ctrl.enable_branching_mode(true)

	# Progress to 480m in launch window
	ctrl.update_distance(480.0)
	assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.LAUNCH_WINDOW, "Pre-pause state must be LAUNCH_WINDOW")

	# Pause controller
	ctrl.set_paused(true)
	assert_true(ctrl.is_paused, "Controller is paused")

	# Attempt distance updates while paused
	ctrl.update_distance(600.0)
	assert_approx_eq(ctrl.current_cumulative_distance, 480.0, 0.001, "Distance must remain frozen while paused")
	assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.LAUNCH_WINDOW, "State must remain frozen while paused")

	# Attempt route confirmation while paused
	var conf_paused := ctrl.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	assert_true(not conf_paused, "confirm_route must fail while paused")
	assert_true(not ctrl.confirmed_realms.has(0), "No realm confirmed while paused")

	# Resume
	ctrl.set_paused(false)
	ctrl.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	ctrl.update_distance(600.0)
	assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.HEAVEN_ACTIVE, "State advances after unpausing")

	# Restart / Reset
	ctrl.reset_progression()
	assert_approx_eq(ctrl.current_cumulative_distance, 0.0, 0.001, "Distance reset to 0.0m")
	assert_eq(ctrl.current_encounter_index, 0, "Encounter index reset to 0")
	assert_eq(ctrl.current_state, WorldCycleSchedule.WorldState.NORMAL_APPROACH, "State reset to NORMAL_APPROACH")
	assert_true(ctrl.confirmed_realms.is_empty(), "Confirmed realms cleared on reset")

	ctrl.free()
	print("  ✓ Pause/resume and run restart semantics verified!")

# ---------------------------------------------------------------------------
# Test 7: Environment Host Branching Coupling
# ---------------------------------------------------------------------------
func test_7_environment_host_branching_coupling() -> void:
	print("-> [7/7] Testing BiomeEnvironmentHost coupling with branching states...")

	var ctrl := BiomeProgressionController.new()
	ctrl.enable_branching_mode(true)

	var host := BiomeEnvironmentHost.new()
	host.bind_progression_controller(ctrl)

	# Verify Normal Approach starts active
	ctrl.update_distance(100.0)
	assert_eq(host.current_world_state, WorldCycleSchedule.WorldState.NORMAL_APPROACH, "Host tracks NORMAL_APPROACH")
	assert_eq(host.current_biome, WorldCycleSchedule.BiomeType.NORMAL_LAND, "Host active biome is NORMAL_LAND")

	# Verify Heaven Entry and Active
	ctrl.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	ctrl.update_distance(520.0)
	assert_eq(host.current_world_state, WorldCycleSchedule.WorldState.HEAVEN_ENTRY, "Host tracks HEAVEN_ENTRY")
	assert_true(host.is_in_transition, "Host is_in_transition is true during HEAVEN_ENTRY")

	ctrl.update_distance(600.0)
	assert_eq(host.current_world_state, WorldCycleSchedule.WorldState.HEAVEN_ACTIVE, "Host tracks HEAVEN_ACTIVE")
	assert_eq(host.current_biome, WorldCycleSchedule.BiomeType.HEAVEN, "Host active biome is HEAVEN")
	assert_true(not host.is_in_transition, "Host is_in_transition is false during HEAVEN_ACTIVE")

	# Verify Exit Transition back to Normal
	ctrl.update_distance(980.0)
	assert_eq(host.current_world_state, WorldCycleSchedule.WorldState.EXIT_TRANSITION, "Host tracks EXIT_TRANSITION")
	assert_true(host.is_in_transition, "Host is_in_transition is true during EXIT_TRANSITION")

	ctrl.update_distance(1000.0)
	assert_eq(host.current_world_state, WorldCycleSchedule.WorldState.NORMAL_APPROACH, "Host returns to NORMAL_APPROACH at 1000m")
	assert_eq(host.current_biome, WorldCycleSchedule.BiomeType.NORMAL_LAND, "Host active biome returns to NORMAL_LAND")

	host.free()
	ctrl.free()
	print("  ✓ BiomeEnvironmentHost coupling with branching states verified!")
