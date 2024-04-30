extends CharacterBody2D

@export var asteroid_sprite: Sprite2D

var asteroid_rotation
var asteroid_speed
var asteroid_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	asteroid_rotation = randf_range(-0.025, 0.025)
	asteroid_speed = randf_range(50, 100)
	asteroid_direction = set_movement_vector()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	asteroid_sprite.rotation += asteroid_rotation
	velocity = asteroid_direction.normalized() * asteroid_speed
	move_and_slide()


func set_movement_vector():
		
	var x_movement = randf_range(1, 5)
	var y_movement = randf_range(-1, 1)
	
	return Vector2(x_movement, y_movement)
