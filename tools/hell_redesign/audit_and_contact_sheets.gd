@tool
extends SceneTree

const SOURCE_DIR = "/home/daniel/Pictures/Assets For Hell"
const OUT_DIR = "res://docs/hell_redesign"
const CONTACT_SHEETS_DIR = "res://docs/hell_redesign/contact_sheets"

func _init() -> void:
	print("==================================================")
	print("PHASE 1: COMPLETE ASSET AUDIT & CONTACT SHEET GENERATION")
	print("==================================================")
	await _run_audit()
	quit(0)

func _run_audit() -> void:
	var dir_access := DirAccess.open(SOURCE_DIR)
	if not dir_access:
		printerr("Cannot open source directory:", SOURCE_DIR)
		return

	var all_files: Array[String] = []
	_scan_dir_recursive(SOURCE_DIR, all_files)
	print("Total files found in source directory: %d" % all_files.size())

	var image_records: Array[Dictionary] = []
	var other_records: Array[Dictionary] = []
	var categories: Dictionary = {
		"A_background": [],
		"B_fortress": [],
		"C_lava_fire": [],
		"D_decorations": [],
		"E_terrain": [],
		"F_characters": [],
		"other": []
	}

	for fpath in all_files:
		var ext := fpath.get_extension().to_lower()
		var fname := fpath.get_file()
		var fsize := FileAccess.get_file_as_bytes(fpath).size()

		if ext in ["png", "jpg", "jpeg", "webp", "bmp"]:
			var img := Image.load_from_file(fpath)
			if img:
				var w := img.get_width()
				var h := img.get_height()
				var has_a: bool = (img.detect_alpha() != Image.ALPHA_NONE)
				var rec := {
					"filename": fname,
					"path": fpath,
					"rel_path": fpath.replace(SOURCE_DIR + "/", ""),
					"format": ext.to_upper(),
					"width": w,
					"height": h,
					"aspect": float(w) / float(maxi(1, h)),
					"size_bytes": fsize,
					"has_alpha": has_a,
					"image": img
				}
				image_records.append(rec)
				_categorize_asset(rec, categories)
			else:
				other_records.append({
					"filename": fname,
					"path": fpath,
					"format": ext.to_upper(),
					"size_bytes": fsize,
					"type": "corrupt_image"
				})
		elif ext in ["zip", "rar"]:
			other_records.append({
				"filename": fname,
				"path": fpath,
				"format": ext.to_upper(),
				"size_bytes": fsize,
				"type": "archive"
			})
		elif ext in ["obj", "blend", "gltf", "glb"]:
			other_records.append({
				"filename": fname,
				"path": fpath,
				"format": ext.to_upper(),
				"size_bytes": fsize,
				"type": "3d_model"
			})
		elif ext in ["ogg", "wav", "mp3"]:
			other_records.append({
				"filename": fname,
				"path": fpath,
				"format": ext.to_upper(),
				"size_bytes": fsize,
				"type": "audio"
			})
		else:
			other_records.append({
				"filename": fname,
				"path": fpath,
				"format": ext.to_upper(),
				"size_bytes": fsize,
				"type": "doc_or_data"
			})

	print("Scanned %d visual images, %d other files." % [image_records.size(), other_records.size()])

	# Generate Contact Sheets
	_generate_contact_sheet(categories["A_background"] + categories["B_fortress"], "cs_01_backgrounds_and_fortresses.png", "A & B: Backgrounds, Skies & Castles", 4, 320, 180)
	_generate_contact_sheet(categories["C_lava_fire"], "cs_02_lava_and_fire.png", "C: Lava Waterfalls, Fire & VFX", 5, 256, 144)
	_generate_contact_sheet(categories["D_decorations"], "cs_03_decorations_props.png", "D: Dark Fantasy Decorations & Props", 6, 200, 200)
	_generate_contact_sheet(categories["E_terrain"], "cs_04_terrain_and_bridge.png", "E: Stone Bridge & Playable Terrain", 4, 320, 180)
	_generate_contact_sheet(categories["F_characters"], "cs_05_characters_and_enemies.png", "F: Characters, Skeletons & Bosses", 6, 180, 180)

	print("[✓] Generated all contact sheets in %s" % CONTACT_SHEETS_DIR)

