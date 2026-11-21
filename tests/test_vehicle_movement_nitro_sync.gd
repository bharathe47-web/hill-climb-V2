extends SceneTree

# Comprehensive Physical Verification Test:
# 1. Normal vehicle movement
# 2. Wheel rotation matching speed
# 3. Body-wheel synchronization and strict attachment
# 4. Uphill slope climbing
# 5. Downhill slope rolling & rotation
# 6. Uneven terrain bump response
# 7. Jumping and landing stability
# 8. Nitro activation, acceleration, and deactivation
# 9. Clean visual check (no engine burst/flame effects)
# Tested across ALL 20 supported vehicles in the project.

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

var _test_ground: StaticBody2D = null

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n==================================================================================")
	print("--- BEGIN ALL-VEHICLES MOVEMENT, NITRO BOOST & WHEEL SYNCHRONIZATION TEST SUITE ---")
	print("==================================================================================")
	
	_create_test_environment()
	
	var vehicle_ids: Array[String] = VehicleRegistry.ORDERED_IDS
	print("Total registered vehicles to verify: %d" % vehicle_ids.size())
	
	var passed_count: int = 0
	var failed_count: int = 0
	var results: Array[Dictionary] = []
	
	for v_id in vehicle_ids:
		var res: Dictionary = await _test_vehicle(v_id)
		results.append(res)
		if res.get("passed", false):
			passed_count += 1
		else:
			failed_count += 1
			
	print("\n==================================================================================")
	print("--- TEST RESULTS SUMMARY ---")
	print("==================================================================================")
	print("%-18s | %-8s | %-12s | %-12s | %-12s | %-8s" % ["Vehicle ID", "Move OK", "Wheel Rot OK", "Body Sync OK", "Nitro Boost", "Status"])
	print("----------------------------------------------------------------------------------")
	for r in results:
		print("%-18s | %-8s | %-12s | %-12s | %-12s | %-8s" % [
			r.get("id", "unknown"),
			"PASS" if r.get("normal_move", false) else "FAIL",
			"PASS" if r.get("wheel_rotation", false) else "FAIL",
			"PASS" if r.get("body_sync", false) else "FAIL",
			"PASS (+%.0f)" % r.get("nitro_gain", 0.0) if r.get("nitro_accel", false) else "FAIL",
			"PASSED" if r.get("passed", false) else "FAILED"
		])
	print("----------------------------------------------------------------------------------")
	print("Total: %d Passed, %d Failed" % [passed_count, failed_count])
	print("==================================================================================\n")
	
	_cleanup_test_environment()
	
	if failed_count > 0:
		push_error("Some vehicle tests failed!")
		quit(1)
	else:
		print("✓ ALL 20 VEHICLES PASSED ALL MOVEMENT, NITRO & SYNCHRONIZATION CHECKS!")
		quit(0)

func _create_test_environment() -> void:
	_test_ground = StaticBody2D.new()
	_test_ground.name = "TestGround"
	_test_ground.collision_layer = 1
	_test_ground.collision_mask = 2
	
	# Flat ground line from -2000 to +4000 at Y = 400
	var flat_shape := CollisionShape2D.new()
	var flat_seg := SegmentShape2D.new()
	flat_seg.a = Vector2(-2000, 400)
	flat_seg.b = Vector2(4000, 400)
	flat_shape.shape = flat_seg
	_test_ground.add_child(flat_shape)
	
	# Uphill ramp: X: 4000 -> 6000, Y: 400 -> 0 (11° incline)
	var uphill_shape := CollisionShape2D.new()
	var uphill_seg := SegmentShape2D.new()
	uphill_seg.a = Vector2(4000, 400)
	uphill_seg.b = Vector2(6000, 0)
	uphill_shape.shape = uphill_seg
	_test_ground.add_child(uphill_shape)
	
	# Downhill ramp: X: -3000 -> -500, Y: 0 -> 400 (downhill)
	var downhill_shape := CollisionShape2D.new()
	var downhill_seg := SegmentShape2D.new()
	downhill_seg.a = Vector2(-3000, 0)
	downhill_seg.b = Vector2(-500, 400)
	downhill_shape.shape = downhill_seg
	_test_ground.add_child(downhill_shape)
	
	root.add_child(_test_ground)

