class_name BiomeProgressionController
extends Node

## BiomeProgressionController: Coordinates deterministic world-cycle progression
## by consuming authoritative run distance from GameManager.
## Resolves biomes, transitions, cycle repetition, and emits one-shot state change signals.
## Completely decoupled from terrain geometry and visual rendering.
## Phase 2.3: Active 900m recurring three-biome schedule (Normal Land -> Heaven -> Hell -> repeat).

signal state_changed(old_state: int, new_state: int, state_info: Dictionary)
signal cycle_completed(completed_cycle: int, new_cycle: int)
signal transition_progress_updated(progress: float, transition_state: int)
signal progression_reset()

# Phase 2.3 Dedicated Signals
signal nitro_prompt_triggered(target_dist_m: float, cycle_idx: int)
signal launch_zone_entered(target_dist_m: float, cycle_idx: int)
signal nitro_launch_activated(cycle_idx: int)
signal heaven_portal_entered(portal_dist_m: float, cycle_idx: int)
signal hell_portal_entered(portal_dist_m: float, cycle_idx: int)
signal return_portal_entered(portal_dist_m: float, cycle_idx: int)
signal biome_changed(old_biome: int, new_biome: int, cycle_idx: int)

# Branching encounter compatibility signals
signal ramp_warning_triggered(gate_dist_m: float, encounter_idx: int)
signal launch_window_entered(gate_dist_m: float, encounter_idx: int)
signal branch_confirmed(realm: int, encounter_idx: int)
signal route_merge_completed(encounter_idx: int)

@export var schedule: WorldCycleSchedule
@export var is_paused: bool = false

@export var enable_cycle_difficulty_scaling: bool = false
@export var difficulty_growth_per_cycle: float = 0.15

var current_cumulative_distance: float = 0.0
var current_cycle_index: int = 0
var current_encounter_index: int = 0
var current_biome_index: int = WorldCycleSchedule.BiomeType.NORMAL_LAND
var current_biome_local_distance: float = 0.0
var current_state: int = WorldCycleSchedule.WorldState.NORMAL_LAND
var current_transition_progress: float = 0.0
var is_launch_zone_active: bool = false
var is_restart_in_progress: bool = false
var last_state_info: Dictionary = {}

var confirmed_realms: Dictionary = {}
var _warning_emitted_encounters: Dictionary = {}
var _launch_window_emitted_encounters: Dictionary = {}
var _merge_emitted_encounters: Dictionary = {}

# One-shot tracking for Phase 2.3 900m cycle
var _prompt_emitted_cycles: Dictionary = {}
var _launch_emitted_cycles: Dictionary = {}
var _heaven_portal_emitted_cycles: Dictionary = {}
var _hell_portal_emitted_cycles: Dictionary = {}
var _return_portal_emitted_cycles: Dictionary = {}
var _nitro_launch_triggered_cycles: Dictionary = {}
var _last_resolved_biome: int = WorldCycleSchedule.BiomeType.NORMAL_LAND

var _game_manager_ref: Node = null
var _vehicle_ref: Node = null

func _init() -> void:
	if not schedule:
		schedule = WorldCycleSchedule.new()

func _ready() -> void:
	if not schedule:
		schedule = WorldCycleSchedule.new()
	reset_progression()

## Checks if current active schedule is running in branching encounter mode
func is_branching_mode() -> bool:
	return schedule != null and schedule.schedule_mode == WorldCycleSchedule.ScheduleMode.BRANCHING_1000M

## Enables or disables branching schedule mode
func enable_branching_mode(enable: bool = true) -> void:
	if not schedule:
		schedule = WorldCycleSchedule.new()
	if enable:
		schedule.init_branching_schedule()
	else:
		schedule.init_default_schedule()
	reset_progression()

## Binds to a VehicleController instance to detect and interact with nitro state
func bind_vehicle(veh: Node) -> void:
	_vehicle_ref = veh

## Connects to the authoritative GameManager instance to track distance and reset signals.
func connect_to_game_manager(gm: Node) -> void:
	if not gm:
		return
	_game_manager_ref = gm

	if gm.has_signal("live_position_updated") and not gm.live_position_updated.is_connected(_on_distance_updated):
		gm.live_position_updated.connect(_on_distance_updated)
	elif gm.has_signal("distance_updated") and not gm.distance_updated.is_connected(_on_distance_updated):
		gm.distance_updated.connect(_on_distance_updated)

	if gm.has_signal("run_finished") and not gm.run_finished.is_connected(_on_run_finished):
		gm.run_finished.connect(_on_run_finished)

	if gm.has_signal("run_restarted") and not gm.run_restarted.is_connected(reset_progression):
		gm.run_restarted.connect(reset_progression)

func _on_distance_updated(distance_m: float) -> void:
	if is_paused:
		return
	update_distance(distance_m)

func _on_run_finished(_final_distance: float, _coins: int, _reason: String) -> void:
	pass

