class_name HellEnvironment
extends ParallaxBackground

## HellEnvironment: Reusable 2D infernal volcanic environment for Godot 4.7.2.
## Features layered volcanic backdrop, basalt columns, crags, giant dragon skull portal,
## molten lava flow with thermal shimmer, brazier torches, and ambient hell characters.
## Designed for zero collision interference with Endless Map vehicle driving lane.

@export var is_active: bool = true:
	set(value):
		if is_active != value:
			is_active = value
			set_environment_active(value)

@export var enable_smoke_drift: bool = true
@export var smoke_drift_speed: float = 6.0 # Horizontal ash/smoke drift in px/s

@onready var distant_crags_layer: ParallaxLayer = get_node_or_null("DistantCragsLayer")
@onready var cinders_vfx: CPUParticles2D = get_node_or_null("LavaThermalLayer/FloatingCinders")

func _ready() -> void:
	_setup_visibility_culling()
	_start_animations()

func _process(delta: float) -> void:
	if not is_active:
		return
	
	if enable_smoke_drift and distant_crags_layer:
		distant_crags_layer.motion_offset.x += smoke_drift_speed * delta

func _setup_visibility_culling() -> void:
	for node in find_children("*", "AnimatedSprite2D", true, false):
		var anim_sprite := node as AnimatedSprite2D
		if anim_sprite:
			var notifier := anim_sprite.get_node_or_null("VisibleOnScreenNotifier2D") as VisibleOnScreenNotifier2D
			if not is_instance_valid(notifier):
				notifier = VisibleOnScreenNotifier2D.new()
				notifier.name = "VisibleOnScreenNotifier2D"
				notifier.rect = Rect2(-100, -100, 200, 200)
				anim_sprite.add_child(notifier)
				
			if not notifier.screen_entered.is_connected(_on_sprite_screen_entered.bind(anim_sprite)):
				notifier.screen_entered.connect(_on_sprite_screen_entered.bind(anim_sprite))
			if not notifier.screen_exited.is_connected(_on_sprite_screen_exited.bind(anim_sprite)):
				notifier.screen_exited.connect(_on_sprite_screen_exited.bind(anim_sprite))

func _on_sprite_screen_entered(anim_sprite: AnimatedSprite2D) -> void:
	if is_active and is_instance_valid(anim_sprite):
		anim_sprite.play()

func _on_sprite_screen_exited(anim_sprite: AnimatedSprite2D) -> void:
	if is_instance_valid(anim_sprite):
		anim_sprite.pause()

func _start_animations() -> void:
	for node in find_children("*", "AnimatedSprite2D", true, false):
		var anim_sprite := node as AnimatedSprite2D
		if anim_sprite and not anim_sprite.is_playing():
			anim_sprite.play()

func set_environment_active(active: bool) -> void:
	if is_active != active:
		is_active = active
	visible = active
	set_process(active)
	set_physics_process(active)
	
	for child in get_children():
		if child is CanvasItem:
			child.visible = active
			child.modulate.a = 1.0 if active else 0.0

	# Manage particle emissions to preserve mobile fill-rate
	for node in find_children("*", "CPUParticles2D", true, false):
		var cpu_particles := node as CPUParticles2D
		if cpu_particles:
			cpu_particles.emitting = active
			
	for node in find_children("*", "GPUParticles2D", true, false):
		var gpu_particles := node as GPUParticles2D
		if gpu_particles:
			gpu_particles.emitting = active

	# Manage animated sprites playback
	for node in find_children("*", "AnimatedSprite2D", true, false):
		var anim_sprite := node as AnimatedSprite2D
		if anim_sprite:
			if active:
				anim_sprite.play()
			else:
				anim_sprite.pause()

func reset_environment_state() -> void:
	for child in get_children():
		if child is ParallaxLayer:
			child.motion_offset = Vector2.ZERO
	set_environment_active(false)
