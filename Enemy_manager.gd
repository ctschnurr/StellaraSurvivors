extends Node
class_name Enemy_manager

var game_manager: Game_manager

@export var small_asteroid: PackedScene

enum Enemy_type {ASTEROID}

const asteroid_spawn_xRange = [-1000, -100]
const asteroid_spawn_yRange = [0, 720]

var spawn_commands: Array
				
				
func _process(_delta):
	if !spawn_commands.is_empty():
		for command in spawn_commands:
			if command.ready: process_command(command)

func create_command():
	pass


func add_command(command: Spawn_command):
	spawn_commands.append(command)
				
			
func process_command(command: Spawn_command):
	command.ready = false
	
	match command.enemy_type:
		Enemy_type.ASTEROID:
				for n in command.spawn_amount:
					var asteroid_instance = small_asteroid.instantiate() as Node2D
					add_child(asteroid_instance)
					asteroid_instance.global_position = Vector2(randf_range(asteroid_spawn_xRange[0], asteroid_spawn_xRange[1]), randf_range(asteroid_spawn_yRange[0], asteroid_spawn_yRange[1]))
					if command.associated_objective != null:
						command.associated_objective.connect_signal(asteroid_instance.health_component.died)
					
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
	
				
class Spawn_command:
	
	enum Spawn_orientation{SCATTER,SQUAD}
	enum Repeat_state{ONCE,MULTIPLE,INFINITE,OBJECTIVE}
	enum Repeat_mode{STEADY,RANDOM,ACCELERATING}
	
	var repeat_state: Repeat_state = Repeat_state.ONCE
	var repeat_mode: Repeat_mode = Repeat_mode.STEADY
	var repeat_delay: int = 0
	var repeat_amount: int = 0
	var ready: bool = true
	var enemy_type: Enemy_type
	var spawn_amount: int
	var spawn_orientation: Spawn_orientation
	var associated_objective: Objective

