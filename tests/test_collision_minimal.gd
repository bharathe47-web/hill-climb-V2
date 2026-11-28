extends SceneTree

func _init() -> void:
	var space := PhysicsServer2D.space_create()
	PhysicsServer2D.space_set_active(space, true)
	print("Space created: ", space)
	quit(0)
