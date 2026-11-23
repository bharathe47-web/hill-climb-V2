@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/forensic_debug/gameplay_clean_452m.png")
	for test_y in [100, 200, 300, 400]:
		print("At x=854, y=%d: %s" % [test_y, img.get_pixel(854, test_y)])
	quit(0)
