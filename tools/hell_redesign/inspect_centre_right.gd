extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	if not img:
		quit(1)
		return
		
	var w := img.get_width()
	var h := img.get_height()
	print("Image size: %dx%d" % [w, h])
	
	# The user says:
	# Location: Centre-right of the gameplay screen.
	# The large rectangular image shows a separate dark cave/rocky bridge scene with a waterfall-like opening.
	# Let's save crops of centre-right area:
	# Centre-right: X from 600 to 1366, Y from 100 to 600.
	# Let's slice this area into a few high-res crops and save them to references/ so we can inspect them!
	
	# Crop 1: x=600..1000, y=100..450
	var c1 := img.get_region(Rect2i(600, 100, 400, 350))
	c1.save_png("res://references/centre_right_top.png")
	
	# Crop 2: x=800..1250, y=100..500
	var c2 := img.get_region(Rect2i(800, 100, 450, 400))
	c2.save_png("res://references/centre_right_mid.png")
	
	# Crop 3: x=900..1366, y=200..600
	var c3 := img.get_region(Rect2i(900, 200, 460, 400))
	c3.save_png("res://references/centre_right_far.png")
	
	# Also let's inspect where the pink annotations are in the image!
	# Let's find every pixel where the user drew annotations:
	# Let's check what pixels were modified or drawn on the screenshot.
	# In Godot, let's scan for colors that look like annotations.
	# Let's find the bounding box of each stroke.
	print("Saved centre-right crops.")
	quit(0)
