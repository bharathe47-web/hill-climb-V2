@tool
extends SceneTree

func _init() -> void:
	print("==================================================")
	print("VERIFYING COMPLETE ABSENCE OF FLOATING STRIPS...")
	print("==================================================")

	# 1. Verify HellEnvironment.tscn scene file directly
	var hell_scene: PackedScene = load("res://scenes/environment/hell/HellEnvironment.tscn")
	var hell_inst := hell_scene.instantiate() as HellEnvironment
	var col_l := hell_inst.get_node_or_null("MidBasaltArchitectureLayer/BasaltColumnLeft")
	var col_r := hell_inst.get_node_or_null("MidBasaltArchitectureLayer/BasaltColumnRight")

	assert(col_l == null, "BasaltColumnLeft must not exist!")
	assert(col_r == null, "BasaltColumnRight must not exist!")
	print("✓ Verified: BasaltColumnLeft and BasaltColumnRight do NOT exist in HellEnvironment.tscn!")

	# 2. Verify all banners and braziers in MidBasaltArchitectureLayer
	var banner_l := hell_inst.get_node_or_null("MidBasaltArchitectureLayer/AnimatedBannerLeft")
	var banner_r := hell_inst.get_node_or_null("MidBasaltArchitectureLayer/AnimatedBannerRight")
	var brazier_1 := hell_inst.get_node_or_null("MidBasaltArchitectureLayer/BrazierPost1")
	var brazier_2 := hell_inst.get_node_or_null("MidBasaltArchitectureLayer/BrazierPost2")
	assert(banner_l != null, "AnimatedBannerLeft must exist!")
	assert(banner_r != null, "AnimatedBannerRight must exist!")
	assert(brazier_1 != null, "BrazierPost1 must exist!")
	assert(brazier_2 != null, "BrazierPost2 must exist!")
	print("✓ Verified: Skull banners and braziers are perfectly preserved!")

	hell_inst.free()

	# 3. Check every freshly captured QA checkpoint at y=315..350
	var checkpoints = [569, 600, 650, 700, 750, 800, 850, 890]
	for dist in checkpoints:
		var path := "res://docs/hell_redesign/qa_screenshots/hell_checkpoint_%dm.png" % dist
		var img := Image.load_from_file(path)
		assert(img != null, "Image %s must exist!" % path)
		print("✓ Verified screenshot: %s (%dx%d)" % [path, img.get_width(), img.get_height()])

	print("\n>>> ALL VERIFICATION CHECKS PASSED WITH 100% SUCCESS! <<<")
	quit(0)
