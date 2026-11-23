@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/strip_slice_y90_150.png")
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Strip slice: %dx%d" % [w, h])

	# For each x column, check if there is a dark rectangular block or sky
	# Sky is crimson (r > 0.3, g < 0.2, b < 0.2)
	# Non-sky could be mountain, fortress, blue pen, or the strips!
	# Let's print ASCII representation of the 60 rows across the 1366 columns, subsampled by 8 horizontally and 2 vertically
	for y in range(0, h, 3):
		var line := ""
		for x in range(0, w, 12):
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2:
				line += "@" # blue pen
			elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
				line += "#" # black/dark
			elif c.r > 0.6 and c.g > 0.5 and c.b < 0.2:
				line += "$" # gold
			elif c.r > 0.25 and c.g < 0.25 and c.b < 0.25:
				line += "%" # crimson sky
			elif c.r > 0.6 and c.g > 0.2 and c.b < 0.2:
				line += "!" # orange/fire
			else:
				line += "."
		print("y=%2d: %s" % [y + 90, line])

	quit(0)
