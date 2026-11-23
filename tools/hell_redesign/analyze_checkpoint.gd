@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/hell_redesign/qa_screenshots/hell_checkpoint_750m.png")
	if not img:
		printerr("Cannot load hell_checkpoint_750m.png")
		quit(1)
		return
	print("Game 750m Screenshot: %dx%d" % [img.get_width(), img.get_height()])

	# Find the road surface in the screenshot:
	# Scan middle columns x=640 (center of 1280x720)
	print("Sampling center column x=640 from top to bottom:")
	for y in range(0, 720, 30):
		var c := img.get_pixel(640, y)
		print("  y=%3d: R=%.2f G=%.2f B=%.2f" % [y, c.r, c.g, c.b])

	quit(0)
