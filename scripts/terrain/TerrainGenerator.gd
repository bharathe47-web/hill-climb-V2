class_name TerrainGenerator
extends Node2D

## TerrainGenerator: Procedural and segmented endless terrain manager.
## Spawns, aligns, recycles, and pools TerrainSegment instances ahead of and behind a target node.
## Intelligently distributes collectible Coin trails and Fuel canisters along terrain curves.
## Guarantees continuous collision geometry with zero gaps between adjacent segments.

signal segment_spawned(segment: TerrainSegment)
signal segment_despawned(segment: TerrainSegment)

@export var terrain_segment_scene: PackedScene = preload("res://scenes/terrain/TerrainSegment.tscn")
@export var coin_scene: PackedScene = preload("res://scenes/pickups/Coin.tscn")
@export var fuel_scene: PackedScene = preload("res://scenes/pickups/FuelPickup.tscn")
@export var target: Node2D
@export var auto_find_target: bool = true

@export_group("Generation Limits")
## How far ahead of the target terrain should be generated (in pixels)
@export var generate_ahead_distance: float = 3000.0
## How far behind the target terrain should be removed (in pixels)
@export var despawn_behind_distance: float = 2000.0
## Default length of each generated terrain segment
@export var default_segment_length: float = 1000.0
## Starting origin position for terrain generation
@export var initial_spawn_point: Vector2 = Vector2(-1200.0, 420.0)

@export_group("Progression & Variety")
## Base amplitude for hills and valleys
@export var base_amplitude: float = 85.0
## Maximum climb or descent height delta per segment
@export var max_height_delta: float = 130.0
## Difficulty increase rate per 100 meters
@export var difficulty_growth: float = 0.15

@export_group("Pickups Distribution")
@export var enable_pickups: bool = true
## Spacing between consecutive fuel canister spawns (in pixels, ~85 meters)
@export var fuel_interval_distance: float = 8500.0
## Probability of generating coins on a procedural segment
@export var coin_spawn_chance: float = 0.75
## Clearance distance above the top ground surface for coin center (px)
@export var coin_surface_clearance: float = 34.0
## Clearance distance above the top ground surface for fuel canister center (px)
@export var fuel_surface_clearance: float = 46.0

@export_group("Biome Profile")
## Active data-driven BiomeTerrainProfile resource (Normal Land, Heaven, or Hell)
@export var active_terrain_profile: Resource = null:
	set(val):
		active_terrain_profile = val

@export_group("Biome Profiles & Portals (Phase 2.3)")
@export var normal_terrain_profile: Resource = preload("res://assets/terrain/profiles/normal_land_profile.tres")
@export var heaven_terrain_profile: Resource = preload("res://assets/terrain/profiles/heaven_terrain_profile.tres")
@export var hell_terrain_profile: Resource = preload("res://assets/terrain/profiles/hell_terrain_profile.tres")
@export var heaven_portal_scene: PackedScene = preload("res://scenes/environment/portals/HeavenPortal.tscn")
@export var hell_portal_scene: PackedScene = preload("res://scenes/environment/portals/HellPortal.tscn")
@export var return_portal_scene: PackedScene = preload("res://scenes/environment/portals/ReturnPortal.tscn")

var active_portals: Array[Node2D] = []
var _spawned_heaven_portal_cycles: Dictionary = {}
var _spawned_hell_portal_cycles: Dictionary = {}
var _spawned_return_portal_cycles: Dictionary = {}

const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")

@export_group("Branching Encounter Mode")
@export var enable_branching_encounters: bool = false

var progression_controller: BiomeProgressionController = null
var active_encounters: Array[Node2D] = []
var _spawned_encounter_indices: Dictionary = {} # enc_idx -> bool

var active_segments: Array[TerrainSegment] = []
var segment_pool: Array[TerrainSegment] = []
var next_attach_point: Vector2 = Vector2.ZERO
var current_slope: float = 0.0
var current_difficulty: float = 1.0
var segment_counter: int = 0
var distance_since_last_fuel: float = 0.0
var total_coins_spawned: int = 0
var total_fuel_spawned: int = 0
var rng := RandomNumberGenerator.new()

# Track all active pickups spawned across segments for clean recycling
var _spawned_pickups: Array[Node2D] = []

