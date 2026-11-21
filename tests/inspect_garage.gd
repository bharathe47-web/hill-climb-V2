extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var garage_scene = load("res://scenes/modes/garage/VintageCarGarage.tscn")
	var garage = garage_scene.instantiate()
	root.add_child(garage)
	garage._ready()
	await process_frame
	
	var vehicles = garage._vehicles
	print("Found %d vehicles in garage" % vehicles.size())
	for i in range(vehicles.size()):
		garage._current_index = i
		garage._display_current_vehicle(true)
		await process_frame
		var v = vehicles[i]
		var vid = v.get("id")
		var rect = garage.vehicle_display_rect
		var tex = rect.texture
		var tex_size = tex.get_size() if tex else Vector2.ZERO
		var parent_container = rect.get_parent()
		print("Vehicle %s [%s]: custom_min_size=%s, actual_rect_size=%s, texture_size=%s, parent_size=%s, rect_pos=%s" % [
			vid, v.get("display_name"), rect.custom_minimum_size, rect.size, tex_size, parent_container.size, rect.global_position
		])
	quit(0)
