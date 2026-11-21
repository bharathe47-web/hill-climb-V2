@tool
extends SceneTree

func _init() -> void:
	print("--- ANALYZING UNWANTED OBJECT CROPS ---")
	for name in [
		"unwanted_569m_A_dragon_upper_right",
		"unwanted_569m_B_monster_or_creature",
		"unwanted_569m_C_platforms_or_pads",
		"unwanted_569m_D_obstacle_blocks_bottom",
		"unwanted_569m_F_rock_fragments"
	]:
		var path := "res://docs/hell_redesign/%s.png" % name
		var img := Image.load_from_file(path)
		if img:
			print("Crop: ", name, " Size: %dx%d" % [img.get_width(), img.get_height()])
			# Sample center color
			var cx := img.get_width() / 2
			var cy := img.get_height() / 2
			print("  Center (%d, %d): %s" % [cx, cy, img.get_pixel(cx, cy)])

	quit(0)
