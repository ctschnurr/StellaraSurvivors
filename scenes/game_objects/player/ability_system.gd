class_name Ability_System extends CanvasLayer

@onready var blaster_sound: AudioStream = load("res://resources/audio/blaster_fired.wav")
@onready var charged_blaster_sound: AudioStream = load("res://resources/audio/charged_blaster_fired.wav")
@onready var charged_blaster_charging_sound: AudioStream = load("res://resources/audio/charged_blaster_charging.wav")
@onready var charged_blaster_charged_sound: AudioStream = load("res://resources/audio/charged_blaster_charged.wav")
@onready var rocket_fire_sound: AudioStream = load("res://resources/audio/rocketB.wav")

@export var ability_icon_card: PackedScene

var player
var blaster_icon_card
var debug = true;

enum Secondary_weapons{NONE, CHARGED_BLASTER, ROCKET_LAUNCHER, ENERGY_PULSE}
var selected_secondary_weapon = Secondary_weapons.ENERGY_PULSE

var player_speed = App.PLAYER_BASE_SPEED
var speed_level: int = 0

#Primary Blaster Variables:
@onready var blaster_timer: Timer = %BlasterTimer

var blaster_enabled: bool = false
var blaster_ready: bool = true

var blaster_cooldown_level: float = 0
var blaster_damage_level = 0

#Charged Blaster Variables:
@onready var charged_blaster_timer: Timer = %ChargedBlasterTimer

var charged_blaster_ready: bool = true
var charged_blaster_charging: bool = false
var charged_blaster_charges: Array[Blaster_Charge]

var charged_blaster_level = 0
var charged_blaster_cooldown_level: int = 0
var charged_blaster_chargetime_level: int = 0

#Rocket Variables:
var rocket_ready: bool = true

var rocket_cooldown_level: int = 0
var rocket_damage_level: float = 0

#Energy Pulse Variables:
var pulse_ready: bool = true

var pulse_strength_level = 3

func _process(delta):	
	if Input.is_action_pressed("primary_fire"):
		if blaster_enabled and blaster_ready and !Input.is_action_pressed("secondary_fire"): 
			fire_blaster(0)
			blaster_ready = false
					
	if Input.is_action_just_pressed("secondary_fire"):
		match selected_secondary_weapon:
			Secondary_weapons.CHARGED_BLASTER:
				if charged_blaster_ready:
					charged_blaster_charging = true
					charged_blaster_ready = false
					var new_charge = Blaster_Charge.new()
					new_charge.charge_count = 6 - charged_blaster_chargetime_level
					charged_blaster_charges.append(new_charge)
					charge_charged_blaster(new_charge)
					
			Secondary_weapons.ROCKET_LAUNCHER:
				fire_rocket()
				
			Secondary_weapons.ENERGY_PULSE:
				fire_pulse()
							
	if Input.is_action_just_released("secondary_fire"):
		match selected_secondary_weapon:
			Secondary_weapons.CHARGED_BLASTER:
				if charged_blaster_charging:
					release_charged_blaster()
					
	if debug:
		if Input.is_action_just_pressed("number1"):
			selected_secondary_weapon = Secondary_weapons.CHARGED_BLASTER
			
		if Input.is_action_just_pressed("number2"):
			selected_secondary_weapon = Secondary_weapons.ROCKET_LAUNCHER
			rocket_damage_level = 4
			
		if Input.is_action_just_pressed("number3"):
			selected_secondary_weapon = Secondary_weapons.ENERGY_PULSE
			pulse_strength_level = 4
			

func enable_blaster():
	blaster_enabled = true
	
	
func fire_blaster(charge_level):
	if charge_level == 0:	
		var pitch = randf_range(0.8, 1.2)
		SoundManager.play_sound_with_pitch(blaster_sound, pitch)
	else:
		SoundManager.play_sound_with_pitch(charged_blaster_sound, 1)
	App.spawn_manager.spawn_blaster_bolt(player.fire_position.global_position, player.ship_cannon.global_rotation, 1 + blaster_damage_level, charge_level)
	player.ship_body.stop()
	player.ship_body.play("player_fire")
	
	blaster_timer.stop()
	blaster_timer.wait_time = (0.8 - (blaster_cooldown_level * .1))
	blaster_timer.start()


