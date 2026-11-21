extends SceneTree

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	print("[GENERATE] Generating full unclipped preview images for all vehicles (margin=0)...")
	var vehicles = VehicleRegistry.get_all_vehicles()
	
	for v in vehicles:
		var v_id = v.get("id", "")
		var cfg = VehicleRegistry.get_vehicle_config(v_id)
		var preview_path = v.get("preview_path", "")
		if preview_path.is_empty():
			continue
			
		var bw: float = cfg.get("body_size", Vector2(800, 400)).x
		var bh: float = cfg.get("body_size", Vector2(800, 400)).y
		var pivot: Vector2 = cfg.get("body_pivot", Vector2(bw * 0.5, bh * 0.5))
		var r_off: Vector2 = cfg.get("rear_wheel_offset", Vector2.ZERO)
		var f_off: Vector2 = cfg.get("front_wheel_offset", Vector2.ZERO)
		var wr: float = cfg.get("wheel_radius", 100.0)
		var is_bike: bool = cfg.get("is_bike", false)
		
		# Compute vehicle bounding box relative to pivot
		var min_x = minf(-pivot.x, minf(r_off.x - wr, f_off.x - wr))
		var max_x = maxf(bw - pivot.x, maxf(r_off.x + wr, f_off.x + wr))
		var min_y = minf(-pivot.y, minf(r_off.y - wr, f_off.y - wr))
		var max_y = maxf(bh - pivot.y, maxf(r_off.y + wr, f_off.y + wr))
		
		var canvas_w = int(ceil(max_x - min_x))
		var canvas_h = int(ceil(max_y - min_y))
		
		# Origin (body pivot) in canvas coordinates
		var origin = Vector2(-min_x, -min_y)
		
		var canvas = Image.create(canvas_w, canvas_h, false, Image.FORMAT_RGBA8)
		canvas.fill(Color(0, 0, 0, 0))
		
		# Load body image
		var body_img_path = cfg.get("body_image", "")
		if body_img_path.is_empty():
			body_img_path = cfg.get("bodyImage", "")
		var body_img: Image = null
		if not body_img_path.is_empty() and ResourceLoader.exists(body_img_path):
			body_img = load(body_img_path).get_image()
			
		# Load wheel image(s)
		var wheel_img_path = cfg.get("wheel_image", "")
		if wheel_img_path.is_empty():
			wheel_img_path = cfg.get("wheelImage", "")
		var wheel_img: Image = null
		if not wheel_img_path.is_empty() and ResourceLoader.exists(wheel_img_path):
			wheel_img = load(wheel_img_path).get_image()
			
		# Also check for separate front wheel if exists
		var f_wheel_path = wheel_img_path.replace("wheel_back", "wheel_front")
		var f_wheel_img: Image = null
		if f_wheel_path != wheel_img_path and ResourceLoader.exists(f_wheel_path):
			f_wheel_img = load(f_wheel_path).get_image()
		else:
			f_wheel_img = wheel_img
			
		var r_wheel_target_size = int(round(wr * 2.0))
		var f_wheel_target_size = int(round(wr * 2.0))
		
		var r_wheel_scaled: Image = null
		if wheel_img:
			r_wheel_scaled = wheel_img.duplicate()
			r_wheel_scaled.resize(r_wheel_target_size, r_wheel_target_size, Image.INTERPOLATE_LANCZOS)
			
		var f_wheel_scaled: Image = null
		if f_wheel_img:
			f_wheel_scaled = f_wheel_img.duplicate()
			f_wheel_scaled.resize(f_wheel_target_size, f_wheel_target_size, Image.INTERPOLATE_LANCZOS)
			
		# Draw order:
		# Bikes & Cars: rear wheel (z -1), front wheel (z -1), body (z 0/1)
		var body_pos = Vector2(int(round(origin.x - pivot.x)), int(round(origin.y - pivot.y)))
		var r_wheel_pos = Vector2(int(round(origin.x + r_off.x - wr)), int(round(origin.y + r_off.y - wr)))
		var f_wheel_pos = Vector2(int(round(origin.x + f_off.x - wr)), int(round(origin.y + f_off.y - wr)))
		
		if is_bike:
			# 1. Rear wheel (behind)
			if r_wheel_scaled:
				canvas.blend_rect(r_wheel_scaled, Rect2i(0, 0, r_wheel_scaled.get_width(), r_wheel_scaled.get_height()), r_wheel_pos)
			# 2. Front wheel (behind)
			if f_wheel_scaled:
				canvas.blend_rect(f_wheel_scaled, Rect2i(0, 0, f_wheel_scaled.get_width(), f_wheel_scaled.get_height()), f_wheel_pos)
			# 3. Bike body (on top of both wheels)
			if body_img:
				canvas.blend_rect(body_img, Rect2i(0, 0, body_img.get_width(), body_img.get_height()), body_pos)
		else:
			# Wheels behind body (through arches)
			if r_wheel_scaled:
				canvas.blend_rect(r_wheel_scaled, Rect2i(0, 0, r_wheel_scaled.get_width(), r_wheel_scaled.get_height()), r_wheel_pos)
			if f_wheel_scaled:
				canvas.blend_rect(f_wheel_scaled, Rect2i(0, 0, f_wheel_scaled.get_width(), f_wheel_scaled.get_height()), f_wheel_pos)
			if body_img:
				canvas.blend_rect(body_img, Rect2i(0, 0, body_img.get_width(), body_img.get_height()), body_pos)
				
		var os_path = ProjectSettings.globalize_path(preview_path)
		var err = canvas.save_png(os_path)
		print("Saved %s -> %s (%dx%d, err=%d)" % [v_id, preview_path, canvas_w, canvas_h, err])
		
	print("[GENERATE] All preview images generated successfully.")
	quit()
