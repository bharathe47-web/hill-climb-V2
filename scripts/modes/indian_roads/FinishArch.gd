class_name IndianFinishArch
extends Node2D

## IndianFinishArch: Grand Destination arch at the end of an Indian Road route.
## Emits destination_reached when the player vehicle drives through the finish line.

const WaypointData = preload("res://resources/routes/WaypointData.gd")

signal destination_reached(destination_id: String, waypoint: WaypointData)

@export var waypoint: WaypointData = null
@export var destination_city: String = "CHENNAI"
@export var is_reached: bool = false

@onready var arch_sprite: Sprite2D = $ArchSprite
@onready var city_label: Label = $CityLabel
@onready var trigger_area: Area2D = $TriggerArea

func _ready() -> void:
	if waypoint != null:
		destination_city = waypoint.title
	if is_instance_valid(city_label):
		if destination_city.to_upper() == "CHENNAI":
			city_label.text = "CHENNAI — JOURNEY COMPLETED"
		else:
			city_label.text = "WELCOME TO " + destination_city.to_upper()

	if is_instance_valid(arch_sprite) and arch_sprite.texture:
		var ah := float(arch_sprite.texture.get_height())
		if ah > 300.0:
			var s := 240.0 / ah
			arch_sprite.scale = Vector2(s, s)
			arch_sprite.position = Vector2(0, -120.0)

	if is_instance_valid(trigger_area):
		trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if is_reached:
		return

	if body is VehicleController or body.is_in_group("vehicle") or body.name == "Vehicle" or body.get_parent() is VehicleController:
		trigger_finish()

func trigger_finish() -> void:
	if is_reached:
		return
	is_reached = true

	# Celebrate with banner bounce
	if is_instance_valid(arch_sprite):
		var tw := create_tween()
		if is_instance_valid(tw):
			tw.tween_property(arch_sprite, "scale", Vector2(1.15, 1.15), 0.2)
			tw.tween_property(arch_sprite, "scale", Vector2(1.0, 1.0), 0.2)

	var dst_id := waypoint.id if waypoint != null else "destination"
	destination_reached.emit(dst_id, waypoint)