func _ready() -> void:
	rng.randomize()
	next_attach_point = initial_spawn_point
	
	if auto_find_target and not is_instance_valid(target):
		_find_target()
	
	# Hook into GameManager restart signal if available in scene tree
	_connect_game_manager_signals()
	
	# Pre-seed initial track with safe starting segment
	_generate_initial_track()

func _connect_game_manager_signals() -> void:
	if not is_inside_tree() or not get_tree():
		return
	var gm := get_tree().root.find_child("GameManager", true, false)
	if is_instance_valid(gm) and gm.has_signal("run_restarted"):
		if not gm.run_restarted.is_connected(_on_game_manager_restarted):
			gm.run_restarted.connect(_on_game_manager_restarted)

func _on_game_manager_restarted() -> void:
	reset_generator(initial_spawn_point)

func _find_target() -> void:
	if not is_inside_tree() or not get_tree():
		return
	# Attempt to locate Vehicle in scene tree
	var vehicle_node = get_tree().get_first_node_in_group("vehicle")
	if is_instance_valid(vehicle_node) and vehicle_node is Node2D:
		target = vehicle_node
		return
	
	# Look for node named "Vehicle" under parent or siblings
	var parent_node := get_parent()
	if parent_node:
		var candidate = parent_node.find_child("Vehicle", true, false)
		if is_instance_valid(candidate) and candidate is Node2D:
			target = candidate
			return
		
		# Alternatively find Camera2D
		var cam = parent_node.find_child("FollowCamera", true, false)
		if is_instance_valid(cam) and cam is Node2D:
			target = cam
			return

func _process(_delta: float) -> void:
	if not is_instance_valid(target):
		if auto_find_target:
			_find_target()
		return
	
	var target_x: float = target.global_position.x
	_update_generation(target_x)
	_update_culling(target_x)

## Generates flat safety stretch followed by introductory gentle hills
func _generate_initial_track() -> void:
	clear_terrain()
	next_attach_point = initial_spawn_point
	current_slope = 0.0
	distance_since_last_fuel = fuel_interval_distance * 0.4 # Pre-charge fuel countdown
	
	# Segment 0: Flat runway at spawn extending through vehicle starting position
	var runway_length: float = maxf(450.0, 150.0 - initial_spawn_point.x)
	var flat_seg := _create_segment(TerrainSegment.SegmentType.FLAT, runway_length, 0.0, 0.0, 0.0, 0.0, 0.0)
	_attach_segment(flat_seg, false)
	
	# Segment 1: Gentle introductory hill with starter coins
	var intro_seg := _create_segment(TerrainSegment.SegmentType.GENTLE_HILLS, 800.0, 0.0, -35.0, 85.0, 0.0, -0.05)
	_attach_segment(intro_seg, true)
	
	# Segment 2: Rolling starter wave with first fuel pickup
	var wave_seg := _create_segment(TerrainSegment.SegmentType.ROLLING_WAVES, 850.0, 0.0, 35.0, 95.0, -0.05, 0.0)
	_attach_segment(wave_seg, true)

func _update_generation(target_x: float) -> void:
	# Keep generating until the end of the track is far enough ahead of the target
	while next_attach_point.x < target_x + generate_ahead_distance:
		if _is_branching_mode_enabled():
			var safe_next_x := maxf(0.0, next_attach_point.x)
			var next_enc_idx: int = int(floor(safe_next_x / 100000.0))
			var gate_x: float = float(next_enc_idx) * 100000.0 + 50000.0 # 500m + (n * 1000m)
			var approach_start_x: float = gate_x - 2000.0

			if not _spawned_encounter_indices.has(next_enc_idx) and next_attach_point.x >= (approach_start_x - default_segment_length):
				# Smooth bridge to approach ramp start if needed
				if next_attach_point.x < approach_start_x:
					var bridge_len := approach_start_x - next_attach_point.x
					var bridge := _create_segment(TerrainSegment.SegmentType.FLAT, bridge_len, 0.0, 420.0 - next_attach_point.y, 0.0, current_slope, 0.0)
					_attach_segment(bridge, enable_pickups)

				# Spawn the branching encounter
				_spawned_encounter_indices[next_enc_idx] = true
				var encounter = BranchingEncounterClass.new()
				encounter.encounter_index = next_enc_idx
				encounter.gate_distance_m = 500.0 + (float(next_enc_idx) * 1000.0)
				if progression_controller:
					encounter.bind_progression_controller(progression_controller)
				add_child(encounter)
				active_encounters.append(encounter)

				# Next attach point resumes at merge point (1,000m)
				next_attach_point = Vector2(gate_x + 50000.0, 420.0)
				current_slope = 0.0
				continue

		if _is_recurring_900m_mode():
			_update_recurring_900m_generation()
			continue

		var seg := _generate_next_procedural_segment()
		_attach_segment(seg, enable_pickups)

