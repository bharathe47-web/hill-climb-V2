@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 15-38-29.png")
	img.convert(Image.FORMAT_RGBA8)

	print("Sampling column x=1180 from y=0 to y=200:")
	for y in range(0, 200, 2):
		var c := img.get_pixel(1180, y)
		var hex := "%02x%02x%02x" % [int(c.r*255), int(c.g*255), int(c.b*255)]
		var type := "other"
		if c.b > 0.5 and (c.b - c.r) > 0.2:
			type = "BLUE_PEN"
		elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
			type = "DARK"
		elif c.r > 0.3 and c.g < 0.2 and c.b < 0.2:
			type = "CRIMSON_SKY"
		elif c.r > 0.7 and c.g > 0.5 and c.b < 0.3:
			type = "GOLD"
		print("y=%3d: #%s (%s)" % [y, hex, type])

	quit(0)
