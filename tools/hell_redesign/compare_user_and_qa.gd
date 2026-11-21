extends SceneTree

func _init() -> void:
	var user_img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png")
	var qa_img := Image.load_from_file("res://docs/hell_redesign/qa_screenshots/hell_checkpoint_600m.png")
	
	print("User img: %dx%d" % [user_img.get_width(), user_img.get_height()])
	print("QA img: %dx%d" % [qa_img.get_width(), qa_img.get_height()])
	
	# Check if user_img has the exact same scene as qa_img (or similar checkpoint)
	# Check checkpoints: 569m, 600m, 650m
	for dist in [569, 600, 650, 700]:
		var check_path := "res://docs/hell_redesign/qa_screenshots/hell_checkpoint_%dm.png" % dist
		var c_img := Image.load_from_file(check_path)
		if not c_img: continue
		# Resize to match or check correlation
		print("Checking distance %dm..." % dist)
		# Sample center 100x100
		var match_count := 0
		for y in range(200, 400, 5):
			for x in range(300, 600, 5):
				var p1 := user_img.get_pixel(x, y)
				var p2 := c_img.get_pixel(x, y)
				if abs(p1.r - p2.r) < 0.1 and abs(p1.g - p2.g) < 0.1 and abs(p1.b - p2.b) < 0.1:
					match_count += 1
		print("  Matches with checkpoint %dm: %d" % [dist, match_count])
	quit(0)
