extends Node

#const START_TARGET_XP = 5
#const TARGET_XP_GROWTH = 5

enum input_device{KEYBOARD, CONTROLLER}

const START_TARGET_XP = 3
const TARGET_XP_GROWTH = 5

const play_area_x_min = -30
const play_area_x_max = 1310
const play_area_y_min = -30
const play_area_y_max = 750

var main_music: AudioStream = load("res://resources/audio/Cosmic Journey.mp3")
var asteroid_collision_sound: AudioStream = load("res://resources/audio/asteroid_collision.wav")
var asteroid_burst_sound: AudioStream = load("res://resources/audio/asteroid_burst.wav")
var upgrade_selected_sound: AudioStream = load("res://resources/audio/upgrade.wav")
var level_up_sound: AudioStream = load("res://resources/audio/level_up.wav")
var player_hurt_sound: AudioStream = load("res://resources/audio/player_hurt.wav")

signal player_hurt(current_health)
signal player_dead
signal start_game
signal reset_game

var camera:Camera2D
var player: Player
@export var player_scene: PackedScene

var experience_manager: Experience_manager
var enemy_manager: Enemy_manager
var screen_manager: Screen_Manager
var mission_manager: Mission_manager
var upgrade_manager: Upgrade_manager

var orb_attract_distance: float = 200

var active_input: input_device = input_device.KEYBOARD

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

