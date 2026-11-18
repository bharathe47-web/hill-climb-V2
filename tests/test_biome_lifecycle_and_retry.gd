@tool
class_name TestBiomeLifecycleAndRetry
extends SceneTree

const WorldCycleScheduleScript = preload("res://scripts/progression/WorldCycleSchedule.gd")
const BiomeProgressionControllerScript = preload("res://scripts/progression/BiomeProgressionController.gd")
const BiomeEnvironmentHostScript = preload("res://scripts/environment/BiomeEnvironmentHost.gd")
const TerrainGeneratorScript = preload("res://scripts/terrain/TerrainGenerator.gd")
const TerrainSegmentScript = preload("res://scripts/terrain/TerrainSegment.gd")
const GameSceneScript = preload("res://scripts/core/Game.gd")
const GameManagerScript = preload("res://scripts/core/GameManager.gd")

var _game_scene: GameScene = null
var _prog_ctrl: BiomeProgressionController = null
var _env_host: BiomeEnvironmentHost = null
var _terrain_gen: TerrainGenerator = null
var _game_manager: GameManager = null
var _vehicle: Node = null

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN BIOME LIFECYCLE & RETRY INTEGRATION TEST SUITE ---")
	print("---   (DEFECT A: MUTUAL EXCLUSIVITY & DEFECT B: RETRY)   ---")
	print("=================================================================")

	await _setup_harness()

	var passed := true
	passed = await _test_a_normal_to_heaven_crossing() and passed
	passed = await _test_b_heaven_to_hell_crossing() and passed
	passed = await _test_c_hell_to_normal_return() and passed
	passed = await _test_d_crash_in_heaven_and_retry() and passed
	passed = await _test_e_crash_in_hell_and_retry() and passed
	passed = await _test_f_retry_during_transition() and passed
	passed = await _test_g_repeated_retries_across_biomes() and passed

	_cleanup_harness()

	if passed:
		print("\n=================================================================")
		print("✓ ALL LIFECYCLE AND RETRY INTEGRATION TESTS PASSED (100% SUCCESS)!")
		print("=================================================================")
		quit(0)
	else:
		print("\n=================================================================")
		print("✗ SOME LIFECYCLE OR RETRY TESTS FAILED!")
		print("=================================================================")
		quit(1)

func _setup_harness() -> void:
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	assert(packed != null, "Game.tscn must be loaded")
	_game_scene = packed.instantiate() as GameScene
	_game_scene.use_procedural_terrain = true
	root.add_child(_game_scene)
	await process_frame
	await process_frame

	_game_manager = _game_scene.get_node_or_null("GameManager") as GameManager
	_prog_ctrl = _game_scene.get_node_or_null("BiomeProgressionController") as BiomeProgressionController
	_env_host = _game_scene.get_node_or_null("BiomeEnvironmentHost") as BiomeEnvironmentHost
	var terrain_slot := _game_scene.get_node_or_null("TerrainSlot")
	if terrain_slot:
		_terrain_gen = terrain_slot.get_node_or_null("TerrainGenerator") as TerrainGenerator
	_vehicle = _game_scene.vehicle

	assert(_game_manager != null, "GameManager must exist")
	assert(_prog_ctrl != null, "BiomeProgressionController must exist")
	assert(_env_host != null, "BiomeEnvironmentHost must exist")
	assert(_terrain_gen != null, "TerrainGenerator must exist")
	assert(_vehicle != null, "Vehicle must exist")

func _cleanup_harness() -> void:
	if is_instance_valid(_game_scene):
		_game_scene.queue_free()

## Helper to drive simulation forward to a target distance (in meters)
func _drive_to_distance(target_dist_m: float, step_size_m: float = 20.0) -> void:
	if is_instance_valid(_vehicle) and _vehicle is RigidBody2D:
		(_vehicle as RigidBody2D).freeze = true

	var curr_dist := _game_manager.current_distance
	while curr_dist < target_dist_m:
		curr_dist = minf(curr_dist + step_size_m, target_dist_m)
		# Update vehicle position (100px = 1m)
		if is_instance_valid(_vehicle):
			var new_pos := Vector2(_game_scene.start_x + (curr_dist * 100.0), 350.0)
			_vehicle.global_position = new_pos
			_vehicle.rotation = 0.0
			if "current_fuel" in _vehicle:
				_vehicle.current_fuel = 100.0
		_game_scene._stopped_timer = 0.0
		_game_manager.current_fuel = 100.0
		_game_manager.current_state = GameManagerScript.RunState.PLAYING
		_game_manager.update_distance(curr_dist)
		if is_instance_valid(_terrain_gen):
			_terrain_gen._process(0.016)
		await process_frame

