extends SceneTree

func _init() -> void:
	print("--- INSPECTING HELL SCENE AT RUNTIME ---")
	var main_scene: PackedScene = load("res://scenes/Main.tscn")
	if not main_scene:
		printerr("Failed to load Main.tscn")
		quit(1)
		return
		
	var main = main_scene.instantiate()
	root.add_child(main)
	
	# Wait for ready
	for i in range(5):
		await process_frame
		
	# Find BiomeEnvironmentHost and check active children
	var host = main.find_child("BiomeEnvironmentHost", true, false)
	if host:
		print("Found BiomeEnvironmentHost!")
		for child in host.get_children():
			print("Host child: ", child.name, " (", child.get_class(), ") visible=", child.visible if child is CanvasItem else "N/A")
			if child.name == "HellEnvironment":
				_print_tree(child, "  ")
	else:
		print("No BiomeEnvironmentHost found directly, checking full tree:")
		_print_canvas_items(main, "")
		
	quit(0)

func _print_tree(node: Node, indent: String) -> void:
	var info := "%s%s (%s)" % [indent, node.name, node.get_class()]
	if node is CanvasItem:
		info += " vis=%s z=%d" % [node.visible, node.z_index]
	if node is Sprite2D:
		info += " pos=%s tex=%s" % [node.position, node.texture.resource_path if node.texture else "null"]
	elif node is AnimatedSprite2D:
		info += " pos=%s frames=%s anim=%s" % [node.position, node.sprite_frames.resource_path if node.sprite_frames else "null", node.animation]
	elif node is TextureRect:
		info += " rect=%s tex=%s" % [node.size, node.texture.resource_path if node.texture else "null"]
	elif node is ParallaxLayer:
		info += " motion_scale=%s motion_mirroring=%s" % [node.motion_scale, node.motion_mirroring]
	print(info)
	for c in node.get_children():
		_print_tree(c, indent + "  ")

func _print_canvas_items(node: Node, indent: String) -> void:
	if node is Sprite2D or node is TextureRect or node is AnimatedSprite2D or "Hell" in node.name or "Cave" in node.name or "Bridge" in node.name:
		var info := "%s%s (%s)" % [indent, node.name, node.get_class()]
		if node is Sprite2D:
			info += " tex=%s" % (node.texture.resource_path if node.texture else "null")
		print(info)
	for c in node.get_children():
		_print_canvas_items(c, indent + "  ")
