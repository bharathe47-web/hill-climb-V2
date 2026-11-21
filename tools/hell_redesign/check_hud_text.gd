extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/pink_hud.png")
	if not img:
		quit(1)
		return
	print("HUD size: ", img.get_size())
	# Find bright pixels (text is usually white)
	# Print ascii art of text area
	for y in range(20, 60, 2):
		var line := ""
		for x in range(30, 200, 2):
			var c := img.get_pixel(x, y)
			if c.r > 0.8 and c.g > 0.8 and c.b > 0.8:
				line += "#"
			else:
				line += " "
		if line.strip_edges() != "":
			print(line)
	quit(0)
