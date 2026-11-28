extends Node

signal coins_changed(total_coins: int)
signal run_coins_changed(run_coins: int)
signal fuel_changed(current: float, max_val: float)
signal nitro_changed(current: float, max_val: float)
signal vehicle_upgraded(vehicle_id: String, stat: String, level: int)
signal stage_unlocked(stage_id: String)
signal vehicle_unlocked(vehicle_id: String)
signal game_over_triggered(reason: String, distance: float, coins: int)
signal game_restarted
signal game_resumed

var coins: int = 500
var active_vehicle_id: String = "red_jeep"
var unlocked_vehicles: Array[String] = ["red_jeep"]
var active_stage_id: String = "stage_01_kanyakumari"
var unlocked_stages: Array[String] = ["stage_01_kanyakumari"]
var stage_best_distances: Dictionary = {}

# Upgrade levels 1 to 5
var vehicle_upgrades: Dictionary = {
	"red_jeep": {"engine": 1, "suspension": 1, "tires": 1, "fuel_tank": 1, "nitro": 1},
	"auto_rickshaw": {"engine": 1, "suspension": 1, "tires": 1, "fuel_tank": 1, "nitro": 1},
	"tractor": {"engine": 1, "suspension": 1, "tires": 1, "fuel_tank": 1, "nitro": 1},
	"mini_truck": {"engine": 1, "suspension": 1, "tires": 1, "fuel_tank": 1, "nitro": 1},
	"rally_jeep": {"engine": 1, "suspension": 1, "tires": 1, "fuel_tank": 1, "nitro": 1}
}

# Settings
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9

# Active run variables
var current_distance: float = 0.0
var current_run_coins: int = 0
var current_fuel: float = 100.0
var max_fuel: float = 100.0
var current_nitro: float = 100.0
var max_nitro: float = 100.0
var is_game_over: bool = false
var is_paused: bool = false

# Upgrade cost formula: 100 * level * 1.5
const UPGRADE_BASE_COST: int = 150
const MAX_UPGRADE_LEVEL: int = 5

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func add_coins(amount: int) -> void:
	coins += amount
	current_run_coins += amount
	coins_changed.emit(coins)
	run_coins_changed.emit(current_run_coins)
	SaveSystem.save_game()

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_changed.emit(coins)
		SaveSystem.save_game()
		return true
	return false

func get_upgrade_cost(level: int) -> int:
	if level >= MAX_UPGRADE_LEVEL:
		return 0
	return int(UPGRADE_BASE_COST * (level * 1.6))

func upgrade_vehicle_stat(vehicle_id: String, stat: String) -> bool:
	if not vehicle_upgrades.has(vehicle_id):
		vehicle_upgrades[vehicle_id] = {"engine": 1, "suspension": 1, "tires": 1, "fuel_tank": 1, "nitro": 1}
	
	var current_lvl: int = vehicle_upgrades[vehicle_id].get(stat, 1)
	if current_lvl >= MAX_UPGRADE_LEVEL:
		return false
	
	var cost: int = get_upgrade_cost(current_lvl)
	if spend_coins(cost):
		vehicle_upgrades[vehicle_id][stat] = current_lvl + 1
		vehicle_upgraded.emit(vehicle_id, stat, current_lvl + 1)
		SaveSystem.save_game()
		return true
	return false

func get_upgrade_level(vehicle_id: String, stat: String) -> int:
	if vehicle_upgrades.has(vehicle_id):
		return vehicle_upgrades[vehicle_id].get(stat, 1)
	return 1

func get_upgrade_multiplier(vehicle_id: String, stat: String) -> float:
	var lvl: int = get_upgrade_level(vehicle_id, stat)
	# 1.0 at lvl 1, up to 1.8 at lvl 5
	return 1.0 + (lvl - 1) * 0.2

func unlock_stage(stage_id: String) -> void:
	if not unlocked_stages.has(stage_id):
		unlocked_stages.append(stage_id)
		stage_unlocked.emit(stage_id)
		SaveSystem.save_game()

func is_stage_unlocked(stage_id: String) -> bool:
	return unlocked_stages.has(stage_id)

func unlock_vehicle(vehicle_id: String) -> void:
	if not unlocked_vehicles.has(vehicle_id):
		unlocked_vehicles.append(vehicle_id)
		vehicle_unlocked.emit(vehicle_id)
		SaveSystem.save_game()

func is_vehicle_unlocked(vehicle_id: String) -> bool:
	return unlocked_vehicles.has(vehicle_id)

func set_fuel(val: float) -> void:
	current_fuel = clampf(val, 0.0, max_fuel)
	fuel_changed.emit(current_fuel, max_fuel)

func add_fuel(percent: float) -> void:
	set_fuel(current_fuel + (max_fuel * percent))

func set_nitro(val: float) -> void:
	current_nitro = clampf(val, 0.0, max_nitro)
	nitro_changed.emit(current_nitro, max_nitro)

func reset_run_state() -> void:
	current_distance = 0.0
	current_run_coins = 0
	var fuel_mult: float = get_upgrade_multiplier(active_vehicle_id, "fuel_tank")
	max_fuel = 100.0 * fuel_mult
	current_fuel = max_fuel
	
	var nitro_mult: float = get_upgrade_multiplier(active_vehicle_id, "nitro")
	max_nitro = 100.0 * nitro_mult
	current_nitro = max_nitro
	
	is_game_over = false
	is_paused = false
	fuel_changed.emit(current_fuel, max_fuel)
	nitro_changed.emit(current_nitro, max_nitro)
	run_coins_changed.emit(0)

func record_distance(stage_id: String, distance_m: float) -> void:
	var best: float = stage_best_distances.get(stage_id, 0.0)
	if distance_m > best:
		stage_best_distances[stage_id] = distance_m
		SaveSystem.save_game()

func trigger_game_over(reason: String) -> void:
	if is_game_over:
		return
	is_game_over = true
	record_distance(active_stage_id, current_distance)
	game_over_triggered.emit(reason, current_distance, current_run_coins)
