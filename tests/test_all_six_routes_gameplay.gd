extends SceneTree

const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const RouteData = preload("res://resources/routes/RouteData.gd")
const IndianRoadsControllerScene = preload("res://scenes/modes/indian_roads/IndianRoadsMode.tscn")

func _init() -> void:
	call_deferred("_test_all_routes")

func _test_all_routes() -> void:
	print("=================================================================")
	print("--- TESTING ALL SIX INDIAN ROADS ROUTES GAMEPLAY LOADING ---")
	print("=================================================================")

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	root.add_child(vp)

	var routes := RouteRegistry.get_all_routes()
	print("Found %d routes to test." % routes.size())

	for r in routes:
		print("\n-------------------------------------------------------------")
		print(">>> TESTING ROUTE: '%s' (%s: %s -> %s) <<<" % [r.state_id, r.state_name, r.start_city, r.destination_city])
		print("-------------------------------------------------------------")

		var ctrl: IndianRoadsController = IndianRoadsControllerScene.instantiate()
		vp.add_child(ctrl)

		for f in range(3):
			await physics_frame

		ctrl.start_route(r)

		# Simulate 40 physics frames of driving
		Input.action_press("accelerate")
		for f in range(40):
			await physics_frame
		Input.action_release("accelerate")

		# Test Nitro for 20 frames
		ctrl.active_vehicle.set_nitro_active(true)
		for f in range(20):
			await physics_frame
		ctrl.active_vehicle.set_nitro_active(false)

		var v_pos: Vector2 = ctrl.active_vehicle.global_position if ctrl.active_vehicle else Vector2.ZERO
		var v_dist: float = ctrl.session_distance_m
		var is_grounded: bool = ctrl.active_vehicle.is_grounded if ctrl.active_vehicle else false
		var r_delta: float = 0.0
		var f_delta: float = 0.0
		if ctrl.active_vehicle:
			var r_pos := ctrl.active_vehicle.to_local(ctrl.active_vehicle.rear_wheel.global_position)
			var f_pos := ctrl.active_vehicle.to_local(ctrl.active_vehicle.front_wheel.global_position)
			var r_mount := ctrl.active_vehicle.rear_wheel_mount.position if ctrl.active_vehicle.rear_wheel_mount else ctrl.active_vehicle._initial_rear_wheel_offset
			var f_mount := ctrl.active_vehicle.front_wheel_mount.position if ctrl.active_vehicle.front_wheel_mount else ctrl.active_vehicle._initial_front_wheel_offset
			r_delta = r_pos.distance_to(r_mount)
			f_delta = f_pos.distance_to(f_mount)

		print("  Driven Distance: %.1fm" % v_dist)
		print("  Vehicle Position: %s" % str(v_pos))
		print("  Wheel Joint Deltas: Rear=%.2f px, Front=%.2f px" % [r_delta, f_delta])

		assert(ctrl.current_state == IndianRoadsController.ModeState.PLAYING, "State must be PLAYING")
		assert(v_dist > 1.0, "Vehicle should have made forward driving progress")
		assert(r_delta <= 3.5 and f_delta <= 3.5, "Tyres must not separate!")
		print("  [PASS] Route '%s' loaded and drove successfully without errors!" % r.state_id)

		ctrl.queue_free()
		for f in range(3):
			await physics_frame

	vp.queue_free()
	print("\n=================================================================")
	print("--- ALL SIX ROUTES SUCCESSFULLY TESTED AND VERIFIED PLAYABLE ---")
	print("=================================================================")
	quit(0)
