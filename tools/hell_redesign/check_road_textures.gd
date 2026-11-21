@tool
extends SceneTree

func _init() -> void:
	var path := "res://assets/environments/hell/architecture/stone_terrain/hell_volcanic_brick_surface.png"
	var img := Image.load_from_file(path)
	if img:
		print("hell_volcanic_brick_surface size: %dx%d" % [img.get_width(), img.get_height()])
	var masonry := Image.load_from_file("res://assets/environments/hell/architecture/hell_bridge/stone_bridge_masonry.png")
	if masonry:
		print("stone_bridge_masonry size: %dx%d" % [masonry.get_width(), masonry.get_height()])
	var arch := Image.load_from_file("res://assets/environments/hell/architecture/hell_bridge/hell_volcanic_bridge_arch.png")
	if arch:
		print("hell_volcanic_bridge_arch size: %dx%d" % [arch.get_width(), arch.get_height()])
	quit(0)
