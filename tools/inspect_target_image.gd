@tool
extends SceneTree

func _init():
	var target = Image.load_from_file("res://references/heaven_target.png")
	print("Target size: ", target.get_size())
	# Let's inspect the layout of target image
	quit(0)
