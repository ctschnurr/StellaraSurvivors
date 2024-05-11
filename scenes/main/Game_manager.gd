extends Node
class_name Game_manager

@export var mission_manager: Mission_manager
@export var enemy_manager: Enemy_manager
@export var screen_manager: Screen_Manager

func _ready():
	mission_manager.game_manager = self
	enemy_manager.game_manager = self
	screen_manager.game_manager = self
	
	screen_manager.show_main_menu()
