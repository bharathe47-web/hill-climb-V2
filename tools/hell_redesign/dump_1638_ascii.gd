@tool
extends SceneTree

func _init() -> void:
	var b_img := Image.load_from_file("res://references/behind_truck_1638.png")
	var a_img := Image.load_from_file("res://references/ahead_right_1638.png")
	b_img.convert(Image.FORMAT_RGBA8)
	a_img.convert(Image.FORMAT_RGBA8)

	print("=== BEHIND TRUCK 16-38-45 ===")
	_dump(b_img)

	print("\n=== AHEAD ON RIGHT 16-38-45 ===")
	_dump(a_img)

	quit(0)

func _dump(img: Image) -> void:
	for y in range(0, img.get_height(), 4):
		var line := ""
		for x in range(0, img.get_width(), 4):
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2:
				line += "@"
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
		print(line)
