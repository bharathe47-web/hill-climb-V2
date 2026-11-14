class_name ObstacleWarning
extends Node2D

## ObstacleWarning: Ground warning marker for falling hazard impact points.
## Displays a pulsing warning ring and alert icon on the projected ground coordinates.

@onready var ring_sprite: Sprite2D = get_node_or_null("RingSprite")
@onready var alert_sprite: Sprite2D = get_node_or_null("AlertSprite")

var _warning_timer: float = 0.0
var _warning_duration: float = 1.0
var _active: bool = false
var _pulse_speed: float = 10.0

func _ready() -> void:
	if not _active:
		visible = false

func start_warning(duration: float) -> void:
	_warning_duration = maxf(0.2, duration)
	_warning_timer = _warning_duration
	_active = true
	visible = true
	modulate.a = 1.0
	scale = Vector2(0.6, 0.6)

func _process(delta: float) -> void:
	if not _active:
		return
	
	_warning_timer -= delta
	var progress: float = 1.0 - clampf(_warning_timer / _warning_duration, 0.0, 1.0)
	
	# Pulse faster as impact approaches
	var freq: float = lerpf(8.0, 22.0, progress)
	var pulse: float = (sin(progress * freq * PI) * 0.5) + 0.5
	
	# Scale expands towards impact point
	var base_scale: float = lerpf(0.6, 1.0, progress)
	var s: float = base_scale + pulse * 0.15
	scale = Vector2(s, s * 0.45) # Flat perspective ground ring
	
	# Color shifts from bright orange to flashing danger red
	modulate = Color(1.0, 0.7, 0.2).lerp(Color(1.0, 0.2, 0.15), pulse)
	
	if is_instance_valid(alert_sprite):
		alert_sprite.position.y = -60.0 - (pulse * 15.0) # Hover alert icon
	
	if _warning_timer <= 0.0:
		_complete_warning()

func _complete_warning() -> void:
	_active = false
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", scale * 1.3, 0.15)
	tw.tween_property(self, "modulate:a", 0.0, 0.15)
	tw.chain().tween_callback(queue_free)
