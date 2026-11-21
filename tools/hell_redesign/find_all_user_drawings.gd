extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_cyan_latest.png")
	var w := img.get_width()
	var h := img.get_height()
	print("Loaded image: %dx%d" % [w, h])
	
	# Let's check color histograms of pixels that are unnatural in a hell scene:
	# Hell scene is mostly red/dark orange/black.
	# Any saturated blue, cyan, magenta, bright green, or pure white strokes:
	var blue_pixels: Array[Vector2i] = []
	var cyan_pixels: Array[Vector2i] = []
	var green_pixels: Array[Vector2i] = []
	
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# Saturated blue/cyan:
			if c.b > 0.5 and (c.b - c.r) > 0.2:
				if c.g > 0.4:
					cyan_pixels.append(Vector2i(x, y))
				else:
					blue_pixels.append(Vector2i(x, y))
			elif c.g > 0.5 and (c.g - c.r) > 0.2 and (c.g - c.b) > 0.2:
				green_pixels.append(Vector2i(x, y))
				
	print("Cyan pixels (b>0.5, b-r>0.2, g>0.4): %d" % cyan_pixels.size())
	print("Blue pixels (b>0.5, b-r>0.2, g<=0.4): %d" % blue_pixels.size())
	print("Green pixels: %d" % green_pixels.size())
	
	# Let's inspect cyan_pixels spatial distribution:
	if cyan_pixels.size() > 0:
		var min_x := 9999
		var max_x := -1
		var min_y := 9999
		var max_y := -1
		for p in cyan_pixels:
			min_x = min(min_x, p.x)
			max_x = max(max_x, p.x)
			min_y = min(min_y, p.y)
			max_y = max(max_y, p.y)
		print("Cyan bounds: X=[%d, %d], Y=[%d, %d]" % [min_x, max_x, min_y, max_y])
		
	if blue_pixels.size() > 0:
		var min_x := 9999
		var max_x := -1
		var min_y := 9999
		var max_y := -1
		for p in blue_pixels:
			min_x = min(min_x, p.x)
			max_x = max(max_x, p.x)
			min_y = min(min_y, p.y)
			max_y = max(max_y, p.y)
		print("Blue bounds: X=[%d, %d], Y=[%d, %d]" % [min_x, max_x, min_y, max_y])
		
	quit(0)
