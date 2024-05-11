class_name Screen_Manager extends Node

var game_manager: Game_manager
@export var objective_info_scene: PackedScene
@export var player_health_info_scene: PackedScene
@export var main_menu: PackedScene
@export var win_screen: PackedScene
@export var lose_screen: PackedScene
@export var pause_screen: PackedScene

var objective_info_instance
var player_health_info_instance

func update_objective_node(info: String):
	if objective_info_instance == null:
		objective_info_instance = objective_info_scene.instantiate()
		add_child(objective_info_instance)

	objective_info_instance.update_objective_text(info)
	
	
func show_player_health():
	if player_health_info_instance == null:
		player_health_info_instance = player_health_info_scene.instantiate()
		add_child(player_health_info_instance)
		
	var health = game_manager.mission_manager.player.get_health()
	player_health_info_instance.update_player_health_text(health)
	
func update_player_health(health: int):
	if player_health_info_instance == null:
		player_health_info_instance = player_health_info_scene.instantiate()
		add_child(player_health_info_instance)
		
	player_health_info_instance.update_player_health_text(health)


func show_main_menu():
	var main_menu_instance = main_menu.instantiate()
	add_child(main_menu_instance)
	main_menu_instance.screen_manager = self
		
		
func show_win_screen():
	get_tree().paused = true
	
	var win_screen_instance = win_screen.instantiate()
	add_child(win_screen_instance)
	win_screen_instance.screen_manager = self
	
	
func show_lose_screen():
	
	var lose_screen_instance = lose_screen.instantiate()
	add_child(lose_screen_instance)
	lose_screen_instance.screen_manager = self
		
		
func show_pause():
	get_tree().paused = true
	var pause_screen_instance = pause_screen.instantiate()
	add_child(pause_screen_instance)
	pause_screen_instance.screen_manager = self
	
		
func quit_game():
	get_tree().quit()
	

func play_game():
	get_tree().paused = false
	game_manager.mission_manager.start_mission()
