extends SceneTree

func _init() -> void:
	var frames = [14, 20, 37, 45, 85, 98]
	for f in frames:
		var p = "/tmp/screencast_frames/frame_%03d.png" % f
		var img = Image.load_from_file(p)
		if img == null: continue
		# crop center (x: 400..950, y: 150..500)
		var crop_center = img.get_region(Rect2i(400, 150, 550, 350))
		crop_center.save_png("/tmp/screencast_frames/crop_center_%03d.png" % f)
		# crop bottom card (x: 350..1000, y: 620..740)
		var crop_btm = img.get_region(Rect2i(350, 620, 650, 120))
		crop_btm.save_png("/tmp/screencast_frames/crop_btm_%03d.png" % f)
	print("Saved cropped regions for inspection.")
	quit()
