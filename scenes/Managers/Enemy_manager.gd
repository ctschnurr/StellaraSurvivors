extends Node
class_name Enemy_manager

var game_manager: Game_manager

@export var small_asteroid: PackedScene

enum Enemy_type {ASTEROID}

const asteroid_spawn_xRange = [-1000, -100]
const asteroid_spawn_yRange = [0, 720]

var spawn_commands: Array
var enemies: Array
				
				
func _process(_delta):
	if !spawn_commands.is_empty():
		for command in spawn_commands:
			if command.ready: process_command(command)

func create_command():
	pass

func add_command(command: Spawn_command):
	spawn_commands.append(command)
	command.associated_objective = command.associated_objective.duplicate()
	command.associated_objective.objective_complete_signal.connect(command.clear_associated_objective,CONNECT_ONE_SHOT)

func process_command(command: Spawn_command):
	command.ready = false
	for n in command.spawn_amount:
		var enemy_instance = command.enemy_type.pick_random().instantiate() as Node2D
		add_child(enemy_instance)
		enemies.append(enemy_instance)
		enemy_instance.global_position = Vector2(randf_range(asteroid_spawn_xRange[0], asteroid_spawn_xRange[1]), randf_range(asteroid_spawn_yRange[0], asteroid_spawn_yRange[1]))
		
		if command.associated_objective != null:
			command.associated_objective.connect_signal(enemy_instance.health_component.died)
		
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
	


