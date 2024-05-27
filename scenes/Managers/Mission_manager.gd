extends Node
class_name Mission_manager

var game_manager: Game_manager
@export var player_scene: PackedScene
var player: Player

@export var possible_spawn_commands:Array[Spawn_command] = []

var objective_text = null
var bolts: Array
var survive_timer: Timer

var current_objective: Objective

func _ready():
	App.mission_manager = self
	App.start_game.connect(start_mission)
	App.player_dead.connect(end_mission)
	#App.reset_game.connect()


func _process(_delta):
	if current_objective != null:
		if current_objective.objective_type == Objective.Objective_type.SURVIVE:
			if survive_timer.is_stopped() == false:
				current_objective.update_survival_objective(survive_timer.time_left)
		
		
func start_mission():
	App.instantiate_player()
	App.player.mission_manager = self
	App.player.global_position = Vector2(App.play_area_x_max / 2, App.play_area_y_max / 2)
	
	
	
	
	# old system:
	var spawn_command: Spawn_command = possible_spawn_commands.pick_random().duplicate()
	App.enemy_manager.add_command(spawn_command)
	
	current_objective = spawn_command.associated_objective
	current_objective.objective_complete_signal.connect(complete_objective, CONNECT_ONE_SHOT)
	current_objective.objective_updated_signal.connect(update_objective)
	current_objective.update_objective_info()
	
	if current_objective.objective_type == Objective.Objective_type.SURVIVE:
		current_objective.update_survival_objective(current_objective.survive_timer_minutes * 60)
		survive_timer = Timer.new()
		add_child(survive_timer)
		await get_tree().create_timer(1.5).timeout
		survive_timer.start(current_objective.survive_timer_minutes * 60)
	
	
func end_mission():
	if current_objective.objective_type == Objective.Objective_type.SURVIVE:
		pass
		
	current_objective = null
	
	
func update_objective(_objective, text):
	App.screen_manager.update_objective_node(text)
	
	
func complete_objective(objective: Objective):
	App.screen_manager.update_objective_node("Objective Complete!")
	objective.objective_updated_signal.disconnect(update_objective)
	objective.clear_objective()
	
	App.screen_manager.show_win_screen()
	App.check_save()
