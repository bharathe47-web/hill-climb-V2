@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/hell_redesign/qa_screenshots/hell_checkpoint_750m.png")
	print("--- VERIFYING CAPTURED 750m GAMEPLAY SCREENSHOT ---")
	print("Size: %dx%d" % [img.get_width(), img.get_height()])

	# Top sky area (x=640, y=50)
	print("Top sky (640, 50): ", img.get_pixel(640, 50))
	# Mid demon fortress area (x=640, y=250)
	print("Mid demon fortress (640, 250): ", img.get_pixel(640, 250))
	# Blood moon area (upper right x=1050, y=150)
	print("Blood moon area (1050, 150): ", img.get_pixel(1050, 150))
	# Road top rim (x=640, y=530..570)
	for y in range(510, 600, 10):
		print("Road profile y=%d: %s" % [y, img.get_pixel(640, y)])
	# Bridge subsoil (x=640, y=650)
	print("Bridge subsoil (640, 650): ", img.get_pixel(640, 650))

	quit(0)
