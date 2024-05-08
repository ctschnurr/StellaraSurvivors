extends CharacterBody2D
class_name Blaster_bolt

const MAX_SPEED = 500
const ACCELERATION_SMOOTHING = 25

@onready var timer = $Timer
@export var hit_box: Area2D

var start_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_velocity = transform.y * MAX_SPEED
	
	velocity = velocity.lerp(-target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()
	
	if timer.time_left == 0:
		queue_free()

