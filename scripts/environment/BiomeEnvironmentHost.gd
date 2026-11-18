class_name BiomeEnvironmentHost
extends Node2D

## BiomeEnvironmentHost: Runtime coordinator for live biome switching, multi-world parallax,
## audio crossfading (Music & Ambience buses), and performance-optimized VFX culling.
## Completely continuous Endless Map drive with zero scene reload between worlds.

signal biome_transition_started(from_biome: int, to_biome: int, transition_state: int)
signal biome_transition_completed(current_biome: int)
signal audio_crossfade_completed(bus_name: String, stream_name: String)

@export_group("Progression & Terrain")
@export var progression_controller: BiomeProgressionController
@export var terrain_generator: TerrainGenerator
@export var auto_spawn_transition_ramps: bool = true

@export_group("Environment Roots")
@export var normal_environment: Node
@export var heaven_environment: Node
@export var hell_environment: Node

@export_group("Terrain Profiles")
@export var normal_terrain_profile: Resource = preload("res://assets/terrain/profiles/normal_land_profile.tres")
@export var heaven_terrain_profile: Resource = preload("res://assets/terrain/profiles/heaven_terrain_profile.tres")
@export var hell_terrain_profile: Resource = preload("res://assets/terrain/profiles/hell_terrain_profile.tres")

@export_group("Audio Settings")
@export var enable_audio_crossfade: bool = true
@export var music_crossfade_duration: float = 2.0
@export var ambience_crossfade_duration: float = 2.0
@export var normal_music_volume_db: float = -10.0
@export var heaven_music_volume_db: float = -10.0
@export var hell_music_volume_db: float = -8.0
@export var normal_ambience_volume_db: float = -14.0
@export var heaven_ambience_volume_db: float = -14.0
@export var hell_ambience_volume_db: float = -12.0

# Preloaded Audio Streams
const STREAM_NORMAL_MUSIC: AudioStream = preload("res://assets/audio/music/background_music_happy_adventure.mp3")
const STREAM_NORMAL_AMBIENCE: AudioStream = preload("res://assets/audio/ambience/countryside_wind_ambience.wav")

const STREAM_HEAVEN_MUSIC: AudioStream = preload("res://assets/environments/heaven/audio/heavenly_loop.ogg")
const STREAM_HEAVEN_AMBIENCE: AudioStream = preload("res://assets/environments/heaven/audio/ambience_wind_soft.mp3")
const STREAM_HEAVEN_STINGER: AudioStream = preload("res://assets/environments/heaven/audio/wind_chimes_settle.mp3")

const STREAM_HELL_MUSIC: AudioStream = preload("res://assets/environments/hell/audio/hell_insistent_loop.ogg")
const STREAM_HELL_AMBIENCE: AudioStream = preload("res://assets/environments/hell/audio/hell_fire_crackle.ogg")
const STREAM_HELL_RUMBLE: AudioStream = preload("res://assets/environments/hell/audio/hell_dark_ambient.ogg")
const STREAM_LANDING_THUD: AudioStream = preload("res://assets/audio/sfx/vehicle/vehicle_landing_thud.wav")

@export var follow_camera: FollowCamera

# Audio Channels for smooth independent crossfading
var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer
var _inactive_music_player: AudioStreamPlayer
var _music_tween: Tween

var _ambience_player_a: AudioStreamPlayer
var _ambience_player_b: AudioStreamPlayer
var _active_ambience_player: AudioStreamPlayer
var _inactive_ambience_player: AudioStreamPlayer
var _ambience_tween: Tween

var _stinger_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer

# Transition Presentation Overlays (Phase 5)
var _overlay_layer: CanvasLayer
var _heaven_golden_flash: ColorRect
var _hell_darkness_vignette: ColorRect
var _cloud_tunnel_overlay: ColorRect
var _geyser_escape_flash: ColorRect

# Runtime State Tracking
var current_biome: int = 0 # WorldCycleSchedule.BiomeType.NORMAL_LAND
var current_world_state: int = 0 # WorldCycleSchedule.WorldState.NORMAL_LAND_1
var is_in_transition: bool = false
var current_transition_progress: float = 0.0
var _is_audio_paused: bool = false
var _last_spawned_ramp_state: int = -1
var _transition_lock: bool = false

func _ready() -> void:
	_init_transition_overlays()
	_setup_audio_players()
	_resolve_environment_references()
	_apply_initial_visual_state()
	
	if progression_controller:
		_bind_progression_controller(progression_controller)