## TEST A: Normal Land to Heaven crossing
func _test_a_normal_to_heaven_crossing() -> bool:
	print("\n-> [TEST A] Testing Normal Land to Heaven crossing (0m -> 300m -> 400m)...")
	# 1. Start from fresh run
	_game_scene.execute_restart_transaction()
	await process_frame

	# Verify 0m Normal Land state
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.NORMAL_LAND:
		printerr("  ✗ At 0m: current_biome is not NORMAL_LAND")
		return false
	if not _env_host.normal_environment.is_active:
		printerr("  ✗ At 0m: normal_environment is not active")
		return false
	if _env_host.heaven_environment.is_active or _env_host.hell_environment.is_active:
		printerr("  ✗ At 0m: heaven or hell environment is active")
		return false

	# 2. Drive to 295m (immediately before 300m portal)
	await _drive_to_distance(295.0)
	if _env_host.heaven_environment.is_active:
		printerr("  ✗ At 295m: heaven_environment became active prematurely before portal crossing")
		return false
	if not _env_host.normal_environment.is_active:
		printerr("  ✗ At 295m: normal_environment deactivated prematurely before portal")
		return false

	# 3. Cross Heaven Portal at 300m -> 305m
	await _drive_to_distance(305.0)

	# Verify MUTUAL EXCLUSIVITY at portal crossing:
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.HEAVEN:
		printerr("  ✗ At 305m: current_biome is not HEAVEN (got %d)" % _env_host.current_biome)
		return false
	if _env_host.normal_environment.is_active:
		printerr("  ✗ At 305m: normal_environment is still active after portal crossing!")
		return false
	if not _env_host.heaven_environment.is_active:
		printerr("  ✗ At 305m: heaven_environment is not active after portal crossing!")
		return false
	if _env_host.hell_environment.is_active:
		printerr("  ✗ At 305m: hell_environment is active!")
		return false

	# 4. Drive 100 metres inside Heaven (to 400m)
	await _drive_to_distance(400.0)

	# Verify all segments created inside Heaven have biome_type == HEAVEN
	var active_segs := _terrain_gen.active_segments
	var heaven_seg_count := 0
	for seg in active_segs:
		if seg.start_distance_m >= 300.0:
			heaven_seg_count += 1
			if seg.biome_type != WorldCycleScheduleScript.BiomeType.HEAVEN:
				printerr("  ✗ Segment at %.1fm has incorrect biome_type %d (expected HEAVEN)" % [seg.start_distance_m, seg.biome_type])
				return false
			# Verify Normal Land visuals are not visible on Heaven segments
			for child in seg.decorations_root.get_children():
				if child.is_in_group("biome_normal_visual") and child.visible:
					printerr("  ✗ Active Normal Land decoration found visible in Heaven at %.1fm!" % seg.start_distance_m)
					return false

	if heaven_seg_count == 0:
		printerr("  ✗ Zero Heaven segments found between 300m and 400m")
		return false

	print("  ✓ TEST A passed: Strict mutual exclusivity verified, 100m driven in Heaven with zero Normal Land visual leaks!")
	return true

