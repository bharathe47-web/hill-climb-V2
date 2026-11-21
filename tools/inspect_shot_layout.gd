@tool
extends SceneTree

func _init():
	var shot = Image.load_from_file("res://docs/forensic_debug/gameplay_clean_452m.png")
	print("Shot size: ", shot.get_size())
	# Let's inspect where the stained glass is in the screenshot
	# We know StainedGlassArch2 was placed at x=1480, y=200 in parallax layer with motion_scale (0.24, 0)
	# At 452m, world_x is ~45200. Camera is at ~45380.
	# Parallax offset mod 2560: 45380 * 0.24 = 10891.2 mod 2560 = 651.2
	# In screen space: 1480 - 651.2 = 828.8 or 828.8 + 2560 etc.
	# Let's check colors in shot around x=828, y=200
	var col = shot.get_pixel(828, 200)
	print("Pixel at (828, 200): ", col)
	quit(0)
