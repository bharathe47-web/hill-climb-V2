extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/cluster2_clean.png")
	var w := img.get_width()
	var h := img.get_height()
	print("--- RENDER cluster2_clean.png (%dx%d) ---" % [w, h])
	
	for y in range(0, h, 4):
		var line := ""
		for x in range(0, w, 3):
			var c: Color = img.get_pixel(x, y)
			# Distinguish:
			# Sky / Red backdrop: R > 0.4, G < 0.2
			# Dark / Chassis / Tires: R < 0.15, G < 0.15, B < 0.15
			# White / Highlights / Metallic: R > 0.7, G > 0.7, B > 0.7
			# Orange / Gold: R > 0.7, G > 0.4, B < 0.2
			# Brown / Wood / Stone / Basalt: R=0.25..0.6, G=0.2..0.5, B=0.15..0.4
			if c.r > 0.75 and c.g > 0.75 and c.b > 0.75:
				line += "W"
			elif c.r > 0.75 and c.g > 0.45 and c.b < 0.25:
				line += "O"
			elif c.r > 0.5 and c.g < 0.2 and c.b < 0.2:
				line += "R"
			elif c.r < 0.12 and c.g < 0.12 and c.b < 0.12:
				line += "."
			elif abs(c.r - c.g) < 0.1 and abs(c.g - c.b) < 0.1 and c.r > 0.2:
				line += "G" # Grey stone
			elif c.r > 0.25 and c.g > 0.15 and c.b < 0.2:
				line += "B" # Brown wood
			else:
				line += " "
		print("%2d: %s" % [y, line])
	quit(0)
