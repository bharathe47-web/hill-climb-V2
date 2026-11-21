extends SceneTree

func _init() -> void:
	var bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]
	for b in bikes:
		var img_path = "assets/vehicles/garage/%s/body.png" % b
		var img = Image.load_from_file(img_path)
		var w = img.get_width()
		var h = img.get_height()
		
		# Let's inspect where the current front wheel offset points on this image!
		# Current config in VehicleRegistry:
		# e.g. for car_14: fw_off = Vector2(245.0, 138.5) -> in image coords: pivot + fw_off = (398+245, 211+138.5) = (643, 349.5)
		# Let's find what is around that point in the image!
		print("\n--- %s (w=%d, h=%d) ---" % [b, w, h])
		
		# Let's check from x = w * 0.5 to w, what is the fork tip:
		# Specifically, what is the bottom-most point of the fork?
		# Or the lowest Y in the front region x in [w*0.6, w]
		var lowest_fork_y = 0
		var lowest_fork_x = 0
		for y in range(h - 1, int(h * 0.5), -1):
			for x in range(w - 1, int(w * 0.55), -1):
				if img.get_pixel(x, y).a > 0.3:
					if y > lowest_fork_y:
						lowest_fork_y = y
						lowest_fork_x = x
		print("Lowest front fork pixel: x=%d, y=%d" % [lowest_fork_x, lowest_fork_y])
		
		var lowest_rear_y = 0
		var lowest_rear_x = 0
		for y in range(h - 1, int(h * 0.5), -1):
			for x in range(0, int(w * 0.45)):
				if img.get_pixel(x, y).a > 0.3:
					if y > lowest_rear_y:
						lowest_rear_y = y
						lowest_rear_x = x
		print("Lowest rear pixel: x=%d, y=%d" % [lowest_rear_x, lowest_rear_y])
	quit(0)
