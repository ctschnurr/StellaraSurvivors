extends CharacterBody2D

const MAX_SPEED = 200
const ACCELERATION_SMOOTHING = 5

@export var blaster_bolt_scene: PackedScene
@export var fire_position: Node2D
@export var ship_cannon: Sprite2D
@export var ship_body: AnimatedSprite2D
@export var hurt_box: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement_vector = get_movement_vector()
	animate_player(movement_vector)	
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED
	
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()
	
	constrain_player()

	var look_direction = get_global_mouse_position()	
	ship_cannon.look_at(look_direction)
	
	var rotate_adjust = deg_to_rad(90)
	ship_cannon.rotation += rotate_adjust
	
	if Input.is_action_just_pressed("input_fire"):
		var blaster_bolt_instance = blaster_bolt_scene.instantiate() as Node2D
		get_parent().add_child(blaster_bolt_instance)
		blaster_bolt_instance.global_position = fire_position.global_position
		blaster_bolt_instance.global_rotation = ship_cannon.global_rotation
		ship_body.stop()
		ship_body.play("player_fire")
		
		

func get_movement_vector():
		
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)


func constrain_player():
	if global_position.x > 600: global_position.x = 600
	if global_position.x < -600: global_position.x = -600
	if global_position.y > 320: global_position.y = 320
	if global_position.y < -320: global_position.y = -320

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
