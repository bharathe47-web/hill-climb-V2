@tool
extends SceneTree

func _init() -> void:
	var paths := [
		"res://assets/environments/hell/terrain/broken_basalt_platform_hazard.png",
		"res://assets/environments/hell/decorations/skull_game_obstacle.png",
		"res://assets/environments/hell/terrain/hell_basalt_platform.png",
		"res://assets/ui/controls/control_button_base.png",
		"res://assets/ui/controls/brake_pedal_normal.png"
	]
	for p in paths:
		var img := Image.load_from_file(p)
		if img:
			print("Asset: ", p, " size: ", img.get_size(), " format: ", img.get_format())
	quit(0)
