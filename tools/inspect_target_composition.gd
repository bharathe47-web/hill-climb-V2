@tool
extends SceneTree

func _init() -> void:
	var target := Image.load_from_file("res://references/heaven_target.png")
	if not target:
		print("Target image not found")
		quit(0)
		return
	var tw = target.get_width()
	var th = target.get_height()
	print("Target size: %dx%d" % [tw, th])
	
	# Let's inspect where the columns/architecture are in heaven_target.png
	# Scan across x at y = th * 0.35 (palace colonnade level)
	quit(0)
