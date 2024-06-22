class_name Player extends CharacterBody2D

const ACCELERATION_SMOOTHING = 5
const BASE_SPEED = 100
var speed = BASE_SPEED

enum State{ACTIVE, INACTIVE}
var state: State = State.ACTIVE

enum Secondary_weapon{NONE, CHARGED_SHOT, ROCKET}
var secondary_weapon = Secondary_weapon.NONE

@export var fire_position: Node2D
@export var ship_cannon: Sprite2D
@export var ship_body: AnimatedSprite2D
var sprites: Array = [ship_cannon, ship_body]
@export var hurt_box: CollisionShape2D
@onready var health_component: HealthComponent = %HealthComponent
@onready var engine_particles: CPUParticles2D = %EngineParticles

@onready var blaster_sound: AudioStream = load("res://resources/audio/blaster4.wav")
@onready var blaster_big_sound: AudioStream = load("res://resources/audio/blaster_big.wav")
@onready var blaster_charge_sound: AudioStream = load("res://resources/audio/blaster_charge2.wav")
@export var explosion_effect: PackedScene

var mission_manager: Mission_manager

var speed_level = 0

#Blaster Variables:
var blaster_ready: bool = true
var blaster_cooldown: float = 0
var blaster_damage_level = 0
var blaster_charge_level = 0
var blaster_charge_timer: float = 0.75
var blaster_max_charge = 3
var blaster_current_charge = 0
var blaster_charging: bool = false
var blaster_charged: bool = false

#Rocket Variables:
var rocket_ready: bool = true
var rocket_cooldown: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	health_component.hurt.connect(player_hurt)
	health_component.died.connect(player_died)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		State.ACTIVE:
			var movement_vector = Vector2.ZERO
			if App.active_input == App.input_device.KEYBOARD:
				var look_direction = get_global_mouse_position()
				ship_cannon.look_at(look_direction)
				
				var rotate_adjust = deg_to_rad(90)
				ship_cannon.rotation += rotate_adjust
				
				movement_vector = get_movement_vector()
				
			if App.active_input == App.input_device.CONTROLLER:
				var look_direction = get_controller_look()
				if look_direction != Vector2.ZERO:
					ship_cannon.look_at(global_position + look_direction)
					
					var rotate_adjust = deg_to_rad(90)
					ship_cannon.rotation += rotate_adjust
					
				movement_vector = controller_movement()
					
					
			animate_player(movement_vector)	
			var direction = movement_vector.normalized()
			var target_velocity = direction * speed
			
			velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
			move_and_slide()
			
			constrain_player()

			if Input.is_action_just_pressed("escape"):
				App.screen_manager.show_pause()
						
			if Input.is_action_pressed("primary_fire"):
				if blaster_ready and !Input.is_action_pressed("secondary_fire"): 
					blaster_ready = false
					fire_blaster()
					
			if Input.is_action_pressed("secondary_fire"):
				match secondary_weapon:
					Secondary_weapon.CHARGED_SHOT:
						blaster_charging = true	
						if blaster_current_charge < blaster_charge_level:
							if blaster_charge_timer > 0:
								blaster_charge_timer -= delta
							else:
								charge_blaster()
								blaster_charge_timer = 1.5
							
					Secondary_weapon.ROCKET:
						fire_rocket()
							
			if Input.is_action_just_released("secondary_fire"):
				match secondary_weapon:
					Secondary_weapon.CHARGED_SHOT:
						release_charged_blaster()
						
			if !Input.is_action_pressed("secondary_fire") and secondary_weapon == Secondary_weapon.CHARGED_SHOT and blaster_charging:
				release_charged_blaster()
			

func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)


func controller_movement():
	var x_move = Input.get_axis("move_left", "move_right")
	var y_move = Input.get_axis("move_up", "move_down")
	return Vector2(x_move, y_move)


func get_controller_look():
	var x_look = -Input.get_action_strength("look_left") + Input.get_action_strength("look_right")
	var y_look = +Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	return Vector2(x_look, y_look)


func charge_blaster():
	match blaster_current_charge:
		0:
			ship_body.stop()
			ship_body.play("blaster_charge_1")
			SoundManager.play_sound_with_pitch(blaster_charge_sound, 0.8)
			blaster_current_charge += 1
		1:
			ship_body.stop()
			ship_body.play("blaster_charge_2")
			blaster_current_charge += 1
			SoundManager.stop_sound(blaster_charge_sound)
			SoundManager.play_sound_with_pitch(blaster_charge_sound, 1)
		2:
			ship_body.stop()
			ship_body.play("blaster_charge_3")
			SoundManager.stop_sound(blaster_charge_sound)
			SoundManager.play_sound_with_pitch(blaster_charge_sound, 1.2)
			blaster_current_charge += 1


func release_charged_blaster():
	if blaster_charging:
		blaster_ready = false
		blaster_charging = false
		blaster_charge_timer = 0.75
		if blaster_current_charge > 0:
			SoundManager.stop_sound(blaster_charge_sound)
			fire_charged_blaster(blaster_current_charge)
			blaster_current_charge = 0
			

func fire_blaster():
	var pitch = randf_range(0.8, 1.2)
	SoundManager.play_sound_with_pitch(blaster_sound, pitch)
	App.spawn_manager.spawn_blaster_bolt(fire_position.global_position, ship_cannon.global_rotation, 1 + blaster_damage_level, 0)
	ship_body.stop()
	ship_body.play("player_fire")
	await get_tree().create_timer(0.8 - blaster_cooldown).timeout
	blaster_ready = true
	
	
