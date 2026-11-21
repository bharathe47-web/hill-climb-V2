extends SceneTree

func _init() -> void:
	var path := "res://quarantine/old_hell_assets_20261120/terrain/broken_basalt_platform_hazard.png"
	var img := Image.load_from_file(path)
	if not img:
		printerr("Cannot load ", path)
		quit(1)
		return
	print("broken_basalt_platform_hazard size: ", img.get_size())
	
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
				line += "*"
			elif c.r < 0.3 and c.g < 0.3 and c.b < 0.3:
				line += "#"
			else:
				line += "."
		print(line)
	quit(0)
