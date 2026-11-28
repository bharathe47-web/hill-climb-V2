class_name WaypointData
extends Resource

## WaypointData: Defines an ordered milestone, landmark, checkpoint, or destination along an Indian Road route.

enum WaypointType {
	START,
	LANDMARK,
	CHECKPOINT,
	DESTINATION
}

@export var id: String = ""
@export var title: String = ""
@export var subtitle: String = ""
@export var distance_m: float = 0.0
@export var waypoint_type: WaypointType = WaypointType.LANDMARK
@export var landmark_texture_path: String = ""
@export var landmark_scale: float = 1.0
@export var announcement_text: String = ""
@export var coins_reward: int = 25
