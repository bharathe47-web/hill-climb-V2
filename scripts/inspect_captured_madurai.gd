extends SceneTree

func _init() -> void:
	var path = "/home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50/06_madurai_checkpoint.png"
	var img = Image.load_from_file(path)
	if img:
		print("Loaded 06_madurai_checkpoint.png: ", img.get_size())
		# Check vehicle contact around x=400..700, y=350..550
		# Also check for colorful temple pixels (Meenakshi temple has distinct golden, pink, green sculptures)
		var colorful_sculptures = 0
		for y in range(150, 450, 4):
			for x in range(300, 900, 4):
				var c = img.get_pixel(x, y)
				# colorful saturated pixels
				var max_c = maxf(c.r, maxf(c.g, c.b))
				var min_c = minf(c.r, minf(c.g, c.b))
				if max_c - min_c > 0.35 and max_c > 0.4:
					colorful_sculptures += 1
		print("Colorful temple gopuram pixel samples: ", colorful_sculptures)
	else:
		print("Could not load image!")
	quit()
