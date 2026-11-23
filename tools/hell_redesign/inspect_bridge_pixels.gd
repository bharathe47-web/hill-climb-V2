@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_target.png")
	var w := img.get_width()
	var h := img.get_height()
	print("--- INSPECTING BRIDGE MASONRY IN TARGET ---")

	# Sample bridge road center at x=700..900, y=360..400
	for y in range(360, 410, 5):
		var line := ""
		for x in range(740, 800, 5):
			var c := img.get_pixel(x, y)
			line += "(%.2f,%.2f,%.2f) " % [c.r, c.g, c.b]
		print("Y=%d: %s" % [y, line])

	quit(0)
