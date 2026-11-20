extends SceneTree

const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const SurvivalDifficultyConfig = preload("res://scripts/modes/survival/SurvivalDifficultyConfig.gd")
const SurvivalDifficultyMenu = preload("res://scripts/ui/survival/SurvivalDifficultyMenu.gd")
const SurvivalDifficultyMenuScene = preload("res://scenes/ui/survival/SurvivalDifficultyMenu.tscn")
const MainMenuScene = preload("res://scenes/main/MainMenu.tscn")
const MainMenuController = preload("res://scripts/core/MainMenuController.gd")
const SaveManager = preload("res://scripts/core/SaveManager.gd")
const UnburnedAsteroid = preload("res://scripts/components/survival_obstacles/unburned_asteroid.gd")
const BurningAsteroid = preload("res://scripts/components/survival_obstacles/burning_asteroid.gd")
const PotholeHazard = preload("res://scripts/components/survival_obstacles/pothole_hazard.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN SURVIVAL MODE THREE-DIFFICULTY VERIFICATION SUITE ---")
	print("=================================================================\n")

	await _test_difficulty_selection_ui(root)
	await _test_easy_mode_rules(root)
	await _test_medium_mode_rules(root)
	await _test_hard_mode_rules(root)
	await _test_lifecycle_retry_and_persistence(root)

	print("\n=================================================================")
	print("✓ ALL THREE-DIFFICULTY SURVIVAL MODE TESTS PASSED (100% SUCCESS)!")
	print("=================================================================\n")
	quit(0)

# ====================================================================
# 1. DIFFICULTY SELECTION UI TESTS
# ====================================================================
func _test_difficulty_selection_ui(win: Window) -> void:
	print("-> [1/5] Verifying Survival Difficulty Selection UI & User Flow...")

	# A. Test MainMenu integration
	var menu: MainMenuController = MainMenuScene.instantiate()
	win.add_child(menu)
	for i in range(3):
		await process_frame

	assert(menu.survival_sign != null, "Survival signboard must exist on MainMenu")
	assert(menu.difficulty_menu != null, "SurvivalDifficultyMenu instance must exist in MainMenu")
	assert(not menu.difficulty_menu.is_visible_in_tree(), "Difficulty menu initially hidden on MainMenu")

	# 1. Click Survival Mode -> Opens difficulty-selection screen
	menu.survival_sign.pressed.emit()
	assert(menu.difficulty_menu.is_visible_in_tree(), "Difficulty menu becomes visible when Survival selected")

	# 2. All three difficulty cards are visible
	var diff_menu: SurvivalDifficultyMenu = menu.difficulty_menu as SurvivalDifficultyMenu
	assert(diff_menu.easy_card != null and diff_menu.easy_card.is_visible_in_tree(), "Easy card must be visible")
	assert(diff_menu.medium_card != null and diff_menu.medium_card.is_visible_in_tree(), "Medium card must be visible")
	assert(diff_menu.hard_card != null and diff_menu.hard_card.is_visible_in_tree(), "Hard card must be visible")

	# 3, 4, 5, 6. Selection of Easy, Medium, Hard and selected-state indication
	diff_menu.select_difficulty(SurvivalDifficultyConfig.Difficulty.EASY)
	assert(diff_menu.get_selected_difficulty() == SurvivalDifficultyConfig.Difficulty.EASY, "Easy must be selected")
	assert(diff_menu.easy_highlight.visible == true, "Easy highlight must be visible")
	assert(diff_menu.medium_highlight.visible == false, "Medium highlight must be hidden")
	assert(diff_menu.hard_highlight.visible == false, "Hard highlight must be hidden")

	diff_menu.select_difficulty(SurvivalDifficultyConfig.Difficulty.MEDIUM)
	assert(diff_menu.get_selected_difficulty() == SurvivalDifficultyConfig.Difficulty.MEDIUM, "Medium must be selected")
	assert(diff_menu.easy_highlight.visible == false, "Easy highlight must be hidden")
	assert(diff_menu.medium_highlight.visible == true, "Medium highlight must be visible")
	assert(diff_menu.hard_highlight.visible == false, "Hard highlight must be hidden")

	diff_menu.select_difficulty(SurvivalDifficultyConfig.Difficulty.HARD)
	assert(diff_menu.get_selected_difficulty() == SurvivalDifficultyConfig.Difficulty.HARD, "Hard must be selected")
	assert(diff_menu.easy_highlight.visible == false, "Easy highlight must be hidden")
	assert(diff_menu.medium_highlight.visible == false, "Medium highlight must be hidden")
	assert(diff_menu.hard_highlight.visible == true, "Hard highlight must be visible")

	# 7. Start button launches the selected difficulty
	var signal_state := {"emitted": false, "diff": -1}
	menu.start_survival_requested.connect(func(diff: int):
		signal_state["emitted"] = true
		signal_state["diff"] = diff
	)
	diff_menu.start_button.pressed.emit()
	assert(signal_state["emitted"] == true, "start_survival_requested signal must be emitted")
	assert(signal_state["diff"] == SurvivalDifficultyConfig.Difficulty.HARD, "Signal must pass selected difficulty HARD")

	# 8. Back button returns correctly
	diff_menu.back_button.pressed.emit()
	assert(not diff_menu.is_visible_in_tree(), "Difficulty menu must hide on back press")
	assert(not menu.difficulty_layer.visible, "Difficulty layer closes and home screen is restored")

	menu.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ Difficulty selection screen, cards, highlights, and transitions verified!")

