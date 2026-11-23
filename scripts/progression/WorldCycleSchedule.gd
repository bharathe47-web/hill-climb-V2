class_name WorldCycleSchedule
extends Resource

## WorldCycleSchedule: Authoritative world progression schedule for Endless Map.
## Phase 2.3: Fixed recurring 900m three-biome sequence:
## NORMAL LAND (0-300m) -> HEAVEN (300-600m) -> HELL (600-900m) -> REPEAT.
## Normal Land -> Heaven: Nitro launch off countryside ramp (NO portal in Normal Land).
## Heaven -> Hell: Physical Hell Portal.
## Hell -> Normal Land: Physical Return Portal.

enum WorldState {
	NORMAL_LAND = 0,
	NORMAL_NITRO_PROMPT = 1,
	NORMAL_HEAVEN_LAUNCH = 2,
	NORMAL_TO_HEAVEN_PORTAL = 2,
	HEAVEN = 3,
	HEAVEN_TO_HELL_PORTAL = 4,
	HELL = 5,
	HELL_TO_NORMAL_PORTAL = 6,
	# Backward-compatibility aliases for legacy tests
	NORMAL_LAND_1 = 0,
	TRANSITION_NORMAL_TO_HEAVEN = 2,
	TRANSITION_HEAVEN_TO_NORMAL = 8,
	NORMAL_LAND_2 = 9,
	TRANSITION_NORMAL_TO_HELL = 10,
	TRANSITION_HELL_TO_NORMAL = 6,
	NORMAL_APPROACH = 7,
	RAMP_WARNING = 1,
	LAUNCH_WINDOW = 11,
	HEAVEN_ENTRY = 2,
	HELL_ENTRY = 4,
	HEAVEN_ACTIVE = 3,
	HELL_ACTIVE = 5,
	EXIT_TRANSITION = 12,
	NORMAL_MERGE = 0
}

enum BiomeType {
	NORMAL_LAND = 0,
	HEAVEN = 1,
	HELL = 2
}

enum ScheduleMode {
	RECURRING_900M = 0,   # Active default mode
	FIXED_5150M = 1,      # Retained legacy schedule
	BRANCHING_1000M = 2   # Retained branching schedule
}

@export var schedule_mode: ScheduleMode = ScheduleMode.RECURRING_900M
@export var cycle_length_m: float = 900.0
@export var biome_duration_m: float = 300.0
@export var entries: Array[Dictionary] = []

# Branching Cadence Parameters (Retained for testing)
@export_group("Branching Schedule Parameters")
@export var normal_section_length_m: float = 500.0
@export var realm_section_length_m: float = 500.0
@export var encounter_cycle_length_m: float = 1000.0
@export var first_gate_distance_m: float = 500.0
@export var warning_distance_m: float = 50.0       # 50m before gate (450m)
@export var launch_window_distance_m: float = 25.0  # 25m before gate (475m)
@export var transition_blend_distance_m: float = 50.0 # 50m entry/exit blend

func _init() -> void:
	if entries.is_empty():
		init_default_schedule()

## Initializes the active default recurring 900m three-biome schedule:
## 0-300m Normal Land -> 300-600m Heaven -> 600-900m Hell -> repeat.
func init_default_schedule() -> void:
	schedule_mode = ScheduleMode.RECURRING_900M
	cycle_length_m = 900.0
	biome_duration_m = 300.0
	entries.clear()

	# 1. Normal Land: 0 - 300m
	entries.append({
		"state": WorldState.NORMAL_LAND,
		"name": "Normal Land (Countryside)",
		"start_m": 0.0,
		"end_m": 300.0,
		"is_transition": false,
		"active_biome": BiomeType.NORMAL_LAND,
		"from_biome": BiomeType.NORMAL_LAND,
		"to_biome": BiomeType.NORMAL_LAND,
		"profile_key": "normal_land_start"
	})

	# 2. Heaven: 300 - 600m
	entries.append({
		"state": WorldState.HEAVEN,
		"name": "Heaven (Celestial Palace)",
		"start_m": 300.0,
		"end_m": 600.0,
		"is_transition": false,
		"active_biome": BiomeType.HEAVEN,
		"from_biome": BiomeType.HEAVEN,
		"to_biome": BiomeType.HEAVEN,
		"profile_key": "heaven_core"
	})

	# 3. Hell: 600 - 900m
	entries.append({
		"state": WorldState.HELL,
		"name": "Hell (Basalt & Magma Caverns)",
		"start_m": 600.0,
		"end_m": 900.0,
		"is_transition": false,
		"active_biome": BiomeType.HELL,
		"from_biome": BiomeType.HELL,
		"to_biome": BiomeType.HELL,
		"profile_key": "hell_core"
	})

