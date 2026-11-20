class_name GroundShadow
extends Node2D

## GroundShadow: Centralized, reusable ground warning shadow projection for all falling obstacles.
## Displays a soft elliptical shadow at the predicted landing coordinates across 3 warning stages:
## Stage 1 (Early Warning): High altitude, low opacity, subtle footprint.
## Stage 2 (Approaching): Altitude decreasing, smooth alpha and scale expansion towards full footprint.
## Stage 3 (Immediate Impact): Dangerous landing zone, maximum opacity and sharpness.
## Uncoupled from obstacle rotation, tumbling, and spinning. Safely fades on impact.

const SHADOW_TEXTURE: Texture2D = preload("res://assets/obstacles/survival/support/impact_effects/obstacle_shadow.png")

@export var base_scale: Vector2 = Vector2(0.45, 0.45)
@export var min_alpha: float = 0.2
@export var max_alpha: float = 0.85
@export var max_track_altitude: float = 650.0

@onready var shadow_sprite: Sprite2D = get_node_or_null("ShadowSprite")

var _is_fading: bool = false
var _current_alpha: float = 0.2
var _current_scale_factor: float = 0.5

func _ready() -> void:
	# Ensure ground shadow is rendered in world coordinates independent of parent rotation
	top_level = true
	z_index = 0
	
	if not is_instance_valid(shadow_sprite):
		shadow_sprite = Sprite2D.new()
		shadow_sprite.name = "ShadowSprite"
		shadow_sprite.texture = SHADOW_TEXTURE
		add_child(shadow_sprite)
	elif shadow_sprite.texture == null:
		shadow_sprite.texture = SHADOW_TEXTURE
		
	# Initial appearance
	_apply_visuals(min_alpha, 0.45)

## Updates the shadow position and 3-stage warning progression based on predicted landing pos and altitude.
func update_landing_state(predicted_pos: Vector2, current_altitude: float, total_height: float = 600.0) -> void:
	if _is_fading:
		return
		
	global_position = predicted_pos
	# Keep rotation flat along horizontal terrain projection
	global_rotation = 0.0

	var max_h: float = maxf(total_height, 100.0)
	var norm_alt: float = clampf(current_altitude / max_h, 0.0, 1.0)
	var impact_proximity: float = 1.0 - norm_alt # 0.0 (sky high) -> 1.0 (touching ground)

	var target_alpha: float = min_alpha
	var target_scale_mult: float = 0.45

	if impact_proximity < 0.35:
		# Stage 1: Early warning (high in sky)
		var t := impact_proximity / 0.35
		target_alpha = lerpf(min_alpha, 0.4, t)
		target_scale_mult = lerpf(0.45, 0.65, t)
	elif impact_proximity < 0.75:
		# Stage 2: Approaching warning (mid altitude)
		var t := (impact_proximity - 0.35) / 0.40
		target_alpha = lerpf(0.4, 0.68, t)
		target_scale_mult = lerpf(0.65, 0.85, t)
	else:
		# Stage 3: Immediate impact warning (critical zone)
		var t := (impact_proximity - 0.75) / 0.25
		target_alpha = lerpf(0.68, max_alpha, t)
		target_scale_mult = lerpf(0.85, 1.0, t)

	_apply_visuals(target_alpha, target_scale_mult)

func _apply_visuals(alpha: float, scale_mult: float) -> void:
	_current_alpha = alpha
	_current_scale_factor = scale_mult
	modulate.a = alpha
	scale = base_scale * scale_mult

## Smoothly fades out and cleans up the ground shadow node on final obstacle ground impact.
func fade_and_free(duration: float = 0.2) -> void:
	if _is_fading:
		return
	_is_fading = true
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 0.0, maxf(0.05, duration))
	tw.tween_property(self, "scale", scale * 1.15, maxf(0.05, duration))
	tw.chain().tween_callback(queue_free)
