extends Node
class_name Game_manager

@export var mission_manager: Mission_manager
@export var enemy_manager: Enemy_manager

func _ready():
	mission_manager.game_manager = self
	enemy_manager.game_manager = self
	
	mission_manager.create_objective_destroy()