## Initializes the legacy 5,150 m world cycle schedule.
func init_fixed_5150m_schedule() -> void:
	schedule_mode = ScheduleMode.FIXED_5150M
	entries.clear()
	cycle_length_m = 5150.0

	# 1. Normal Land 1: 0 - 1000m (Countryside start)
	entries.append({
		"state": WorldState.NORMAL_LAND_1,
		"name": "Normal Land (Countryside Start)",
		"start_m": 0.0,
		"end_m": 1000.0,
		"is_transition": false,
		"active_biome": BiomeType.NORMAL_LAND,
		"from_biome": BiomeType.NORMAL_LAND,
		"to_biome": BiomeType.NORMAL_LAND,
		"profile_key": "normal_land_start"
	})

	# 2. Normal Land -> Heaven: 1000 - 1150m (Launch ramp & gateway)
	entries.append({
		"state": WorldState.TRANSITION_NORMAL_TO_HEAVEN,
		"name": "Transition: Normal Land -> Heaven",
		"start_m": 1000.0,
		"end_m": 1150.0,
		"is_transition": true,
		"active_biome": BiomeType.NORMAL_LAND,
		"from_biome": BiomeType.NORMAL_LAND,
		"to_biome": BiomeType.HEAVEN,
		"profile_key": "ramp_normal_to_heaven"
	})

	# 3. Heaven: 1150 - 2200m (Celestial palace, clouds and gardens)
	entries.append({
		"state": WorldState.HEAVEN,
		"name": "Heaven (Celestial Palace)",
		"start_m": 1150.0,
		"end_m": 2200.0,
		"is_transition": false,
		"active_biome": BiomeType.HEAVEN,
		"from_biome": BiomeType.HEAVEN,
		"to_biome": BiomeType.HEAVEN,
		"profile_key": "heaven_core"
	})

	# 4. Heaven -> Normal Land: 2200 - 2350m (Cloud-slide return ramp)
	entries.append({
		"state": WorldState.TRANSITION_HEAVEN_TO_NORMAL,
		"name": "Transition: Heaven -> Normal Land",
		"start_m": 2200.0,
		"end_m": 2350.0,
		"is_transition": true,
		"active_biome": BiomeType.HEAVEN,
		"from_biome": BiomeType.HEAVEN,
		"to_biome": BiomeType.NORMAL_LAND,
		"profile_key": "ramp_heaven_to_normal"
	})

	# 5. Normal Land 2: 2350 - 3500m (Expert slopes and dips)
	entries.append({
		"state": WorldState.NORMAL_LAND_2,
		"name": "Normal Land (Expert Slopes)",
		"start_m": 2350.0,
		"end_m": 3500.0,
		"is_transition": false,
		"active_biome": BiomeType.NORMAL_LAND,
		"from_biome": BiomeType.NORMAL_LAND,
		"to_biome": BiomeType.NORMAL_LAND,
		"profile_key": "normal_land_expert"
	})

	# 6. Normal Land -> Hell: 3500 - 3650m (Volcanic chasm plunge)
	entries.append({
		"state": WorldState.TRANSITION_NORMAL_TO_HELL,
		"name": "Transition: Normal Land -> Hell",
		"start_m": 3500.0,
		"end_m": 3650.0,
		"is_transition": true,
		"active_biome": BiomeType.NORMAL_LAND,
		"from_biome": BiomeType.NORMAL_LAND,
		"to_biome": BiomeType.HELL,
		"profile_key": "ramp_normal_to_hell"
	})

	# 7. Hell: 3650 - 5000m (Volcanic basalt and magma caverns)
	entries.append({
		"state": WorldState.HELL,
		"name": "Hell (Basalt & Magma Caverns)",
		"start_m": 3650.0,
		"end_m": 5000.0,
		"is_transition": false,
		"active_biome": BiomeType.HELL,
		"from_biome": BiomeType.HELL,
		"to_biome": BiomeType.HELL,
		"profile_key": "hell_core"
	})

	# 8. Hell -> Normal Land: 5000 - 5150m (Magma geyser escape ramp)
	entries.append({
		"state": WorldState.TRANSITION_HELL_TO_NORMAL,
		"name": "Transition: Hell -> Normal Land",
		"start_m": 5000.0,
		"end_m": 5150.0,
		"is_transition": true,
		"active_biome": BiomeType.HELL,
		"from_biome": BiomeType.HELL,
		"to_biome": BiomeType.NORMAL_LAND,
		"profile_key": "ramp_hell_to_normal"
	})

