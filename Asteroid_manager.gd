extends Node

@export var small_asteroid: PackedScene

const MAX_ASTEROIDS: int = 500

var asteroids_list: Array


func _ready():
	spawn_asteroids()

func _process(_delta):
	$Timer.timeout.connect(on_timer_timeout)

func on_timer_timeout():
	if asteroids_list.size() <= MAX_ASTEROIDS:
		spawn_asteroids()


func spawn_asteroids():
	var spawn_number = randf_range(15, 20)
	for n in spawn_number:
		var asteroid_instance = small_asteroid.instantiate() as Node2D
		add_child(asteroid_instance)
		asteroid_instance.global_position = Vector2(-100, randf_range(400, 700))
		asteroids_list.append(asteroid_instance)

