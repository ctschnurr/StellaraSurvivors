extends Node
class_name Mission_manager

var game_manager: Game_manager
@export var player_scene: PackedScene
var player: Player

@export var possible_spawn_commands:Array[Spawn_command] = []

var objective_text = null
var bolts: Array

func start_mission():
	for bolt in bolts:
		if bolt != null: bolt.queue_free()	
	bolts = []
	game_manager.enemy_manager.clear_enemies()
	if player != null: 
		player.queue_free()
	player = player_scene.instantiate()
	add_child(player)
	player.health_component.hurt.connect(player_hurt)
	player.health_component.died.connect(player_died)
	game_manager.screen_manager.show_player_health()
	player.mission_manager = self
	player.global_position = Vector2(640,360)
	
	var spawn_command: Spawn_command = possible_spawn_commands.pick_random().duplicate()
	print("Connecting objective %s" % spawn_command.associated_objective)
	game_manager.enemy_manager.add_command(spawn_command)
	spawn_command.associated_objective.objective_complete_signal.connect(complete_objective, CONNECT_ONE_SHOT)
	spawn_command.associated_objective.objective_updated_signal.connect(update_objective)
	spawn_command.associated_objective.update_objective_info()
	
	
func update_objective(_objective, text):
	game_manager.screen_manager.update_objective_node(text)
	
	
func complete_objective(objective: Objective):
	game_manager.screen_manager.update_objective_node("Objective Complete!")
	objective.objective_updated_signal.disconnect(update_objective)
	objective.clear_objective()
	
	game_manager.screen_manager.show_win_screen()
	
	
func player_hurt(health: int):
	game_manager.screen_manager.update_player_health(health)
	

func player_died():
	game_manager.screen_manager.show_lose_screen()
	
	

