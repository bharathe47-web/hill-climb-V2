extends Control
class_name CheckpointBanner

@onready var panel: PanelContainer = $PanelContainer
@onready var label_en: Label = $PanelContainer/VBox/LabelEN
@onready var label_ta: Label = $PanelContainer/VBox/LabelTA

var font_tamil: Font = preload("res://fonts/NotoSansTamil-Bold.ttf")

func _ready() -> void:
	visible = false
	label_ta.add_theme_font_override("font", font_tamil)
	if StageManager:
		StageManager.checkpoint_reached.connect(_on_checkpoint_reached)

func _on_checkpoint_reached(data: Dictionary) -> void:
	var name_en: String = data.get("name_en", "Checkpoint Reached!")
	var name_ta: String = data.get("name_ta", "சோதனைச் சாவடி")
	var dist: float = float(data.get("distance", 0.0))
	
	label_en.text = "CHECKPOINT %dm: %s" % [int(dist), name_en]
	label_ta.text = name_ta
	
	visible = true
	modulate.a = 0.0
	position.y = -80.0
	
	var tween := create_tween()
	tween.tween_property(self, "position:y", 60.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func(): visible = false)
