extends SceneTree

func _init() -> void:
	print("=== DETAILED INSPECTION OF USER SCREENSHOTS ===")
	var paths = [
		"/home/joel/Pictures/Screenshots/Screenshot From 2026-11-23 13-57-09.png",
		"/home/joel/Pictures/Screenshots/Screenshot From 2026-11-23 13-57-51.png"
	]
	for p in paths:
		var img = Image.load_from_file(p)
		if img == null:
			continue
		print("\n--- ", p.get_file(), " ---")
		print("Size: ", img.get_size())
		# Check top banner/HUD (y=20 to 100)
		# Check middle area (y=250 to 500)
		# Check road/ground (y=500 to 700)
		# Let's sample colors across the middle to see what structures exist
		# Specifically let's search for green/blue/yellow/white structures
		var col_histogram = {}
		for y in range(0, img.get_height(), 16):
			for x in range(0, img.get_width(), 16):
				var c = img.get_pixel(x, y)
				var key = "R%.1f_G%.1f_B%.1f" % [round(c.r*5.0)/5.0, round(c.g*5.0)/5.0, round(c.b*5.0)/5.0]
				col_histogram[key] = col_histogram.get(key, 0) + 1
		print("Color distribution sample:")
		var keys = col_histogram.keys()
		# sort by count
		keys.sort_custom(func(a, b): return col_histogram[a] > col_histogram[b])
		for i in range(min(5, keys.size())):
			print("  ", keys[i], ": ", col_histogram[keys[i]])
	quit()
