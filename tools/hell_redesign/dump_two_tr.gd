@tool
extends SceneTree

func _init() -> void:
	var hud_tr := Image.load_from_file("res://references/hud_top_right.png")
	var marked_tr := Image.load_from_file("res://references/marked_right_crop.png")
	hud_tr.convert(Image.FORMAT_RGBA8)
	marked_tr.convert(Image.FORMAT_RGBA8)

	print("=== HUD TOP RIGHT (y=10..70) ===")
	_dump(hud_tr)

	print("\n=== MARKED RIGHT CROP (y=80..150) ===")
	_dump(marked_tr)

	quit(0)

func _dump(img: Image) -> void:
	for y in range(0, img.get_height(), 3):
		var line := ""
		for x in range(0, img.get_width(), 3):
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2:
				line += "@" # blue pen
			elif c.r > 0.7 and c.g > 0.5 and c.b < 0.3:
				line += "$" # gold
			elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
				line += "#" # dark
			elif c.r > 0.25 and c.g < 0.25 and c.b < 0.25:
				line += "%" # crimson sky
			elif c.r > 0.6 and c.g > 0.2 and c.b < 0.2:
				line += "!" # orange/fire
			else:
				line += "."
		print(line)
