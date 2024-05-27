extends Resource
class_name Objective

signal objective_complete_signal(objective: Objective)
signal objective_updated_signal(objective: Objective, info: String)

enum Objective_type {DESTROY_ENEMIES,SURVIVE,DEFEND}

@export var objective_type: Objective_type
@export_multiline var objective_description: String
@export var survive_timer_minutes: int
var objective_count: int
@export var objective_target: int
var objective_info: String

var connected_input_signals:Array[Signal] = []	

func update_objective_info():
	var name = "asteroid"
	if objective_target - objective_count > 1: name = name + "s"
	objective_info = "Destroy %s %s" %[objective_target - objective_count, name]
	objective_updated_signal.emit(self, objective_info)
	
	
func update_survival_objective(time_left: int):
	if time_left > 0:
		var seconds = time_left%60
		var minutes: float = (time_left/60)%60
		objective_info = "Survive for %01d:%02d" %[minutes, seconds]
		objective_updated_signal.emit(self, objective_info)
	else:
		objective_complete_signal.emit(self)


func clear_objective():
	objective_count = 0
	
	#for connection_dictionary in objective_complete_signal.get_connections():
	#	objective_complete_signal.disconnect(connection_dictionary["callable"])
		
	for signals in connected_input_signals:
		signals.disconnect(signal_response)
	
	connected_input_signals = []

func connect_signal(input: Signal):
	input.connect(signal_response)


func signal_response(_dead_health):
	match objective_type:
		Objective_type.DESTROY_ENEMIES:
			objective_count += 1
			if objective_count == objective_target:
				objective_complete_signal.emit(self)
				
	update_objective_info()
