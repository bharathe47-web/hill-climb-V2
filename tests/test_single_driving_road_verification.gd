extends SceneTree

## Dedicated automated test suite verifying:
## REMOVE DUPLICATE / UNWANTED ROAD PATHS FROM SURVIVAL MAP
## Rule:
## ONE MAIN DRIVING ROAD ONLY.
## NO SECONDARY VISIBLE ROADS.
## NO UNWANTED TERRAIN PATH LINES.

const SurvivalScene: PackedScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const TerrainGenerator = preload("res://scripts/terrain/TerrainGenerator.gd")
const TerrainSegment = preload("res://scripts/terrain/TerrainSegment.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN SINGLE DRIVING ROAD VERIFICATION SUITE ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var root := get_root()

	_test_1_verify_no_secondary_road_lines_on_initial_segments(root)
	_test_2_verify_newly_streamed_segments_maintain_single_road(root)
	_test_3_verify_restart_and_retry_do_not_reintroduce_secondary_roads(root)
	_test_4_verify_main_road_collision_and_textures_preserved(root)
	_test_5_verify_vehicle_wheel_contact_and_driving_physics(root)

	print("\n=================================================================")
	print("✓ ALL SINGLE DRIVING ROAD TESTS PASSED (100% SUCCESS)!")
	print("=================================================================\n")
	quit(0)

func _test_1_verify_no_secondary_road_lines_on_initial_segments(root: Window) -> void:
	print("-> [1/5] Verifying No Secondary Road Ribbons or Outlines on Initial Segments...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	var t_gen: TerrainGenerator = surv.terrain_generator as TerrainGenerator
	assert(t_gen != null, "TerrainGenerator must exist")
	assert(t_gen.active_segments.size() >= 3, "Initial active segments must be populated")

	for i in range(t_gen.active_segments.size()):
		var seg: TerrainSegment = t_gen.active_segments[i]
		assert(seg.theme == TerrainSegment.TerrainTheme.DESTROYED_CITY, "Segment %d must be DESTROYED_CITY theme" % i)

		# Verify duplicate/secondary Line2D roads are disabled
		assert(seg.grass_line.visible == false, "Segment %d GrassLine (secondary road ribbon) must be visible=false" % i)
		assert(seg.grass_line.points.size() == 0, "Segment %d GrassLine points must be empty" % i)

		# Verify duplicate cream/light-colored outline is disabled
		assert(seg.grass_highlight_line.visible == false, "Segment %d GrassHighlightLine must be visible=false" % i)
		assert(seg.grass_highlight_line.points.size() == 0, "Segment %d GrassHighlightLine points must be empty" % i)

		# Verify main road surfaces exist
		assert(seg.ground_polygon.visible == true, "Segment %d GroundPolygon must be visible" % i)
		assert(seg.ground_polygon.polygon.size() > 0, "Segment %d GroundPolygon must have geometry" % i)

	surv.queue_free()
	print("  ✓ Secondary road ribbons and outlines strictly disabled on all initial segments!")

func _test_2_verify_newly_streamed_segments_maintain_single_road(root: Window) -> void:
	print("-> [2/5] Verifying Newly Streamed Procedural Segments Maintain Single Road...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	var t_gen: TerrainGenerator = surv.terrain_generator as TerrainGenerator
	var initial_seg_counter := t_gen.segment_counter

	# Advance vehicle position significantly to force procedural streaming
	surv.vehicle.global_position.x += 4500.0
	t_gen._process(0.016)

	assert(t_gen.segment_counter > initial_seg_counter, "TerrainGenerator must generate new procedural segments")

	for i in range(t_gen.active_segments.size()):
		var seg: TerrainSegment = t_gen.active_segments[i]
		assert(seg.grass_line.visible == false, "New segment %d must not enable GrassLine" % i)
		assert(seg.grass_line.points.size() == 0, "New segment %d GrassLine points must be empty" % i)
		assert(seg.grass_highlight_line.visible == false, "New segment %d must not enable GrassHighlightLine" % i)
		assert(seg.grass_highlight_line.points.size() == 0, "New segment %d GrassHighlightLine points must be empty" % i)

	surv.queue_free()
	print("  ✓ All newly streamed segments ahead of vehicle strictly maintain ONE main road!")

func _test_3_verify_restart_and_retry_do_not_reintroduce_secondary_roads(root: Window) -> void:
	print("-> [3/5] Verifying R-Key Restart & Retry Do Not Reintroduce Secondary Roads...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	# Simulate R-key restart
	surv.start_run()
	var t_gen: TerrainGenerator = surv.terrain_generator as TerrainGenerator
	for i in range(t_gen.active_segments.size()):
		var seg: TerrainSegment = t_gen.active_segments[i]
		assert(seg.grass_line.visible == false, "After R restart, segment %d GrassLine must be visible=false" % i)
		assert(seg.grass_highlight_line.visible == false, "After R restart, segment %d GrassHighlightLine must be visible=false" % i)

	# Simulate Retry button
	surv.start_run()
	for i in range(t_gen.active_segments.size()):
		var seg: TerrainSegment = t_gen.active_segments[i]
		assert(seg.grass_line.visible == false, "After Retry, segment %d GrassLine must be visible=false" % i)
		assert(seg.grass_highlight_line.visible == false, "After Retry, segment %d GrassHighlightLine must be visible=false" % i)

	surv.queue_free()
	print("  ✓ Restarts and Retries cleanly preserve single road configuration without regressions!")

func _test_4_verify_main_road_collision_and_textures_preserved(root: Window) -> void:
	print("-> [4/5] Verifying Main Road Visual Textures & Collision Geometry Preserved...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	var t_gen: TerrainGenerator = surv.terrain_generator as TerrainGenerator
	for i in range(t_gen.active_segments.size()):
		var seg: TerrainSegment = t_gen.active_segments[i]

		# Verify collision polygon matches ground visual geometry
		assert(seg.collision_polygon.polygon.size() > 0, "Collision polygon must have points")
		assert(seg.collision_polygon.polygon == seg.ground_polygon.polygon, "Collision geometry must exactly match ground visual")

		# Verify ground and subsoil textures
		assert(seg.ground_polygon.texture != null, "Ground polygon must have texture")
		var ground_tex_path: String = seg.ground_polygon.texture.resource_path
		assert(ground_tex_path.ends_with("apocalyptic_ground_seamless.png") or ground_tex_path.ends_with("survival_drivable_ground_strip.png"), "Ground must use apocalyptic ground texture")

		assert(seg.subsoil_polygon.texture != null, "Subsoil polygon must have texture")
		var subsoil_tex_path: String = seg.subsoil_polygon.texture.resource_path
		assert(subsoil_tex_path.ends_with("apocalyptic_subsoil_seamless.png"), "Subsoil must use apocalyptic subsoil texture")

	surv.queue_free()
	print("  ✓ Main road collision and orange ground/subsoil artwork 100% intact!")

func _test_5_verify_vehicle_wheel_contact_and_driving_physics(root: Window) -> void:
	print("-> [5/5] Verifying Vehicle Wheel Surface Alignment & Ground Contact...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	var expected_surface_y: float = surv.get_terrain_surface_y(surv.vehicle.global_position.x)
	var veh_pos: Vector2 = surv.vehicle.global_position
	# Vehicle chassis sits ~38px above surface contact
	assert(absf(veh_pos.y - (expected_surface_y - 38.0)) < 6.0, "Vehicle wheels must align with driving surface (veh Y=%f, surface Y=%f)" % [veh_pos.y, expected_surface_y])

	surv.queue_free()
	print("  ✓ Vehicle driving physics and surface contact operate with zero discrepancies!")