func charge_charged_blaster(charge: Blaster_Charge):
	if charge.fired: pass
	if charge.charge_count > 0:
		match charge.charge_level:
			0:
				player.ship_body.play("blaster_charging_A")
				await SoundManager.play_sound_with_pitch(charged_blaster_charging_sound, 0.8).finished
				charge.charge_count -= 1
			1:
				player.ship_body.play("blaster_charging_B")
				await SoundManager.play_sound_with_pitch(charged_blaster_charging_sound, 1).finished
				charge.charge_count -= 1
			2:
				player.ship_body.play("blaster_charging_C")
				await SoundManager.play_sound_with_pitch(charged_blaster_charging_sound, 1.2).finished
				charge.charge_count -= 1
			_:
				release_charged_blaster()
				pass
				
		if !charge.fired: charge_charged_blaster(charge)		
		else: pass
			
	else:
		if charge.charge_level < charged_blaster_level:
			charge.charge_level += 1
			charge.charge_count = 6 - charged_blaster_chargetime_level
			charge_charged_blaster(charge)
			
		else:
			charge.charge_level += 1
			match charge.charge_level:
				1: SoundManager.play_sound_with_pitch(charged_blaster_charged_sound, 0.8)
				2: SoundManager.play_sound_with_pitch(charged_blaster_charged_sound, 1)
				3: SoundManager.play_sound_with_pitch(charged_blaster_charged_sound, 1.2)
			player.ship_body.play("blaster_charged")


func release_charged_blaster():
	if charged_blaster_charges.size() != 0:
		fire_blaster(charged_blaster_charges[0].charge_level)			
		for charge in charged_blaster_charges:
			charge.fired = true
		charged_blaster_charges.clear()
		blaster_ready = false
		charged_blaster_charging = false
		SoundManager.stop_sound(charged_blaster_charged_sound)

		charged_blaster_timer.stop()
		charged_blaster_timer.wait_time = (0.8 - (charged_blaster_cooldown_level * .1))
		charged_blaster_timer.start()
		

func fire_rocket():
	if rocket_ready:
		rocket_ready = false
		SoundManager.play_sound(rocket_fire_sound)
		App.spawn_manager.spawn_rocket(player.fire_position.global_position, player.ship_cannon.global_rotation, rocket_damage_level)
		player.ship_body.stop()
		player.ship_body.play("player_fire")
		await get_tree().create_timer(1 - (rocket_cooldown_level * 0.1)).timeout
		rocket_ready = true
		
		
func fire_pulse():
	if pulse_ready:
		pulse_ready = false
		SoundManager.play_sound(rocket_fire_sound)
		App.spawn_manager.spawn_energy_pulse(player.global_position, pulse_strength_level + 1, self)
		player.toggle_status()
		player.velocity = Vector2.ZERO
		player.ship_body.stop()
		player.ship_body.play("player_fire")
		await get_tree().create_timer(1 - (rocket_cooldown_level * 0.1)).timeout
		pulse_ready = true
		

func pulse_done():
	player.toggle_status()		


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
			selected_secondary_weapon = Secondary_weapons.CHARGED_BLASTER
		"blaster_charge_level":
			charged_blaster_level = current_abilities["blaster_charge_level"]["quantity"]
		"rocket_unlock":
			selected_secondary_weapon = Secondary_weapons.ROCKET_LAUNCHER
		"rocket_damage":
			rocket_damage_level = current_abilities["rocket_damage"]["quantity"]
		"pulse_unlock":
			selected_secondary_weapon = Secondary_weapons.ENERGY_PULSE
		_:
			return


func _on_blaster_timer_timeout():
	blaster_ready = true


func _on_charged_blaster_timer_timeout():
	charged_blaster_ready = true


class Blaster_Charge:
	
	var charge_count: int = 0
	var charge_level: int = 0
	var fired: bool = false

