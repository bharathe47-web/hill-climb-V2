class_name SaveManager
extends RefCounted

## SaveManager: Centralized save & load persistence for Hill Climb 2D.
## Manages high scores, collected coins, upgrade tiers, and settings in user://savegame.json.

const DEFAULT_SAVE_PATH: String = "user://savegame.json"

const DEFAULT_SAVE_DATA: Dictionary = {
	"version": 1,
	"best_distance": 0.0,
	"total_coins": 0,
	"runs_played": 0,
	"sound_volume": 1.0,
	"music_volume": 1.0,
	"selected_vehicle_id": "blue_flame_truck",
	"unlocked_vehicles": ["blue_flame_truck"],
	"completed_routes": [],
	"discovered_landmarks": [],
	"upgrades": {
		"engine": 1,
		"tires": 1,
		"suspension": 1,
		"fuel_tank": 1,
		"nitro": 1
	},
	"vehicle_upgrades": {
		"blue_flame_truck": {"engine": 1, "tires": 1, "suspension": 1, "fuel_tank": 1, "nitro": 1},
		"orc_racer": {"engine": 1, "tires": 1, "suspension": 1, "fuel_tank": 1, "nitro": 1},
		"trophy_truck": {"engine": 1, "tires": 1, "suspension": 1, "fuel_tank": 1, "nitro": 1},
		"dune_buggy": {"engine": 1, "tires": 1, "suspension": 1, "fuel_tank": 1, "nitro": 1}
	}
}

## Optional custom path for isolated testing
static var custom_save_path: String = ""

static func get_save_path() -> String:
	if not custom_save_path.is_empty():
		return custom_save_path
	return DEFAULT_SAVE_PATH

static func load_save() -> Dictionary:
	var path := get_save_path()
	if not FileAccess.file_exists(path):
		return DEFAULT_SAVE_DATA.duplicate(true)
	
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_warning("SaveManager: Failed to open save file for read at %s" % path)
		return DEFAULT_SAVE_DATA.duplicate(true)
	
	var text := file.get_as_text()
	file.close()
	
	var json_data = JSON.parse_string(text)
	if not (json_data is Dictionary):
		push_warning("SaveManager: Save data corrupted or invalid at %s, using defaults." % path)
		return DEFAULT_SAVE_DATA.duplicate(true)
	
	# Merge loaded data with defaults to ensure all required keys exist
	var merged := DEFAULT_SAVE_DATA.duplicate(true)
	for key in json_data.keys():
		merged[key] = json_data[key]
		
	return merged

static func save_game(data: Dictionary) -> bool:
	var path := get_save_path()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: Failed to open save file for write at %s" % path)
		return false
	
	var json_string := JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	return true

static func get_best_distance() -> float:
	var data := load_save()
	return float(data.get("best_distance", 0.0))

static func get_total_coins() -> int:
	var data := load_save()
	return int(data.get("total_coins", 0))

static func get_runs_played() -> int:
	var data := load_save()
	return int(data.get("runs_played", 0))

static func get_selected_vehicle_id() -> String:
	var data := load_save()
	var val: String = str(data.get("selected_vehicle_id", "blue_flame_truck"))
	var valid_ids := VehicleRegistry.get_vehicle_ids()
	if val in valid_ids:
		return val
	return valid_ids[0] if not valid_ids.is_empty() else "blue_flame_truck"

static func set_selected_vehicle_id(vehicle_id: String) -> bool:
	var valid_ids := VehicleRegistry.get_vehicle_ids()
	var default_id := valid_ids[0] if not valid_ids.is_empty() else "blue_flame_truck"
	var target_id := vehicle_id if vehicle_id in valid_ids else default_id
	var data := load_save()
	data["selected_vehicle_id"] = target_id
	return save_game(data)

