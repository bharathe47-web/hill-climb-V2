class_name RouteCompleteScreen
extends Control

## RouteCompleteScreen: Victory screen shown when reaching destination in Indian Roads mode.
## Displays route metrics, bonus coins, and newly unlocked Indian states!

signal replay_pressed
signal next_state_pressed(next_state_id: String)
signal state_selection_pressed
signal return_to_main_menu_requested

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var distance_value_label: Label = %DistanceValue
@onready var checkpoints_value_label: Label = %CheckpointsValue
@onready var time_value_label: Label = %TimeValue
@onready var coins_value_label: Label = %CoinsValue
@onready var replay_button: Button = %ReplayButton
@onready var state_sel_button: Button = %StateSelButton
@onready var menu_button: Button = %MenuButton

var next_unlocked_id: String = ""

func _ready() -> void:
	if is_instance_valid(replay_button):
		replay_button.pressed.connect(func(): replay_pressed.emit())
	if is_instance_valid(state_sel_button):
		state_sel_button.pressed.connect(func(): state_selection_pressed.emit())
	if is_instance_valid(menu_button):
		menu_button.pressed.connect(func(): return_to_main_menu_requested.emit())

func display_results(state_name: String, dest_city: String, distance_m: float, cp_cleared: int, total_cp: int, time_s: float, coins_earned: int, next_state_id: String = "") -> void:
	visible = true
	next_unlocked_id = next_state_id

	if is_instance_valid(title_label):
		title_label.text = "%s DESTINATION REACHED!" % state_name.to_upper()

	if is_instance_valid(subtitle_label):
		if next_unlocked_id != "":
			var next_route := RouteRegistry.get_route(next_unlocked_id)
			subtitle_label.text = "Congratulations! You reached %s!\n🎉 UNLOCKED NEW HIGHWAY: %s!" % [dest_city, next_route.state_name.to_upper()]
		else:
			subtitle_label.text = "Congratulations! You successfully reached %s!" % dest_city

	if is_instance_valid(distance_value_label):
		distance_value_label.text = "%dm" % int(distance_m)
	if is_instance_valid(checkpoints_value_label):
		checkpoints_value_label.text = "%d / %d" % [cp_cleared, total_cp]
	if is_instance_valid(time_value_label):
		time_value_label.text = "%.1fs" % time_s
	if is_instance_valid(coins_value_label):
		coins_value_label.text = "+%d" % coins_earned
