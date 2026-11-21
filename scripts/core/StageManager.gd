extends Node

const StageDataScript = preload("res://scripts/data/StageData.gd")

signal checkpoint_reached(checkpoint_data: Dictionary)
signal stage_completed(stage_data: Resource)

var current_stage: Resource
var passed_checkpoints: Array[int] = []
var stage_cache: Dictionary = {}

const STAGE_PATHS: Dictionary = {
	"stage_01_kanyakumari": "res://data/stages/stage_01_kanyakumari.tres",
	"stage_02_nagercoil": "res://data/stages/stage_02_nagercoil.tres",
	"stage_03_tirunelveli": "res://data/stages/stage_03_tirunelveli.tres",
	"stage_04_madurai": "res://data/stages/stage_04_madurai.tres",
	"stage_05_trichy": "res://data/stages/stage_05_trichy.tres",
	"stage_06_villupuram": "res://data/stages/stage_06_villupuram.tres",
	"stage_07_chennai": "res://data/stages/stage_07_chennai.tres"
}

const STAGE_ORDER: Array[String] = [
	"stage_01_kanyakumari",
	"stage_02_nagercoil",
	"stage_03_tirunelveli",
	"stage_04_madurai",
	"stage_05_trichy",
	"stage_06_villupuram",
	"stage_07_chennai"
]

func _ready() -> void:
	load_active_stage()

func load_active_stage() -> Resource:
	var stage_id: String = GameState.active_stage_id
	if not STAGE_PATHS.has(stage_id):
		stage_id = "stage_01_kanyakumari"
		GameState.active_stage_id = stage_id
	
	if stage_cache.has(stage_id):
		current_stage = stage_cache[stage_id]
	elif ResourceLoader.exists(STAGE_PATHS[stage_id]):
		current_stage = load(STAGE_PATHS[stage_id])
		stage_cache[stage_id] = current_stage
	else:
		# Fallback default stage if resource not yet saved to disk
		current_stage = StageDataScript.new()
		current_stage.id = stage_id
		stage_cache[stage_id] = current_stage
		
	passed_checkpoints.clear()
	return current_stage

func check_progress(distance_meters: float) -> void:
	if not current_stage:
		return
		
	# Check checkpoints
	for i in range(current_stage.checkpoints.size()):
		if i in passed_checkpoints:
			continue
		var cp: Dictionary = current_stage.checkpoints[i]
		if distance_meters >= cp.get("distance", 99999.0):
			passed_checkpoints.append(i)
			checkpoint_reached.emit(cp)
			# Refill 35% fuel on checkpoint!
			GameState.add_fuel(0.35)
			AudioManager.play_sfx("fuel", 1.2)
			break
			
	# Check stage completion
	if distance_meters >= current_stage.length_meters and not GameState.is_game_over:
		unlock_next_stage()
		stage_completed.emit(current_stage)

func unlock_next_stage() -> void:
	var current_idx := STAGE_ORDER.find(GameState.active_stage_id)
	if current_idx != -1 and current_idx + 1 < STAGE_ORDER.size():
		var next_id := STAGE_ORDER[current_idx + 1]
		GameState.unlock_stage(next_id)

func get_stage_data(stage_id: String) -> Resource:
	if stage_cache.has(stage_id):
		return stage_cache[stage_id]
	if STAGE_PATHS.has(stage_id) and ResourceLoader.exists(STAGE_PATHS[stage_id]):
		var s: Resource = load(STAGE_PATHS[stage_id])
		stage_cache[stage_id] = s
		return s
	return null
