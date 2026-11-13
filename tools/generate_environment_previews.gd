@tool
extends SceneTree

func _init() -> void:
	print("=================================================================")
	print("--- RENDERING IN-ENGINE ENVIRONMENT PREVIEWS (VULKAN) ---")
	print("=================================================================")

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var camera := Camera2D.new()
	camera.position = Vector2(640, 360)
	vp.add_child(camera)

	# 1. Render Heaven Environment
	print("-> Rendering HeavenEnvironment...")
	var heaven: Node = load("res://scenes/environment/heaven/HeavenEnvironment.tscn").instantiate()
	vp.add_child(heaven)

	# Let animations and particles advance
	for i in range(12):
		await process_frame

	var heaven_tex := vp.get_texture()
	if heaven_tex:
		var heaven_img := heaven_tex.get_image()
		if heaven_img and not heaven_img.is_empty():
			heaven_img.save_png("docs/previews/heaven_environment_preview.png")
			print("  ✓ Saved docs/previews/heaven_environment_preview.png (1280x720)")

	heaven.queue_free()
	for i in range(3):
		await process_frame

	# 2. Render Hell Environment
	print("-> Rendering HellEnvironment...")
	var hell: Node = load("res://scenes/environment/hell/HellEnvironment.tscn").instantiate()
	vp.add_child(hell)

	for i in range(12):
		await process_frame

	var hell_tex := vp.get_texture()
	if hell_tex:
		var hell_img := hell_tex.get_image()
		if hell_img and not hell_img.is_empty():
			hell_img.save_png("docs/previews/hell_environment_preview.png")
			print("  ✓ Saved docs/previews/hell_environment_preview.png (1280x720)")

	hell.queue_free()
	for i in range(3):
		await process_frame

	camera.queue_free()
	vp.queue_free()

	print("=================================================================")
	print("✓ ALL IN-ENGINE ENVIRONMENT PREVIEWS RENDERED SUCCESSFULLY!")
	print("=================================================================")
	quit(0)
