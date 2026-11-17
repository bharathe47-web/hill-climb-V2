@tool
extends SceneTree

## Tool script to render actual in-engine visual snapshots for Phase 7
## Captures:
## 1. docs/previews/dressing_normal_land.png
## 2. docs/previews/dressing_heaven.png
## 3. docs/previews/dressing_hell.png

func _init() -> void:
	print("--- RENDERING PHASE 7 DRESSING PREVIEWS ---")
	await _render_previews()
	print("✓ PHASE 7 PREVIEWS COMPLETE!")
	quit(0)

func _render_previews() -> void:
	var dir := DirAccess.open("res://docs/previews")
	if not dir:
		DirAccess.make_dir_recursive_absolute("res://docs/previews")

	# 1. Normal Land
	await _capture_scene("res://scenes/environment/ParallaxEnvironment.tscn", "res://docs/previews/dressing_normal_land.png")

	# 2. Heaven
	await _capture_scene("res://scenes/environment/heaven/HeavenEnvironment.tscn", "res://docs/previews/dressing_heaven.png")

	# 3. Hell
	await _capture_scene("res://scenes/environment/hell/HellEnvironment.tscn", "res://docs/previews/dressing_hell.png")

func _capture_scene(scene_path: String, out_png: String) -> void:
	print("Rendering: ", scene_path, " -> ", out_png)
	var packed: PackedScene = load(scene_path)
	if not packed:
		printerr("Failed to load scene: ", scene_path)
		return
		
	var sub_viewport := SubViewport.new()
	sub_viewport.size = Vector2i(1280, 720)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sub_viewport)

	var inst = packed.instantiate()
	sub_viewport.add_child(inst)

	# Add Camera2D positioned at default gameplay viewpoint
	var cam := Camera2D.new()
	cam.position = Vector2(640, 360)
	sub_viewport.add_child(cam)

	# Simulate 5 frames for particle & animation warmup
	for i in range(5):
		await process_frame

	var img: Image = sub_viewport.get_texture().get_image()
	if img:
		img.save_png(out_png)
		print("  ✓ Saved preview: ", out_png)
	else:
		printerr("  ✗ Failed to capture viewport image")

	sub_viewport.queue_free()
	await process_frame
