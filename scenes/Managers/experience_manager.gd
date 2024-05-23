class_name Experience_manager extends Node

signal update_experience(player_experience: float, target_experience: float)
signal level_up(new_level: int)

@export var xp_orb_scene: PackedScene
@export var xp_bar_scene: PackedScene

var player_experience: float
var player_level: int = 1
var xp_bar
var xp_orbs: Array

@onready var target_experience = App.START_TARGET_XP


func _ready():
	App.experience_manager = self
	App.reset_game.connect(reset)
	

func xp_collected(xp: float):
	if xp_bar == null:
		xp_bar = xp_bar_scene.instantiate()
		add_child(xp_bar)

	
	player_experience = min(player_experience + xp, target_experience)
	update_experience.emit(player_experience, target_experience)
	if player_experience == target_experience:
		player_level += 1
		target_experience += App.TARGET_XP_GROWTH
		player_experience = 0
		update_experience.emit(player_experience, target_experience)
		SoundManager.play_sound(App.level_up_sound)
		level_up.emit(player_level)
		

func spawn_xp_orb(spawn_position: Vector2, size_multiplier: int):
	var orb = xp_orb_scene.instantiate() as Experience_orb
	xp_orbs.append(orb)
	orb.collected.connect(xp_collected)
	orb.global_position = spawn_position
	orb.xp_amount *= size_multiplier
	orb.scale *= (1 + size_multiplier * 0.3)
	get_tree().root.add_child(orb)
	
	
func reset():
	if xp_bar != null:
		xp_bar.queue_free()

	player_experience = 0
	player_level = 1
	target_experience = App.START_TARGET_XP
	
	for orb in xp_orbs:
		if orb != null: orb.queue_free()
	xp_orbs = []
