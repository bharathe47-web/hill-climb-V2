class_name HellEnvironment
extends ParallaxBackground

## HellEnvironment: Reusable 2D infernal volcanic environment for Godot 4.7.2.
## Features layered volcanic backdrop, basalt columns, crags, giant dragon skull portal,
## molten lava flow with thermal shimmer, brazier torches, and ambient hell characters.
## Designed for zero collision interference with Endless Map vehicle driving lane.

@export var is_active: bool = true:
	set(value):
		is_active = value
		set_environment_active(value)

@export var enable_smoke_drift: bool = true
@export var smoke_drift_speed: float = 6.0 # Horizontal ash/smoke drift in px/s

@export var enable_dragon_patrol: bool = true
@export var dragon_patrol_speed: float = 55.0 # Ambient dragon flight speed

@onready var distant_crags_layer: ParallaxLayer = get_node_or_null("DistantCragsLayer")
@onready var ambient_dragon_layer: ParallaxLayer = get_node_or_null("AmbientDragonLayer")
@onready var cinders_vfx: CPUParticles2D = get_node_or_null("LavaThermalLayer/FloatingCinders")

func _ready() -> void:
	_start_animations()

func _process(delta: float) -> void:
	if not is_active:
		return
	
	if enable_smoke_drift and distant_crags_layer:
		distant_crags_layer.motion_offset.x += smoke_drift_speed * delta
		
	if enable_dragon_patrol and ambient_dragon_layer:
		ambient_dragon_layer.motion_offset.x += dragon_patrol_speed * delta

func _start_animations() -> void:
	for node in find_children("*", "AnimatedSprite2D", true, false):
		var anim_sprite := node as AnimatedSprite2D
		if anim_sprite and not anim_sprite.is_playing():
			anim_sprite.play()

func set_environment_active(active: bool) -> void:
	visible = active
	set_process(active)
	set_physics_process(active)
	
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
