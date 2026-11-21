extends SceneTree

func _init() -> void:
	var path := "/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-47.png"
	var img := Image.load_from_file(path)
	print("--- Scanning text row 8..35, x=500..850 ---")
	for y in range(8, 30):
		var line := ""
		for x in range(500, 850, 2):
			var c := img.get_pixel(x, y)
			line += "#" if (c.r > 0.8 and c.g > 0.8 and c.b > 0.8) else " "
		if line.strip_edges() != "":
			print(line)
	quit(0)
