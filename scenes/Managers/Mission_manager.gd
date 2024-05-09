extends Node
class_name Mission_manager

var game_manager: Game_manager

@export var possible_spawn_commands:Array[Spawn_command] = []

func create_objective_destroy():
	var spawn_command: Spawn_command = possible_spawn_commands.pick_random().duplicate()
	spawn_command.associated_objective.objective_complete_signal.connect(complete_objective, CONNECT_ONE_SHOT)
	game_manager.enemy_manager.add_command(spawn_command)
	
func complete_objective(objective: Objective):
	print("Objective Complete!")
	objective.clear_objective()
	pass
