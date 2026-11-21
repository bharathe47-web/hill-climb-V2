@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_blue_strips.png"
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)

	# 1. Right strip: x=1080..1310, y=80..150
	var r_crop := img.get_region(Rect2i(1080, 80, 240, 80))
	r_crop.save_png("res://references/marked_strip_right.png")

	# 2. Left strip (top-left / middle-left):
	# The user says:
	# "1. LEFT: A long, thin rectangular scenery strip floating across the middle-left of the Hell background.
	# 2. RIGHT: Another long, thin rectangular scenery strip floating across the middle-right of the Hell background."
	# Notice:
	# "A long, thin rectangular scenery strip floating across the middle-left of the Hell background"
	# "Another long, thin rectangular scenery strip floating across the middle-right of the Hell background"
	
	# Let's check at the same Y as the right strip!
	# The right strip is at y=86..141 (height ~30-40px)!
	# Where is the left strip?
	# Is it at x=0..400, y=80..160?
	var l_crop := img.get_region(Rect2i(50, 80, 300, 80))
	l_crop.save_png("res://references/marked_strip_left_top.png")

	print("Saved marked_strip_right.png and marked_strip_left_top.png")
	quit(0)
