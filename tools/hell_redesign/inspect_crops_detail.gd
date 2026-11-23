@tool
extends SceneTree

func _init() -> void:
	var crops := [
		"res://references/crop_centre_left.png",
		"res://references/crop_middle_right.png",
		"res://references/crop_far_right.png"
	]
	for c_path in crops:
		var img := Image.load_from_file(c_path)
		img.convert(Image.FORMAT_RGBA8)
		print("\nAnalyzing %s (%dx%d):" % [c_path, img.get_width(), img.get_height()])
		
		# Count colors
		var black_pixels := 0
		var orange_pixels := 0
		var white_pixels := 0
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var c := img.get_pixel(x, y)
				if c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
					black_pixels += 1
				elif c.r > 0.8 and c.g > 0.3 and c.g < 0.7 and c.b < 0.2:
					orange_pixels += 1
				elif c.r > 0.85 and c.g > 0.85 and c.b > 0.85:
					white_pixels += 1
		print("  Black: %d, Orange: %d, White: %d" % [black_pixels, orange_pixels, white_pixels])

	quit(0)
