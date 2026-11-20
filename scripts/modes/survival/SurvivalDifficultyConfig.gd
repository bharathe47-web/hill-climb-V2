class_name SurvivalDifficultyConfig
extends RefCounted

## SurvivalDifficultyConfig: Centralized configuration and rules for Survival Mode difficulties.
## Dictates hazard spawning, warning markers, asteroid bombardment, and pothole road damage.

enum Difficulty {
	EASY = 0,
	MEDIUM = 1,
	HARD = 2
}

const CONFIG: Dictionary = {
	Difficulty.EASY: {
		"id": Difficulty.EASY,
		"name": "EASY",
		"title": "EASY",
		"description": "Survive the falling obstacles.",
		"food_obstacles": true,
		"food_warnings": true,
		"unburned_asteroids": false,
		"unburned_asteroid_warnings": false,
		"burning_asteroids": false,
		"burning_asteroid_warnings": false,
		"potholes": false,
		"food_spawn_interval_min": 1.6,
		"food_spawn_interval_max": 2.8,
		"unburned_asteroid_interval_min": 0.0,
		"unburned_asteroid_interval_max": 0.0,
		"burning_asteroid_interval_min": 0.0,
		"burning_asteroid_interval_max": 0.0,
		"score_multiplier": 1.0
	},
	Difficulty.MEDIUM: {
		"id": Difficulty.MEDIUM,
		"name": "MEDIUM",
		"title": "MEDIUM",
		"description": "Watch out for unexpected asteroids.",
		"food_obstacles": true,
		"food_warnings": true,
		"unburned_asteroids": true,
		"unburned_asteroid_warnings": false,
		"burning_asteroids": false,
		"burning_asteroid_warnings": false,
		"potholes": false,
		"food_spawn_interval_min": 1.4,
		"food_spawn_interval_max": 2.5,
		"unburned_asteroid_interval_min": 3.0,
		"unburned_asteroid_interval_max": 5.0,
		"burning_asteroid_interval_min": 0.0,
		"burning_asteroid_interval_max": 0.0,
		"score_multiplier": 1.5
	},
	Difficulty.HARD: {
		"id": Difficulty.HARD,
		"name": "HARD",
		"title": "HARD",
		"description": "Survive asteroids, fire and damaged roads.",
		"food_obstacles": true,
		"food_warnings": true,
		"unburned_asteroids": true,
		"unburned_asteroid_warnings": false,
		"burning_asteroids": true,
		"burning_asteroid_warnings": false,
		"potholes": true,
		"food_spawn_interval_min": 1.2,
		"food_spawn_interval_max": 2.2,
		"unburned_asteroid_interval_min": 3.5,
		"unburned_asteroid_interval_max": 5.5,
		"burning_asteroid_interval_min": 2.8,
		"burning_asteroid_interval_max": 4.6,
		"score_multiplier": 2.0
	}
}

static func get_config(diff: int) -> Dictionary:
	if CONFIG.has(diff):
		return CONFIG[diff]
	return CONFIG[Difficulty.EASY]

static func get_difficulty_name(diff: int) -> String:
	var cfg = get_config(diff)
	return String(cfg.get("name", "EASY"))
