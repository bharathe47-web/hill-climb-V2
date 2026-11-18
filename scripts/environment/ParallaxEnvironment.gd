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
	set_physics_process(active)
	_set_node_hierarchy_active(self, active)

func _set_node_hierarchy_active(node: Node, active: bool) -> void:
	for child in node.get_children():
		if child is CanvasItem:
			child.visible = active
			child.modulate.a = 1.0 if active else 0.0
		if child is CanvasLayer:
			child.visible = active
		if child is CPUParticles2D or child is GPUParticles2D:
			child.emitting = active
		if child is AnimatedSprite2D:
			if active:
				child.play()
			else:
				child.pause()
		if child.get_child_count() > 0:
			_set_node_hierarchy_active(child, active)

func reset_environment_state() -> void:
	for child in get_children():
		if child is ParallaxLayer:
			child.motion_offset = Vector2.ZERO
	set_environment_active(true)
