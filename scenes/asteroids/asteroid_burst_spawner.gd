extends Node2D

@export var small_asteroid: PackedScene
@onready var sprite: Sprite2D = %Sprite2D

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(%Sprite2D, "scale", Vector2(2, 2), 2)
	tween.set_parallel(true).tween_property(%Sprite2D, "modulate:a", 0, 2 )
	await tween.finished
	spawn_asteroids()
	

func spawn_asteroids():
	print("boom")
	var new_asteroidA = small_asteroid.instantiate() as Asteroid
	add_child(new_asteroidA)
	new_asteroidA.position = Vector2(-15, -15)
	new_asteroidA.asteroid_direction = Vector2(-1, -1)
	get_tree().root.add_child(new_asteroidA)
	
	var new_asteroidB = small_asteroid.instantiate() as Asteroid
	add_child(new_asteroidB)
	new_asteroidB.position = Vector2(15, -15)
	new_asteroidB.asteroid_direction = Vector2(1, -1)
	get_tree().root.add_child(new_asteroidB)
	
	var new_asteroidC = small_asteroid.instantiate() as Asteroid
	add_child(new_asteroidC)
	new_asteroidC.position = Vector2(-15, 15)
	new_asteroidC.asteroid_direction = Vector2(-1, 1)
	get_tree().root.add_child(new_asteroidC)
	
	var new_asteroidD = small_asteroid.instantiate() as Asteroid
	add_child(new_asteroidD)
	new_asteroidD.position = Vector2(15, 15)
	new_asteroidD.asteroid_direction = Vector2(1, 1)
	get_tree().root.add_child(new_asteroidA)
	pass
