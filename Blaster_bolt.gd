extends CharacterBody2D

const MAX_SPEED = 500
const ACCELERATION_SMOOTHING = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_velocity = transform.y * MAX_SPEED
	
	velocity = velocity.lerp(-target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()
