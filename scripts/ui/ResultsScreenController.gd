class_name ResultsScreenController
extends Control

## ResultsScreenController: End-of-run results screen displaying distance, records, rewards, and retry flow.
## Operates decoupled from gameplay via GameManager signals.

@onready var title_label: Label = %TitleLabel
@onready var reason_label: Label = %ReasonLabel
@onready var distance_value_label: Label = %DistanceValueLabel
@onready var best_value_label: Label = %BestValueLabel
@onready var coins_value_label: Label = %CoinsValueLabel
@onready var time_value_label: Label = %TimeValueLabel
@onready var new_record_badge: Label = %NewRecordBadge
@onready var retry_button: Button = %RetryButton
@onready var game_over_audio: AudioStreamPlayer = get_node_or_null("GameOverAudio")
@onready var click_audio: AudioStreamPlayer = get_node_or_null("ClickAudio")
@onready var card_panel: PanelContainer = get_node_or_null("%CardPanel")

var game_manager_ref: Node
var _entrance_tween: Tween = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if is_instance_valid(retry_button):
		retry_button.pressed.connect(_on_retry_pressed)

func bind_game_manager(gm: Node) -> void:
	game_manager_ref = gm
	if not is_instance_valid(gm):
		return
	
	if gm.has_signal("run_finished") and not gm.run_finished.is_connected(_on_run_finished):
		gm.run_finished.connect(_on_run_finished)
	if gm.has_signal("run_started") and not gm.run_started.is_connected(_on_run_started):
		gm.run_started.connect(_on_run_started)
	if gm.has_signal("run_restarted") and not gm.run_restarted.is_connected(_on_run_started):
		gm.run_restarted.connect(_on_run_started)

func _on_run_started() -> void:
	visible = false

func _on_run_finished(final_distance: float, coins: int = 0, reason: String = "") -> void:
	visible = true
	_play_entrance_animation()
	if is_instance_valid(game_over_audio):
		game_over_audio.play()
	
	# Determine title & styling based on finish reason
	match reason:
		"crashed":
			title_label.text = "DRIVER CRASHED!"
			title_label.modulate = Color(0.98, 0.28, 0.24)
			reason_label.text = "Vehicle sustained fatal impact"
		"out_of_fuel":
			title_label.text = "OUT OF FUEL!"
			title_label.modulate = Color(0.98, 0.65, 0.15)
			reason_label.text = "Fuel depleted while ascending"
		_:
			title_label.text = "RUN FINISHED"
			title_label.modulate = Color(0.35, 0.75, 1.0)
			reason_label.text = "Good driving effort!"
	
	var best_dist: float = final_distance
	var is_record: bool = false
	var run_time: float = 0.0
	
	if is_instance_valid(game_manager_ref):
		if "best_distance" in game_manager_ref:
			best_dist = game_manager_ref.best_distance
		if "is_new_record" in game_manager_ref:
			is_record = game_manager_ref.is_new_record
		if "run_time" in game_manager_ref:
			run_time = game_manager_ref.run_time

	# Stats count up from zero in a short, staggered sequence instead of appearing instantly,
	# so the results card reads as a small reveal rather than a static printout.
	_animate_stat_count_up(distance_value_label, final_distance, 0.5, 0.0, func(v: float) -> String: return "%d m" % int(round(v)))
	_animate_stat_count_up(best_value_label, best_dist, 0.5, 0.08, func(v: float) -> String: return "%d m" % int(round(v)))
	_animate_stat_count_up(coins_value_label, float(coins), 0.5, 0.16, func(v: float) -> String: return "+%d" % int(round(v)))
	_animate_stat_count_up(time_value_label, run_time, 0.5, 0.24, func(v: float) -> String: return "%.1f s" % v)
	
	if is_instance_valid(new_record_badge):
		new_record_badge.visible = is_record
	
	if is_instance_valid(retry_button):
		retry_button.grab_focus()

## Animates a stat label counting up from 0 to target_value over `duration` seconds, after an
## optional `delay` (used to stagger the four stats so they reveal one after another rather
## than all at once). `format_fn` turns the current interpolated float into the label's text,
## so each stat can keep its own formatting (whole meters, a "+" prefix, one decimal of time).
func _animate_stat_count_up(label: Label, target_value: float, duration: float, delay: float, format_fn: Callable) -> void:
	if not is_instance_valid(label):
		return
	label.text = format_fn.call(0.0)
	var tw := create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_method(func(v: float) -> void: label.text = format_fn.call(v), 0.0, target_value, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Small scale+fade pop so the results card arrives with a bit of weight instead of snapping
## instantly to full size, mirroring the pause menu's entrance.
func _play_entrance_animation() -> void:
	if not is_instance_valid(card_panel):
		return
	if _entrance_tween and _entrance_tween.is_valid():
		_entrance_tween.kill()
	card_panel.pivot_offset = card_panel.size * 0.5
	card_panel.scale = Vector2(0.82, 0.82)
	card_panel.modulate.a = 0.0
	_entrance_tween = create_tween().set_parallel(true)
	_entrance_tween.tween_property(card_panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_entrance_tween.tween_property(card_panel, "modulate:a", 1.0, 0.2)

func _on_retry_pressed() -> void:
	if is_instance_valid(click_audio):
		click_audio.play()
	visible = false
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("restart_run"):
		game_manager_ref.restart_run()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("restart") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_on_retry_pressed()
