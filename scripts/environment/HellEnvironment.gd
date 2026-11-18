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

@export var enable_dragon_patrol: bool = true
@export var dragon_patrol_speed: float = 55.0 # Ambient dragon flight speed

@export var enable_character_patrol: bool = true
@export var patrol_range: float = 35.0 # Platform-bounded patrol distance
@export var patrol_speed: float = 25.0 # Patrol speed in px/s

@onready var distant_crags_layer: ParallaxLayer = get_node_or_null("DistantCragsLayer")
@onready var ambient_dragon_layer: ParallaxLayer = get_node_or_null("AmbientDragonLayer")
@onready var cinders_vfx: CPUParticles2D = get_node_or_null("LavaThermalLayer/FloatingCinders")
@onready var skeleton_knight: AnimatedSprite2D = get_node_or_null("AmbientCharactersLayer/SkeletonKnight")
@onready var demon_goblin: AnimatedSprite2D = get_node_or_null("AmbientCharactersLayer/DemonGoblin")

var _skeleton_base_x: float = 1020.0
var _goblin_base_x: float = 1580.0
var _patrol_time: float = 0.0

func _ready() -> void:
	if is_instance_valid(skeleton_knight):
		_skeleton_base_x = skeleton_knight.position.x
	if is_instance_valid(demon_goblin):
		_goblin_base_x = demon_goblin.position.x
		
	_setup_visibility_culling()
	_start_animations()

func _process(delta: float) -> void:
	if not is_active:
		return
	
	if enable_smoke_drift and distant_crags_layer:
		distant_crags_layer.motion_offset.x += smoke_drift_speed * delta
		
	if enable_dragon_patrol and ambient_dragon_layer:
		ambient_dragon_layer.motion_offset.x += dragon_patrol_speed * delta

	if enable_character_patrol:
		_patrol_time += delta * (patrol_speed / patrol_range)
		var offset := sin(_patrol_time) * patrol_range
		var vel_dir := cos(_patrol_time)
		
		if is_instance_valid(skeleton_knight):
			skeleton_knight.position.x = _skeleton_base_x + offset
			skeleton_knight.flip_h = (vel_dir < 0.0)
			if skeleton_knight.sprite_frames and skeleton_knight.sprite_frames.has_animation("walk"):
				if skeleton_knight.animation != &"walk":
					skeleton_knight.play("walk")

		if is_instance_valid(demon_goblin):
			# Offset goblin cycle phase so they don't patrol in unison
			var gob_offset := sin(_patrol_time + PI) * patrol_range
			demon_goblin.position.x = _goblin_base_x + gob_offset
			demon_goblin.flip_h = (cos(_patrol_time + PI) < 0.0)
			if demon_goblin.sprite_frames and demon_goblin.sprite_frames.has_animation("walk"):
				if demon_goblin.animation != &"walk":
					demon_goblin.play("walk")

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