func _is_recurring_900m_mode() -> bool:
	if _is_branching_mode_enabled():
		return false
	if is_instance_valid(progression_controller) and progression_controller.schedule:
		return progression_controller.schedule.schedule_mode == WorldCycleSchedule.ScheduleMode.RECURRING_900M
	return true

func get_biome_type_for_world_x(world_x: float) -> int:
	var safe_x := maxf(0.0, world_x)
	var cycle_pos_m := fposmod(safe_x / 100.0, 900.0)
	if cycle_pos_m < 300.0:
		return 0 # WorldCycleSchedule.BiomeType.NORMAL_LAND
	elif cycle_pos_m < 600.0:
		return 1 # WorldCycleSchedule.BiomeType.HEAVEN
	else:
		return 2 # WorldCycleSchedule.BiomeType.HELL

func get_distance_to_next_biome_boundary(world_x: float) -> float:
	var safe_x := maxf(0.0, world_x)
	var cycle_pos_px := fposmod(safe_x, 90000.0)
	if cycle_pos_px < 30000.0:
		return 30000.0 - cycle_pos_px
	elif cycle_pos_px < 60000.0:
		return 60000.0 - cycle_pos_px
	else:
		return 90000.0 - cycle_pos_px

func get_profile_for_world_x(world_x: float) -> Resource:
	var b_type := get_biome_type_for_world_x(world_x)
	match b_type:
		1:
			return heaven_terrain_profile
		2:
			return hell_terrain_profile
		_:
			return normal_terrain_profile

func cull_outgoing_decorations(active_biome: int) -> void:
	for seg in active_segments:
		if is_instance_valid(seg) and seg is TerrainSegment:
			if seg.biome_type != active_biome:
				seg.set_decorations_visible(false)

func _update_recurring_900m_generation() -> void:
	var safe_x: float = maxf(0.0, next_attach_point.x)
	var cycle_idx: int = int(floor(safe_x / 90000.0))
	var cycle_base_x: float = float(cycle_idx) * 90000.0

	# 1. Spawn Return Portal if previous cycle reached 900m boundary
	var prev_cycle := cycle_idx - 1
	if prev_cycle >= 0 and not _spawned_return_portal_cycles.has(prev_cycle):
		_spawned_return_portal_cycles[prev_cycle] = true
		if return_portal_scene:
			var ret_portal: ReturnPortal = return_portal_scene.instantiate() as ReturnPortal
			ret_portal.cycle_index = prev_cycle
			ret_portal.portal_distance_m = float(prev_cycle) * 900.0 + 900.0
			ret_portal.global_position = Vector2(cycle_base_x, next_attach_point.y)
			ret_portal.traversed.connect(func(_p, c_idx): _on_portal_traversed(_p, c_idx, "return"))
			add_child(ret_portal)
			active_portals.append(ret_portal)

	var heaven_start_x: float = cycle_base_x + 30000.0 # 300m
	var hell_start_x: float = cycle_base_x + 60000.0   # 600m
	var return_start_x: float = cycle_base_x + 90000.0 # 900m

	# 2. Normal Land Section [0m, 300m) - Procedural countryside road up to Heaven Portal
	if safe_x < heaven_start_x:
		var dist_to_heaven: float = heaven_start_x - safe_x
		if dist_to_heaven < default_segment_length * 1.35:
			var seg := _generate_next_procedural_segment(dist_to_heaven, normal_terrain_profile)
			_attach_segment(seg, enable_pickups)
		else:
			var seg := _generate_next_procedural_segment(-1.0, normal_terrain_profile)
			_attach_segment(seg, enable_pickups)
		return

	# 3. Heaven Portal Spawning at 300m boundary
	if safe_x >= heaven_start_x and not _spawned_heaven_portal_cycles.has(cycle_idx):
		_spawned_heaven_portal_cycles[cycle_idx] = true
		if heaven_portal_scene:
			var heaven_portal: HeavenPortal = heaven_portal_scene.instantiate() as HeavenPortal
			heaven_portal.cycle_index = cycle_idx
			heaven_portal.portal_distance_m = float(cycle_idx) * 900.0 + 300.0
			heaven_portal.global_position = Vector2(heaven_start_x, next_attach_point.y)
			heaven_portal.traversed.connect(func(_p, c_idx): _on_portal_traversed(_p, c_idx, "heaven"))
			add_child(heaven_portal)
			active_portals.append(heaven_portal)

	# 4. Hell Portal Spawning at 600m boundary
	if safe_x >= hell_start_x and not _spawned_hell_portal_cycles.has(cycle_idx):
		_spawned_hell_portal_cycles[cycle_idx] = true
		if hell_portal_scene:
			var hell_portal: HellPortal = hell_portal_scene.instantiate() as HellPortal
			hell_portal.cycle_index = cycle_idx
			hell_portal.portal_distance_m = float(cycle_idx) * 900.0 + 600.0
			hell_portal.global_position = Vector2(hell_start_x, next_attach_point.y)
			hell_portal.traversed.connect(func(_p, c_idx): _on_portal_traversed(_p, c_idx, "hell"))
			add_child(hell_portal)
			active_portals.append(hell_portal)

	# 5. Heaven Section [300m, 600m)
	if safe_x < hell_start_x:
		var dist_to_hell: float = hell_start_x - safe_x
		if dist_to_hell < default_segment_length * 1.35:
			var seg := _generate_next_procedural_segment(dist_to_hell, heaven_terrain_profile)
			_attach_segment(seg, enable_pickups)
		else:
			var seg := _generate_next_procedural_segment(-1.0, heaven_terrain_profile)
			_attach_segment(seg, enable_pickups)
		return

	# 6. Hell Section [600m, 900m)
	if safe_x < return_start_x:
		var dist_to_return: float = return_start_x - safe_x
		if dist_to_return < default_segment_length * 1.35:
			var seg := _generate_next_procedural_segment(dist_to_return, hell_terrain_profile)
			_attach_segment(seg, enable_pickups)
		else:
			var seg := _generate_next_procedural_segment(-1.0, hell_terrain_profile)
			_attach_segment(seg, enable_pickups)
		return

