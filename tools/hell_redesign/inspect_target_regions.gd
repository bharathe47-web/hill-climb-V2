@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_target.png")
	if not img:
		printerr("Cannot load hell_target.png")
		quit(0)
		return

	var w := img.get_width()
	var h := img.get_height()
	print("Hell Target Size: %dx%d" % [w, h])

	# Inspect colors in key regions:
	# 1. Sky / Moon at upper right (x=1350, y=100)
	print("Blood moon center (1350, 100): ", img.get_pixel(1350, 100))
	# 2. Central demon fortress eyes (x=830, y=250), mouth (x=830, y=320)
	print("Fortress center (830, 200): ", img.get_pixel(830, 200))
	print("Fortress eye (810, 240): ", img.get_pixel(810, 240))
	print("Fortress mouth (830, 310): ", img.get_pixel(830, 310))
	# 3. Lava falls left (x=450, y=280) and right (x=1150, y=280)
	print("Lavafall left (450, 280): ", img.get_pixel(450, 280))
	print("Lavafall right (1150, 280): ", img.get_pixel(1150, 280))
	# 4. Cavern ceiling top-left (x=100, y=30)
	print("Cavern ceiling (100, 30): ", img.get_pixel(100, 30))
	# 5. Hanging cage (x=300, y=120)
	print("Hanging cage (300, 120): ", img.get_pixel(300, 120))
	# 6. Skull banner left (x=60, y=250) and right (x=1540, y=250)
	print("Skull banner left (60, 250): ", img.get_pixel(60, 250))
	print("Skull banner right (1540, 250): ", img.get_pixel(1540, 250))
	# 7. Bridge surface (x=800, y=410)
	print("Bridge surface (800, 410): ", img.get_pixel(800, 410))
	# 8. Foreground skulls / rocks (x=800, y=500)
	print("Foreground (800, 500): ", img.get_pixel(800, 500))

	quit(0)
