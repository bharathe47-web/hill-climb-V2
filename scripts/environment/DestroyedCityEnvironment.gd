class_name DestroyedCityEnvironment
extends ParallaxBackground

## DestroyedCityEnvironment: Parallax background for the Survival Destroyed City theme.
## Features layered sunset sky, ruined skyline, industrial rubble, transmission towers,
## and atmospheric haze with zero interference to vehicle physics and ground collision.

@export var cloud_drift_speed: float = 12.0
@export var enable_dust_drift: bool = true

@onready var cloud_layer: ParallaxLayer = get_node_or_null("CloudLayer")
@onready var smoke_layer: ParallaxLayer = get_node_or_null("DistantSkylineLayer")

func _process(delta: float) -> void:
	if is_instance_valid(cloud_layer):
		cloud_layer.motion_offset.x += cloud_drift_speed * delta
