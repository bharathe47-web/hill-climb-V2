@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_pink.png"
	var img := Image.load_from_file(path)
	if not img:
		quit(1)
		return

	var w := img.get_width()
	var h := img.get_height()

	# The annotation pen has:
	# R high (> 0.70 or > 0.60), and G/B are elevated (around 0.25..0.60), typically R > 0.75, G in 0.3..0.55, B in 0.3..0.55
	# Let's inspect a patch around x=865, y=213 to see the exact profile of the pen stroke!
	print("--- Pen stroke profile around (865, 213) ---")
	for dy in range(-5, 6):
		var line := ""
		for dx in range(-5, 6):
			var c := img.get_pixel(865 + dx, 213 + dy)
			line += "[%.2f,%.2f,%.2f] " % [c.r, c.g, c.b]
		print(line)

	quit(0)
