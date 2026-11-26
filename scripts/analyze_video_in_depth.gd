extends SceneTree

func _init() -> void:
	print("=== IN-DEPTH VIDEO AUDIT (0s - 114s) ===")
	# Let's inspect key intervals and measure:
	# 1. Car body position & bounding box
	# 2. Wheel positions relative to road surface
	# 3. Terrain height profile
	# 4. Visible landmark sprites & check if toll plaza appears
	# 5. Background texture appearance
	
	for t in range(1, 114, 2):
		var p = "/tmp/screencast_frames/frame_%03d.png" % t
		var img = Image.load_from_file(p)
		if img == null: continue
		var w = img.get_width()
		var h = img.get_height()
		
		# Detect car chassis: find red pixels cluster (r > 0.6, g < 0.35, b < 0.35)
		var car_pixels = []
		for y in range(200, 700, 4):
			for x in range(50, 700, 4):
				var c = img.get_pixel(x, y)
				if c.r > 0.55 and c.g < 0.32 and c.b < 0.32:
					car_pixels.append(Vector2(x, y))
		
		var car_box = Rect2()
		if car_pixels.size() > 5:
			var min_x = 9999.0
			var max_x = -9999.0
			var min_y = 9999.0
			var max_y = -9999.0
			for pt in car_pixels:
				if pt.x < min_x: min_x = pt.x
				if pt.x > max_x: max_x = pt.x
				if pt.y < min_y: min_y = pt.y
				if pt.y > max_y: max_y = pt.y
			car_box = Rect2(min_x, min_y, max_x - min_x, max_y - min_y)
		
		# Detect wheels below car chassis: wheels are dark circles (r < 0.25, g < 0.25, b < 0.25)
		# with bright rim or hubcap around y in [car_box.position.y + car_box.size.y - 10, car_box.position.y + car_box.size.y + 45]
		var wheel_contact_issue = "OK"
		var road_at_car = -1
		if car_box.size.x > 20:
			var car_cx = car_box.position.x + car_box.size.x * 0.5
			# Find road surface under car by scanning vertically around car bottom
			for y in range(int(car_box.position.y), min(760, int(car_box.position.y + 120)), 2):
				var c = img.get_pixel(int(car_cx), y)
				# Road surface boundary: asphalt is dark, then shoulder line or dirt
				if y > car_box.position.y + car_box.size.y * 0.8:
					# Check if there is significant brightness or color change indicating ground
					road_at_car = y
					break
			var car_bottom = car_box.position.y + car_box.size.y
			var gap = road_at_car - car_bottom
			if gap > 35:
				wheel_contact_issue = "AIRBORNE/FLOATING (gap=%d)" % gap
			elif gap < -5:
				wheel_contact_issue = "SINKING (penetration=%d)" % abs(gap)
		
		# Check for Toll Plaza roof/structure: Toll plaza has green banner / white pillars
		# Usually has yellow/black barrier or green overhead canopy
		var green_toll_canopy = 0
		for y in range(250, 450, 6):
			for x in range(300, 1100, 6):
				var c = img.get_pixel(x, y)
				# Toll plaza canopy green: r: 0.05-0.2, g: 0.35-0.6, b: 0.1-0.3
				if c.g > 0.38 and c.r < 0.22 and c.b < 0.25:
					green_toll_canopy += 1
		
		var toll_str = ""
		if green_toll_canopy > 150:
			toll_str = " [POSSIBLE TOLL CANOPY (%d px)]" % green_toll_canopy
			
		print("t=%03ds | Car: pos=(%.0f, %.0f) size=(%.0f, %.0f) | Contact: %s%s" % [
			t, car_box.position.x, car_box.position.y, car_box.size.x, car_box.size.y, wheel_contact_issue, toll_str
		])
	quit()
