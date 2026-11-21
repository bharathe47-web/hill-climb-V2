extends ParallaxBackground
class_name ParallaxWorld

@export var cloud_drift_speed: float = 12.0

@onready var cloud_layer: ParallaxLayer = $CloudLayer
@onready var sky_layer: ParallaxLayer = $SkyLayer
@onready var sea_layer: ParallaxLayer = $SeaLayer
@onready var islands_layer: ParallaxLayer = $IslandsLayer
@onready var town_layer: ParallaxLayer = $TownLayer

func _ready() -> void:
	# Ensure motion_mirroring is strictly set to texture width (2048.0)
	sky_layer.motion_mirroring = Vector2(2048.0, 0.0)
	cloud_layer.motion_mirroring = Vector2(2048.0, 0.0)
	sea_layer.motion_mirroring = Vector2(2048.0, 0.0)
	islands_layer.motion_mirroring = Vector2(2048.0, 0.0)
	town_layer.motion_mirroring = Vector2(2048.0, 0.0)

func _process(delta: float) -> void:
	# Autonomous cloud drift across the sky
	cloud_layer.motion_offset.x += cloud_drift_speed * delta
	if cloud_layer.motion_offset.x >= 2048.0:
		cloud_layer.motion_offset.x -= 2048.0
