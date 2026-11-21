extends SceneTree

func _init() -> void:
	var bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]
	for b in bikes:
		var img_path = "assets/vehicles/garage/%s/body.png" % b
		var img = Image.load_from_file(img_path)
		var w = img.get_width()
		var h = img.get_height()
		print("========================================")
		print("BIKE: %s (%dx%d)" % [b, w, h])
		
		# Let's find the non-transparent bounding box in the right half (front fork)
		# and left half (rear axle)
		var min_x = w
		var max_x = 0
		var min_y = h
		var max_y = 0
		for y in range(h):
			for x in range(w):
				if img.get_pixel(x, y).a > 0.05:
					if x < min_x: min_x = x
					if x > max_x: max_x = x
					if y < min_y: min_y = y
					if y > max_y: max_y = y
		print("Overall bbox: x [%d, %d], y [%d, %d]" % [min_x, max_x, min_y, max_y])
		
		# Let's find bottom-most / right-most points in the front fork region (x > w * 0.6, y > h * 0.5)
		# Fork usually slants down and forward, ending at the fork tip / axle dropout
		var fork_pts = []
		for y in range(int(h * 0.4), h):
			for x in range(int(w * 0.55), w):
				if img.get_pixel(x, y).a > 0.1:
					fork_pts.append(Vector2(x, y))
		
		# Rear axle / swingarm region (x < w * 0.4, y > h * 0.5)
		var rear_pts = []
		for y in range(int(h * 0.4), h):
			for x in range(0, int(w * 0.45)):
				if img.get_pixel(x, y).a > 0.1:
					rear_pts.append(Vector2(x, y))
		
		print("Fork pixels count: %d, Rear pixels count: %d" % [fork_pts.size(), rear_pts.size()])
	quit(0)
