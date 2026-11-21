class_name ReturnPortal
extends Node2D

## ReturnPortal: Physical gateway spawned at the 900m boundary (Hell -> Normal Land).
## Features warm limestone pillars entwined with green countryside vines,
## pastoral golden-emerald vortex, and sunny sparkles. Preserves vehicle momentum.

signal traversed(portal: ReturnPortal, cycle_index: int)

@export var cycle_index: int = 0
@export var portal_distance_m: float = 900.0

var is_traversed: bool = false

@onready var trigger_area: Area2D = $TriggerArea
@onready var vortex_sprite: Sprite2D = $Vortex
@onready var sparkles_particles: CPUParticles2D = $Sparkles
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	if trigger_area and not trigger_area.body_entered.is_connected(_on_body_entered):
		trigger_area.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if vortex_sprite:
		vortex_sprite.rotation += 1.4 * delta
		var pulse := 1.0 + 0.04 * sin(Time.get_ticks_msec() * 0.004)
		vortex_sprite.scale = Vector2(pulse, pulse) * 0.95

func _on_body_entered(body: Node) -> void:
	if is_traversed:
		return
	if _is_vehicle(body):
		trigger_traversal()

func _is_vehicle(body: Node) -> bool:
	if not body:
		return false
	if body is RigidBody2D and (body.name == "Vehicle" or body.is_in_group("vehicle") or body.get("current_nitro") != null):
		return true
	if body.get_parent() and (body.get_parent().name == "Vehicle" or body.get_parent().is_in_group("vehicle")):
		return true
	return false

func trigger_traversal() -> void:
	if is_traversed:
		return
	is_traversed = true
	
	if sparkles_particles:
		sparkles_particles.amount = 40
		sparkles_particles.speed_scale = 1.8
	
	if audio_player and audio_player.stream:
		audio_player.play()
	
	traversed.emit(self, cycle_index)
