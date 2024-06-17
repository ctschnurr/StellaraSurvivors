extends Node

#const START_TARGET_XP = 5
#const TARGET_XP_GROWTH = 5

enum input_device{KEYBOARD, CONTROLLER}

const START_TARGET_XP = 3
const TARGET_XP_GROWTH = 5
const UPGRADES_PER_LEVEL = 2
const BASE_PICKUP_ATTRACT: float = 150
const GOLDEN_ASTEROID_CHANCE: int = 1
const STAT_CHANGE_PARTICLE_MULTIPLIER: int = 1
const CAMERA_TRAUMA_MAX = 10

const play_area_x_min = 0
const play_area_x_max = 1280
const play_area_y_min = 0
const play_area_y_max = 720

const play_area_mid = Vector2(play_area_x_max / 2, play_area_y_max / 2)

const CRATE_EVENT_TARGET: float = 25.0

var main_music: AudioStream = load("res://resources/audio/Cosmic Journey.mp3")
var asteroid_collision_sound: AudioStream = load("res://resources/audio/asteroid_collision.wav")
var asteroid_burst_sound: AudioStream = load("res://resources/audio/asteroid_burst.wav")
var upgrade_selected_sound: AudioStream = load("res://resources/audio/upgrade.wav")
var level_up_sound: AudioStream = load("res://resources/audio/level_up.wav")
var pickup_sound: AudioStream = load("res://resources/audio/pickup_xp.wav")
var player_hurt_sound: AudioStream = load("res://resources/audio/player_hurt.wav")

var stat_change_particles = load("res://scenes/effects/stat_change_particles.tscn")

var player_score = 0
var high_score = 0
var high_score_saver: Save_resource
var difficulty_factor = 0
var pickup_attract_distance = BASE_PICKUP_ATTRACT

signal player_hurt(current_health)
signal player_dead
signal start_game
signal reset_game
signal score_updated(player_score, high_score)

var camera:Camera2D
var player: Player
@export var player_scene: PackedScene

var mission_manager: Mission_manager
var experience_manager: Experience_manager
var enemy_manager: Enemy_manager
var screen_manager: Screen_Manager
var upgrade_manager: Upgrade_manager
var event_manager: Event_manager
var spawn_manager: Spawn_manager

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


func emit_player_dead(_max_health):
	check_save()
	player_dead.emit()
	
	
func request_reset_game():
	emit_reset_game()
	
	
func emit_reset_game():
	player_score = 0
	score_updated.emit(player_score, high_score)
	check_save()
	reset_game.emit()
	
	
func request_start_game():
	emit_start_game()
	
	
func emit_start_game():
	check_save()
	start_game.emit()
	score_updated.emit(player_score, high_score)
	
	
func update_score(score: int):
	player_score += score
	if player_score >= high_score:
		high_score = player_score
		
	score_updated.emit(player_score, high_score)


func check_save():
	if ResourceLoader.exists("user://stellara_hs.res"):
		high_score_saver = ResourceLoader.load("user://stellara_hs.res")
		if high_score_saver is Save_resource: # Check that the data is valid
			if high_score_saver.high_score > high_score: 
				high_score = high_score_saver.high_score
			else:
				high_score_saver.high_score = high_score
	else:
		high_score_saver = Save_resource.new()
		
	var save = ResourceSaver.save(high_score_saver, "user://stellara_hs.res")
	assert(save == OK)