## Validates the active schedule entries for continuity, non-overlapping intervals,
## and complete boundary coverage from 0.0 to cycle_length_m.
func validate_schedule() -> Dictionary:
	var errors: Array[String] = []

	if entries.is_empty():
		return {
			"valid": false,
			"errors": ["Schedule entries list is empty."]
		}

	# Check start of first entry
	if not is_equal_approx(entries[0]["start_m"], 0.0):
		errors.append("First schedule entry must start at 0.0m (got %f)." % entries[0]["start_m"])

	# Check contiguity and positive length across all entries
	for i in range(entries.size()):
		var entry: Dictionary = entries[i]
		var start_m: float = entry.get("start_m", -1.0)
		var end_m: float = entry.get("end_m", -1.0)

		if end_m <= start_m:
			errors.append("Entry [%d] '%s' has non-positive length (start: %f, end: %f)." % [i, entry.get("name", "unnamed"), start_m, end_m])

		if i > 0:
			var prev_end: float = entries[i - 1].get("end_m", -1.0)
			if not is_equal_approx(start_m, prev_end):
				errors.append("Discontinuity between entry [%d] (ends at %f) and entry [%d] (starts at %f)." % [i - 1, prev_end, i, start_m])

	# Check end of last entry matches cycle_length_m
	var last_end: float = entries[-1].get("end_m", -1.0)
	if not is_equal_approx(last_end, cycle_length_m):
		errors.append("Last entry end (%f) does not match cycle_length_m (%f)." % [last_end, cycle_length_m])

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

## Initializes the branching 1,000m cadence schedule.
func init_branching_schedule() -> void:
	schedule_mode = ScheduleMode.BRANCHING_1000M
	normal_section_length_m = 500.0
	realm_section_length_m = 500.0
	encounter_cycle_length_m = normal_section_length_m + realm_section_length_m # 1000.0m
	first_gate_distance_m = normal_section_length_m # 500.0m
	warning_distance_m = 50.0
	launch_window_distance_m = 25.0
	transition_blend_distance_m = 50.0
	cycle_length_m = encounter_cycle_length_m

## Validates the branching schedule parameters.
func validate_branching_schedule() -> Dictionary:
	var errors: Array[String] = []

	if encounter_cycle_length_m <= 0.0:
		errors.append("Encounter cycle length must be strictly positive (got %f)." % encounter_cycle_length_m)

	if normal_section_length_m <= 0.0:
		errors.append("Normal section length must be strictly positive (got %f)." % normal_section_length_m)

	if realm_section_length_m <= 0.0:
		errors.append("Realm section length must be strictly positive (got %f)." % realm_section_length_m)

	if not is_equal_approx(encounter_cycle_length_m, normal_section_length_m + realm_section_length_m):
		errors.append("Encounter cycle length (%f) must equal normal_section_length (%f) + realm_section_length (%f)." % [
			encounter_cycle_length_m, normal_section_length_m, realm_section_length_m
		])

	if first_gate_distance_m <= 0.0 or first_gate_distance_m > normal_section_length_m:
		errors.append("First gate distance (%f) must be in (0, %f]." % [first_gate_distance_m, normal_section_length_m])

	if warning_distance_m <= launch_window_distance_m:
		errors.append("Warning distance (%f) must be greater than launch window distance (%f)." % [
			warning_distance_m, launch_window_distance_m
		])

	if launch_window_distance_m <= 0.0:
		errors.append("Launch window distance must be strictly positive (got %f)." % launch_window_distance_m)

	if transition_blend_distance_m <= 0.0 or transition_blend_distance_m > (realm_section_length_m / 2.0):
		errors.append("Transition blend distance (%f) must be positive and <= half of realm length (%f)." % [
			transition_blend_distance_m, realm_section_length_m / 2.0
		])

	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

