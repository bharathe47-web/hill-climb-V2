class_name RoadsideLandmark
extends Node2D

## RoadsideLandmark: Reusable roadside tourist attraction component for Indian Roads mode.
## Displays authentic monuments, forts, temples, bridges, and natural attractions along the road,
## anchored cleanly to roadside ground with highway identification signboards.

signal landmark_discovered(landmark_id: String, place_name: String)

@export var landmark_id: String = ""
@export var state_id: String = ""
@export var place_name: String = ""
@export var location_district: String = ""
@export var landmark_category: String = "medium_monument"
@export var visual_asset_path: String = ""
@export var target_height: float = 240.0
@export var target_width: float = 0.0
@export var ground_offset_y: float = 0.0
@export var show_signboard: bool = true
@export var is_discovered: bool = false

@onready var monument_sprite: Sprite2D = $MonumentSprite
@onready var ground_shadow: Sprite2D = get_node_or_null("GroundShadow")
@onready var signboard: Node2D = get_node_or_null("Signboard")
@onready var title_label: Label = get_node_or_null("Signboard/TitleLabel")
@onready var subtitle_label: Label = get_node_or_null("Signboard/SubtitleLabel")
@onready var trigger_area: Area2D = get_node_or_null("TriggerArea")

func _ready() -> void:
	_setup_monument()
	_setup_signboard()
	if is_instance_valid(trigger_area):
		trigger_area.body_entered.connect(_on_body_entered)

func _setup_monument() -> void:
	if visual_asset_path == "" or not ResourceLoader.exists(visual_asset_path):
		return

	var tex: Texture2D = load(visual_asset_path) as Texture2D
	if not tex or not is_instance_valid(monument_sprite):
		return

	monument_sprite.texture = tex
	var th := float(tex.get_height())
	var tw := float(tex.get_width())

	if th > 0.0:
		var s := target_height / th
		if target_width > 0.0 and tw > 0.0:
			s = minf(target_height / th, target_width / tw)
		monument_sprite.scale = Vector2(s, s)

		# Ground anchor: Base of monument rests right at the roadside shoulder (y = ground_offset_y)
		monument_sprite.position = Vector2(0.0, ground_offset_y - (target_height * 0.5))

	# Assign depth layer according to category
	match landmark_category:
		"tall_temple", "tall_tower":
			monument_sprite.z_index = -2
		"large_fort", "palace":
			monument_sprite.z_index = -3
		"distant_monument":
			monument_sprite.z_index = -4
		"bridge", "aqueduct":
			monument_sprite.z_index = -2
		_:
			monument_sprite.z_index = -2

func _setup_signboard() -> void:
	if not is_instance_valid(signboard):
		return

	signboard.visible = show_signboard
	if not show_signboard:
		return

	if is_instance_valid(title_label):
		title_label.text = place_name.to_upper()
	if is_instance_valid(subtitle_label):
		subtitle_label.text = location_district

	# Signboard positioned at road shoulder edge (offset to left so it never occludes monument)
	signboard.position = Vector2(-110.0, -42.0)
	signboard.z_index = 1

func _on_body_entered(body: Node) -> void:
	if is_discovered:
		return

	if body is VehicleController or body.is_in_group("vehicle") or body.name == "Vehicle" or body.get_parent() is VehicleController:
		discover_landmark()

func discover_landmark() -> void:
	if is_discovered:
		return
	is_discovered = true

	# Celebrate with gentle elevation bounce
	if is_instance_valid(monument_sprite):
		var tw := create_tween()
		if is_instance_valid(tw):
			tw.tween_property(monument_sprite, "position:y", monument_sprite.position.y - 14.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(monument_sprite, "position:y", monument_sprite.position.y, 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	landmark_discovered.emit(landmark_id, place_name)
