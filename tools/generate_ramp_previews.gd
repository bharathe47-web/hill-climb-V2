@tool
extends SceneTree

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	print("=================================================================")
	print("--- RENDERING IN-ENGINE RAMP PREVIEWS (VULKAN) ---")
	print("=================================================================")

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var camera := Camera2D.new()
	camera.position = Vector2(600, 200)
	camera.zoom = Vector2(0.85, 0.85)
	vp.add_child(camera)

	var seg_scene: PackedScene = load("res://scenes/terrain/TerrainSegment.tscn")
	var normal_prof: Resource = load("res://assets/terrain/profiles/normal_land_profile.tres")
	var heaven_prof: Resource = load("res://assets/terrain/profiles/heaven_terrain_profile.tres")
	var hell_prof: Resource = load("res://assets/terrain/profiles/hell_terrain_profile.tres")

	var ramps_data: Array[Dictionary] = [
		{
			"type": TerrainSegment.SegmentType.RAMP_NORMAL_TO_HEAVEN,
			"profile": heaven_prof,
			"height": -120.0,
			"amp": 95.0,
			"vehicle": "blue_flame_truck",
			"filename": "docs/previews/ramp_normal_to_heaven.png",
			"title": "Transition 1: Normal Land -> Heaven (Golden Gateway Launch Ramp)"
		},
		{
			"type": TerrainSegment.SegmentType.RAMP_HEAVEN_TO_NORMAL,
			"profile": normal_prof,
			"height": 120.0,
			"amp": 90.0,
			"vehicle": "dune_buggy",
			"filename": "docs/previews/ramp_heaven_to_normal.png",
			"title": "Transition 2: Heaven -> Normal Land (Celestial Cloud Return Slide)"
		},
		{
			"type": TerrainSegment.SegmentType.RAMP_NORMAL_TO_HELL,
			"profile": hell_prof,
			"height": 90.0,
			"amp": 110.0,
			"vehicle": "trophy_truck",
			"filename": "docs/previews/ramp_normal_to_hell.png",
			"title": "Transition 3: Normal Land -> Hell (Dragon Skull Chasm Plunge)"
		},
		{
			"type": TerrainSegment.SegmentType.RAMP_HELL_TO_NORMAL,
			"profile": normal_prof,
			"height": -90.0,
			"amp": 105.0,
			"vehicle": "orc_racer",
			"filename": "docs/previews/ramp_hell_to_normal.png",
			"title": "Transition 4: Hell -> Normal Land (Magma Geyser Escape Ramp)"
		}
	]

	# Ensure docs/previews exists
	DirAccess.make_dir_recursive_absolute("docs/previews")

	for r in ramps_data:
		print("-> Rendering %s..." % r["title"])
		var ramp: TerrainSegment = seg_scene.instantiate()
		ramp.segment_type = r["type"]
		ramp.segment_length = 1200.0
		ramp.start_height = 0.0
		ramp.end_height = r["height"]
		ramp.amplitude = r["amp"]
		ramp.start_slope = 0.0
		ramp.end_slope = 0.0
		ramp.terrain_profile = r["profile"]
		vp.add_child(ramp)
		ramp.rebuild_segment()

		# Add sample vehicle poised on the ramp
		var veh: VehicleController = VehicleRegistry.instantiate_vehicle(r["vehicle"])
		var mid_x: float = ramp.segment_length * 0.45
		var surf_sample := ramp.get_surface_point_and_normal_at(mid_x)
		veh.position = surf_sample["point"] + Vector2(0, -60)
		veh.rotation = surf_sample["normal"].angle() + PI * 0.5
		vp.add_child(veh)

		# Allow rendering to update
		for f in range(8):
			await process_frame

		var vp_tex := vp.get_texture()
		if vp_tex:
			var img := vp_tex.get_image()
			if img and not img.is_empty():
				img.save_png(r["filename"])
				print("  ✓ Saved %s (1280x720)" % r["filename"])

		veh.queue_free()
		ramp.queue_free()
		for f in range(2):
			await process_frame

	camera.queue_free()
	vp.queue_free()
	print("=================================================================")
	print("✓ ALL RAMP PREVIEWS GENERATED SUCCESSFULLY!")
	print("=================================================================")
	quit(0)
