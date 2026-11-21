extends SceneTree

func _init() -> void:
	var files: Array[String] = ["Screenshot From 2026-11-21 13-37-47.png", "Screenshot From 2026-11-21 13-37-08.png"]
	for fname in files:
		var path: String = "/home/daniel/Pictures/Screenshots/" + fname
		var img := Image.load_from_file(path)
		if not img:
			continue
		print("\n=== ", fname, " ===")
		print("Dimensions: ", img.get_size())
		
		# Read HUD distance text around x=600..750, y=10..30
		for y in range(8, 25):
			var line := ""
			for x in range(650, 770):
				var c := img.get_pixel(x, y)
				line += "#" if (c.r > 0.8 and c.g > 0.8 and c.b > 0.8) else " "
			if line.strip_edges() != "":
				print(line)
	quit(0)
