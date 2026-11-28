class_name SettingsMenuController
extends Control

## SettingsMenuController: Handles volume sliders for Music & SFX,
## updating AudioServer buses and persisting values in SaveManager.

const SaveManager = preload("res://scripts/core/SaveManager.gd")

signal close_requested

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var close_button: Button = %CloseButton
@onready var music_value_label: Label = get_node_or_null("%MusicValueLabel")
@onready var sfx_value_label: Label = get_node_or_null("%SFXValueLabel")

func _ready() -> void:
	_init_sliders()
	if is_instance_valid(close_button):
		close_button.pressed.connect(_on_close_pressed)

func _init_sliders() -> void:
	var music_vol := SaveManager.get_music_volume()
	var sfx_vol := SaveManager.get_sound_volume()

	if is_instance_valid(music_slider):
		music_slider.min_value = 0.0
		music_slider.max_value = 1.0
		music_slider.step = 0.01
		music_slider.value = music_vol
		if not music_slider.value_changed.is_connected(_on_music_value_changed):
			music_slider.value_changed.connect(_on_music_value_changed)
		_update_music_label(music_vol)

	if is_instance_valid(sfx_slider):
		sfx_slider.min_value = 0.0
		sfx_slider.max_value = 1.0
		sfx_slider.step = 0.01
		sfx_slider.value = sfx_vol
		if not sfx_slider.value_changed.is_connected(_on_sfx_value_changed):
			sfx_slider.value_changed.connect(_on_sfx_value_changed)
		_update_sfx_label(sfx_vol)

func _on_music_value_changed(val: float) -> void:
	apply_music_volume(val)
	SaveManager.set_music_volume(val)
	_update_music_label(val)

func _on_sfx_value_changed(val: float) -> void:
	apply_sound_volume(val)
	SaveManager.set_sound_volume(val)
	_update_sfx_label(val)

func _update_music_label(val: float) -> void:
	if is_instance_valid(music_value_label):
		music_value_label.text = str(roundi(val * 100.0)) + "%"

func _update_sfx_label(val: float) -> void:
	if is_instance_valid(sfx_value_label):
		sfx_value_label.text = str(roundi(val * 100.0)) + "%"

func _on_close_pressed() -> void:
	close_requested.emit()

static func apply_music_volume(val: float) -> void:
	var db: float = linear_to_db(val) if val > 0.0001 else -80.0
	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, db)
	var amb_bus := AudioServer.get_bus_index("Ambience")
	if amb_bus >= 0:
		AudioServer.set_bus_volume_db(amb_bus, db)

static func apply_sound_volume(val: float) -> void:
	var db: float = linear_to_db(val) if val > 0.0001 else -80.0
	var sfx_bus := AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, db)
	var ui_bus := AudioServer.get_bus_index("UI")
	if ui_bus >= 0:
		AudioServer.set_bus_volume_db(ui_bus, db)
