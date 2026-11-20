class_name AsteroidLandingBurst
extends Node2D

## AsteroidLandingBurst: 8-frame fiery ground explosion with sparks when burning asteroid hits terrain.

@onready var burst_sprite: AnimatedSprite2D = $BurstSprite
@onready var spark_particles: CPUParticles2D = $SparkParticles

func _ready() -> void:
	if is_instance_valid(burst_sprite):
		burst_sprite.animation_finished.connect(_on_animation_finished)
		burst_sprite.play("default")
	if is_instance_valid(spark_particles):
		spark_particles.emitting = true

func _on_animation_finished() -> void:
	queue_free()
