@tool
extends SceneTree

func _init() -> void:
	var crops := [
		{"name": "Centre-Left", "path": "res://references/crop_centre_left.png"},
		{"name": "Middle-Right", "path": "res://references/crop_middle_right.png"},
		{"name": "Far-Right", "path": "res://references/crop_far_right.png"}
	]

	for c in crops:
		print("\n==========================================")
		print("OBSTACLE IN: %s" % c.name)
		print("==========================================")
		var img := Image.load_from_file(c.path)
		img.convert(Image.FORMAT_RGBA8)
		var w := img.get_width()
		var h := img.get_height()
		# sample at 8x12
		var step_x := 6
		var step_y := 10
		for y in range(0, h, step_y):
			var line := ""
			for x in range(0, w, step_x):
				var p := img.get_pixel(x, y)
				# Check if white stroke
				if p.r > 0.85 and p.g > 0.85 and p.b > 0.85:
					line += "@"
				# Check if orange/red dot: r > 0.7, g > 0.2, b < 0.2
				elif p.r > 0.6 and p.g > 0.2 and p.b < 0.2:
					line += "*"
				# Check if dark black/grey rock:
				elif p.r < 0.2 and p.g < 0.2 and p.b < 0.2:
					line += "#"
				else:
					line += " "
			if line.strip_edges() != "":
				print(line)

	quit(0)
