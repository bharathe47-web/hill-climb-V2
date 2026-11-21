class_name IndianLandmarkV2
extends Node2D

## IndianLandmarkV2: High-definition regional landmark component for Indian Roads mode.
## Displays authentic state landmarks without signboard occlusion and with dynamic scale normalization.

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
		var tex_path := waypoint.landmark_texture_path
		
		# Upgrade to v2 asset path if available
		var v2_path := tex_path.replace("assets/indian_locations/", "assets/indian_locations/visual_upgrade_v2/")
		v2_path = v2_path.replace("assets/indian_roads/", "assets/indian_roads/visual_upgrade_v2/")
		if ResourceLoader.exists(v2_path):
			tex_path = v2_path
			
		if waypoint.waypoint_type == WaypointData.WaypointType.START or tex_path == "" or "triveni_sangam" in tex_path:
			if is_instance_valid(monument_sprite):
				monument_sprite.visible = false
				monument_sprite.texture = null
		elif tex_path != "" and ResourceLoader.exists(tex_path):
			var tex: Texture2D = load(tex_path)
			if tex and is_instance_valid(monument_sprite):
				monument_sprite.visible = true
				monument_sprite.texture = tex
				var scale_factor: float = waypoint.landmark_scale
				var h := float(tex.get_height())
				if h > 450.0:
					scale_factor *= (320.0 / h)
				monument_sprite.scale = Vector2(scale_factor, scale_factor)
				# Anchor base of monument to ground
				monument_sprite.position = Vector2(0, -(320.0 * 0.5) if h > 450.0 else -110.0)
	else:
		if is_instance_valid(monument_sprite) and monument_sprite.texture:
			var h := float(monument_sprite.texture.get_height())
			if h > 450.0:
				var s := 320.0 / h
				monument_sprite.scale = Vector2(s, s)
				monument_sprite.position = Vector2(0, -(320.0 * 0.5))

	if is_instance_valid(milestone_sprite) and milestone_sprite.texture:
		var mh := float(milestone_sprite.texture.get_height())
		if mh > 80.0:
			var ms := 52.0 / mh
			milestone_sprite.scale = Vector2(ms, ms)
			milestone_sprite.position = Vector2(110.0, -26.0)

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

	# Visual elevation bounce celebration
	if is_instance_valid(monument_sprite):
		var tw := create_tween()
		if is_instance_valid(tw):
			tw.tween_property(monument_sprite, "position:y", monument_sprite.position.y - 12.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(monument_sprite, "position:y", monument_sprite.position.y, 0.2)

	var lm_id: String = waypoint.id if waypoint != null else String(name)
	landmark_reached.emit(lm_id, waypoint)
