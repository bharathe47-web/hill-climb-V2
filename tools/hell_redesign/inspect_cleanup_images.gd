@tool
extends SceneTree

func _init() -> void:
	print("--- INSPECTING ANNOTATED SCREENSHOTS ---")
	_inspect_image("res://references/hell_cleanup_569m.png")
	_inspect_image("res://references/hell_cleanup_600m.png")
	quit(0)

func _inspect_image(path: String) -> void:
	var img := Image.load_from_file(path)
	if not img:
		printerr("Cannot load: ", path)
		return
	print("\nFile: ", path.get_file(), " Size: %dx%d" % [img.get_width(), img.get_height()])

	# Find bright blue pixels (user annotations)
	# User mentioned: "The blue markings identify unwanted objects."
	# Blue annotation pixels typically have: high blue (b > 0.7), lower red (r < 0.3 or r < b*0.5)
	var blue_pixels: Array[Vector2i] = []
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			# Look for saturated blue (e.g. #0000FF, #00A2E8, #3F48CC, #00C0FF, cyan/blue pen)
			if c.b > 0.65 and c.b > c.r + 0.3 and c.b > c.g:
				blue_pixels.append(Vector2i(x, y))

	print("Found %d blue annotation pixels." % blue_pixels.size())

	if blue_pixels.size() > 0:
		# Group blue pixels into bounding boxes
		# Let's find clusters of blue markings
		var min_x := img.get_width()
		var max_x := 0
		var min_y := img.get_height()
		var max_y := 0
		for p in blue_pixels:
			min_x = mini(min_x, p.x)
			max_x = maxi(max_x, p.x)
			min_y = mini(min_y, p.y)
			max_y = maxi(max_y, p.y)
		print("Overall blue bounding box: x=[%d..%d], y=[%d..%d]" % [min_x, max_x, min_y, max_y])
