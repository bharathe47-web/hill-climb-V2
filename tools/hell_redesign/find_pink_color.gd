@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_pink.png"
	var img := Image.load_from_file(path)
	if not img:
		quit(1)
		return

	# Sample pixels across the image to find any annotation lines
	# Let's count pixels with unusual color combinations
	print("Inspecting colors in ", path.get_file())
	var unusual_pixels := []
	for y in range(0, img.get_height(), 2):
		for x in range(0, img.get_width(), 2):
			var c := img.get_pixel(x, y)
			# Look for pink, purple, violet, magenta, red-violet
			# E.g. c.r > 0.5 and c.b > 0.4, or c.r > c.g + 0.3
			# Or any saturated color where r and b are prominent
			if c.r > 0.5 and c.b > 0.3 and c.g < 0.6:
				# Check if it's magenta/pink (r > 0.6, b > 0.4, g < r*0.6)
				if c.b > c.g + 0.15:
					unusual_pixels.append(Vector3(c.r, c.g, c.b))

	print("Total unusual candidate pixels (downsampled 2x): ", unusual_pixels.size())
	if unusual_pixels.size() > 0:
		for i in range(mini(10, unusual_pixels.size())):
			print("  sample: ", unusual_pixels[i])

	# Let's check max red, max green, max blue
	# Also let's check what screenshot files exist in Pictures/Screenshots
	quit(0)
