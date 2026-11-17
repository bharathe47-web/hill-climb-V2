class_name ParallaxEnvironment
extends ParallaxBackground

## ParallaxEnvironment: Multi-layered 2D parallax environment system.
## Provides sky, animated clouds, distant mountains, mid hills, and near scenery
## with accurate depth scaling and optional gentle atmospheric drift.

@export var is_active: bool = true:
	set(value):
		if is_active != value:
			is_active = value
			set_environment_active(value)

@export var enable_cloud_drift: bool = true
@export var cloud_drift_speed: float = 12.0 # Pixels per second horizontal drift

@onready var clouds_layer: ParallaxLayer = get_node_or_null("CloudsLayer")
@onready var distant_clouds_layer: ParallaxLayer = get_node_or_null("DistantCloudsLayer")

func _process(delta: float) -> void:
	if not is_active:
		return
	if enable_cloud_drift:
		if clouds_layer:
			clouds_layer.motion_offset.x += cloud_drift_speed * delta
		if distant_clouds_layer:
			distant_clouds_layer.motion_offset.x += (cloud_drift_speed * 0.4) * delta

func set_environment_active(active: bool) -> void:
	if is_active != active:
		is_active = active
	visible = active
	set_process(active)
