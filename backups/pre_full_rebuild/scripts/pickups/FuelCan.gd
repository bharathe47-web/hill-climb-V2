extends Area2D
class_name FuelCan

@export var refill_percent: float = 0.45

var is_collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Gentle floating idle bounce animation
	var tween := create_tween().set_loops()
	tween.tween_property($Sprite2D, "position:y", -5.0, 0.7).set_trans(Tween.TRANS_SINE)
	tween.tween_property($Sprite2D, "position:y", 5.0, 0.7).set_trans(Tween.TRANS_SINE)

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body is RigidBody2D: # Vehicle or wheel
		is_collected = true
		AudioManager.play_sfx("fuel", 1.0)
		GameState.add_fuel(refill_percent)
		
		# Popup animation
		var tween := create_tween()
		tween.tween_property($Sprite2D, "scale", Vector2(1.4, 1.4), 0.15)
		tween.parallel().tween_property($Sprite2D, "modulate:a", 0.0, 0.15)
		tween.tween_callback(queue_free)
