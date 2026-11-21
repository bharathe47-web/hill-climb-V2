extends SceneTree

func _init() -> void:
	var bikes = ["car_14", "car_15", "car_16", "car_17", "car_24", "car_25"]
	for b in bikes:
		var img_path = "assets/vehicles/garage/%s/body.png" % b
		var img = Image.load_from_file(img_path)
		print("%s body image size: %dx%d" % [b, img.get_width(), img.get_height()])
	quit(0)