func get_gate_distance_for_encounter(encounter_idx: int) -> float:
	return float(encounter_idx) * encounter_cycle_length_m + normal_section_length_m

func get_encounter_for_distance(distance_m: float) -> int:
	return int(floor(maxf(0.0, distance_m) / encounter_cycle_length_m))

func resolve_branching_encounter(cumulative_dist_m: float, confirmed_realm: int = -1) -> Dictionary:
	var safe_dist := maxf(0.0, cumulative_dist_m)
	var encounter_cycle := encounter_cycle_length_m
	var encounter_idx := int(floor(safe_dist / encounter_cycle))
	var dist_in_enc := fposmod(safe_dist, encounter_cycle)

	if is_equal_approx(dist_in_enc, encounter_cycle) or dist_in_enc >= encounter_cycle:
		encounter_idx += 1
		dist_in_enc = 0.0

	var gate_dist_in_enc := normal_section_length_m # 500.0m
	var gate_world_dist_m := float(encounter_idx) * encounter_cycle + gate_dist_in_enc
	var warning_start := gate_dist_in_enc - warning_distance_m # 450.0m
	var launch_start := gate_dist_in_enc - launch_window_distance_m # 475.0m
	var entry_trans_end := gate_dist_in_enc + transition_blend_distance_m # 550.0m
	var exit_trans_start := encounter_cycle - transition_blend_distance_m # 950.0m

	var state: int = WorldState.NORMAL_APPROACH
	var state_name: String = "Normal Land Approach"
	var is_trans: bool = false
	var active_biome: int = BiomeType.NORMAL_LAND
	var from_biome: int = BiomeType.NORMAL_LAND
	var to_biome: int = BiomeType.NORMAL_LAND
	var trans_prog: float = 0.0
	var profile_key: String = "normal_land_start" if encounter_idx == 0 else "normal_land_expert"
	var resolved_realm: int = -1
	var entry_start_m: float = float(encounter_idx) * encounter_cycle
	var entry_end_m: float = entry_start_m + warning_start

	if dist_in_enc < warning_start:
		state = WorldState.NORMAL_APPROACH
		state_name = "Normal Land Approach"
		is_trans = false
		active_biome = BiomeType.NORMAL_LAND
		from_biome = BiomeType.NORMAL_LAND
		to_biome = BiomeType.NORMAL_LAND
		trans_prog = 0.0
		profile_key = "normal_land_start" if encounter_idx == 0 else "normal_land_expert"
		resolved_realm = -1
		entry_start_m = float(encounter_idx) * encounter_cycle
		entry_end_m = entry_start_m + warning_start

	elif dist_in_enc < launch_start:
		state = WorldState.RAMP_WARNING
		state_name = "Ramp Warning (Approach)"
		is_trans = false
		active_biome = BiomeType.NORMAL_LAND
		from_biome = BiomeType.NORMAL_LAND
		to_biome = BiomeType.NORMAL_LAND
		trans_prog = 0.0
		profile_key = "ramp_approach"
		resolved_realm = -1
		entry_start_m = float(encounter_idx) * encounter_cycle + warning_start
		entry_end_m = float(encounter_idx) * encounter_cycle + launch_start

	elif dist_in_enc < gate_dist_in_enc:
		state = WorldState.LAUNCH_WINDOW
		state_name = "Launch Window (Boost Prompt)"
		is_trans = false
		active_biome = BiomeType.NORMAL_LAND
		from_biome = BiomeType.NORMAL_LAND
		to_biome = BiomeType.NORMAL_LAND
		trans_prog = clampf((dist_in_enc - launch_start) / launch_window_distance_m, 0.0, 1.0)
		profile_key = "ramp_launch"
		resolved_realm = -1
		entry_start_m = float(encounter_idx) * encounter_cycle + launch_start
		entry_end_m = float(encounter_idx) * encounter_cycle + gate_dist_in_enc

	else:
		if confirmed_realm == BiomeType.HEAVEN:
			resolved_realm = BiomeType.HEAVEN
		else:
			resolved_realm = BiomeType.HELL

		if dist_in_enc < entry_trans_end:
			if resolved_realm == BiomeType.HEAVEN:
				state = WorldState.HEAVEN_ENTRY
				state_name = "Heaven Entry (Ascent)"
				profile_key = "ramp_normal_to_heaven"
			else:
				state = WorldState.HELL_ENTRY
				state_name = "Hell Entry (Descent)"
				profile_key = "ramp_normal_to_hell"

			is_trans = true
			active_biome = resolved_realm
			from_biome = BiomeType.NORMAL_LAND
			to_biome = resolved_realm
			trans_prog = clampf((dist_in_enc - gate_dist_in_enc) / transition_blend_distance_m, 0.0, 1.0)
			entry_start_m = float(encounter_idx) * encounter_cycle + gate_dist_in_enc
			entry_end_m = float(encounter_idx) * encounter_cycle + entry_trans_end

		elif dist_in_enc < exit_trans_start:
			if resolved_realm == BiomeType.HEAVEN:
				state = WorldState.HEAVEN_ACTIVE
				state_name = "Heaven Active Route"
				profile_key = "heaven_core"
			else:
				state = WorldState.HELL_ACTIVE
				state_name = "Hell Active Route"
				profile_key = "hell_core"

			is_trans = false
			active_biome = resolved_realm
			from_biome = resolved_realm
			to_biome = resolved_realm
			trans_prog = 0.0
			entry_start_m = float(encounter_idx) * encounter_cycle + entry_trans_end
			entry_end_m = float(encounter_idx) * encounter_cycle + exit_trans_start

		else:
			state = WorldState.EXIT_TRANSITION
			state_name = "Exit Transition (Merge to Normal)"
			is_trans = true
			active_biome = resolved_realm
			from_biome = resolved_realm
			to_biome = BiomeType.NORMAL_LAND
			trans_prog = clampf((dist_in_enc - exit_trans_start) / transition_blend_distance_m, 0.0, 1.0)
			profile_key = "ramp_heaven_to_normal" if resolved_realm == BiomeType.HEAVEN else "ramp_hell_to_normal"
			entry_start_m = float(encounter_idx) * encounter_cycle + exit_trans_start
			entry_end_m = float(encounter_idx + 1) * encounter_cycle

	return {
		"cumulative_distance": safe_dist,
		"cycle_index": encounter_idx,
		"distance_in_cycle": dist_in_enc,
		"encounter_index": encounter_idx,
		"distance_in_encounter": dist_in_enc,
		"gate_distance_m": gate_world_dist_m,
		"distance_to_gate_m": gate_world_dist_m - safe_dist,
		"resolved_realm": resolved_realm,
		"state": state,
		"state_name": state_name,
		"is_transition": is_trans,
		"active_biome": active_biome,
		"from_biome": from_biome,
		"to_biome": to_biome,
		"transition_progress": trans_prog,
		"profile_key": profile_key,
		"entry_start_m": entry_start_m,
		"entry_end_m": entry_end_m,
		"cycle_length_m": encounter_cycle
	}

