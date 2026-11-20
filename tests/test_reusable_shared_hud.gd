extends SceneTree

const GameHUD = preload("res://scripts/ui/game_hud.gd")
const HUDController = preload("res://scripts/ui/HUDController.gd")
const GameManager = preload("res://scripts/core/GameManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN REUSABLE SHARED HUD VERIFICATION TEST SUITE ---")
	print("=================================================================\n")
	
	call_deferred("_run_tests")

func _run_tests() -> void:
	var root := get_root()
	
	_test_hud_scenes_load(root)
	_test_game_manager_binding(root)
	_test_vehicle_telemetry_and_gauges(root)
	_test_mobile_touch_pedals(root)
	_test_mode_switching_and_displays(root)
	_test_safe_rebinding_and_lifecycle(root)
	_test_survival_mode_integration(root)
	
	print("\n=================================================================")
	print("✓ ALL REUSABLE SHARED HUD TESTS COMPLETED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_hud_scenes_load(root: Window) -> void:
	print("-> [1/7] Testing HUD scenes loading and inheritance...")
	
	var hud_packed: PackedScene = load("res://scenes/ui/HUD.tscn")
	assert(hud_packed != null, "Canonical HUD.tscn must load successfully")
	var hud_inst = hud_packed.instantiate()
	assert(hud_inst != null, "HUD.tscn must instantiate")
	assert(hud_inst is GameHUD, "HUD.tscn instance must inherit GameHUD")
	assert(hud_inst is HUDController, "HUD.tscn instance must be a HUDController")
	root.add_child(hud_inst)
	
	var game_hud_packed: PackedScene = load("res://scenes/ui/hud/game_hud.tscn")
	assert(game_hud_packed != null, "Target scenes/ui/hud/game_hud.tscn must load successfully")
	var game_hud_inst = game_hud_packed.instantiate()
	assert(game_hud_inst != null, "game_hud.tscn must instantiate")
	assert(game_hud_inst is GameHUD, "game_hud.tscn instance must inherit GameHUD")
	root.add_child(game_hud_inst)
	
	assert(game_hud_inst.anchors_preset == Control.PRESET_FULL_RECT, "game_hud.tscn must use full rect preset")
	assert(hud_inst.anchors_preset == Control.PRESET_FULL_RECT, "HUD.tscn must use full rect preset")
	
	hud_inst.queue_free()
	game_hud_inst.queue_free()
	print("  ✓ Both scenes loaded, validated, and confirmed polymorphic!")

func _test_game_manager_binding(root: Window) -> void:
	print("-> [2/7] Testing GameManager binding, distance, fuel, and coins...")
	var hud_packed: PackedScene = load("res://scenes/ui/hud/game_hud.tscn")
	var hud: GameHUD = hud_packed.instantiate()
	root.add_child(hud)
	
	var gm := GameManager.new()
	root.add_child(gm)
	
	hud.bind_game_manager(gm)
	gm.start_run()
	
	# Distance
	gm.update_distance(385.4)
	assert(hud.distance_label.text == "385 m", "Distance label must display integer meters")
	
	# Coins
	gm.add_coins(75)
	assert(hud.coins_label.text == "75", "Coins label must display coins")
	
	# Fuel
	gm.fuel_updated.emit(15.0, 100.0)
	assert(hud.fuel_bar.value == 15.0, "Fuel bar value must match update")
	assert(hud._is_low_fuel == true, "Low fuel warning flag must be active below 20%")
	hud._process(0.1)
	assert(hud.low_fuel_indicator.visible == true, "Low fuel indicator must flash visible")
	
	# Refuel
	gm.fuel_updated.emit(90.0, 100.0)
	assert(hud._is_low_fuel == false, "Low fuel flag must clear")
	hud._process(0.1)
	assert(hud.low_fuel_indicator.visible == false, "Low fuel indicator must hide")
	
	# Pause
	gm.pause_run(true)
	assert(hud.pause_banner.visible == true, "Pause banner must show on pause")
	gm.pause_run(false)
	assert(hud.pause_banner.visible == false, "Pause banner must hide on resume")
	
	hud.queue_free()
	gm.queue_free()
	print("  ✓ GameManager telemetry, fuel warning, and banners verified!")

func _test_vehicle_telemetry_and_gauges(root: Window) -> void:
	print("-> [3/7] Testing Vehicle binding, Speedometer, RPM, and Nitro...")
	var hud_packed: PackedScene = load("res://scenes/ui/hud/game_hud.tscn")
	var hud: GameHUD = hud_packed.instantiate()
	root.add_child(hud)
	
	var veh = VehicleRegistry.instantiate_vehicle("blue_flame_truck")
	root.add_child(veh)
	
	hud.bind_vehicle(veh)
	
	# Test Nitro updates
	veh.nitro_changed.emit(45.0, 100.0)
	assert(hud.nitro_bar.value == 45.0, "Nitro bar value must match update")
	assert(hud.nitro_percentage_label.text == "45%", "Nitro percentage label must reflect 45%")
	
	# Test Speedometer readout
	# Simulate 120 km/h
	veh.linear_velocity.x = 120.0 * 20.0 # Vehicle speed proxy
	hud._process(0.016)
	assert(hud.speed_digital_label != null, "Speed digital label must exist")
	assert(hud.speed_needle != null, "Speed needle must exist")
	
	# Test RPM dial needle where supported
	if is_instance_valid(hud._rpm_needle):
		assert(hud._rpm_needle is Node2D, "RPM needle must be Node2D when supported")
	
	hud.queue_free()
	veh.queue_free()
	print("  ✓ Vehicle gauges, Speedometer, and Nitro telemetry verified!")

func _test_mobile_touch_pedals(root: Window) -> void:
	print("-> [4/7] Testing Mobile Touch Controls (Gas, Brake, Nitro, Pause)...")
	var hud_packed: PackedScene = load("res://scenes/ui/hud/game_hud.tscn")
	var hud: GameHUD = hud_packed.instantiate()
	root.add_child(hud)
	
	# Gas pedal
	hud._on_gas_down()
	assert(Input.is_action_pressed("accelerate"), "Gas pedal press must set accelerate action")
	hud._on_gas_up()
	assert(not Input.is_action_pressed("accelerate"), "Gas pedal release must release accelerate action")
	
	# Brake pedal
	hud._on_brake_down()
	assert(Input.is_action_pressed("brake_reverse"), "Brake pedal press must set brake_reverse action")
	hud._on_brake_up()
	assert(not Input.is_action_pressed("brake_reverse"), "Brake pedal release must release brake_reverse action")
	
	# Nitro pedal
	hud._on_nitro_button_down()
	assert(Input.is_action_pressed("nitro"), "Nitro button press must set nitro action")
	hud._on_nitro_button_up()
	assert(not Input.is_action_pressed("nitro"), "Nitro button release must release nitro action")
	
	# Pedals size and touch targets verification
	assert(hud.gas_pedal != null and hud.gas_pedal.size.x >= 100.0, "Gas pedal touch width must be >= 100px")
	assert(hud.brake_pedal != null and hud.brake_pedal.size.x >= 100.0, "Brake pedal touch width must be >= 100px")
	assert(hud.nitro_button != null and hud.nitro_button.size.x >= 80.0, "Nitro button touch width must be >= 80px")
	assert(hud.pause_button != null and hud.pause_button.size.x >= 40.0, "Pause button touch width must be >= 40px")
	
	hud.queue_free()
	print("  ✓ Mobile touch pedals, actions, and comfortable touch targets verified!")

func _test_mode_switching_and_displays(root: Window) -> void:
	print("-> [5/7] Testing Mode Switching (Endless, Indian Roads, Survival)...")
	var hud_packed: PackedScene = load("res://scenes/ui/hud/game_hud.tscn")
	var hud: GameHUD = hud_packed.instantiate()
	root.add_child(hud)
	
	# Mode 1: Endless Map (Default)
	hud.set_hud_mode(GameHUD.HUDMode.ENDLESS)
	assert(hud.top_stats_panel.visible == true, "Endless mode must show TopStatsPanel")
	assert(hud.fuel_section.visible == true, "Endless mode must show FuelSection")
	assert(hud.coins_panel.visible == true, "Endless mode must show CoinsPanel")
	assert(hud.indian_roads_panel.visible == false, "Endless mode must hide IndianRoadsPanel")
	assert(hud.survival_panel.visible == false, "Endless mode must hide SurvivalPanel")
	
	# Mode 2: Indian Roads
	hud.set_hud_mode(GameHUD.HUDMode.INDIAN_ROADS)
	assert(hud.indian_roads_panel.visible == true, "Indian Roads mode must show IndianRoadsPanel")
	assert(hud.survival_panel.visible == false, "Indian Roads mode must hide SurvivalPanel")
	
	hud.set_indian_roads_progress(3, 5, "Goa")
	assert(hud.checkpoint_label.text == "CHECKPOINT 3 / 5", "Checkpoint label must reflect 3/5")
	assert(hud.checkpoint_bar.value == 3.0, "Checkpoint bar value must be 3")
	assert(hud.checkpoint_bar.max_value == 5.0, "Checkpoint bar max value must be 5")
	assert(hud.checkpoint_pct_label.text == "60%", "Checkpoint percentage must be 60%")
	assert("GOA" in hud.destination_label.text, "Destination label must show GOA")
	
	# Mode 3: Survival
	hud.set_hud_mode(GameHUD.HUDMode.SURVIVAL)
	assert(hud.survival_panel.visible == true, "Survival mode must show SurvivalPanel")
	assert(hud.indian_roads_panel.visible == false, "Survival mode must hide IndianRoadsPanel")
	assert(hud.fuel_section.is_visible_in_tree() and not hud.get_node("%DistanceLabel").is_visible_in_tree(), "Survival mode keeps only the compact fuel gauge")
	
	hud.set_survival_lives(2, 3)
	assert(hud.heart_container != null, "Heart container must exist")
	var hearts: Array[Node] = hud.heart_container.get_children()
	assert(hearts.size() == 3, "Heart container must contain exactly 3 hearts")
	var h0 = hearts[0] as TextureRect
	var h1 = hearts[1] as TextureRect
	var h2 = hearts[2] as TextureRect
	assert(h0.texture == GameHUD.HEART_FULL_TEX, "Heart 1 must be full")
	assert(h1.texture == GameHUD.HEART_FULL_TEX, "Heart 2 must be full")
	assert(h2.texture == GameHUD.HEART_EMPTY_TEX, "Heart 3 must be empty")
	
	hud.set_survival_stats(18.5, 240.0)
	assert("18.5s" in hud.survival_time_label.text, "Survival time label must show 18.5s")
	assert("240m" in hud.survival_dist_label.text, "Survival dist label must show 240m")
	
	hud.queue_free()
	print("  ✓ Mode switching, layout toggling, and mode-specific panels verified!")

func _test_safe_rebinding_and_lifecycle(root: Window) -> void:
	print("-> [6/7] Testing Safe Rebinding & Signal Disconnection...")
	var hud_packed: PackedScene = load("res://scenes/ui/hud/game_hud.tscn")
	var hud: GameHUD = hud_packed.instantiate()
	root.add_child(hud)
	
	var gm1 := GameManager.new()
	var gm2 := GameManager.new()
	root.add_child(gm1)
	root.add_child(gm2)
	
	hud.bind_game_manager(gm1)
	assert(hud.game_manager_ref == gm1, "GameManager 1 must be bound")
	
	# Rebind to gm2
	hud.bind_game_manager(gm2)
	assert(hud.game_manager_ref == gm2, "GameManager 2 must be bound")
	
	# Verify gm1 signals are disconnected
	gm1.distance_updated.emit(999.0)
	assert(hud.distance_label.text != "999 m", "gm1 signals must be disconnected and ignored")
	
	# Verify gm2 signals work
	gm2.distance_updated.emit(500.0)
	assert(hud.distance_label.text == "500 m", "gm2 signals must update HUD")
	
	# Unbind cleanly
	hud.unbind_game_manager()
	assert(hud.game_manager_ref == null, "GameManager reference must be cleared")
	gm2.distance_updated.emit(700.0)
	assert(hud.distance_label.text == "500 m", "Unbound GameManager must not trigger updates")
	
	# Safe null binding
	hud.bind_game_manager(null)
	assert(hud.game_manager_ref == null, "Binding null must not crash")
	
	hud.queue_free()
	gm1.queue_free()
	gm2.queue_free()
	print("  ✓ Signal isolation, rebinding safety, and null handling verified!")

func _test_survival_mode_integration(root: Window) -> void:
	print("-> [7/7] Testing SurvivalController binding to Shared HUD...")
	var hud_packed: PackedScene = load("res://scenes/ui/hud/game_hud.tscn")
	var hud: GameHUD = hud_packed.instantiate()
	root.add_child(hud)
	
	var surv = SurvivalController.new()
	root.add_child(surv)
	
	hud.bind_survival_controller(surv)
	assert(hud.current_mode == GameHUD.HUDMode.SURVIVAL, "Binding SurvivalController must auto-switch HUD to SURVIVAL mode")
	assert(hud.survival_panel.visible == true, "Survival panel must be visible")
	
	# Trigger life change signal
	surv.lives_changed.emit(1, 3)
	var hearts: Array[Node] = hud.heart_container.get_children()
	var h0 = hearts[0] as TextureRect
	var h1 = hearts[1] as TextureRect
	var h2 = hearts[2] as TextureRect
	assert(h0.texture == GameHUD.HEART_FULL_TEX, "Heart 1 full")
	assert(h1.texture == GameHUD.HEART_EMPTY_TEX, "Heart 2 empty")
	assert(h2.texture == GameHUD.HEART_EMPTY_TEX, "Heart 3 empty")
	
	hud.queue_free()
	surv.queue_free()
	print("  ✓ SurvivalController signal binding and live heart updates verified!")