## Binds an external BiomeProgressionController to drive live runtime switching
func bind_progression_controller(controller: BiomeProgressionController) -> void:
	progression_controller = controller
	_bind_progression_controller(controller)
	if controller:
		var info: Dictionary = controller.get_current_state_info()
		if not info.is_empty():
			_on_progression_state_changed(-1, controller.current_state, info)

func _bind_progression_controller(controller: BiomeProgressionController) -> void:
	if not controller.state_changed.is_connected(_on_progression_state_changed):
		controller.state_changed.connect(_on_progression_state_changed)
	if not controller.transition_progress_updated.is_connected(_on_transition_progress_updated):
		controller.transition_progress_updated.connect(_on_transition_progress_updated)
	if not controller.progression_reset.is_connected(_on_progression_reset):
		controller.progression_reset.connect(_on_progression_reset)
	if not controller.cycle_completed.is_connected(_on_cycle_completed):
		controller.cycle_completed.connect(_on_cycle_completed)
	if not controller.nitro_launch_activated.is_connected(_on_nitro_launch_activated):
		controller.nitro_launch_activated.connect(_on_nitro_launch_activated)
	if not controller.heaven_portal_entered.is_connected(_on_heaven_portal_entered):
		controller.heaven_portal_entered.connect(_on_heaven_portal_entered)
	if not controller.hell_portal_entered.is_connected(_on_hell_portal_entered):
		controller.hell_portal_entered.connect(_on_hell_portal_entered)
	if not controller.return_portal_entered.is_connected(_on_return_portal_entered):
		controller.return_portal_entered.connect(_on_return_portal_entered)
	if not controller.biome_changed.is_connected(_on_biome_changed):
		controller.biome_changed.connect(_on_biome_changed)

