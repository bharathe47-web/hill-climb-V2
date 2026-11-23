@tool
extends SceneTree

func _init() -> void:
	var cp_crop := Image.load_from_file("res://references/cp600_strip_region.png")
	var usr_crop := Image.load_from_file("res://references/user_strip_region.png")
	cp_crop.convert(Image.FORMAT_RGBA8)
	usr_crop.convert(Image.FORMAT_RGBA8)

	print("--- CP600 CROP (1000..1240, 70..150) ---")
	_dump_ascii(cp_crop)

	print("\n--- USER CROP (1080..1320, 80..160) ---")
	_dump_ascii(usr_crop)

	quit(0)

func _dump_ascii(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for y in range(0, h, 4):
		var line := ""
		for x in range(0, w, 4):
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2:
				line += "@" # blue pen
			elif c.r > 0.7 and c.g > 0.5 and c.b < 0.3:
				line += "$" # gold/yellow
			elif c.r < 0.2 and c.g < 0.2 and c.b < 0.2:
				line += "#" # dark
			elif c.r > 0.3 and c.g < 0.2 and c.b < 0.2:
				line += "%" # crimson sky
			elif c.r > 0.6 and c.g > 0.2 and c.b < 0.2:
				line += "!" # orange/fire
			else:
				line += "."
		print(line)
