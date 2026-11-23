extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/environments/hell/decorations/giant_dragon_skull_decal.png")
	if not img:
		quit(1)
		return
	print("Size: ", img.get_size())
	# Let's inspect borders:
	print("Pixel at (0,0): ", img.get_pixel(0, 0))
	print("Pixel at (350,0): ", img.get_pixel(350, 0))
	print("Pixel at (699,0): ", img.get_pixel(699, 0))
	print("Pixel at (0,275): ", img.get_pixel(0, 275))
	print("Pixel at (350,275): ", img.get_pixel(350, 275))
	print("Pixel at (699,275): ", img.get_pixel(699, 275))
	print("Pixel at (0,549): ", img.get_pixel(0, 549))
	print("Pixel at (350,549): ", img.get_pixel(350, 549))
	print("Pixel at (699,549): ", img.get_pixel(699, 549))
	
	# Where did this image come from? Let's check quarantine or git log / file history if any or find how it was created
	quit(0)
