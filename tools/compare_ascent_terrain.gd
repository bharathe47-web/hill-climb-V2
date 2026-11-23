@tool
extends SceneTree

func _init() -> void:
	var ascent_img := Image.load_from_file("res://Heavenly Monster Truck Ascent.png")
	var target_img := Image.load_from_file("res://references/heaven_target.png")
	var game_img := Image.load_from_file("res://docs/forensic_debug/gameplay_clean_452m.png")

	print("--- COMPARING TERRAIN IN 'Heavenly Monster Truck Ascent.png' VS GAME HEAVEN ---")
	print("Ascent image size: ", ascent_img.get_size() if ascent_img else "null")
	print("Target image size: ", target_img.get_size() if target_img else "null")
	print("Game shot size: ", game_img.get_size() if game_img else "null")

	# Let's inspect the road line in Ascent image across X coordinates
	# In Ascent image (1280x720 or similar):
	var aw = ascent_img.get_width()
	var ah = ascent_img.get_height()
	print("Ascent dimensions: %dx%d" % [aw, ah])

	# Trace road surface Y in Ascent image:
	# The road has gold trim and marble white deck
	print("\nSampling road profile in Heavenly Monster Truck Ascent.png:")
	for x_norm in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]:
		var x = int(aw * x_norm)
		# Scan Y from ah * 0.4 to ah * 0.85
		var road_y = -1
		for y in range(int(ah * 0.4), int(ah * 0.85)):
			var c = ascent_img.get_pixel(x, y)
			# Road surface in Ascent: ivory marble / gold trim
			if (c.r > 0.85 and c.g > 0.80 and c.b > 0.65) or (c.r > 0.75 and c.g > 0.60 and c.b < 0.45):
				road_y = y
				break
		print("  x=%.2f (%d): road_y = %d (relative Y = %.3f)" % [x_norm, x, road_y, float(road_y) / float(ah)])

	quit(0)
