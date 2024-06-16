class_name Objective_data extends Resource

signal objective_complete_signal(objective: Objective)
signal objective_updated_signal(objective: Objective, info: String)

enum Objective_type {DESTROY,SURVIVE,DEFEND}
@export var objective_type: Objective_type

@export var spawn_data: Spawn_data

@export_multiline var objective_description: String
@export var survive_timer_minutes: int
var objective_count: int
@export var objective_target: int
var objective_info: String

var connected_input_signals:Array[Signal] = []	

func update_objective_info():
	match objective_type:
		Objective_type.DESTROY:
			var name = spawn_data.who_description
			if objective_target - objective_count > 1: name = name + "s"
			objective_info = "Destroy %s %s" %[objective_target - objective_count, name]
			objective_updated_signal.emit(self, objective_info)
		Objective_type.SURVIVE:
			var time_left: int = App.mission_manager.get_survive_time_left()
			if time_left > 0:
				var seconds = time_left%60
				var minutes = (time_left/60)%60
				objective_info = "Survive for %01d:%02d" %[minutes, seconds]
				objective_updated_signal.emit(self, objective_info)
			else:
				objective_complete_signal.emit(self)
				pass


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
		Objective_type.DESTROY:
			objective_count += 1
			if objective_count == objective_target:
				objective_complete_signal.emit(self)
				
	update_objective_info()

