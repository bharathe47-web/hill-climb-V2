@tool
extends SceneTree

func _init() -> void:
	var crops := [
		{"name": "RIGHT STRIP", "path": "res://references/marked_strip_right.png"},
		{"name": "LEFT STRIP", "path": "res://references/marked_strip_left_top.png"}
	]

	for c in crops:
		print("\n==========================================")
		print(c.name)
		print("==========================================")
		var img := Image.load_from_file(c.path)
		img.convert(Image.FORMAT_RGBA8)
		var w := img.get_width()
		var h := img.get_height()
		var step_x := 4
		var step_y := 4
		for y in range(0, h, step_y):
			var line := ""
			for x in range(0, w, step_x):
				var p := img.get_pixel(x, y)
				# Check if blue pen
				if p.b > 0.5 and (p.b - p.r) > 0.2 and (p.b - p.g) > 0.1:
					line += "@"
				elif p.r > 0.7 and p.g > 0.4 and p.b < 0.2:
					line += "*" # bright orange
				elif p.r < 0.15 and p.g < 0.15 and p.b < 0.15:
					line += "#" # black/dark
				elif p.r > 0.4 and p.g < 0.2 and p.b < 0.2:
					line += "%" # crimson sky
				else:
					line += "."
			if line.strip_edges() != "":
				print(line)

	quit(0)