func fire_charged_blaster(charge_level):
	SoundManager.play_sound_with_pitch(blaster_big_sound, 1)
	App.spawn_manager.spawn_blaster_bolt(fire_position.global_position, ship_cannon.global_rotation, 1 + blaster_damage_level, charge_level)
	ship_body.stop()
	ship_body.play("player_fire")
	await get_tree().create_timer(1).timeout
	blaster_ready = true


func fire_rocket():
	if rocket_ready:
		rocket_ready = false
		SoundManager.play_ambient_sound(blaster_sound)
		App.spawn_manager.spawn_rocket(fire_position.global_position, ship_cannon.global_rotation)
		ship_body.stop()
		ship_body.play("player_fire")
		await get_tree().create_timer(1 - rocket_cooldown).timeout
		rocket_ready = true


func constrain_player():
	if global_position.x < App.play_area_x_min + 30: global_position.x = App.play_area_x_min + 30
	if global_position.x > App.play_area_x_max - 30: global_position.x = App.play_area_x_max - 30
	if global_position.y < App.play_area_y_min + 30: global_position.y = App.play_area_y_min + 30
	if global_position.y > App.play_area_y_max - 30: global_position.y = App.play_area_y_max - 30


func animate_player(direction: Vector2):
	if ship_body.is_playing():
		if ship_body.animation == "player_fire" or ship_body.animation == "blaster_charge_1" or ship_body.animation == "blaster_charge_2" or ship_body.animation == "blaster_charge_3":
			return	

	if (direction.x > 0):
		if (direction.y == 0):
			ship_body.play("player_move_h&v")
			ship_body.rotation = deg_to_rad(-90)
			
		if (direction.y > 0):
			ship_body.play("player_move_d")
			ship_body.rotation = deg_to_rad(-90)
			
		if (direction.y < 0):
			ship_body.play("player_move_d")
			ship_body.rotation = deg_to_rad(180)
			
	if (direction.x < 0):
		if (direction.y == 0):
			ship_body.play("player_move_h&v")
			ship_body.rotation = deg_to_rad(90)
			
		if (direction.y > 0):
			ship_body.play("player_move_d")
			ship_body.rotation = deg_to_rad(0)
			
		if (direction.y < 0):
			ship_body.play("player_move_d")
			ship_body.rotation = deg_to_rad(90)
			
	if (direction.x == 0):
		if(direction.y > 0):
			ship_body.play("player_move_h&v")
			ship_body.rotation = deg_to_rad(0)
			
		if(direction.y < 0):
			ship_body.play("player_move_h&v")
			ship_body.rotation = deg_to_rad(180)
			
		if(direction.y == 0):
			ship_body.play("player_idle")
			ship_body.rotation = deg_to_rad(0)
			
			
func toggle_status():
	if state == State.ACTIVE:
		state = State.INACTIVE
	else: state = State.ACTIVE
	
	
func get_health():
	return health_component.current_health/health_component.max_health


func heal(heal_amt):
	health_component.heal(heal_amt)
	
	
func player_hurt(_damage):
	SoundManager.play_ambient_sound(App.player_hurt_sound)
	var tween = get_tree().create_tween()
	
	tween.tween_property(ship_body, "scale", Vector2(1.25, 1.25), 0.1)
	tween.parallel().tween_property(ship_cannon, "scale", Vector2(1.25, 1.25), 0.1)
	tween.parallel().tween_property(ship_body, "modulate", Color(100, 100, 100, 100), 0.1)
	tween.parallel().tween_property(ship_cannon, "modulate", Color(100, 100, 100, 100), 0.1)
	
	tween.tween_property(ship_body, "scale", Vector2(1, 1), 0.1)
	tween.parallel().tween_property(ship_cannon, "scale", Vector2(1, 1), 0.1)
	tween.parallel().tween_property(ship_body, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.parallel().tween_property(ship_cannon, "modulate", Color(1, 1, 1, 1), 0.1)
	
	
func player_died(_max_health):
	state = State.INACTIVE
	#engine_particles.queue_free()
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(ship_body, "modulate", Color(100, 100, 100, 100), 0.25)
	tween.parallel().tween_property(ship_cannon, "modulate", Color(100, 100, 100, 100), 0.25)
	tween.parallel().tween_property(ship_body, "scale", Vector2(1.25, 1.25), 0.25)
	tween.tween_property(ship_cannon, "scale", Vector2(1.25, 1.25), 0.25)
	tween.parallel().tween_property(ship_body, "scale", Vector2(0, 0), 0.25)
	tween.parallel().tween_property(ship_cannon, "scale", Vector2(0, 0), 0.25)
	tween.parallel().tween_property(ship_body, "modulate:a", 0, 0.25)
	tween.parallel().tween_property(ship_cannon, "modulate:a", 0, 0.25)
	tween.parallel().tween_callback(play_explosion_effect).set_delay(0.1)
	
	
func play_explosion_effect():
	App.camera.add_trauma(0.5)
	SoundManager.play_ambient_sound(App.asteroid_burst_sound)
	var effect = explosion_effect.instantiate() as CPUParticles2D
	add_child(effect)
	effect.global_position = global_position
	effect.scale_amount_max = 3
	effect.restart()
	await effect.finished
	queue_free()
	
	
func update_abilities(upgrade: Player_upgrade, current_abilities: Dictionary):
	match upgrade.id:
		"fire_rate":
			blaster_cooldown = (current_abilities["fire_rate"]["quantity"] * .1)
		"fire_damage":
			blaster_damage_level = current_abilities["fire_damage"]["quantity"]
		"speed_upgrade":
			speed_level = current_abilities["speed_upgrade"]["quantity"]
			speed = BASE_SPEED + (speed_level * 20)
		"blaster_charge_level":
			blaster_charge_level = current_abilities["blaster_charge_level"]["quantity"]
			secondary_weapon = Secondary_weapon.CHARGED_SHOT
		_:
			return
