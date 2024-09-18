class_name Player extends CharacterBody2D

const ACCELERATION_SMOOTHING = 5

enum State{ACTIVE, INACTIVE}
var state: State = State.ACTIVE

@export var fire_position: Node2D
@export var ship_cannon: Sprite2D
@export var ship_body: AnimatedSprite2D
var sprites: Array = [ship_cannon, ship_body]
@export var hurt_box: CollisionShape2D
@onready var health_component: HealthComponent = %HealthComponent
@onready var engine_particles: CPUParticles2D = %EngineParticles
@onready var ability_system: Ability_System = %ability_system

var mission_manager: Mission_manager

# Called when the node enters the scene tree for the first time.
func _ready():
	health_component.hurt.connect(player_hurt)
	health_component.died.connect(player_died)
	ability_system.player = self

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
			var target_velocity = direction * ability_system.player_speed
			
			velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
			move_and_slide()
			
			constrain_player()

			if Input.is_action_just_pressed("escape"):
				App.screen_manager.show_pause()
			

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


func constrain_player():
	if global_position.x < App.play_area_x_min + 30: global_position.x = App.play_area_x_min + 30
	if global_position.x > App.play_area_x_max - 30: global_position.x = App.play_area_x_max - 30
	if global_position.y < App.play_area_y_min + 30: global_position.y = App.play_area_y_min + 30
	if global_position.y > App.play_area_y_max - 30: global_position.y = App.play_area_y_max - 30


func animate_player(direction: Vector2):
	if ship_body.is_playing():
		if ship_body.animation == "player_fire" or ship_body.animation == "blaster_charging_A" or ship_body.animation == "blaster_charging_B" or ship_body.animation == "blaster_charging_C" or ship_body.animation == "blaster_charged":
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
	tween.parallel().tween_callback(trigger_explosion).set_delay(0.1)
	
	
func trigger_explosion():
	App.camera.add_trauma(0.5)
	App.spawn_manager.spawn_expolsion(global_position, 5)
	queue_free()
	
	
func update_abilities(upgrade: Player_upgrade, current_abilities: Dictionary):
	ability_system.update_ability(upgrade, current_abilities)
