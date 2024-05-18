extends Node
class_name Mission_manager

var game_manager: Game_manager
@export var player_scene: PackedScene
var player: Player

@export var possible_spawn_commands:Array[Spawn_command] = []

var objective_text = null
var bolts: Array


func _ready():
	App.mission_manager = self
	App.start_game.connect(start_mission)
	#App.reset_game.connect()


func start_mission():
	App.instantiate_player()
	#game_manager.enemy_manager.clear_enemies()
	#if player != null: 
	#	player.queue_free()
	#player = player_scene.instantiate()
	#get_tree().root.add_child(player)
	#player.health_component.hurt.connect(player_hurt)
	#player.health_component.died.connect(player_died)
	App.screen_manager.show_player_health()
	App.player.mission_manager = self
	App.player.global_position = Vector2(640,360)
	
	var spawn_command: Spawn_command = possible_spawn_commands.pick_random().duplicate()
	print("Connecting objective %s" % spawn_command.associated_objective)
	App.enemy_manager.add_command(spawn_command)
	spawn_command.associated_objective.objective_complete_signal.connect(complete_objective, CONNECT_ONE_SHOT)
	spawn_command.associated_objective.objective_updated_signal.connect(update_objective)
	spawn_command.associated_objective.update_objective_info()
	
	
func update_objective(_objective, text):
	App.screen_manager.update_objective_node(text)
	
	
func complete_objective(objective: Objective):
	App.screen_manager.update_objective_node("Objective Complete!")
	objective.objective_updated_signal.disconnect(update_objective)
	objective.clear_objective()
	
	App.screen_manager.show_win_screen()
