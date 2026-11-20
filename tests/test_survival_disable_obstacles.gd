extends SceneTree

const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN SURVIVAL MODE DISABLED OBSTACLES VERIFICATION ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var root := get_root()

	_test_default_configuration(root)
	await _test_no_obstacles_during_gameplay(root)
	_test_restart_maintains_disabled(root)
	_test_manual_spawn_calls_blocked(root)
	_test_all_obstacle_assets_preserved()

	print("\n=================================================================")
	print("✓ ALL DISABLED OBSTACLE SYSTEM TESTS PASSED 100%!")
	print("=================================================================\n")
	quit(0)

func _test_default_configuration(root: Window) -> void:
	print("-> [1/5] Verifying default configuration has obstacle spawning disabled...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	assert(surv.enable_obstacle_spawning == false, "enable_obstacle_spawning must be false by default")
	assert(surv.obstacle_container != null, "ObstacleContainer exists")
	assert(surv.obstacle_container.get_child_count() == 0, "ObstacleContainer must start empty")

	# Check for any warning indicator in scene
	for child in surv.get_children():
		assert(not (child is ObstacleWarning), "No ObstacleWarning should exist at start")

	surv.queue_free()
	print("  ✓ enable_obstacle_spawning is false by default and no obstacles or warnings exist at start!")

func _test_no_obstacles_during_gameplay(root: Window) -> void:
	print("-> [2/5] Simulating extended gameplay with disabled obstacle spawning...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	var warning_signal_count := 0
	surv.warning_requested.connect(func(_pos, _dur): warning_signal_count += 1)

	# Simulate 300 physics frames and 300 seconds of survival time
	for i in range(10):
		await process_frame

	for frame in range(120):
		surv._process(0.5) # Simulates 60 seconds of survival time
		await physics_frame

	assert(surv.survival_time > 50.0, "Survival time progresses normally")
	assert(surv.obstacle_container.get_child_count() == 0, "ObstacleContainer must remain empty during gameplay")
	assert(warning_signal_count == 0, "No warning_requested signal should ever fire when spawning is disabled")

	for child in surv.get_children():
		assert(not (child is ObstacleWarning), "No ObstacleWarning nodes should be created in scene")

	surv.queue_free()
	print("  ✓ Zero food obstacles and zero warning indicators during extended gameplay!")

func _test_restart_maintains_disabled(root: Window) -> void:
	print("-> [3/5] Verifying restart and retry maintains disabled obstacle spawning...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	for i in range(5):
		await process_frame

	# Simulate a restart
	surv.start_run()
	assert(surv.enable_obstacle_spawning == false, "enable_obstacle_spawning remains false after start_run()")
	assert(surv.obstacle_container.get_child_count() == 0, "ObstacleContainer remains empty after start_run()")

	# Simulate retry button press
	surv._on_retry_pressed()
	assert(surv.enable_obstacle_spawning == false, "enable_obstacle_spawning remains false after retry")
	assert(surv.obstacle_container.get_child_count() == 0, "ObstacleContainer remains empty after retry")

	surv.queue_free()
	print("  ✓ Restart and retry maintain disabled obstacle spawning!")

func _test_manual_spawn_calls_blocked(root: Window) -> void:
	print("-> [4/5] Verifying direct spawn calls are safely blocked when disabled...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.load_default_obstacles()
	root.add_child(surv)

	for i in range(5):
		await process_frame

	var warning_fired := false
	surv.warning_requested.connect(func(_pos, _dur): warning_fired = true)

	# Direct call to _trigger_obstacle_spawn()
	surv._trigger_obstacle_spawn()
	assert(warning_fired == false, "_trigger_obstacle_spawn() must safely return early when disabled")
	assert(surv.obstacle_container.get_child_count() == 0, "No obstacle spawned from _trigger_obstacle_spawn()")

	# Direct call to _spawn_obstacle_at()
	surv._spawn_obstacle_at(200.0)
	assert(surv.obstacle_container.get_child_count() == 0, "_spawn_obstacle_at() must safely return early when disabled")

	surv.queue_free()
	print("  ✓ Direct obstacle spawn methods are safely blocked when disabled!")

func _test_all_obstacle_assets_preserved() -> void:
	print("-> [5/5] Verifying all 8 Indian food obstacle scenes and warning scenes are intact...")
	var obstacle_paths := [
		"res://scenes/modes/survival/obstacles/idli_obstacle.tscn",
		"res://scenes/modes/survival/obstacles/dosa_obstacle.tscn",
		"res://scenes/modes/survival/obstacles/vada_obstacle.tscn",
		"res://scenes/modes/survival/obstacles/samosa_obstacle.tscn",
		"res://scenes/modes/survival/obstacles/murukku_obstacle.tscn",
		"res://scenes/modes/survival/obstacles/pani_puri_obstacle.tscn",
		"res://scenes/modes/survival/obstacles/jalebi_obstacle.tscn",
		"res://scenes/modes/survival/obstacles/coconut_obstacle.tscn",
		"res://scenes/modes/survival/warnings/obstacle_warning.tscn"
	]

	for path in obstacle_paths:
		assert(ResourceLoader.exists(path), "Preserved obstacle scene must exist: %s" % path)
		var res = load(path)
		assert(res != null, "Preserved obstacle scene must load successfully: %s" % path)

	print("  ✓ All 8 Indian food hazards and warning scenes are intact and preserved!")