static func record_run(distance: float, coins: int) -> Dictionary:
	var data := load_save()
	data["runs_played"] = int(data.get("runs_played", 0)) + 1
	data["total_coins"] = int(data.get("total_coins", 0)) + maxi(0, coins)
	
	var prev_best: float = float(data.get("best_distance", 0.0))
	var is_new_record: bool = false
	if distance > prev_best:
		data["best_distance"] = distance
		is_new_record = true
	
	save_game(data)
	return {
		"is_new_record": is_new_record,
		"best_distance": float(data["best_distance"]),
		"total_coins": int(data["total_coins"]),
		"runs_played": int(data["runs_played"])
	}

static func reset_save() -> bool:
	var path := get_save_path()
	if FileAccess.file_exists(path):
		var dir := DirAccess.open("user://")
		if dir:
			dir.remove(path.get_file())
	return save_game(DEFAULT_SAVE_DATA.duplicate(true))

# --- PROGRESSION & UNLOCK EXTENSIONS ---

static func is_vehicle_unlocked(vehicle_id: String) -> bool:
	if vehicle_id == "blue_flame_truck":
		return true
	var data := load_save()
	var list: Array = data.get("unlocked_vehicles", [])
	return vehicle_id in list

static func unlock_vehicle(vehicle_id: String) -> bool:
	var data := load_save()
	var list: Array = data.get("unlocked_vehicles", [])
	if not (vehicle_id in list):
		list.append(vehicle_id)
		data["unlocked_vehicles"] = list
		return save_game(data)
	return true

static func add_coins(amount: int) -> bool:
	if amount <= 0:
		return true
	var data := load_save()
	data["total_coins"] = int(data.get("total_coins", 0)) + amount
	return save_game(data)

static func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return true
	var data := load_save()
	var current: int = int(data.get("total_coins", 0))
	if current >= amount:
		data["total_coins"] = current - amount
		return save_game(data)
	return false

static func get_upgrade_level(vehicle_id: String, stat_key: String) -> int:
	var data := load_save()
	var v_upgrades: Dictionary = data.get("vehicle_upgrades", {})
	if v_upgrades.has(vehicle_id):
		var stats: Dictionary = v_upgrades[vehicle_id]
		return int(stats.get(stat_key, 1))
	var common: Dictionary = data.get("upgrades", {})
	return int(common.get(stat_key, 1))

static func upgrade_vehicle_stat(vehicle_id: String, stat_key: String) -> bool:
	var current_lvl := get_upgrade_level(vehicle_id, stat_key)
	if current_lvl >= 5:
		return false
	var cost := VehicleRegistry.get_upgrade_cost(current_lvl)
	if not spend_coins(cost):
		return false
	var data := load_save()
	if not data.has("vehicle_upgrades"):
		data["vehicle_upgrades"] = {}
	if not data["vehicle_upgrades"].has(vehicle_id):
		data["vehicle_upgrades"][vehicle_id] = {"engine": 1, "tires": 1, "suspension": 1, "fuel_tank": 1, "nitro": 1}
	data["vehicle_upgrades"][vehicle_id][stat_key] = current_lvl + 1
	# Also update common fallback
	if not data.has("upgrades"):
		data["upgrades"] = {}
	data["upgrades"][stat_key] = current_lvl + 1
	return save_game(data)

static func mark_route_completed(state_id: String) -> bool:
	var data := load_save()
	var routes: Array = data.get("completed_routes", [])
	if not (state_id in routes):
		routes.append(state_id)
		data["completed_routes"] = routes
		return save_game(data)
	return true

static func is_route_completed(state_id: String) -> bool:
	var data := load_save()
	var routes: Array = data.get("completed_routes", [])
	return state_id in routes

static func mark_landmark_discovered(landmark_id: String) -> bool:
	var data := load_save()
	var landmarks: Array = data.get("discovered_landmarks", [])
	if not (landmark_id in landmarks):
		landmarks.append(landmark_id)
		data["discovered_landmarks"] = landmarks
		return save_game(data)
	return true

static func is_landmark_discovered(landmark_id: String) -> bool:
	var data := load_save()
	var landmarks: Array = data.get("discovered_landmarks", [])
	return landmark_id in landmarks
