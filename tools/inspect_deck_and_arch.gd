@tool
extends SceneTree

func _init():
	var deck = Image.load_from_file("res://assets/environments/heaven/architecture/heaven_marble_deck_inlaid.png")
	var arch = Image.load_from_file("res://assets/environments/heaven/architecture/heaven_viaduct_arch_cutout.png")
	print("Deck size: ", deck.get_size(), " format: ", deck.get_format())
	print("Arch size: ", arch.get_size(), " format: ", arch.get_format())

	# Inspect top, middle, bottom colors of deck
	for y in [0, 5, 10, 20, 40, 60, 75, 79]:
		var col = deck.get_pixel(320, y)
		print("  Deck y=%d: rgba(%.2f, %.2f, %.2f, %.2f)" % [y, col.r, col.g, col.b, col.a])

	# Inspect top, middle, bottom of arch
	for y in [0, 5, 15, 30, 80, 150, 279]:
		var col_l = arch.get_pixel(10, y)
		var col_m = arch.get_pixel(320, y)
		var col_r = arch.get_pixel(630, y)
		print("  Arch y=%d: left_a=%.2f mid_a=%.2f right_a=%.2f (mid_col: r=%.2f g=%.2f b=%.2f)" % [
			y, col_l.a, col_m.a, col_r.a, col_m.r, col_m.g, col_m.b
		])
	quit(0)
