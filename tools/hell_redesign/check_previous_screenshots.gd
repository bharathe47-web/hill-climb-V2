@tool
extends SceneTree

func _init() -> void:
	var img_1443 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-43-03.png")
	var img_1538 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 15-38-29.png")
	img_1443.convert(Image.FORMAT_RGBA8)
	img_1538.convert(Image.FORMAT_RGBA8)

	# Read HUD distance in 1538
	# Distance label in 1366x768 is at center top: x=580..680, y=10..30
	print("--- HUD DISTANCE IN 15-38-29 ---")
	for y in range(12, 28):
		var line := ""
		for x in range(570, 700, 2):
			var c := img_1538.get_pixel(x, y)
			if c.r > 0.7 and c.g > 0.7 and c.b > 0.7:
				line += "#"
			else:
				line += " "
		if line.strip_edges() != "":
			print("%2d: %s" % [y, line])

	print("--- HUD DISTANCE IN 14-43-03 ---")
	for y in range(12, 28):
		var line := ""
		for x in range(570, 700, 2):
			var c := img_1443.get_pixel(x, y)
			if c.r > 0.7 and c.g > 0.7 and c.b > 0.7:
				line += "#"
			else:
				line += " "
		if line.strip_edges() != "":
			print("%2d: %s" % [y, line])

	# Check right region in 1443
	print("\n--- RIGHT REGION IN 14-43-03 ---")
	for y in range(95, 140, 4):
		var line := ""
		for x in range(1090, 1300, 6):
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

	# Check right region in 1538 without blue pen
	print("\n--- RIGHT REGION IN 15-38-29 ---")
	for y in range(95, 140, 4):
		var line := ""
		for x in range(1090, 1300, 6):
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
