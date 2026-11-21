@tool
extends SceneTree

func _init() -> void:
	var crops = [
		{"name": "RIGHT STRIP (Cluster 0)", "path": "res://references/blue_strip_crop_0.png"},
		{"name": "LEFT STRIP (Cluster 2)", "path": "res://references/blue_strip_crop_2.png"}
	]

	for item in crops:
		print("\n==========================================")
		print(item.name)
		print("==========================================")
		var img := Image.load_from_file(item.path)
		if not img: continue
		img.convert(Image.FORMAT_RGBA8)
		var w := img.get_width()
		var h := img.get_height()
		print("Size: %dx%d" % [w, h])
		var step_x := maxi(1, w / 60)
		var step_y := maxi(1, h / 25)
		for y in range(0, h, step_y):
			var line := ""
			for x in range(0, w, step_x):
				var p := img.get_pixel(x, y)
				# Check if blue pen: b > 0.6 and (b - r) > 0.3
				if p.b > 0.55 and (p.b - p.r) > 0.25:
					line += "@"
				elif p.r > 0.6 and p.g > 0.3 and p.b < 0.2:
					line += "*" # orange/fire
				elif p.r < 0.2 and p.g < 0.2 and p.b < 0.2:
					line += "#" # dark
				elif p.r > 0.3 and p.r < 0.6 and p.g < 0.2 and p.b < 0.2:
					line += "%" # dark crimson
				else:
					line += "."
			if line.strip_edges() != "":
				print(line)

	quit(0)
