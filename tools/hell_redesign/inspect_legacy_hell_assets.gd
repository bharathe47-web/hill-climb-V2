@tool
extends SceneTree

func _init() -> void:
	print("--- INSPECTING POTENTIAL LEGACY ASSETS ---")
	var paths := [
		"res://assets/environments/hell/terrain/hell_volcanic_rock_a.png",
		"res://assets/environments/hell/terrain/hell_volcanic_rock_b.png",
		"res://assets/environments/hell/terrain/hell_volcanic_rock_c.png",
		"res://assets/environments/hell/terrain/hell_basalt_platform.png",
		"res://assets/environments/hell/terrain/broken_basalt_platform_hazard.png",
		"res://assets/environments/hell/decorations/skull_game_obstacle.png",
		"res://assets/environments/hell/characters/flying_dragon/spritesheets/hell_dragon_fly_sheet.png",
		"res://assets/environments/hell/characters/demon_goblin/spritesheets/goblin_fiend_idle_sheet.png",
		"res://assets/environments/hell/characters/horned_fiend/spritesheets/horned_fiend_walk_sheet.png"
	]
	for p in paths:
		var img := Image.load_from_file(p)
		if img:
			print("Asset: ", p.get_file(), " Size: %dx%d" % [img.get_width(), img.get_height()])
		else:
			print("Could not load: ", p)
	quit(0)
