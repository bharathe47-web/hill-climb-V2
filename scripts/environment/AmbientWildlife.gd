class_name AmbientWildlife
extends Node2D

## AmbientWildlife: Lightweight controller for ambient aerial creatures (e.g. Doves, Dragons).
## Provides continuous loop animation, gentle sine-wave bobbing/drift, offscreen culling,
## and zero collision interaction with the player's vehicle.

@export var creature_name: String = "Wildlife"
@export var animation_name: String = "fly"
@export var bob_amplitude: float = 8.0 # Vertical oscillation in pixels
@export var bob_frequency: float = 2.0 # Oscillation speed (rad/s)
@export var forward_drift_speed: float = 0.0 # Horizontal flight drift

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var notifier: VisibleOnScreenNotifier2D = get_node_or_null("VisibleOnScreenNotifier2D")

var _spawn_y: float = 0.0
var _elapsed: float = 0.0
var _is_on_screen: bool = true

func _ready() -> void:
	_spawn_y = position.y
	
	if not is_instance_valid(notifier):
		notifier = VisibleOnScreenNotifier2D.new()
		notifier.rect = Rect2(-100, -100, 200, 200)
		add_child(notifier)
		
	if not notifier.screen_entered.is_connected(_on_screen_entered):
		notifier.screen_entered.connect(_on_screen_entered)
	if not notifier.screen_exited.is_connected(_on_screen_exited):
		notifier.screen_exited.connect(_on_screen_exited)
		
	if not is_instance_valid(sprite):
		sprite = get_node_or_null("AnimatedSprite2D")
		
	if is_instance_valid(sprite) and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation(animation_name):
			sprite.play(animation_name)

func _process(delta: float) -> void:
	if not _is_on_screen:
		return
		
	_elapsed += delta
	if bob_amplitude > 0.0:
		position.y = _spawn_y + sin(_elapsed * bob_frequency) * bob_amplitude
		
	if forward_drift_speed != 0.0:
		position.x += forward_drift_speed * delta

func set_wildlife_active(active: bool) -> void:
	visible = active
	set_process(active and _is_on_screen)
	if is_instance_valid(sprite):
		if active and _is_on_screen:
			sprite.play()
		else:
			sprite.pause()

func _on_screen_entered() -> void:
	_is_on_screen = true
	set_process(true)
	if is_instance_valid(sprite):
		sprite.play()

func _on_screen_exited() -> void:
	_is_on_screen = false
	set_process(false)
	if is_instance_valid(sprite):
		sprite.pause()
