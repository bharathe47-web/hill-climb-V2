@tool
extends SceneTree

const OUT_PATH = "res://docs/hell_redesign/contact_sheets/current_hell_assets_audit.png"

func _init() -> void:
	print("--- AUDITING CURRENT HELL SCENE & ASSETS ---")
	var scene: PackedScene = load("res://scenes/environment/hell/HellEnvironment.tscn")
	if not scene:
		printerr("Cannot load HellEnvironment.tscn")
		quit(1)
		return

	var inst := scene.instantiate()
	var nodes_info: Array[Dictionary] = []

	_collect_nodes(inst, nodes_info)
	print("Collected %d nodes from HellEnvironment.tscn:" % nodes_info.size())
	for info in nodes_info:
		print("  Node: %s | Type: %s | Pos: %s | Scale: %s | Z: %d | Motion: %s | Tex: %s" % [
			info["path"], info["type"], str(info["pos"]), str(info["scale"]),
			info["z_index"], str(info["motion"]), info["tex_path"]
		])

	# Generate visual audit contact sheet of the active assets
	_generate_audit_sheet(nodes_info)

	inst.free()
	quit(0)

func _collect_nodes(node: Node, list: Array[Dictionary], parent_path: String = "") -> void:
	var cur_path: String
	if parent_path != "":
		cur_path = parent_path + "/" + str(node.name)
	else:
		cur_path = str(node.name)
	var info: Dictionary = {
		"name": node.name,
		"path": cur_path,
		"type": node.get_class(),
		"pos": Vector2.ZERO,
		"scale": Vector2.ONE,
		"z_index": 0,
		"motion": Vector2.ONE,
		"tex_path": ""
	}

	if node is Node2D:
		info["pos"] = node.position
		info["scale"] = node.scale
		info["z_index"] = node.z_index

	if node is ParallaxLayer:
		info["motion"] = node.motion_scale

	if node is Sprite2D and node.texture:
		info["tex_path"] = node.texture.resource_path
	elif node is TextureRect and node.texture:
		info["tex_path"] = node.texture.resource_path
	elif node is AnimatedSprite2D and node.sprite_frames:
		info["tex_path"] = node.sprite_frames.resource_path

	if info["tex_path"] != "":
		list.append(info)

	for c in node.get_children():
		_collect_nodes(c, list, cur_path)

func _generate_audit_sheet(nodes_info: Array[Dictionary]) -> void:
	var sheet_w := 1400
	var cell_w := 260
	var cell_h := 200
	var cols := 5
	var rows := int(ceil(float(nodes_info.size()) / float(cols)))
	var sheet_h := rows * cell_h + 80

	var sheet := Image.create(sheet_w, sheet_h, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.12, 0.08, 0.08, 1.0)) # Dark slate charcoal background

	var font := ThemeDB.fallback_font

	for i in range(nodes_info.size()):
		var info := nodes_info[i]
		var col := i % cols
		var row := i / cols
		var bx := col * cell_w + 30
		var by := row * cell_h + 50

		# Draw border box
		for x in range(bx, bx + cell_w - 20):
			sheet.set_pixel(x, by, Color(0.4, 0.25, 0.25, 1.0))
			sheet.set_pixel(x, by + cell_h - 30, Color(0.4, 0.25, 0.25, 1.0))
		for y in range(by, by + cell_h - 30):
			sheet.set_pixel(bx, y, Color(0.4, 0.25, 0.25, 1.0))
			sheet.set_pixel(bx + cell_w - 20, y, Color(0.4, 0.25, 0.25, 1.0))

		# Load texture thumbnail
		var tex_p: String = info["tex_path"]
		if tex_p.begins_with("res://") and ResourceLoader.exists(tex_p):
			var res = load(tex_p)
			var img: Image = null
			if res is Texture2D:
				img = res.get_image()
			elif res is SpriteFrames and res.has_animation("default"):
				var frame_tex = res.get_frame_texture("default", 0)
				if frame_tex:
					img = frame_tex.get_image()
			elif res is SpriteFrames and res.get_animation_names().size() > 0:
				var first_anim = res.get_animation_names()[0]
				var frame_tex = res.get_frame_texture(first_anim, 0)
				if frame_tex:
					img = frame_tex.get_image()

			if img and not img.is_empty():
				var thumb := img.duplicate()
				thumb.convert(Image.FORMAT_RGBA8)
				var tw := cell_w - 40
				var th := cell_h - 70
				thumb.resize(tw, th, Image.INTERPOLATE_BILINEAR)
				sheet.blit_rect(thumb, Rect2i(0, 0, tw, th), Vector2i(bx + 10, by + 10))

	var abs_out := ProjectSettings.globalize_path(OUT_PATH)
	sheet.save_png(abs_out)
	print("[✓] Saved Current Hell Assets Contact Sheet: %s (%dx%d)" % [OUT_PATH, sheet_w, sheet_h])
