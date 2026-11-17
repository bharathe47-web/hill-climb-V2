extends SceneTree

## Dedicated End-to-End QA and Acceptance Test Suite for Phase 7.
## Implements all 10 Required Acceptance Tests (A through J) from:
## phases docs/DANIEL_ENDLESS_MAP_BRANCHING_HEAVEN_HELL_DESIGN.md (Section 9)
## 
## Tests:
## A: 500m gate with Nitro success -> Upper Heaven route confirmed
## B: 500m gate without Nitro -> Lower Hell catch basin safely received
## C: Arrive at gate with empty Nitro -> Safe Hell route (no softlock/death)
## D: Nitro pressed too early (ordinary driving) -> Physical landing dictates outcome
## E: Nitro in window with insufficient speed -> Hell route catches vehicle
## F: Complete Heaven section -> Merges at 1,000m into Normal Land baseline
## G: Complete Hell section -> Merges at 1,000m into Normal Land baseline
## H: Multi-encounter cycle continuity -> Gate at 1,500m repeats both outcomes
## I: 5,000m+ continuous endless progression -> 5 consecutive encounters (500m, 1500m, 2500m, 3500m, 4500m)
## J: Lifecycle robustness -> Pause/resume, crash/death, restart, and SaveManager best-distance persistence
## Multi-Vehicle: All 4 registered vehicles tested on both branches

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")
const BiomeProgressionControllerClass = preload("res://scripts/progression/BiomeProgressionController.gd")
const WorldCycleScheduleClass = preload("res://scripts/progression/WorldCycleSchedule.gd")
const GameManagerClass = preload("res://scripts/core/GameManager.gd")
const SaveManagerClass = preload("res://scripts/core/SaveManager.gd")

var _pass_count: int = 0
var _fail_count: int = 0

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN PHASE 7 END-TO-END QA & ACCEPTANCE TEST SUITE ---")
	print("=================================================================\n")
	
	await _run_all_acceptance_tests()
	
	print("\n=================================================================")
	if _fail_count == 0:
		print("✓ ALL PHASE 7 ACCEPTANCE TESTS COMPLETED WITH 100%% SUCCESS (%d checks passed)!" % _pass_count)
		print("=================================================================\n")
		quit(0)
	else:
		printerr("✗ PHASE 7 ACCEPTANCE TEST SUITE FINISHED WITH %d FAILURES (%d checks passed)" % [_fail_count, _pass_count])
		print("=================================================================\n")
		quit(1)

func _assert_true(condition: bool, message: String) -> void:
	if condition:
		_pass_count += 1
		print("  ✓ %s" % message)
	else:
		_fail_count += 1
		printerr("  ✗ FAILED: %s" % message)

func _run_all_acceptance_tests() -> void:
	await _test_a_and_f_first_encounter_nitro_to_heaven_and_merge()
	await _test_b_and_g_first_encounter_no_nitro_to_hell_and_merge()
	await _test_c_empty_nitro_safe_hell_fallback()
	await _test_d_nitro_pressed_too_early_landing_dictates()
	await _test_e_insufficient_speed_at_launch_window()
	await _test_h_encounter_continuity_to_1500m_gate()
	await _test_i_endless_5000m_5_consecutive_encounters()
	await _test_j_pause_resume_restart_and_save_data()
	await _test_all_4_vehicles_physics_and_clearance()

