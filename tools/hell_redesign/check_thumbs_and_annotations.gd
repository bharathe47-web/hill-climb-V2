extends SceneTree

func _init() -> void:
	var img1 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png")
	var img2 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-47.png")
	
	print("Checking what is in 13-37-08 vs 13-37-47:")
	# Save scaled thumbnails (400x225) so we can inspect
	var thumb1 := img1.duplicate()
	thumb1.resize(400, 225)
	thumb1.save_png("res://references/thumb_133708.png")
	
	var thumb2 := img2.duplicate()
	thumb2.resize(400, 225)
	thumb2.save_png("res://references/thumb_133747.png")
	print("Saved thumbnails.")
	
	# What vehicle is in 13-37-08 and 13-37-47?
	# Let's search where the vehicle is: usually around x=300..600, y=300..600
	# What colors are drawn as annotations?
	# In 13-37-47, let's find saturated colors:
	var blue_cyan := 0
	var red_pink := 0
	var green := 0
	var yellow := 0
	for y in range(img2.get_height()):
		for x in range(img2.get_width()):
			var c := img2.get_pixel(x, y)
			# Cyan: high G, high B, low R
			if c.b > 0.6 and c.g > 0.6 and c.r < 0.4:
				blue_cyan += 1
			# Blue: high B, low R, low G
			elif c.b > 0.7 and c.r < 0.4 and c.g < 0.5:
				blue_cyan += 1
			# Red: high R, low G, low B
			elif c.r > 0.7 and c.g < 0.4 and c.b < 0.4:
				red_pink += 1
			# Yellow: high R, high G, low B
			elif c.r > 0.8 and c.g > 0.8 and c.b < 0.3:
				yellow += 1
				
	print("13-37-47 colors: cyan/blue=%d, red=%d, yellow=%d" % [blue_cyan, red_pink, yellow])
	
	var blue_cyan1 := 0
	for y in range(img1.get_height()):
		for x in range(img1.get_width()):
			var c := img1.get_pixel(x, y)
			if (c.b > 0.6 and c.g > 0.6 and c.r < 0.4) or (c.b > 0.7 and c.r < 0.4 and c.g < 0.5):
				blue_cyan1 += 1
	print("13-37-08 colors: cyan/blue=%d" % blue_cyan1)
	
	quit(0)
