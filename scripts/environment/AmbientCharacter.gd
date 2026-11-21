class_name AmbientCharacter
extends Node2D

## AmbientCharacter: Lightweight controller for environmental/scenery inhabitants.
## Provides idle and walk loops, optional horizontal patrol bounding on safe platforms,
## zero collision interaction with gameplay vehicles, and offscreen culling via
## VisibleOnScreenNotifier2D to optimize mobile fill-rate and CPU overhead.

@export var character_name: String = "AmbientCharacter"
@export var default_animation: String = "idle"
@export var walk_animation: String = "walk"
@export var is_patrolling: bool = false
@export var patrol_range: float = 60.0 # Maximum distance to walk left/right from spawn
@export var patrol_speed: float = 30.0 # Horizontal walk velocity in px/s
@export var face_right_initially: bool = true

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var notifier: VisibleOnScreenNotifier2D = get_node_or_null("VisibleOnScreenNotifier2D")

var _spawn_x: float = 0.0
var _patrol_dir: float = 1.0
var _is_on_screen: bool = true

func _ready() -> void:
	_spawn_x = position.x
	_patrol_dir = 1.0 if face_right_initially else -1.0
	
	if not is_instance_valid(notifier):
		notifier = VisibleOnScreenNotifier2D.new()
		notifier.rect = Rect2(-80, -80, 160, 160)
		add_child(notifier)
		
	if not notifier.screen_entered.is_connected(_on_screen_entered):
		notifier.screen_entered.connect(_on_screen_entered)
	if not notifier.screen_exited.is_connected(_on_screen_exited):
		notifier.screen_exited.connect(_on_screen_exited)
		
	if not is_instance_valid(sprite):
		sprite = get_node_or_null("AnimatedSprite2D")
		
	_apply_animation()

func _apply_animation() -> void:
	if not is_instance_valid(sprite) or not sprite.sprite_frames:
		return
		
	var anim_to_play: String = walk_animation if (is_patrolling and patrol_range > 0.0) else default_animation
	if sprite.sprite_frames.has_animation(anim_to_play):
		sprite.play(anim_to_play)
	elif sprite.sprite_frames.has_animation(default_animation):
		sprite.play(default_animation)
	
	_update_sprite_flip()

func _update_sprite_flip() -> void:
	if is_instance_valid(sprite):
		# When walking right, flip_h is false if sprite faces right by default
		sprite.flip_h = (_patrol_dir < 0.0)

func _process(delta: float) -> void:
	if not _is_on_screen:
		return
		
	if is_patrolling and patrol_range > 0.0:
		position.x += _patrol_dir * patrol_speed * delta
		
		# Platform ledge / patrol boundary checks
		if position.x >= _spawn_x + patrol_range:
			position.x = _spawn_x + patrol_range
			_patrol_dir = -1.0
			_update_sprite_flip()
		elif position.x <= _spawn_x - patrol_range:
			position.x = _spawn_x - patrol_range
			_patrol_dir = 1.0
			_update_sprite_flip()

func set_character_active(active: bool) -> void:
	visible = active
	set_process(active and _is_on_screen)
	if is_instance_valid(sprite):
		if active and _is_on_screen:
			sprite.play()
		else:
			sprite.pause()

func _on_screen_entered() -> void:
	_is_on_screen = true
	set_process(is_patrolling and patrol_range > 0.0)
	if is_instance_valid(sprite):
		sprite.play()

func _on_screen_exited() -> void:
	_is_on_screen = false
	set_process(false)
	if is_instance_valid(sprite):
		sprite.pause()
