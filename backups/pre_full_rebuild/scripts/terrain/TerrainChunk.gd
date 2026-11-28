extends StaticBody2D
class_name TerrainChunk

@onready var cliff_polygon: Polygon2D = $CliffPolygon
@onready var road_line: Line2D = $RoadLine
@onready var collision_poly: CollisionPolygon2D = $CollisionPolygon2D
@onready var props_container: Node2D = $PropsContainer

var chunk_index: int = 0
var start_x: float = 0.0
var end_x: float = 0.0

func setup_chunk(p_index: int, p_start_x: float, p_end_x: float, surface_points: PackedVector2Array, cliff_texture: Texture2D, road_texture: Texture2D) -> void:
	chunk_index = p_index
	start_x = p_start_x
	end_x = p_end_x
	position = Vector2.ZERO # Chunk points are in global world coordinates
	
	if surface_points.size() < 2:
		return
		
	# 1. Setup Road Line
	road_line.texture = road_texture
	road_line.texture_mode = Line2D.LINE_TEXTURE_TILE
	road_line.width = 38.0
	road_line.points = surface_points
	road_line.joint_mode = Line2D.LINE_JOINT_ROUND
	road_line.begin_cap_mode = Line2D.LINE_CAP_BOX
	road_line.end_cap_mode = Line2D.LINE_CAP_BOX
	
	# 2. Setup Cliff Polygon (Layered rock with vertical gradient)
	var poly_pts := PackedVector2Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	
	# Deep base Y level
	var base_y: float = 1800.0
	
	# Add top surface points
	for pt in surface_points:
		poly_pts.append(pt)
		uvs.append(pt / 512.0)
		colors.append(Color(1.0, 1.0, 1.0, 1.0)) # Bright at surface
		
	# Add bottom points to close the cross-section
	var last_x := surface_points[-1].x
	var first_x := surface_points[0].x
	
	poly_pts.append(Vector2(last_x, base_y))
	uvs.append(Vector2(last_x, base_y) / 512.0)
	colors.append(Color(0.22, 0.18, 0.16, 1.0)) # Darker toward bottom
	
	poly_pts.append(Vector2(first_x, base_y))
	uvs.append(Vector2(first_x, base_y) / 512.0)
	colors.append(Color(0.22, 0.18, 0.16, 1.0))
	
	cliff_polygon.polygon = poly_pts
	cliff_polygon.uv = uvs
	cliff_polygon.vertex_colors = colors
	cliff_polygon.texture = cliff_texture
	cliff_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	# 3. Setup Collision Polygon (exact match to visual surface)
	var col_pts := PackedVector2Array()
	for pt in surface_points:
		col_pts.append(pt)
	col_pts.append(Vector2(last_x, base_y))
	col_pts.append(Vector2(first_x, base_y))
	collision_poly.polygon = col_pts

func add_prop(node: Node2D) -> void:
	props_container.add_child(node)

func clear_props() -> void:
	for c in props_container.get_children():
		c.queue_free()
