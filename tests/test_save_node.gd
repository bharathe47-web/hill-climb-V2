extends Node2D

func _ready() -> void:
	print("--- Running Test: Save/Load System Persistence ---")
	
	# Set test data
	GameState.coins = 1250
	GameState.active_vehicle_id = "auto_rickshaw"
	GameState.unlock_vehicle("auto_rickshaw")
	GameState.unlock_stage("stage_02_nagercoil")
	GameState.vehicle_upgrades["auto_rickshaw"] = {"engine": 3, "suspension": 2, "tires": 1, "fuel_tank": 1, "nitro": 1}
	GameState.stage_best_distances["stage_01_kanyakumari"] = 840.0
	
	# Save to disk
	SaveSystem.save_game()
	print("Game saved to user://kanyakumari_save.json")
	
	# Wipe in-memory values
	GameState.coins = 0
	GameState.active_vehicle_id = "red_jeep"
	GameState.unlocked_stages = ["stage_01_kanyakumari"]
	GameState.stage_best_distances.clear()
	
	# Reload from disk
	SaveSystem.load_game()
	print("Game loaded. Restored coins: ", GameState.coins)
	print("Restored vehicle: ", GameState.active_vehicle_id)
	print("Restored stages: ", GameState.unlocked_stages)
	print("Restored upgrade lvl: ", GameState.get_upgrade_level("auto_rickshaw", "engine"))
	print("Restored best dist: ", GameState.stage_best_distances.get("stage_01_kanyakumari", 0.0))
	
	assert(GameState.coins == 1250, "Coins must persist across save/load!")
	assert(GameState.active_vehicle_id == "auto_rickshaw", "Active vehicle must persist!")
	assert(GameState.is_stage_unlocked("stage_02_nagercoil"), "Unlocked stage must persist!")
	assert(GameState.get_upgrade_level("auto_rickshaw", "engine") == 3, "Upgrade levels must persist!")
	assert(GameState.stage_best_distances.get("stage_01_kanyakumari", 0.0) == 840.0, "Best distance must persist!")
	
	print("--- Save/Load System Persistence Test PASSED ---")
	get_tree().quit(0)
