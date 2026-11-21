@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_blue_strips.png")
	img.convert(Image.FORMAT_RGBA8)

	# Crop top-right (y=10..70)
	var hud_tr := img.get_region(Rect2i(1050, 10, 260, 60))
	hud_tr.save_png("res://references/hud_top_right.png")

	# Crop marked-right (y=80..150)
	var marked_tr := img.get_region(Rect2i(1050, 80, 260, 70))
	marked_tr.save_png("res://references/marked_right_crop.png")

	# Crop top-left (y=10..70)
	var hud_tl := img.get_region(Rect2i(50, 10, 260, 60))
	hud_tl.save_png("res://references/hud_top_left.png")

	# Crop marked-left (y=80..250)
	var marked_tl := img.get_region(Rect2i(50, 80, 260, 170))
	marked_tl.save_png("res://references/marked_left_crop.png")

	print("Saved crops! Checking differences...")

	# Let's inspect the content of marked_tr vs hud_tr
	# Does marked_tr look like a scenery strip, or like a duplicate HUD, or what?
	# Let's check colors in marked_tr:
	var tr_colors: Dictionary = {}
	for y in range(marked_tr.get_height()):
		for x in range(marked_tr.get_width()):
			var c := marked_tr.get_pixel(x, y)
			var hex := "%02x%02x%02x" % [int(c.r*255), int(c.g*255), int(c.b*255)]
			tr_colors[hex] = tr_colors.get(hex, 0) + 1

	var top_tr = tr_colors.keys()
	top_tr.sort_custom(func(a,b): return tr_colors[a] > tr_colors[b])
	print("Top 5 colors in marked_tr:")
	for i in range(mini(5, top_tr.size())):
		print("  #%s: %d" % [top_tr[i], tr_colors[top_tr[i]]])

	quit(0)
