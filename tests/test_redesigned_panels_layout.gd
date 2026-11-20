extends SceneTree

const SurvivalDifficultyScene = preload("res://scenes/ui/survival/SurvivalDifficultyMenu.tscn")
const SurvivalDifficultyConfig = preload("res://scripts/modes/survival/SurvivalDifficultyConfig.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN REDESIGNED DIFFICULTY INFO PANELS TEST ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var win = root
	var menu = SurvivalDifficultyScene.instantiate()
	win.add_child(menu)
	
	for i in range(10):
		await process_frame
		
	# 1. Verify existence of cards and panels
	print("-> [1/4] Verifying Wooden Signboards and Info Panels...")
	assert(menu.easy_card != null, "EasyCard must exist")
	assert(menu.medium_card != null, "MediumCard must exist")
	assert(menu.hard_card != null, "HardCard must exist")
	
	var easy_panel = menu.easy_card.find_child("EasyInfoPanel", true, false)
	var med_panel = menu.medium_card.find_child("MediumInfoPanel", true, false)
	var hard_panel = menu.hard_card.find_child("HardInfoPanel", true, false)
	
	assert(easy_panel != null, "EasyInfoPanel must exist")
	assert(med_panel != null, "MediumInfoPanel must exist")
	assert(hard_panel != null, "HardInfoPanel must exist")
	
	var easy_sc = menu.easy_card.find_child("SignboardContainer", true, false)
	var med_sc = menu.medium_card.find_child("SignboardContainer", true, false)
	var hard_sc = menu.hard_card.find_child("SignboardContainer", true, false)
	
	assert(easy_sc != null, "SignboardContainer must exist for Easy")
	assert(med_sc != null, "SignboardContainer must exist for Medium")
	assert(hard_sc != null, "SignboardContainer must exist for Hard")
	print("  ✓ All 3 cards contain both SignboardContainer and InfoPanel!")

	# 2. Verify non-overlapping layout (VBox vertical separation)
	print("\n-> [2/4] Verifying Non-Overlapping Layout & Vertical Positioning...")
	# In CardVBox, SignboardContainer is child 0, InfoPanel is child 1.
	# InfoPanel y-position must be strictly below SignboardContainer!
	print("  • Easy signboard y: ", easy_sc.position.y, " height: ", easy_sc.size.y, " | panel y: ", easy_panel.position.y)
	assert(easy_panel.position.y >= easy_sc.position.y + easy_sc.size.y, "Easy info panel must sit strictly below signboard")
	assert(med_panel.position.y >= med_sc.position.y + med_sc.size.y, "Medium info panel must sit strictly below signboard")
	assert(hard_panel.position.y >= hard_sc.position.y + hard_sc.size.y, "Hard info panel must sit strictly below signboard")
	print("  ✓ Verified: Info panels sit completely below signboards with ZERO overlap!")

	# 3. Verify Content and Text in Info Panels
	print("\n-> [3/4] Verifying Content (Badges, Multipliers, Descriptions, Hazards)...")
	var easy_badge = easy_panel.find_child("BadgeLabel", true, false)
	var easy_mult = easy_panel.find_child("MultiplierLabel", true, false)
	var easy_desc = easy_panel.find_child("DescLabel", true, false)
	var easy_obs = easy_panel.find_child("ObstaclesLabel", true, false)
	
	assert(easy_badge != null and "LEVEL 1" in easy_badge.text, "Easy has LEVEL 1 badge")
	assert(easy_mult != null and "1.0x" in easy_mult.text, "Easy has 1.0x multiplier")
	assert(easy_desc != null and easy_desc.text.length() > 0, "Easy has description")
	assert(easy_obs != null and "Indian Street Foods" in easy_obs.text, "Easy has obstacles listed")

	var hard_badge = hard_panel.find_child("BadgeLabel", true, false)
	var hard_mult = hard_panel.find_child("MultiplierLabel", true, false)
	var hard_obs = hard_panel.find_child("ObstaclesLabel", true, false)
	assert(hard_badge != null and "LEVEL 3" in hard_badge.text, "Hard has LEVEL 3 badge")
	assert(hard_mult != null and "2.0x" in hard_mult.text, "Hard has 2.0x multiplier")
	assert(hard_obs != null and "Burning Asteroids" in hard_obs.text, "Hard has burning asteroids listed")
	print("  ✓ All labels, multipliers, descriptions, and hazard bullets verified!")

	# 4. Test Selection Highlighting on Panels
	print("\n-> [4/4] Verifying Dynamic Selection Highlight on Info Panels...")
	menu.select_difficulty(SurvivalDifficultyConfig.Difficulty.EASY, false)
	assert(menu.easy_highlight.visible == true, "Easy signboard highlight visible")
	assert(menu.medium_highlight.visible == false, "Medium signboard highlight hidden")
	assert(menu.hard_highlight.visible == false, "Hard signboard highlight hidden")

	menu.select_difficulty(SurvivalDifficultyConfig.Difficulty.MEDIUM, false)
	assert(menu.easy_highlight.visible == false, "Easy signboard highlight hidden")
	assert(menu.medium_highlight.visible == true, "Medium signboard highlight visible")
	assert(menu.hard_highlight.visible == false, "Hard signboard highlight hidden")

	menu.select_difficulty(SurvivalDifficultyConfig.Difficulty.HARD, false)
	assert(menu.easy_highlight.visible == false, "Easy signboard highlight hidden")
	assert(menu.medium_highlight.visible == false, "Medium signboard highlight hidden")
	assert(menu.hard_highlight.visible == true, "Hard signboard highlight visible")
	print("  ✓ Selection switching and highlights fully functional!")

	print("\n=================================================================")
	print("✓ ALL REDESIGNED DIFFICULTY INFO PANEL TESTS PASSED 100%!")
	print("=================================================================\n")
	
	menu.queue_free()
	quit(0)
