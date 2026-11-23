extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	if not img:
		printerr("Cannot load hell_cleanup_pink.png")
		quit(1)
		return
	
	print("Image size: ", img.get_size())
	# Find pink pixels
	# Let's inspect colors with R > 0.7, G between 0.4 and 0.7, B between 0.4 and 0.7, and abs(G-B) < 0.15
	var pink_coords: Array[Vector2i] = []
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			# Pink annotation: high R, medium G and B, distinct from hell reds (which have very low G and B or high G for yellow lava)
			# Hell crimson is typically R=0.4..0.8, G=0.0..0.15, B=0.0..0.15.
			# Salmon pink pen is R ~ 0.85-0.98, G ~ 0.45-0.70, B ~ 0.45-0.70.
			if c.r > 0.75 and c.g > 0.4 and c.g < 0.75 and c.b > 0.4 and c.b < 0.75 and abs(c.g - c.b) < 0.12:
				pink_coords.append(Vector2i(x, y))
				
	print("Found %d pink annotation pixels" % pink_coords.size())
	
	if pink_coords.is_empty():
		# Let's sample pixels across the image to see what colors the annotation has
		print("Scanning image for highest G and B with R > 0.8...")
		for y in range(0, img.get_height(), 10):
			for x in range(0, img.get_width(), 10):
				var c := img.get_pixel(x, y)
				if c.r > 0.8 and c.g > 0.3 and c.b > 0.3:
					print("Sample at (%d, %d): R=%.2f, G=%.2f, B=%.2f" % [x, y, c.r, c.g, c.b])
		quit(0)
		return
		
	# Cluster pink pixels into bounding boxes
	# We can do a simple connected components or grid clustering
	var min_x := 999999
	var max_x := -1
	var min_y := 999999
	var max_y := -1
	for p in pink_coords:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)
	print("Overall pink bounds: X=[%d, %d], Y=[%d, %d]" % [min_x, max_x, min_y, max_y])
	
	# Split into 3 clusters based on X coordinate: Left, Center, Right
	var left_pixels: Array[Vector2i] = []
	var center_pixels: Array[Vector2i] = []
	var right_pixels: Array[Vector2i] = []
	
	for p in pink_coords:
		if p.x < 500:
			left_pixels.append(p)
		elif p.x > 800:
			right_pixels.append(p)
		else:
			center_pixels.append(p)
			
	print("Left pink count: %d" % left_pixels.size())
	print("Center pink count: %d" % center_pixels.size())
	print("Right pink count: %d" % right_pixels.size())
	
	for cluster_info in [["left", left_pixels], ["center", center_pixels], ["right", right_pixels]]:
		var name_str: String = cluster_info[0]
		var pixels: Array = cluster_info[1]
		if pixels.is_empty():
			continue
		var c_min_x := 999999
		var c_max_x := -1
		var c_min_y := 999999
		var c_max_y := -1
		for p in pixels:
			c_min_x = min(c_min_x, p.x)
			c_max_x = max(c_max_x, p.x)
			c_min_y = min(c_min_y, p.y)
			c_max_y = max(c_max_y, p.y)
		print("Cluster '%s' bounds: X=[%d, %d], Y=[%d, %d]" % [name_str, c_min_x, c_max_x, c_min_y, c_max_y])
		
		# Crop and save region
		var pad := 20
		var crop_x := clampi(c_min_x - pad, 0, img.get_width() - 1)
		var crop_y := clampi(c_min_y - pad, 0, img.get_height() - 1)
		var crop_w := clampi(c_max_x - c_min_x + 2 * pad, 1, img.get_width() - crop_x)
		var crop_h := clampi(c_max_y - c_min_y + 2 * pad, 1, img.get_height() - crop_y)
		var crop := img.get_region(Rect2i(crop_x, crop_y, crop_w, crop_h))
		crop.save_png("res://references/cluster_" + name_str + ".png")
		print("Saved references/cluster_" + name_str + ".png (" + str(crop_w) + "x" + str(crop_h) + ")")

	quit(0)
