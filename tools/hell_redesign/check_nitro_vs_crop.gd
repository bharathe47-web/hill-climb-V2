@tool
extends SceneTree

func _init() -> void:
	var bl := Image.load_from_file("res://docs/hell_redesign/bottom_left_crop_569m.png")
	var brake := Image.load_from_file("res://assets/ui/controls/brake_pedal_normal.png")
	var btn := Image.load_from_file("res://assets/ui/controls/control_button_base.png")
	var nitro := Image.load_from_file("res://assets/effects/nitro/nitro_bottle.png")
	print("BL size: ", bl.get_size(), " Brake size: ", brake.get_size() if brake else Vector2i.ZERO, " Btn size: ", btn.get_size() if btn else Vector2i.ZERO)

	# Check what is at (x=240-20, y=624-600) = (220, 24) in the crop
	# In the crop:
	# Brake pedal was placed at local x = 32-20 = 12, y = -164+164 = 0..140
	# Nitro button was placed at local x = 188-20 = 168, y = 0..140
	# In the crop, the blue mark was at x in [245-20..342-20] = [225..322], y in [628-600..725-600] = [28..125]
	print("Nitro button occupies x=[168..308], y=[0..140] in this crop")
	print("Blue mark is on the right side of Nitro button: x=[225..322], y=[28..125]")
	quit(0)
