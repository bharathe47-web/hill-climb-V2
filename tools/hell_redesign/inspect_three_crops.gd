@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-43-03.png")
	img.convert(Image.FORMAT_RGBA8)

	# Read the HUD distance first to know where the vehicle is in 14-43-03
	# Let's sample HUD text around x=600..750, y=10..60
	# Let's save a clean HUD image
	var hud := img.get_region(Rect2i(550, 10, 260, 50))
	hud.save_png("res://references/hud_1443.png")

	# Let's inspect the circles:
	# What color are the circles that the user drew?
	# Let's check the perimeter of the three regions mentioned by the user:
	# 1. "The dotted obstacle near the centre-left road."
	# 2. "The large dotted obstacle in the middle-right."
	# 3. "The dotted obstacle on the far-right."
	
	# Let's search for any hand-drawn loop or oval in the whole image!
	# How? In image processing, user drawings are lines with high contrast against the game background.
	# Let's check for any pure white pixels or near-white pixels:
	print("Checking all pixels with lum > 0.8 in y in [300..650]...")
	var bright_pts: Array[Vector2i] = []
	for y in range(300, 650):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			# pedals are at x < 260 or x > 1100 when y > 580
			if y > 580 and (x < 260 or x > 1050):
				continue
			var lum := 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
			# Let's check if it's near white: c.r > 0.85 and c.g > 0.85 and c.b > 0.85
			if c.r > 0.85 and c.g > 0.85 and c.b > 0.85:
				bright_pts.append(Vector2i(x, y))

	print("Total bright points: %d" % bright_pts.size())
	for pt in bright_pts:
		if pt.x % 50 == 0:
			print("  bright pt at (%d, %d)" % [pt.x, pt.y])

	quit(0)