func _on_portal_traversed(_portal: Node2D, cycle_idx: int, portal_type: String) -> void:
	if portal_type == "heaven":
		cull_outgoing_decorations(1)
		if is_instance_valid(progression_controller):
			progression_controller.update_distance(float(cycle_idx) * 900.0 + 300.0)
	elif portal_type == "hell":
		cull_outgoing_decorations(2)
		if is_instance_valid(progression_controller):
			progression_controller.update_distance(float(cycle_idx) * 900.0 + 600.0)
	elif portal_type == "return":
		cull_outgoing_decorations(0)
		if is_instance_valid(progression_controller):
			progression_controller.update_distance(float(cycle_idx) * 900.0 + 900.0)

func _update_culling(target_x: float) -> void:
	var cull_threshold := target_x - despawn_behind_distance
	while not active_segments.is_empty():
		var first_seg := active_segments[0]
		var exit_global_x := first_seg.global_position.x + first_seg.segment_length
		if exit_global_x < cull_threshold:
			active_segments.remove_at(0)
			segment_despawned.emit(first_seg)
			
			# Recycle pickups attached to this segment
			_cull_pickups_for_segment(first_seg)
			
			# Pool segment instead of freeing to avoid GC spikes
			first_seg.visible = false
			segment_pool.append(first_seg)
		else:
			break

	# Always reconcile encounter nodes. If the controller switches back to the
	# fixed world cycle while an encounter is still alive, remove that obsolete
	# branch instead of leaving it attached forever.
	var branching_enabled := _is_branching_mode_enabled()
	var remaining_enc: Array[Node2D] = []
	for enc in active_encounters:
		if not is_instance_valid(enc):
			continue
		if not branching_enabled:
			enc.queue_free()
			continue
		var gate_dist = enc.get("gate_distance_m")
		var realm_len = enc.get("realm_total_length")
		var exit_x: float = 0.0
		if gate_dist != null and realm_len != null:
			exit_x = (float(gate_dist) * 100.0) + float(realm_len)
		else:
			exit_x = enc.global_position.x
		if exit_x < cull_threshold:
			enc.queue_free()
		else:
			remaining_enc.append(enc)
	active_encounters = remaining_enc

	# Cull portals behind despawn threshold
	var remaining_portals: Array[Node2D] = []
	for portal in active_portals:
		if not is_instance_valid(portal):
			continue
		if portal.global_position.x < cull_threshold:
			portal.queue_free()
		else:
			remaining_portals.append(portal)
	active_portals = remaining_portals

