class_name WarningIndicator
extends Node2D

## WarningIndicator: Visual indicator projected on ground where a falling food obstacle will land.
## Conforms to SHARED_GAME_INTERFACES.md Section 6.2.

@export var warning_duration: float = 1.0

@onready var shadow_sprite: Sprite2D = $ShadowSprite
@onready var circle_sprite: Sprite2D = $CircleSprite
@onready var marker_sprite: Sprite2D = $MarkerSprite

func _ready() -> void:
	pass

func start_warning(duration: float) -> void:
	warning_duration = maxf(0.2, duration)

	modulate.a = 0.0
	scale = Vector2(0.6, 0.6)

	var tw := create_tween()
	# Fade in and grow
	tw.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
	tw.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Pulse and intensify danger color
	var pulse_count := maxi(1, int(warning_duration / 0.22))
	for i in range(pulse_count):
		if is_instance_valid(circle_sprite):
			tw.tween_property(circle_sprite, "modulate", Color(1.0, 0.15, 0.15, 1.0), 0.11)
		tw.parallel().tween_property(self, "scale", Vector2(1.18, 1.18), 0.11)
		if is_instance_valid(circle_sprite):
			tw.tween_property(circle_sprite, "modulate", Color(1.0, 0.75, 0.2, 0.85), 0.11)
		tw.parallel().tween_property(self, "scale", Vector2(0.92, 0.92), 0.11)

	# Final fade out and cleanup
	tw.tween_property(self, "modulate:a", 0.0, 0.15)
	tw.tween_callback(queue_free)
