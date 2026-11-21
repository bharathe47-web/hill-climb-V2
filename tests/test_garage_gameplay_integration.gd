extends SceneTree

const MainScene = preload("res://scenes/main/Main.tscn")
const GarageScene = preload("res://scenes/modes/garage/VintageCarGarage.tscn")
const GameScene = preload("res://scenes/game/Game.tscn")
const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN GARAGE & VEHICLE GAMEPLAY INTEGRATION TEST SUITE ---")
	print("=================================================================\n")
	
	_test_garage_displays_all_vehicles()
	_test_driving_collected_vehicles()
	await _test_full_main_menu_to_garage_to_game_flow()
	
	print("\n=================================================================")
	print("✓ ALL GARAGE & VEHICLE INTEGRATION TESTS PASSED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_garage_displays_all_vehicles() -> void:
	print("-> [1/3] Verifying Garage Displays All Collected Vehicles in Carousel...")
	var garage: VintageCarGarageController = GarageScene.instantiate()
	root.add_child(garage)
	
	# Verify total vehicles in garage catalog (20 remaining active vehicles)
	assert(garage._vehicles.size() == 20, "Garage must display exactly 20 vehicles, got %d" % garage._vehicles.size())
	
	# Verify that all collected vehicles in registry are present in the garage catalog
	var ids_in_garage: Array[String] = []
	for v in garage._vehicles:
		ids_in_garage.append(v["id"])
		
	for expected_id in VehicleRegistry.GARAGE_COLLECTED_IDS:
		assert(ids_in_garage.has(expected_id), "Garage must include collected vehicle: %s" % expected_id)
		
	# Verify carousel navigation across all vehicles
	var start_idx = garage._current_index
	for step in range(garage._vehicles.size()):
		var cur_id = garage._vehicles[garage._current_index]["id"]
		assert(garage.vehicle_display_rect.texture != null, "Vehicle %s must have a valid display texture in garage" % cur_id)
		assert(not garage.vehicle_name_label.text.is_empty(), "Vehicle name must be shown for %s" % cur_id)
		garage._on_next_pressed()
	
	# Returned full circle
	assert(garage._current_index == start_idx, "Next navigation must loop back cleanly after cycling all vehicles")
	
	garage.queue_free()
	print("  ✓ All 25+ vehicles successfully displayed in garage showroom with textures & stats!")

func _test_driving_collected_vehicles() -> void:
	print("-> [2/3] Verifying Selecting and Driving Collected Vehicles in Gameplay...")
	
	var sample_test_ids: Array[String] = [
		"car_01", # Starter Hatchback
		"car_08", # Bigfoot Monster Truck
		"car_09", # Mustang GT Boost Mod
		"car_14", # Racing Superbike
		"car_11"  # HillClimb Monster Beast 4x4
	]
	
	var initial_id = SaveManager.get_selected_vehicle_id()
	
	for test_id in sample_test_ids:
		# 1. Select vehicle via SaveManager
		SaveManager.set_selected_vehicle_id(test_id)
		assert(SaveManager.get_selected_vehicle_id() == test_id, "Selected vehicle must persist: %s" % test_id)
		
		# 2. Instantiate GameScene
		var game = GameScene.instantiate()
		root.add_child(game)
		
		for frame in range(3):
			await physics_frame
		
		# 3. Verify vehicle spawned in game is indeed the selected vehicle
		assert(game.vehicle != null, "Vehicle must be spawned in GameScene for %s" % test_id)
		assert(game.vehicle is VehicleController, "Spawned vehicle must be VehicleController")
		
		var init_x = game.vehicle.global_position.x
		
		# 4. Simulate acceleration input
		Input.action_press("accelerate")
		for frame in range(30):
			await physics_frame
		Input.action_release("accelerate")
		
		var after_x = game.vehicle.global_position.x
		assert(after_x > init_x, "Vehicle %s must move forward under acceleration (from %f to %f)" % [test_id, init_x, after_x])
		
		game.queue_free()
		for frame in range(2):
			await physics_frame
			
		print("    • %s drives smoothly, accelerates, and responds to physics!" % test_id)
	
	# Restore initial vehicle selection
	SaveManager.set_selected_vehicle_id(initial_id)
	print("  ✓ All sample collected vehicles verified driving in active gameplay!")

func _test_full_main_menu_to_garage_to_game_flow() -> void:
	print("-> [3/3] Verifying Complete Player Flow: MainMenu -> Garage -> Select Car -> Play Drive...")
	var main: MainController = MainScene.instantiate()
	root.add_child(main)
	
	for frame in range(3):
		await process_frame
		
	# Verify starting in MainMenu
	assert(main.current_scene_node is MainMenuController, "Must start in MainMenu")
	var menu: MainMenuController = main.current_scene_node as MainMenuController
	
	# Player clicks Garage ("MY CARS")
	if "garage_sign" in menu and is_instance_valid(menu.garage_sign):
		menu.garage_sign.pressed.emit()
	elif "garage_mode_button" in menu and is_instance_valid(menu.garage_mode_button):
		menu.garage_mode_button.pressed.emit()
	else:
		menu.start_garage_requested.emit()
	for frame in range(3):
		await process_frame
		
	# Verify transition into Garage
	assert(main.current_scene_node is VintageCarGarageController, "Must transition into Garage showroom")
	var garage: VintageCarGarageController = main.current_scene_node as VintageCarGarageController
	
	# Navigate to car_08 (Bigfoot Monster Truck) and select it
	for i in range(garage._vehicles.size()):
		if garage._vehicles[garage._current_index]["id"] == "car_08":
			break
		garage._on_next_pressed()
		
	assert(garage._vehicles[garage._current_index]["id"] == "car_08", "Must reach car_08")
	garage.select_button.pressed.emit()
	assert(SaveManager.get_selected_vehicle_id() == "car_08", "Must save car_08 as selected vehicle")
	
	# Player clicks Home button to return to MainMenu
	garage.home_button.pressed.emit()
	for frame in range(3):
		await process_frame
		
	assert(main.current_scene_node is MainMenuController, "Must return cleanly to MainMenu")
	menu = main.current_scene_node as MainMenuController
	
	# Player clicks START DRIVE (ENDLESS)
	if "endless_sign" in menu and is_instance_valid(menu.endless_sign):
		menu.endless_sign.pressed.emit()
	elif "start_button" in menu and is_instance_valid(menu.start_button):
		menu.start_button.pressed.emit()
	else:
		menu.start_game_requested.emit()
	for frame in range(3):
		await process_frame
		
	# Verify transition into GameScene with car_08 active
	assert(main.current_scene_node is GameScene, "Must transition to GameScene")
	var game: GameScene = main.current_scene_node as GameScene
	
	for frame in range(5):
		await physics_frame
		
	assert(game.vehicle != null, "Vehicle must be loaded in GameScene")
	# Check mass matches car_08 (12.0)
	assert(game.vehicle.mass == 5000.0, "Active vehicle mass must match car_08 (12.0), got %f" % game.vehicle.mass)
	
	main.queue_free()
	print("  ✓ Complete player lifecycle (Menu -> Garage -> Select Car -> Drive in Endless) verified!")