## Setup dual audio channels for clickless, non-leaking crossfading
func _setup_audio_players() -> void:
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.name = "MusicPlayerA"
	_music_player_a.bus = &"Music"
	add_child(_music_player_a)

	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.name = "MusicPlayerB"
	_music_player_b.bus = &"Music"
	add_child(_music_player_b)

	_active_music_player = _music_player_a
	_inactive_music_player = _music_player_b

	_ambience_player_a = AudioStreamPlayer.new()
	_ambience_player_a.name = "AmbiencePlayerA"
	_ambience_player_a.bus = &"Ambience"
	add_child(_ambience_player_a)

	_ambience_player_b = AudioStreamPlayer.new()
	_ambience_player_b.name = "AmbiencePlayerB"
	_ambience_player_b.bus = &"Ambience"
	add_child(_ambience_player_b)

	_active_ambience_player = _ambience_player_a
	_inactive_ambience_player = _ambience_player_b

	_stinger_player = AudioStreamPlayer.new()
	_stinger_player.name = "StingerPlayer"
	_stinger_player.bus = &"Music"
	add_child(_stinger_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.name = "TransitionSFXPlayer"
	_sfx_player.bus = &"SFX"
	if is_instance_valid(_overlay_layer):
		_overlay_layer.add_child(_sfx_player)
	else:
		add_child(_sfx_player)

	# Start initial Normal Land audio
	_active_music_player.stream = STREAM_NORMAL_MUSIC
	_active_music_player.volume_db = normal_music_volume_db
	if is_inside_tree():
		_active_music_player.play()

	_active_ambience_player.stream = STREAM_NORMAL_AMBIENCE
	_active_ambience_player.volume_db = normal_ambience_volume_db
	if is_inside_tree():
		_active_ambience_player.play()

func _init_transition_overlays() -> void:
	if is_instance_valid(_overlay_layer):
		return
	
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.name = "TransitionOverlayLayer"
	_overlay_layer.layer = 5 # Below HUD (10), above world (0)
	
	_heaven_golden_flash = ColorRect.new()
	_heaven_golden_flash.name = "HeavenGoldenFlash"
	_heaven_golden_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_heaven_golden_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_heaven_golden_flash.color = Color(1.0, 0.95, 0.75, 0.0)
	_overlay_layer.add_child(_heaven_golden_flash)
	
	_hell_darkness_vignette = ColorRect.new()
	_hell_darkness_vignette.name = "HellDarknessVignette"
	_hell_darkness_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hell_darkness_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_hell_darkness_vignette.color = Color(0.12, 0.02, 0.02, 0.0)
	_overlay_layer.add_child(_hell_darkness_vignette)
	
	_cloud_tunnel_overlay = ColorRect.new()
	_cloud_tunnel_overlay.name = "CloudTunnelOverlay"
	_cloud_tunnel_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cloud_tunnel_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cloud_tunnel_overlay.color = Color(0.95, 0.98, 1.0, 0.0)
	_overlay_layer.add_child(_cloud_tunnel_overlay)
	
	_geyser_escape_flash = ColorRect.new()
	_geyser_escape_flash.name = "GeyserEscapeFlash"
	_geyser_escape_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_geyser_escape_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_geyser_escape_flash.color = Color(1.0, 0.45, 0.15, 0.0)
	_overlay_layer.add_child(_geyser_escape_flash)
	
	add_child(_overlay_layer)

func _resolve_environment_references() -> void:
	if not follow_camera and is_inside_tree():
		var tree_root := get_tree().root
		if tree_root:
			var cam = tree_root.find_child("FollowCamera", true, false)
			if is_instance_valid(cam) and cam is FollowCamera:
				follow_camera = cam
	# Check direct children first (e.g. when instantiated from BiomeEnvironmentHost.tscn)
	if not normal_environment:
		var cand: Node = get_node_or_null("ParallaxEnvironment")
		if cand and is_instance_valid(cand) and not cand.is_queued_for_deletion():
			normal_environment = cand
		elif get_parent():
			var p_cand: Node = get_parent().find_child("ParallaxEnvironment", true, false)
			if p_cand and is_instance_valid(p_cand) and not p_cand.is_queued_for_deletion():
				normal_environment = p_cand
		if not normal_environment:
			var normal_packed: PackedScene = load("res://scenes/environment/ParallaxEnvironment.tscn")
			if normal_packed:
				normal_environment = normal_packed.instantiate()
				add_child(normal_environment)

	if not heaven_environment:
		var cand: Node = get_node_or_null("HeavenEnvironment")
		if cand and is_instance_valid(cand) and not cand.is_queued_for_deletion():
			heaven_environment = cand
		elif get_parent():
			var p_cand: Node = get_parent().find_child("HeavenEnvironment", true, false)
			if p_cand and is_instance_valid(p_cand) and not p_cand.is_queued_for_deletion():
				heaven_environment = p_cand
		if not heaven_environment:
			var heaven_packed: PackedScene = load("res://scenes/environment/heaven/HeavenEnvironment.tscn")
			if heaven_packed:
				heaven_environment = heaven_packed.instantiate()
				add_child(heaven_environment)

	if not hell_environment:
		var cand: Node = get_node_or_null("HellEnvironment")
		if cand and is_instance_valid(cand) and not cand.is_queued_for_deletion():
			hell_environment = cand
		elif get_parent():
			var p_cand: Node = get_parent().find_child("HellEnvironment", true, false)
			if p_cand and is_instance_valid(p_cand) and not p_cand.is_queued_for_deletion():
				hell_environment = p_cand
		if not hell_environment:
			var hell_packed: PackedScene = load("res://scenes/environment/hell/HellEnvironment.tscn")
			if hell_packed:
				hell_environment = hell_packed.instantiate()
				add_child(hell_environment)

	# If terrain_generator is not wired, search under parent or scene tree
	if not terrain_generator:
		var parent_node := get_parent()
		if parent_node:
			terrain_generator = parent_node.find_child("TerrainGenerator", true, false) as TerrainGenerator

func _apply_initial_visual_state() -> void:
	activate_biome_exclusive(WorldCycleSchedule.BiomeType.NORMAL_LAND)

## Safe profile resolver providing cosmetic fallback without breaking physics
func _get_safe_profile(requested_profile: Resource) -> Resource:
	if requested_profile != null:
		return requested_profile
	if normal_terrain_profile != null:
		return normal_terrain_profile
	# Ultimate fallback: generate dynamic fallback profile
	var fallback := BiomeTerrainProfile.create_normal_land_profile()
	return fallback

## Authoritative, mutually exclusive biome activation.
## Exactly ONE environment root is active/visible; the other two are completely hidden and stopped.
func activate_biome_exclusive(target_biome: int) -> void:
	current_biome = target_biome
	var is_normal: bool = (target_biome == WorldCycleSchedule.BiomeType.NORMAL_LAND)
	var is_heaven: bool = (target_biome == WorldCycleSchedule.BiomeType.HEAVEN)
	var is_hell: bool = (target_biome == WorldCycleSchedule.BiomeType.HELL)

	_set_hierarchy_active(normal_environment, is_normal)
	_set_hierarchy_active(heaven_environment, is_heaven)
	_set_hierarchy_active(hell_environment, is_hell)

	if terrain_generator and is_instance_valid(terrain_generator):
		terrain_generator.cull_outgoing_decorations(target_biome)
		match target_biome:
			WorldCycleSchedule.BiomeType.HEAVEN:
				terrain_generator.active_terrain_profile = _get_safe_profile(heaven_terrain_profile)
			WorldCycleSchedule.BiomeType.HELL:
				terrain_generator.active_terrain_profile = _get_safe_profile(hell_terrain_profile)
			_:
				terrain_generator.active_terrain_profile = _get_safe_profile(normal_terrain_profile)

## Recursively toggles visibility, processes, particle emissions, and animations for an environment root
func _set_hierarchy_active(root_node: Node, active: bool) -> void:
	if not is_instance_valid(root_node) or root_node.is_queued_for_deletion():
		return

	if root_node.has_method("set_environment_active"):
		root_node.set_environment_active(active)
	else:
		if "visible" in root_node:
			root_node.visible = active
		root_node.set_process(active)
		root_node.set_physics_process(active)

	_recursive_walk_active(root_node, active)

func _recursive_walk_active(node: Node, active: bool) -> void:
	for child in node.get_children():
		if child is CanvasItem:
			child.visible = active
			child.modulate.a = 1.0 if active else 0.0
		elif child is CanvasLayer:
			child.visible = active

		if child is CPUParticles2D or child is GPUParticles2D:
			child.emitting = active
			if not active:
				child.restart()

		if child is AnimatedSprite2D:
			if active:
				child.play()
			else:
				child.pause()

		child.set_process(active)
		child.set_physics_process(active)

		if child.get_child_count() > 0:
			_recursive_walk_active(child, active)

## Sets visual opacity and automatically enables/disables processes and emitters (delegates to exclusive activation)
func _set_environment_opacity(env: Node, alpha: float) -> void:
	if not is_instance_valid(env) or env.is_queued_for_deletion():
		return
	var is_visible := alpha > 0.5
	_set_hierarchy_active(env, is_visible)

## Handles state transition from BiomeProgressionController
func _on_progression_state_changed(old_state: int, new_state: int, state_info: Dictionary) -> void:
	current_world_state = new_state
	is_in_transition = state_info.get("is_transition", false)
	var target_biome: int = state_info.get("biome", 0)

	match new_state:
		WorldCycleSchedule.WorldState.NORMAL_LAND_1, WorldCycleSchedule.WorldState.NORMAL_LAND_2, \
		WorldCycleSchedule.WorldState.NORMAL_APPROACH, WorldCycleSchedule.WorldState.RAMP_WARNING, \
		WorldCycleSchedule.WorldState.LAUNCH_WINDOW, WorldCycleSchedule.WorldState.NORMAL_MERGE:
			_enter_normal_land_state()

		WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HEAVEN, WorldCycleSchedule.WorldState.HEAVEN_ENTRY:
			_enter_transition_to_heaven()

		WorldCycleSchedule.WorldState.HEAVEN, WorldCycleSchedule.WorldState.HEAVEN_ACTIVE:
			_enter_heaven_state()

		WorldCycleSchedule.WorldState.TRANSITION_HEAVEN_TO_NORMAL:
			_enter_transition_from_heaven()

		WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HELL, WorldCycleSchedule.WorldState.HELL_ENTRY:
			_enter_transition_to_hell()

		WorldCycleSchedule.WorldState.HELL, WorldCycleSchedule.WorldState.HELL_ACTIVE:
			_enter_hell_state()

		WorldCycleSchedule.WorldState.TRANSITION_HELL_TO_NORMAL:
			_enter_transition_from_hell()

		WorldCycleSchedule.WorldState.EXIT_TRANSITION:
			if state_info.get("from_biome", -1) == WorldCycleSchedule.BiomeType.HEAVEN:
				_enter_transition_from_heaven()
			else:
				_enter_transition_from_hell()

## Transition progress update (no visual opacity crossfades — atomic portal switching only)
func _on_transition_progress_updated(progress: float, _transition_state: int) -> void:
	current_transition_progress = progress

# ----------------------------------------------------
# State Entry Handlers
# ----------------------------------------------------

## Explicitly activates the visual and audio state for a specific biome
func apply_biome_state(biome_type: int) -> void:
	match biome_type:
		WorldCycleSchedule.BiomeType.HEAVEN:
			_enter_heaven_state()
		WorldCycleSchedule.BiomeType.HELL:
			_enter_hell_state()
		_:
			_enter_normal_land_state()

func _enter_normal_land_state() -> void:
	_last_spawned_ramp_state = -1
	activate_biome_exclusive(WorldCycleSchedule.BiomeType.NORMAL_LAND)

	# Reset transition overlays
	if is_instance_valid(_heaven_golden_flash):
		_heaven_golden_flash.color.a = 0.0
	if is_instance_valid(_hell_darkness_vignette):
		_hell_darkness_vignette.color.a = 0.0
	if is_instance_valid(_cloud_tunnel_overlay):
		_cloud_tunnel_overlay.color.a = 0.0
	if is_instance_valid(_geyser_escape_flash):
		_geyser_escape_flash.color.a = 0.0

	crossfade_music(STREAM_NORMAL_MUSIC, normal_music_volume_db, music_crossfade_duration)
	crossfade_ambience(STREAM_NORMAL_AMBIENCE, normal_ambience_volume_db, ambience_crossfade_duration)
	biome_transition_completed.emit(current_biome)

func _should_spawn_sequential_ramps() -> bool:
	if not auto_spawn_transition_ramps or not terrain_generator:
		return false
	if terrain_generator.enable_branching_encounters:
		return false
	if progression_controller and progression_controller.schedule:
		if progression_controller.schedule.schedule_mode == WorldCycleSchedule.ScheduleMode.BRANCHING_1000M:
			return false
		if progression_controller.schedule.schedule_mode == WorldCycleSchedule.ScheduleMode.RECURRING_900M:
			return false
	return true

func _enter_transition_to_heaven() -> void:
	biome_transition_started.emit(current_biome, WorldCycleSchedule.BiomeType.HEAVEN, WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HEAVEN)
	
	# Spawn Transition Ramp 1: Normal Land -> Heaven (sequential mode only)
	if _should_spawn_sequential_ramps() and _last_spawned_ramp_state != WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HEAVEN:
		_last_spawned_ramp_state = WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HEAVEN
		var heaven_prof := _get_safe_profile(heaven_terrain_profile)
		terrain_generator.spawn_transition_ramp(
			TerrainSegment.SegmentType.RAMP_NORMAL_TO_HEAVEN,
			1200.0, -100.0, 95.0, 0.0, heaven_prof
		)

	# Play celestial entry chime stinger
	if _stinger_player and STREAM_HEAVEN_STINGER and is_inside_tree():
		_stinger_player.stream = STREAM_HEAVEN_STINGER
		_stinger_player.volume_db = -8.0
		_stinger_player.play()

	# Heaven Ascent Golden Light presentation (Phase 5)
	if is_instance_valid(_heaven_golden_flash):
		var tw := create_tween()
		tw.tween_property(_heaven_golden_flash, "color:a", 0.32, 0.35).set_trans(Tween.TRANS_SINE)
		tw.tween_property(_heaven_golden_flash, "color:a", 0.0, 1.3).set_trans(Tween.TRANS_SINE)

	if is_instance_valid(_hell_darkness_vignette):
		_hell_darkness_vignette.color.a = 0.0

func _enter_heaven_state() -> void:
	_last_spawned_ramp_state = -1
	activate_biome_exclusive(WorldCycleSchedule.BiomeType.HEAVEN)
	crossfade_music(STREAM_HEAVEN_MUSIC, heaven_music_volume_db, music_crossfade_duration)
	crossfade_ambience(STREAM_HEAVEN_AMBIENCE, heaven_ambience_volume_db, ambience_crossfade_duration)
	biome_transition_completed.emit(current_biome)

func _enter_transition_from_heaven() -> void:
	biome_transition_started.emit(current_biome, WorldCycleSchedule.BiomeType.NORMAL_LAND, WorldCycleSchedule.WorldState.TRANSITION_HEAVEN_TO_NORMAL)

	# Spawn Transition Ramp 2: Heaven -> Normal Land (sequential mode only)
	if _should_spawn_sequential_ramps() and _last_spawned_ramp_state != WorldCycleSchedule.WorldState.TRANSITION_HEAVEN_TO_NORMAL:
		_last_spawned_ramp_state = WorldCycleSchedule.WorldState.TRANSITION_HEAVEN_TO_NORMAL
		var normal_prof := _get_safe_profile(normal_terrain_profile)
		terrain_generator.spawn_transition_ramp(
			TerrainSegment.SegmentType.RAMP_HEAVEN_TO_NORMAL,
			1200.0, 100.0, 90.0, 0.0, normal_prof
		)

	# Cloud Tunnel presentation on return descent (Phase 5)
	if is_instance_valid(_cloud_tunnel_overlay):
		var tw := create_tween()
		tw.tween_property(_cloud_tunnel_overlay, "color:a", 0.28, 0.4).set_trans(Tween.TRANS_SINE)
		tw.tween_property(_cloud_tunnel_overlay, "color:a", 0.0, 1.2).set_trans(Tween.TRANS_SINE)

func _enter_transition_to_hell() -> void:
	biome_transition_started.emit(current_biome, WorldCycleSchedule.BiomeType.HELL, WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HELL)

	# Spawn Transition Ramp 3: Normal Land -> Hell (sequential mode only)
	if _should_spawn_sequential_ramps() and _last_spawned_ramp_state != WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HELL:
		_last_spawned_ramp_state = WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HELL
		var hell_prof := _get_safe_profile(hell_terrain_profile)
		terrain_generator.spawn_transition_ramp(
			TerrainSegment.SegmentType.RAMP_NORMAL_TO_HELL,
			1200.0, 80.0, 110.0, 0.0, hell_prof
		)

	# Hell Descent Atmospheric Darkening & Rumble presentation (Phase 5)
	if is_instance_valid(_hell_darkness_vignette):
		var tw := create_tween()
		tw.tween_property(_hell_darkness_vignette, "color:a", 0.38, 0.45).set_trans(Tween.TRANS_SINE)
		tw.tween_property(_hell_darkness_vignette, "color:a", 0.16, 1.0).set_trans(Tween.TRANS_SINE)

	if is_instance_valid(_heaven_golden_flash):
		_heaven_golden_flash.color.a = 0.0

	if _stinger_player and STREAM_HELL_RUMBLE and is_inside_tree():
		_stinger_player.stream = STREAM_HELL_RUMBLE
		_stinger_player.volume_db = -6.0
		_stinger_player.play()

	if is_instance_valid(follow_camera):
		follow_camera.trigger_hell_rumble()

func _enter_hell_state() -> void:
	_last_spawned_ramp_state = -1
	activate_biome_exclusive(WorldCycleSchedule.BiomeType.HELL)
	crossfade_music(STREAM_HELL_MUSIC, hell_music_volume_db, music_crossfade_duration)
	crossfade_ambience(STREAM_HELL_AMBIENCE, hell_ambience_volume_db, ambience_crossfade_duration)
	biome_transition_completed.emit(current_biome)

func _enter_transition_from_hell() -> void:
	biome_transition_started.emit(current_biome, WorldCycleSchedule.BiomeType.NORMAL_LAND, WorldCycleSchedule.WorldState.TRANSITION_HELL_TO_NORMAL)

	# Spawn Transition Ramp 4: Hell -> Normal Land (sequential mode only)
	if _should_spawn_sequential_ramps() and _last_spawned_ramp_state != WorldCycleSchedule.WorldState.TRANSITION_HELL_TO_NORMAL:
		_last_spawned_ramp_state = WorldCycleSchedule.WorldState.TRANSITION_HELL_TO_NORMAL
		var normal_prof := _get_safe_profile(normal_terrain_profile)
		terrain_generator.spawn_transition_ramp(
			TerrainSegment.SegmentType.RAMP_HELL_TO_NORMAL,
			1200.0, -80.0, 105.0, 0.0, normal_prof
		)

	# Magma Geyser Escape Eruption Flash presentation (Phase 5)
	if is_instance_valid(_geyser_escape_flash):
		var tw := create_tween()
		tw.tween_property(_geyser_escape_flash, "color:a", 0.38, 0.25).set_trans(Tween.TRANS_SINE)
		tw.tween_property(_geyser_escape_flash, "color:a", 0.0, 1.4).set_trans(Tween.TRANS_SINE)

	if is_instance_valid(_hell_darkness_vignette):
		var tw2 := create_tween()
		tw2.tween_property(_hell_darkness_vignette, "color:a", 0.0, 0.8)

## Plays physical landing sound and tactile camera trauma
func play_landing_thud() -> void:
	if _sfx_player and STREAM_LANDING_THUD and is_inside_tree():
		_sfx_player.stream = STREAM_LANDING_THUD
		_sfx_player.volume_db = -6.0
		_sfx_player.play()
	if is_instance_valid(follow_camera):
		follow_camera.trigger_landing_thud()

# ----------------------------------------------------
# Cycle & Reset Handlers
# ----------------------------------------------------

func _on_cycle_completed(old_cycle: int, new_cycle: int) -> void:
	# Cycle rollover verified; state smoothly loops back to Normal Land
	pass

func _on_progression_reset() -> void:
	_transition_lock = false
	current_biome = WorldCycleSchedule.BiomeType.NORMAL_LAND
	current_world_state = WorldCycleSchedule.WorldState.NORMAL_LAND_1
	is_in_transition = false
	current_transition_progress = 0.0
	_last_spawned_ramp_state = -1

	_apply_initial_visual_state()

	# Reset parallax offsets to 0
	if normal_environment and normal_environment.has_method("reset_environment_state"):
		normal_environment.reset_environment_state()
	if heaven_environment and heaven_environment.has_method("reset_environment_state"):
		heaven_environment.reset_environment_state()
	if hell_environment and hell_environment.has_method("reset_environment_state"):
		hell_environment.reset_environment_state()

	# Reset overlay alphas to 0.0
	if is_instance_valid(_heaven_golden_flash):
		_heaven_golden_flash.color.a = 0.0
	if is_instance_valid(_hell_darkness_vignette):
		_hell_darkness_vignette.color.a = 0.0
	if is_instance_valid(_cloud_tunnel_overlay):
		_cloud_tunnel_overlay.color.a = 0.0
	if is_instance_valid(_geyser_escape_flash):
		_geyser_escape_flash.color.a = 0.0

	# Reset audio channels immediately to Normal Land
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
	if _ambience_tween and _ambience_tween.is_valid():
		_ambience_tween.kill()

	_inactive_music_player.stop()
	_inactive_ambience_player.stop()

	_active_music_player.stream = STREAM_NORMAL_MUSIC
	_active_music_player.volume_db = normal_music_volume_db
	if not _active_music_player.playing and is_inside_tree():
		_active_music_player.play()

	_active_ambience_player.stream = STREAM_NORMAL_AMBIENCE
	_active_ambience_player.volume_db = normal_ambience_volume_db
	if not _active_ambience_player.playing and is_inside_tree():
		_active_ambience_player.play()

# ----------------------------------------------------
# Audio Crossfade Engine
# ----------------------------------------------------

func crossfade_music(new_stream: AudioStream, target_db: float, duration: float) -> void:
	if not is_instance_valid(_active_music_player):
		_setup_audio_players()
	if not is_instance_valid(_active_music_player):
		return
		
	if not enable_audio_crossfade or not is_instance_valid(new_stream):
		if _active_music_player:
			_active_music_player.stream = new_stream
			_active_music_player.volume_db = target_db
			if not _active_music_player.playing and is_inside_tree():
				_active_music_player.play()
		return

	if _active_music_player.stream == new_stream and _active_music_player.playing:
		# Already playing requested stream; gently adjust volume if needed
		if not is_equal_approx(_active_music_player.volume_db, target_db):
			var tw := create_tween()
			tw.tween_property(_active_music_player, "volume_db", target_db, 0.5)
		return

	# Swap active and inactive players
	var outgoing := _active_music_player
	var incoming := _inactive_music_player
	_active_music_player = incoming
	_inactive_music_player = outgoing

	incoming.stream = new_stream
	incoming.volume_db = -60.0
	if is_inside_tree():
		incoming.play()

	if duration <= 0.05:
		incoming.volume_db = target_db
		outgoing.volume_db = -60.0
		outgoing.stop()
		audio_crossfade_completed.emit("Music", new_stream.resource_path.get_file())
		return

	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()

	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	_music_tween.tween_property(incoming, "volume_db", target_db, duration)
	_music_tween.tween_property(outgoing, "volume_db", -60.0, duration)
	_music_tween.chain().tween_callback(func():
		outgoing.stop()
		audio_crossfade_completed.emit("Music", new_stream.resource_path.get_file())
	)

func crossfade_ambience(new_stream: AudioStream, target_db: float, duration: float) -> void:
	if not is_instance_valid(_active_ambience_player):
		_setup_audio_players()
	if not is_instance_valid(_active_ambience_player):
		return
		
	if not enable_audio_crossfade or not is_instance_valid(new_stream):
		if _active_ambience_player:
			_active_ambience_player.stream = new_stream
			_active_ambience_player.volume_db = target_db
			if not _active_ambience_player.playing and is_inside_tree():
				_active_ambience_player.play()
		return

	if _active_ambience_player.stream == new_stream and _active_ambience_player.playing:
		if not is_equal_approx(_active_ambience_player.volume_db, target_db):
			var tw := create_tween()
			tw.tween_property(_active_ambience_player, "volume_db", target_db, 0.5)
		return

	var outgoing := _active_ambience_player
	var incoming := _inactive_ambience_player
	_active_ambience_player = incoming
	_inactive_ambience_player = outgoing

	incoming.stream = new_stream
	incoming.volume_db = -60.0
	if is_inside_tree():
		incoming.play()

	if duration <= 0.05:
		incoming.volume_db = target_db
		outgoing.volume_db = -60.0
		outgoing.stop()
		audio_crossfade_completed.emit("Ambience", new_stream.resource_path.get_file())
		return

	if _ambience_tween and _ambience_tween.is_valid():
		_ambience_tween.kill()

	_ambience_tween = create_tween()
	_ambience_tween.set_parallel(true)
	_ambience_tween.tween_property(incoming, "volume_db", target_db, duration)
	_ambience_tween.tween_property(outgoing, "volume_db", -60.0, duration)
	_ambience_tween.chain().tween_callback(func():
		outgoing.stop()
		audio_crossfade_completed.emit("Ambience", new_stream.resource_path.get_file())
	)

## Handles pause / resume state
func set_audio_paused(paused: bool) -> void:
	_is_audio_paused = paused
	if _active_music_player:
		_active_music_player.stream_paused = paused
	if _inactive_music_player and _inactive_music_player.playing:
		_inactive_music_player.stream_paused = paused
	if _active_ambience_player:
		_active_ambience_player.stream_paused = paused
	if _inactive_ambience_player and _inactive_ambience_player.playing:
		_inactive_ambience_player.stream_paused = paused

## Diagnostics and telemetry helper
func get_telemetry() -> Dictionary:
	return {
		"current_biome": current_biome,
		"current_world_state": current_world_state,
		"is_in_transition": is_in_transition,
		"transition_progress": current_transition_progress,
		"active_music_stream": _active_music_player.stream.resource_path.get_file() if _active_music_player and _active_music_player.stream else "",
		"active_ambience_stream": _active_ambience_player.stream.resource_path.get_file() if _active_ambience_player and _active_ambience_player.stream else "",
		"normal_active": normal_environment.get("is_active") if normal_environment and "is_active" in normal_environment else false,
		"heaven_active": heaven_environment.get("is_active") if heaven_environment and "is_active" in heaven_environment else false,
		"hell_active": hell_environment.get("is_active") if hell_environment and "is_active" in hell_environment else false
	}

func play_stinger(strm: AudioStream, vol_db: float = -7.0) -> void:
	if is_instance_valid(_stinger_player) and is_instance_valid(strm) and is_inside_tree():
		_stinger_player.stream = strm
		_stinger_player.volume_db = vol_db
		_stinger_player.play()

func _on_nitro_launch_activated(_cycle_idx: int) -> void:
	if is_instance_valid(_heaven_golden_flash):
		var tw := create_tween()
		tw.tween_property(_heaven_golden_flash, "color:a", 0.45, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(_heaven_golden_flash, "color:a", 0.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	play_stinger(STREAM_HEAVEN_STINGER)

func _on_heaven_portal_entered(_portal_dist_m: float, _cycle_idx: int) -> void:
	if is_instance_valid(_heaven_golden_flash):
		var tw := create_tween()
		tw.tween_property(_heaven_golden_flash, "color:a", 0.45, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(_heaven_golden_flash, "color:a", 0.0, 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	play_stinger(STREAM_HEAVEN_STINGER)

func _on_hell_portal_entered(_portal_dist_m: float, _cycle_idx: int) -> void:
	if is_instance_valid(_hell_darkness_vignette):
		var tw := create_tween()
		tw.tween_property(_hell_darkness_vignette, "color:a", 0.65, 0.15)
		tw.tween_property(_hell_darkness_vignette, "color:a", 0.0, 0.65)
	if is_instance_valid(_geyser_escape_flash):
		var tw2 := create_tween()
		tw2.tween_property(_geyser_escape_flash, "color:a", 0.35, 0.1)
		tw2.tween_property(_geyser_escape_flash, "color:a", 0.0, 0.5)
	play_stinger(STREAM_HELL_RUMBLE)

func _on_return_portal_entered(_portal_dist_m: float, _cycle_idx: int) -> void:
	if is_instance_valid(_cloud_tunnel_overlay):
		var tw := create_tween()
		tw.tween_property(_cloud_tunnel_overlay, "color:a", 0.4, 0.2)
		tw.tween_property(_cloud_tunnel_overlay, "color:a", 0.0, 0.6)

func _on_biome_changed(_old_biome: int, new_biome: int, _cycle_idx: int) -> void:
	apply_biome_state(new_biome)
