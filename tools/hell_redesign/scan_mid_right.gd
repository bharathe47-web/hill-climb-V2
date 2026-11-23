@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 15-38-29.png")
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# Inspect y=300 to y=550 across x=700 to x=1300
	print("Scanning middle-right region (x=700..1300, y=300..550):")
	for y in range(300, 550, 10):
		var line := ""
		for x in range(700, 1300, 12):
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2:
				line += "@" # blue pen
			elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
				line += "#"
			elif c.r > 0.7 and c.g > 0.5 and c.b < 0.3:
				line += "$"
			elif c.r > 0.3 and c.g < 0.2 and c.b < 0.2:
				line += "%"
			elif c.r > 0.6 and c.g > 0.2 and c.b < 0.2:
				line += "!"
			else:
				line += "."
		print("y=%3d: %s" % [y, line])

	quit(0)
