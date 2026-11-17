@tool
extends SceneTree

func _init() -> void:
	var sched: Resource = load("res://scripts/progression/WorldCycleSchedule.gd").new()
	sched.call("init_default_schedule")
	var err := ResourceSaver.save(sched, "res://scripts/progression/default_world_cycle_schedule.tres")
	if err == OK:
		print("✓ Saved default_world_cycle_schedule.tres successfully!")
		quit(0)
	else:
		print("✗ Failed to save default_world_cycle_schedule.tres: ", err)
		quit(1)
