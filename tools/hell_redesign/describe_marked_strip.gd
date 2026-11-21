@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/marked_strip_right.png")
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Right strip crop size: %dx%d" % [w, h])

	# Let's inspect rows around the blue box:
	# Where are the blue pixels?
	var blue_min_y := 999; var blue_max_y := -1
	var blue_min_x := 999; var blue_max_x := -1
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2 and (c.b - c.g) > 0.1:
				blue_min_y = mini(blue_min_y, y)
				blue_max_y = maxi(blue_max_y, y)
				blue_min_x = mini(blue_min_x, x)
				blue_max_x = maxi(blue_max_x, x)

	print("Blue box in crop: x=[%d..%d], y=[%d..%d]" % [blue_min_x, blue_max_x, blue_min_y, blue_max_y])

	# Now let's inspect the pixels INSIDE that blue box:
	# From x = blue_min_x + 5 to blue_max_x - 5, y = blue_min_y + 5 to blue_max_y - 5
	var inner := img.get_region(Rect2i(blue_min_x + 5, blue_min_y + 5, (blue_max_x - blue_min_x) - 10, (blue_max_y - blue_min_y) - 10))
	inner.save_png("res://references/exact_strip_right_content.png")
	print("Saved exact_strip_right_content.png (%dx%d)" % [inner.get_width(), inner.get_height()])

	# Let's print the colors across this strip
	print("Colors inside right strip:")
	for y in range(0, inner.get_height(), 3):
		var row_str := ""
		for x in range(0, inner.get_width(), 4):
			var p := inner.get_pixel(x, y)
			# print hex or character
			if p.a < 0.1:
				row_str += " "
			else:
				row_str += "%02x%02x%02x " % [int(p.r*255), int(p.g*255), int(p.b*255)]
		print("y=%2d: %s" % [y, row_str])

	quit(0)