func _cull_pickups_for_segment(seg: TerrainSegment) -> void:
	var remaining: Array[Node2D] = []
	for p in _spawned_pickups:
		if is_instance_valid(p):
			if p.get_parent() == seg or seg.is_ancestor_of(p):
				p.queue_free()
			else:
				remaining.append(p)
	_spawned_pickups = remaining

func _generate_next_procedural_segment(custom_length: float = -1.0, profile_override: Resource = null) -> TerrainSegment:
	segment_counter += 1
	var progress_m := maxf(0.0, (next_attach_point.x - initial_spawn_point.x) / 100.0)
	current_difficulty = 1.0 + (progress_m / 250.0) * difficulty_growth
	current_difficulty = clampf(current_difficulty, 1.0, 3.0)
	
	var dist_to_boundary := get_distance_to_next_biome_boundary(next_attach_point.x)
	var seg_type := _select_segment_type(current_difficulty)
	var seg_length := default_segment_length * rng.randf_range(0.9, 1.25)
	if custom_length > 0.0:
		seg_length = custom_length

	# Strictly clamp segment length so it never crosses a biome boundary
	if seg_length >= dist_to_boundary or dist_to_boundary < default_segment_length * 1.35:
		seg_length = dist_to_boundary

	if profile_override != null:
		active_terrain_profile = profile_override
	else:
		active_terrain_profile = get_profile_for_world_x(next_attach_point.x)

	var amp: float = 0.0
	var height_change: float = 0.0
	var start_slope: float = current_slope
	var target_slope: float = 0.0

	if seg_type == TerrainSegment.SegmentType.FLAT:
		# Relatively flat section to gain speed and momentum
		seg_length = minf(rng.randf_range(600.0, 800.0), dist_to_boundary) if custom_length <= 0.0 else seg_length
		amp = 0.0
		height_change = 0.0
		target_slope = 0.0
	else:
		amp = base_amplitude * clampf(current_difficulty, 1.0, 2.0) * rng.randf_range(0.9, 1.15)
		# Height delta with spring bias towards comfortable baseline y = 380
		height_change = rng.randf_range(-max_height_delta, max_height_delta)
		var center_bias := (380.0 - next_attach_point.y) * 0.35
		height_change = clampf(height_change + center_bias, -max_height_delta, max_height_delta)
		
		# Safety clamp bounds
		var predicted_end_y := next_attach_point.y + height_change
		if predicted_end_y < 180.0:
			height_change = absf(height_change) + 20.0
		elif predicted_end_y > 500.0:
			height_change = -absf(height_change) - 20.0
		
		# Target slope naturally aligns with height change, bounded for smooth drivability (-0.20 to +0.20)
		target_slope = clampf((height_change / seg_length) * 0.85, -0.20, 0.20)
		target_slope += rng.randf_range(-0.03, 0.03)
		target_slope = clampf(target_slope, -0.20, 0.20)
	
	return _create_segment(seg_type, seg_length, 0.0, height_change, amp, start_slope, target_slope)

func _select_segment_type(_diff: float) -> TerrainSegment.SegmentType:
	var roll := rng.randf()
	if roll < 0.60:
		# 60% Gentle rolling terrain (smooth waves, pleasant hills, undulating contours)
		if rng.randf() < 0.55:
			return TerrainSegment.SegmentType.GENTLE_HILLS
		else:
			return TerrainSegment.SegmentType.ROLLING_WAVES
	elif roll < 0.80:
		# 20% Relatively flat sections (moments to gain speed and momentum)
		return TerrainSegment.SegmentType.FLAT
	elif roll < 0.95:
		# 15% Moderate hills and valleys (rewarding climbs, thrilling descents)
		if rng.randf() < 0.50:
			return TerrainSegment.SegmentType.VALLEY_DIP
		else:
			return TerrainSegment.SegmentType.STEEP_CLIMB
	else:
		# 5% Challenging sections (steep climbs, crest jumps, technical dips)
		var c_roll := rng.randf()
		if c_roll < 0.50:
			return TerrainSegment.SegmentType.JUMP_RAMP
		elif c_roll < 0.80:
			return TerrainSegment.SegmentType.DOUBLE_CREST
		else:
			return TerrainSegment.SegmentType.BUMPY_WASHBOARD

