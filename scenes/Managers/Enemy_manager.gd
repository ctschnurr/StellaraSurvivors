extends Node
class_name Enemy_manager

var game_manager: Game_manager

@export var asteroid_small: PackedScene
@export var asteroid_medium: PackedScene
@export var asteroid_large: PackedScene

enum Enemy_type{ASTEROID_SMALL, ASTEROID_MEDIUM, ASTEROID_LARGE}
@onready var enemy_dictionary: Dictionary = {"ASTEROID_SMALL": asteroid_small, "ASTEROID_MEDIUM": asteroid_medium, "ASTEROID_LARGE": asteroid_large}

const asteroid_spawn_xRange = [-1000, -100]
const asteroid_spawn_yRange = [0, 720]

var spawn_commands: Array
var enemies: Array
				
				
func _process(_delta):
	if !spawn_commands.is_empty():
		for command in spawn_commands:
			if command.ready: process_command(command)



func add_command(command: Spawn_command):
	spawn_commands.append(command)
	if command.associated_objective != null: 
		command.associated_objective = command.associated_objective.duplicate()
		command.associated_objective.objective_complete_signal.connect(command.clear_associated_objective,CONNECT_ONE_SHOT)

func process_command(command: Spawn_command):
	command.ready = false
	match command.spawn_positioning:
		Spawn_command.Spawn_positioning.SCATTER:	
			for n in command.spawn_amount:
				var enemy_instance = command.enemy_type.pick_random().instantiate() as Node2D
				add_child(enemy_instance)
				enemies.append(enemy_instance)
				enemy_instance.enemy_manager = self
				enemy_instance.global_position = Vector2(randf_range(asteroid_spawn_xRange[0], asteroid_spawn_xRange[1]), randf_range(asteroid_spawn_yRange[0], asteroid_spawn_yRange[1]))
				
				if command.associated_objective != null:
					command.associated_objective.connect_signal(enemy_instance.health_component.died)
		Spawn_command.Spawn_positioning.ASTEROID_BURST:
			spawn_asteroid_burst(command)
			
			
	match command.repeat_state:
		Spawn_command.Repeat_state.INFINITE:
			await get_tree().create_timer(command.repeat_delay).timeout
			command.ready = true
			return
		Spawn_command.Repeat_state.MULTIPLE:
			if command.repeat_amount > 0:
				await get_tree().create_timer(command.repeat_delay).timeout
				command.repeat_amount -= 1
				command.ready = true
				return
		Spawn_command.Repeat_state.OBJECTIVE:
			if command.associated_objective != null:
				await get_tree().create_timer(command.repeat_delay).timeout
				command.ready = true
				return
	
	spawn_commands.erase(command)
	pass
	
	
func clear_enemies():
	for enemy in enemies:
		if enemy != null: enemy.queue_free()
	enemies = []
	spawn_commands = []
	
	
func spawn_asteroid_burst(command: Spawn_command):	
	var amount = randf_range(2, 4)
	var arrangement1: Array[Vector2] = [Vector2(1, 1), Vector2(-1, -1), Vector2(-1, 1), Vector2(1, -1)]
	var arrangement2: Array[Vector2] = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
	var arrangements: Array[Array] = [arrangement1, arrangement2]
	
	var asteroids: Array[Asteroid] = []
	for number in amount:
		var new_asteroid_select = command.possible_enemies.pick_random()
		var this_enum = Enemy_type.keys()[new_asteroid_select]
		var new_asteroid = enemy_dictionary[this_enum].instantiate() as Asteroid
		new_asteroid.enemy_manager = self
		enemies.append(new_asteroid)
		asteroids.append(new_asteroid)
		
	var arrange: Array[Vector2] = arrangements.pick_random().duplicate()
	
	for asteroid in asteroids:
		var position = arrange.pick_random()
		arrange.erase(position)
		
		asteroid.position = command.spawn_location + Vector2(position.x * (15 * asteroid.size_multiplier), position.y * (15 * asteroid.size_multiplier))
		asteroid.asteroid_direction = position
		asteroid.asteroid_speed = 75
		add_child(asteroid)
