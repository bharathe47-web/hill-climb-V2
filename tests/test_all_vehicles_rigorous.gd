extends SceneTree

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN COMPREHENSIVE INDIVIDUAL VEHICLE AUDIT & TEST SUITE ---")
	print("=================================================================")
	
	var all_ids: Array[String] = VehicleRegistry.ORDERED_IDS
	print("Total active vehicles in registry: %d" % all_ids.size())
	assert(all_ids.size() == 20, "Expected exactly 20 vehicles, found %d" % all_ids.size())
	
	# 1. VERIFY UNWANTED / REMOVED VEHICLES ARE COMPLETELY GONE
	var removed_vehicles = [
		"car_03", # Vehicle No. 7 (Off-Road Racing Pickup)
		"car_05", # Bus
		"car_09", # Supercar (Mustang GT Widebody Boost Beast)
		"car_20", # Classic Blown Hotrod Coupe
		"car_21", # Vehicle No. 21 (Enduro Adventure Dual-Sport)
		"car_22"  # Heavy 4x4 Off-Road Truck
	]
	
	for rid in removed_vehicles:
		assert(not VehicleRegistry.has_vehicle(rid), "Removed vehicle %s must NOT be in registry!" % rid)
		assert(not ResourceLoader.exists("res://scenes/vehicle/garage/%s.tscn" % rid), "Scene for %s must not exist!" % rid)
		assert(not ResourceLoader.exists("res://assets/vehicles/garage/%s/body.png" % rid), "Asset body for %s must not exist!" % rid)
	print("✓ Confirmed: All unwanted vehicles (car_03, car_05, car_09, car_20, car_21, car_22) are completely removed.")
	
	# Ground for test driving
	var ground: StaticBody2D = StaticBody2D.new()
	var g_mat := PhysicsMaterial.new()
	g_mat.friction = 1.0
	ground.physics_material_override = g_mat
	root.add_child(ground)
	var g_col: CollisionShape2D = CollisionShape2D.new()
	var g_seg: SegmentShape2D = SegmentShape2D.new()
	g_seg.a = Vector2(-2000, 100)
	g_seg.b = Vector2(8000, 100)
	g_col.shape = g_seg
	ground.add_child(g_col)
	
	var passed_count: int = 0
	
	for v_id in all_ids:
		var info: Dictionary = VehicleRegistry.get_vehicle(v_id)
		print("\n--> Auditing [%s]: %s" % [v_id, info["display_name"]])
		
		# Check preview file
		assert(ResourceLoader.exists(info["preview_path"]), "Preview texture must exist: %s" % info["preview_path"])
		var preview_tex = load(info["preview_path"])
		assert(preview_tex != null, "Preview texture must load: %s" % info["preview_path"])
		
		# Scene instantiation
		var car: VehicleController = VehicleRegistry.instantiate_vehicle(v_id)
		assert(car != null, "Vehicle %s must instantiate cleanly" % v_id)
		car.position = Vector2(0, 0)
		root.add_child(car)
		await physics_frame
		
		# Component verification
		assert(car.rear_wheel != null, "Rear wheel missing in %s" % v_id)
		assert(car.front_wheel != null, "Front wheel missing in %s" % v_id)
		assert(car.rear_joint != null, "Rear joint missing in %s" % v_id)
		assert(car.front_joint != null, "Front joint missing in %s" % v_id)
		assert(car.crash_detector != null, "Crash detector missing in %s" % v_id)
		assert(car.rear_joint.node_b != NodePath(""), "Rear joint must be connected in %s" % v_id)
		assert(car.front_joint.node_b != NodePath(""), "Front joint must be connected in %s" % v_id)
		
		# Let it settle on ground
		for s in range(35):
			await physics_frame
		
		# Suspension compression check
		var target_rear: Vector2 = car.to_global(car._initial_rear_wheel_offset)
		var target_front: Vector2 = car.to_global(car._initial_front_wheel_offset)
		var rear_disp: float = (car.rear_wheel.global_position - target_rear).length()
		var front_disp: float = (car.front_wheel.global_position - target_front).length()
		assert(rear_disp < 18.0, "Rear wheel excessively displaced in %s (disp: %.1f)" % [v_id, rear_disp])
		assert(front_disp < 18.0, "Front wheel excessively displaced in %s (disp: %.1f)" % [v_id, front_disp])
		
		# Test Forward Driving Direction (+X)
		var start_x = car.global_position.x
		for s in range(30):
			if car.rear_wheel:
				car.rear_wheel.apply_torque(car.motor_torque)
			if car.front_wheel:
				car.front_wheel.apply_torque(car.motor_torque * 0.75)
			await physics_frame
		
		var end_x = car.global_position.x
		assert(end_x > start_x + 5.0, "Vehicle %s must drive FORWARD to the right (+X)! Start: %.1f, End: %.1f" % [v_id, start_x, end_x])
		
		# Specific checks for special vehicles
		if v_id == "car_04":
			# Vehicle No. 8: verify it moves forward properly and is right-facing
			assert(end_x > start_x + 10.0, "Vehicle No. 8 (car_04) must move briskly forward (+X)")
			print("    -> Vehicle No. 8 (car_04) orientation & forward drive verified (+%.1f px)" % (end_x - start_x))
			
		elif v_id == "car_06":
			# Ice Cream Truck: verify positive forward travel
			assert(end_x > start_x + 10.0, "Ice Cream Vehicle (car_06) must drive smoothly without chassis dragging")
			print("    -> Ice Cream Truck (car_06) smooth forward drive verified (+%.1f px)" % (end_x - start_x))
			
		elif v_id == "car_07":
			# Ambulance: verify wheel fitment and driving
			assert(end_x > start_x + 10.0, "Ambulance (car_07) must move forward properly")
			print("    -> Ambulance (car_07) wheel fitment & forward drive verified (+%.1f px)" % (end_x - start_x))
			
		elif v_id == "car_08":
			# Vehicle No. 12 (Bigfoot Heavy Monster Truck): verify boost bonus & power
			assert(car.boost_power_multiplier > 1.0, "Bigfoot (car_08) must have boost_power_multiplier > 1.0")
			print("    -> Bigfoot (car_08) boost bonus verified (%.2fx)!" % car.boost_power_multiplier)
			
		elif v_id in ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]:
			# Bike vehicles: verify rear wheel and front wheel match config geometry
			var rw_offset = car._initial_rear_wheel_offset
			var fw_offset = car._initial_front_wheel_offset
			var cfg = VehicleRegistry.get_vehicle_config(v_id)
			var exp_r = cfg.get("rear_wheel_offset", Vector2.ZERO) * cfg.get("body_scale", 1.0)
			var exp_f = cfg.get("front_wheel_offset", Vector2.ZERO) * cfg.get("body_scale", 1.0)
			assert(rw_offset.distance_to(exp_r) <= 1.0, "Bike %s rear wheel offset mismatch" % v_id)
			assert(fw_offset.distance_to(exp_f) <= 1.0, "Bike %s front wheel offset mismatch" % v_id)
			print("    -> Bike %s wheel positioning verified (Rear: %s, Front: %s)" % [v_id, rw_offset, fw_offset])
		
		car.queue_free()
		await physics_frame
		await physics_frame
		passed_count += 1
		print("  ✓ [%s] Passed all checks." % v_id)
	
	ground.queue_free()
	
	# 2. SPECIFIC IN-DEPTH TEST: VEHICLE NO. 12 SUSTAINED BOOST & RESILIENCE (NO HEAT / BURST)
	print("\n=================================================================")
	print("--- TESTING VEHICLE NO. 12 SUSTAINED NITRO BOOST DYNAMICS ---")
	print("=================================================================")
	var car12: VehicleController = VehicleRegistry.instantiate_vehicle("car_08")
	assert(car12 != null, "Vehicle No. 12 must instantiate")
	root.add_child(car12)
	car12.position = Vector2(0, 0)
	await physics_frame
	
	# Activate nitro boost continuously for 200 frames - must NEVER burst or overheat
	car12.is_nitro_requested = true
	for i in range(200):
		car12.current_nitro = car12.max_nitro
		await physics_frame
		assert(car12.is_active, "Vehicle No. 12 must remain active during sustained boost!")
		assert(not car12.is_damaged, "Vehicle No. 12 must never overheat or enter damaged mode!")
		
	print("✓ Vehicle No. 12 Sustained Boost without Overheat/Burst PASSED!")
	
	# Deactivate nitro
	car12.is_nitro_requested = false
	await physics_frame
	assert(not car12.is_nitro_active, "Nitro must deactivate cleanly")
	
	# Test reset
	car12.reset_vehicle(Vector2(100, 100))
	assert(car12.is_active, "Vehicle should be active after reset")
	assert(not car12.is_damaged, "is_damaged should be false after reset")
	assert(car12.rear_joint.node_b != NodePath(""), "Rear joint must remain connected on reset")
	assert(car12.front_joint.node_b != NodePath(""), "Front joint must remain connected on reset")
	print("✓ Vehicle No. 12 Clean State and Reset PASSED!")
	
	car12.queue_free()
	await physics_frame
	
	# 3. SPECIFIC IN-DEPTH TEST: ICE CREAM TRUCK (car_06) ON 15° SLOPE
	print("\n=================================================================")
	print("--- TESTING ICE CREAM TRUCK (car_06) ON 15° STEEP SLOPE ---")
	print("=================================================================")
	var slope_ground: StaticBody2D = StaticBody2D.new()
	var s_col: CollisionShape2D = CollisionShape2D.new()
	var s_seg: SegmentShape2D = SegmentShape2D.new()
	s_seg.a = Vector2(-500, 250)
	s_seg.b = Vector2(1500, 250 - 2000.0 * tan(deg_to_rad(15.0)))
	s_col.shape = s_seg
	var s_mat := PhysicsMaterial.new()
	s_mat.friction = 1.0
	slope_ground.physics_material_override = s_mat
	slope_ground.add_child(s_col)
	root.add_child(slope_ground)
	
	var car06: VehicleController = VehicleRegistry.instantiate_vehicle("car_06")
	car06.position = Vector2(0, 50)
	root.add_child(car06)
	
	for i in range(40):
		await physics_frame
	
	var slope_start_x = car06.global_position.x
	for i in range(80):
		car06.rear_wheel.apply_torque(car06.motor_torque)
		car06.front_wheel.apply_torque(car06.motor_torque * 0.75)
		await physics_frame
	
	var slope_end_x = car06.global_position.x
	assert(slope_end_x > slope_start_x + 30.0, "Ice Cream Truck must climb 15° slope effectively! Start: %.1f, End: %.1f" % [slope_start_x, slope_end_x])
	print("✓ Ice Cream Truck climbed 15° slope effectively (+%.1f px)!" % (slope_end_x - slope_start_x))
	
	car06.queue_free()
	slope_ground.queue_free()
	await physics_frame
	
	print("\n=================================================================")
	print("✓ ALL %d ACTIVE VEHICLES & MECHANICS FULLY VERIFIED (100%% PASS)!" % passed_count)
	print("=================================================================")
	quit(0)
