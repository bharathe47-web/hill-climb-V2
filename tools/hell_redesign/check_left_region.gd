@tool
extends SceneTree

func _init() -> void:
	var img_1443 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-43-03.png")
	var img_1538 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 15-38-29.png")
	img_1443.convert(Image.FORMAT_RGBA8)
	img_1538.convert(Image.FORMAT_RGBA8)

	print("--- LEFT REGION IN 14-43-03 (x=100..400, y=95..145) ---")
	for y in range(95, 140, 4):
		var line := ""
		for x in range(120, 360, 6):
			var c := img_1443.get_pixel(x, y)
			if c.r < 0.2 and c.g < 0.2 and c.b < 0.2:
				line += "#"
			elif c.r > 0.6 and c.g > 0.5 and c.b < 0.3:
				line += "$"
			elif c.r > 0.3 and c.g < 0.25 and c.b < 0.25:
				line += "%"
			else:
				line += "."
		print("%2d: %s" % [y, line])

	print("\n--- LEFT REGION IN 15-38-29 (x=100..400, y=95..145) ---")
	for y in range(95, 140, 4):
		var line := ""
		for x in range(120, 360, 6):
			var c := img_1538.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2:
				line += "@"
			elif c.r < 0.2 and c.g < 0.2 and c.b < 0.2:
				line += "#"
			elif c.r > 0.6 and c.g > 0.5 and c.b < 0.3:
				line += "$"
			elif c.r > 0.3 and c.g < 0.25 and c.b < 0.25:
				line += "%"
			else:
				line += "."
		print("%2d: %s" % [y, line])

	quit(0)
