extends SceneTree

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const IndianRoadTerrainV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_run_reproduction_suite")

func _run_reproduction_suite() -> void:
	print("=================================================================")
	print("--- INVESTIGATING NITRO VEHICLE PHYSICS & WHEEL ALIGNMENT ---")
	print("=================================================================")

	var vehicle_ids := VehicleRegistry.get_vehicle_ids()
	print("Testing Vehicle IDs: %s" % str(vehicle_ids))

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	root.add_child(vp)

	var terr := IndianRoadTerrainV2Scene.instantiate()
	vp.add_child(terr)
	terr.generate_route(RouteRegistry.get_route("tamil_nadu"))

	for v_id in vehicle_ids:
		print("\n-------------------------------------------------------------")
		print(">>> TESTING VEHICLE: '%s' <<<" % v_id)
		print("-------------------------------------------------------------")

		var veh: VehicleController = VehicleRegistry.instantiate_vehicle(v_id)
		if not veh:
			print("  [ERROR] Failed to instantiate '%s'!" % v_id)
			continue

		vp.add_child(veh)

		var r_mount: Vector2 = veh.rear_wheel_mount.position if veh.rear_wheel_mount else (veh.rear_wheel.position if veh.rear_wheel else Vector2.ZERO)
		var f_mount: Vector2 = veh.front_wheel_mount.position if veh.front_wheel_mount else (veh.front_wheel.position if veh.front_wheel else Vector2.ZERO)

		print("  Initial mount offsets: Rear=%s, Front=%s" % [r_mount, f_mount])
		print("  PinJoint softness: Rear=%f, Front=%f" % [
			veh.rear_joint.softness if veh.rear_joint else -1.0,
			veh.front_joint.softness if veh.front_joint else -1.0
		])
		print("  Vehicle Mass: Chassis=%.1f, RearWheel=%.1f, FrontWheel=%.1f" % [
			veh.mass,
			veh.rear_wheel.mass if veh.rear_wheel else 0.0,
			veh.front_wheel.mass if veh.front_wheel else 0.0
		])

		# Test 1: Start route
		veh.reset_vehicle(Vector2(200.0, 300.0))
		for f in range(30):
			await physics_frame
		_log_status("1. Start Route (Settled)", veh, r_mount, f_mount)

		# Test 2: Accelerate normally
		Input.action_press("accelerate")
		for f in range(40):
			await physics_frame
		_log_status("2. Accelerate Normally", veh, r_mount, f_mount)

		# Test 3: Activate Nitro while moving
		veh.set_nitro_active(true)
		for f in range(15):
			await physics_frame
		_log_status("3. Activate Nitro While Moving", veh, r_mount, f_mount)

		# Test 4: Hold Nitro (continuous)
		for f in range(60):
			await physics_frame
		_log_status("4. Hold Nitro Continuous", veh, r_mount, f_mount)

		# Test 5: Release Nitro
		veh.set_nitro_active(false)
		for f in range(30):
			await physics_frame
		_log_status("5. Release Nitro", veh, r_mount, f_mount)

		# Test 6: Repeat Nitro activation several times
		for burst in range(4):
			veh.set_nitro_active(true)
			for f in range(15):
				await physics_frame
			veh.set_nitro_active(false)
			for f in range(15):
				await physics_frame
		_log_status("6. Repeat Nitro Bursts", veh, r_mount, f_mount)

		# Test 7: Activate Nitro Uphill
		_teleport_vehicle(veh, Vector2(750.0, 280.0), -0.35, Vector2(100.0, -35.0))
		veh.set_nitro_active(true)
		for f in range(40):
			await physics_frame
		_log_status("7. Activate Nitro Uphill", veh, r_mount, f_mount)

		# Test 8: Activate Nitro Downhill
		_teleport_vehicle(veh, Vector2(1200.0, 220.0), 0.35, Vector2(250.0, 80.0))
		veh.set_nitro_active(true)
		for f in range(40):
			await physics_frame
		_log_status("8. Activate Nitro Downhill", veh, r_mount, f_mount)

		# Test 9: Activate Nitro during a jump (airborne)
		_teleport_vehicle(veh, Vector2(1500.0, 100.0), 0.0, Vector2(400.0, -250.0))
		veh.set_nitro_active(true)
		for f in range(30):
			await physics_frame
		_log_status("9. Activate Nitro Mid-Air Jump", veh, r_mount, f_mount)

		# Test 10: Landing with Nitro active
		for f in range(50):
			await physics_frame
		_log_status("10. Impact Landing with Nitro", veh, r_mount, f_mount)

		# Test 11: Rollover
		_teleport_vehicle(veh, Vector2(1800.0, 280.0), PI, Vector2(50.0, 50.0))
		for f in range(30):
			await physics_frame
		_log_status("11. Vehicle Rollover (Inverted)", veh, r_mount, f_mount)

		# Test 12: Recovery
		veh.recover_vehicle(Vector2(1900.0, 280.0))
		for f in range(10):
			await physics_frame
		_log_status("12. Vehicle Recovery Triggered", veh, r_mount, f_mount)

		# Test 13: Activate Nitro after Recovery
		veh.set_nitro_active(true)
		for f in range(40):
			await physics_frame
		_log_status("13. Activate Nitro After Recovery", veh, r_mount, f_mount)

		veh.queue_free()

	Input.action_release("accelerate")
	print("\n=================================================================")
	print("--- FINISHED REPRODUCTION AND DIAGNOSTIC SUITE ---")
	print("=================================================================")
	quit(0)