func _create_segment(
	type: TerrainSegment.SegmentType,
	length_val: float,
	start_h: float,
	end_h: float,
	amp: float,
	start_s: float = 0.0,
	end_s: float = 0.0
) -> TerrainSegment:
	var seg: TerrainSegment
	
	# Recycle from pool if available
	if not segment_pool.is_empty():
		seg = segment_pool.pop_back()
		seg.visible = true
	elif terrain_segment_scene:
		seg = terrain_segment_scene.instantiate() as TerrainSegment
	else:
		seg = TerrainSegment.new()
	
	seg.start_world_x = next_attach_point.x
	seg.end_world_x = next_attach_point.x + length_val
	seg.start_distance_m = seg.start_world_x / 100.0
	seg.end_distance_m = seg.end_world_x / 100.0
	seg.biome_type = get_biome_type_for_world_x(seg.start_world_x)
	var expected_profile := get_profile_for_world_x(seg.start_world_x)
	if active_terrain_profile != null and get_biome_type_for_world_x(seg.start_world_x) == get_biome_type_for_world_x(next_attach_point.x):
		seg.terrain_profile = active_terrain_profile
	else:
		seg.terrain_profile = expected_profile
	if seg.biome_type == 1:
		seg.is_floating_platform = true
		seg.platform_thickness = 120.0
	else:
		seg.is_floating_platform = false
	seg.segment_type = type
	seg.segment_length = length_val
	seg.start_height = start_h
	seg.end_height = end_h
	seg.amplitude = amp
	seg.start_slope = start_s
	seg.end_slope = end_s
	seg.samples_count = clampi(int(length_val / 28.0), 16, 72)
	seg.rebuild_segment()
	return seg

## Spawns a dedicated transition ramp segment attaching seamlessly to the current track
func spawn_transition_ramp(
	ramp_type: TerrainSegment.SegmentType,
	length_val: float = 1200.0,
	height_change: float = 0.0,
	amp: float = 85.0,
	target_exit_slope: float = 0.0,
	override_profile: Resource = null
) -> TerrainSegment:
	var start_s := current_slope
	var prev_prof := active_terrain_profile
	if override_profile != null:
		active_terrain_profile = override_profile
	var seg := _create_segment(ramp_type, length_val, 0.0, height_change, amp, start_s, target_exit_slope)
	_attach_segment(seg, enable_pickups)
	active_terrain_profile = prev_prof
	return seg

func _attach_segment(seg: TerrainSegment, allow_pickups: bool = true) -> void:
	if seg.get_parent() != self:
		add_child(seg)
	
	seg.global_position = next_attach_point - seg.get_entry_point()
	active_segments.append(seg)
	segment_spawned.emit(seg)
	current_slope = seg.get_exit_slope()
	
	# Spawn collectibles on this segment if requested
	if allow_pickups and enable_pickups:
		_populate_segment_pickups(seg)
	
	# Update next attachment point to match segment's exit point
	var exit_local := seg.get_exit_point()
	next_attach_point = seg.global_position + exit_local
	distance_since_last_fuel += seg.segment_length

func _populate_segment_pickups(seg: TerrainSegment) -> void:
	# 0. Pre-launch nitro boost guarantee: spawn fuel at ~272m (27200px mod 90000px)
	var seg_start_x: float = seg.global_position.x
	var seg_end_x: float = seg_start_x + seg.segment_length
	var safe_start := maxf(0.0, seg_start_x)
	var c_base: float = floor(safe_start / 90000.0) * 90000.0
	var nitro_boost_target: float = c_base + 27200.0
	if seg_start_x <= nitro_boost_target and seg_end_x >= nitro_boost_target and fuel_scene:
		var local_fx: float = clampf(nitro_boost_target - seg_start_x, 50.0, seg.segment_length - 50.0)
		_spawn_fuel_on_segment(seg, local_fx)
		distance_since_last_fuel = 0.0
		return

	# 1. Fuel canister placement
	if distance_since_last_fuel >= fuel_interval_distance and fuel_scene:
		distance_since_last_fuel = 0.0
		_spawn_fuel_on_segment(seg, seg.segment_length * 0.5)
		return # Avoid overcrowding fuel segment with too many coins
	
	# 2. Coin patterns placement
	if rng.randf() <= coin_spawn_chance and coin_scene:
		_spawn_coins_on_segment(seg)

