class_name IndianLandmark
extends Node2D

## IndianLandmark: Roadside cultural monument or city icon for Indian Roads mode.
## Displays authentic state landmarks and emits landmark_reached when player approaches.

const WaypointData = preload("res://resources/routes/WaypointData.gd")

signal landmark_reached(landmark_id: String, waypoint: WaypointData)

@export var waypoint: WaypointData = null
@export var landmark_title: String = "LANDMARK"
@export var landmark_subtitle: String = ""
@export var is_discovered: bool = false

@onready var monument_sprite: Sprite2D = $MonumentSprite
@onready var milestone_sprite: Sprite2D = $MilestoneSprite
@onready var title_label: Label = $Signboard/TitleLabel
@onready var subtitle_label: Label = $Signboard/SubtitleLabel
@onready var trigger_area: Area2D = $TriggerArea

func _ready() -> void:
	if waypoint != null:
		landmark_title = waypoint.title
		landmark_subtitle = waypoint.subtitle
		if waypoint.waypoint_type == WaypointData.WaypointType.START or waypoint.landmark_texture_path.is_empty() or "triveni_sangam" in waypoint.landmark_texture_path:
			if is_instance_valid(monument_sprite):
				monument_sprite.visible = false
				monument_sprite.texture = null
		elif waypoint.landmark_texture_path != "" and ResourceLoader.exists(waypoint.landmark_texture_path):
			var tex: Texture2D = load(waypoint.landmark_texture_path)
			if tex and is_instance_valid(monument_sprite):
				monument_sprite.visible = true
				monument_sprite.texture = tex
				var scale_factor: float = waypoint.landmark_scale
				if tex.get_height() > 500:
					scale_factor *= (300.0 / float(tex.get_height()))
				monument_sprite.scale = Vector2(scale_factor, scale_factor)

	if is_instance_valid(milestone_sprite) and milestone_sprite.texture:
		var mh := float(milestone_sprite.texture.get_height())
		if mh > 100.0:
			var ms := 50.0 / mh
			milestone_sprite.scale = Vector2(ms, ms)

	if is_instance_valid(title_label):
		title_label.text = landmark_title
	if is_instance_valid(subtitle_label):
		subtitle_label.text = landmark_subtitle

	if is_instance_valid(trigger_area):
		trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if is_discovered:
		return

	if body is VehicleController or body.is_in_group("vehicle") or body.name == "Vehicle" or body.get_parent() is VehicleController:
		discover_landmark()

func discover_landmark() -> void:
	if is_discovered:
		return
	is_discovered = true

	# Visual elevation bounce
	if is_instance_valid(monument_sprite):
		var tw := create_tween()
		if is_instance_valid(tw):
			tw.tween_property(monument_sprite, "position:y", monument_sprite.position.y - 12.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(monument_sprite, "position:y", monument_sprite.position.y, 0.2)

	var lm_id: String = waypoint.id if waypoint != null else String(name)
	landmark_reached.emit(lm_id, waypoint)
