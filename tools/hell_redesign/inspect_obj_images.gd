extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	# Let's crop the entire region X=[650, 1050], Y=[200, 550]
	var rect := Rect2i(650, 200, 400, 350)
	var crop := img.get_region(rect)
	crop.save_png("res://references/suspect_region_large.png")
	print("Saved suspect_region_large.png")
	
	# Let's also check the left torch area:
	# "OBJECT 2 — LEFT BLACK FIRE SQUARE: Above the bridge on the left side."
	# "OBJECT 3 — RIGHT BLACK FIRE SQUARE: Above the bridge on the right side."
	# In HellEnvironment.tscn:
	# TorchFlameLeft is at (950, 310)
	# TorchFlameRight is at (1650, 310)
	# On screen, where are they?
	# Let's check where the two black squares with fire are!
	quit(0)
