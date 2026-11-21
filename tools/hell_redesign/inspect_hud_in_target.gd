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
	print("--- INSPECTING references/hell_target.png ---")
	print("Size: %dx%d, format: %d" % [w, h, img.get_format()])

	# Check corner regions for HUD text or controls:
	# Top-left (usually coins / distance)
	# Top-right (usually pause / settings)
	# Bottom-left (brake pedal)
	# Bottom-right (gas pedal / nitro)
	# Bottom-center (vehicle / speedometer)
	# Check whether this is an in-game screenshot from another game or an artwork illustration
	print("Corners:")
	print("  Top-left (10, 10): ", img.get_pixel(10, 10))
	print("  Top-right (%d, 10): %s" % [w - 10, img.get_pixel(w - 10, 10)])
	print("  Bottom-left (10, %d): %s" % [h - 10, img.get_pixel(10, h - 10)])
	print("  Bottom-right (%d, %d): %s" % [w - 10, h - 10, img.get_pixel(w - 10, h - 10)])

	quit(0)