func _log_status(test_name: String, veh: VehicleController, r_mount: Vector2, f_mount: Vector2) -> void:
	var r_pos: Vector2 = veh.to_local(veh.rear_wheel.global_position) if veh.rear_wheel else Vector2.ZERO
	var f_pos: Vector2 = veh.to_local(veh.front_wheel.global_position) if veh.front_wheel else Vector2.ZERO
	var r_delta: float = r_pos.distance_to(r_mount)
	var f_delta: float = f_pos.distance_to(f_mount)
	var status: String = "PASS" if (r_delta <= 3.5 and f_delta <= 3.5) else "FAIL (DETACHED!)"
	print("  [%s] Rear delta: %.2f px, Front delta: %.2f px -> %s" % [test_name, r_delta, f_delta, status])

func _teleport_vehicle(veh: VehicleController, pos: Vector2, rot: float, vel: Vector2) -> void:
	veh.global_position = pos
	veh.rotation = rot
	veh.linear_velocity = vel
	veh.angular_velocity = 0.0
	PhysicsServer2D.body_set_state(veh.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(rot, pos))
	PhysicsServer2D.body_set_state(veh.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, vel)
	if veh.rear_wheel:
		var r_pos := veh.to_global(veh.rear_wheel_mount.position if veh.rear_wheel_mount else veh.rear_wheel.position)
		veh.rear_wheel.global_position = r_pos
		veh.rear_wheel.rotation = rot
		veh.rear_wheel.linear_velocity = vel
		veh.rear_wheel.angular_velocity = 0.0
		PhysicsServer2D.body_set_state(veh.rear_wheel.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(rot, r_pos))
		PhysicsServer2D.body_set_state(veh.rear_wheel.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, vel)
	if veh.front_wheel:
		var f_pos := veh.to_global(veh.front_wheel_mount.position if veh.front_wheel_mount else veh.front_wheel.position)
		veh.front_wheel.global_position = f_pos
		veh.front_wheel.rotation = rot
		veh.front_wheel.linear_velocity = vel
		veh.front_wheel.angular_velocity = 0.0
		PhysicsServer2D.body_set_state(veh.front_wheel.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(rot, f_pos))
		PhysicsServer2D.body_set_state(veh.front_wheel.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, vel)