## Resolves an authoritative cumulative distance into exact cycle index, world state, and progress.
func resolve_distance(cumulative_distance_m: float, confirmed_realm: int = -1) -> Dictionary:
	if schedule_mode == ScheduleMode.BRANCHING_1000M:
		return resolve_branching_encounter(cumulative_distance_m, confirmed_realm)
	elif schedule_mode == ScheduleMode.FIXED_5150M:
		return _resolve_fixed_5150m(cumulative_distance_m)

	# Active Default Mode: RECURRING_900M
	var safe_dist := maxf(0.0, cumulative_distance_m)
	var cycle_idx := int(floor(safe_dist / 900.0))
	var cycle_pos := fposmod(safe_dist, 900.0)

	var state: int = WorldState.NORMAL_LAND
	var state_name: String = "Normal Land"
	var active_biome: int = BiomeType.NORMAL_LAND
	var from_biome: int = BiomeType.NORMAL_LAND
	var to_biome: int = BiomeType.NORMAL_LAND
	var is_trans: bool = false
	var trans_prog: float = 0.0
	var profile_key: String = "normal_land_start"
	var biome_local_dist: float = 0.0
	var is_prompt_active: bool = false
	var is_launch_zone: bool = false
	var is_portal_zone: bool = false

	if cycle_pos < 300.0:
		active_biome = BiomeType.NORMAL_LAND
		from_biome = BiomeType.NORMAL_LAND
		to_biome = BiomeType.HEAVEN
		biome_local_dist = cycle_pos
		profile_key = "normal_land_start"
		
		if cycle_pos < 270.0:
			state = WorldState.NORMAL_LAND
			state_name = "Normal Land (Countryside)"
			is_trans = false
			trans_prog = 0.0
		else: # [270.0, 300.0)
			state = WorldState.NORMAL_TO_HEAVEN_PORTAL
			state_name = "Normal Land (Heaven Portal Approach)"
			is_portal_zone = true
			is_trans = true
			trans_prog = clampf((cycle_pos - 270.0) / 30.0, 0.0, 1.0)

	elif cycle_pos < 600.0:
		active_biome = BiomeType.HEAVEN
		from_biome = BiomeType.HEAVEN
		to_biome = BiomeType.HELL
		biome_local_dist = cycle_pos - 300.0
		profile_key = "heaven_core"

		if cycle_pos < 570.0:
			state = WorldState.HEAVEN
			state_name = "Heaven (Celestial Palace)"
			is_trans = false
			trans_prog = 0.0
		else: # [570.0, 600.0)
			state = WorldState.HEAVEN_TO_HELL_PORTAL
			state_name = "Heaven (Hell Portal Zone)"
			is_portal_zone = true
			is_trans = true
			trans_prog = clampf((cycle_pos - 570.0) / 30.0, 0.0, 1.0)

	else: # [600.0, 900.0)
		active_biome = BiomeType.HELL
		from_biome = BiomeType.HELL
		to_biome = BiomeType.NORMAL_LAND
		biome_local_dist = cycle_pos - 600.0
		profile_key = "hell_core"

		if cycle_pos < 870.0:
			state = WorldState.HELL
			state_name = "Hell (Basalt & Magma Caverns)"
			is_trans = false
			trans_prog = 0.0
		else: # [870.0, 900.0)
			state = WorldState.HELL_TO_NORMAL_PORTAL
			state_name = "Hell (Return Portal Zone)"
			is_portal_zone = true
			is_trans = true
			trans_prog = clampf((cycle_pos - 870.0) / 30.0, 0.0, 1.0)

	return {
		"cumulative_distance": safe_dist,
		"cycle_index": cycle_idx,
		"distance_in_cycle": cycle_pos,
		"cycle_position": cycle_pos,
		"biome_local_distance": biome_local_dist,
		"active_biome": active_biome,
		"from_biome": from_biome,
		"to_biome": to_biome,
		"state": state,
		"state_name": state_name,
		"is_transition": is_trans,
		"transition_progress": trans_prog,
		"profile_key": profile_key,
		"is_prompt_active": is_prompt_active,
		"is_launch_zone": is_launch_zone,
		"is_portal_zone": is_portal_zone,
		"cycle_length_m": 900.0,
		"biome_duration_m": 300.0,
		"entry_start_m": float(cycle_idx) * 900.0,
		"entry_end_m": float(cycle_idx + 1) * 900.0
	}

