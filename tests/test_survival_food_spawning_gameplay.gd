extends SceneTree

const MainScene = preload("res://scenes/main/Main.tscn")
const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const FoodObstacle = preload("res://scripts/components/survival_obstacles/food_obstacle.gd")
const GroundShadow = preload("res://scripts/components/survival_obstacles/ground_shadow.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN SURVIVAL MODE FOOD SPAWNING & FALLING SYSTEM TEST ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var root := get_root()

	_test_1_main_lifecycle_and_spawning_enabled(root)
	_test_2_all_eight_food_types_can_spawn(root)
	_test_3_sky_spawning_world_coordinates(root)
	_test_4_falling_physics_and_ground_impact(root)
	_test_5_coconut_bounce_behavior(root)
	_test_6_ground_shadow_landing_alignment(root)
	_test_7_pause_restart_and_game_over(root)

	print("\n=================================================================")
	print("✓ ALL FOOD SPAWNING & SKY-FALLING TESTS PASSED (100% SUCCESS)!")
	print("=================================================================\n")
	quit(0)

func _test_1_main_lifecycle_and_spawning_enabled(root: Window) -> void:
	print("-> [1/7] Testing MainController launch & SurvivalMode obstacle initialization...")
	var main = MainScene.instantiate()
	root.add_child(main)
	main.load_survival()

	var surv: SurvivalController = main.current_scene_node as SurvivalController
	assert(surv != null, "SurvivalController must be instantiated in Main")
	assert(surv.enable_obstacle_spawning == true, "Obstacle spawning must be ENABLED during active Survival gameplay")
	assert(surv.obstacle_scenes.size() == 8, "All 8 food obstacles must be registered and available")
	assert(surv.obstacle_container != null, "ObstacleContainer node must exist")

	main.queue_free()
	print("  ✓ MainController sets enable_obstacle_spawning=true and registers all 8 food scenes!")

func _test_2_all_eight_food_types_can_spawn(root: Window) -> void:
	print("-> [2/7] Verifying all 8 Indian food hazard scenes can spawn into ObstacleContainer...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.enable_obstacle_spawning = true
	surv.load_default_obstacles()
	root.add_child(surv)

	var spawned_ids := {}
	# Force spawns across the registered scenes
	for i in range(len(surv.obstacle_scenes)):
		var scene = surv.obstacle_scenes[i]
		var obs: FoodObstacle = scene.instantiate() as FoodObstacle
		assert(obs != null, "Obstacle scene %d must instantiate FoodObstacle" % i)
		surv.obstacle_container.add_child(obs)
		obs.global_position = Vector2(100.0 + i * 50.0, -50.0)
		spawned_ids[obs.obstacle_id] = true

	var expected := ["idli", "dosa", "vada", "samosa", "murukku", "pani_puri", "jalebi", "coconut"]
	for food_id in expected:
		assert(spawned_ids.has(food_id), "Food type '%s' must be present in obstacle scenes" % food_id)

	surv.queue_free()
	print("  ✓ All 8 Indian foods (Idli, Dosa, Vada, Samosa, Murukku, Pani Puri, Jalebi, Coconut) verified!")

func _test_3_sky_spawning_world_coordinates(root: Window) -> void:
	print("-> [3/7] Verifying sky spawning coordinates above visible camera viewport...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.enable_obstacle_spawning = true
	surv.load_default_obstacles()
	root.add_child(surv)

	var target_x := 300.0
	var sky_y := surv.get_sky_spawn_y(target_x)
	var surf_y := surv.get_terrain_surface_y(target_x)

	assert(sky_y < surf_y - 350.0, "Spawn Y must be high in the sky (at least 350px above road)")

	if is_instance_valid(surv.follow_camera):
		var vp_h: float = float(ProjectSettings.get_setting("display/window/size/viewport_height", 720))
		var half_h := (vp_h * 0.5) / surv.follow_camera.zoom.y
		var cam_top := surv.follow_camera.global_position.y - half_h
		assert(sky_y <= cam_top - 50.0, "Obstacle must spawn strictly above the visible camera viewport")

	# Test lead distance with moving vehicle
	if is_instance_valid(surv.vehicle):
		var obs = surv._spawn_obstacle_at(surv.vehicle.global_position.x + 200.0)
		assert(obs != null, "Spawned obstacle must not be null")
		assert(obs.get_parent() == surv.obstacle_container, "Obstacle must be child of ObstacleContainer")
		assert(obs.global_position.y == sky_y, "Obstacle position Y must match calculated sky Y")

	surv.queue_free()
	print("  ✓ Sky spawning places obstacles offscreen above camera in world coordinates!")

func _test_4_falling_physics_and_ground_impact(root: Window) -> void:
	print("-> [4/7] Verifying continuous falling physics, gravity acceleration, and ground impact...")
	var idli_scene: PackedScene = load("res://scenes/modes/survival/obstacles/idli_obstacle.tscn")
	var idli: FoodObstacle = idli_scene.instantiate()
	idli.global_position = Vector2(200.0, 100.0)
	idli.ground_y = 400.0
	root.add_child(idli)

	var initial_vy := idli._current_velocity.y
	idli._physics_process(0.1)

	assert(idli._current_velocity.y > initial_vy, "Vertical velocity must increase under gravity (350 px/s^2)")
	assert(idli.global_position.y > 100.0, "Global position Y must advance downwards")

	# Advance to ground contact - triggers universal bounce
	idli.global_position.y = 401.0
	idli._physics_process(0.016)
	assert(idli._bounces_left == 1, "Idli bounces on ground contact (bounces_left = 1)")
	assert(idli.ground_bounce_count == 1, "Idli ground_bounce_count incremented to 1")
	assert(idli._current_velocity.y < 0.0, "Idli upward bounce velocity applied")

	# Second bounce
	idli.global_position.y = 401.0
	idli._current_velocity.y = 100.0
	idli._physics_process(0.016)
	assert(idli._bounces_left == 0, "Bounces left reduced to 0 after second bounce")

	# Final ground impact (bounces exhausted)
	idli.global_position.y = 401.0
	idli._current_velocity.y = 100.0
	idli._physics_process(0.016)
	assert(idli._has_hit == true, "Final ground impact triggered when bounces exhausted")

	idli.queue_free()
	print("  ✓ Gravity acceleration, continuous descent, and ground impact confirmed!")

func _test_5_coconut_bounce_behavior(root: Window) -> void:
	print("-> [5/7] Verifying Coconut bounce physics, bounce count, and upward velocity...")
	var coconut_scene: PackedScene = load("res://scenes/modes/survival/obstacles/coconut_obstacle.tscn")
	var coconut: FoodObstacle = coconut_scene.instantiate()
	coconut.global_position = Vector2(250.0, 395.0)
	coconut.ground_y = 400.0
	root.add_child(coconut)

	assert(coconut.movement_type == FoodObstacle.MovementType.BOUNCE, "Coconut identity is BOUNCE")
	assert(coconut.max_bounces == 2, "Coconut configured with 2 bounces")
	assert(coconut._bounces_left == 2, "Bounces left starts at 2")

	# Trigger first bounce
	coconut.global_position.y = 401.0
	coconut._physics_process(0.016)

	assert(coconut._bounces_left == 1, "Bounces left reduced to 1 after bounce")
	assert(coconut._current_velocity.y < 0.0, "Bounce gives upward negative vertical velocity")

	# Trigger second bounce
	coconut.global_position.y = 401.0
	coconut._current_velocity.y = 100.0 # Moving downwards to hit road
	coconut._physics_process(0.016)
	assert(coconut._bounces_left == 0, "Bounces left reduced to 0 after second bounce")

	# Final impact
	coconut.global_position.y = 401.0
	coconut._current_velocity.y = 100.0
	coconut._physics_process(0.016)
	assert(coconut._has_hit == true, "Final impact triggers removal after exhausting bounces")

	coconut.queue_free()
	print("  ✓ Coconut multi-bounce physics and velocity reversals verified!")

func _test_6_ground_shadow_landing_alignment(root: Window) -> void:
	print("-> [6/7] Verifying GroundShadow landing prediction on uneven terrain...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.enable_obstacle_spawning = true
	surv.load_default_obstacles()
	root.add_child(surv)

	var dosa_scene: PackedScene = load("res://scenes/modes/survival/obstacles/dosa_obstacle.tscn")
	var dosa: FoodObstacle = dosa_scene.instantiate()
	dosa.terrain_generator = surv.terrain_generator
	surv.obstacle_container.add_child(dosa)
	dosa.global_position = Vector2(350.0, -100.0)
	dosa._physics_process(0.016)

	var pred_pos := dosa.calculate_predicted_landing()
	var expected_y := surv.get_terrain_surface_y(pred_pos.x)

	assert(absf(pred_pos.x - 350.0) < 0.1, "Straight/rotating falls land at spawn X")
	assert(absf(pred_pos.y - expected_y) < 1.0, "Predicted landing Y matches terrain surface height")

	if dosa.ground_shadow != null:
		assert(dosa.ground_shadow.global_position == pred_pos, "GroundShadow must align with predicted landing")
		assert(dosa.ground_shadow.modulate.a > 0.0, "GroundShadow must be visible")

	surv.queue_free()
	print("  ✓ GroundShadow accurately predicts terrain landing coordinates!")

func _test_7_pause_restart_and_game_over(root: Window) -> void:
	print("-> [7/7] Verifying spawning lifecycle: pause, game over, and clean restart...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.enable_obstacle_spawning = true
	surv.load_default_obstacles()
	root.add_child(surv)
	surv.start_run()

	# 1. Spawning runs during active play
	surv._spawn_timer = surv.base_spawn_interval
	surv._process(0.05)
	assert(surv.obstacle_container.get_child_count() >= 1, "Obstacle spawns during PLAYING state")

	# 2. Pause stops timer progression
	surv.toggle_pause()
	assert(surv.current_state == SurvivalController.RunState.PAUSED, "State is PAUSED")
	var timer_before := surv._spawn_timer
	surv._process(1.0)
	assert(surv._spawn_timer == timer_before, "Spawn timer frozen while paused")
	surv.toggle_pause()

	# 3. Game over stops spawning
	surv.finish_run("TEST GAME OVER")
	assert(surv.current_state == SurvivalController.RunState.FINISHED, "State is FINISHED")
	var count_at_over := surv.obstacle_container.get_child_count()
	surv._process(5.0)
	assert(surv.obstacle_container.get_child_count() == count_at_over, "No new obstacles spawn after game over")

	# 4. Restart clears container
	surv.start_run()
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "State reset to PLAYING")
	assert(surv.obstacle_container.get_child_count() == 0, "Obstacle container cleanly cleared on restart")

	surv.queue_free()
	print("  ✓ Spawning lifecycle safely responds to pause, game over, and restart!")
