@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/environments/hell/terrain/broken_basalt_platform_hazard.png")
	if img:
		print("broken_basalt_platform_hazard size: ", img.get_size())
		# check colors
		var has_dots := false
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var c := img.get_pixel(x, y)
				if c.a > 0.1 and c.r > 0.7 and c.g > 0.3 and c.b < 0.2:
					has_dots = true
		print("Has orange pixels: ", has_dots)

	var img_obs := Image.load_from_file("res://assets/environments/hell/decorations/skull_game_obstacle.png")
	if img_obs:
		print("skull_game_obstacle size: ", img_obs.get_size())

	quit(0)