## TEST B: Heaven to Hell crossing
func _test_b_heaven_to_hell_crossing() -> bool:
	print("\n-> [TEST B] Testing Heaven to Hell crossing (400m -> 600m -> 700m)...")
	# 1. Drive to 595m
	await _drive_to_distance(595.0)
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.HEAVEN:
		printerr("  ✗ At 595m: expected HEAVEN, got %d" % _env_host.current_biome)
		return false

	# 2. Cross Hell Portal at 600m -> 605m
	await _drive_to_distance(605.0)

	# Verify MUTUAL EXCLUSIVITY at 605m:
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.HELL:
		printerr("  ✗ At 605m: expected HELL, got %d" % _env_host.current_biome)
		return false
	if _env_host.heaven_environment.is_active:
		printerr("  ✗ At 605m: heaven_environment is still active!")
		return false
	if not _env_host.hell_environment.is_active:
		printerr("  ✗ At 605m: hell_environment is not active!")
		return false
	if _env_host.normal_environment.is_active:
		printerr("  ✗ At 605m: normal_environment is active!")
		return false

	# 3. Drive 100m into Hell (to 700m)
	await _drive_to_distance(700.0)
	for seg in _terrain_gen.active_segments:
		if seg.start_distance_m >= 600.0:
			if seg.biome_type != WorldCycleScheduleScript.BiomeType.HELL:
				printerr("  ✗ Segment at %.1fm has incorrect biome_type %d (expected HELL)" % [seg.start_distance_m, seg.biome_type])
				return false

	print("  ✓ TEST B passed: Heaven to Hell portal transition verified with exclusive Hell visuals!")
	return true

## TEST C: Hell to Normal Land return
func _test_c_hell_to_normal_return() -> bool:
	print("\n-> [TEST C] Testing Hell to Normal Land return (700m -> 900m -> 950m)...")
	# 1. Drive to 895m
	await _drive_to_distance(895.0)
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.HELL:
		printerr("  ✗ At 895m: expected HELL, got %d" % _env_host.current_biome)
		return false

	# 2. Cross Return Portal at 900m -> 905m
	await _drive_to_distance(905.0)

	# Verify MUTUAL EXCLUSIVITY at 905m:
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.NORMAL_LAND:
		printerr("  ✗ At 905m: expected NORMAL_LAND, got %d" % _env_host.current_biome)
		return false
	if _env_host.hell_environment.is_active:
		printerr("  ✗ At 905m: hell_environment is still active!")
		return false
	if not _env_host.normal_environment.is_active:
		printerr("  ✗ At 905m: normal_environment is not active!")
		return false

	# 3. Drive 50m into new cycle Normal Land (to 950m)
	await _drive_to_distance(950.0)
	print("  ✓ TEST C passed: Return portal to Normal Land verified cleanly!")
	return true

## TEST D: Crash inside Heaven and Retry
func _test_d_crash_in_heaven_and_retry() -> bool:
	print("\n-> [TEST D] Testing crash inside Heaven and Retry (at 450m)...")
	# 1. Drive deep into Heaven (450m)
	_game_scene.execute_restart_transaction()
	await process_frame
	await _drive_to_distance(450.0)

	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.HEAVEN:
		printerr("  ✗ Failed to reach Heaven at 450m")
		return false

	# 2. Trigger Crash
	_game_manager.finish_run("crashed")
	await process_frame
	if _game_manager.current_state != GameManagerScript.RunState.FINISHED:
		printerr("  ✗ Run did not finish on crash")
		return false

	# 3. Player selects Retry
	_game_manager.restart_run()
	await process_frame
	await process_frame

	# 4. Verify 8-Phase Transaction results:
	# - Distance resets to 0.0m
	if not is_equal_approx(_game_manager.current_distance, 0.0):
		printerr("  ✗ Distance did not reset to 0.0 (is %f)" % _game_manager.current_distance)
		return false
	# - Biome is Normal Land
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.NORMAL_LAND:
		printerr("  ✗ Biome did not reset to NORMAL_LAND (is %d)" % _env_host.current_biome)
		return false
	if _prog_ctrl.current_biome_index != WorldCycleScheduleScript.BiomeType.NORMAL_LAND:
		printerr("  ✗ Progression controller biome is not NORMAL_LAND (is %d)" % _prog_ctrl.current_biome_index)
		return false
	# - Cycle index is 0
	if _prog_ctrl.current_cycle_index != 0:
		printerr("  ✗ Cycle index is not 0 (is %d)" % _prog_ctrl.current_cycle_index)
		return false
	# - Normal Land root is active, Heaven and Hell inactive
	if not _env_host.normal_environment.is_active:
		printerr("  ✗ Normal environment is not active after Retry")
		return false
	if _env_host.heaven_environment.is_active:
		printerr("  ✗ Heaven environment is STILL active after Retry!")
		return false
	if _env_host.hell_environment.is_active:
		printerr("  ✗ Hell environment is active after Retry!")
		return false

	# 5. Verify the road from 0m to 299m has ZERO Heaven assets
	for seg in _terrain_gen.active_segments:
		if seg.start_distance_m < 300.0:
			if seg.biome_type != WorldCycleScheduleScript.BiomeType.NORMAL_LAND:
				printerr("  ✗ Stale segment found with biome %d on restarted track!" % seg.biome_type)
				return false
			for child in seg.decorations_root.get_children():
				if child.is_in_group("biome_heaven_visual") and child.visible:
					printerr("  ✗ Stale Heaven decoration visible on freshly restarted road at %.1fm!" % seg.start_distance_m)
					return false

	# 6. Drive 50m in restarted world and verify only Normal Land assets
	await _drive_to_distance(50.0)
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.NORMAL_LAND:
		printerr("  ✗ Biome changed unexpectedly during post-retry drive")
		return false

	print("  ✓ TEST D passed: Crash in Heaven followed by Retry successfully produced a clean Normal Land run at 0m!")
	return true

