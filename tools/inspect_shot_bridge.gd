@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/forensic_debug/gameplay_clean_452m.png")
	print("Inspecting gameplay_clean_452m.png under the road:")
	# Let's inspect vertical strips at x = 200, 400, 600, 800, 1000 from y = 380 to 520
	for test_x in [200, 400, 600, 800, 1000]:
		print("\nStrip at screen X = %d:" % test_x)
		for y in range(390, 500, 10):
			var c := img.get_pixel(test_x, y)
			print("  y=%3d: rgba(%.2f, %.2f, %.2f, %.2f)" % [y, c.r, c.g, c.b, c.a])
	quit(0)
