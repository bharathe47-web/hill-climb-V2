class_name ParallaxEnvironment
extends ParallaxBackground

## ParallaxEnvironment: Multi-layered 2D parallax environment system.
## Provides sky, animated clouds, distant mountains, mid hills, and near scenery
## with accurate depth scaling and optional gentle atmospheric drift.

@export var enable_cloud_drift: bool = true
@export var cloud_drift_speed: float = 12.0 # Pixels per second horizontal drift

@onready var clouds_layer: ParallaxLayer = get_node_or_null("CloudsLayer")
@onready var distant_clouds_layer: ParallaxLayer = get_node_or_null("DistantCloudsLayer")
@onready var atmosphere_haze: Polygon2D = get_node_or_null("SkyLayer/AtmosphereHaze")
@onready var mountain_range: Polygon2D = get_node_or_null("DistantMountainsLayer/MountainRange")
@onready var hills_body: Polygon2D = get_node_or_null("MidHillsLayer/HillsBody")
@onready var near_hills_body: Polygon2D = get_node_or_null("NearHillsLayer/NearHillsBody")

func _process(delta: float) -> void:
	if enable_cloud_drift:
		if clouds_layer:
			clouds_layer.motion_offset.x += cloud_drift_speed * delta
		if distant_clouds_layer:
			distant_clouds_layer.motion_offset.x += (cloud_drift_speed * 0.4) * delta

func set_biome_theme(biome_type: int) -> void:
	match biome_type:
		1: # HEAVEN
			if atmosphere_haze:
				atmosphere_haze.color = Color(0.92, 0.96, 1.0, 0.55)
			if mountain_range:
				mountain_range.color = Color(0.82, 0.88, 0.98, 0.85)
			if hills_body:
				hills_body.color = Color(0.68, 0.80, 0.95, 0.85)
			if near_hills_body:
				near_hills_body.color = Color(0.58, 0.72, 0.90, 0.85)
		2: # HELL
			if atmosphere_haze:
				atmosphere_haze.color = Color(0.85, 0.22, 0.05, 0.45)
			if mountain_range:
				mountain_range.color = Color(0.24, 0.12, 0.14, 0.95)
			if hills_body:
				hills_body.color = Color(0.18, 0.08, 0.10, 0.95)
			if near_hills_body:
				near_hills_body.color = Color(0.14, 0.06, 0.07, 0.95)
		_: # COUNTRYSIDE / NORMAL LAND
			if atmosphere_haze:
				atmosphere_haze.color = Color(0.72, 0.84, 0.96, 0.35)
			if mountain_range:
				mountain_range.color = Color(0.55, 0.62, 0.72, 0.95)
			if hills_body:
				hills_body.color = Color(0.38, 0.46, 0.52, 0.95)
			if near_hills_body:
				near_hills_body.color = Color(0.28, 0.34, 0.38, 0.95)


