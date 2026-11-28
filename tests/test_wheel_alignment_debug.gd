extends SceneTree

const BlueFlameTruckScene = preload("res://scenes/vehicle/BlueFlameTruck.tscn")
const IndianRoadTerrainV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_test_wheel_alignment")

func _test_wheel_alignment() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	root.add_child(vp)

	var terr := IndianRoadTerrainV2Scene.instantiate()
	vp.add_child(terr)
	terr.generate_route(RouteRegistry.get_route("tamil_nadu"))

	var veh := BlueFlameTruckScene.instantiate() as VehicleController
	vp.add_child(veh)
	veh.global_position = Vector2(500.0, 300.0)

	# Let vehicle settle on road
	for i in range(60):
		await process_frame

	print("\n--- VEHICLE SETTLED ---")
	var r_mount: Vector2 = veh.rear_wheel_mount.position
	var f_mount: Vector2 = veh.front_wheel_mount.position
	var r_pos_settled: Vector2 = veh.to_local(veh.rear_wheel.global_position)
	var f_pos_settled: Vector2 = veh.to_local(veh.front_wheel.global_position)
	print("Rear Mount: ", r_mount, " | Actual Local Rear: ", r_pos_settled, " | Diff: ", r_mount.distance_to(r_pos_settled))
	print("Front Mount:", f_mount, " | Actual Local Front:", f_pos_settled, " | Diff: ", f_mount.distance_to(f_pos_settled))
	print("Chassis Rotation (deg): ", rad_to_deg(veh.rotation))

	# Now apply normal driving acceleration
	print("\n--- NORMAL DRIVING (Throttle=1.0) ---")
	Input.action_press("accelerate")
	for i in range(60):
		await process_frame

	var r_pos_drive: Vector2 = veh.to_local(veh.rear_wheel.global_position)
	var f_pos_drive: Vector2 = veh.to_local(veh.front_wheel.global_position)
	print("Rear Mount: ", r_mount, " | Actual Local Rear: ", r_pos_drive, " | Diff: ", r_mount.distance_to(r_pos_drive))
	print("Front Mount:", f_mount, " | Actual Local Front:", f_pos_drive, " | Diff: ", f_mount.distance_to(f_pos_drive))
	print("Chassis Rotation (deg): ", rad_to_deg(veh.rotation))

	# Now activate NITRO!
	print("\n--- NITRO BOOST ACTIVATED ---")
	veh.set_nitro_active(true)
	for i in range(60):
		await process_frame
		if i % 15 == 0:
			var r_cur: Vector2 = veh.to_local(veh.rear_wheel.global_position)
			var f_cur: Vector2 = veh.to_local(veh.front_wheel.global_position)
			print("Frame %d | Speed: %.1f km/h | Rot: %.1f deg | Rear Delta: %.2f px | Front Delta: %.2f px" % [
				i, veh.get_speed_kmh(), rad_to_deg(veh.rotation), r_mount.distance_to(r_cur), f_mount.distance_to(f_cur)
			])

	Input.action_release("accelerate")
	veh.set_nitro_active(false)
	vp.queue_free()
	quit(0)
