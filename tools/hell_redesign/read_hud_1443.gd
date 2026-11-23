@tool
extends SceneTree

func _init() -> void:
	var hud := Image.load_from_file("res://references/hud_1443.png")
	hud.convert(Image.FORMAT_RGBA8)
	var w := hud.get_width()
	var h := hud.get_height()
	print("HUD ASCII:")
	for y in range(0, h, 2):
		var line := ""
		for x in range(0, w, 2):
			var c := hud.get_pixel(x, y)
			if c.r > 0.8 and c.g > 0.8 and c.b > 0.8:
				line += "#"
			elif c.r > 0.5:
				line += "."
			else:
				line += " "
		if line.strip_edges() != "":
			print(line)
	quit(0)
