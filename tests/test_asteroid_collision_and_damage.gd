extends SceneTree

const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")
const UnburnedAsteroidScene = preload("res://scenes/modes/survival/obstacles/unburned_asteroid_obstacle.tscn")
const BurningAsteroidScene = preload("res://scenes/modes/survival/obstacles/burning_asteroid_obstacle.tscn")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN ASTEROID COLLISION & LIFE REDUCTION TEST SUITE ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var surv = SurvivalScene.instantiate()
	root.add_child(surv)
	for i in range(10):
		await process_frame
		
	var controller = surv
	var veh = controller.vehicle
	assert(veh != null, "Vehicle must exist in Survival scene")
	
	# =========================================================================
	# TEST 1: Normal (Unburned) Asteroid Direct Collision & Life Reduction
	# =========================================================================
	print("-> [1/4] Testing Normal (Unburned) Asteroid Direct Collision...")
	var initial_lives = controller.current_lives
	print("  • Starting lives: %d" % initial_lives)
	assert(initial_lives == 3, "Survival mode must start with 3 lives")
	
	var ast = controller._trigger_unburned_asteroid_spawn()
	if ast == null:
		ast = UnburnedAsteroidScene.instantiate()
		controller.obstacle_container.add_child(ast)
		ast.obstacle_hit.connect(controller._on_obstacle_reported_hit.bind(ast))
	
	ast.setup_spawn(veh.global_position.x, veh.global_position.y - 100.0, veh.global_position.y + 20.0)
	ast.horizontal_speed = 0.0
	ast._velocity.x = 0.0
	
	var normal_hit := false
	for f in range(60):
		await physics_frame
		if controller.current_lives < initial_lives and not normal_hit:
			normal_hit = true
			print("  • Normal asteroid hit registered at frame %d! Lives: %d" % [f, controller.current_lives])
			assert(controller.is_invulnerable, "Controller must enter invulnerability state immediately upon hit")
			var dup_blocked = controller.register_obstacle_hit("unburned_asteroid", null)
			assert(dup_blocked == false, "Duplicate damage must be blocked during invulnerability window")
			break
			
	assert(normal_hit, "Normal asteroid must detect collision with car")
	assert(controller.current_lives == initial_lives - 1, "Normal asteroid collision must reduce player life by exactly 1")
	print("  ✓ Test A PASSED: Normal asteroid collision and life reduction verified!")
	
	# Wait for invulnerability to expire (0.8s cooldown)
	print("  • Awaiting invulnerability expiry (0.8s cooldown)...")
	while controller.is_invulnerable:
		await physics_frame
	print("  • Cooldown expired. Controller ready for subsequent hazard.")

	# =========================================================================
	# TEST 2: Flaming Asteroid Direct Collision & Life Reduction
	# =========================================================================
	print("\n-> [2/4] Testing Flaming Asteroid Direct Collision...")
	var lives_before_flaming = controller.current_lives
	var b_ast = controller._trigger_burning_asteroid_spawn()
	if b_ast == null:
		b_ast = BurningAsteroidScene.instantiate()
		controller.obstacle_container.add_child(b_ast)
		b_ast.obstacle_hit.connect(controller._on_obstacle_reported_hit.bind(b_ast))
		
	b_ast.setup_spawn(veh.global_position.x, veh.global_position.y - 100.0, veh.global_position.y + 20.0)
	b_ast.horizontal_speed = 0.0
	b_ast._velocity.x = 0.0
	
	var flaming_hit := false
	for f in range(60):
		await physics_frame
		if controller.current_lives < lives_before_flaming and not flaming_hit:
			flaming_hit = true
			print("  • Flaming asteroid hit registered at frame %d! Lives: %d" % [f, controller.current_lives])
			assert(controller.is_invulnerable, "Must enter invulnerability state immediately upon flaming asteroid hit")
			var dup_blocked = controller.register_obstacle_hit("burning_asteroid", null)
			assert(dup_blocked == false, "VFX/particles must not cause duplicate damage")
			break
			
	assert(flaming_hit, "Flaming asteroid must detect collision with car")
	assert(controller.current_lives == lives_before_flaming - 1, "Flaming asteroid collision must reduce player life by exactly 1")
	print("  ✓ Test B PASSED: Flaming asteroid collision, life reduction, and single-damage verified!")

	# =========================================================================
	# TEST 3: Car Moving into Asteroid (Relative Velocity & Both Moving)
	# =========================================================================
	print("\n-> [3/4] Testing Car Moving into Asteroid...")
	while controller.is_invulnerable:
		await physics_frame
	var lives_before_car_move = controller.current_lives
	
	var ast_front = UnburnedAsteroidScene.instantiate()
	controller.obstacle_container.add_child(ast_front)
	ast_front.setup_spawn(veh.global_position.x + 30.0, veh.global_position.y - 10.0, veh.global_position.y + 20.0)
	ast_front.horizontal_speed = 0.0
	ast_front.fall_speed = 0.0
	ast_front._velocity = Vector2.ZERO
	ast_front.obstacle_hit.connect(controller._on_obstacle_reported_hit.bind(ast_front))
	
	veh.linear_velocity = Vector2(160.0, 0.0)
	var car_move_hit := false
	for f in range(30):
		await physics_frame
		if controller.current_lives < lives_before_car_move and not car_move_hit:
			car_move_hit = true
			print("  • Car drove into asteroid! Hit registered at frame %d" % f)
			break
			
	assert(car_move_hit, "Collision when car drives into asteroid must be detected")
	assert(controller.current_lives == lives_before_car_move - 1, "Life must be reduced when driving into asteroid")
	print("  ✓ Test C PASSED: Car moving into asteroid collision verified!")

	# =========================================================================
	# TEST 4: Game Over Activation when Lives Depleted
	# =========================================================================
	print("\n-> [4/4] Verifying Game Over / Depletion when Lives Reach 0...")
	assert(controller.current_lives == 0, "All 3 lives must now be exhausted")
	assert(controller.current_state != controller.RunState.PLAYING or veh.freeze == true, "Gameplay must halt upon life depletion")
	print("  ✓ Test D PASSED: Game over lifecycle activates when lives reach zero!")

	surv.queue_free()
	print("\n=================================================================")
	print("✓ ALL ASTEROID COLLISION AND LIFE REDUCTION TESTS PASSED (100%)!")
	print("=================================================================\n")
	quit(0)
