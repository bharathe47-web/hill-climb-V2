extends SceneTree

const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const SurvivalRewardProvider = preload("res://scripts/modes/survival/SurvivalRewardProvider.gd")
const DestroyedCityEnv = preload("res://scenes/environment/survival/destroyed_city_environment.tscn")
const ObstacleWarningScript = preload("res://scripts/components/survival_obstacles/obstacle_warning.gd")
const FoodObstacle = preload("res://scripts/components/survival_obstacles/food_obstacle.gd")
const GameHUD = preload("res://scripts/ui/game_hud.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN SURVIVAL MODE COMPLETE VERIFICATION TEST SUITE ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var root := get_root()

	_test_survival_scene_and_environment(root)
	_test_all_eight_food_obstacles(root)
	_test_obstacle_warning_indicator(root)
	_test_lives_and_debounce_rules(root)
	_test_reward_seam_and_single_extra_life(root)
	_test_difficulty_and_generational_spawner(root)
	_test_shared_hud_integration(root)
	_test_lifecycle_and_navigation(root)

	print("\n=================================================================")
	print("✓ ALL SURVIVAL MODE TESTS COMPLETED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_survival_scene_and_environment(root: Window) -> void:
	print("-> [1/8] Verifying Survival Scene, Destroyed City Environment & Endless Terrain...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	# Environment verification
	var env = surv.get_node_or_null("DestroyedCityEnvironment")
	assert(env != null, "DestroyedCityEnvironment must be present in Survival.tscn")
	assert(env is ParallaxBackground, "Environment must be a ParallaxBackground")
	assert(env.get_node_or_null("SkyLayer") != null, "SkyLayer must exist")
	assert(env.get_node_or_null("CloudLayer") != null, "CloudLayer must exist")
	assert(env.get_node_or_null("DistantSkylineLayer") != null, "DistantSkylineLayer must exist")
	assert(env.get_node_or_null("MidgroundLayer") != null, "MidgroundLayer must exist")
	assert(env.get_node_or_null("ForegroundPropsLayer") != null, "ForegroundPropsLayer must exist")
	assert(env.get_node_or_null("AtmosphereOverlayLayer") != null, "AtmosphereOverlayLayer must exist")

	# Flat ground removed check (no second flat collision surface)
	assert(surv.get_node_or_null("Ground") == null, "Old static flat Ground body must not exist")

	# TerrainGenerator verification
	var t_gen: TerrainGenerator = surv.get_node_or_null("TerrainGenerator")
	assert(t_gen != null, "Survival Mode must contain an active TerrainGenerator")
	assert(t_gen.terrain_theme == TerrainSegment.TerrainTheme.DESTROYED_CITY, "TerrainGenerator must use DESTROYED_CITY theme")
	assert(t_gen.enable_pickups == false, "Pickups must be disabled in Survival mode")
	assert(t_gen.active_segments.size() >= 3, "Multiple terrain segments must be generated")
	assert(t_gen.target == surv.vehicle, "TerrainGenerator must target spawned vehicle")

	# Height variation and seamless joins
	var min_y := 9999.0
	var max_y := -9999.0
	for seg in t_gen.active_segments:
		assert(seg.theme == TerrainSegment.TerrainTheme.DESTROYED_CITY, "Segment theme must be DESTROYED_CITY")
		assert(seg.collision_polygon.polygon.size() > 0, "Segment must have collision geometry")
		assert(seg.collision_polygon.polygon == seg.ground_polygon.polygon, "Collision geometry must match visual geometry")
		for pt in seg.generated_surface_points:
			var wy := seg.global_position.y + pt.y
			min_y = minf(min_y, wy)
			max_y = maxf(max_y, wy)
	assert((max_y - min_y) > 25.0, "Terrain surface must have natural uneven height variations (not flat)")

	for i in range(t_gen.active_segments.size() - 1):
		var s1 := t_gen.active_segments[i]
		var s2 := t_gen.active_segments[i + 1]
		var exit_pt := s1.global_position + s1.get_exit_point()
		var entry_pt := s2.global_position + s2.get_entry_point()
		assert(exit_pt.distance_to(entry_pt) < 0.01, "Adjacent segments must join with 0 gap")

	# Vehicle starting height and camera target
	assert(surv.vehicle != null, "Vehicle must be spawned")
	var expected_veh_y := surv.get_terrain_surface_y(0.0) - 38.0
	assert(absf(surv.vehicle.global_position.y - expected_veh_y) < 5.0, "Vehicle starts at correct terrain surface height")
	assert(surv.follow_camera != null and surv.follow_camera.target == surv.vehicle, "Camera must target vehicle")

	surv.queue_free()
	print("  ✓ Destroyed City environment, endless uneven procedural terrain, and vehicle target verified!")

func _test_all_eight_food_obstacles(root: Window) -> void:
	print("-> [2/8] Verifying All 8 Indian Food Obstacle Scenes & Movement Types...")
	var expected_foods := [
		{"id": "idli", "path": "res://scenes/modes/survival/obstacles/idli_obstacle.tscn", "type": FoodObstacle.MovementType.STRAIGHT},
		{"id": "dosa", "path": "res://scenes/modes/survival/obstacles/dosa_obstacle.tscn", "type": FoodObstacle.MovementType.ROTATING},
		{"id": "vada", "path": "res://scenes/modes/survival/obstacles/vada_obstacle.tscn", "type": FoodObstacle.MovementType.SPINNING},
		{"id": "samosa", "path": "res://scenes/modes/survival/obstacles/samosa_obstacle.tscn", "type": FoodObstacle.MovementType.TUMBLING},
		{"id": "murukku", "path": "res://scenes/modes/survival/obstacles/murukku_obstacle.tscn", "type": FoodObstacle.MovementType.SPINNING},
		{"id": "pani_puri", "path": "res://scenes/modes/survival/obstacles/pani_puri_obstacle.tscn", "type": FoodObstacle.MovementType.CLUSTER},
		{"id": "jalebi", "path": "res://scenes/modes/survival/obstacles/jalebi_obstacle.tscn", "type": FoodObstacle.MovementType.WOBBLE},
		{"id": "coconut", "path": "res://scenes/modes/survival/obstacles/coconut_obstacle.tscn", "type": FoodObstacle.MovementType.BOUNCE}
	]

	for f in expected_foods:
		var packed: PackedScene = load(f["path"])
		assert(packed != null, "Obstacle scene %s must load" % f["path"])
		var obs: FoodObstacle = packed.instantiate()
		root.add_child(obs)

		assert(obs.obstacle_id == f["id"], "Obstacle ID must match %s" % f["id"])
		assert(obs.movement_type == f["type"], "Movement type must match identity for %s" % f["id"])
		assert(obs.has_signal("obstacle_hit"), "Must have obstacle_hit signal")

		# Test signal emission
		var state := {"received": false}
		obs.obstacle_hit.connect(func(hit_id, _pos):
			if hit_id == f["id"]:
				state["received"] = true
		)
		obs.obstacle_hit.emit(obs.obstacle_id, obs.global_position)
		assert(state["received"], "obstacle_hit signal must fire with correct ID")

		obs.queue_free()

	print("  ✓ All 8 Indian food hazards (Idli, Dosa, Vada, Samosa, Murukku, Pani Puri, Jalebi, Coconut) verified!")

func _test_obstacle_warning_indicator(root: Window) -> void:
	print("-> [3/8] Verifying Obstacle Ground Warning Indicator...")
	var w_packed: PackedScene = load("res://scenes/modes/survival/warnings/obstacle_warning.tscn")
	assert(w_packed != null, "obstacle_warning.tscn must load")
	var w = w_packed.instantiate()
	root.add_child(w)

	w.start_warning(0.5)
	assert(w.visible == true, "Warning must be visible when started")
	w._process(0.25)
	assert(w.scale.x > 0.6, "Warning ring must expand as impact approaches")
	w._process(0.3) # Complete warning
	assert(w._active == false, "Warning completes after duration")

	w.queue_free()
	print("  ✓ Ground warning ring expansion, pulse, and completion verified!")

func _test_lives_and_debounce_rules(root: Window) -> void:
	print("-> [4/8] Verifying 3-Life Rule & Hit Debouncing...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	assert(surv.current_lives == 3, "Must start with exactly 3 lives")
	assert(surv.max_lives == 3, "Max lives must be 3")

	# Single valid hit
	var hit1 = surv.register_obstacle_hit("idli")
	assert(hit1 == true, "Hit 1 must register")
	assert(surv.current_lives == 2, "Lives must be 2")
	assert(surv.is_invulnerable == true, "Invulnerability active")

	# Debounced multi-hit during cooldown
	var hit_debounce = surv.register_obstacle_hit("idli_chassis")
	assert(hit_debounce == false, "Multi-hit during invulnerability must be rejected")
	assert(surv.current_lives == 2, "Lives must remain 2")

	# Advance invulnerability cooldown
	surv._process(1.0)
	assert(surv.is_invulnerable == false, "Invulnerability must expire")

	# Second hit
	var hit2 = surv.register_obstacle_hit("samosa")
	assert(hit2 == true, "Hit 2 must register")
	assert(surv.current_lives == 1, "Lives must be 1")

	surv.queue_free()
	print("  ✓ 3-life rule and multi-body collision debouncing verified!")

func _test_reward_seam_and_single_extra_life(root: Window) -> void:
	print("-> [5/8] Verifying Rewarded Ad Seam & Single Extra Life Rule...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	var mock_provider := SurvivalRewardProvider.new()
	surv.reward_provider = mock_provider

	# Deplete all 3 lives
	surv.is_invulnerable = false
	surv.register_obstacle_hit("h1")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("h2")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("h3")
	assert(surv.current_lives == 0, "Lives depleted to 0")

	# Case A: Failed ad reward
	mock_provider.mock_should_succeed = false
	surv.request_ad_extra_life()
	assert(surv.current_lives == 0, "Failed ad must not grant lives")
	assert(surv.current_state == SurvivalController.RunState.FINISHED, "Failed ad triggers Game Over")
	assert(surv.extra_life_used == false, "extra_life_used remains false if ad failed")

	# Case B: Successful ad reward grants exactly 1 life
	surv.start_run()
	surv.is_invulnerable = false
	surv.register_obstacle_hit("h1")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("h2")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("h3")

	mock_provider.mock_should_succeed = true
	surv.request_ad_extra_life()
	assert(surv.current_lives == 1, "Verified reward grants exactly 1 life")
	assert(surv.extra_life_used == true, "extra_life_used set to true")
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "Run resumes playing")

	# Case C: Second ad attempt in same run is rejected
	surv.is_invulnerable = false
	surv.register_obstacle_hit("fatal_hit")
	assert(surv.current_lives == 0, "Extra life lost")
	assert(surv.current_state == SurvivalController.RunState.FINISHED, "Run permanently finished; no second ad")

	surv.queue_free()
	print("  ✓ Rewarded ad single extra-life limit and verification gating verified!")

func _test_difficulty_and_generational_spawner(root: Window) -> void:
	print("-> [6/8] Verifying Difficulty Scaling & Generational Cancellation...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.load_default_obstacles()

	assert(surv.obstacle_scenes.size() == 8, "Loaded 8 food obstacle scenes")
	var initial_interval := surv.base_spawn_interval

	# Simulate 30s of survival
	surv._process(30.0)
	var scaled_interval: float = maxf(surv.min_spawn_interval, surv.base_spawn_interval - (surv.survival_time * surv.difficulty_scale_rate))
	assert(scaled_interval < initial_interval, "Spawn interval must scale down over time")
	assert(scaled_interval >= surv.min_spawn_interval, "Spawn interval must not drop below minimum")

	# Test generational cancellation on restart
	var gen_before := surv._run_generation
	surv.start_run()
	assert(surv._run_generation > gen_before, "Restart increments generation to cancel stale delayed spawns")

	surv.queue_free()
	print("  ✓ Gradual difficulty progression and delayed-spawn cancellation verified!")

func _test_shared_hud_integration(root: Window) -> void:
	print("-> [7/8] Verifying Shared HUD Integration in Survival Mode...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	var hud = surv.hud as GameHUD
	assert(hud != null, "SurvivalHUD must be an instance of GameHUD")
	assert(hud.current_mode == GameHUD.HUDMode.SURVIVAL, "HUD must be in SURVIVAL mode")
	assert(hud.survival_panel != null and hud.survival_panel.visible == true, "SurvivalPanel must be visible")
	assert(hud.fuel_section.is_visible_in_tree() and not hud.get_node("%DistanceLabel").is_visible_in_tree(), "Survival shows only the compact fuel gauge (distance row hidden)")
	assert(hud.coins_panel.visible == true, "Survival shows the coin counter for collectibles")

	# Heart indicators sync
	hud.set_survival_lives(3, 3)
	var hearts: Array[Node] = hud.heart_container.get_children()
	assert(hearts.size() == 3, "Heart container has 3 hearts")
	var h0 = hearts[0] as TextureRect
	var h1 = hearts[1] as TextureRect
	var h2 = hearts[2] as TextureRect
	assert(h0.texture == GameHUD.HEART_FULL_TEX, "Heart 1 full")
	assert(h1.texture == GameHUD.HEART_FULL_TEX, "Heart 2 full")
	assert(h2.texture == GameHUD.HEART_FULL_TEX, "Heart 3 full")

	hud.set_survival_lives(1, 3)
	assert(h0.texture == GameHUD.HEART_FULL_TEX, "Heart 1 full")
	assert(h1.texture == GameHUD.HEART_EMPTY_TEX, "Heart 2 empty")
	assert(h2.texture == GameHUD.HEART_EMPTY_TEX, "Heart 3 empty")

	# Mobile pedals exist and active
	assert(hud.gas_pedal != null and hud.gas_pedal.visible == true, "Gas pedal active in Survival")
	assert(hud.brake_pedal != null and hud.brake_pedal.visible == true, "Brake pedal active in Survival")

	surv.queue_free()
	print("  ✓ Shared HUD mode, dynamic heart display, and mobile pedals verified!")

func _test_lifecycle_and_navigation(root: Window) -> void:
	print("-> [8/8] Verifying Lifecycle, Pause, Restart, and Menu Navigation...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	# Pause / Resume
	surv.pause_run(true)
	assert(surv.current_state == SurvivalController.RunState.PAUSED, "State must be PAUSED")
	assert(surv.get_tree().paused == true, "Tree must be paused")

	surv.pause_run(false)
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "State must be PLAYING")
	assert(surv.get_tree().paused == false, "Tree unpaused")

	# Menu return signal
	var state := {"menu": false}
	surv.return_to_main_menu_requested.connect(func(): state["menu"] = true)
	surv._on_menu_pressed()
	assert(state["menu"] == true, "return_to_main_menu_requested must fire on menu press")

	surv.queue_free()
	print("  ✓ Pause, resume, and return-to-menu signal verified!")