func _scan_dir_recursive(path: String, out_files: Array[String]) -> void:
	var da := DirAccess.open(path)
	if not da:
		return
	da.list_dir_begin()
	var item := da.get_next()
	while item != "":
		if item != "." and item != ".." and not item.begins_with("."):
			var full_p := path + "/" + item
			if da.current_is_dir():
				_scan_dir_recursive(full_p, out_files)
			else:
				out_files.append(full_p)
		item = da.get_next()
	da.list_dir_end()

func _categorize_asset(rec: Dictionary, cats: Dictionary) -> void:
	var p: String = rec["rel_path"].to_lower()
	var fn: String = rec["filename"].to_lower()

	if "background" in p or "sky" in p or "castle" in p or "hellwake" in p or "sceneforge" in p or "assetsmithy" in p or "target" in p:
		if "fortress" in fn or "castle" in fn or "portal" in fn:
			cats["B_fortress"].append(rec)
		else:
			cats["A_background"].append(rec)
	elif "lava" in p or "fire" in p or "flame" in p or "torch" in fn or "campfire" in fn or "caldera" in p:
		cats["C_lava_fire"].append(rec)
	elif "skeleton" in p or "enemy" in p or "heros" in p or "dragon" in p:
		cats["F_characters"].append(rec)
	elif "bridge" in p or "tile" in p or "terrain" in p or "ground" in p or "stone" in p or "rock" in p:
		cats["E_terrain"].append(rec)
	elif "prop" in p or "banner" in fn or "chain" in fn or "cage" in fn or "skull" in fn or "chest" in fn or "potion" in fn or "lantern" in fn:
		cats["D_decorations"].append(rec)
	else:
		cats["D_decorations"].append(rec)

func _generate_contact_sheet(items: Array, filename: String, title: String, cols: int, cell_w: int, cell_h: int) -> void:
	if items.is_empty():
		return

	var count := items.size()
	var rows := int(ceil(float(count) / float(cols)))
	var padding := 16
	var header_h := 60
	var label_h := 30
	var total_w := padding + cols * (cell_w + padding)
	var total_h := header_h + padding + rows * (cell_h + label_h + padding)

	var sheet := Image.create(total_w, total_h, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.08, 0.06, 0.09, 1.0)) # Dark obsidian background

	for i in range(count):
		var item: Dictionary = items[i]
		var r := i / cols
		var c := i % cols
		var x := padding + c * (cell_w + padding)
		var y := header_h + padding + r * (cell_h + label_h + padding)

		# Draw cell border / background
		for cy in range(y, y + cell_h):
			for cx in range(x, x + cell_w):
				sheet.set_pixel(cx, cy, Color(0.14, 0.11, 0.16, 1.0))

		# Scale and blit image into cell maintaining aspect ratio
		var src: Image = item["image"]
		if src and not src.is_empty():
			var src_w := src.get_width()
			var src_h := src.get_height()
			var scale_f := minf(float(cell_w - 4) / float(src_w), float(cell_h - 4) / float(src_h))
			var draw_w := maxi(1, int(float(src_w) * scale_f))
			var draw_h := maxi(1, int(float(src_h) * scale_f))
			var off_x := x + (cell_w - draw_w) / 2
			var off_y := y + (cell_h - draw_h) / 2

			var scaled := src.duplicate()
			if scaled.get_format() != Image.FORMAT_RGBA8:
				scaled.convert(Image.FORMAT_RGBA8)
			scaled.resize(draw_w, draw_h, Image.INTERPOLATE_LANCZOS)
			sheet.blend_rect(scaled, Rect2i(0, 0, draw_w, draw_h), Vector2i(off_x, off_y))

	var out_path := CONTACT_SHEETS_DIR + "/" + filename
	var abs_out := ProjectSettings.globalize_path(out_path)
	sheet.save_png(abs_out)
	print("  [✓] Saved Contact Sheet: %s (%dx%d, %d items)" % [filename, total_w, total_h, count])
