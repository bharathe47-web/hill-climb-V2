class_name HeavenEnvironment
extends ParallaxBackground

## HeavenEnvironment: Reusable 2D celestial environment for Godot 4.7.2.
## Features layered parallax backdrop, golden palace architecture, angel statue,
## animated dove flock, celestial clouds, and mobile-optimized glow/sparkle VFX.
## Designed for zero collision interference with Endless Map vehicle driving lane.

@export var is_active: bool = true:
	set(value):
		is_active = value
		set_environment_active(value)

@export var enable_cloud_drift: bool = true
@export var cloud_drift_speed: float = 8.0 # Horizontal cloud drift in px/s

@export var enable_dove_flight: bool = true
@export var dove_speed: float = 45.0 # Flight drift speed across the sky

@onready var celestial_clouds_layer: ParallaxLayer = get_node_or_null("CelestialCloudsLayer")
@onready var distant_clouds_layer: ParallaxLayer = get_node_or_null("DistantCloudsLayer")
@onready var dove_flock_layer: ParallaxLayer = get_node_or_null("DoveFlockLayer")
@onready var sparkles_vfx: CPUParticles2D = get_node_or_null("NearFloraLayer/CelestialSparkles")

func _ready() -> void:
	_start_animations()

func _process(delta: float) -> void:
	if not is_active:
		return
	
	if enable_cloud_drift:
		if celestial_clouds_layer:
			celestial_clouds_layer.motion_offset.x += cloud_drift_speed * delta
		if distant_clouds_layer:
			distant_clouds_layer.motion_offset.x += (cloud_drift_speed * 0.5) * delta
			
	if enable_dove_flight and dove_flock_layer:
		dove_flock_layer.motion_offset.x += dove_speed * delta

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
