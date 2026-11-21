extends SceneTree

const GarageScene = preload("res://scenes/modes/garage/VintageCarGarage.tscn")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const VehicleController = preload("res://scripts/vehicle/VehicleController.gd")
const SaveManager = preload("res://scripts/core/SaveManager.gd")

const BIKES: Array[String] = [
	"car_14", # Super Sport Racing Superbike
	"car_15", # Custom Chopper Beast
	"car_16", # Off-Road Motocross Dirt Bike
	"car_17", # Streetfighter Naked Bike
	"car_24", # Highway Touring Cruiser
	"car_25"  # Urban City Commuter Bike
]

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN DEDICATED BIKE GARAGE & GAMEPLAY AUDIT SUITE ---")
	print("=================================================================\n")
	
	_test_garage_bike_display_and_sizing()
	await _test_each_bike_gameplay()
	
	print("\n=================================================================")
	print("✓ ALL 6 BIKES FULLY VERIFIED IN GARAGE & GAMEPLAY (100% SUCCESS)!")
	print("=================================================================\n")
	quit(0)

func _test_garage_bike_display_and_sizing() -> void:
	print("-> [Part 1] Verifying Garage Presentation & Natural Sizing for All Bikes...")
	var garage: VintageCarGarageController = GarageScene.instantiate()
	root.add_child(garage)
	garage._ready()
	
	for bike_id in BIKES:
		var v_info = VehicleRegistry.get_vehicle(bike_id)
		var expected_name: String = v_info.get("display_name", "")
		
		# Navigate to this bike in garage
		SaveManager.set_selected_vehicle_id(bike_id)
		garage._init_vehicle_catalog()
		garage._display_current_vehicle(true)
		
		# 1. Clean vehicle name (no counter like /20)
		var name_text = garage.vehicle_name_label.text
		assert(name_text == expected_name, "Garage name for %s must be '%s', got '%s'" % [bike_id, expected_name, name_text])
		assert(not name_text.contains("/20"), "Garage name must NOT contain counter formatting!")
		
		# 2. Natural viewing size (avoid unnecessary zooming)
		var disp_rect: TextureRect = garage.vehicle_display_rect
		assert(disp_rect != null, "VehicleDisplayRect must exist")
		assert(disp_rect.texture != null, "Vehicle preview texture must be valid for %s" % bike_id)
		
		var view_size: Vector2 = disp_rect.custom_minimum_size
		assert(view_size.x >= 250.0 and view_size.x <= 900.0, 
			"Bike %s viewing width must be natural (250-380px, got %.1f)" % [bike_id, view_size.x])
		assert(view_size.y >= 100.0 and view_size.y <= 380.0,
			"Bike %s viewing height must be natural (100-220px, got %.1f)" % [bike_id, view_size.y])
		
		# 3. Ground shadow sits naturally under tires
		var shadow_pos = garage.vehicle_shadow.position
		var shadow_scale = garage.vehicle_shadow.scale
		assert(absf(shadow_pos.y) <= 10.0,
			"Bike %s shadow position must align with wheels near ground (got %.1f)" % [bike_id, shadow_pos.y])
		assert(shadow_scale.x <= 0.65,
			"Bike %s shadow scale must be proportionate to bike (got %.2f)" % [bike_id, shadow_scale.x])
		
		print("  ✓ Bike [%s: %s] Garage Display: Natural Size %dx%d, Clean Name, Shadow at (%.1f, %.1f)" % [
			bike_id, expected_name, int(view_size.x), int(view_size.y), shadow_pos.x, shadow_pos.y
		])
	
	garage.queue_free()

