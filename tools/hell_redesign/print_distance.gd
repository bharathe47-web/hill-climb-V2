extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	for y in range(10, 50):
		var line := ""
		for x in range(600, 750):
			var c := img.get_pixel(x, y)
			line += "#" if c.r > 0.8 and c.g > 0.8 and c.b > 0.8 else " "
		if line.strip_edges() != "":
			print(line)
	quit(0)
