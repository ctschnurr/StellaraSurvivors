class_name Screen_Manager extends Node

var game_manager: Game_manager
@export var objective_info_scene: PackedScene
@export var player_health_info_scene: PackedScene
@export var main_menu: PackedScene
@export var win_screen: PackedScene
@export var lose_screen: PackedScene
@export var pause_screen: PackedScene
@export var options_screen: PackedScene

var objective_info_instance
var player_health_info_instance


func _ready():
	App.screen_manager = self
	App.player_hurt.connect(update_player_health)
	App.player_dead.connect(show_lose_screen)
	

func update_objective_node(info: String):
	if objective_info_instance == null:
		objective_info_instance = objective_info_scene.instantiate()
		add_child(objective_info_instance)

	objective_info_instance.update_objective_text(info)
	
	
func show_player_health():
	if player_health_info_instance == null:
		player_health_info_instance = player_health_info_scene.instantiate()
		add_child(player_health_info_instance)
		
	var health = App.player.get_health()
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
	
	
func show_lose_screen():
	await get_tree().create_timer(1.5).timeout
	var lose_screen_instance = lose_screen.instantiate()
	add_child(lose_screen_instance)
		
		
func show_pause():
	get_tree().paused = true
	var pause_screen_instance = pause_screen.instantiate()
	add_child(pause_screen_instance)
	pause_screen_instance.screen_manager = self
	
		
func quit_game():
	get_tree().quit()
	

func play_game():
	get_tree().paused = false
	App.request_reset_game()
	App.request_start_game()
	#game_manager.mission_manager.start_mission()
	
	
func show_options_screen(back_scene_name: String):
	var options_screen_instance = options_screen.instantiate()
	options_screen_instance.back_scene_name = back_scene_name
	add_child(options_screen_instance)
	
	
func back_button(back_scene_name: String):
	if back_scene_name == "Main_menu":
		show_main_menu()
	if back_scene_name == "Pause_screen":
		show_pause()
