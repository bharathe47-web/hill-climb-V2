class_name FuelPickup
extends Area2D

## FuelPickup: Reusable fuel canister pickup providing fuel replenishment.
## Disables on collection, triggers fuel vapor burst particles, and cleanly resets during run restarts.

signal collected(amount: float)

@export var fuel_amount: float = 35.0
@export var is_nitro_pickup: bool = false
@export var nitro_amount: float = 50.0
@export var bob_height: float = 5.0
@export var bob_frequency: float = 3.5
@export var biome_theme: String = "normal":
	set(value):
		if biome_theme != value:
			biome_theme = value
			apply_biome_theme(value)

@onready var visual: Node2D = $Visual
@onready var fuel_animated_sprite: AnimatedSprite2D = get_node_or_null("Visual/FuelAnimatedSprite")
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var popup_label: Label = $PopupLabel
@onready var vapor_particles: CPUParticles2D = get_node_or_null("VaporParticles")
@onready var glow_aura: Polygon2D = get_node_or_null("Visual/GlowAura")
@onready var audio_player: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")

var is_collected: bool = false
var _elapsed: float = 0.0
var _initial_visual_y: float = 0.0

const FUEL_DIR := "res://assets/survival/collectibles/fuel/"
static var _fuel_frames_cache: SpriteFrames = null

static func _get_frames() -> SpriteFrames:
	if _fuel_frames_cache != null:
		return _fuel_frames_cache
	var sf := SpriteFrames.new()
	sf.remove_animation(&"default")
	sf.add_animation(&"default")
	sf.set_animation_speed(&"default", 6.0)
	sf.set_animation_loop(&"default", true)
	for i in range(1, 7):
		sf.add_frame(&"default", load("%sfuel_frame_%02d.png" % [FUEL_DIR, i]))
	_fuel_frames_cache = sf
	return sf

func _ready() -> void:
	collision_layer = 4
	collision_mask = 2 # Vehicle layer
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	if not is_nitro_pickup and is_instance_valid(fuel_animated_sprite):
		if fuel_animated_sprite.sprite_frames == null:
			fuel_animated_sprite.sprite_frames = _get_frames()
		if not fuel_animated_sprite.is_playing():
			fuel_animated_sprite.play(&"default")
	if is_instance_valid(visual):
		_initial_visual_y = visual.position.y
	if is_instance_valid(popup_label):
		popup_label.visible = false
	if is_instance_valid(vapor_particles):
		vapor_particles.emitting = false
	if is_nitro_pickup:
		if is_instance_valid(glow_aura):
			glow_aura.color = Color(0.1, 0.75, 1.0, 0.40)
		if is_instance_valid(vapor_particles):
			vapor_particles.color = Color(0.2, 0.85, 1.0, 1.0)

func _process(delta: float) -> void:
	if not is_collected and is_instance_valid(visual):
		_elapsed += delta
		visual.position.y = _initial_visual_y - (sin(_elapsed * bob_frequency) * 0.5 + 0.5) * bob_height
		if is_instance_valid(glow_aura):
			var pulse := (sin(_elapsed * 4.0) * 0.15) + 0.85
			glow_aura.scale = Vector2(pulse, pulse)

func _find_vehicle(node: Node) -> Node:
	var curr: Node = node
	while curr != null and curr != get_tree().root:
		if is_nitro_pickup and curr.has_method("refill_nitro"):
			return curr
		elif not is_nitro_pickup and curr.has_method("refuel"):
			return curr
		elif curr.is_in_group("vehicle") or curr.name == "Vehicle":
			var p := curr
			while p != null and p != get_tree().root:
				if is_nitro_pickup and p.has_method("refill_nitro"):
					return p
				elif not is_nitro_pickup and p.has_method("refuel"):
					return p
				p = p.get_parent()
			return curr
		curr = curr.get_parent()
	return null

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	var veh = _find_vehicle(body)
	if veh != null:
		_collect(veh)

func _on_area_entered(area: Area2D) -> void:
	if is_collected:
		return
	var veh = _find_vehicle(area)
	if veh != null:
		_collect(veh)

func _collect(target_vehicle: Node) -> void:
	if is_collected:
		return
	is_collected = true
	
	if is_nitro_pickup:
		collected.emit(nitro_amount)
		if target_vehicle != null and target_vehicle.has_method("refill_nitro"):
			target_vehicle.refill_nitro(nitro_amount)
	else:
		collected.emit(fuel_amount)
		if target_vehicle != null and target_vehicle.has_method("refuel"):
			target_vehicle.refuel(fuel_amount)
	
	# Visual & Audio collection feedback
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", true)
	if is_instance_valid(audio_player):
		audio_player.play()
	if is_instance_valid(visual):
		visual.visible = false
		
	if is_instance_valid(vapor_particles):
		vapor_particles.restart()
		vapor_particles.emitting = true
	
	if is_nitro_pickup:
		_show_popup("+%.0f NITRO" % nitro_amount, Color(0.15, 0.85, 1.0))
	else:
		_show_popup("+%.0f FUEL" % fuel_amount, Color(0.2, 0.95, 0.35))

func _show_popup(text_val: String, color_val: Color) -> void:
	if not is_instance_valid(popup_label):
		return
	popup_label.text = text_val
	popup_label.modulate = color_val
	popup_label.visible = true
	popup_label.position = Vector2(-30, -20)
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup_label, "position:y", -54.0, 0.6)
	tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(func(): popup_label.visible = false)

func reset_pickup() -> void:
	is_collected = false
	_elapsed = 0.0
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", false)
	if is_instance_valid(visual):
		visual.visible = true
		visual.position.y = _initial_visual_y
		visual.scale = Vector2.ONE
	if is_instance_valid(fuel_animated_sprite):
		fuel_animated_sprite.play(&"default")
	if is_instance_valid(popup_label):
		popup_label.visible = false
	if is_instance_valid(vapor_particles):
		vapor_particles.emitting = false
	if is_nitro_pickup:
		if is_instance_valid(glow_aura):
			glow_aura.color = Color(0.1, 0.75, 1.0, 0.40)
		if is_instance_valid(vapor_particles):
			vapor_particles.color = Color(0.2, 0.85, 1.0, 1.0)
	else:
		apply_biome_theme(biome_theme)

## Applies optional thematic visual styling per biome without changing collision or fuel replenishment
func apply_biome_theme(theme_name: String) -> void:
	if biome_theme != theme_name:
		biome_theme = theme_name
	match theme_name.to_lower():
		"heaven":
			if is_instance_valid(glow_aura):
				glow_aura.color = Color(0.85, 0.95, 1.0, 0.35)
		"hell":
			if is_instance_valid(glow_aura):
				glow_aura.color = Color(1.0, 0.4, 0.1, 0.35)
		_:
			if is_instance_valid(glow_aura):
				glow_aura.color = Color(0.2, 0.8, 0.3, 0.22)
