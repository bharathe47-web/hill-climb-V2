@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 15-38-29.png")
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Screenshot size: %dx%d" % [w, h])

	# Scale to 80 cols by 30 rows (step_x = 17, step_y = 25)
	var step_x := 17
	var step_y := 25
	for y in range(0, h, step_y):
		var line := ""
		for x in range(0, w, step_x):
			var has_blue := false
			var has_dark := false
			var has_crimson := false
			var has_orange := false
			for sy in range(y, mini(h, y + step_y)):
				for sx in range(x, mini(w, x + step_x)):
					var c := img.get_pixel(sx, sy)
					if c.b > 0.5 and (c.b - c.r) > 0.2 and (c.b - c.g) > 0.1:
						has_blue = true
					elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
						has_dark = true
					elif c.r > 0.3 and c.g < 0.2 and c.b < 0.2:
						has_crimson = true
					elif c.r > 0.6 and c.g > 0.3 and c.b < 0.2:
						has_orange = true

			if has_blue:
				line += "@"
			elif has_dark:
				line += "#"
			elif has_crimson:
				line += "%"
			elif has_orange:
				line += "!"
			else:
				line += "."
		print(line)

	quit(0)
