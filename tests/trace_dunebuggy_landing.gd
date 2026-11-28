extends SceneTree

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const IndianRoadTerrainV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_trace")

func _trace() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	root.add_child(vp)

	var terr := IndianRoadTerrainV2Scene.instantiate()
	vp.add_child(terr)
	terr.generate_route(RouteRegistry.get_route("tamil_nadu"))

	var veh: VehicleController = VehicleRegistry.instantiate_vehicle("dune_buggy")
	vp.add_child(veh)

	veh.global_position = Vector2(1500.0, 100.0)
	veh.linear_velocity = Vector2(400.0, -250.0)
	veh.set_nitro_active(true)
	Input.action_press("accelerate")

	var f_mount: Vector2 = veh.front_wheel_mount.position
	var r_mount: Vector2 = veh.rear_wheel_mount.position

	for f in range(30):
		await physics_frame

	print("Tracing Impact Landing frames:")
	for f in range(50):
		await physics_frame
		var f_pos: Vector2 = veh.to_local(veh.front_wheel.global_position)
		var r_pos: Vector2 = veh.to_local(veh.rear_wheel.global_position)
		var f_delta: float = f_pos.distance_to(f_mount)
		var r_delta: float = r_pos.distance_to(r_mount)
		if f_delta > 3.0 or r_delta > 3.0 or f % 5 == 0:
			print("  Frame %d: Chassis pos=(%.1f, %.1f), rot=%.2f, lin_vel=(%.1f, %.1f) | Front pos=(%.1f, %.1f) delta=%.2f | Rear pos=(%.1f, %.1f) delta=%.2f | contacts: R=%d, F=%d" % [
				f, veh.global_position.x, veh.global_position.y, veh.rotation,
				veh.linear_velocity.x, veh.linear_velocity.y,
				f_pos.x, f_pos.y, f_delta,
				r_pos.x, r_pos.y, r_delta,
				veh.rear_wheel.get_contact_count(), veh.front_wheel.get_contact_count()
			])

	quit(0)
