class_name Home_scene extends Node2D

@export var tile_maps: Array[PackedScene]
var active_maps: Array

func _ready():
	for map in tile_maps:
		var new_map = map.instantiate()
		active_maps.append(new_map)
		add_child(new_map)
	for number in active_maps.size():
		active_maps[number].global_position = Vector2(-1000 * number, -1000 * number)


func _process(_delta):
	for map in active_maps:
		map.global_position += Vector2(0.5, 0.5)
		if map.global_position > Vector2(1000, 1000): 
			map.global_position = Vector2(-1000, -1000)
			move_child(map, 0)
	
	
func generate_maps():
	for i in 2:
		var new_tilemap = TileMap.new()
		#new_tilemap.tile_set = tile_set
		var vector_array: Array[Vector2i]
		for x in 300:
			for y in 300:
				vector_array.push_front(Vector2i(x, y))
		new_tilemap.set_cells_terrain_connect(0, vector_array, 0, 0)
		new_tilemap.global_position = Vector2(-300, -300)
		tile_maps.append(new_tilemap)
		add_child(new_tilemap)
