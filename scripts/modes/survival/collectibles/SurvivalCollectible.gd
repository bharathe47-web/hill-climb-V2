class_name SurvivalCollectible
extends Area2D

## SurvivalCollectible: Lightweight coin / fuel-can pickup for Survival Mode.
## A non-solid Area2D (never blocks or pushes the vehicle). It reports a single
## `collected` event when the player vehicle touches it, plays the collected pop
## animation, then frees itself. Effects (coin count, refuel) are applied by the spawner.

enum Kind { COIN, FUEL }

signal collected(kind: int, value: float, pickup: SurvivalCollectible)

const COIN_DIR := "res://assets/survival/collectibles/coins/"
const FUEL_DIR := "res://assets/survival/collectibles/fuel/"
const COIN_SOUND: AudioStream = preload("res://assets/audio/sfx/pickups/coin_collection_sound.wav")
const FUEL_SOUND: AudioStream = preload("res://assets/audio/sfx/pickups/fuel_collection_sound.wav")

## Frames are shared between all instances (built once per kind).
static var _frames_cache: Dictionary = {}

@export var kind: Kind = Kind.COIN
## Coins: coin value. Fuel: fuel units restored.
@export var value: float = 1.0
@export var bob_height: float = 4.0
@export var bob_speed: float = 3.0
## Coin spin speed in radians/sec. Spin is computed every rendered frame (smooth at 60+ fps)
## instead of stepping through the 6-image flipbook at 9 fps, which looked like frame drops.
@export var coin_spin_speed: float = 4.7

## Index of the edge-on image in the coin_rotate_ frames (coin_rotate_04.png).
const COIN_EDGE_FRAME := 3
## Below this |cos(angle)| the squashed face is thinner than the edge-on art, so show the edge image.
const COIN_EDGE_THRESHOLD := 0.145

var is_collected: bool = false

var _sprite: AnimatedSprite2D
var _base_y: float = 0.0
var _time: float = 0.0
var _base_scale: Vector2 = Vector2.ONE
var _spin_angle: float = 0.0

func _ready() -> void:
	# Pickup layer only; detects vehicle bodies (layer 2). Never collides physically.
	collision_layer = 4
	collision_mask = 2
	monitoring = true
	monitorable = false
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_sprite = $Sprite as AnimatedSprite2D
	_sprite.sprite_frames = _get_frames(kind)
	_base_scale = _sprite.scale
	_base_y = _sprite.position.y
	_time = randf() * TAU
	if kind == Kind.COIN:
		# Procedural spin: hold the idle animation and drive the spin ourselves each frame.
		_sprite.animation = &"idle"
		_sprite.stop()
		_spin_angle = randf() * TAU
		_apply_coin_spin()
	else:
		_sprite.play(&"idle")
		_sprite.frame = randi() % 6
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_collected:
		return
	_time += delta * bob_speed
	_sprite.position.y = _base_y - (sin(_time) * 0.5 + 0.5) * bob_height
	if kind == Kind.COIN:
		_spin_angle = fmod(_spin_angle + delta * coin_spin_speed, TAU)
		_apply_coin_spin()

func _apply_coin_spin() -> void:
	var c := cos(_spin_angle)
	var face := absf(c)
	if face < COIN_EDGE_THRESHOLD:
		# Edge-on: the edge art already has the right thickness.
		_sprite.frame = COIN_EDGE_FRAME
		_sprite.scale = _base_scale
	else:
		_sprite.frame = 0
		_sprite.scale = Vector2(_base_scale.x * face, _base_scale.y)
	# Slightly darker while the back side faces the camera, for a subtle 3D cue.
	var shade := 1.0 if c >= 0.0 else 0.88
	_sprite.modulate = Color(shade, shade, shade, 1.0)

func _on_body_entered(body: Node) -> void:
	if is_collected or not _is_vehicle(body):
		return
	is_collected = true
	set_deferred("monitoring", false)
	collected.emit(kind, value, self)
	_play_collect_feedback()

func _is_vehicle(body: Node) -> bool:
	var n: Node = body
	while n != null and n != get_tree().root:
		if n.is_in_group("vehicle"):
			return true
		n = n.get_parent()
	return false

func _play_collect_feedback() -> void:
	var audio := AudioStreamPlayer2D.new()
	audio.stream = COIN_SOUND if kind == Kind.COIN else FUEL_SOUND
	audio.volume_db = -4.0
	add_child(audio)
	audio.play()
	_sprite.speed_scale = 1.0
	_sprite.scale = _base_scale
	_sprite.modulate = Color.WHITE
	_sprite.play(&"pop")
	_sprite.animation_finished.connect(_sprite.hide, CONNECT_ONE_SHOT)
	get_tree().create_timer(0.8).timeout.connect(queue_free)

static func _get_frames(k: int) -> SpriteFrames:
	if _frames_cache.has(k):
		return _frames_cache[k]
	var sf := SpriteFrames.new()
	var dir := COIN_DIR if k == Kind.COIN else FUEL_DIR
	var idle_prefix := "coin_rotate_" if k == Kind.COIN else "fuel_frame_"
	var pop_prefix := "coin_pop_" if k == Kind.COIN else "fuel_pop_"
	sf.remove_animation(&"default")
	sf.add_animation(&"idle")
	sf.set_animation_speed(&"idle", 9.0 if k == Kind.COIN else 6.0)
	sf.set_animation_loop(&"idle", true)
	sf.add_animation(&"pop")
	sf.set_animation_speed(&"pop", 14.0)
	sf.set_animation_loop(&"pop", false)
	for i in range(1, 7):
		sf.add_frame(&"idle", load("%s%s%02d.png" % [dir, idle_prefix, i]))
		sf.add_frame(&"pop", load("%s%s%02d.png" % [dir, pop_prefix, i]))
	_frames_cache[k] = sf
	return sf
