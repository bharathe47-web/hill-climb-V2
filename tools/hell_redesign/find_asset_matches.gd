@tool
extends SceneTree

func _init() -> void:
	print("--- FINDING MATCHES FOR CROPPED UNWANTED OBJECTS ---")
	var crop_b := Image.load_from_file("res://docs/hell_redesign/unwanted_569m_B_monster_or_creature.png")
	var crop_c := Image.load_from_file("res://docs/hell_redesign/unwanted_569m_C_platforms_or_pads.png")
	var crop_d := Image.load_from_file("res://docs/hell_redesign/unwanted_569m_D_obstacle_blocks_bottom.png")
	var crop_f := Image.load_from_file("res://docs/hell_redesign/unwanted_600m_F_rock_fragments.png")

	# Let's inspect what colors/patterns are in crop_d (the obstacle blocks)
	if crop_d:
		print("\nCrop D (Obstacle blocks) size: ", crop_d.get_size())
		# Sample distinct non-blue pixels in crop_d
		var colors := {}
		for y in range(0, crop_d.get_height(), 4):
			for x in range(0, crop_d.get_width(), 4):
				var c := crop_d.get_pixel(x, y)
				# Ignore blue annotation line
				if not (c.b > 0.65 and c.b > c.r + 0.3):
					var key := "%d,%d,%d" % [int(c.r * 10), int(c.g * 10), int(c.b * 10)]
					colors[key] = colors.get(key, 0) + 1
		print("Top color clusters in Crop D: ", colors.keys().slice(0, 10))

	# Let's check crop_c (platforms/pads)
	if crop_c:
		print("\nCrop C (Platforms/pads) size: ", crop_c.get_size())
		var colors_c := {}
		for y in range(0, crop_c.get_height(), 4):
			for x in range(0, crop_c.get_width(), 4):
				var c := crop_c.get_pixel(x, y)
				if not (c.b > 0.65 and c.b > c.r + 0.3):
					var key := "%d,%d,%d" % [int(c.r * 10), int(c.g * 10), int(c.b * 10)]
					colors_c[key] = colors_c.get(key, 0) + 1
		print("Top color clusters in Crop C: ", colors_c.keys().slice(0, 10))

	quit(0)