func _spawn_fuel_on_segment(seg: TerrainSegment, local_x: float) -> void:
	var safe_y := _calculate_safe_pickup_y(seg, local_x, fuel_surface_clearance, 18.0)
	var fuel_inst := fuel_scene.instantiate() as Node2D
	seg.add_child(fuel_inst)
	fuel_inst.position = Vector2(local_x, safe_y)
	fuel_inst.add_to_group("pickups")
	if active_terrain_profile and fuel_inst.has_method("apply_biome_theme"):
		fuel_inst.apply_biome_theme(str(active_terrain_profile.get("profile_name")))
	_spawned_pickups.append(fuel_inst)
	total_fuel_spawned += 1

func _calculate_safe_pickup_y(seg: TerrainSegment, local_x: float, base_clearance: float, half_extent: float = 16.0) -> float:
	var center_surf_y := seg.get_surface_y_at(local_x)
	var left_surf_y := seg.get_surface_y_at(maxf(0.0, local_x - half_extent))
	var right_surf_y := seg.get_surface_y_at(minf(seg.segment_length, local_x + half_extent))
	# In Godot 2D coordinates, smaller Y is higher in the air.
	# The highest point of ground across the footprint is minf of the surface Y values.
	var highest_ground_y := minf(center_surf_y, minf(left_surf_y, right_surf_y))
	
	# Target Y maintains at least base_clearance at center and ensures bottom clears highest ground point
	var safe_y := minf(center_surf_y - base_clearance, highest_ground_y - (half_extent + 6.0))
	
	# Verify against collision polygon geometry to ensure no bounding point is inside ground
	if is_instance_valid(seg.collision_polygon) and not seg.collision_polygon.polygon.is_empty():
		var poly := seg.collision_polygon.polygon
		var iterations := 0
		while iterations < 15:
			var test_points := [
				Vector2(local_x, safe_y),
				Vector2(local_x, safe_y + half_extent),
				Vector2(local_x - half_extent * 0.7, safe_y + half_extent * 0.7),
				Vector2(local_x + half_extent * 0.7, safe_y + half_extent * 0.7),
				Vector2(local_x - half_extent, safe_y),
				Vector2(local_x + half_extent, safe_y)
			]
			var penetrated := false
			for pt in test_points:
				if Geometry2D.is_point_in_polygon(pt, poly):
					penetrated = true
					break
			if not penetrated:
				break
			safe_y -= 2.0
			iterations += 1
	return safe_y

func _spawn_coins_on_segment(seg: TerrainSegment) -> void:
	var seg_type := seg.segment_type
	var num_coins := rng.randi_range(3, 5)
	total_coins_spawned += num_coins
	
	match seg_type:
		TerrainSegment.SegmentType.JUMP_RAMP:
			# Arc of coins soaring off the crest lip
			var start_x := seg.segment_length * 0.55
			var span := seg.segment_length * 0.35
			for i in range(num_coins):
				var t := float(i) / float(maxi(1, num_coins - 1))
				var cx := start_x + (t * span)
				var arc_height := sin(t * PI) * 55.0
				var safe_y := _calculate_safe_pickup_y(seg, cx, coin_surface_clearance, 16.0)
				var coin_inst := coin_scene.instantiate() as Node2D
				seg.add_child(coin_inst)
				coin_inst.position = Vector2(cx, safe_y - arc_height)
				coin_inst.add_to_group("pickups")
				if active_terrain_profile and coin_inst.has_method("apply_biome_theme"):
					coin_inst.apply_biome_theme(str(active_terrain_profile.get("profile_name")))
				_spawned_pickups.append(coin_inst)
				
		TerrainSegment.SegmentType.DOUBLE_CREST, TerrainSegment.SegmentType.PLATEAU_DROP:
			# Evenly spaced contour trail across the elevated feature
			var start_x := seg.segment_length * 0.25
			var span := seg.segment_length * 0.5
			for i in range(num_coins):
				var t := float(i) / float(maxi(1, num_coins - 1))
				var cx := start_x + (t * span)
				var safe_y := _calculate_safe_pickup_y(seg, cx, coin_surface_clearance, 16.0)
				var coin_inst := coin_scene.instantiate() as Node2D
				seg.add_child(coin_inst)
				coin_inst.position = Vector2(cx, safe_y)
				coin_inst.add_to_group("pickups")
				if active_terrain_profile and coin_inst.has_method("apply_biome_theme"):
					coin_inst.apply_biome_theme(str(active_terrain_profile.get("profile_name")))
				_spawned_pickups.append(coin_inst)
				
		_:
			# Standard contour trail following hill / slope
			var start_x := seg.segment_length * 0.3
			var span := seg.segment_length * 0.4
			for i in range(num_coins):
				var t := float(i) / float(maxi(1, num_coins - 1))
				var cx := start_x + (t * span)
				var safe_y := _calculate_safe_pickup_y(seg, cx, coin_surface_clearance, 16.0)
				var coin_inst := coin_scene.instantiate() as Node2D
				seg.add_child(coin_inst)
				coin_inst.position = Vector2(cx, safe_y)
				coin_inst.add_to_group("pickups")
				if active_terrain_profile and coin_inst.has_method("apply_biome_theme"):
					coin_inst.apply_biome_theme(str(active_terrain_profile.get("profile_name")))
				_spawned_pickups.append(coin_inst)

