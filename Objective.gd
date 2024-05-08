extends Resource
class_name Objective

signal objective_complete_signal(this_objective)

enum Objective_type {DESTROY_ENEMIES,SURVIVE,DEFEND}

var objective_complete: bool
@export var objective_type: Objective_type
@export_multiline var objective_description: String
var objective_timer: Timer
var objective_count: int
@export var objective_target: int

var connected_input_signals:Array[Signal] = []

func clear_objective():
	objective_count = 0
	for connection_dictionary in objective_complete_signal.get_connections():
		objective_complete_signal.disconnect(connection_dictionary["callable"])
		
	for signals in connected_input_signals:
		signals.disconnect(signal_response)
	
	connected_input_signals = []

func connect_signal(input: Signal):
	input.connect(signal_response)

func signal_response():
	match objective_type:
		Objective_type.DESTROY_ENEMIES:
			objective_count += 1
			print(objective_count, "/", objective_target)
			if objective_count == objective_target:
				objective_complete_signal.emit(self)
