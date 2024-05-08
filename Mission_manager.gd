extends Node
class_name Mission_manager

var game_manager: Game_manager

@export var possible_spawn_commands:Array[Spawn_command] = []

func create_objective_destroy():
	game_manager.enemy_manager.add_command(possible_spawn_commands.pick_random().duplicate())
	
func complete_objective(objective: Objective):
	print("Objective Complete!")
	objective.clear_objective()
	pass
