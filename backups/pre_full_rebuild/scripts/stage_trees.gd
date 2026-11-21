extends SceneTree

func _init():
	print("--- CROPPING AND STAGING TREES ---")
	
	# Banyan tree: sprite_0099.png (1024x1024)
	var img_banyan = Image.new()
	img_banyan.load("res://assets/indian_roads_replacements/foliage/PNG/Shaded/sprite_0099.png")
	var r_banyan = img_banyan.get_used_rect()
	var crop_banyan = Image.create(r_banyan.size.x, r_banyan.size.y, false, Image.FORMAT_RGBA8)
	crop_banyan.blit_rect(img_banyan, r_banyan, Vector2i.ZERO)
	crop_banyan.save_png("res://assets/indian_roads_replacements/replacement_roadside_banyan_tree.png")
	print("Saved replacement banyan tree: ", r_banyan.size)
	
	# Coconut palm: sprite_0097.png (1024x1024)
	var img_palm = Image.new()
	img_palm.load("res://assets/indian_roads_replacements/foliage/PNG/Shaded/sprite_0097.png")
	var r_palm = img_palm.get_used_rect()
	var crop_palm = Image.create(r_palm.size.x, r_palm.size.y, false, Image.FORMAT_RGBA8)
	crop_palm.blit_rect(img_palm, r_palm, Vector2i.ZERO)
	crop_palm.save_png("res://assets/indian_roads_replacements/replacement_roadside_coconut_tree.png")
	print("Saved replacement coconut palm: ", r_palm.size)
	
	quit(0)
