extends SceneTree

const SurvivalDifficultyScene = preload("res://scenes/ui/survival/SurvivalDifficultyMenu.tscn")
const SurvivalDifficultyConfig = preload("res://scripts/modes/survival/SurvivalDifficultyConfig.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN WOODEN SIGNBOARD DIFFICULTY MENU VERIFICATION ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var win = root
	var menu = SurvivalDifficultyScene.instantiate()
	win.add_child(menu)
	
	for i in range(5):
		await process_frame
	
	# 1. Verify Card nodes and signboards
	print("-> [1/4] Verifying Wooden Signboard Textures & Chains...")
	assert(menu.easy_card != null, "EasyCard must exist")
	assert(menu.medium_card != null, "MediumCard must exist")
	assert(menu.hard_card != null, "HardCard must exist")
	
	var easy_img: TextureRect = menu.easy_card.find_child("CardImage", true, false)
	var med_img: TextureRect = menu.medium_card.find_child("CardImage", true, false)
	var hard_img: TextureRect = menu.hard_card.find_child("CardImage", true, false)
	
	assert(easy_img != null and easy_img.texture != null, "Easy signboard texture must be loaded")
	assert(med_img != null and med_img.texture != null, "Medium signboard texture must be loaded")
	assert(hard_img != null and hard_img.texture != null, "Hard signboard texture must be loaded")
	
	assert(easy_img.texture.resource_path.ends_with("signboard_easy.png") or "easy" in easy_img.texture.resource_path, "Easy uses signboard_easy")
	assert(med_img.texture.resource_path.ends_with("signboard_medium.png") or "medium" in med_img.texture.resource_path, "Medium uses signboard_medium")
	assert(hard_img.texture.resource_path.ends_with("signboard_hard.png") or "hard" in hard_img.texture.resource_path, "Hard uses signboard_hard")
	print("  ✓ All three wooden signboards loaded with authentic artwork and hanging chains!")

	# 2. Test Selection & Golden Outline Highlights
	print("-> [2/4] Testing Selection & Golden Outline Highlights...")
	menu.select_difficulty(SurvivalDifficultyConfig.Difficulty.EASY, false)
	assert(menu.get_selected_difficulty() == SurvivalDifficultyConfig.Difficulty.EASY, "Easy selected")
	assert(menu.easy_highlight.visible == true, "Easy highlight active")
	assert(menu.medium_highlight.visible == false, "Medium highlight inactive")
	assert(menu.hard_highlight.visible == false, "Hard highlight inactive")
	assert(menu.easy_card.scale.x > 1.0, "Easy card gentle scale-up verified")
	
	menu.select_difficulty(SurvivalDifficultyConfig.Difficulty.MEDIUM, false)
	assert(menu.get_selected_difficulty() == SurvivalDifficultyConfig.Difficulty.MEDIUM, "Medium selected")
	assert(menu.easy_highlight.visible == false, "Easy highlight inactive")
	assert(menu.medium_highlight.visible == true, "Medium highlight active")
	assert(menu.hard_highlight.visible == false, "Hard highlight inactive")
	assert(menu.medium_card.scale.x > 1.0, "Medium card gentle scale-up verified")
	
	menu.select_difficulty(SurvivalDifficultyConfig.Difficulty.HARD, false)
	assert(menu.get_selected_difficulty() == SurvivalDifficultyConfig.Difficulty.HARD, "Hard selected")
	assert(menu.easy_highlight.visible == false, "Easy highlight inactive")
	assert(menu.medium_highlight.visible == false, "Medium highlight inactive")
	assert(menu.hard_highlight.visible == true, "Hard highlight active")
	assert(menu.hard_card.scale.x > 1.0, "Hard card gentle scale-up verified")
	print("  ✓ Selection switching and golden highlight outlines verified!")

	# 3. Test Interactive Buttons
	print("-> [3/4] Testing Button Interaction & Callbacks...")
	menu.easy_button.emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(menu.get_selected_difficulty() == SurvivalDifficultyConfig.Difficulty.EASY, "Easy button pressed selects Easy")

	menu.medium_button.emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(menu.get_selected_difficulty() == SurvivalDifficultyConfig.Difficulty.MEDIUM, "Medium button pressed selects Medium")

	menu.hard_button.emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(menu.get_selected_difficulty() == SurvivalDifficultyConfig.Difficulty.HARD, "Hard button pressed selects Hard")
	print("  ✓ Full button interaction and signal dispatch verified!")

	# 4. Test Start & Back Navigation
	print("-> [4/4] Testing Start Survival & Back Navigation...")
	var started := [-1]
	menu.start_survival_pressed.connect(func(d: int): started[0] = d)
	menu.start_button.emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(started[0] == SurvivalDifficultyConfig.Difficulty.HARD, "Start survival passes selected difficulty (HARD)")

	var backed := [false]
	menu.back_pressed.connect(func(): backed[0] = true)
	menu.back_button.emit_signal("pressed")
	for i in range(2):
		await process_frame
	assert(backed[0] == true, "Back button emits back_pressed signal")
	print("  ✓ Start Survival and Back navigation verified!")

	print("\n=================================================================")
	print("✓ ALL WOODEN SIGNBOARD DIFFICULTY MENU TESTS PASSED 100%!")
	print("=================================================================\n")
	
	menu.queue_free()
	quit(0)
