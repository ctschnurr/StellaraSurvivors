class_name Rocket extends CharacterBody2D

const MAX_SPEED = 500
const ACCELERATION_SMOOTHING = 25

@onready var timer = $Timer

var direction = Vector2.ZERO
var base_damage = 1
var rocket_damage_level

@onready var blaster_collision_sound: AudioStream = load("res://resources/audio/blaster_impact.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	rocket_damage_level += base_damage	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_velocity = transform.y * MAX_SPEED
	velocity = velocity.lerp(-target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()
	direction = velocity
	
	if timer.time_left == 0:
		queue_free()


func _physics_process(_delta):	
	fire_raycast(direction)


func fire_raycast(raycast_direction: Vector2):
	var space_state = get_world_2d().direct_space_state
	var raycast = PhysicsRayQueryParameters2D.create(global_position, global_position + (raycast_direction / 35))
	raycast.exclude = [self]
	
	var raycast_output = space_state.intersect_ray(raycast)
	
	if !raycast_output.is_empty() and raycast_output.collider is Destructable_object:
		
		set_physics_process(false)
		App.spawn_manager.spawn_expolsion(global_position, rocket_damage_level)
		queue_free()

	
func set_movement_vector():
	var x_movement = 0
	var y_movement = 1
	
	return Vector2(x_movement, y_movement).normalized()