func _resolve_fixed_5150m(cumulative_distance_m: float) -> Dictionary:
	var safe_dist := maxf(0.0, cumulative_distance_m)
	var cycle_idx := int(floor(safe_dist / cycle_length_m))
	var dist_in_cycle := fposmod(safe_dist, cycle_length_m)

	if is_equal_approx(dist_in_cycle, cycle_length_m) or dist_in_cycle >= cycle_length_m:
		cycle_idx += 1
		dist_in_cycle = 0.0

	var matched_entry: Dictionary = {}
	var entry_idx := -1

	for i in range(entries.size()):
		var e: Dictionary = entries[i]
		var s: float = e["start_m"]
		var end_m: float = e["end_m"]

		if dist_in_cycle >= s and dist_in_cycle < end_m:
			matched_entry = e
			entry_idx = i
			break

	if matched_entry.is_empty() and not entries.is_empty():
		matched_entry = entries[-1]
		entry_idx = entries.size() - 1

	var is_trans: bool = matched_entry.get("is_transition", false)
	var trans_prog: float = 0.0

	if is_trans:
		var e_start: float = matched_entry["start_m"]
		var e_len: float = matched_entry["end_m"] - e_start
		if e_len > 0.0:
			trans_prog = clampf((dist_in_cycle - e_start) / e_len, 0.0, 1.0)

	return {
		"cumulative_distance": safe_dist,
		"cycle_index": cycle_idx,
		"distance_in_cycle": dist_in_cycle,
		"cycle_position": dist_in_cycle,
		"biome_local_distance": dist_in_cycle,
		"entry_index": entry_idx,
		"state": matched_entry.get("state", WorldState.NORMAL_LAND_1),
		"state_name": matched_entry.get("name", "Unknown"),
		"is_transition": is_trans,
		"active_biome": matched_entry.get("active_biome", BiomeType.NORMAL_LAND),
		"from_biome": matched_entry.get("from_biome", BiomeType.NORMAL_LAND),
		"to_biome": matched_entry.get("to_biome", BiomeType.NORMAL_LAND),
		"transition_progress": trans_prog,
		"profile_key": matched_entry.get("profile_key", "default"),
		"entry_start_m": matched_entry.get("start_m", 0.0),
		"entry_end_m": matched_entry.get("end_m", cycle_length_m),
		"cycle_length_m": cycle_length_m
	}

