@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_target.png")
	var w := img.get_width()
	var h := img.get_height()
	print("Target image: %dx%d" % [w, h])

	# Let's find any unique objects or shapes on the road:
	# Scan row by row around y=300..450 to see color variation
	var has_unique_colors := false
	for y in range(300, 450, 10):
		var colors := []
		for x in range(0, w, 20):
			var c := img.get_pixel(x, y)
			# Look for vehicle colors like blue, yellow, green, bright metallics
			if (c.b > 0.4 and c.b > c.r) or (c.g > 0.5 and c.b > 0.4):
				print("Found unusual color at (%d, %d): R=%.2f G=%.2f B=%.2f" % [x, y, c.r, c.g, c.b])
				has_unique_colors = true
	if not has_unique_colors:
		print("No vehicle-like colors (cyan, blue, green) found on the road!")

	quit(0)