## Confirms route selection (Heaven or Hell) for a branching encounter.
func confirm_route(realm: int, encounter_idx: int = -1) -> bool:
	if is_paused:
		return false

	var enc_idx := current_encounter_index if encounter_idx < 0 else encounter_idx

	if confirmed_realms.has(enc_idx):
		return false

	if realm != WorldCycleSchedule.BiomeType.HEAVEN and realm != WorldCycleSchedule.BiomeType.HELL:
		push_warning("BiomeProgressionController: Invalid realm %d for route confirmation." % realm)
		return false

	confirmed_realms[enc_idx] = realm
	branch_confirmed.emit(realm, enc_idx)

	if is_branching_mode():
		_recalculate_progression_state()

	return true

func _recalculate_progression_state() -> void:
	var enc_idx := current_encounter_index
	var conf_realm: int = confirmed_realms.get(enc_idx, -1)
	var info := schedule.resolve_branching_encounter(current_cumulative_distance, conf_realm)
	var new_state: int = info["state"]
	if new_state != current_state or last_state_info.is_empty():
		var old_st := current_state
		current_state = new_state
		last_state_info = info
		state_changed.emit(old_st, new_state, info)

	if info["is_transition"]:
		current_transition_progress = info["transition_progress"]
		transition_progress_updated.emit(info["transition_progress"], new_state)
	else:
		current_transition_progress = 0.0

	last_state_info = info

## Attempts to initiate the special Heaven Nitro launch.
## Only initiates if inside the active launch zone [285m, 300m) mod 900.
## Ordinary nitro presses elsewhere return false without affecting progression.
func attempt_nitro_launch() -> bool:
	if not is_launch_zone_active:
		return false

	var cycle_idx := current_cycle_index
	if _nitro_launch_triggered_cycles.has(cycle_idx):
		return true # Already triggered for this cycle

	_nitro_launch_triggered_cycles[cycle_idx] = true
	nitro_launch_activated.emit(cycle_idx)

	if is_instance_valid(_vehicle_ref) and _vehicle_ref.has_method("apply_central_force"):
		_vehicle_ref.apply_central_force(Vector2(32000.0, -12000.0))

	return true

## Authoritative distance update function. Resolves cycle index, world state, and progress.
func update_distance(new_distance_m: float) -> void:
	if is_paused or is_restart_in_progress:
		return

	var safe_dist := maxf(0.0, new_distance_m)
	current_cumulative_distance = safe_dist

	if is_branching_mode():
		_update_branching_distance(safe_dist)
	else:
		_update_fixed_distance(safe_dist)

func _update_branching_distance(safe_dist: float) -> void:
	var enc_idx: int = schedule.get_encounter_for_distance(safe_dist)
	current_encounter_index = enc_idx
	var gate_dist_m: float = schedule.get_gate_distance_for_encounter(enc_idx)

	if safe_dist >= gate_dist_m and not confirmed_realms.has(enc_idx):
		confirmed_realms[enc_idx] = WorldCycleSchedule.BiomeType.HELL
		branch_confirmed.emit(WorldCycleSchedule.BiomeType.HELL, enc_idx)

	var conf_realm: int = confirmed_realms.get(enc_idx, -1)
	var info := schedule.resolve_branching_encounter(safe_dist, conf_realm)
	var new_biome: int = info.get("active_biome", WorldCycleSchedule.BiomeType.NORMAL_LAND)
	current_biome_index = new_biome
	var new_cycle: int = info["cycle_index"]

	if new_biome != _last_resolved_biome:
		var old_b := _last_resolved_biome
		_last_resolved_biome = new_biome
		biome_changed.emit(old_b, new_biome, new_cycle)

	var new_state: int = info["state"]
	var new_trans_prog: float = info["transition_progress"]

	if new_state == WorldCycleSchedule.WorldState.RAMP_WARNING:
		if not _warning_emitted_encounters.has(enc_idx):
			_warning_emitted_encounters[enc_idx] = true
			ramp_warning_triggered.emit(gate_dist_m, enc_idx)

	if new_state == WorldCycleSchedule.WorldState.LAUNCH_WINDOW:
		if not _launch_window_emitted_encounters.has(enc_idx):
			_launch_window_emitted_encounters[enc_idx] = true
			launch_window_entered.emit(gate_dist_m, enc_idx)

	if new_state == WorldCycleSchedule.WorldState.NORMAL_APPROACH and enc_idx > 0:
		var prev_enc := enc_idx - 1
		if not _merge_emitted_encounters.has(prev_enc):
			_merge_emitted_encounters[prev_enc] = true
			route_merge_completed.emit(prev_enc)

	if new_cycle > current_cycle_index:
		var old_cycle := current_cycle_index
		current_cycle_index = new_cycle
		cycle_completed.emit(old_cycle, new_cycle)

	if new_state != current_state or last_state_info.is_empty():
		var old_st := current_state
		current_state = new_state
		last_state_info = info
		state_changed.emit(old_st, new_state, info)

	if info["is_transition"]:
		current_transition_progress = new_trans_prog
		transition_progress_updated.emit(new_trans_prog, new_state)
	else:
		current_transition_progress = 0.0

	last_state_info = info

