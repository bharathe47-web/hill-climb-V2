extends Node

const SAVE_PATH: String = "user://kanyakumari_save.json"

func _ready() -> void:
	load_game()

func save_game() -> void:
	var save_dict: Dictionary = {
		"version": 1,
		"coins": GameState.coins,
		"active_vehicle_id": GameState.active_vehicle_id,
		"unlocked_vehicles": GameState.unlocked_vehicles,
		"active_stage_id": GameState.active_stage_id,
		"unlocked_stages": GameState.unlocked_stages,
		"stage_best_distances": GameState.stage_best_distances,
		"vehicle_upgrades": GameState.vehicle_upgrades,
		"master_volume": GameState.master_volume,
		"music_volume": GameState.music_volume,
		"sfx_volume": GameState.sfx_volume
	}
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_str := JSON.stringify(save_dict, "\t")
		file.store_string(json_str)
		file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	
	var text := file.get_as_text()
	file.close()
	
	var test_json_conv := JSON.new()
	var error := test_json_conv.parse(text)
	if error != OK:
		push_warning("Failed to parse save game JSON: " + test_json_conv.get_error_message())
		return
	
	var data: Variant = test_json_conv.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		return
	
	var dict: Dictionary = data
	GameState.coins = int(dict.get("coins", GameState.coins))
	GameState.active_vehicle_id = str(dict.get("active_vehicle_id", GameState.active_vehicle_id))
	
	if dict.has("unlocked_vehicles"):
		var u_v: Array = dict["unlocked_vehicles"]
		var typed_uv: Array[String] = []
		for v in u_v:
			typed_uv.append(str(v))
		GameState.unlocked_vehicles = typed_uv
	
	GameState.active_stage_id = str(dict.get("active_stage_id", GameState.active_stage_id))
	
	if dict.has("unlocked_stages"):
		var u_s: Array = dict["unlocked_stages"]
		var typed_us: Array[String] = []
		for s in u_s:
			typed_us.append(str(s))
		GameState.unlocked_stages = typed_us
	
	if dict.has("stage_best_distances") and typeof(dict["stage_best_distances"]) == TYPE_DICTIONARY:
		GameState.stage_best_distances = dict["stage_best_distances"]
	
	if dict.has("vehicle_upgrades") and typeof(dict["vehicle_upgrades"]) == TYPE_DICTIONARY:
		for k in dict["vehicle_upgrades"].keys():
			GameState.vehicle_upgrades[k] = dict["vehicle_upgrades"][k]
			
	GameState.master_volume = float(dict.get("master_volume", 1.0))
	GameState.music_volume = float(dict.get("music_volume", 0.8))
	GameState.sfx_volume = float(dict.get("sfx_volume", 0.9))
