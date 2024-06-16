class_name Rocket extends CharacterBody2D

const MAX_SPEED = 500
const ACCELERATION_SMOOTHING = 25

@onready var timer = $Timer
@export var hit_box: Area2D

var direction = Vector2.ZERO
var default_damage = 1

@onready var hitbox = %HitboxComponent as HitboxComponent

@onready var blaster_collision_sound: AudioStream = load("res://resources/audio/blaster_impact.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	#hitbox.damage = default_damage + App.player.damage_level
	hitbox.hit.connect(rocket_hit)
	#var scale_factor = default_damage + (hitbox.damage * .2)
	#scale = Vector2(scale_factor, scale_factor)
	
	
func rocket_hit():
	SoundManager.play_ambient_sound(blaster_collision_sound)
	App.spawn_manager.spawn_expolsion(global_position)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_velocity = transform.y * MAX_SPEED
	velocity = velocity.lerp(-target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))
	move_and_slide()
	direction = velocity
	
	if timer.time_left == 0:
		queue_free()


func _physics_process(_delta):
	#queue_redraw()
	#fire_raycast(direction)
	pass


#func _draw():
	#draw_line(Vector2.ZERO, (Vector2.ZERO + direction) * 20, Color.GREEN)
	#pass


func fire_raycast(raycast_direction: Vector2):
	var space_state = get_world_2d().direct_space_state
	var raycast = PhysicsRayQueryParameters2D.create(global_position, global_position + (raycast_direction /30))
	raycast.exclude = [self]
	
	var raycast_output = space_state.intersect_ray(raycast)
	
	if !raycast_output.is_empty():
					
		App.spawn_manager.spawn_expolsion(global_position)
			
		collision_cooldown()
		

func collision_cooldown():
	set_physics_process(false)
	await get_tree().create_timer(1).timeout
	set_physics_process(true)
	
	
func set_movement_vector():
	var x_movement = 0
	var y_movement = 1
	
	return Vector2(x_movement, y_movement).normalized()
