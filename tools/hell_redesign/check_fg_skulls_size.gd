@tool
extends SceneTree

func _init() -> void:
	var path := "res://assets/environments/hell/foreground/decorations/hell_foreground_skulls_rocks.png"
	var img := Image.load_from_file(path)
	if img:
		print("hell_foreground_skulls_rocks.png size: %dx%d" % [img.get_width(), img.get_height()])
	quit(0)
