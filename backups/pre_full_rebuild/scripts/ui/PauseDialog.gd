extends Control
class_name PauseDialog

signal resume_pressed
signal restart_pressed
signal garage_pressed
signal map_pressed

@onready var resume_btn: Button = $Panel/VBox/ResumeButton
@onready var restart_btn: Button = $Panel/VBox/RestartButton
@onready var garage_btn: Button = $Panel/VBox/GarageButton
@onready var map_btn: Button = $Panel/VBox/MapButton
@onready var music_slider: HSlider = $Panel/VBox/AudioBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBox/AudioBox/SFXRow/SFXSlider

func _ready() -> void:
	visible = false
	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
	garage_btn.pressed.connect(_on_garage)
	map_btn.pressed.connect(_on_map)
	
	music_slider.value = GameState.music_volume * 100.0
	sfx_slider.value = GameState.sfx_volume * 100.0
	
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

func open_pause() -> void:
	visible = true
	get_tree().paused = true
	GameState.is_paused = true

func close_pause() -> void:
	visible = false
	get_tree().paused = false
	GameState.is_paused = false

func _on_resume() -> void:
	close_pause()
	AudioManager.play_sfx("click")
	resume_pressed.emit()

func _on_restart() -> void:
	close_pause()
	AudioManager.play_sfx("click")
	restart_pressed.emit()

func _on_garage() -> void:
	close_pause()
	AudioManager.play_sfx("click")
	garage_pressed.emit()

func _on_map() -> void:
	close_pause()
	AudioManager.play_sfx("click")
	map_pressed.emit()

func _on_music_changed(val: float) -> void:
	GameState.music_volume = val / 100.0
	AudioManager.update_volumes()
	SaveSystem.save_game()

func _on_sfx_changed(val: float) -> void:
	GameState.sfx_volume = val / 100.0
	AudioManager.update_volumes()
	SaveSystem.save_game()
