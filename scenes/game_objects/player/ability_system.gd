class_name Ability_System extends CanvasLayer

@onready var blaster_sound: AudioStream = load("res://resources/audio/blaster4.wav")
@onready var charged_blaster_sound: AudioStream = load("res://resources/audio/blaster_big.wav")
@onready var charged_blaster_charging_sound: AudioStream = load("res://resources/audio/blaster_charge2.wav")

@export var ability_icon_card: PackedScene

var player
var blaster_icon_card

enum Secondary_weapons{NONE, CHARGED_SHOT, ROCKET}
var selected_secondary_weapon = Secondary_weapons.NONE

var player_speed = App.PLAYER_BASE_SPEED
var speed_level: int = 0

#Primary Blaster Variables:
var blaster_enabled: bool = false
var blaster_ready: bool = true
var blaster_cooldown_level: float = 0
var blaster_damage_level = 0

#Charged Blaster Variables:
var charged_blaster_enabled = false
var charged_blaster_level = 0
var charged_blaster_timer: float = 0.75
var charged_blaster_current_charge = 0
var charged_blaster_max_charge = 3
var charged_blaster_charging: bool = false
var charged_blaster_charged: bool = false

#Rocket Variables:
var rocket_ready: bool = true

var rocket_cooldown_level: int = 0
var rocket_damage_level: float = 0

func _process(delta):
	if Input.is_action_pressed("primary_fire"):
		if blaster_enabled and blaster_ready and !Input.is_action_pressed("secondary_fire"): 
			blaster_ready = false
			fire_blaster(0)
					
	if Input.is_action_pressed("secondary_fire"):
		match selected_secondary_weapon:
			Secondary_weapons.CHARGED_SHOT:
				charged_blaster_charging = true	
				if charged_blaster_current_charge < charged_blaster_level + 1:
					if charged_blaster_timer > 0:
						charged_blaster_timer -= delta
					else:
						charge_charged_blaster()
						charged_blaster_timer = 1.5
					
			Secondary_weapons.ROCKET:
				fire_rocket()
							
	if Input.is_action_just_released("secondary_fire"):
		match selected_secondary_weapon:
			Secondary_weapons.CHARGED_SHOT:
				release_charged_blaster()
				
	if !Input.is_action_pressed("secondary_fire") and selected_secondary_weapon == Secondary_weapons.CHARGED_SHOT and charged_blaster_charging:
				release_charged_blaster()


func enable_blaster():
	blaster_enabled = true
	
	
func fire_blaster(charge_level):
	if charge_level == 0:	
		var pitch = randf_range(0.8, 1.2)
		SoundManager.play_sound_with_pitch(blaster_sound, pitch)
	else:
		SoundManager.play_sound_with_pitch(charged_blaster_charging_sound, 1)
	App.spawn_manager.spawn_blaster_bolt(player.fire_position.global_position, player.ship_cannon.global_rotation, 1 + blaster_damage_level, charge_level)
	player.ship_body.stop()
	player.ship_body.play("player_fire")
	await get_tree().create_timer(0.8 - (blaster_cooldown_level * .1)).timeout
	blaster_ready = true


func charge_charged_blaster():
	match charged_blaster_current_charge:
		0:
			player.ship_body.stop()
			player.ship_body.play("blaster_charge_1")
			SoundManager.play_sound_with_pitch(charged_blaster_charging_sound, 0.8)
			charged_blaster_current_charge += 1
		1:
			player.ship_body.stop()
			player.ship_body.play("blaster_charge_2")
			SoundManager.stop_sound(charged_blaster_charging_sound)
			SoundManager.play_sound_with_pitch(charged_blaster_charging_sound, 1)
			charged_blaster_current_charge += 1
		2:
			player.ship_body.stop()
			player.ship_body.play("blaster_charge_3")
			SoundManager.stop_sound(charged_blaster_charging_sound)
			SoundManager.play_sound_with_pitch(charged_blaster_charging_sound, 1.2)
			charged_blaster_current_charge += 1


func release_charged_blaster():
	if charged_blaster_charging:
		charged_blaster_charging = false
		charged_blaster_timer = 0.75
		if charged_blaster_current_charge > 0:
			blaster_ready = false
			fire_blaster(charged_blaster_current_charge)
			charged_blaster_current_charge = 0
		
	SoundManager.stop_sound(charged_blaster_charging_sound)
	

func fire_rocket():
	if rocket_ready:
		rocket_ready = false
		SoundManager.play_ambient_sound(blaster_sound)
		App.spawn_manager.spawn_rocket(player.fire_position.global_position, player.ship_cannon.global_rotation, rocket_damage_level)
		player.ship_body.stop()
		player.ship_body.play("player_fire")
		await get_tree().create_timer(1 - (rocket_cooldown_level * 0.1)).timeout
		rocket_ready = true


func update_ability(upgrade: Player_upgrade, current_abilities: Dictionary):
	match upgrade.id:
		"blaster_unlock":
			enable_blaster()
		"fire_rate":
			blaster_cooldown_level = (current_abilities["fire_rate"]["quantity"])
		"fire_damage":
			blaster_damage_level = current_abilities["fire_damage"]["quantity"]
		"speed_upgrade":
			speed_level = current_abilities["speed_upgrade"]["quantity"]
			player_speed = App.PLAYER_BASE_SPEED + (speed_level * 20)
		"blaster_charge_unlock":
			selected_secondary_weapon = Secondary_weapons.CHARGED_SHOT
		"blaster_charge_level":
			charged_blaster_level = current_abilities["blaster_charge_level"]["quantity"]
		"rocket_unlock":
			selected_secondary_weapon = Secondary_weapons.ROCKET
		"rocket_damage":
			rocket_damage_level = current_abilities["rocket_damage"]["quantity"]
		_:
			return