# ====================================================================
# 2. EASY MODE RULES TESTS
# ====================================================================
func _test_easy_mode_rules(win: Window) -> void:
	print("-> [2/5] Verifying Easy Mode Rules (Food with Warnings, No Asteroids, No Potholes)...")

	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.selected_difficulty = SurvivalDifficultyConfig.Difficulty.EASY
	surv.enable_obstacle_spawning = true
	surv.use_default_food_obstacles = true
	win.add_child(surv)
	for i in range(3):
		await process_frame

	assert(surv.selected_difficulty == SurvivalDifficultyConfig.Difficulty.EASY, "Selected difficulty is EASY")
	assert(surv.difficulty_config.get("food_obstacles", false) == true, "Food obstacles must be enabled in Easy")
	assert(surv.difficulty_config.get("food_warnings", false) == true, "Warning indicators enabled for food")
	assert(surv.difficulty_config.get("unburned_asteroids", true) == false, "Unburned asteroids MUST be disabled in Easy")
	assert(surv.difficulty_config.get("burning_asteroids", true) == false, "Burning asteroids MUST be disabled in Easy")
	assert(surv.difficulty_config.get("potholes", true) == false, "Potholes MUST be disabled in Easy")

	# 1. All eight food obstacle scenes registered
	assert(surv.obstacle_scenes.size() == 8, "All 8 Indian food obstacle scenes registered")

	# 2 & 3. Normal obstacle spawn triggers warning indicator
	var warning_state := {"caught": false, "target": Vector2.ZERO}
	surv.warning_requested.connect(func(pos: Vector2, _dur: float):
		warning_state["caught"] = true
		warning_state["target"] = pos
	)

	surv._trigger_obstacle_spawn()
	assert(warning_state["caught"] == true, "Normal food obstacle MUST trigger warning indicator")
	assert(warning_state["target"] != Vector2.ZERO, "Warning indicator target pos must be set")

	# Check children in obstacle_container
	var container_children = surv.obstacle_container.get_children()
	assert(container_children.size() >= 1, "Food obstacle spawned in obstacle_container")
	for child in container_children:
		assert(not (child is UnburnedAsteroid), "No UnburnedAsteroid in Easy Mode")
		assert(not (child is BurningAsteroid), "No BurningAsteroid in Easy Mode")
		assert(not (child is PotholeHazard), "No PotholeHazard in Easy Mode")

	# 4 & 5. Unburned and burning asteroid inactive in Easy config
	assert(surv.difficulty_config["unburned_asteroids"] == false, "Unburned asteroids inactive in Easy config")
	assert(surv.difficulty_config["burning_asteroids"] == false, "Burning asteroids inactive in Easy config")

	# 6. Potholes are never created in Easy
	assert(surv._active_potholes.is_empty(), "No active potholes in Easy Mode")

	surv.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ Easy Mode: 8 food hazards with warnings verified; asteroid/pothole threats disabled!")

