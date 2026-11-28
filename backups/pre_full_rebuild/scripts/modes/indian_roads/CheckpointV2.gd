class_name IndianCheckpointV2
extends Node2D

## IndianCheckpointV2: High-definition toll plaza / checkpoint gate for Indian Roads mode.
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
			gate_sprite.position = Vector2(0, -90.0)

	if is_instance_valid(banner_sprite) and banner_sprite.texture:
		var bh := float(banner_sprite.texture.get_height())
		if bh > 80.0:
			var s := 65.0 / bh
			banner_sprite.scale = Vector2(s, s)
			banner_sprite.position = Vector2(0, -180.0)

	if is_instance_valid(trigger_area):
		trigger_area.body_entered.connect(_on_body_entered)

	_setup_boom_barrier()

var barrier_pivot: Node2D = null

func _setup_boom_barrier() -> void:
	if is_instance_valid(barrier_pivot):
		return

	# Dedicated mechanical boom barrier arm mounted on the toll booth support
	barrier_pivot = Node2D.new()
	barrier_pivot.name = "BarrierPivot"
	barrier_pivot.position = Vector2(-44.0, -32.0)
	barrier_pivot.z_index = 0 # Aligns at road surface level without blocking HUD
	add_child(barrier_pivot)

	# Pivot housing bracket
	var pivot_base := ColorRect.new()
	pivot_base.size = Vector2(10.0, 16.0)
	pivot_base.position = Vector2(-5.0, -8.0)
	pivot_base.color = Color(0.22, 0.25, 0.30, 1.0)
	barrier_pivot.add_child(pivot_base)

	# Main barrier arm (85px long)
	var arm := Line2D.new()
	arm.name = "ArmLine"
	arm.points = PackedVector2Array([Vector2(0, 0), Vector2(88.0, 0)])
	arm.width = 5.0
	arm.default_color = Color(0.95, 0.95, 0.95, 1.0)
	barrier_pivot.add_child(arm)

	# Alternating red reflective safety stripes
	for i in range(1, 5):
		var stripe := Line2D.new()
		var sx: float = float(i * 18)
		stripe.points = PackedVector2Array([Vector2(sx - 8.0, 0), Vector2(sx, 0)])
		stripe.width = 5.0
		stripe.default_color = Color(0.90, 0.18, 0.15, 1.0)
		barrier_pivot.add_child(stripe)

func _on_body_entered(body: Node) -> void:
	if is_cleared:
		return

	if body is VehicleController or body.is_in_group("vehicle") or body.name == "Vehicle" or body.get_parent() is VehicleController:
		trigger_clear()

func trigger_clear() -> void:
	if is_cleared:
		return
	is_cleared = true

	if is_instance_valid(status_label):
		status_label.text = "CLEARED ✓"
		status_label.add_theme_color_override("font_color", Color(0.2, 0.95, 0.4, 1.0))

	# Celebratory visual bounce for toll banner
	if is_instance_valid(banner_sprite):
		var tw := create_tween()
		if is_instance_valid(tw):
			tw.tween_property(banner_sprite, "scale", banner_sprite.scale * 1.12, 0.2)
			tw.tween_property(banner_sprite, "scale", banner_sprite.scale, 0.15)

	# Smoothly lift the boom barrier arm to open the lane (booth structure stays firmly grounded)
	if is_instance_valid(barrier_pivot):
		var tw_arm := create_tween()
		if is_instance_valid(tw_arm):
			tw_arm.tween_property(barrier_pivot, "rotation_degrees", -78.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var cp_id := waypoint.id if waypoint != null else "checkpoint"
	checkpoint_cleared.emit(cp_id, waypoint)
