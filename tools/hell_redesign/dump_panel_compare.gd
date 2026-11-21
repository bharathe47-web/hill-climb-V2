@tool
extends SceneTree

func _init() -> void:
	var p1 := Image.load_from_file("res://references/panel_upper.png")
	var p2 := Image.load_from_file("res://references/panel_lower.png")
	p1.convert(Image.FORMAT_RGBA8)
	p2.convert(Image.FORMAT_RGBA8)

	print("=== UPPER PANEL (y=15..75) ===")
	_dump(p1)

	print("\n=== LOWER PANEL (y=86..146) ===")
	_dump(p2)

	quit(0)

func _dump(img: Image) -> void:
	for y in range(0, img.get_height(), 3):
		var line := ""
		for x in range(0, img.get_width(), 3):
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2:
				line += "@"
			elif c.r > 0.7 and c.g > 0.5 and c.b < 0.3:
				line += "$"
			elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
				line += "#"
			elif c.r > 0.25 and c.g < 0.25 and c.b < 0.25:
				line += "%"
			else:
				line += "."
		print(line)
