@tool
extends SceneTree

func _init() -> void:
	var user_img := Image.load_from_file("res://references/hell_cleanup_blue_strips.png")
	user_img.convert(Image.FORMAT_RGBA8)
	print("User image size: %dx%d" % [user_img.get_width(), user_img.get_height()])

	# Check checkpoints
	var cp_600 := Image.load_from_file("res://references/hell_checkpoint_600m.png")
	if cp_600:
		print("Checkpoint 600m size: %dx%d" % [cp_600.get_width(), cp_600.get_height()])
	
	# Let's inspect the right strip crop in user_img vs checkpoint
	# In analyze_blue_markings:
	# Right strip was around x=[1090..1302], y=[86..141] in user_img
	# Left strip was around x=[80..244], y=[104..241] in user_img
	
	# Let's also check distance text in user_img around center top:
	# Let's scan for white text pixels near center top (x=500..800, y=10..70)
	var min_tx := 9999; var max_tx := -1; var min_ty := 9999; var max_ty := -1
	for y in range(10, 70):
		var line := ""
		for x in range(550, 750, 2):
			var c := user_img.get_pixel(x, y)
			if c.r > 0.8 and c.g > 0.8 and c.b > 0.8:
				line += "#"
			elif c.r > 0.8 and c.g > 0.7 and c.b < 0.3:
				line += "$" # gold/coin
			else:
				line += " "
		if line.strip_edges() != "":
			print("Y=%2d: %s" % [y, line])

	quit(0)
