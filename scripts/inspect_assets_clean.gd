extends SceneTree

func _init() -> void:
	print("=== SUPPLIED ASSET INSPECTION ===")
	var paths = [
		"/home/joel/Downloads/Pasted image.png",
		"/home/joel/Downloads/meenakshi_tower_source_2.jpg.jpeg",
		"/home/joel/Pictures/Screenshots/Screenshot From 2026-11-23 13-57-09.png",
		"/home/joel/Pictures/Screenshots/Screenshot From 2026-11-23 13-57-51.png"
	]
	for p in paths:
		if not FileAccess.file_exists(p):
			print("File does NOT exist: ", p)
			continue
		var img = Image.load_from_file(p)
		if img == null:
			print("Failed to load: ", p)
			continue
		print("\nFile: ", p)
		print("  Size: ", img.get_size(), " Format: ", img.get_format())
		# check bounds of non-transparent pixels
		var w = img.get_width()
		var h = img.get_height()
		var min_x = w
		var min_y = h
		var max_x = 0
		var max_y = 0
		var has_transparency = false
		for y in range(0, h, 4):
			for x in range(0, w, 4):
				var col = img.get_pixel(x, y)
				if col.a < 0.99:
					has_transparency = true
				if col.a > 0.05:
					if x < min_x: min_x = x
					if y < min_y: min_y = y
					if x > max_x: max_x = x
					if y > max_y: max_y = y
		print("  Has transparency: ", has_transparency)
		print("  Visible Bounding Box: (", min_x, ", ", min_y, ") to (", max_x, ", ", max_y, ")")
		print("  Content Dimensions: ", (max_x - min_x), "x", (max_y - min_y))
	quit()