## TEST E: Crash inside Hell and Retry
func _test_e_crash_in_hell_and_retry() -> bool:
	print("\n-> [TEST E] Testing crash inside Hell and Retry (at 750m)...")
	# 1. Drive to 750m in Hell
	await _drive_to_distance(750.0)
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.HELL:
		printerr("  ✗ Failed to reach Hell at 750m")
		return false

	# 2. Trigger Crash & Retry
	_game_manager.finish_run("crashed")
	await process_frame
	_game_manager.restart_run()
	await process_frame
	await process_frame

	# 3. Assert clean Normal Land state
	if not is_equal_approx(_game_manager.current_distance, 0.0):
		printerr("  ✗ Distance did not reset to 0.0 after Hell crash")
		return false
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.NORMAL_LAND:
		printerr("  ✗ Biome did not reset to NORMAL_LAND after Hell crash")
		return false
	if not _env_host.normal_environment.is_active or _env_host.hell_environment.is_active or _env_host.heaven_environment.is_active:
		printerr("  ✗ Environment exclusivity failed after Hell crash")
		return false

	print("  ✓ TEST E passed: Crash in Hell followed by Retry cleanly restored Normal Land at 0m!")
	return true

## TEST F: Retry during transition
func _test_f_retry_during_transition() -> bool:
	print("\n-> [TEST F] Testing Retry during active portal transition...")
	# Drive to exact portal crossing at 300.0m
	await _drive_to_distance(300.0)

	# Trigger Retry right on the boundary
	_game_manager.restart_run()
	await process_frame
	await process_frame

	# Verify clean state
	if not is_equal_approx(_game_manager.current_distance, 0.0):
		printerr("  ✗ Distance did not reset to 0.0 after boundary retry")
		return false
	if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.NORMAL_LAND:
		printerr("  ✗ Biome did not reset to NORMAL_LAND after boundary retry")
		return false
	if not _env_host.normal_environment.is_active or _env_host.heaven_environment.is_active:
		printerr("  ✗ Half-transition state leaked into new run!")
		return false

	print("  ✓ TEST F passed: Retry during portal transition reset cleanly with zero leak!")
	return true

## TEST G: Repeated retries across biomes
func _test_g_repeated_retries_across_biomes() -> bool:
	print("\n-> [TEST G] Testing 5 successive crash-retry sequences across different biomes...")
	var test_points := [150.0, 450.0, 750.0, 350.0, 650.0]

	for i in range(test_points.size()):
		var target_d: float = test_points[i]
		await _drive_to_distance(target_d)
		_game_manager.finish_run("crashed")
		await process_frame
		_game_manager.restart_run()
		await process_frame
		await process_frame

		if not is_equal_approx(_game_manager.current_distance, 0.0):
			printerr("  ✗ Iteration %d: distance not 0.0" % i)
			return false
		if _env_host.current_biome != WorldCycleScheduleScript.BiomeType.NORMAL_LAND:
			printerr("  ✗ Iteration %d: biome not NORMAL_LAND" % i)
			return false
		if not _env_host.normal_environment.is_active:
			printerr("  ✗ Iteration %d: normal environment not active" % i)
			return false
		if _env_host.heaven_environment.is_active or _env_host.hell_environment.is_active:
			printerr("  ✗ Iteration %d: foreign environment active" % i)
			return false

	print("  ✓ TEST G passed: 5 consecutive crash-retry sequences executed with zero corruption or leakage!")
	return true