func _update_fixed_distance(safe_dist: float) -> void:
	var info := schedule.resolve_distance(safe_dist)
	var new_cycle: int = info["cycle_index"]
	var new_state: int = info["state"]
	var new_biome: int = info["active_biome"]
	var new_trans_prog: float = info["transition_progress"]

	current_biome_local_distance = info.get("biome_local_distance", 0.0)

	# 1. Detect Cycle Crossing
	if new_cycle > current_cycle_index:
		var old_cycle := current_cycle_index
		current_cycle_index = new_cycle
		cycle_completed.emit(old_cycle, new_cycle)

	# 2. Detect Biome Change
	if new_biome != _last_resolved_biome:
		var old_b := _last_resolved_biome
		_last_resolved_biome = new_biome
		current_biome_index = new_biome
		biome_changed.emit(old_b, new_biome, new_cycle)

	# 3. Detect Phase 2.3 One-Shot Milestones (Portals)
	if schedule.schedule_mode == WorldCycleSchedule.ScheduleMode.RECURRING_900M:
		# Heaven portal zone [270m, 300m) - physical gateway at 300m, no nitro required
		if new_state == WorldCycleSchedule.WorldState.NORMAL_TO_HEAVEN_PORTAL and not _heaven_portal_emitted_cycles.has(new_cycle):
			_heaven_portal_emitted_cycles[new_cycle] = true
			heaven_portal_entered.emit(float(new_cycle) * 900.0 + 300.0, new_cycle)

		# Hell portal zone [570m, 600m) - physical gateway at 600m
		if new_state == WorldCycleSchedule.WorldState.HEAVEN_TO_HELL_PORTAL and not _hell_portal_emitted_cycles.has(new_cycle):
			_hell_portal_emitted_cycles[new_cycle] = true
			hell_portal_entered.emit(float(new_cycle) * 900.0 + 600.0, new_cycle)

		# Return portal zone [870m, 900m) - physical gateway at 900m
		if new_state == WorldCycleSchedule.WorldState.HELL_TO_NORMAL_PORTAL and not _return_portal_emitted_cycles.has(new_cycle):
			_return_portal_emitted_cycles[new_cycle] = true
			return_portal_entered.emit(float(new_cycle) * 900.0 + 900.0, new_cycle)

	# 4. Detect State Change
	if new_state != current_state or last_state_info.is_empty():
		var old_st := current_state
		current_state = new_state
		last_state_info = info
		state_changed.emit(old_st, new_state, info)

	# 5. Detect Transition Progress Update
	if info["is_transition"]:
		current_transition_progress = new_trans_prog
		transition_progress_updated.emit(new_trans_prog, new_state)
	else:
		current_transition_progress = 0.0

	last_state_info = info

func handle_distance_jump(target_distance_m: float) -> void:
	update_distance(target_distance_m)

func reset_progression() -> void:
	current_cumulative_distance = 0.0
	current_cycle_index = 0
	current_encounter_index = 0
	current_biome_index = WorldCycleSchedule.BiomeType.NORMAL_LAND
	current_biome_local_distance = 0.0
	current_transition_progress = 0.0
	is_launch_zone_active = false
	confirmed_realms.clear()
	_warning_emitted_encounters.clear()
	_launch_window_emitted_encounters.clear()
	_merge_emitted_encounters.clear()
	_prompt_emitted_cycles.clear()
	_launch_emitted_cycles.clear()
	_heaven_portal_emitted_cycles.clear()
	_hell_portal_emitted_cycles.clear()
	_return_portal_emitted_cycles.clear()
	_nitro_launch_triggered_cycles.clear()
	var old_b := _last_resolved_biome
	_last_resolved_biome = WorldCycleSchedule.BiomeType.NORMAL_LAND

	if is_branching_mode():
		current_state = WorldCycleSchedule.WorldState.NORMAL_APPROACH
		last_state_info = schedule.resolve_branching_encounter(0.0)
	else:
		current_state = WorldCycleSchedule.WorldState.NORMAL_LAND
		last_state_info = schedule.resolve_distance(0.0)

	progression_reset.emit()
	if old_b != WorldCycleSchedule.BiomeType.NORMAL_LAND:
		biome_changed.emit(old_b, WorldCycleSchedule.BiomeType.NORMAL_LAND, 0)

func set_paused(paused: bool) -> void:
	is_paused = paused

func get_current_state_info() -> Dictionary:
	if last_state_info.is_empty():
		if is_branching_mode():
			var conf: int = confirmed_realms.get(current_encounter_index, -1)
			last_state_info = schedule.resolve_branching_encounter(current_cumulative_distance, conf)
		else:
			last_state_info = schedule.resolve_distance(current_cumulative_distance)
	return last_state_info

func get_cycle_difficulty_multiplier(cycle_idx: int = -1) -> float:
	var target_cycle := current_cycle_index if cycle_idx < 0 else cycle_idx
	if not enable_cycle_difficulty_scaling:
		return 1.0
	return 1.0 + (target_cycle * difficulty_growth_per_cycle)
