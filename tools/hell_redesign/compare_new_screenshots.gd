extends SceneTree

func _init() -> void:
	var img1 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png")
	var img2 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-47.png")
	
	print("Comparing 13-37-08 with 13-37-47:")
	var diff_pixels := 0
	var diff_img := Image.create(img1.get_width(), img1.get_height(), false, Image.FORMAT_RGBA8)
	
	for y in range(img1.get_height()):
		for x in range(img1.get_width()):
			var c1 := img1.get_pixel(x, y)
			var c2 := img2.get_pixel(x, y)
			if abs(c1.r - c2.r) > 0.05 or abs(c1.g - c2.g) > 0.05 or abs(c1.b - c2.b) > 0.05:
				diff_pixels += 1
				diff_img.set_pixel(x, y, Color(1, 0, 0, 1))
			else:
				diff_img.set_pixel(x, y, Color(0, 0, 0, 0))
				
	print("Diff pixels: ", diff_pixels)
	diff_img.save_png("res://references/cyan_annotation_diff.png")
	
	# Find bounds of differences (which will be the newly drawn annotations!)
	var min_x := 9999
	var max_x := -1
	var min_y := 9999
	var max_y := -1
	for y in range(img1.get_height()):
		for x in range(img1.get_width()):
			if diff_img.get_pixel(x, y).a > 0.5:
				min_x = min(min_x, x)
				max_x = max(max_x, x)
				min_y = min(min_y, y)
				max_y = max(max_y, y)
	print("Annotation diff bounds: X=[%d, %d], Y=[%d, %d]" % [min_x, max_x, min_y, max_y])
	quit(0)
