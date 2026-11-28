extends Control
class_name MapMenu

signal stage_selected(stage_id: String)
signal back_pressed

@onready var stage_container: VBoxContainer = $ScrollContainer/Margin/StageList
@onready var back_button: Button = $Header/BackButton
@onready var total_coins_label: Label = $Header/CoinPill/HBox/CoinLabel

var font_tamil: Font = preload("res://fonts/NotoSansTamil-Bold.ttf")

const STAGES_INFO: Array[Dictionary] = [
	{"id": "stage_01_kanyakumari", "en": "1. Kanyakumari Coast", "ta": "கன்னியாகுமரி கடற்கரை", "desc": "Land's End & Ocean Highway - 1200m"},
	{"id": "stage_02_nagercoil", "en": "2. Nagercoil Foothills", "ta": "நாகர்கோவில் அடிவாரம்", "desc": "Western Ghats & Plantations - 1500m"},
	{"id": "stage_03_tirunelveli", "en": "3. Tirunelveli Plains", "ta": "திருநெல்வேலி சமவெளி", "desc": "Thamirabarani River & Valley - 1800m"},
	{"id": "stage_04_madurai", "en": "4. Madurai Temple City", "ta": "மதுரை கோயில் நகரம்", "desc": "Meenakshi Skyline & Vaigai - 2100m"},
	{"id": "stage_05_trichy", "en": "5. Trichy Rockfort", "ta": "திருச்சி மலைக்கோட்டை", "desc": "Cauvery Riverbed & Fort - 2400m"},
	{"id": "stage_06_villupuram", "en": "6. Villupuram Expressway", "ta": "விழுப்புரம் நெடுஞ்சாலை", "desc": "NH44 High-Speed Corridor - 2700m"},
	{"id": "stage_07_chennai", "en": "7. Chennai Marina Promenade", "ta": "சென்னை மெரினா கடற்கரை", "desc": "Final Grand Victory Sprint - 3000m"}
]

func _ready() -> void:
	back_button.pressed.connect(_on_back)
	_refresh_view()

func _refresh_view() -> void:
	if total_coins_label and GameState:
		total_coins_label.text = str(GameState.coins)
		
	# Clear previous cards
	for c in stage_container.get_children():
		c.queue_free()
		
	for info in STAGES_INFO:
		var stage_id: String = info["id"]
		var is_unlocked: bool = GameState.is_stage_unlocked(stage_id) if GameState else (stage_id == "stage_01_kanyakumari")
		var best_dist: float = GameState.stage_best_distances.get(stage_id, 0.0) if GameState else 0.0
		
		var card := _create_stage_card(info, is_unlocked, best_dist)
		stage_container.add_child(card)

func _create_stage_card(info: Dictionary, is_unlocked: bool, best_dist: float) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.15, 0.20, 0.9) if is_unlocked else Color(0.08, 0.09, 0.11, 0.7)
	style.border_color = Color(0.2, 0.7, 0.9, 1.0) if is_unlocked else Color(0.3, 0.3, 0.35, 0.5)
	style.border_width_left = 3
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	panel.add_theme_stylebox_override("panel", style)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)
	
	# Text Column
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	var title_lbl := Label.new()
	title_lbl.text = info["en"]
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1) if is_unlocked else Color(0.6, 0.6, 0.6))
	vbox.add_child(title_lbl)
	
	var tamil_lbl := Label.new()
	tamil_lbl.text = info["ta"]
	tamil_lbl.add_theme_font_override("font", font_tamil)
	tamil_lbl.add_theme_font_size_override("font_size", 18)
	tamil_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1) if is_unlocked else Color(0.5, 0.5, 0.5))
	vbox.add_child(tamil_lbl)
	
	var desc_lbl := Label.new()
	desc_lbl.text = info["desc"] + (" | Best: %dm" % int(best_dist) if best_dist > 0 else "")
	desc_lbl.add_theme_font_size_override("font_size", 15)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8) if is_unlocked else Color(0.4, 0.4, 0.4))
	vbox.add_child(desc_lbl)
	
	# Action Button
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(140, 50)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var btn_style := StyleBoxFlat.new()
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_right = 8
	btn_style.corner_radius_bottom_left = 8
	
	if is_unlocked:
		btn.text = "DRIVE"
		btn_style.bg_color = Color(0.12, 0.65, 0.32, 1)
		btn.pressed.connect(func(): _select_stage(info["id"]))
	else:
		btn.text = "LOCKED"
		btn_style.bg_color = Color(0.25, 0.25, 0.28, 1)
		btn.disabled = true
		
	btn.add_theme_stylebox_override("normal", btn_style)
	btn.add_theme_font_size_override("font_size", 18)
	hbox.add_child(btn)
	
	return panel

func _select_stage(stage_id: String) -> void:
	AudioManager.play_sfx("click")
	GameState.active_stage_id = stage_id
	StageManager.load_active_stage()
	stage_selected.emit(stage_id)

func _on_back() -> void:
	AudioManager.play_sfx("click")
	back_pressed.emit()
