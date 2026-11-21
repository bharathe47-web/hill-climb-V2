@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/forensic_debug/gameplay_clean_452m.png")
	for y in range(330, 430, 2):
		print("At x=854, y=%d: %s" % [y, img.get_pixel(854, y)])
	quit(0)
