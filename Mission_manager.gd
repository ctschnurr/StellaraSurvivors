extends Node
class_name Mission_manager

var game_manager: Game_manager

func create_objective_destroy():
	var new_objective = Objective.Objective_destroy_enemies.new()
	new_objective.enemy_type = Enemy_manager.Enemy_type.ASTEROID
	new_objective.kill_target = 10
	new_objective.objective_complete_signal.connect(complete_objective)
	add_child(new_objective)
	
	var enemy_manager_command = Enemy_manager.Spawn_command.new()
	enemy_manager_command.repeat_state = Enemy_manager.Spawn_command.Repeat_state.OBJECTIVE
	enemy_manager_command.repeat_delay = 3
	enemy_manager_command.enemy_type = Enemy_manager.Enemy_type.ASTEROID
	enemy_manager_command.spawn_amount = 15
	enemy_manager_command.associated_objective = new_objective
	
	game_manager.enemy_manager.add_command(enemy_manager_command)
	
	
func complete_objective(objective: Objective):
	print("Objective Complete!")
	objective.queue_free()
	pass
