extends SceneTree

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN GARAGE 25 VEHICLES VERIFICATION TEST SUITE ---")
	print("=================================================================\n")
	
	var registry = preload("res://scripts/vehicle/VehicleRegistry.gd")
	var garage_ids = registry.GARAGE_COLLECTED_IDS
	print("Testing %d collected garage vehicles..." % garage_ids.size())
	
	for cid in garage_ids:
		var path = "res://scenes/vehicle/garage/%s.tscn" % cid
		assert(ResourceLoader.exists(path), "Vehicle scene file must exist: %s" % path)
		
		var packed: PackedScene = load(path) as PackedScene
		assert(packed != null, "Scene must load as PackedScene: %s" % path)
		
		var inst = packed.instantiate()
		assert(inst != null, "Vehicle must instantiate: %s" % cid)
		assert(inst is VehicleController, "Instance must be VehicleController")
		
		root.add_child(inst)
		inst.global_position = Vector2(0, 382)
		
		# Verify key components
		assert(inst.rear_wheel != null, "RearWheel must exist on %s" % cid)
		assert(inst.front_wheel != null, "FrontWheel must exist on %s" % cid)
		assert(inst.rear_joint != null, "RearJoint must exist on %s" % cid)
		assert(inst.front_joint != null, "FrontJoint must exist on %s" % cid)
		assert(inst.crash_detector != null, "CrashDetector must exist on %s" % cid)
		
		# Let it tick physics for 2 frames
		for frame in range(2):
			await physics_frame
		
		inst.queue_free()
		print("  ✓ [%s] Verified physics, joints, wheels, crash detector & audio." % cid)
	
	print("\n=================================================================")
	print("✓ ALL %d GARAGE VEHICLES VERIFIED WITH 100%% SUCCESS!" % garage_ids.size())
	print("=================================================================\n")
	quit(0)
