extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	if not img:
		quit(1)
		return
	print("Scanning for white pixels (R>0.8, G>0.8, B>0.8) in upper half:")
	var min_x := 9999
	var max_x := -1
	var min_y := 9999
	var max_y := -1
	for y in range(0, 150):
		for x in range(0, img.get_width()):
			var c := img.get_pixel(x, y)
			if c.r > 0.85 and c.g > 0.85 and c.b > 0.85:
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)
	print("White text bounds: X=[%d, %d], Y=[%d, %d]" % [min_x, max_x, min_y, max_y])
	
	# Let's render ascii art of this text region!
	for y in range(min_y, max_y + 1, 2):
		var line := ""
		for x in range(min_x, max_x + 1, 2):
			var c := img.get_pixel(x, y)
			if c.r > 0.8 and c.g > 0.8 and c.b > 0.8:
				line += "#"
			else:
				line += " "
		print(line)
	quit(0)