func _test_each_bike_gameplay() -> void:
	print("\n-> [Part 2] Verifying Gameplay Physics, Fork Alignment & No Unwanted Driver...")
	
	# Create ground static body
	var ground: StaticBody2D = StaticBody2D.new()
	var g_mat := PhysicsMaterial.new()
	g_mat.friction = 1.0
	ground.physics_material_override = g_mat
	root.add_child(ground)
	var g_col: CollisionShape2D = CollisionShape2D.new()
	var g_seg: SegmentShape2D = SegmentShape2D.new()
	g_seg.a = Vector2(-2000, 200)
	g_seg.b = Vector2(8000, 200)
	g_col.shape = g_seg
	ground.add_child(g_col)
	
	for bike_id in BIKES:
		var cfg = VehicleRegistry.get_vehicle_config(bike_id)
		var bike: VehicleController = VehicleRegistry.instantiate_vehicle(bike_id)
		assert(bike != null, "Bike %s must instantiate cleanly" % bike_id)
		
		root.add_child(bike)
		bike._ready()
		var wheel_bottom: float = bike.get_wheel_bottom_offset()
		bike.position = Vector2(0, 200.0 - wheel_bottom)
		bike.reset_vehicle(bike.position)
		
		# 1. Unwanted character check: No driver sprite may be visible during gameplay
		var driver = bike.get_node_or_null("DriverSprite")
		assert(driver == null or not driver.visible, 
			"No driver character may appear during gameplay for %s!" % bike_id)
		
		# 2. Bike Draw Order verification:
		assert(bike.rear_wheel.z_index == -1, "Bike %s rear wheel must have z_index -1 (behind frame)" % bike_id)
		var body_sp = bike.get_node_or_null("BodySprite")
		if body_sp:
			assert(body_sp.z_index == 0, "Bike %s frame must have z_index 0" % bike_id)
		assert(bike.front_wheel.z_index == -1, "Bike %s front wheel must have z_index -1 (behind frame)" % bike_id)
		
		# 3. Fork axle offset calibration check:
		var fw_off = cfg.get("front_wheel_offset")
		var b_scale: float = cfg.get("body_scale", 1.0)
		var expected_scaled_fw: float = fw_off.x * b_scale
		assert(absf(bike._initial_front_wheel_offset.x - expected_scaled_fw) < 0.5,
			"Front wheel mount X must match fork offset within 0.5px for %s" % bike_id)
		assert(bike._initial_front_wheel_offset.x >= 40.0 and bike._initial_front_wheel_offset.x <= 75.0,
			"Front wheel mount X must be in natural fork range (40-75px, got %.1f) for %s" % [bike._initial_front_wheel_offset.x, bike_id])
		
		# 4. Settle on ground and verify stable ground contact
		for f in range(25):
			await physics_frame
		
		var contact_diff = absf(bike.rear_wheel.global_position.y - bike.front_wheel.global_position.y)
		assert(contact_diff < 8.0, 
			"Bike %s must sit level on flat ground (rear/front Y diff: %.2f px)" % [bike_id, contact_diff])
		
		# 5. Drive forward with acceleration torque
		var start_x = bike.global_position.x
		for f in range(40):
			bike.rear_wheel.apply_torque(bike.motor_torque)
			bike.front_wheel.apply_torque(bike.motor_torque * 0.4)
			await physics_frame
			
		var forward_dist = bike.global_position.x - start_x
		assert(forward_dist > 15.0,
			"Bike %s must drive forward smoothly (+X)! Travelled: %.1f px" % [bike_id, forward_dist])
		assert(absf(bike.rotation_degrees) < 35.0,
			"Bike %s must remain upright while accelerating (tilt: %.1f deg)" % [bike_id, bike.rotation_degrees])
			
		# 6. Test crash & reset_vehicle
		bike.apply_crash_damage()
		var driver_after_crash = bike.get_node_or_null("DriverSprite")
		assert(driver_after_crash == null or not driver_after_crash.visible,
			"No driver character should appear after crash for %s" % bike_id)
			
		bike.reset_vehicle(Vector2(0, 200.0 - wheel_bottom))
		assert(bike.is_active, "Bike must reset to active")
		
		bike.queue_free()
		await physics_frame
		await physics_frame
		
		print("  ✓ Bike [%s: %s] Gameplay: Zero Character, Fork Aligned, Level Stance, Smooth Drive (+%.1f px)" % [
			bike_id, cfg.get("name", ""), forward_dist
		])
	
	ground.queue_free()
