extends Node
class_name Objective
	
signal objective_complete_signal(this_objective)
var objective_complete: bool
	
enum Objective_type {DESTROY}
var type: Objective_type
	
func connect_signal(input: Signal):
	input.connect(signal_response)
	
func signal_response():
	pass


class Objective_destroy:
	extends Objective
	
	var kill_target: int = 0
	var kill_count: int = 0
	
	
	func _init():
		type = Objective.Objective_type.DESTROY
	
	
	func signal_response():
		kill_count += 1
		print(kill_count)
		if kill_count == kill_target:
			objective_complete_signal.emit(self)
