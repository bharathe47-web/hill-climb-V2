extends SceneTree

func _init() -> void:
	var frames = [5, 11, 21, 37, 45, 60, 65, 71, 80, 100]
	for f in frames:
		var p = "/tmp/screencast_frames/frame_%03d.png" % f
		var img = Image.load_from_file(p)
		if img == null: continue
		print("\n--- Inspecting Frame %03d (t=%ds) ---" % [f, f])
		# Let's check what is in the center
		# Check if pause menu is open: Pause menu has text "PAUSED" or "RESUME"
		# Let's inspect brightness across key zones
		var center_col = img.get_pixel(683, 384)
		print("  Center pixel (683, 384): ", center_col)
		# Check if dark overlay exists (Pause dialog dims the screen)
		var top_left = img.get_pixel(100, 100)
		print("  Sky pixel (100, 100): ", top_left)
	quit()
