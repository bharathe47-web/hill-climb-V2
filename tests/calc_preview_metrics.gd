extends SceneTree

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	var vehicles = VehicleRegistry.get_all_vehicles()
	print("%-25s | %-8s | %-8s | %-8s | %-8s | %-8s" % ["Vehicle Name", "Real W", "Real H", "Scale", "Scaled W", "Scaled H"])
	print("-".repeat(80))
	
	# Preview area dimensions:
	# Preview area: X from 140 to 1140 (width 1000), Y from 110 to 530 (height 420)
	var preview_w = 1000.0
	var preview_h = 420.0
	var target_w = preview_w * 0.70 # 700.0
	var max_w = preview_w * 0.90   # 900.0 (5% margin each side)
	var max_h = preview_h * 0.90   # 378.0 (5% margin each side)
	
	for v in vehicles:
		var v_id = v.get("id", "")
		var v_name = v.get("display_name", v_id)
		var cfg = VehicleRegistry.get_vehicle_config(v_id)
		
		var bw = cfg.get("body_size", Vector2(800, 400)).x
		var bh = cfg.get("body_size", Vector2(800, 400)).y
		var pivot = cfg.get("body_pivot", Vector2(bw * 0.5, bh * 0.5))
		var r_off = cfg.get("rear_wheel_offset", Vector2.ZERO)
		var f_off = cfg.get("front_wheel_offset", Vector2.ZERO)
		var wr = cfg.get("wheel_radius", 100.0)
		
		var min_x = minf(-pivot.x, minf(r_off.x - wr, f_off.x - wr))
		var max_x = maxf(bw - pivot.x, maxf(r_off.x + wr, f_off.x + wr))
		var min_y = minf(-pivot.y, minf(r_off.y - wr, f_off.y - wr))
		var max_y = maxf(bh - pivot.y, maxf(r_off.y + wr, f_off.y + wr))
		
		var real_w = max_x - min_x
		var real_h = max_y - min_y
		
		var s = target_w / real_w
		# Enforce margins: width <= max_w and height <= max_h
		if real_w * s > max_w:
			s = max_w / real_w
		if real_h * s > max_h:
			s = max_h / real_h
			
		print("%-25s | %8.1f | %8.1f | %8.4f | %8.1f | %8.1f" % [v_name.substr(0, 25), real_w, real_h, s, real_w * s, real_h * s])
		
	quit()
