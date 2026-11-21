extends SceneTree

const VintageCarGarageScene = preload("res://scenes/modes/garage/VintageCarGarage.tscn")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	print("\n================================================================================")
	print("PART 1: GARAGE PREVIEW FIT VERIFICATION TEST")
	print("================================================================================\n")
	
	var garage = VintageCarGarageScene.instantiate()
	root.add_child(garage)
	
	# Allow ready and layout processing
	await process_frame
	await process_frame
	
	var vehicles = VehicleRegistry.get_all_vehicles()
	var total_count = vehicles.size()
	var cut_count = 0
	
	print("%-28s | %-8s | %-8s | %-8s | %-12s | %-6s" % [
		"Vehicle Name", "Width", "Height", "Scale", "Floor Y", "Status"
	])
	print("-".repeat(82))
	
	for i in range(total_count):
		garage._current_index = i
		garage._display_current_vehicle(true)
		await process_frame
		
		var v_data = vehicles[i]
		var v_id = v_data.get("id", "")
		var v_name = v_data.get("display_name", v_id)
		var cfg = VehicleRegistry.get_vehicle_config(v_id)
		
		var bounds = VintageCarGarageController.get_vehicle_real_bounds(cfg)
		var scale_val = VintageCarGarageController.compute_uniform_preview_scale(bounds.real_w, bounds.real_h)
		var scaled_w = bounds.real_w * scale_val
		var scaled_h = bounds.real_h * scale_val
		
		var disp_rect: TextureRect = garage.vehicle_display_rect
		assert(disp_rect != null, "VehicleDisplayRect must exist")
		assert(disp_rect.texture != null, "Vehicle %s preview texture must be loaded" % v_id)
		
		var rect_global_pos = disp_rect.global_position
		var rect_size = disp_rect.size
		var bottom_y = rect_global_pos.y + rect_size.y
		var top_y = rect_global_pos.y
		var left_x = rect_global_pos.x
		var right_x = rect_global_pos.x + rect_size.x
		
		# Verification criteria:
		# 1. Scaled width <= 900.0 (5% margin inside 1000px preview width)
		# 2. Scaled height <= 378.0 (5% margin inside 420px preview height)
		# 3. Horizontal centering: left margin and right margin relative to 640.0 center
		# 4. Vertical fit: top_y >= 110.0 (TopUI boundary), bottom_y == 505.0 (Floor line)
		# 5. Non-clipped texture bounds
		var is_cut = false
		var failure_reasons: Array[String] = []
		
		if scaled_w > 900.01 or scaled_h > 378.01:
			is_cut = true
			failure_reasons.append("Exceeds max size with 5% margin (w=%.1f, h=%.1f)" % [scaled_w, scaled_h])
			
		if top_y < 110.0:
			is_cut = true
			failure_reasons.append("Overlaps TopUI (top_y=%.1f < 110)" % top_y)
			
		if absf(bottom_y - 505.0) > 1.0:
			is_cut = true
			failure_reasons.append("Wheels do not touch floor (bottom_y=%.1f != 505.0)" % bottom_y)
			
		if left_x < 140.0 or right_x > 1140.0:
			is_cut = true
			failure_reasons.append("Overlaps stage pillars (X bounds=[%.1f, %.1f])" % [left_x, right_x])
			
		# Check texture dimensions match real vehicle bounds
		var tex = disp_rect.texture
		if absf(tex.get_width() - bounds.real_w) > 2.0 or absf(tex.get_height() - bounds.real_h) > 2.0:
			is_cut = true
			failure_reasons.append("Texture size (%dx%d) != real bounds (%.1fx%.1f)" % [
				tex.get_width(), tex.get_height(), bounds.real_w, bounds.real_h
			])
			
		var status_str = "fits"
		if is_cut:
			status_str = "CUT: " + ", ".join(failure_reasons)
			cut_count += 1
			
		print("%-28s | %8.1f | %8.1f | %8.4f | %12.1f | %-6s" % [
			v_name.substr(0, 28), scaled_w, scaled_h, scale_val, bottom_y, status_str
		])
		
	print("-".repeat(82))
	print("Summary: Total Vehicles = %d, Fits = %d, Cut = %d" % [total_count, total_count - cut_count, cut_count])
	
	if cut_count > 0:
		printerr("[FAIL] %d vehicle(s) were cut!" % cut_count)
		quit(1)
	else:
		print("[PASS] All %d vehicles fit perfectly with full visibility and floor contact!" % total_count)
		garage.queue_free()
		quit(0)
