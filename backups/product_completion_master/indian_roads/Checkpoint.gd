class_name IndianCheckpoint
extends Node2D

## IndianCheckpoint: Reusable toll plaza / checkpoint gate for Indian Roads mode.
## Emits checkpoint_cleared signal when the player vehicle drives through.

const WaypointData = preload("res://resources/routes/WaypointData.gd")

signal checkpoint_cleared(checkpoint_id: String, waypoint: WaypointData)

@export var waypoint: WaypointData = null
@export var checkpoint_name: String = "CHECKPOINT"
@export var is_cleared: bool = false

@onready var trigger_area: Area2D = $TriggerArea
@onready var banner_sprite: Sprite2D = $BannerSprite
@onready var gate_sprite: Sprite2D = $GateSprite
@onready var title_label: Label = $TitleLabel
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	if waypoint != null:
		checkpoint_name = waypoint.title
	if is_instance_valid(title_label):
		title_label.text = checkpoint_name
	if is_instance_valid(status_label):
		status_label.text = "STOP & TOLL" if not is_cleared else "CLEARED"

	if is_instance_valid(gate_sprite) and gate_sprite.texture:
		var gh := float(gate_sprite.texture.get_height())
		if gh > 150.0:
			var s := 180.0 / gh
			gate_sprite.scale = Vector2(s, s)

	if is_instance_valid(banner_sprite) and banner_sprite.texture:
		var bh := float(banner_sprite.texture.get_height())
		if bh > 80.0:
			var s := 60.0 / bh
			banner_sprite.scale = Vector2(s, s)

	if is_instance_valid(trigger_area):
		trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if is_cleared:
		return

	# Detect vehicle (chassis or vehicle root)
	if body is VehicleController or body.is_in_group("vehicle") or body.name == "Vehicle" or body.get_parent() is VehicleController:
		trigger_clear()

func trigger_clear() -> void:
	if is_cleared:
		return
	is_cleared = true

	if is_instance_valid(status_label):
		status_label.text = "CLEARED ✓"
		status_label.add_theme_color_override("font_color", Color(0.2, 0.95, 0.4, 1.0))

	# Play celebratory visual bounce
	if is_instance_valid(banner_sprite):
		var tw := create_tween()
		if is_instance_valid(tw):
			tw.tween_property(banner_sprite, "scale", Vector2(1.2, 1.2), 0.15)
			tw.tween_property(banner_sprite, "scale", Vector2(1.0, 1.0), 0.2)

	var cp_id: String = waypoint.id if waypoint != null else String(name)
	checkpoint_cleared.emit(cp_id, waypoint)