# ====================================================================
# 3. MEDIUM MODE RULES TESTS
# ====================================================================
func _test_medium_mode_rules(win: Window) -> void:
	print("-> [3/5] Verifying Medium Mode Rules (Food + Silent Unburned Asteroids)...")

	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.selected_difficulty = SurvivalDifficultyConfig.Difficulty.MEDIUM
	surv.enable_obstacle_spawning = true
	surv.use_default_food_obstacles = true
	win.add_child(surv)
	for i in range(3):
		await process_frame

	assert(surv.selected_difficulty == SurvivalDifficultyConfig.Difficulty.MEDIUM, "Selected difficulty is MEDIUM")
	assert(surv.difficulty_config.get("food_obstacles", false) == true, "Food obstacles enabled in Medium")
	assert(surv.difficulty_config.get("food_warnings", false) == true, "Food warnings enabled in Medium")
	assert(surv.difficulty_config.get("unburned_asteroids", false) == true, "Unburned asteroids ENABLED in Medium")
	assert(surv.difficulty_config.get("burning_asteroids", true) == false, "Burning asteroids DISABLED in Medium")
	assert(surv.difficulty_config.get("potholes", true) == false, "Potholes DISABLED in Medium")

	# 1 & 2. Food obstacles still spawn and have warnings
	var warning_state := {"count": 0}
	surv.warning_requested.connect(func(_pos: Vector2, _dur: float):
		warning_state["count"] += 1
	)

	surv._trigger_obstacle_spawn()
	assert(warning_state["count"] == 1, "Food obstacle in Medium MUST emit warning sign")

	# 3 & 4. Unburned asteroids spawn and DO NOT trigger warning indicators
	var prev_warning_count: int = warning_state["count"]
	var ast := surv._trigger_unburned_asteroid_spawn()
	assert(ast != null, "Unburned asteroid must spawn successfully")
	assert(ast is UnburnedAsteroid, "Spawned node must be UnburnedAsteroid")
	assert(warning_state["count"] == prev_warning_count, "CRITICAL: Unburned asteroid MUST NOT trigger warning indicators!")

	# Direct hit damages vehicle
	assert(surv.current_lives == 3, "Starts with 3 lives")
	surv._on_obstacle_reported_hit("unburned_asteroid", ast.global_position, ast)
	assert(surv.current_lives == 2, "Unburned asteroid direct hit deducts 1 life")

	# 5 & 6. Burning asteroids and potholes do not exist in Medium
	assert(surv.difficulty_config["burning_asteroids"] == false, "Burning asteroids disabled in Medium")
	assert(surv.difficulty_config["potholes"] == false, "Potholes disabled in Medium")
	assert(surv._active_potholes.is_empty(), "No potholes in Medium")

	surv.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ Medium Mode: Silent unburned asteroids with 0 warnings & damage verified!")

# ====================================================================
# 4. HARD MODE RULES TESTS
# ====================================================================
func _test_hard_mode_rules(win: Window) -> void:
	print("-> [4/5] Verifying Hard Mode Rules (Food + Asteroids + Fire + Road Potholes)...")

	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.selected_difficulty = SurvivalDifficultyConfig.Difficulty.HARD
	surv.enable_obstacle_spawning = true
	surv.use_default_food_obstacles = true
	win.add_child(surv)
	for i in range(3):
		await process_frame

	assert(surv.selected_difficulty == SurvivalDifficultyConfig.Difficulty.HARD, "Selected difficulty is HARD")
	assert(surv.difficulty_config.get("food_obstacles", false) == true, "Food obstacles enabled in Hard")
	assert(surv.difficulty_config.get("unburned_asteroids", false) == true, "Unburned asteroids enabled in Hard")
	assert(surv.difficulty_config.get("burning_asteroids", false) == true, "Burning asteroids enabled in Hard")
	assert(surv.difficulty_config.get("potholes", false) == true, "Potholes enabled in Hard")

	# 1 & 2. Food obstacle has warning
	var warning_state := {"count": 0}
	surv.warning_requested.connect(func(_pos: Vector2, _dur: float):
		warning_state["count"] += 1
	)
	surv._trigger_obstacle_spawn()
	assert(warning_state["count"] == 1, "Food obstacle in Hard emits warning")

	# 3 & 4 & 5. Unburned and Burning asteroids spawn with NO warnings
	var ast_unburned := surv._trigger_unburned_asteroid_spawn()
	assert(ast_unburned != null and ast_unburned is UnburnedAsteroid, "Unburned asteroid spawned")
	assert(warning_state["count"] == 1, "Unburned asteroid MUST NOT emit warning")

	var ast_burning := surv._trigger_burning_asteroid_spawn()
	assert(ast_burning != null and ast_burning is BurningAsteroid, "Burning asteroid spawned")
	assert(warning_state["count"] == 1, "Burning asteroid MUST NOT emit warning")

	# 6 & 7. Burning asteroid impact creates a pothole at impact position
	var impact_pos := Vector2(450.0, surv.get_terrain_surface_y(450.0))
	surv._on_burning_asteroid_ground_impact(impact_pos, 0.05)
	assert(surv._active_potholes.size() >= 1, "Pothole created upon burning asteroid impact")
	var pothole: PotholeHazard = surv._active_potholes[0] as PotholeHazard
	assert(pothole != null, "Pothole instance is valid PotholeHazard")
	assert(pothole.global_position == impact_pos, "Pothole matches burning asteroid impact position")

	# 8. Pothole interacts correctly with vehicle
	var veh := surv.vehicle as VehicleController
	assert(veh != null, "Vehicle must exist in Survival")
	var initial_vel_x := 100.0
	veh.linear_velocity = Vector2(initial_vel_x, 0.0)

	# Simulate vehicle entering pothole
	pothole._handle_vehicle_interaction(veh)
	assert(veh.linear_velocity.x < initial_vel_x, "Pothole must apply speed penalty factor to vehicle")
	assert(surv.follow_camera.trauma > 0.0, "Pothole interaction triggers camera trauma shake")

	# 9. Multiple potholes placement verification
	surv.create_pothole_at(Vector2(600.0, 420.0), -0.08)
	surv.create_pothole_at(Vector2(750.0, 430.0), 0.12)
	assert(surv._active_potholes.size() == 3, "Multiple potholes coexist without destabilizing system")

	surv.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ Hard Mode: Burning asteroid impact, road pothole creation & vehicle physics verified!")

