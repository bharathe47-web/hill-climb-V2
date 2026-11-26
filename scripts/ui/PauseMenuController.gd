class_name PauseMenuController
extends Control

## PauseMenuController: Handles the pause overlay, resume, and restart actions.

signal menu_requested

@onready var resume_button: Button = %ResumeButton
@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var panel: PanelContainer = get_node_or_null("%Panel")

var _entrance_tween: Tween = null

var game_manager_ref: Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if is_instance_valid(resume_button):
		resume_button.pressed.connect(_on_resume_pressed)
	if is_instance_valid(retry_button):
		retry_button.pressed.connect(_on_retry_pressed)
	if is_instance_valid(main_menu_button):
		main_menu_button.pressed.connect(_on_main_menu_pressed)

func bind_game_manager(gm: Node) -> void:
	game_manager_ref = gm
	if not is_instance_valid(gm):
		return
	
	if gm.has_signal("run_paused") and not gm.run_paused.is_connected(_on_run_paused):
		gm.run_paused.connect(_on_run_paused)
	if gm.has_signal("run_started") and not gm.run_started.is_connected(_on_run_started):
		gm.run_started.connect(_on_run_started)
	if gm.has_signal("run_restarted") and not gm.run_restarted.is_connected(_on_run_started):
		gm.run_restarted.connect(_on_run_started)

func _on_run_paused(is_paused: bool) -> void:
	visible = is_paused
	if visible:
		_play_entrance_animation()
		if is_instance_valid(resume_button):
			resume_button.grab_focus()

## Small scale+fade pop so the pause card arrives with a bit of weight instead of snapping
## instantly to full size.
func _play_entrance_animation() -> void:
	if not is_instance_valid(panel):
		return
	if _entrance_tween and _entrance_tween.is_valid():
		_entrance_tween.kill()
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.82, 0.82)
	panel.modulate.a = 0.0
	_entrance_tween = create_tween().set_parallel(true)
	_entrance_tween.tween_property(panel, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_entrance_tween.tween_property(panel, "modulate:a", 1.0, 0.18)

func _on_run_started() -> void:
	visible = false

func _on_resume_pressed() -> void:
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("pause_run"):
		game_manager_ref.pause_run(false)
	else:
		visible = false
		get_tree().paused = false

func _on_retry_pressed() -> void:
	visible = false
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("restart_run"):
		game_manager_ref.restart_run()

func _on_main_menu_pressed() -> void:
	visible = false
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("pause_run"):
		game_manager_ref.pause_run(false)
	else:
		get_tree().paused = false
	menu_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_on_resume_pressed()
	elif event.is_action_pressed("restart"):
		get_viewport().set_input_as_handled()
		_on_retry_pressed()
