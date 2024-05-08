extends Node
class_name Objective
	
signal objective_complete_signal(this_objective)

enum Objective_type {DESTROY_ENEMIES,SURVIVE,DEFEND}
	
var objective_complete: bool
var objective_type: Objective_type
var objective_description: String
var objective_timer: Timer

func connect_signal(input: Signal):
	input.connect(signal_response)
	
func signal_response():
	pass


class Objective_destroy_enemies:
	extends Objective
	
	var kill_target: int = 0
	var kill_count: int = 0
	var enemy_type: Enemy_manager.Enemy_type
	
	
	func _init():
		objective_type = Objective_type.DESTROY_ENEMIES
		objective_description = "Destroy enemies!"
	
	func signal_response():
		kill_count += 1
		print(kill_count, "/", kill_target)
		if kill_count == kill_target:
			objective_complete_signal.emit(self)
