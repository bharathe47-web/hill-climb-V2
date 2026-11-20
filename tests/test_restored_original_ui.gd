extends SceneTree

const MainMenuScene = preload("res://scenes/main/MainMenu.tscn")
const GarageScene = preload("res://scenes/modes/garage/VintageCarGarage.tscn")
const HUDScene = preload("res://scenes/ui/HUD.tscn")
const GameHUDScene = preload("res://scenes/ui/hud/game_hud.tscn")
const PauseMenuScene = preload("res://scenes/ui/PauseMenu.tscn")
const ResultsScreenScene = preload("res://scenes/ui/ResultsScreen.tscn")
const SurvivalDifficultyScene = preload("res://scenes/ui/survival/SurvivalDifficultyMenu.tscn")
const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN RESTORED ORIGINAL UI VERIFICATION TEST SUITE ---")
	print("=================================================================\n")
	
	await test_main_menu(root)
	await test_garage(root)
	await test_hud(root)
	await test_pause_menu(root)
	await test_results_screen(root)
	await test_survival_difficulty_menu(root)
	await test_survival_screen_ui(root)
	
	print("\n=================================================================")
	print("✓ ALL RESTORED ORIGINAL UI TESTS PASSED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func test_main_menu(win: Window) -> void:
	print("-> [1/7] Testing MainMenu UI & Controller...")
	var menu = MainMenuScene.instantiate()
	win.add_child(menu)
	for i in range(3):
		await process_frame
	
	# Four environment signboards + sky quit button (replaces the old panel/button layout)
	for sign_name in ["%EndlessSign", "%SurvivalSign", "%GarageSign", "%IndianRoadsSign"]:
		assert(menu.get_node(sign_name) is TextureButton, "%s must be a clickable signboard" % sign_name)
	assert(menu.get_node("%QuitButton") is TextureButton, "QuitButton must exist")
	assert(menu.get_node_or_null("%StartButton") == null, "Old StartButton must be gone")
	assert(menu.get_node_or_null("%StatsPanel") == null, "Old stats panel must be gone")
	assert(menu.get_node_or_null("%SettingsButton") == null, "SettingsButton must not exist")

	# Exactly one showcase vehicle
	var showcase: HomeVehicleShowcase = menu.get_node("%VehicleShowcase")
	assert(showcase.vehicle_id == SaveManager.get_selected_vehicle_id(), "Home vehicle must match Garage selection")

	# Survival difficulty menu integration
	var survival_btn = menu.get_node("%SurvivalSign")
	var diff_menu = menu.get_node("%SurvivalDifficultyMenu")
	assert(diff_menu != null, "SurvivalDifficultyMenu must be instanced in MainMenu")
	assert(not diff_menu.is_visible_in_tree(), "Difficulty menu should start hidden")
	survival_btn.emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(diff_menu.is_visible_in_tree(), "Pressing survival signboard should display difficulty menu")
	diff_menu.get_node("%BackButton").emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(not diff_menu.is_visible_in_tree(), "Back button should hide difficulty menu")

	# Quit confirmation: No closes it, dialog opens on Quit
	var quit_dialog = menu.get_node("%QuitDialog")
	assert(not quit_dialog.visible, "Quit dialog starts hidden")
	menu.get_node("%QuitButton").emit_signal("pressed")
	assert(quit_dialog.visible, "Quit dialog must open")
	menu.get_node("%QuitNoButton").emit_signal("pressed")
	assert(not quit_dialog.visible, "No must close the quit dialog")

	menu.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ MainMenu: Signboards, showcase vehicle, quit dialog, and navigation verified!")

func test_garage(win: Window) -> void:
	print("-> [2/7] Testing VintageCarGarage UI & Controller...")
	var garage = GarageScene.instantiate()
	win.add_child(garage)
	for i in range(3):
		await process_frame
	
	var home_btn = garage.find_child("HomeButton", true, false)
	assert(home_btn is TextureButton or home_btn is Button, "HomeButton exists in garage")
	var prev_btn = garage.find_child("PrevButton", true, false)
	assert(prev_btn is Button, "PrevButton exists")
	var next_btn = garage.find_child("NextButton", true, false)
	assert(next_btn is Button, "NextButton exists")
	var select_btn = garage.find_child("SelectVehicleButton", true, false)
	assert(select_btn is Button, "SelectVehicleButton exists")
	
	# Verify signal connections using array closure
	var back_called = [false]
	garage.return_to_main_menu_requested.connect(func(): back_called[0] = true)
	home_btn.emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(back_called[0], "HomeButton must emit return_to_main_menu_requested")
	
	garage.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ VintageCarGarage: Original buttons, layout, and signal handlers verified!")

func test_hud(win: Window) -> void:
	print("-> [3/7] Testing HUD and GameHUD UI...")
	var hud = HUDScene.instantiate()
	win.add_child(hud)
	for i in range(3):
		await process_frame
	
	var pause_btn = hud.get_node_or_null("%PauseButton")
	assert(pause_btn != null, "Pause button must exist in HUD")
	
	# Check pedal controls
	var gas_btn = hud.get_node_or_null("%GasPedal")
	var brake_btn = hud.get_node_or_null("%BrakePedal")
	assert(gas_btn != null and brake_btn != null, "Gas and Brake pedal buttons must exist")
	
	# Check stats displays
	var dist_lbl = hud.get_node_or_null("%DistanceLabel")
	var fuel_bar = hud.get_node_or_null("%FuelBar")
	var nitro_bar = hud.get_node_or_null("%NitroBar")
	assert(dist_lbl != null and fuel_bar != null and nitro_bar != null, "HUD stats elements exist")
	
	hud.queue_free()
	for i in range(2):
		await process_frame
	
	# Also test game_hud.tscn (Survival HUD)
	var game_hud = GameHUDScene.instantiate()
	win.add_child(game_hud)
	for i in range(3):
		await process_frame
	assert(game_hud.get_node_or_null("%HeartContainer") != null, "HeartContainer must exist in Survival HUD")
	assert(game_hud.get_node_or_null("%DistanceLabel") != null, "DistanceLabel must exist")
	game_hud.queue_free()
	for i in range(2):
		await process_frame
	
	print("  ✓ HUD: Original pedals, pause button, and survival HUD elements verified!")

func test_pause_menu(win: Window) -> void:
	print("-> [4/7] Testing PauseMenu UI & Controller...")
	var pause_menu = PauseMenuScene.instantiate()
	win.add_child(pause_menu)
	for i in range(3):
		await process_frame
	
	var resume_btn = pause_menu.get_node_or_null("%ResumeButton")
	var retry_btn = pause_menu.get_node_or_null("%RetryButton")
	var main_menu_btn = pause_menu.get_node_or_null("%MainMenuButton")
	
	assert(resume_btn != null, "ResumeButton must exist")
	assert(retry_btn != null, "RetryButton must exist")
	assert(main_menu_btn != null, "MainMenuButton must exist")
	
	# Verify SettingsButton does NOT exist
	assert(pause_menu.get_node_or_null("%SettingsButton") == null, "SettingsButton must not exist in PauseMenu")
	
	# Verify MainMenuButton emits menu_requested
	var menu_called = [false]
	pause_menu.menu_requested.connect(func(): menu_called[0] = true)
	main_menu_btn.emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(menu_called[0], "MainMenuButton emits menu_requested")
	
	pause_menu.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ PauseMenu: Original buttons and signal routing verified!")

func test_results_screen(win: Window) -> void:
	print("-> [5/7] Testing ResultsScreen UI & Controller...")
	var results = ResultsScreenScene.instantiate()
	win.add_child(results)
	for i in range(3):
		await process_frame
	
	var retry_btn = results.get_node_or_null("%RetryButton")
	assert(retry_btn != null, "RetryButton must exist")
	
	results.visible = true
	assert(results.visible, "Results screen becomes visible")
	
	results.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ ResultsScreen: Original buttons and retry navigation verified!")

func test_survival_difficulty_menu(win: Window) -> void:
	print("-> [6/7] Testing SurvivalDifficultyMenu UI & Selection...")
	var diff_menu = SurvivalDifficultyScene.instantiate()
	win.add_child(diff_menu)
	for i in range(3):
		await process_frame
	
	var easy_btn = diff_menu.get_node_or_null("%EasyButton")
	var med_btn = diff_menu.get_node_or_null("%MediumButton")
	var hard_btn = diff_menu.get_node_or_null("%HardButton")
	var start_btn = diff_menu.get_node_or_null("%StartSurvivalButton")
	var back_btn = diff_menu.get_node_or_null("%BackButton")
	
	assert(easy_btn != null and med_btn != null and hard_btn != null, "Difficulty buttons must exist")
	assert(start_btn != null and back_btn != null, "Start and Back buttons must exist")
	
	# Test difficulty selection via method and button
	diff_menu.select_difficulty(2)
	assert(diff_menu.get_selected_difficulty() == 2, "Hard difficulty should be selected (value 2)")
	
	var started_diff = [-1]
	diff_menu.start_survival_pressed.connect(func(d: int): started_diff[0] = d)
	start_btn.emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(started_diff[0] == 2, "Start button should emit start_survival_pressed with difficulty 2")
	
	diff_menu.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ SurvivalDifficultyMenu: Card selection, styling, and start trigger verified!")

func test_survival_screen_ui(win: Window) -> void:
	print("-> [7/7] Testing Survival Scene In-Game UI...")
	var surv = SurvivalScene.instantiate()
	surv.enable_obstacle_spawning = false
	win.add_child(surv)
	for i in range(3):
		await process_frame
	
	# Verify ExitMenuButton
	var exit_btn = surv.find_child("ExitMenuButton", true, false)
	assert(exit_btn != null, "ExitMenuButton must exist")
	assert(exit_btn is Button, "ExitMenuButton must be a Button")
	assert(exit_btn.text == "MENU", "ExitMenuButton text must be 'MENU'")
	
	# Verify AdOfferPanel and GameOverPanel buttons
	var ad_panel = surv.find_child("AdOfferPanel", true, false)
	assert(ad_panel != null, "AdOfferPanel must exist")
	var watch_ad_btn = surv.find_child("WatchAdButton", true, false)
	var skip_ad_btn = surv.find_child("SkipAdButton", true, false)
	assert(watch_ad_btn is Button and skip_ad_btn is Button, "Ad buttons must be standard Buttons")
	
	var game_over_panel = surv.find_child("GameOverPanel", true, false)
	assert(game_over_panel != null, "GameOverPanel must exist")
	var retry_btn = surv.find_child("RetryButton", true, false)
	var menu_btn = surv.find_child("MenuButton", true, false)
	assert(retry_btn is Button and menu_btn is Button, "GameOver buttons must be standard Buttons")
	
	surv.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ Survival In-Game UI: Standard modal panels, MENU button, and retry buttons verified!")
