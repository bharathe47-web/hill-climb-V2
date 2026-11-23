@tool
extends SceneTree

func _init() -> void:
	print("--- INSPECTING EXACT NON-TRANSPARENT PIXEL BOUNDS ---")
	_inspect_image("res://assets/environments/heaven/architecture/heaven_viaduct_arch_cutout.png", "Viaduct Arch")
	_inspect_image("res://assets/environments/heaven/architecture/heaven_column_corinthian_gold.png", "Column Corinthian Gold")
	_inspect_image("res://assets/environments/heaven/architecture/heaven_marble_deck_inlaid.png", "Marble Deck Inlaid")
	quit(0)

func _inspect_image(path: String, label: String) -> void:
	var img := Image.load_from_file(path)
	if not img:
		printerr("Failed to load:", path)
		return
	var w := img.get_width()
	var h := img.get_height()
	var min_x := w
	var max_x := -1
	var min_y := h
	var max_y := -1

	for y in range(h):
		for x in range(w):
			var a := img.get_pixel(x, y).a
			if a > 0.02: # Visible pixel threshold
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)

	print("[%s] Size: %dx%d" % [label, w, h])
	print("  Visible X bounds: [%d, %d] (width: %d, left margin: %d, right margin: %d)" % [
		min_x, max_x, max_x - min_x + 1, min_x, w - 1 - max_x
	])
	print("  Visible Y bounds: [%d, %d] (height: %d, top margin: %d, bottom margin: %d)" % [
		min_y, max_y, max_y - min_y + 1, min_y, h - 1 - max_y
	])

	# Also inspect top row (y=0..min_y+5) and bottom row (y=max_y-5..h-1) alpha
	var top_alphas = []
	for y in range(min_y, mini(h, min_y + 6)):
		top_alphas.append(img.get_pixel(w / 2, y).a)
	print("  Top center alphas (y=%d..%d): %s" % [min_y, min_y + top_alphas.size() - 1, top_alphas])

	var bot_alphas = []
	for y in range(maxi(0, max_y - 5), max_y + 1):
		bot_alphas.append(img.get_pixel(w / 2, y).a)
	print("  Bottom center alphas (y=%d..%d): %s" % [max_y - bot_alphas.size() + 1, max_y, bot_alphas])
