extends SceneTree

## test_core_architecture_and_navigation.gd
## Verifies Phase 1 Core Game Architecture, Unified Scene Navigation,
## GarageMenu integration, StateSelection integration, and SaveManager progression.

const MainScene = preload("res://scenes/main/Main.tscn")
const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const GarageMenu = preload("res://scripts/ui/GarageMenu.gd")

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 1 CORE ARCHITECTURE & NAVIGATION TEST SUITE ---")
	print("=================================================================")
	
	SaveManager.custom_save_path = "user://test_rebuild_architecture_save.json"
	SaveManager.reset_save()

	# -----------------------------------------------------------------
	# 1. BOOTSTRAP MAIN SCENE
	# -----------------------------------------------------------------
	print("-> [1/5] Bootstrapping Main.tscn into Viewport...")
	var main_inst: MainController = MainScene.instantiate() as MainController
	root.add_child(main_inst)

	for f in range(5):
		await process_frame

	assert(main_inst.current_scene_node is MainMenuController, "Initial scene must be MainMenuController")
	var menu := main_inst.current_scene_node as MainMenuController
	print("  ✓ MainMenu instantiated and displayed by default")

	# -----------------------------------------------------------------
	# 2. TEST TRANSITION: MAIN MENU -> GARAGE -> MAIN MENU
	# -----------------------------------------------------------------
	print("-> [2/5] Testing MainMenu -> GarageMenu -> MainMenu transition...")
	menu.open_garage_requested.emit()
	for f in range(5):
		await process_frame

	assert(main_inst.current_scene_node is GarageMenu, "Scene must be GarageMenu")
	var garage := main_inst.current_scene_node as GarageMenu
	assert(garage.vehicles_list.size() == 4, "Garage must load 4 registered vehicles")
	assert(garage.coin_label.text == "0", "Initial coins must be 0")
	print("  ✓ GarageMenu instantiated with all 4 vehicles from VehicleRegistry")

	# Test Garage upgrades & purchases
	SaveManager.add_coins(1000)
	garage._update_view()
	assert(garage.coin_label.text == "1000", "Garage coin label must reflect added coins")

	# Upgrade engine
	var initial_engine_lvl := SaveManager.get_upgrade_level("blue_flame_truck", "engine")
	garage._on_upgrade_stat("blue_flame_truck", "engine")
	assert(SaveManager.get_upgrade_level("blue_flame_truck", "engine") == initial_engine_lvl + 1, "Engine level must increment")
	print("  ✓ Vehicle stat upgrade persisted in SaveManager")

	# Unlock second vehicle (orc_racer, cost 350)
	garage.current_vehicle_index = 1 # orc_racer
	garage._update_view()
	garage._on_select_or_buy()
	assert(SaveManager.is_vehicle_unlocked("orc_racer"), "Orc Racer must be unlocked")
	assert(SaveManager.get_selected_vehicle_id() == "orc_racer", "Active vehicle must switch to Orc Racer")
	print("  ✓ Vehicle purchase and active selection verified in Garage")

	# Return to menu
	garage.back_pressed.emit()
	for f in range(5):
		await process_frame
	assert(main_inst.current_scene_node is MainMenuController, "Must return to MainMenuController")
	menu = main_inst.current_scene_node as MainMenuController
	print("  ✓ Return from Garage to MainMenu verified")

	# -----------------------------------------------------------------
	# 3. TEST TRANSITION: MAIN MENU -> INDIAN ROADS (STATE SELECTION)
	# -----------------------------------------------------------------
	print("-> [3/5] Testing MainMenu -> Indian Roads (StateSelection) -> MainMenu...")
	menu.start_indian_roads_requested.emit()
	for f in range(8):
		await process_frame

	assert(main_inst.current_scene_node is IndianRoadsControllerV2, "Scene must be IndianRoadsControllerV2")
	var roads := main_inst.current_scene_node as IndianRoadsControllerV2
	assert(is_instance_valid(roads.state_selection_view), "StateSelection view must be instantiated")
	assert(roads.state_selection_view.visible, "StateSelection screen must be visible on entry")
	print("  ✓ Indian Roads starts directly into the interactive StateSelection Hub")

	# Return to menu from StateSelection
	roads.state_selection_view.return_to_main_menu_requested.emit()
	for f in range(5):
		await process_frame
	assert(main_inst.current_scene_node is MainMenuController, "Must return to MainMenuController")
	menu = main_inst.current_scene_node as MainMenuController
	print("  ✓ Return from StateSelection to MainMenu verified")

	# -----------------------------------------------------------------
	# 4. TEST TRANSITION: MAIN MENU -> SURVIVAL -> MAIN MENU
	# -----------------------------------------------------------------
	print("-> [4/5] Testing MainMenu -> Survival Mode -> MainMenu...")
	menu.start_survival_requested.emit()
	for f in range(5):
		await process_frame

	assert(main_inst.current_scene_node is SurvivalController, "Scene must be SurvivalController")
	var surv := main_inst.current_scene_node as SurvivalController
	assert(surv.current_lives == 3, "Survival mode must initialize with 3 lives")
	surv.return_to_main_menu_requested.emit()
	for f in range(5):
		await process_frame
	assert(main_inst.current_scene_node is MainMenuController, "Must return to MainMenuController")
	menu = main_inst.current_scene_node as MainMenuController
	print("  ✓ Survival Mode entry and return verified")

	# -----------------------------------------------------------------
	# 5. TEST TRANSITION: MAIN MENU -> ENDLESS MAP -> MAIN MENU
	# -----------------------------------------------------------------
	print("-> [5/5] Testing MainMenu -> Endless Map -> MainMenu...")
	menu.start_game_requested.emit()
	for f in range(5):
		await process_frame

	assert(main_inst.current_scene_node is GameScene, "Scene must be GameScene")
	var game := main_inst.current_scene_node as GameScene
	assert(game.get_node_or_null("SnowfallManager") == null, "SnowfallManager must NOT exist in default Endless Mode")
	game.return_to_main_menu_requested.emit()
	for f in range(5):
		await process_frame
	assert(main_inst.current_scene_node is MainMenuController, "Must return to MainMenuController")
	print("  ✓ Endless Map entry and return verified (Snowfall removed)")

	main_inst.queue_free()
	print("\n=================================================================")
	print("✓ ALL 5/5 PHASE 1 CORE ARCHITECTURE & NAVIGATION CHECKS PASSED (100%)!")
	print("=================================================================")
	quit(0)
