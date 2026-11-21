@tool
extends SceneTree

func _init() -> void:
	var user_img := Image.load_from_file("res://references/hell_cleanup_blue_strips.png")
	user_img.convert(Image.FORMAT_RGBA8)
	var uw := user_img.get_width()
	var uh := user_img.get_height()
	print("User image: %dx%d" % [uw, uh])

	var checkpoints := [
		"569m", "590m", "600m", "650m", "700m", "750m", "800m", "850m", "890m"
	]
	
	# Let's check each checkpoint in docs/hell_redesign/qa_screenshots/
	for cp in checkpoints:
		var path := "res://docs/hell_redesign/qa_screenshots/hell_checkpoint_%s.png" % cp
		var img := Image.load_from_file(path)
		if not img:
			print("Could not load %s" % path)
			continue
		img.convert(Image.FORMAT_RGBA8)
		print("Loaded %s: %dx%d" % [cp, img.get_width(), img.get_height()])

		# Check if the right strip content exists in img
		# We have references/exact_strip_right_content.png (202x45)
		# Let's check region x=1090..1302, y=86..141 in user_img, scaled to img
		# Notice user_img is 1366x768, qa_screenshots is 1280x720!
		# 1366 / 1280 = 1.0671875, 768 / 720 = 1.06666667
		# So scale factor is ~1.067!
		# 1090 / 1.0671875 = 1021, 1302 / 1.0671875 = 1220
		# 86 / 1.06667 = 80, 141 / 1.06667 = 132
	
	# Let's crop x=1000..1240, y=70..150 from hell_checkpoint_600m.png and hell_checkpoint_750m.png
	var cp_600 := Image.load_from_file("res://docs/hell_redesign/qa_screenshots/hell_checkpoint_600m.png")
	if cp_600:
		cp_600.convert(Image.FORMAT_RGBA8)
		var c600_crop := cp_600.get_region(Rect2i(1000, 70, 240, 80))
		c600_crop.save_png("res://references/cp600_strip_region.png")
		print("Saved cp600_strip_region.png")

	# Also crop user_img at x=1080, y=80, w=240, h=80
	var user_crop := user_img.get_region(Rect2i(1080, 80, 240, 80))
	user_crop.save_png("res://references/user_strip_region.png")
	print("Saved user_strip_region.png")

	quit(0)
