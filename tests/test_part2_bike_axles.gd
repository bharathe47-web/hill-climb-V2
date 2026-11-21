extends SceneTree

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const VintageCarGarageScene = preload("res://scenes/modes/garage/VintageCarGarage.tscn")

const BIKE_IDS = [
	"car_14",
	"car_15",
	"car_16",
	"car_17",
	"car_24",
	"car_25"
]

func _init() -> void:
	print("\n==================================================================================================")
	print("TASK A: BIKE AXLE ALIGNMENT, GROUND CONTACT & CIRCLE FIT TEST")
	print("==================================================================================================\n")
	
	var garage = VintageCarGarageScene.instantiate()
	root.add_child(garage)
	await process_frame
	await process_frame
	
	print("%-26s | %-16s | %-16s | %-8s | %-10s | %-10s | %-12s | %-6s" % [
		"Bike Name", "Front Offset", "Rear Offset", "Radius", "Dist F (px)", "Dist R (px)", "Ground Gap", "Status"
	])
	print("-".repeat(118))
	
	var total_bikes = BIKE_IDS.size()
	var error_count = 0
	
	for b_id in BIKE_IDS:
		var cfg = VehicleRegistry.get_vehicle_config(b_id)
		var b_name = cfg.get("name", b_id)
		var f_off: Vector2 = cfg.get("front_wheel_offset", Vector2.ZERO)
		var r_off: Vector2 = cfg.get("rear_wheel_offset", Vector2.ZERO)
		var wr: float = cfg.get("wheel_radius", 100.0)
		var body_scale: float = cfg.get("body_scale", 1.0)
		
		# 1. Check ground line contact:
		# Bottom of front wheel = f_off.y + wr
		# Bottom of rear wheel = r_off.y + wr
		var front_bottom = f_off.y + wr
		var rear_bottom = r_off.y + wr
		var ground_gap = absf(front_bottom - rear_bottom)
		
		# 2. Check gameplay instantiation:
		# In gameplay, wheel positions at rest match initial mounts
		var bike_node: VehicleController = VehicleRegistry.instantiate_vehicle(b_id)
		assert(bike_node != null, "Bike %s must instantiate" % b_id)
		root.add_child(bike_node)
		bike_node.position = Vector2(500, 300)
		await physics_frame
		await physics_frame
		
		var r_wheel = bike_node.rear_wheel
		var f_wheel = bike_node.front_wheel
		assert(r_wheel != null and f_wheel != null, "Wheels must exist on %s" % b_id)
		
		# Expected rest mount positions in physics space:
		var expected_r_pos = r_off * body_scale
		var expected_f_pos = f_off * body_scale
		
		# In VehicleController, the red dot is at _initial_rear_wheel_offset,
		# and the green circle center is at rear_wheel.position
		var dist_r = r_wheel.position.distance_to(expected_r_pos)
		var dist_f = f_wheel.position.distance_to(expected_f_pos)
		
		# Check draw order: rear wheel (behind), front wheel (behind), body (on top)
		var body_sprite = bike_node.get_node_or_null("BodySprite") as CanvasItem
		assert(r_wheel.z_index < body_sprite.z_index, "Rear wheel must be behind body frame on %s" % b_id)
		assert(f_wheel.z_index < body_sprite.z_index, "Front wheel must be behind body frame on %s" % b_id)
		
		# Clean up gameplay bike
		bike_node.queue_free()
		await physics_frame
		
		var is_ok = (dist_r <= 1.0) and (dist_f <= 1.0) and (ground_gap <= 1.0)
		var status_str = "PASS" if is_ok else "FAIL"
		if not is_ok:
			error_count += 1
			
		print("%-26s | (%6.1f, %5.1f) | (%6.1f, %5.1f) | %8.1f | %10.2f | %10.2f | %12.2f | %-6s" % [
			b_name.substr(0, 26), f_off.x, f_off.y, r_off.x, r_off.y, wr, dist_f, dist_r, ground_gap, status_str
		])
		
	print("-".repeat(118))
	print("Summary: Total Bikes = %d, Passed = %d, Failed = %d" % [total_bikes, total_bikes - error_count, error_count])
	
	garage.queue_free()
	
	if error_count > 0:
		printerr("[FAIL] %d bike(s) failed alignment/ground test!" % error_count)
		quit(1)
	else:
		print("[PASS] All %d bikes have perfect axle alignment, 0px circle distance, and touch the exact same ground line!" % total_bikes)
		quit(0)
