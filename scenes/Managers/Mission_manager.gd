extends Node
class_name Mission_manager

var game_manager: Game_manager
var player: Player

@export var objective_array: Array[Objective_data]

var objective_text = null
var bolts: Array
var survive_timer: Timer

var current_objective: Objective_data

func _ready():
	App.mission_manager = self
	App.start_game.connect(start_mission)
	App.player_dead.connect(end_mission)
	#App.reset_game.connect()


func _process(_delta):
	if current_objective != null:
		current_objective.update_objective_info()
	#if current_objective != null:
		#if current_objective.objective_type == Objective.Objective_type.SURVIVE:
			#if survive_timer.is_stopped() == false:
				#current_objective.update_survival_objective(int(survive_timer.time_left))
	#if objective_array.size() > 0 && current_objective == null:
		#current_objective = objective_array[0]
		#start_mission(current_objective)
		
		
func get_survive_time_left():
	return survive_timer.time_left
	
	
func start_mission():
	App.instantiate_player()
	App.player.mission_manager = self
	App.player.global_position = App.play_area_mid

	#var spawn_command: Spawn_command = possible_spawn_commands.pick_random().duplicate()
	#App.enemy_manager.add_command(spawn_command)
	
	#var spawn_data: Spawn_data = possible_spawn_datas.pick_random().duplicate()
	
	#current_objective = spawn_command.associated_objective
	
	current_objective = objective_array[0].duplicate()
		
	current_objective.objective_complete_signal.connect(complete_objective, CONNECT_ONE_SHOT)
	current_objective.objective_updated_signal.connect(update_objective)
	
	App.spawn_manager.add_data(current_objective.spawn_data)
	current_objective.spawn_data.associated_objective = current_objective
	
	if current_objective.objective_type == Objective.Objective_type.SURVIVE:
		survive_timer = Timer.new()
		add_child(survive_timer)
		survive_timer.start(current_objective.survive_timer_minutes * 60)
		survive_timer.paused = true
		print(survive_timer.time_left)
		current_objective.update_objective_info()
		await get_tree().create_timer(1.5).timeout
		survive_timer.paused = false

	App.upgrade_manager.set_abilities_and_upgrades(current_objective.player_starting_abilities, current_objective.available_upgrades)

	
	
func end_mission():
	#if current_objective.objective_type == Objective.Objective_type.SURVIVE:
		#pass
		
	current_objective = null
	
	
func update_objective(_objective, text):
	App.screen_manager.update_objective_node(text)
	
	
func complete_objective(objective: Objective_data):
	App.screen_manager.update_objective_node("Objective Complete!")
	objective.objective_updated_signal.disconnect(update_objective)
	objective.clear_objective()
	
	App.screen_manager.show_win_screen()
	App.check_save()
