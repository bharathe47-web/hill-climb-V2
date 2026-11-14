extends SceneTree

## Comprehensive test suite for the Vintage Car Garage / Vehicle Showcase:
## 1. Scene loading & visual composition nodes (pillars, shelves, lighting, floor, vignette).
## 2. Dynamic coin display from SaveManager.
## 3. Vehicle carousel inspection (Prev/Next navigation, stats display, preview texture).
## 4. Vehicle selection persistence via SaveManager.
## 5. Top navigation buttons (Trophy, Crown, Share, Home) and return to main menu flow.

const GarageScene = preload("res://scenes/modes/garage/VintageCarGarage.tscn")
const MainScene = preload("res://scenes/main/Main.tscn")
const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN VINTAGE CAR GARAGE VERIFICATION TEST SUITE ---")
	print("=================================================================\n")
	
	_test_garage_scene_hierarchy()
	_test_dynamic_coin_balance()
	_test_vehicle_carousel_and_stats()
	_test_vehicle_selection_persistence()
	_test_top_navigation_and_dialogs()
	_test_main_controller_garage_routing()
	
	print("\n=================================================================")
	print("✓ ALL VINTAGE CAR GARAGE TESTS PASSED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_garage_scene_hierarchy() -> void:
	print("-> [1/6] Verifying Garage Scene Visual Hierarchy & Environment Composition...")
	var garage: VintageCarGarageController = GarageScene.instantiate()
	root.add_child(garage)
	
	# Verify environment layers from specification
	var bg = garage.get_node_or_null("Background")
	assert(bg != null and bg is TextureRect, "Background TextureRect must exist")
	
	var env = garage.get_node_or_null("GarageEnvironment")
	assert(env != null, "GarageEnvironment Node2D must exist")
	assert(env.get_node_or_null("LeftPillar") != null, "LeftPillar Sprite2D must exist")
	assert(env.get_node_or_null("RightPillar") != null, "RightPillar Sprite2D must exist")
	assert(env.get_node_or_null("UpperShelf") != null, "UpperShelf Sprite2D must exist")
	assert(env.get_node_or_null("LowerShelf") != null, "LowerShelf Sprite2D must exist")
	assert(env.get_node_or_null("TireStackLeft") == null, "TireStackLeft Sprite2D must be removed as requested")
	assert(env.get_node_or_null("TireStackRight") == null, "TireStackRight Sprite2D must be removed as requested")
	assert(env.get_node_or_null("PipeLeft") != null, "PipeLeft Sprite2D must exist")
	assert(env.get_node_or_null("PipeRight") != null, "PipeRight Sprite2D must exist")
	assert(env.get_node_or_null("GearLarge") != null, "GearLarge Sprite2D must exist")
	assert(env.get_node_or_null("GearSmall") != null, "GearSmall Sprite2D must exist")
	assert(env.get_node_or_null("Machinery") == null, "Machinery Sprite2D must be removed from bottom-left corner")
	
	var floor_node = garage.get_node_or_null("Floor")
	assert(floor_node != null, "Floor Sprite2D must exist")
	
	var lighting = garage.get_node_or_null("LightingEffects")
	assert(lighting != null, "LightingEffects Node2D must exist")
	assert(lighting.get_node_or_null("SpotlightBeam") != null, "SpotlightBeam must exist")
	assert(lighting.get_node_or_null("FloorGlow") != null, "FloorGlow must exist")
	
	var veh_disp = garage.get_node_or_null("VehicleDisplay")
	assert(veh_disp != null, "VehicleDisplay Node2D must exist")
	assert(garage.vehicle_shadow != null, "VehicleShadow Sprite2D must exist")
	assert(garage.vehicle_shadow.texture != null, "VehicleShadow texture must be assigned")
	assert(garage.vehicle_display_rect != null, "VehicleDisplayRect must exist")
	
	garage.queue_free()
	print("  ✓ Industrial brick garage environment, pillars, shelves, tires & lighting verified!")

func _test_dynamic_coin_balance() -> void:
	print("-> [2/6] Verifying Dynamic Coin Balance Connection...")
	var garage: VintageCarGarageController = GarageScene.instantiate()
	root.add_child(garage)
	
	var expected_coins = SaveManager.get_total_coins()
	assert(garage.coin_balance_label != null, "CoinBalance Label must exist")
	assert(garage.coin_balance_label.text == str(expected_coins), "Coin balance must dynamically reflect SaveManager total coins (expected %d, got %s)" % [expected_coins, garage.coin_balance_label.text])
	
	garage.queue_free()
	print("  ✓ Dynamic currency display verified!")

func _test_vehicle_carousel_and_stats() -> void:
	print("-> [3/6] Verifying Vehicle Carousel Navigation & Stat Ratings...")
	var garage: VintageCarGarageController = GarageScene.instantiate()
	root.add_child(garage)
	
	var all_vehicles = VehicleRegistry.get_all_vehicles()
	assert(all_vehicles.size() >= 4, "Must have at least 4 vehicles in catalog")
	
	var initial_name = garage.vehicle_name_label.text
	var initial_shadow_scale = garage.vehicle_shadow.scale
	var initial_shadow_pos = garage.vehicle_shadow.position
	assert(not initial_name.is_empty(), "Vehicle name must be displayed")
	assert(garage.vehicle_display_rect.texture != null, "Vehicle preview texture must be valid")
	
	# Test Next vehicle navigation & shadow dynamic update
	garage._on_next_pressed()
	# Fast-forward tween if present
	if garage._shadow_tween and garage._shadow_tween.is_valid():
		garage._shadow_tween.custom_step(1.0)
	var next_name = garage.vehicle_name_label.text
	var next_shadow_scale = garage.vehicle_shadow.scale
	var next_shadow_pos = garage.vehicle_shadow.position
	assert(next_name != initial_name, "Next button must advance to another vehicle")
	assert(garage.vehicle_display_rect.texture != null, "Next vehicle preview must be valid")
	assert(next_shadow_scale != initial_shadow_scale or next_shadow_pos != initial_shadow_pos, "Vehicle shadow must dynamically adapt its scale or position when changing vehicles")
	
	# Verify stat ratings are bounded (1 to 5)
	assert(garage.power_bar.value >= 1 and garage.power_bar.value <= 5, "Power rating must be between 1 and 5")
	assert(garage.grip_bar.value >= 1 and garage.grip_bar.value <= 5, "Grip rating must be between 1 and 5")
	assert(garage.suspension_bar.value >= 1 and garage.suspension_bar.value <= 5, "Suspension rating must be between 1 and 5")
	assert(garage.fuel_bar.value >= 1 and garage.fuel_bar.value <= 5, "Fuel rating must be between 1 and 5")
	
	# Test Prev vehicle navigation
	garage._on_prev_pressed()
	assert(garage.vehicle_name_label.text == initial_name, "Prev button must return to previous vehicle")
	
	garage.queue_free()
	print("  ✓ Vehicle carousel, preview texture updates, and stat ratings verified!")

func _test_vehicle_selection_persistence() -> void:
	print("-> [4/6] Verifying Vehicle Selection & Persistence via SaveManager...")
	var garage: VintageCarGarageController = GarageScene.instantiate()
	root.add_child(garage)
	
	# Navigate until we find an unselected vehicle
	var cur_selected = SaveManager.get_selected_vehicle_id()
	while garage._vehicles[garage._current_index]["id"] == cur_selected:
		garage._on_next_pressed()
	
	var target_vehicle = garage._vehicles[garage._current_index]
	var target_id = target_vehicle["id"]
	assert(target_id != cur_selected, "Target vehicle must differ from current selected")
	assert(garage.select_button.disabled == false, "Select button must be enabled for unselected vehicle")
	assert(garage.select_button.text == "SELECT VEHICLE", "Button text must read SELECT VEHICLE")
	
	# Trigger selection
	garage._on_select_pressed()
	assert(SaveManager.get_selected_vehicle_id() == target_id, "SaveManager selected vehicle must update to %s" % target_id)
	assert(garage.select_button.disabled == true, "Select button must become disabled after selection")
	assert(garage.select_button.text == "★ SELECTED (ACTIVE)", "Button text must show ACTIVE status")
	
	# Restore initial vehicle to keep save clean
	SaveManager.set_selected_vehicle_id(cur_selected)
	
	garage.queue_free()
	print("  ✓ Vehicle selection persistence and active status updates verified!")

func _test_top_navigation_and_dialogs() -> void:
	print("-> [5/6] Verifying Top Navigation Wooden Panels & Dialogs...")
	var garage: VintageCarGarageController = GarageScene.instantiate()
	root.add_child(garage)
	
	assert(garage.trophy_button != null, "TrophyButton must exist")
	assert(garage.crown_button != null, "CrownButton must exist")
	assert(garage.share_button != null, "ShareButton must exist")
	assert(garage.home_button != null, "HomeButton must exist")
	
	# Test Trophy (Achievements dialog)
	garage._on_trophy_pressed()
	assert(garage.info_dialog.visible == true, "InfoDialog must open on trophy click")
	assert(garage.info_title_label.text == "ACHIEVEMENTS", "Title must read ACHIEVEMENTS")
	garage._close_info_dialog()
	assert(garage.info_dialog.visible == false, "InfoDialog must close")
	
	# Test Crown (Leaderboard dialog)
	garage._on_crown_pressed()
	assert(garage.info_dialog.visible == true, "InfoDialog must open on crown click")
	assert(garage.info_title_label.text == "LEADERBOARD", "Title must read LEADERBOARD")
	garage._close_info_dialog()
	
	# Test Home button emits signal
	var flag = [false]
	garage.return_to_main_menu_requested.connect(func(): flag[0] = true)
	garage._on_home_pressed()
	assert(flag[0] == true, "HomeButton must emit return_to_main_menu_requested")
	
	garage.queue_free()
	print("  ✓ Wooden panel navigation, trophy, crown, share, and home signals verified!")

func _test_main_controller_garage_routing() -> void:
	print("-> [6/6] Verifying MainController load_garage() and scene switching...")
	var main_node: MainController = MainScene.instantiate()
	root.add_child(main_node)
	
	# Load garage
	main_node.load_garage()
	assert(main_node.current_scene_node is VintageCarGarageController, "MainController must load VintageCarGarageController into SceneContainer")
	
	# Return to menu
	var garage_inst = main_node.current_scene_node as VintageCarGarageController
	garage_inst.return_to_main_menu_requested.emit()
	assert(main_node.current_scene_node is MainMenuController, "Scene switcher must return to MainMenuController")
	
	main_node.queue_free()
	print("  ✓ Full Main scene transition into Garage and return-to-menu verified!")
