extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	# Let's find the distance number.
	# The text "HELL BIOME xxxm" or "xxxm" is located at:
	# In print_distance.gd, y was 10..50.
	# Let's print the entire text row from y=10 to y=35, x=650..780
	for y in range(8, 25):
		var line := ""
		for x in range(680, 760):
			var c := img.get_pixel(x, y)
			line += "#" if (c.r > 0.8 and c.g > 0.8 and c.b > 0.8) else " "
		print(line)
		
	# Also let's check coin count at top right:
	print("--- COINS ---")
	for y in range(8, 25):
		var line := ""
		for x in range(1200, 1340):
			var c := img.get_pixel(x, y)
			line += "#" if (c.r > 0.8 and c.g > 0.8 and c.b > 0.8) else " "
		if line.strip_edges() != "":
			print(line)
	quit(0)
