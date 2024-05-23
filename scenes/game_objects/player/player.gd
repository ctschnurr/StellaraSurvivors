class_name Player extends CharacterBody2D

const ACCELERATION_SMOOTHING = 5
const BASE_SPEED = 100
var speed = BASE_SPEED

enum State{ACTIVE, INACTIVE}

var state: State = State.ACTIVE

@export var fire_position: Node2D
@export var ship_cannon: Sprite2D
@export var ship_body: AnimatedSprite2D
var sprites: Array = [ship_cannon, ship_body]
@export var hurt_box: CollisionShape2D
@onready var health_component: HealthComponent = %HealthComponent
@onready var engine_particles: CPUParticles2D = %EngineParticles

@onready var blaster_sound: AudioStream = load("res://resources/audio/blaster.wav")
@export var explosion_effect: PackedScene

var mission_manager: Mission_manager

var gun_ready: bool = true
var fire_rate_base = 0
var gun_cooldown: float = fire_rate_base
var damage_level = 0
var speed_level = 0

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
					
					fire_blaster()
					
				movement_vector = controller_movement()
					
					
			animate_player(movement_vector)	
			var direction = movement_vector.normalized()
			var target_velocity = direction * speed
			
			velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
			move_and_slide()
			
			constrain_player()

			if Input.is_action_just_pressed("escape"):
				App.screen_manager.show_pause()
			
			if Input.is_action_pressed("input_fire"):
				fire_blaster()
				

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


func fire_blaster():
	if gun_ready:
		gun_ready = false
		SoundManager.play_sound(blaster_sound)
		App.enemy_manager.spawn_blaster_bolt(fire_position.global_position, ship_cannon.global_rotation)
		ship_body.stop()
		ship_body.play("player_fire")
		await get_tree().create_timer(0.8 - gun_cooldown).timeout
		gun_ready = true


func constrain_player():
	if global_position.x > 1250: global_position.x = 1250
	if global_position.x < 30: global_position.x = 30
	if global_position.y > 690: global_position.y = 690
	if global_position.y < 30: global_position.y = 30


func animate_player(direction: Vector2):
	if ship_body.animation == "player_fire" and ship_body.is_playing(): return
	
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
	return health_component.current_health
	
	
func player_hurt(_damage):
	SoundManager.play_sound(App.player_hurt_sound)
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
	engine_particles.queue_free()
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
	SoundManager.play_sound(App.asteroid_burst_sound)
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
			gun_cooldown = (current_abilities["fire_rate"]["quantity"] * .1)
		"fire_damage":
			damage_level = current_abilities["fire_damage"]["quantity"]
		"speed_upgrade":
			speed_level = current_abilities["speed_upgrade"]["quantity"]
			speed = BASE_SPEED + (speed_level * 20)
		_:
			return
