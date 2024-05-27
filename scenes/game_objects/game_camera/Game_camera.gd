extends Camera2D

@export var player: CharacterBody2D

var target_position = Vector2.ZERO

enum Camera_behavior {STATIONARY, FOLLOW}

@export var behavior: Camera_behavior = Camera_behavior.STATIONARY

@export var decay = 0.8  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
@export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = Vector2(App.play_area_x_max / 2, App.play_area_y_max / 2)
	make_current();
	App.camera = self
	
func add_trauma(amount):
	trauma = min(trauma + (amount * 1.7), 1.0)
	
func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1.0, 1.0)
	offset.x = max_offset.x * amount * randf_range(-1.0, 1.0)
	offset.y = max_offset.y * amount * randf_range(-1.0, 1.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
		
	match behavior:
		Camera_behavior.STATIONARY:
			return
		Camera_behavior.FOLLOW:
			acquire_target()
			global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 20))
	

func acquire_target():
	if player != null:
		target_position = player.global_position