static func get_state_name(state: int) -> String:
	match state:
		WorldState.NORMAL_LAND:
			return "NORMAL_LAND"
		WorldState.NORMAL_NITRO_PROMPT:
			return "NORMAL_NITRO_PROMPT"
		WorldState.NORMAL_HEAVEN_LAUNCH:
			return "NORMAL_HEAVEN_LAUNCH"
		WorldState.HEAVEN:
			return "HEAVEN"
		WorldState.HEAVEN_TO_HELL_PORTAL:
			return "HEAVEN_TO_HELL_PORTAL"
		WorldState.HELL:
			return "HELL"
		WorldState.HELL_TO_NORMAL_PORTAL:
			return "HELL_TO_NORMAL_PORTAL"
		WorldState.TRANSITION_HEAVEN_TO_NORMAL:
			return "TRANSITION_HEAVEN_TO_NORMAL"
		WorldState.TRANSITION_NORMAL_TO_HELL:
			return "TRANSITION_NORMAL_TO_HELL"
		WorldState.NORMAL_LAND_2:
			return "NORMAL_LAND_2"
		WorldState.NORMAL_APPROACH:
			return "NORMAL_APPROACH"
		WorldState.RAMP_WARNING:
			return "RAMP_WARNING"
		WorldState.LAUNCH_WINDOW:
			return "LAUNCH_WINDOW"
		WorldState.HEAVEN_ENTRY:
			return "HEAVEN_ENTRY"
		WorldState.HELL_ENTRY:
			return "HELL_ENTRY"
		WorldState.HEAVEN_ACTIVE:
			return "HEAVEN_ACTIVE"
		WorldState.HELL_ACTIVE:
			return "HELL_ACTIVE"
		WorldState.EXIT_TRANSITION:
			return "EXIT_TRANSITION"
		WorldState.NORMAL_MERGE:
			return "NORMAL_MERGE"
		_:
			return "UNKNOWN_STATE"

static func get_biome_name(biome: int) -> String:
	match biome:
		BiomeType.NORMAL_LAND:
			return "Normal Land"
		BiomeType.HEAVEN:
			return "Heaven"
		BiomeType.HELL:
			return "Hell"
		_:
			return "Unknown Biome"
