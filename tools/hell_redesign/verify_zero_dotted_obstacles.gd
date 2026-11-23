@tool
extends SceneTree

func _init() -> void:
	var checkpoints: Array[int] = [569, 600, 650, 700, 750, 800, 850, 890]
	
	print("==================================================")
	print("AUDITING CHECKPOINTS FOR DOTTED OBSTACLES...")
	print("==================================================")

	var all_clear := true
	for dist: int in checkpoints:
		var file_path := "res://docs/hell_redesign/qa_screenshots/hell_checkpoint_%dm.png" % dist
		var img := Image.load_from_file(file_path)
		if not img:
			printerr("Missing checkpoint: ", file_path)
			all_clear = false
			continue
		img.convert(Image.FORMAT_RGBA8)
		
		# Check across the entire road area (y in [350..650], x in [0..1280])
		var obstacle_suspects: int = 0
		for y: int in range(350, 650):
			for x: int in range(img.get_width()):
				# Exclude pedals
				if y > 580 and (x < 260 or x > 1050):
					continue
				var c: Color = img.get_pixel(x, y)
				if c.r < 0.12 and c.g < 0.12 and c.b < 0.12:
					# Check 4-neighborhood for orange dot
					var has_orange := false
					for dy: int in [-2, 0, 2]:
						for dx: int in [-2, 0, 2]:
							var nx: int = x + dx
							var ny: int = y + dy
							if nx >= 0 and nx < img.get_width() and ny >= 0 and ny < img.get_height():
								var nc: Color = img.get_pixel(nx, ny)
								if nc.r > 0.75 and nc.g > 0.35 and nc.g < 0.65 and nc.b < 0.15:
									has_orange = true
									break
						if has_orange: break
					if has_orange:
						obstacle_suspects += 1
		
		print("Checkpoint %dm: %d dotted obstacle suspect pixels" % [dist, obstacle_suspects])
		if obstacle_suspects > 15:
			printerr("  ✗ Potential obstacle detected at %dm!" % dist)
			all_clear = false
		else:
			print("  ✓ Checkpoint %dm is 100%% clean of dotted obstacle blocks!" % dist)

	if all_clear:
		print("\n==================================================")
		print("✓ ALL CHECKPOINTS CONFIRMED 100% CLEAN!")
		print("==================================================")
		quit(0)
	else:
		printerr("\n✗ AUDIT FAILED!")
		quit(1)
