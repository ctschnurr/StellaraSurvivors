extends Node

signal player_hurt(current_health)
signal player_dead
signal start_game
signal reset_game

var player: Player
@export var player_scene: PackedScene

var experience_manager: Experience_manager
var enemy_manager: Enemy_manager
var screen_manager: Screen_Manager
var mission_manager: Mission_manager

var orb_attract_distance: float = 200
var starter_target_experience = 1


func instantiate_player():
	if player != null: 
		player.queue_free()
	player = player_scene.instantiate()
	get_tree().root.add_child(player)
	player.health_component.hurt.connect(emit_player_hurt)
	player.health_component.died.connect(emit_player_dead)


func set_player(new_player: Player):
	player = new_player
	player.health_component.died.connect(emit_player_dead)
	

func get_player():
	if player != null: return player


func emit_player_hurt(player_health: float):
	player_hurt.emit(player_health)


func emit_player_dead():
	player_dead.emit()
	
	
func request_reset_game():
	emit_reset_game()
	
	
func emit_reset_game():
	reset_game.emit()
	
	
func request_start_game():
	emit_start_game()
	
	
func emit_start_game():
	start_game.emit()

