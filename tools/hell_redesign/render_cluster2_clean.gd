@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/cluster2_in_1443.png")
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("cluster2_in_1443 size: %dx%d" % [w, h])

	for y in range(0, h, 2):
		var line := ""
		for x in range(0, w, 2):
			var c := img.get_pixel(x, y)
			if c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
				line += "#"
			elif c.r > 0.7 and c.g > 0.5 and c.b < 0.3:
				line += "$"
			elif c.r > 0.3 and c.g < 0.2 and c.b < 0.2:
				line += "%"
			elif c.r > 0.6 and c.g > 0.2 and c.b < 0.2:
				line += "!"
			else:
				line += "."
		print(line)

	quit(0)
