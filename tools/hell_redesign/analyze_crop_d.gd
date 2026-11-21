@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/hell_redesign/unwanted_569m_D_obstacle_blocks_bottom.png")
	if not img:
		quit(1)
		return
	print("Size: ", img.get_size())
	# Let's inspect rows around the center
	# Nitro bottle icon is at the center of Nitro button!
	# Does it have "NITRO" or a bottle?
	# Let's check non-blue pixels:
	var w := img.get_width()
	var h := img.get_height()
	# Check if any pixels match nitro bottle or pedal
	# Count how many transparent pixels, how many colored
	var col_counts := {}
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.b > 0.65 and c.b > c.r + 0.3 and c.b > c.g:
				continue # blue annotation
			# classify
			var tag := "other"
			if c.r > 0.8 and c.g > 0.7 and c.b > 0.7:
				tag = "white/light"
			elif c.r < 0.2 and c.g < 0.2 and c.b < 0.2:
				tag = "dark/black"
			elif c.r > 0.7 and c.g > 0.4 and c.b < 0.2:
				tag = "orange"
			elif c.b > 0.6 and c.r < 0.3:
				tag = "cyan/blue"
			elif c.r > 0.6 and c.g < 0.3:
				tag = "red"
			col_counts[tag] = col_counts.get(tag, 0) + 1
	print("Color classification in Crop D: ", col_counts)
	quit(0)
