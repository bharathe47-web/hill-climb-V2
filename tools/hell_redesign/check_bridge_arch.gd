extends SceneTree

func _init() -> void:
	var path := "res://assets/environments/hell/architecture/hell_bridge/hell_volcanic_bridge_arch.png"
	var img := Image.load_from_file(path)
	if img:
		print("hell_volcanic_bridge_arch.png: size=", img.get_size(), " format=", img.get_format())
		# check alpha corners and non-transparent pixels
		var non_trans := 0
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				if img.get_pixel(x, y).a > 0.1:
					non_trans += 1
		print("Non-transparent pixels: ", non_trans, " / ", img.get_width() * img.get_height())
	else:
		print("Cannot load hell_volcanic_bridge_arch.png")
	quit(0)