## Returns the surface Y in world coordinates at the given world_x
func get_surface_y_at_world_x(world_x: float) -> float:
	for seg in active_segments:
		if not is_instance_valid(seg):
			continue
		var seg_start_x := seg.global_position.x
		var seg_end_x := seg_start_x + seg.segment_length
		if world_x >= seg_start_x and world_x <= seg_end_x:
			var local_x := world_x - seg_start_x
			return seg.global_position.y + seg.get_surface_y_at(local_x)
	for enc in active_encounters:
		if is_instance_valid(enc):
			var gate_x: float = enc.gate_distance_m * 100.0
			var realm_len: float = enc.realm_total_length
			if world_x >= (gate_x - enc.approach_ramp_length) and world_x <= (gate_x + realm_len):
				if enc.heaven_segment and enc.heaven_segment.visible:
					var h_start: float = enc.heaven_segment.global_position.x
					return enc.heaven_segment.global_position.y + enc.heaven_segment.get_surface_y_at(world_x - h_start)
				elif enc.hell_segment and enc.hell_segment.visible:
					var l_start: float = enc.hell_segment.global_position.x
					return enc.hell_segment.global_position.y + enc.hell_segment.get_surface_y_at(world_x - l_start)
				elif enc.approach_segment:
					var a_start: float = enc.approach_segment.global_position.x
					return enc.approach_segment.global_position.y + enc.approach_segment.get_surface_y_at(world_x - a_start)
	return initial_spawn_point.y

## Clears all active segments and resets generation state
func clear_terrain() -> void:
	for p in _spawned_pickups:
		if is_instance_valid(p):
			p.visible = false
			p.queue_free()
	_spawned_pickups.clear()
	
	for seg in active_segments:
		if is_instance_valid(seg):
			seg.visible = false
			seg.set_process(false)
			seg.set_physics_process(false)
			seg.queue_free()
	active_segments.clear()
	
	for seg in segment_pool:
		if is_instance_valid(seg):
			seg.queue_free()
	segment_pool.clear()

	for enc in active_encounters:
		if is_instance_valid(enc):
			enc.visible = false
			enc.queue_free()
	active_encounters.clear()
	_spawned_encounter_indices.clear()

	for portal in active_portals:
		if is_instance_valid(portal):
			portal.visible = false
			portal.set_process(false)
			portal.queue_free()
	active_portals.clear()
	_spawned_heaven_portal_cycles.clear()
	_spawned_hell_portal_cycles.clear()
	_spawned_return_portal_cycles.clear()
	
	segment_counter = 0
	current_difficulty = 1.0
	current_slope = 0.0
	distance_since_last_fuel = 0.0
	total_coins_spawned = 0
	total_fuel_spawned = 0
	active_terrain_profile = normal_terrain_profile
	next_attach_point = initial_spawn_point

## Returns the live branching state. The exported flag is an explicit manual
## override; controller mode is read dynamically so changing schedules at
## runtime cannot leave generation and culling out of sync.
func _is_branching_mode_enabled() -> bool:
	return enable_branching_encounters or (is_instance_valid(progression_controller) and progression_controller.is_branching_mode())

## Binds to BiomeProgressionController to wire branching triggers.
## Do not cache its mode in the exported override: the controller can change it.
func bind_progression_controller(ctrl: BiomeProgressionController) -> void:
	progression_controller = ctrl

## Resets generator to initial condition for a new run
func reset_generator(at_origin: Vector2 = Vector2(-1200.0, 420.0)) -> void:
	initial_spawn_point = at_origin
	_generate_initial_track()
