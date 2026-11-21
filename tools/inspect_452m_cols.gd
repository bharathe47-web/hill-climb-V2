@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/forensic_debug/gameplay_clean_452m.png")
	if not img:
		printerr("No 452m image")
		quit(0)
		return

	# In 452m, Column1 is at screen_x = 149.6, Column2 is at screen_x = 853.6, Column3 is at screen_x = 1293.6
	for col_x in [150, 854]:
		print("\n--- Visual column inspection at screen X = %d in 452m ---" % col_x)
		# Print vertical strip around column base (y = 400..450)
		for y in range(410, 440):
			var c = img.get_pixel(col_x, y)
			print("  y=%d: rgba(%.2f, %.2f, %.2f, %.2f)" % [y, c.r, c.g, c.b, c.a])

	quit(0)
