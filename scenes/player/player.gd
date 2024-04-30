extends CharacterBody2D

const MAX_SPEED = 150
const ACCELERATION_SMOOTHING = 25

@export var blaster_bolt_scene: PackedScene
@export var fire_position: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	var target_velocity = direction * MAX_SPEED
	
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()

	var look_direction = get_global_mouse_position()	
	look_at(look_direction)
	
	var rotate_adjust = deg_to_rad(90)
	rotation += rotate_adjust
	
	if Input.is_action_just_pressed("input_fire"):
		var blaster_bolt_instance = blaster_bolt_scene.instantiate() as Node2D
		get_parent().add_child(blaster_bolt_instance)
		blaster_bolt_instance.global_position = fire_position.global_position
		blaster_bolt_instance.global_rotation = global_rotation

func get_movement_vector():
		
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	return Vector2(x_movement, y_movement)
