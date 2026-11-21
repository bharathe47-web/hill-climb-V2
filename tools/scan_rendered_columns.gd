@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/forensic_debug/gameplay_clean_512m.png")
	if not img:
		printerr("Could not load 512m image")
		quit(0)
		return

	# Let's inspect where columns actually appear in the 512m rendered screenshot!
	# The column has a gold base (around y=380..440) and white shaft
	print("Scanning gameplay_clean_512m.png for columns:")
	var found_cols = []
	for x in range(20, 1260, 10):
		# Sample column shaft at y = 260
		var c = img.get_pixel(x, 260)
		if c.r > 0.85 and c.g > 0.80 and c.b > 0.70 and c.r > c.b + 0.04:
			# Look for base
			for y in range(350, 480, 2):
				var cb = img.get_pixel(x, y)
				# Gold base
				if cb.r > 0.75 and cb.g > 0.55 and cb.b < 0.45:
					found_cols.append(Vector2i(x, y))
					break

	print("Found column signatures in 512m: ", found_cols)
	quit(0)
