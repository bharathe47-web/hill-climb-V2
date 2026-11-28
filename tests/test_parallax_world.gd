extends SceneTree

func _init() -> void:
	print("--- Running Test: Parallax World & Mirroring ---")
	var scene := load("res://scenes/world/ParallaxWorld.tscn") as PackedScene
	var world: Node = scene.instantiate()
	get_root().add_child(world)
	var sky: ParallaxLayer = world.get_node("SkyLayer")
	var cloud: ParallaxLayer = world.get_node("CloudLayer")
	var sea: ParallaxLayer = world.get_node("SeaLayer")
	print("Sky mirroring: ", sky.motion_mirroring)
	print("Cloud mirroring: ", cloud.motion_mirroring)
	print("Sea mirroring: ", sea.motion_mirroring)
	assert(sky.motion_mirroring.x == 2048.0, "Sky must mirror at 2048")
	assert(cloud.motion_mirroring.x == 2048.0, "Cloud must mirror at 2048")
	assert(sea.motion_mirroring.x == 2048.0, "Sea must mirror at 2048")
	print("--- Parallax World Test PASSED ---")
	quit(0)