# ====================================================================
# 5. LIFECYCLE, RETRY AND PERSISTENCE TESTS
# ====================================================================
func _test_lifecycle_retry_and_persistence(win: Window) -> void:
	print("-> [5/5] Verifying Lifecycle, Retry Difficulty Retention, Pause & Spawner Cleanup...")

	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.set_difficulty(SurvivalDifficultyConfig.Difficulty.HARD)
	surv.enable_obstacle_spawning = true
	surv.use_default_food_obstacles = true
	win.add_child(surv)
	for i in range(3):
		await process_frame

	# 1. Pause stops hazard spawning
	surv.pause_run(true)
	assert(surv.current_state == SurvivalController.RunState.PAUSED, "State must be PAUSED")
	var timer_before := surv._spawn_timer
	surv._process(0.5)
	assert(surv._spawn_timer == timer_before, "Pause stops spawner timers from advancing")

	# 2. Resume restores hazard spawning
	surv.pause_run(false)
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "State resumed to PLAYING")
	surv._process(0.5)
	assert(surv._spawn_timer > timer_before, "Resume restores spawner timer advancement")

	# 3. Game Over stops all hazard spawning
	surv.finish_run("TEST RUN COMPLETED")
	assert(surv.current_state == SurvivalController.RunState.FINISHED, "State is FINISHED")
	var timer_after_finish := surv._spawn_timer
	surv._process(1.0)
	assert(surv._spawn_timer == timer_after_finish, "Finished state stops all hazard spawning")

	# Spawn test hazards and potholes before Retry
	surv.set_difficulty(SurvivalDifficultyConfig.Difficulty.HARD)
	surv.enable_obstacle_spawning = true
	surv._trigger_obstacle_spawn()
	surv._trigger_unburned_asteroid_spawn()
	surv.create_pothole_at(Vector2(500.0, 420.0))
	assert(surv.obstacle_container.get_child_count() > 0, "Container has active hazards before retry")
	assert(surv._active_potholes.size() > 0, "Active potholes exist before retry")

	# 4 & 5. Retry preserves the selected difficulty and clears old hazards and potholes
	surv._on_retry_pressed()
	assert(surv.selected_difficulty == SurvivalDifficultyConfig.Difficulty.HARD, "Retry must PRESERVE Hard difficulty")
	assert(surv.current_lives == surv.max_lives, "Retry restores 3 lives")
	assert(surv._active_potholes.is_empty(), "Retry clears all active potholes")
	assert(surv.survival_time == 0.0, "Survival time reset to 0.0s")
	assert(surv.survival_distance == 0.0, "Survival distance reset to 0m")

	# 6. Generational cancellation test
	var old_gen := surv._run_generation
	surv.start_run()
	assert(surv._run_generation > old_gen, "Generation counter increments to invalidate old callbacks")

	# 7. Return to main menu requested
	var menu_state := {"requested": false}
	surv.return_to_main_menu_requested.connect(func(): menu_state["requested"] = true)
	surv._on_menu_pressed()
	assert(menu_state["requested"] == true, "Return to main menu signal must be emitted")

	surv.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ Lifecycle, pause, game-over, retry preservation, and spawner cleanup verified!")
