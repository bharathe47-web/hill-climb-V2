extends SceneTree

func _init() -> void:
	var path := "res://assets/environments/hell/terrain/hell_basalt_column.png"
	var img := Image.load_from_file(path)
	if not img:
		printerr("Cannot load ", path)
		quit(1)
		return
	print("hell_basalt_column size: ", img.get_size())
	# Render 40x30 ascii
	var tw := 40
	var th := 30
	var sm := img.duplicate()
	sm.resize(tw, th)
	for y in range(th):
		var line := ""
		for x in range(tw):
			var c: Color = sm.get_pixel(x, y)
			if c.a < 0.1:
				line += " "
			elif c.r > 0.6 and c.g > 0.6 and c.b > 0.6:
				line += "#"
			elif c.r > 0.3 or c.g > 0.3 or c.b > 0.3:
				line += "+"
			else:
				line += "."
		print(line)
	quit(0)
