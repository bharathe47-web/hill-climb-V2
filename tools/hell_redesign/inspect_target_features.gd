@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_target.png")
	if not img:
		printerr("Cannot load references/hell_target.png")
		quit(1)
		return
	var w := img.get_width()
	var h := img.get_height()
	print("--- TARGET IMAGE ANALYSIS ---")
	print("Size: %dx%d" % [w, h])

	# Let's inspect vertical color slices
	# At x = 400 (left lavafall area)
	# At x = 800 (center fortress area)
	# At x = 1200 (right lavafall area)
	# At x = 1400 (blood moon area)
	for x_sample in [200, 450, 800, 1150, 1380]:
		print("\nColumn x = %d:" % x_sample)
		for y in range(0, h, 40):
			var c := img.get_pixel(x_sample, y)
			print("  y=%3d: R=%.2f G=%.2f B=%.2f A=%.2f" % [y, c.r, c.g, c.b, c.a])

	quit(0)
