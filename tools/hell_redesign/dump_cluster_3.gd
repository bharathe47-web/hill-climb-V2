@tool
extends SceneTree

func _init() -> void:
	var c3 := Image.load_from_file("res://references/user_blue_cluster_3.png")
	c3.convert(Image.FORMAT_RGBA8)
	print("Cluster 3 crop size: %dx%d" % [c3.get_width(), c3.get_height()])

	for y in range(0, c3.get_height(), 2):
		var line := ""
		for x in range(0, c3.get_width(), 2):
			var c := c3.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2:
				line += "@"
			elif c.r > 0.7 and c.g > 0.5 and c.b < 0.3:
				line += "$"
			elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
				line += "#"
			elif c.r > 0.25 and c.g < 0.25 and c.b < 0.25:
				line += "%"
			elif c.r > 0.6 and c.g > 0.2 and c.b < 0.2:
				line += "!"
			else:
				line += "."
		print(line)

	quit(0)
