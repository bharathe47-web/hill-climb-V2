class_name BiomeProgressionController
extends Node

## BiomeProgressionController: Coordinates deterministic world-cycle progression
## by consuming authoritative run distance from GameManager.
## Resolves biomes, transitions, cycle repetition, and emits one-shot state change signals.
## Completely decoupled from terrain geometry and visual rendering.
## Supports both legacy FIXED_5150M cycle and skill-based BRANCHING_1000M encounters.

signal state_changed(old_state: int, new_state: int, state_info: Dictionary)
signal cycle_completed(completed_cycle: int, new_cycle: int)
signal transition_progress_updated(progress: float, transition_state: int)
signal progression_reset()

# Branching encounter signals (Section 5.3 & Phase 1 TODO)
signal ramp_warning_triggered(gate_dist_m: float, encounter_idx: int)
signal launch_window_entered(gate_dist_m: float, encounter_idx: int)
signal branch_confirmed(realm: int, encounter_idx: int)
signal route_merge_completed(encounter_idx: int)

@export var schedule: WorldCycleSchedule
@export var is_paused: bool = false

## Proposed cycle difficulty scaling (+0.15 per completed 5,150m cycle).
## Kept false by default to respect TerrainGenerator's existing difficulty clamp.
@export var enable_cycle_difficulty_scaling: bool = false
@export var difficulty_growth_per_cycle: float = 0.15

var current_cumulative_distance: float = 0.0
var current_cycle_index: int = 0
var current_encounter_index: int = 0
var current_state: int = WorldCycleSchedule.WorldState.NORMAL_LAND_1
var current_transition_progress: float = 0.0
var last_state_info: Dictionary = {}

# Branching encounter route resolution
var confirmed_realms: Dictionary = {} # encounter_idx (int) -> BiomeType (HEAVEN or HELL)
var _warning_emitted_encounters: Dictionary = {}
var _launch_window_emitted_encounters: Dictionary = {}
var _merge_emitted_encounters: Dictionary = {}

var _game_manager_ref: Node = null

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

## Connects to the authoritative GameManager instance to track distance and reset signals.
func connect_to_game_manager(gm: Node) -> void:
	if not gm:
		return
	_game_manager_ref = gm

	if gm.has_signal("distance_updated") and not gm.distance_updated.is_connected(_on_distance_updated):
		gm.distance_updated.connect(_on_distance_updated)

	if gm.has_signal("run_finished") and not gm.run_finished.is_connected(_on_run_finished):
		gm.run_finished.connect(_on_run_finished)

func _on_distance_updated(distance_m: float) -> void:
	if is_paused:
		return
	update_distance(distance_m)

func _on_run_finished(_final_distance: float, _coins: int, _reason: String) -> void:
	# Run completed; state remains frozen until explicit reset
	pass

## Confirms route selection (Heaven or Hell) for an encounter.
## Idempotent: a gate can resolve only once per encounter.
## Returns true if confirmed successfully, false if duplicate or invalid.
func confirm_route(realm: int, encounter_idx: int = -1) -> bool:
	if is_paused:
		return false

	var enc_idx := current_encounter_index if encounter_idx < 0 else encounter_idx

	# Once resolved/confirmed, reject duplicate trigger calls
	if confirmed_realms.has(enc_idx):
		return false

	if realm != WorldCycleSchedule.BiomeType.HEAVEN and realm != WorldCycleSchedule.BiomeType.HELL:
		push_warning("BiomeProgressionController: Invalid realm %d for route confirmation." % realm)
		return false

	confirmed_realms[enc_idx] = realm
	branch_confirmed.emit(realm, enc_idx)

	# If currently at or past gate, recalculate progression state immediately
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

## Authoritative distance update function. Resolves cycle index, world state, and progress.
func update_distance(new_distance_m: float) -> void:
	if is_paused:
		return

	var safe_dist := maxf(0.0, new_distance_m)
	# Distance in Endless Map should be monotonic
	if safe_dist < current_cumulative_distance and not is_equal_approx(safe_dist, 0.0):
		# Distance went backwards without reset
		return

	current_cumulative_distance = safe_dist

	if is_branching_mode():
		_update_branching_distance(safe_dist)
	else:
		_update_fixed_distance(safe_dist)

