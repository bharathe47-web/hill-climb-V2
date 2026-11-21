@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/environments/hell/background/sky/hell_sky_crimson_panorama.png")
	print("Panorama Size: %dx%d" % [img.get_width(), img.get_height()])
	print("Cavern ceiling (top center 960, 40): ", img.get_pixel(960, 40))
	print("Demon Fortress (center 960, 260): ", img.get_pixel(960, 260))
	print("Blood Moon (upper right 1510, 193): ", img.get_pixel(1510, 193))
	print("Left Lavafall (610, 400): ", img.get_pixel(610, 400))
	print("Right Lavafall (1310, 400): ", img.get_pixel(1310, 400))
	print("Magma Abyss (bottom center 960, 680): ", img.get_pixel(960, 680))
	print("Left edge (0, 360): ", img.get_pixel(0, 360))
	print("Right edge (1919, 360): ", img.get_pixel(1919, 360))
	var edge_diff := 0.0
	for y in range(img.get_height()):
		var cl := img.get_pixel(0, y)
		var cr := img.get_pixel(img.get_width() - 1, y)
		edge_diff += abs(cl.r - cr.r) + abs(cl.g - cr.g) + abs(cl.b - cr.b)
	print("Seam difference along entire height: ", edge_diff)
	quit(0)
