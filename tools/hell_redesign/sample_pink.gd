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

	# Sample the user's pink pen color at (865, 220):
	# Let's inspect the exact RGB around (865, 220..225)
	for y in range(210, 230):
		var c := img.get_pixel(865, y)
		print("y=%d: R=%.3f G=%.3f B=%.3f" % [y, c.r, c.g, c.b])

	quit(0)
