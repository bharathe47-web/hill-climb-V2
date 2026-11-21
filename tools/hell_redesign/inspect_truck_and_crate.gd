extends SceneTree

func _init() -> void:
	var path := "/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png"
	var img := Image.load_from_file(path)
	if not img:
		printerr("Cannot load ", path)
		quit(1)
		return
	print("Loaded unannotated screenshot 13-37-08.png: ", img.get_size())
	
	# Let's crop:
	# Monster truck is roughly at x=200..450, y=350..550
	# Let's render detailed ASCII of x=150..550, y=350..550:
	var x_start := 180
	var x_end := 540
	var y_start := 360
	var y_end := 540
	var step_x := 4
	var step_y := 6
	
	print("\n--- MONSTER TRUCK & BEHIND/RIGHT (x=%d..%d, y=%d..%d) ---" % [x_start, x_end, y_start, y_end])
	for y in range(y_start, y_end, step_y):
		var line := ""
		for x in range(x_start, x_end, step_x):
			var c: Color = img.get_pixel(x, y)
			# Character based on luminance and color
			if c.r > 0.8 and c.g > 0.8 and c.b > 0.8:
				line += "W" # white/bright
			elif c.r > 0.7 and c.g > 0.5 and c.b < 0.3:
				line += "Y" # yellow/gold
			elif c.r > 0.6 and c.g < 0.3 and c.b < 0.3:
				line += "R" # red
			elif c.r > 0.4 and c.g > 0.25 and c.b < 0.2:
				line += "B" # brown / orange
			elif c.r < 0.2 and c.g < 0.2 and c.b < 0.2:
				line += "." # dark / black
			else:
				line += " "
		print(line)
		
	# Save a PNG crop of this area
	var crop := img.get_region(Rect2i(x_start, y_start, x_end - x_start, y_end - y_start))
	crop.save_png("res://references/truck_and_crate_crop.png")
	print("Saved res://references/truck_and_crate_crop.png")
	quit(0)