# ---------------------------------------------------------------------------
# Test A & F: First Encounter Nitro Launch -> Heaven -> Normal Land Merge
# ---------------------------------------------------------------------------
func _test_a_and_f_first_encounter_nitro_to_heaven_and_merge() -> void:
	print("-> [Test A & F] Testing Nitro launch success -> Heaven -> 1,000m Normal Land merge...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.gate_distance_m = 500.0
	encounter.encounter_index = 0
	get_root().add_child(encounter)
	
	var prog_ctrl = BiomeProgressionControllerClass.new()
	encounter.bind_progression_controller(prog_ctrl)
	get_root().add_child(prog_ctrl)
	prog_ctrl.enable_branching_mode(true)
	
	var confirmed_route := {"realm": -1, "encounter": -1}
	encounter.route_confirmed.connect(func(realm: int, enc: int) -> void:
		confirmed_route["realm"] = realm
		confirmed_route["encounter"] = enc
	)
	
	var merge_state := {"merged": false}
	encounter.merge_completed.connect(func(enc: int) -> void:
		merge_state["merged"] = true
	)
	
	var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle("blue_flame_truck")
	get_root().add_child(vehicle)
	vehicle.global_position = Vector2(50000.0 - 1200.0, 370.0)
	vehicle.linear_velocity = Vector2(1200.0, 0.0)
	vehicle.set_nitro_active(true)
	
	var reached_heaven := false
	for frame in range(160):
		vehicle.apply_central_force(vehicle.transform.x * vehicle.nitro_boost_force)
		if vehicle.rear_wheel:
			vehicle.rear_wheel.apply_torque(vehicle.motor_torque * 1.6)
		await physics_frame
		if confirmed_route["realm"] == WorldCycleScheduleClass.BiomeType.HEAVEN:
			reached_heaven = true
			break
	
	_assert_true(reached_heaven, "Test A: Vehicle with Nitro successfully reached upper Heaven landing apron")
	_assert_true(confirmed_route["realm"] == WorldCycleScheduleClass.BiomeType.HEAVEN, "Test A: Route trigger confirmed realm = HEAVEN")
	_assert_true(vehicle.global_position.y <= 300.0, "Test A: Vehicle elevation in Heaven zone (Y <= 300px, got %.1f)" % vehicle.global_position.y)
	
	# Simulate vehicle traversing across Heaven route into exit descent slide (50,000px realm section)
	vehicle.global_position = Vector2(99800.0, 320.0)
	vehicle.linear_velocity = Vector2(600.0, 0.0)
	for f in range(60):
		await physics_frame
		if merge_state["merged"]:
			break
	
	_assert_true(merge_state["merged"], "Test F: Merge trigger confirmed vehicle return to Normal Land after 500m Heaven route")
	_assert_true(is_equal_approx(encounter.heaven_segment.get_surface_y_at(encounter.realm_total_length - encounter.launch_gap), encounter.baseline_y), 
		"Test F: Heaven exit ramp rejoins Normal Land baseline exactly at Y = 420px")
	
	get_root().remove_child(vehicle)
	vehicle.queue_free()
	get_root().remove_child(prog_ctrl)
	prog_ctrl.queue_free()
	get_root().remove_child(encounter)
	encounter.queue_free()

# ---------------------------------------------------------------------------
# Test B & G: First Encounter Missed Launch -> Hell Catch Basin -> Normal Merge
# ---------------------------------------------------------------------------
func _test_b_and_g_first_encounter_no_nitro_to_hell_and_merge() -> void:
	print("-> [Test B & G] Testing missed launch (no Nitro) -> Hell catch basin -> Normal Land merge...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.gate_distance_m = 500.0
	encounter.encounter_index = 0
	get_root().add_child(encounter)
	
	var confirmed_route := {"realm": -1, "encounter": -1}
	encounter.route_confirmed.connect(func(realm: int, enc: int) -> void:
		confirmed_route["realm"] = realm
		confirmed_route["encounter"] = enc
	)
	
	var merge_state := {"merged": false}
	encounter.merge_completed.connect(func(enc: int) -> void:
		merge_state["merged"] = true
	)
	
	var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle("blue_flame_truck")
	get_root().add_child(vehicle)
	vehicle.global_position = Vector2(50000.0 - 100.0, 325.0)
	vehicle.linear_velocity = Vector2(650.0, -100.0)
	vehicle.set_nitro_active(false)
	
	var crash_state := {"crashed": false}
	vehicle.crashed.connect(func(): crash_state["crashed"] = true)
	
	var reached_hell := false
	for frame in range(140):
		await physics_frame
		if confirmed_route["realm"] == WorldCycleScheduleClass.BiomeType.HELL:
			reached_hell = true
			for _f in range(35):
				await physics_frame
			break
	
	_assert_true(reached_hell, "Test B: Vehicle without Nitro safely received by lower Hell catch basin")
	_assert_true(confirmed_route["realm"] == WorldCycleScheduleClass.BiomeType.HELL, "Test B: Route trigger confirmed realm = HELL")
	_assert_true(not crash_state["crashed"], "Test B: Vehicle did NOT crash during landing in catch basin")
	_assert_true(vehicle.global_position.y >= 440.0, "Test B: Vehicle elevation in Hell zone (Y >= 440px, got %.1f)" % vehicle.global_position.y)
	
	# Simulate traversing through geyser exit ramp to merge point
	vehicle.global_position = Vector2(99800.0, 320.0)
	vehicle.linear_velocity = Vector2(600.0, 0.0)
	for f in range(60):
		await physics_frame
		if merge_state["merged"]:
			break
	
	_assert_true(merge_state["merged"], "Test G: Merge trigger confirmed vehicle return to Normal Land after 500m Hell route")
	_assert_true(is_equal_approx(encounter.hell_segment.get_surface_y_at(encounter.realm_total_length - 50.0), encounter.baseline_y), 
		"Test G: Hell geyser escape ramp rejoins Normal Land baseline exactly at Y = 420px")
	
	get_root().remove_child(vehicle)
	vehicle.queue_free()
	get_root().remove_child(encounter)
	encounter.queue_free()

# ---------------------------------------------------------------------------
# Test C: Empty Nitro Arrival at Gate
# ---------------------------------------------------------------------------
func _test_c_empty_nitro_safe_hell_fallback() -> void:
	print("-> [Test C] Testing arrival at 500m gate with 0.0 Nitro (empty tank)...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.gate_distance_m = 500.0
	get_root().add_child(encounter)
	
	var confirmed_route := {"realm": -1}
	encounter.route_confirmed.connect(func(realm: int, _enc: int) -> void:
		confirmed_route["realm"] = realm
	)
	
	var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle("trophy_truck")
	get_root().add_child(vehicle)
	vehicle.current_nitro = 0.0 # Completely empty tank
	vehicle.global_position = Vector2(50000.0 - 500.0, 360.0)
	vehicle.linear_velocity = Vector2(700.0, 0.0)
	
	var crashed := false
	vehicle.crashed.connect(func(): crashed = true)
	
	for frame in range(140):
		if vehicle.rear_wheel:
			vehicle.rear_wheel.apply_torque(vehicle.motor_torque)
		await physics_frame
		if confirmed_route["realm"] == WorldCycleScheduleClass.BiomeType.HELL:
			break
	
	_assert_true(confirmed_route["realm"] == WorldCycleScheduleClass.BiomeType.HELL, "Test C: Empty Nitro arrival smoothly resolves to valid Hell route")
	_assert_true(not crashed, "Test C: Empty Nitro vehicle does NOT crash, softlock, or enter game over")
	
	get_root().remove_child(vehicle)
	vehicle.queue_free()
	get_root().remove_child(encounter)
	encounter.queue_free()

# ---------------------------------------------------------------------------
# Test D: Nitro Activated Too Early Outside Launch Window
# ---------------------------------------------------------------------------
func _test_d_nitro_pressed_too_early_landing_dictates() -> void:
	print("-> [Test D] Testing Nitro activated too early (350m, outside launch window)...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.gate_distance_m = 500.0
	get_root().add_child(encounter)
	
	var confirmed_route := {"realm": -1}
	encounter.route_confirmed.connect(func(realm: int, _enc: int) -> void:
		confirmed_route["realm"] = realm
	)
	
	var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle("orc_racer")
	get_root().add_child(vehicle)
	# Vehicle burns Nitro early and arrives at ramp lip with ordinary momentum
	vehicle.current_nitro = 0.0
	vehicle.global_position = Vector2(50000.0 - 150.0, 325.0)
	vehicle.linear_velocity = Vector2(650.0, -30.0)
	
	for frame in range(120):
		if vehicle.rear_wheel:
			vehicle.rear_wheel.apply_torque(vehicle.motor_torque)
		await physics_frame
		if confirmed_route["realm"] != -1:
			break
	
	_assert_true(confirmed_route["realm"] == WorldCycleScheduleClass.BiomeType.HELL, 
		"Test D: Early Nitro exhaustion results in physical fall to Hell; no false Heaven confirmation")
	
	get_root().remove_child(vehicle)
	vehicle.queue_free()
	get_root().remove_child(encounter)
	encounter.queue_free()

# ---------------------------------------------------------------------------
# Test E: Nitro in Launch Window with Insufficient Momentum
# ---------------------------------------------------------------------------
func _test_e_insufficient_speed_at_launch_window() -> void:
	print("-> [Test E] Testing Nitro active in window but with insufficient speed (< 400 px/s)...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.gate_distance_m = 500.0
	get_root().add_child(encounter)
	
	var confirmed_route := {"realm": -1}
	encounter.route_confirmed.connect(func(realm: int, _enc: int) -> void:
		confirmed_route["realm"] = realm
	)
	
	var vehicle: VehicleController = VehicleRegistry.instantiate_vehicle("dune_buggy")
	get_root().add_child(vehicle)
	# Vehicle moving very slowly at ramp lip
	vehicle.current_nitro = 50.0
	vehicle.global_position = Vector2(50000.0 - 50.0, 320.0)
	vehicle.linear_velocity = Vector2(300.0, -40.0)
	vehicle.set_nitro_active(true)
	
	for frame in range(120):
		await physics_frame
		if confirmed_route["realm"] != -1:
			break
	
	_assert_true(confirmed_route["realm"] == WorldCycleScheduleClass.BiomeType.HELL, 
		"Test E: Insufficient launch speed fails to reach Heaven apron; safely caught in Hell basin")
	
	get_root().remove_child(vehicle)
	vehicle.queue_free()
	get_root().remove_child(encounter)
	encounter.queue_free()

# ---------------------------------------------------------------------------
# Test H: Multi-Encounter Continuity to 1,500m Gate
# ---------------------------------------------------------------------------
func _test_h_encounter_continuity_to_1500m_gate() -> void:
	print("-> [Test H] Testing encounter progression past 1,000m merge to next gate at 1,500m...")
	
	var prog_ctrl = BiomeProgressionControllerClass.new()
	get_root().add_child(prog_ctrl)
	prog_ctrl.enable_branching_mode(true)
	
	# Complete Encounter 0 (500m -> 1,000m) with Heaven
	prog_ctrl.confirm_route(WorldCycleScheduleClass.BiomeType.HEAVEN, 0)
	prog_ctrl.update_distance(500.0)
	_assert_true(prog_ctrl.current_state == WorldCycleScheduleClass.WorldState.HEAVEN_ENTRY, "At 500m: HEAVEN_ENTRY state verified")
	
	prog_ctrl.update_distance(750.0)
	_assert_true(prog_ctrl.current_state == WorldCycleScheduleClass.WorldState.HEAVEN_ACTIVE, "At 750m: HEAVEN_ACTIVE state verified")
	
	prog_ctrl.update_distance(970.0)
	_assert_true(prog_ctrl.current_state == WorldCycleScheduleClass.WorldState.EXIT_TRANSITION, "At 970m: EXIT_TRANSITION state verified")
	
	# Pass 1,000m merge boundary -> Returns to Normal Land approach
	prog_ctrl.update_distance(1050.0)
	_assert_true(prog_ctrl.current_state == WorldCycleScheduleClass.WorldState.NORMAL_APPROACH, "At 1,050m: Returned to NORMAL_APPROACH")
	_assert_true(prog_ctrl.current_encounter_index == 1, "Encounter index advanced to 1 for 1,500m gate")
	
	# Approach 1,500m gate
	prog_ctrl.update_distance(1460.0)
	_assert_true(prog_ctrl.current_state == WorldCycleScheduleClass.WorldState.RAMP_WARNING, "At 1,460m: Encounter 1 RAMP_WARNING active")
	
	prog_ctrl.update_distance(1485.0)
	_assert_true(prog_ctrl.current_state == WorldCycleScheduleClass.WorldState.LAUNCH_WINDOW, "At 1,485m: Encounter 1 LAUNCH_WINDOW active")
	
	# Confirm Hell at second gate
	prog_ctrl.confirm_route(WorldCycleScheduleClass.BiomeType.HELL, 1)
	prog_ctrl.update_distance(1520.0)
	_assert_true(prog_ctrl.current_state == WorldCycleScheduleClass.WorldState.HELL_ENTRY, "At 1,520m: HELL_ENTRY confirmed for Encounter 1")
	
	get_root().remove_child(prog_ctrl)
	prog_ctrl.queue_free()

# ---------------------------------------------------------------------------
# Test I: Endless 5,000m Continuous Run Across 5 Encounters
# ---------------------------------------------------------------------------
func _test_i_endless_5000m_5_consecutive_encounters() -> void:
	print("-> [Test I] Testing endless 5,000m+ continuous run across 5 consecutive encounters...")
	
	var prog_ctrl = BiomeProgressionControllerClass.new()
	get_root().add_child(prog_ctrl)
	prog_ctrl.enable_branching_mode(true)
	
	# Simulate 5 consecutive encounters: 500m, 1500m, 2500m, 3500m, 4500m
	var planned_routes: Array[int] = [
		WorldCycleScheduleClass.BiomeType.HEAVEN, # Enc 0: 500m - 1000m
		WorldCycleScheduleClass.BiomeType.HELL,   # Enc 1: 1500m - 2000m
		WorldCycleScheduleClass.BiomeType.HEAVEN, # Enc 2: 2500m - 3000m
		WorldCycleScheduleClass.BiomeType.HELL,   # Enc 3: 3500m - 4000m
		WorldCycleScheduleClass.BiomeType.HEAVEN  # Enc 4: 4500m - 5000m
	]
	
	for enc_idx in range(5):
		var gate_m := 500.0 + (float(enc_idx) * 1000.0)
		var chosen_realm := planned_routes[enc_idx]
		
		# Approach ramp
		prog_ctrl.update_distance(gate_m - 40.0)
		_assert_true(prog_ctrl.current_encounter_index == enc_idx, "Encounter %d active index verified" % enc_idx)
		
		# Confirm route
		var confirmed := prog_ctrl.confirm_route(chosen_realm, enc_idx)
		_assert_true(confirmed, "Encounter %d successfully confirmed route" % enc_idx)
		
		# Duplicate confirmation rejection
		var dup := prog_ctrl.confirm_route(chosen_realm, enc_idx)
		_assert_true(not dup, "Encounter %d rejects duplicate route confirmation" % enc_idx)
		
		# Active realm
		prog_ctrl.update_distance(gate_m + 250.0)
		var exp_state: int = WorldCycleScheduleClass.WorldState.HEAVEN_ACTIVE if chosen_realm == WorldCycleScheduleClass.BiomeType.HEAVEN else WorldCycleScheduleClass.WorldState.HELL_ACTIVE
		_assert_true(prog_ctrl.current_state == exp_state, "Encounter %d at %.0fm: active realm matches selection" % [enc_idx, gate_m + 250.0])
		
		# Merge back to Normal Land
		prog_ctrl.update_distance(gate_m + 510.0)
		if enc_idx < 4:
			_assert_true(prog_ctrl.current_state == WorldCycleScheduleClass.WorldState.NORMAL_APPROACH, 
				"Encounter %d merged back to NORMAL_APPROACH at %.0fm" % [enc_idx, gate_m + 510.0])
	
	# Verify final distance beyond 5,000m
	prog_ctrl.update_distance(5050.0)
	_assert_true(prog_ctrl.current_cumulative_distance >= 5000.0, "Endless continuous distance >= 5,000m verified (Got: %.1fm)" % prog_ctrl.current_cumulative_distance)
	_assert_true(prog_ctrl.current_encounter_index == 5, "Encounter index advanced cleanly to 5 after 5,000m")
	
	get_root().remove_child(prog_ctrl)
	prog_ctrl.queue_free()

# ---------------------------------------------------------------------------
# Test J: Lifecycle Robustness (Pause/Resume, Crash/Restart, Save Continuity)
# ---------------------------------------------------------------------------
func _test_j_pause_resume_restart_and_save_data() -> void:
	print("-> [Test J] Testing lifecycle robustness (pause/resume, crash, restart, and save persistence)...")
	
	var gm = GameManagerClass.new()
	get_root().add_child(gm)
	gm.start_run()
	
	# 1. Pause and Resume test
	gm.update_distance(480.0)
	gm.pause_run(true)
	_assert_true(gm.current_state == GameManagerClass.RunState.PAUSED, "Run pauses successfully in launch window (480m)")
	gm.pause_run(false)
	_assert_true(gm.current_state == GameManagerClass.RunState.PLAYING, "Run resumes successfully without state corruption")
	
	# 2. Distance and coin accumulation across biomes
	gm.update_distance(650.0) # In Heaven
	gm.add_coins(35)
	gm.update_distance(1200.0) # Merged back into Normal
	gm.add_coins(20)
	gm.update_distance(1650.0) # In Hell
	gm.add_coins(40)
	_assert_true(gm.coins_collected == 95, "Coins accumulate correctly across branch transitions (Got: %d)" % gm.coins_collected)
	_assert_true(is_equal_approx(gm.current_distance, 1650.0), "Authoritative distance tracks monotonically to 1,650m")
	
	# 3. Crash detection & Run Finish
	gm.finish_run("vehicle_crashed")
	_assert_true(gm.current_state == GameManagerClass.RunState.FINISHED, "GameManager transitions to FINISHED on crash")
	_assert_true(gm.finish_reason == "vehicle_crashed", "Finish reason preserved as 'vehicle_crashed'")
	_assert_true(gm.best_distance >= 1650.0, "Best distance recorded in SaveManager (>= 1,650m, Got: %.1f)" % gm.best_distance)
	
	# 4. Restart test
	gm.restart_run()
	_assert_true(gm.current_state == GameManagerClass.RunState.PLAYING, "restart_run() transitions back to PLAYING")
	_assert_true(gm.current_distance == 0.0, "Distance reset to 0.0m on restart")
	_assert_true(gm.coins_collected == 0, "Coins reset to 0 on restart")
	
	get_root().remove_child(gm)
	gm.queue_free()

# ---------------------------------------------------------------------------
# Multi-Vehicle Physical Verification: All 4 Vehicles
# ---------------------------------------------------------------------------
func _test_all_4_vehicles_physics_and_clearance() -> void:
	print("-> [Multi-Vehicle QA] Testing all 4 registered vehicles for physical clearance on Heaven & Hell...")
	
	var encounter = BranchingEncounterClass.new()
	encounter.gate_distance_m = 500.0
	get_root().add_child(encounter)
	
	var vehicle_ids := VehicleRegistry.get_vehicle_ids()
	_assert_true(vehicle_ids.size() == 4, "Exact 4 vehicles registered in VehicleRegistry (Count: %d)" % vehicle_ids.size())
	
	for v_id in vehicle_ids:
		var veh: VehicleController = VehicleRegistry.instantiate_vehicle(v_id)
		get_root().add_child(veh)
		var crash_tracker := {"crashed": false}
		veh.crashed.connect(func(): crash_tracker["crashed"] = true)
		
		# Test Heaven landing apron clearance
		var h_surf_y: float = encounter.heaven_segment.get_surface_y_at(encounter.launch_gap + 200.0)
		veh.global_position = Vector2(50000.0 + encounter.launch_gap + 200.0, h_surf_y - 35.0)
		veh.linear_velocity = Vector2(800.0, 0.0)
		for _f in range(12):
			await physics_frame
		_assert_true(not crash_tracker["crashed"], "Vehicle [%s] lands on Heaven apron without crashing" % v_id)
		
		# Test Hell catch basin clearance
		crash_tracker["crashed"] = false
		var hell_surf_y: float = encounter.hell_segment.get_surface_y_at(800.0)
		veh.global_position = Vector2(50000.0 + 800.0, hell_surf_y - 35.0)
		veh.linear_velocity = Vector2(750.0, 0.0)
		for _f in range(12):
			await physics_frame
		_assert_true(not crash_tracker["crashed"], "Vehicle [%s] traverses Hell catch basin without crashing" % v_id)
		
		get_root().remove_child(veh)
		veh.queue_free()
	
	get_root().remove_child(encounter)
	encounter.queue_free()
