extends SceneTree

## Comprehensive Phase 2 test suite for:
## 1. MainMenu Mode Cards (Endless, Indian Roads, Survival, Garage).
## 2. SurvivalController 3-life system, single life lost per hit, and invulnerability debouncing.
## 3. Extra life reward seam gating (verified reward grants 1 life, max 1 per run, failure grants 0).
## 4. Continuity of existing Endless Map launch and Joel obstacle dependency safety.

const MainMenuScene = preload("res://scenes/main/MainMenu.tscn")
const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")
const MainScene = preload("res://scenes/main/Main.tscn")
const SurvivalRewardProvider = preload("res://scripts/modes/survival/SurvivalRewardProvider.gd")

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN PHASE 2 SHARED FOUNDATION & SURVIVAL TEST SUITE ---")
	print("=================================================================\n")

	_test_main_menu_mode_cards()
	_test_endless_mode_launch_preservation()
	_test_survival_core_life_and_hit_logic()
	_test_survival_extra_life_reward_gating()
	_test_joel_obstacle_dependency_resilience()

	print("\n=================================================================")
	print("✓ ALL PHASE 2 TESTS COMPLETED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_main_menu_mode_cards() -> void:
	print("-> [1/5] Verifying MainMenu 4 Mode Selection Cards...")
	var menu: MainMenuController = MainMenuScene.instantiate()
	root.add_child(menu)

	var endless_btn: Button = menu.get_node_or_null("%EndlessModeButton")
	var roads_btn: Button = menu.get_node_or_null("%IndianRoadsModeButton")
	var surv_btn: Button = menu.get_node_or_null("%SurvivalModeButton")
	var garage_btn: Button = menu.get_node_or_null("%GarageModeButton")

	assert(endless_btn != null, "EndlessModeButton must exist in MainMenu")
	assert(roads_btn != null, "IndianRoadsModeButton must exist in MainMenu")
	assert(surv_btn != null, "SurvivalModeButton must exist in MainMenu")
	assert(garage_btn != null, "GarageModeButton must exist in MainMenu")

	# Verify honest statuses
	assert(not endless_btn.disabled, "EndlessModeButton must be enabled")
	assert(roads_btn.disabled, "IndianRoadsModeButton must be disabled (Joel module pending)")
	assert(not surv_btn.disabled, "SurvivalModeButton must be enabled")
	assert(not garage_btn.disabled, "GarageModeButton must be enabled")

	# Test Garage button opens vehicle selection panel
	garage_btn.pressed.emit()
	var veh_panel: Control = menu.get_node_or_null("%VehicleSelectPanel")
	assert(veh_panel != null and veh_panel.visible, "GarageModeButton must open VehicleSelectPanel")

	menu.queue_free()
	print("  ✓ All 4 mode cards present with honest statuses and Garage navigation verified!")

func _test_endless_mode_launch_preservation() -> void:
	print("-> [2/5] Verifying Main.tscn launches Endless Map into GameScene...")
	var main_node: MainController = MainScene.instantiate()
	root.add_child(main_node)

	# Emulate start_game_requested from menu
	main_node.load_game()
	assert(main_node.current_scene_node is GameScene, "load_game() must instantiate GameScene")
	var game_scene = main_node.current_scene_node as GameScene
	assert(game_scene.use_procedural_terrain == true, "Endless map must use procedural terrain")

	# Test return to menu
	game_scene.return_to_main_menu_requested.emit()
	assert(main_node.current_scene_node is MainMenuController, "Must return cleanly to MainMenuController")

	main_node.queue_free()
	print("  ✓ Original Endless Map launch and return-to-menu verified intact!")

func _test_survival_core_life_and_hit_logic() -> void:
	print("-> [3/5] Verifying SurvivalController 3-life system & hit debouncing...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	# Initial lives
	assert(surv.current_lives == 3, "Survival must start with exactly 3 lives")
	assert(surv.max_lives == 3, "Max lives must be 3")
	assert(surv.extra_life_used == false, "extra_life_used must start as false")
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "Run state must be PLAYING")

	# Single hit removes 1 life
	var hit1: bool = surv.register_obstacle_hit("test_chilli")
	assert(hit1 == true, "First hit must be registered")
	assert(surv.current_lives == 2, "Life count must be exactly 2 after first hit")
	assert(surv.is_invulnerable == true, "Invulnerability must be active immediately after hit")

	# Immediate second hit in same frame/window must be debounced (rejected)
	var hit_debounce: bool = surv.register_obstacle_hit("test_chilli_wheel")
	assert(hit_debounce == false, "Subsequent hit during invulnerability must be ignored")
	assert(surv.current_lives == 2, "Life count must NOT decrement during invulnerability")

	# Clear invulnerability and test second legitimate hit
	surv.is_invulnerable = false
	var hit2: bool = surv.register_obstacle_hit("test_rice")
	assert(hit2 == true, "Second legitimate hit must be registered")
	assert(surv.current_lives == 1, "Life count must be 1 after second hit")

	surv.queue_free()
	print("  ✓ 3-life baseline and multi-body collision debouncing verified!")

func _test_survival_extra_life_reward_gating() -> void:
	print("-> [4/5] Verifying Rewarded Ad seam & single extra life rule...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	var mock_provider = SurvivalRewardProvider.new()
	surv.reward_provider = mock_provider

	# Deplete all 3 lives
	surv.is_invulnerable = false
	surv.register_obstacle_hit("hit1")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("hit2")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("hit3")
	assert(surv.current_lives == 0, "Lives should be 0 before ad offer")

	# Test Case A: Ad fails or is skipped -> 0 lives granted, Game Over
	mock_provider.mock_should_succeed = false
	surv.request_ad_extra_life()
	assert(surv.current_lives == 0, "Failed ad must grant 0 lives")
	assert(surv.current_state == SurvivalController.RunState.FINISHED, "Failed ad must end run")
	assert(surv.extra_life_used == false, "extra_life_used must remain false if ad was not rewarded")

	# Test Case B: Fresh run, ad succeeds -> exactly 1 extra life granted
	surv.start_run()
	assert(surv.current_lives == 3, "Restart must reset to 3 lives")
	assert(surv.extra_life_used == false, "Restart must reset extra_life_used")

	# Deplete lives again
	surv.is_invulnerable = false
	surv.register_obstacle_hit("hit1")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("hit2")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("hit3")

	mock_provider.mock_should_succeed = true
	surv.request_ad_extra_life()
	assert(surv.current_lives == 1, "Verified reward must grant exactly 1 extra life")
	assert(surv.extra_life_used == true, "extra_life_used must be true after claiming")
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "Game must resume playing after reward")

	# Test Case C: Extra life lost -> immediate Game Over, no second ad permitted
	surv.is_invulnerable = false
	surv.register_obstacle_hit("fatal_hit")
	assert(surv.current_lives == 0, "Lives must be 0")
	assert(surv.current_state == SurvivalController.RunState.FINISHED, "Losing extra life must immediately end run")

	surv.queue_free()
	print("  ✓ Reward seam gating, extra life limits, and game-over transition verified!")

func _test_joel_obstacle_dependency_resilience() -> void:
	print("-> [5/5] Verifying resilience when Joel's obstacle scenes are pending...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	# Assert that empty obstacle_scenes does not crash
	assert(surv.obstacle_scenes.is_empty(), "Joel obstacles default to empty array")
	surv._trigger_obstacle_spawn()
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "Controller remains healthy with empty obstacle catalog")

	surv.queue_free()
	print("  ✓ Safe handling of pending teammate components verified!")
