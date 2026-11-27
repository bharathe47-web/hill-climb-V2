class_name RouteData
extends Resource

## RouteData: Encapsulates all data for an Indian State Route.
## Stores ordered waypoints, landmarks, checkpoints, distance, and visual themes.

const WaypointData = preload("res://resources/routes/WaypointData.gd")

@export var state_id: String = "tamil_nadu"
@export var state_name: String = "Tamil Nadu"
@export var start_city: String = "Kanyakumari"
@export var destination_city: String = "Chennai"
@export var total_distance_m: float = 1800.0
@export var description: String = "Drive from Kanyakumari through the Meenakshi Temple city of Madurai to Marina Beach in Chennai along NH44."
@export var state_map_path: String = "res://assets/indian_locations/tamil_nadu_state_map.svg"
@export var state_card_icon_path: String = "res://assets/indian_locations/state_select_tamil_nadu.png"
@export var sky_texture_path: String = "res://assets/indian_roads/indian_sky_tropical.png"
@export var parallax_bg_path: String = "res://assets/indian_roads/indian_parallax_rural_plains.png"
@export var is_unlocked: bool = true
@export var completion_reward_coins: int = 500

@export var waypoints: Array[WaypointData] = []

func get_total_distance_m() -> float:
	return total_distance_m

func get_checkpoint_count() -> int:
	var count := 0
	for wp in waypoints:
		if wp.waypoint_type == WaypointData.WaypointType.CHECKPOINT:
			count += 1
	return count
