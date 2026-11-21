@tool
extends SceneTree

func _init() -> void:
	var path := "res://assets/environments/hell/background/sky/hell_sky_crimson_panorama.png"
	var img := Image.load_from_file(path)
	if img:
		print("hell_sky_crimson_panorama.png size: %dx%d" % [img.get_width(), img.get_height()])
	quit(0)