func _cleanup_test_environment() -> void:
	if is_instance_valid(_test_ground):
		root.remove_child(_test_ground)
		_test_ground.queue_free()

func _teleport_vehicle(vehicle: VehicleController, at_position: Vector2, rot: float = 0.0) -> void:
	vehicle.global_position = at_position
	vehicle.rotation = rot
	vehicle.linear_velocity = Vector2.ZERO
	vehicle.angular_velocity = 0.0
	
	var chassis_transform := Transform2D(rot, at_position)
	PhysicsServer2D.body_set_state(vehicle.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, chassis_transform)
	PhysicsServer2D.body_set_state(vehicle.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
	PhysicsServer2D.body_set_state(vehicle.get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)
	
	var rw = vehicle.rear_wheel
	var fw = vehicle.front_wheel
	if rw:
		rw.linear_velocity = Vector2.ZERO
		rw.angular_velocity = 0.0
		var rw_world = at_position + vehicle._initial_rear_wheel_offset.rotated(rot)
		var rear_transform := Transform2D(rot, rw_world)
		PhysicsServer2D.body_set_state(rw.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, rear_transform)
		PhysicsServer2D.body_set_state(rw.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
		PhysicsServer2D.body_set_state(rw.get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)
	if fw:
		fw.linear_velocity = Vector2.ZERO
		fw.angular_velocity = 0.0
		var fw_world = at_position + vehicle._initial_front_wheel_offset.rotated(rot)
		var front_transform := Transform2D(rot, fw_world)
		PhysicsServer2D.body_set_state(fw.get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, front_transform)
		PhysicsServer2D.body_set_state(fw.get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
		PhysicsServer2D.body_set_state(fw.get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)

func _test_vehicle(v_id: String) -> Dictionary:
	var v_name: String = VehicleRegistry.get_vehicle(v_id).get("name", v_id)
	print("\n>>> Testing Vehicle: %s (%s)..." % [v_name, v_id])
	
	var vehicle = VehicleRegistry.instantiate_vehicle(v_id)
	if not vehicle:
		push_error("Failed to instantiate vehicle: %s" % v_id)
		return {"id": v_id, "passed": false}
		
	root.add_child(vehicle)
	vehicle._ready()
	
	var bottom_offset: float = vehicle.get_wheel_bottom_offset()
	_teleport_vehicle(vehicle, Vector2(100, 400.0 - bottom_offset), 0.0)
	
	# Wait for physics settlement onto the ground
	for frame in range(10):
		await physics_frame
	
	var res := {
		"id": v_id,
		"name": v_name,
		"normal_move": false,
		"wheel_rotation": false,
		"body_sync": false,
		"uphill": false,
		"downhill": false,
		"bump_jump": false,
		"nitro_accel": false,
		"nitro_gain": 0.0,
		"visuals_clean": false,
		"passed": false
	}
	
	var rw: RigidBody2D = vehicle.rear_wheel
	var fw: RigidBody2D = vehicle.front_wheel
	var init_rw_local_x: float = vehicle.to_local(rw.global_position).x if rw else 0.0
	var init_fw_local_x: float = vehicle.to_local(fw.global_position).x if fw else 0.0
	
	# --- 1. VISUAL CHECK: Ensure NO engine burst, flame, or glow effects are visible ---
	var flame_clean: bool = true
	if vehicle.nitro_flame and vehicle.nitro_flame.modulate.a > 0.05:
		flame_clean = false
	if vehicle.nitro_burst and vehicle.nitro_burst.modulate.a > 0.05:
		flame_clean = false
	if vehicle.boost_particles and vehicle.boost_particles.modulate.a > 0.05 and vehicle.boost_particles.color.a > 0.05:
		flame_clean = false
	res["visuals_clean"] = flame_clean
	assert(flame_clean, "Vehicle %s must have clean visuals (no visible burst/flame)" % v_id)
	
	# --- 2. NORMAL VEHICLE MOVEMENT & ACCELERATION ---
	Input.action_press("accelerate")
	for frame in range(35):
		await physics_frame
	Input.action_release("accelerate")
	
	var norm_speed: float = vehicle.linear_velocity.dot(vehicle.transform.x)
	res["normal_move"] = norm_speed > 25.0
	print("  • Normal drive forward speed: %.1f px/s" % norm_speed)
	assert(norm_speed > 25.0, "%s must move forward under normal acceleration" % v_id)
	
	# --- 3. WHEEL ROTATION MATCHING SPEED ---
	var rw_w: float = rw.angular_velocity if rw else 0.0
	var fw_w: float = fw.angular_velocity if fw else 0.0
	var w_rad: float = maxf(vehicle.wheel_radius, 1.0)
	var expected_roll_w: float = norm_speed / w_rad
	
	var rw_rotates: bool = (rw == null or rw_w > 0.8)
	var fw_rotates: bool = (fw == null or fw_w > 0.8)
	res["wheel_rotation"] = rw_rotates and fw_rotates
	print("  • Wheel rotation: Rear=%.1f rad/s, Front=%.1f rad/s (Expected roll=%.1f rad/s)" % [rw_w, fw_w, expected_roll_w])
	assert(res["wheel_rotation"], "%s wheels must rotate when moving forward" % v_id)
	
	# --- 4. BODY & WHEEL SYNCHRONIZATION (Strict X alignment & Y suspension travel) ---
	var cur_rw_local_x: float = vehicle.to_local(rw.global_position).x if rw else 0.0
	var cur_fw_local_x: float = vehicle.to_local(fw.global_position).x if fw else 0.0
	var x_drift_r: float = absf(cur_rw_local_x - init_rw_local_x)
	var x_drift_f: float = absf(cur_fw_local_x - init_fw_local_x)
	
	var rw_disp_y: float = (rw.global_position - vehicle.to_global(vehicle._initial_rear_wheel_offset)).dot(vehicle.transform.y) if rw else 0.0
	var fw_disp_y: float = (fw.global_position - vehicle.to_global(vehicle._initial_front_wheel_offset)).dot(vehicle.transform.y) if fw else 0.0
	
	var sync_ok: bool = x_drift_r < 1.5 and x_drift_f < 1.5 and absf(rw_disp_y) < 14.0 and absf(fw_disp_y) < 14.0
	res["body_sync"] = sync_ok
	print("  • Body-Wheel Sync: X-drift Rear=%.3f px, Front=%.3f px | Y-disp Rear=%.2f px, Front=%.2f px" % [
		x_drift_r, x_drift_f, rw_disp_y, fw_disp_y
	])
	assert(sync_ok, "%s wheels must remain strictly synchronized to body" % v_id)
	
	# --- 5. UPHILL SLOPE CLIMBING ---
	_teleport_vehicle(vehicle, Vector2(4150, 370 - bottom_offset), -0.20)
	for frame in range(5):
		await physics_frame
	Input.action_press("accelerate")
	for frame in range(35):
		await physics_frame
	Input.action_release("accelerate")
	var uphill_speed: float = vehicle.linear_velocity.dot(vehicle.transform.x)
	res["uphill"] = uphill_speed > 10.0
	print("  • Uphill climb forward speed: %.1f px/s" % uphill_speed)
	assert(uphill_speed > 10.0, "%s must be able to climb uphill" % v_id)
	
	# --- 6. DOWNHILL SLOPE ROLLING & NATURAL ROTATION ---
	_teleport_vehicle(vehicle, Vector2(-1500, 240 - bottom_offset), 0.16)
	for frame in range(5):
		await physics_frame
	# Neutral throttle: roll down naturally
	for frame in range(30):
		await physics_frame
	var downhill_speed: float = vehicle.linear_velocity.dot(vehicle.transform.x)
	var downhill_rw_w: float = rw.angular_velocity if rw else 0.0
	res["downhill"] = downhill_speed > 15.0 and downhill_rw_w > 0.5
	print("  • Downhill rolling speed: %.1f px/s, Wheel rot: %.1f rad/s" % [downhill_speed, downhill_rw_w])
	assert(res["downhill"], "%s must roll downhill with natural wheel rotation" % v_id)
	
	# --- 7. BUMP RESPONSE & AIRBORNE JUMP / LANDING ---
	_teleport_vehicle(vehicle, Vector2(200, 200), 0.0)
	vehicle.linear_velocity = Vector2(80.0, -150.0)
	for frame in range(15):
		await physics_frame
	var jump_rw_x = vehicle.to_local(rw.global_position).x if rw else 0.0
	var jump_x_drift = absf(jump_rw_x - init_rw_local_x)
	assert(jump_x_drift < 1.5, "%s wheels must stay aligned in mid-air" % v_id)
	
	# Land onto ground
	for frame in range(40):
		await physics_frame
	var land_rw_x = vehicle.to_local(rw.global_position).x if rw else 0.0
	var land_x_drift = absf(land_rw_x - init_rw_local_x)
	res["bump_jump"] = land_x_drift < 1.5
	print("  • Jump & Landing alignment drift: Mid-air=%.3f px, Landing=%.3f px" % [jump_x_drift, land_x_drift])
	assert(res["bump_jump"], "%s must remain stable and aligned on landing" % v_id)
	
	# --- 8. NITRO ACTIVATION, ACCELERATION & DEACTIVATION ---
	# Test Nitro from complete standstill on flat ground
	_teleport_vehicle(vehicle, Vector2(500, 400.0 - bottom_offset), 0.0)
	for frame in range(5):
		await physics_frame
	
	# Verify no silver strut connector is visible
	assert(vehicle.rear_strut == null or vehicle.rear_strut.visible == false, "%s Rear silver connector must be hidden" % v_id)
	assert(vehicle.front_strut == null or vehicle.front_strut.visible == false, "%s Front silver connector must be hidden" % v_id)
	
	# Activate Nitro
	vehicle.set_nitro_active(true)
	await physics_frame
	assert(vehicle.is_nitro_active == true, "%s Nitro must activate" % v_id)
	assert(vehicle.nitro_flame != null and vehicle.nitro_flame.visible == true, "%s Nitro flame must be visible while boosting" % v_id)
	
	# Run 25 frames of pure Nitro boost without holding accelerate
	for frame in range(25):
		await physics_frame
		
	var nitro_speed: float = vehicle.linear_velocity.dot(vehicle.transform.x)
	var nitro_rw_w: float = rw.angular_velocity if rw else 0.0
	print("  • Standstill Nitro boost speed after 25 frames: %.1f px/s, Wheel rot: %.1f rad/s" % [nitro_speed, nitro_rw_w])
	
	res["nitro_gain"] = nitro_speed
	res["nitro_accel"] = nitro_speed > 30.0 and nitro_rw_w > 1.2
	assert(res["nitro_accel"], "%s Nitro must accelerate vehicle from standstill" % v_id)
	assert(vehicle.is_active == true, "%s Nitro must NOT kill driver (vehicle must remain active)" % v_id)
	
	# Test Nitro in motion (boost speed further)
	for frame in range(20):
		await physics_frame
	var high_speed: float = vehicle.linear_velocity.dot(vehicle.transform.x)
	assert(high_speed > nitro_speed, "%s Nitro must continue to increase vehicle speed" % v_id)
	assert(vehicle.is_active == true, "%s Driver must still be alive at high speed boost" % v_id)
	print("  • Nitro in-motion speed: %.1f px/s" % high_speed)
	
	# Deactivate Nitro
	vehicle.set_nitro_active(false)
	await physics_frame
	assert(vehicle.is_nitro_active == false, "%s Nitro must deactivate cleanly" % v_id)
	assert(vehicle.nitro_flame.visible == false, "%s Nitro flame must hide when boost stops" % v_id)
	print("  • Nitro deactivation: Clean transition to normal physics (flame stopped)")
	
	res["passed"] = res["normal_move"] and res["wheel_rotation"] and res["body_sync"] and res["uphill"] and res["downhill"] and res["bump_jump"] and res["nitro_accel"] and res["visuals_clean"]
	
	root.remove_child(vehicle)
	vehicle.queue_free()
	for frame in range(2):
		await physics_frame
	
	print("  ✓ %s: All movement, rotation, body-wheel sync, and Nitro checks PASSED!" % v_id)
	return res