func _update_branching_distance(safe_dist: float) -> void:
	var enc_idx: int = schedule.get_encounter_for_distance(safe_dist)
	current_encounter_index = enc_idx
	var gate_dist_m: float = schedule.get_gate_distance_for_encounter(enc_idx)

	# 1. Gate crossing resolution check: Fallback to Hell if unconfirmed or missed launch
	if safe_dist >= gate_dist_m and not confirmed_realms.has(enc_idx):
		confirmed_realms[enc_idx] = WorldCycleSchedule.BiomeType.HELL
		branch_confirmed.emit(WorldCycleSchedule.BiomeType.HELL, enc_idx)

	var conf_realm: int = confirmed_realms.get(enc_idx, -1)
	var info := schedule.resolve_branching_encounter(safe_dist, conf_realm)
	var new_cycle: int = info["cycle_index"]
	var new_state: int = info["state"]
	var new_trans_prog: float = info["transition_progress"]

	# 2. Warning Zone Signal (One-shot per encounter)
	if new_state == WorldCycleSchedule.WorldState.RAMP_WARNING:
		if not _warning_emitted_encounters.has(enc_idx):
			_warning_emitted_encounters[enc_idx] = true
			ramp_warning_triggered.emit(gate_dist_m, enc_idx)

	# 3. Launch Window Signal (One-shot per encounter)
	if new_state == WorldCycleSchedule.WorldState.LAUNCH_WINDOW:
		if not _launch_window_emitted_encounters.has(enc_idx):
			_launch_window_emitted_encounters[enc_idx] = true
			launch_window_entered.emit(gate_dist_m, enc_idx)

	# 4. Route Merge Signal (One-shot when entering next encounter's approach)
	if new_state == WorldCycleSchedule.WorldState.NORMAL_APPROACH and enc_idx > 0:
		var prev_enc := enc_idx - 1
		if not _merge_emitted_encounters.has(prev_enc):
			_merge_emitted_encounters[prev_enc] = true
			route_merge_completed.emit(prev_enc)

	# 5. Cycle Crossing
	if new_cycle > current_cycle_index:
		var old_cycle := current_cycle_index
		current_cycle_index = new_cycle
		cycle_completed.emit(old_cycle, new_cycle)

	# 6. State Change
	if new_state != current_state or last_state_info.is_empty():
		var old_st := current_state
		current_state = new_state
		last_state_info = info
		state_changed.emit(old_st, new_state, info)

	# 7. Transition Progress Update
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
	var new_trans_prog: float = info["transition_progress"]

	# 1. Detect Cycle Crossing
	if new_cycle > current_cycle_index:
		var old_cycle := current_cycle_index
		current_cycle_index = new_cycle
		cycle_completed.emit(old_cycle, new_cycle)

	# 2. Detect State Change
	if new_state != current_state or last_state_info.is_empty():
		var old_st := current_state
		current_state = new_state
		last_state_info = info
		state_changed.emit(old_st, new_state, info)

	# 3. Detect Transition Progress Update
	if info["is_transition"]:
		current_transition_progress = new_trans_prog
		transition_progress_updated.emit(new_trans_prog, new_state)
	else:
		current_transition_progress = 0.0

	last_state_info = info

## Handles a large arbitrary distance jump (e.g. testing teleports or milestone leaps).
func handle_distance_jump(target_distance_m: float) -> void:
	update_distance(target_distance_m)

## Resets progression state cleanly on run restart.
func reset_progression() -> void:
	current_cumulative_distance = 0.0
	current_cycle_index = 0
	current_encounter_index = 0
	current_transition_progress = 0.0
	confirmed_realms.clear()
	_warning_emitted_encounters.clear()
	_launch_window_emitted_encounters.clear()
	_merge_emitted_encounters.clear()

	if is_branching_mode():
		current_state = WorldCycleSchedule.WorldState.NORMAL_APPROACH
		last_state_info = schedule.resolve_branching_encounter(0.0)
	else:
		current_state = WorldCycleSchedule.WorldState.NORMAL_LAND_1
		last_state_info = schedule.resolve_distance(0.0)

	progression_reset.emit()

## Sets paused state to prevent duplicate events during pause/menu interactions.
func set_paused(paused: bool) -> void:
	is_paused = paused

## Returns current resolved state snapshot.
func get_current_state_info() -> Dictionary:
	if last_state_info.is_empty():
		if is_branching_mode():
			var conf: int = confirmed_realms.get(current_encounter_index, -1)
			last_state_info = schedule.resolve_branching_encounter(current_cumulative_distance, conf)
		else:
			last_state_info = schedule.resolve_distance(current_cumulative_distance)
	return last_state_info

## Computes cycle difficulty multiplier (+0.15 per cycle if enabled).
func get_cycle_difficulty_multiplier(cycle_idx: int = -1) -> float:
	var target_cycle := current_cycle_index if cycle_idx < 0 else cycle_idx
	if not enable_cycle_difficulty_scaling:
		return 1.0
	return 1.0 + (target_cycle * difficulty_growth_per_cycle)
