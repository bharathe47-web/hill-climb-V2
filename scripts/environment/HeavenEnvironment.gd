class_name HeavenEnvironment
extends ParallaxBackground

## HeavenEnvironment: Reusable 2D celestial environment for Godot 4.7.2.
## Features layered parallax backdrop, golden palace architecture, angel statue,
## animated dove flock, celestial clouds, and mobile-optimized glow/sparkle VFX.
## Designed for zero collision interference with Endless Map vehicle driving lane.

@export var is_active: bool = true:
	set(value):
		if is_active != value:
			is_active = value
			set_environment_active(value)

@export var enable_cloud_drift: bool = true
@export var cloud_drift_speed: float = 8.0 # Horizontal cloud drift in px/s

@export var enable_dove_flight: bool = true
@export var dove_speed: float = 45.0 # Flight drift speed across the sky
@export var dove_bob_amplitude: float = 6.0 # Gentle vertical flock bobbing
@export var dove_bob_frequency: float = 2.0

@onready var celestial_clouds_layer: ParallaxLayer = get_node_or_null("CelestialCloudsLayer")
@onready var distant_clouds_layer: ParallaxLayer = get_node_or_null("DistantCloudsLayer")
@onready var dove_flock_layer: ParallaxLayer = get_node_or_null("DoveFlockLayer")
@onready var sparkles_vfx: CPUParticles2D = get_node_or_null("NearFloraLayer/CelestialSparkles")

var _dove_base_y: float = 0.0
var _dove_time: float = 0.0

func _ready() -> void:
	if is_instance_valid(dove_flock_layer):
		_dove_base_y = dove_flock_layer.motion_offset.y
		dove_flock_layer.visible = false
		dove_flock_layer.modulate = Color(1, 1, 1, 0.0)
		
	_setup_visibility_culling()
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
		if dove_bob_amplitude > 0.0:
			_dove_time += delta * dove_bob_frequency
			dove_flock_layer.motion_offset.y = _dove_base_y + sin(_dove_time) * dove_bob_amplitude

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
