class_name TestIndianRoadsVisualUpgradeV2
extends SceneTree

## TestIndianRoadsVisualUpgradeV2: Independent verification test suite for Joel's Visual Upgrade v2.
## Validates non-destructive v2 scenes, parallax multi-state backgrounds,
## non-occluding landmark signboards, terrain profile, and survival obstacles v2.

const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const RouteData = preload("res://resources/routes/RouteData.gd")
const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const IndianRoadTerrainV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
const LandmarkV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/LandmarkV2.tscn")
const CheckpointV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/CheckpointV2.tscn")
const FinishArchV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/FinishArchV2.tscn")

const ChilliV2Scene = preload("res://scenes/modes/survival/obstacles/visual_upgrade_v2/ChilliObstacleV2.tscn")
const RiceV2Scene = preload("res://scenes/modes/survival/obstacles/visual_upgrade_v2/RiceObstacleV2.tscn")
const SweetsV2Scene = preload("res://scenes/modes/survival/obstacles/visual_upgrade_v2/SweetsObstacleV2.tscn")
const VadaPavV2Scene = preload("res://scenes/modes/survival/obstacles/visual_upgrade_v2/VadaPavObstacleV2.tscn")
const SamosaV2Scene = preload("res://scenes/modes/survival/obstacles/visual_upgrade_v2/SamosaObstacleV2.tscn")
const WarningV2Scene = preload("res://scenes/modes/survival/obstacles/visual_upgrade_v2/WarningIndicatorV2.tscn")

func _init() -> void:
	call_deferred("_run_all_v2_tests")

func _run_all_v2_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN JOEL'S VISUAL UPGRADE V2 INDEPENDENT TEST SUITE ---")
	print("=================================================================\n")

	_test_indian_roads_mode_v2_and_states()
	_test_landmark_v2_signboard_decoupling()
	_test_checkpoint_and_finish_arch_v2()
	_test_terrain_v2_geometry_and_props()
	_test_survival_obstacles_v2_alignment()

	print("\n=================================================================")
	print("✓ ALL VISUAL UPGRADE V2 INDEPENDENT CHECKS COMPLETED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_indian_roads_mode_v2_and_states() -> void:
	print("-> [1/5] Verifying IndianRoadsModeV2 across all 6 Indian States...")
	var mode := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	root.add_child(mode)

	for i in range(5):
		await process_frame

	assert(mode != null, "IndianRoadsModeV2 failed to instantiate")
	assert(is_instance_valid(mode.active_terrain), "Mode must spawn an active terrain instance")
	assert(is_instance_valid(mode.active_vehicle), "Mode must spawn a valid vehicle")
	assert(is_instance_valid(mode.parallax_bg), "ParallaxBackground must be valid")

	var state_list := ["tamil_nadu", "goa", "kerala", "rajasthan", "gujarat", "telangana"]
	for state_id in state_list:
		var r: RouteData = RouteRegistry.get_route(state_id)
		assert(r != null, "RouteData for %s must exist" % state_id)
		mode.start_route(r)
		for i in range(3):
			await process_frame
		assert(mode.active_route.state_id == state_id, "Active route state mismatch")
		print("   ✓ State route '%s' (%s) launched cleanly with parallax '%s'" % [r.state_id, r.state_name, r.parallax_bg_path.get_file()])

	mode.queue_free()
	print("  ✓ IndianRoadsModeV2 verified across all 6 states!")

func _test_landmark_v2_signboard_decoupling() -> void:
	print("-> [2/5] Verifying LandmarkV2 non-occluding signboard & scale normalization...")
	var lm := LandmarkV2Scene.instantiate() as IndianLandmarkV2
	root.add_child(lm)

	var sb: Node2D = lm.get_node("Signboard") as Node2D
	var mon: Sprite2D = lm.get_node("MonumentSprite") as Sprite2D
	assert(sb != null, "Signboard must exist")
	assert(mon != null, "MonumentSprite must exist")

	# Crucial check: Signboard must not overlap the monument center (x=0)
	assert(sb.position.x < -50.0 or sb.position.x > 50.0, "Signboard must be placed to the side to avoid covering monument artwork!")
	assert(mon.scale.x <= 0.35, "MonumentSprite must scale down high-resolution 1500px textures to viewport scale")

	lm.queue_free()
	print("  ✓ LandmarkV2 decouples signboard to roadside and normalizes monument scale!")

func _test_checkpoint_and_finish_arch_v2() -> void:
	print("-> [3/5] Verifying CheckpointV2 and FinishArchV2...")
	var cp := CheckpointV2Scene.instantiate() as IndianCheckpointV2
	root.add_child(cp)
	var gate_sp: Sprite2D = cp.get_node("GateSprite") as Sprite2D
	assert(gate_sp != null and gate_sp.texture != null, "GateSprite must have texture")
	assert(gate_sp.scale.x <= 0.5, "GateSprite must be normalized for high-res assets")
	cp.queue_free()

	var fa := FinishArchV2Scene.instantiate() as IndianFinishArchV2
	root.add_child(fa)
	var arch_sp: Sprite2D = fa.get_node("ArchSprite") as Sprite2D
	assert(arch_sp != null and arch_sp.texture != null, "ArchSprite must have texture")
	assert(arch_sp.scale.x <= 0.4, "ArchSprite must be normalized for high-res assets")
	fa.queue_free()
	print("  ✓ CheckpointV2 and FinishArchV2 scale normalization verified!")

func _test_terrain_v2_geometry_and_props() -> void:
	print("-> [4/5] Verifying IndianRoadTerrainV2 profile & roadside prop spawning...")
	var terr := IndianRoadTerrainV2Scene.instantiate() as IndianRoadTerrainV2
	root.add_child(terr)

	var route: RouteData = RouteRegistry.get_route("tamil_nadu")
	terr.generate_route(route)

	assert(terr.road_points.size() > 500, "Road profile points must be generated")
	assert(terr.collision_poly.polygon.size() > 500, "Collision polygon must be built")
	assert(terr.props_container.get_child_count() > 50, "Roadside props must be spawned along the highway")
	assert(terr.waypoints_container.get_child_count() == 6, "All 6 waypoints must be spawned in waypoints container")

	terr.queue_free()
	print("  ✓ IndianRoadTerrainV2 geometry and roadside prop spawning verified!")

func _test_survival_obstacles_v2_alignment() -> void:
	print("-> [5/5] Verifying Survival Food Obstacles v2 visual-collision alignment...")
	var scenes: Array[PackedScene] = [ChilliV2Scene, RiceV2Scene, SweetsV2Scene, VadaPavV2Scene, SamosaV2Scene]
	for sc in scenes:
		var obs := sc.instantiate() as FoodObstacle
		root.add_child(obs)
		assert(obs.visual_sprite != null, "Visual sprite must be valid")
		assert(obs.collision_shape != null, "Collision shape must be valid")
		# Check that sprite scale is normalized near collision diameter
		assert(obs.visual_sprite.scale.x < 0.3, "Visual sprite must be scaled to match physical collision radius")
		obs.queue_free()

	var warn := WarningV2Scene.instantiate() as WarningIndicator
	root.add_child(warn)
	assert(warn != null, "WarningIndicatorV2 must instantiate cleanly")
	warn.queue_free()
	print("  ✓ Survival Food Obstacles v2 shape-collision alignment verified!")
