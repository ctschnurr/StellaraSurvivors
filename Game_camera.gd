extends Camera2D

@export var player: CharacterBody2D

var target_position = Vector2.ZERO

enum Camera_behavior {STATIONARY, FOLLOW}

@export var behavior: Camera_behavior = Camera_behavior.STATIONARY

# Called when the node enters the scene tree for the first time.
func _ready():
	make_current();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match behavior:
		Camera_behavior.STATIONARY:
			return
		Camera_behavior.FOLLOW:
			acquire_target()
			global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 20))
	

func acquire_target():
	if player != null:
		target_position = player.global_position
