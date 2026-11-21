extends SceneTree

func _init() -> void:
	var path := "res://assets/environments/hell/terrain/magma_vent_fissure_prop.png"
	var img := Image.load_from_file(path)
	if not img:
		printerr("Cannot load ", path)
		quit(1)
		return
	print("magma_vent_fissure_prop size: ", img.get_size())
	
	# Render 40x20 ascii
	var tw := 40
	var th := 20
	var sm := img.duplicate()
	sm.resize(tw, th)
	for y in range(th):
		var line := ""
		for x in range(tw):
			var c: Color = sm.get_pixel(x, y)
			if c.a < 0.1:
				line += " "
			elif c.r > 0.8 and c.g > 0.4 and c.b < 0.3:
				line += "*" # Orange/yellow dots!
			elif c.r < 0.3 and c.g < 0.3 and c.b < 0.3:
				line += "#" # Dark/black rock
			else:
				line += "."
		print(line)
	quit(0)
