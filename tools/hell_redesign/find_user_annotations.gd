@tool
extends SceneTree

func _init() -> void:
	var path := "/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-43-03.png"
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# Let's save a downscaled 683x384 image so we can inspect it or analyze
	var down := img.duplicate()
	down.resize(w / 2, h / 2, Image.INTERPOLATE_BILINEAR)
	down.save_png("res://references/screenshot_half.png")

	# Let's print any pixels that have r > 0.7, g > 0.7, b > 0.7 in the whole image (excluding HUD y < 100 and pedals y > 600)
	print("Scanning whole image for any stroke or annotation (y in [100..600]):")
	for y in range(100, 600, 10):
		var line := "y=%3d: " % y
		var found_in_row := 0
		for x in range(0, w, 10):
			var c := img.get_pixel(x, y)
			# Check if white-ish or light gray
			if c.r > 0.7 and c.g > 0.7 and c.b > 0.7:
				found_in_row += 1
		line += "%d pts" % found_in_row
		if found_in_row > 0:
			print(line)

	quit(0)
