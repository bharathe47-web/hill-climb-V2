class_name LandingDustEffect
extends Node2D

## LandingDustEffect: Reusable 2D cartoon ground-impact dust effect.
## Features AnimatedSprite2D playing Candidate 1 (Mushroom Cloud), Candidate 2 (Ground Ring),
## or Candidate 3 (Impact Poof) from the imported landing_dust asset pack.
## Automatically cleans itself up upon animation completion.

const SPRITE_FRAMES: SpriteFrames = preload("res://assets/effects/landing_dust/landing_dust_frames.tres")
const SCENE_PATH: String = "res://scenes/components/effects/landing_dust_effect.tscn"

@export var animation_name: String = "mushroom_cloud"
@export var effect_scale: Vector2 = Vector2(0.26, 0.26)
@export var playback_speed: float = 1.0
@export var enable_secondary_ring: bool = false
@export var enable_dust_particles: bool = true

@onready var main_dust: AnimatedSprite2D = $MainDust
@onready var secondary_ring: AnimatedSprite2D = $SecondaryRing
@onready var dust_particles: CPUParticles2D = $DustParticles

var _has_started: bool = false

## Static helper to spawn, position, and play effect in one call
static func spawn_at(parent: Node, world_pos: Vector2, anim: String = "mushroom_cloud", scale_val: float = 0.26, with_ring: bool = false, with_particles: bool = true) -> LandingDustEffect:
	if not is_instance_valid(parent):
		return null
	var scene_res = load(SCENE_PATH)
	if scene_res == null:
		return null
	var inst: LandingDustEffect = scene_res.instantiate()
	inst.animation_name = anim
	inst.effect_scale = Vector2(scale_val, scale_val)
	inst.enable_secondary_ring = with_ring
	inst.enable_dust_particles = with_particles
	inst.global_position = world_pos
	parent.add_child(inst)
	inst.play_effect(anim)
	return inst

func _ready() -> void:
	# Ensure safety cleanup in case animation fails or gets interrupted
	var safety_timer := get_tree().create_timer(1.5)
	safety_timer.timeout.connect(_on_safety_timeout)
	
	if not _has_started:
		play_effect(animation_name)

## Starts playing the configured landing dust animation
func play_effect(anim: String = "") -> void:
	_has_started = true
	if not anim.is_empty():
		animation_name = anim
		
	scale = effect_scale
	
	if is_instance_valid(main_dust):
		if not main_dust.sprite_frames:
			main_dust.sprite_frames = SPRITE_FRAMES
		
		# Connect completion signal once
		if not main_dust.animation_finished.is_connected(_on_animation_finished):
			main_dust.animation_finished.connect(_on_animation_finished)
			
		main_dust.speed_scale = playback_speed
		if main_dust.sprite_frames.has_animation(animation_name):
			main_dust.play(animation_name)
		else:
			main_dust.play("mushroom_cloud")
	
	# Secondary ground ring for heavy impacts
	if is_instance_valid(secondary_ring):
		if enable_secondary_ring:
			secondary_ring.visible = true
			if not secondary_ring.sprite_frames:
				secondary_ring.sprite_frames = SPRITE_FRAMES
			secondary_ring.speed_scale = playback_speed * 1.1
			secondary_ring.play("ground_ring")
		else:
			secondary_ring.visible = false
			
	# Complementary modular floating dust particles
	if is_instance_valid(dust_particles):
		if enable_dust_particles:
			dust_particles.emitting = true
			dust_particles.one_shot = true
		else:
			dust_particles.emitting = false

func _on_animation_finished() -> void:
	# Fade out cleanly and free
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.08)
	tw.tween_callback(queue_free)

func _on_safety_timeout() -> void:
	if is_instance_valid(self):
		queue_free()
