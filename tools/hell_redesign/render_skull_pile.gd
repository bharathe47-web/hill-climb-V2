extends SceneTree

func _init() -> void:
	var path := "res://assets/environments/hell/decorations/catacomb_skull_pile_decal.png"
	var img := Image.load_from_file(path)
	print("catacomb_skull_pile_decal size: ", img.get_size())
	
	var tw := 40
	var th := 25
	var sm := img.duplicate()
	sm.resize(tw, th)
	for y in range(th):
		var line := ""
		for x in range(tw):
			var c: Color = sm.get_pixel(x, y)
			if c.a < 0.1:
				line += " "
			elif c.r > 0.6 and c.g > 0.6 and c.b > 0.6:
				line += "W"
			elif c.r > 0.3:
				line += "#"
			else:
				line += "."
		print(line)
	quit(0)
