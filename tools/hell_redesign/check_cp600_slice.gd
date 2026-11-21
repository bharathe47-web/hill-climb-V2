@tool
extends SceneTree

func _init() -> void:
	var cp_600 := Image.load_from_file("res://docs/hell_redesign/qa_screenshots/hell_checkpoint_600m.png")
	cp_600.convert(Image.FORMAT_RGBA8)
	var w := cp_600.get_width()
	var h := cp_600.get_height()
	print("CP600 size: %dx%d" % [w, h])

	# Let's inspect rows 80 to 140 across the entire 1280 width of CP600
	for y in range(80, 140, 5):
		var line := ""
		for x in range(0, w, 12):
			var c := cp_600.get_pixel(x, y)
			if c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
				line += "#"
			elif c.r > 0.6 and c.g > 0.5 and c.b < 0.2:
				line += "$"
			elif c.r > 0.3 and c.g < 0.25 and c.b < 0.25:
				line += "%"
			else:
				line += "."
		print("y=%2d: %s" % [y, line])

	quit(0)
