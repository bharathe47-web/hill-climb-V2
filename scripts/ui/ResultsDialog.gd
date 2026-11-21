extends Control
class_name ResultsDialog

signal retry_pressed
signal revive_pressed
signal garage_pressed
signal map_pressed

@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var distance_label: Label = $Panel/VBox/StatsBox/DistBox/DistanceLabel
@onready var best_label: Label = $Panel/VBox/StatsBox/DistBox/BestLabel
@onready var coins_label: Label = $Panel/VBox/StatsBox/CoinBox/HBox/CoinsLabel
@onready var revive_button: Button = $Panel/VBox/Buttons/ReviveButton
@onready var retry_button: Button = $Panel/VBox/Buttons/RetryButton
@onready var garage_button: Button = $Panel/VBox/Buttons/NavRow/GarageButton
@onready var map_button: Button = $Panel/VBox/Buttons/NavRow/MapButton

func _ready() -> void:
	visible = false
	revive_button.pressed.connect(_on_revive)
	retry_button.pressed.connect(_on_retry)
	garage_button.pressed.connect(_on_garage)
	map_button.pressed.connect(_on_map)
	
	if GameState:
		GameState.game_over_triggered.connect(_on_game_over)

func _on_game_over(reason: String, distance: float, coins_collected: int) -> void:
	title_label.text = reason
	distance_label.text = "%d m" % int(distance)
	
	var best: float = GameState.stage_best_distances.get(GameState.active_stage_id, distance)
	best_label.text = "Best: %d m" % int(best)
	coins_label.text = "+%d" % coins_collected
	
	# Enable revive only if player has at least 50 coins
	revive_button.text = "REVIVE (50 Coins)"
	revive_button.disabled = (GameState.coins < 50)
	
	visible = true
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func _on_revive() -> void:
	if GameState.spend_coins(50):
		visible = false
		GameState.is_game_over = false
		GameState.set_fuel(GameState.max_fuel * 0.5)
		AudioManager.start_engine()
		revive_pressed.emit()

func _on_retry() -> void:
	visible = false
	AudioManager.play_sfx("click")
	retry_pressed.emit()

func _on_garage() -> void:
	visible = false
	AudioManager.play_sfx("click")
	garage_pressed.emit()

func _on_map() -> void:
	visible = false
	AudioManager.play_sfx("click")
	map_pressed.emit()
