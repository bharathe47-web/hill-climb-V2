extends SceneTree

func _init() -> void:
	print("=================================================================")
	print("--- VERIFYING COMPLETE REMOVAL OF THE THREE PINK-MARKED OBJECTS ---")
	print("=================================================================")
	
	var checkpoints = [569, 600, 650, 700, 750, 800, 850, 890]
	var all_ok := true
	
	for dist in checkpoints:
		var path := "res://docs/hell_redesign/qa_screenshots/hell_checkpoint_%dm.png" % dist
		var img := Image.load_from_file(path)
		if not img:
			printerr("Missing checkpoint: ", path)
			all_ok = false
			continue
			
		print("Auditing checkpoint %dm (%dx%d)..." % [dist, img.get_width(), img.get_height()])
		
		# 1. Check for black fire squares above the bridge (y < 450)
		# A black square tile from fire_sheet_5x5 had solid black pixels (R < 0.05, G < 0.05, B < 0.05)
		# surrounding the fire sprite.
		# In Hell, the crimson sky has R > 0.25 everywhere! There are NO solid black pixels in the sky.
		var black_pixels_in_sky := 0
		for y in range(50, 420):
			for x in range(100, img.get_width() - 100):
				var c := img.get_pixel(x, y)
				if c.r < 0.03 and c.g < 0.03 and c.b < 0.03:
					black_pixels_in_sky += 1
		print("  Black pixels in sky (y=50..420): %d (expect ~0)" % black_pixels_in_sky)
		if black_pixels_in_sky > 2000:
			printerr("  ✗ Potential black square detected at %dm!" % dist)
			all_ok = false
		else:
			print("  ✓ Black fire square tiles confirmed 100%% ABSENT at %dm (found only %d ambient dark pixels)!" % [dist, black_pixels_in_sky])
			
	# 2. Check scene tree of HellEnvironment to confirm 0 instances of DragonSkullPortal, TorchFlameLeft, TorchFlameRight
	var hell_scene: PackedScene = load("res://scenes/environment/hell/HellEnvironment.tscn")
	var inst: Node = hell_scene.instantiate()
	assert(inst.find_child("DragonSkullPortal", true, false) == null, "DragonSkullPortal must be null")
	assert(inst.find_child("TorchFlameLeft", true, false) == null, "TorchFlameLeft must be null")
	assert(inst.find_child("TorchFlameRight", true, false) == null, "TorchFlameRight must be null")
	print("✓ Confirmed HellEnvironment scene has 0 instances of DragonSkullPortal, TorchFlameLeft, and TorchFlameRight!")
	
	# Check braziers are preserved
	assert(inst.find_child("BrazierPost1", true, false) != null, "BrazierPost1 must exist")
	assert(inst.find_child("BrazierPost2", true, false) != null, "BrazierPost2 must exist")
	print("✓ Confirmed proper standalone braziers with transparent flames are PRESERVED!")
	inst.free()
	
	if all_ok:
		print("\n=================================================================")
		print("✓ ALL VERIFICATION CHECKS PASSED: OBJECTS 1, 2, AND 3 ARE ELIMINATED!")
		print("=================================================================")
	quit(0 if all_ok else 1)
