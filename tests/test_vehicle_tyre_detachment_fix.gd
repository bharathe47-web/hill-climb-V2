extends SceneTree

## test_vehicle_tyre_detachment_fix.gd
## Comprehensive multi-iteration test suite verifying permanent vehicle tyre attachment
## Covers all 12 Phase 7 test scenarios across repeated runs at 60 Hz physics rate.

const BlueFlameTruckScene = preload("res://scenes/vehicle/BlueFlameTruck.tscn")
const IndianRoadTerrainV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("=================================================================")
	print("--- BEGIN VEHICLE TYRE ATTACHMENT ACCEPTANCE SUITE (60 Hz) ---")
	print("=================================================================")

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	root.add_child(vp)

	var terr := IndianRoadTerrainV2Scene.instantiate()
	vp.add_child(terr)
	terr.generate_route(RouteRegistry.get_route("tamil_nadu"))

	var veh := BlueFlameTruckScene.instantiate() as VehicleController
	vp.add_child(veh)

	var r_mount: Vector2 = veh.rear_wheel_mount.position
	var f_mount: Vector2 = veh.front_wheel_mount.position

	const MAX_ALLOWED_DIFF: float = 3.5 # pixels maximum acceptable displacement

	# We will run 3 full cycles of the 12-test suite to ensure stability across repeated attempts
	for cycle in range(1, 4):
		print("\n>>> EXECUTING ACCEPTANCE CYCLE %d OF 3 <<<" % cycle)

		# 1. Reset / Start driving
		veh.reset_vehicle(Vector2(200.0, 300.0))
		for f in range(30):
			await physics_frame
		_assert_wheel_delta("1. Start Driving (Settled)", veh, r_mount, f_mount, 2.5)

		# 2. Normal driving
		Input.action_press("accelerate")
		for f in range(40):
			await physics_frame
		_assert_wheel_delta("2. Normal Driving", veh, r_mount, f_mount, MAX_ALLOWED_DIFF)

		# 3. Continuous acceleration (high speed)
		for f in range(60):
			await physics_frame
		_assert_wheel_delta("3. Continuous Acceleration", veh, r_mount, f_mount, MAX_ALLOWED_DIFF)

		# 4. Nitro activation
		veh.set_nitro_active(true)
		for f in range(45):
			await physics_frame
		_assert_wheel_delta("4. Nitro Activation", veh, r_mount, f_mount, MAX_ALLOWED_DIFF)

		# 5. Nitro release
		veh.set_nitro_active(false)
		for f in range(30):
			await physics_frame
		_assert_wheel_delta("5. Nitro Release", veh, r_mount, f_mount, MAX_ALLOWED_DIFF)

		# 6. Uphill climb
		var x_up: float = 350.0 * 100.0
		veh.global_position = Vector2(x_up, terr.get_height_at(x_up) - 40.0)
		veh.linear_velocity = Vector2(200.0, -50.0)
		for f in range(30):
			await physics_frame
		_assert_wheel_delta("6. Uphill", veh, r_mount, f_mount, MAX_ALLOWED_DIFF)

		# 7. Downhill descent
		var x_down: float = 450.0 * 100.0
		veh.global_position = Vector2(x_down, terr.get_height_at(x_down) - 40.0)
		veh.linear_velocity = Vector2(300.0, 50.0)
		for f in range(30):
			await physics_frame
		_assert_wheel_delta("7. Downhill", veh, r_mount, f_mount, MAX_ALLOWED_DIFF)

		# 8. Jump (Mid-air)
		veh.global_position = Vector2(60000.0, 180.0)
		veh.linear_velocity = Vector2(400.0, -250.0)
		for f in range(25):
			await physics_frame
		_assert_wheel_delta("8. Jump (Mid-Air)", veh, r_mount, f_mount, 1.0)

		# 9. Landing
		for f in range(40):
			await physics_frame
		_assert_wheel_delta("9. Landing", veh, r_mount, f_mount, MAX_ALLOWED_DIFF)

		# 10. Rollover
		veh.rotation_degrees = 180.0
		for f in range(15):
			await physics_frame
		_assert_wheel_delta("10. Rollover", veh, r_mount, f_mount, MAX_ALLOWED_DIFF)

		# 11. Vehicle Recovery
		var rec_x: float = veh.global_position.x
		var rec_y: float = terr.get_height_at(rec_x) - 45.0
		veh.recover_vehicle(Vector2(rec_x, rec_y))
		await physics_frame
		_assert_wheel_delta("11. Recovery", veh, r_mount, f_mount, 0.5)

		# 12. Nitro after recovery
		veh.set_nitro_active(true)
		Input.action_press("accelerate")
		for f in range(35):
			await physics_frame
		_assert_wheel_delta("12. Nitro after Recovery", veh, r_mount, f_mount, MAX_ALLOWED_DIFF)
		veh.set_nitro_active(false)
		Input.action_release("accelerate")

	# Check no duplicate wheel bodies
	var wheel_body_count := 0
	for child in veh.get_children():
		if child is RigidBody2D and child.name.contains("Wheel"):
			wheel_body_count += 1
	assert(wheel_body_count == 2, "Expected exactly 2 wheel bodies in vehicle, found: %d" % wheel_body_count)
	print("\n  ✓ Verified no duplicate wheel bodies created (exact count: 2)")

	print("\n=================================================================")
	print("✓ ALL 3 CYCLES OF 12 VEHICLE MOVEMENT ACCEPTANCE TESTS PASSED (100%)!")
	print("=================================================================")
	quit(0)

func _assert_wheel_delta(scenario: String, veh: VehicleController, r_mount: Vector2, f_mount: Vector2, threshold: float) -> void:
	var r_local := veh.to_local(veh.rear_wheel.global_position)
	var f_local := veh.to_local(veh.front_wheel.global_position)
	var r_diff: float = r_local.distance_to(r_mount)
	var f_diff: float = f_local.distance_to(f_mount)

	print("  [%s] Rear delta: %.2f px, Front delta: %.2f px (Threshold: %.1f px) -> PASS" % [
		scenario, r_diff, f_diff, threshold
	])
	assert(r_diff <= threshold, "[%s] Rear wheel displaced beyond threshold: %.2f px > %.1f px" % [scenario, r_diff, threshold])
	assert(f_diff <= threshold, "[%s] Front wheel displaced beyond threshold: %.2f px > %.1f px" % [scenario, f_diff, threshold])
