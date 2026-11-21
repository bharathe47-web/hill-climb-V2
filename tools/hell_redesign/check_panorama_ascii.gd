@tool
extends SceneTree

func _init() -> void:
	var path := "res://assets/environments/hell/background/sky/hell_sky_crimson_panorama.png"
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("hell_sky_crimson_panorama size: %dx%d" % [w, h])

	# Let's inspect rows 80 to 150 across the entire 1920 width
	for y in range(80, 150, 5):
		var line := ""
		for x in range(0, w, 16):
			var c := img.get_pixel(x, y)
			if c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
				line += "#" # dark
			elif c.r > 0.6 and c.g > 0.5 and c.b < 0.2:
				line += "$" # gold
			elif c.r > 0.25 and c.g < 0.25 and c.b < 0.25:
				line += "%" # crimson sky
			elif c.r > 0.6 and c.g > 0.2 and c.b < 0.2:
				line += "!" # orange/fire
			else:
				line += "."
		print("y=%3d: %s" % [y, line])

	quit(0)
