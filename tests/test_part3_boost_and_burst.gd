extends SceneTree

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	print("\n==================================================================================================")
	print("TASK: UNIFIED BOOST VERIFICATION (HEAT & BURST COMPLETELY REMOVED)")
	print("==================================================================================================\n")
	
	var test_vehicles: Array[Dictionary] = [
		{"id": "car_08", "type": "Monster Truck", "name": "Bigfoot Heavy Monster Truck"},
		{"id": "car_01", "type": "Normal Car",    "name": "Classic Vintage Sedan"},
		{"id": "car_14", "type": "Bike",          "name": "Super Sport Racing Superbike"}
	]
	
	var passed_count := 0
	
	for entry in test_vehicles:
		var vid: String = entry["id"]
		var vname: String = entry["name"]
		var vtype: String = entry["type"]
		
		print("--------------------------------------------------------------------------------------------------")
		print("TESTING: %s (%s, ID: %s)" % [vname, vtype, vid])
		print("--------------------------------------------------------------------------------------------------")
		
		var car: VehicleController = VehicleRegistry.instantiate_vehicle(vid)
		if not car:
			push_error("Failed to instantiate vehicle: %s" % vid)
			quit(1)
			return
			
		root.add_child(car)
		car._ready()
		
		# 1. Config verification: no heat or burst parameters
		var cfg: Dictionary = VehicleRegistry.get_vehicle_config(vid)
		assert(not cfg.has("warning_heat"), "warning_heat should not be present in config")
		assert(not cfg.has("burst_heat"), "burst_heat should not be present in config")
		assert(not "engine_heat" in car, "engine_heat property should not exist on VehicleController")
		assert(not "burst_heat" in car, "burst_heat property should not exist on VehicleController")
		assert(not "warning_heat" in car, "warning_heat property should not exist on VehicleController")
		print("  [CONFIG] Clean config verified: zero heat/burst parameters")
		
		# 2. Boost power verification
		if vid == "car_08":
			assert(car.boost_power_multiplier == VehicleRegistry.BIGFOOT_BOOST_BONUS, "Bigfoot boost must have bonus (1.15x)")
			assert(VehicleRegistry.get_vehicle_base_boost("car_08") == VehicleRegistry.BIGFOOT_BOOST_FORCE, "Bigfoot base boost must be 45000 N")
			print("  [BOOST] Bigfoot Boost Power Verified: %.2fx multiplier, 45000 N force" % car.boost_power_multiplier)
		else:
			assert(car.boost_power_multiplier == VehicleRegistry.BOOST_POWER_MULTIPLIER, "Normal vehicles must have standard boost multiplier")
			assert(VehicleRegistry.get_vehicle_base_boost(vid) == VehicleRegistry.DEFAULT_BASE_BOOST_FORCE, "Normal base boost must be 18000 N")
			print("  [BOOST] Standard Boost Power Verified: %.2fx multiplier, 18000 N force" % car.boost_power_multiplier)
		
		# 3. Initial state check
		assert(car.is_active == true, "Initial vehicle must be active")
		assert(car.is_damaged == false, "Initial vehicle must not be damaged")
		var body_spr: Sprite2D = car.get_node_or_null("BodySprite")
		assert(body_spr.modulate == Color.WHITE, "Body must have clean Color.WHITE modulate initially")
		print("  [STATE 1] Initial Clean State: OK")
		
		# 4. Extended sustained boost test (simulating player holding boost as long as they want)
		car.set_nitro_active(true)
		var dt: float = 1.0 / 60.0
		for i in range(240): # 4.0 continuous seconds of boost
			car.current_nitro = car.max_nitro # keep boost held
			car._physics_process(dt)
			assert(car.is_active == true, "Vehicle must NEVER stop/burst during continuous boost (frame %d)" % i)
			assert(car.is_damaged == false, "Vehicle must NEVER enter damaged mode during continuous boost (frame %d)" % i)
		
		print("  [STATE 2] Sustained Boost (4.0s / 240 frames held): Vehicle stays fully active and undamaged!")
		assert(car.is_active == true, "Vehicle must be active after sustained boost")
		assert(car.is_damaged == false, "Vehicle must NOT be damaged")
		assert(car.get_node_or_null("BurstExplosion") == null, "No BurstExplosion node should ever exist")
		assert(body_spr.modulate == Color.WHITE, "Body must remain Color.WHITE")
		
		# 5. Nitro deactivation
		car.set_nitro_active(false)
		car._physics_process(dt)
		assert(car.is_nitro_active == false, "Nitro must deactivate cleanly")
		print("  [STATE 3] Boost Released: Clean transition to normal driving")
		
		# 6. Crash and reset flow
		car.apply_crash_damage()
		assert(car.is_damaged == true or body_spr.modulate != Color.WHITE, "Vehicle should show crash visual on crash")
		car.reset_vehicle(Vector2.ZERO)
		assert(car.is_active == true, "Vehicle must be active on reset")
		assert(car.is_damaged == false, "Vehicle must be restored to undamaged on reset")
		assert(body_spr.modulate == Color.WHITE, "Body modulate must be WHITE on reset")
		print("  [STATE 4] Crash & Reset Flow: OK")
		
		root.remove_child(car)
		car.queue_free()
		passed_count += 1
		print("[PASS] Vehicle %s completed boost and clean operation tests!\n" % vname)
	
	print("==================================================================================================")
	print("RESULT: %d/%d VEHICLES PASSED ALL TESTS (Bigfoot, Sedan, Bike)" % [passed_count, test_vehicles.size()])
	print("==================================================================================================\n")
	
	quit(0)
