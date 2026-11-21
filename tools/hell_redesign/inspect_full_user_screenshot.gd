@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_blue_strips.png")
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Full screenshot dimensions: %dx%d" % [w, h])

	# Let's inspect the LEFT strip in the user image:
	# From analyze_blue_markings: Left strip was around x=[80..244], y=[104..241]
	# Let's print out what is inside the LEFT strip!
	var left_crop := img.get_region(Rect2i(50, 80, 250, 100))
	left_crop.save_png("res://references/inspect_left_strip_full.png")
	print("Saved inspect_left_strip_full.png")

	# Let's also inspect the entire width at y=90..150!
	# Are these strips part of something spanning across the screen, or two separate objects?
	var strip_slice := img.get_region(Rect2i(0, 90, w, 60))
	strip_slice.save_png("res://references/strip_slice_y90_150.png")
	print("Saved strip_slice_y90_150.png")

	# Let's also find where the player truck / wheels / ground are
	# Check at x=200..600, y=300..700
	var ground_y := -1
	for y in range(h - 1, 0, -1):
		var p := img.get_pixel(w / 2, y)
		# Road / bridge is typically non-black, let's see colors along center vertical line
	
	# Let's inspect horizontal bands:
	# For each 50px vertical block, print dominant colors
	for y_block in range(0, h, 60):
		var dark_count := 0
		var crimson_count := 0
		var orange_count := 0
		var other_count := 0
		for y in range(y_block, mini(h, y_block + 60), 5):
			for x in range(0, w, 10):
				var c := img.get_pixel(x, y)
				if c.r < 0.2 and c.g < 0.2 and c.b < 0.2:
					dark_count += 1
				elif c.r > 0.3 and c.g < 0.25 and c.b < 0.25:
					crimson_count += 1
				elif c.r > 0.6 and c.g > 0.3 and c.b < 0.2:
					orange_count += 1
				else:
					other_count += 1
		print("Band Y=[%3d..%3d]: dark=%4d, crimson=%4d, orange=%4d, other=%4d" % [
			y_block, mini(h, y_block + 60), dark_count, crimson_count, orange_count, other_count
		])

	quit(0)
