extends CharacterBody2D
class_name Asteroid

@export var asteroid_sprite: Sprite2D

var asteroid_rotation
var asteroid_speed
var asteroid_direction

var x_movement
var y_movement

var has_hit:bool = false
var was_hit:bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	asteroid_rotation = randf_range(-0.025, 0.025)
	asteroid_speed = randf_range(50, 100)
	asteroid_direction = set_movement_vector()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	asteroid_sprite.rotation += asteroid_rotation
	velocity = asteroid_direction * asteroid_speed
	move_and_slide()
	
	if global_position.x > 5000 or global_position.x < -2000:
		queue_free()
		

func _physics_process(_delta):
	queue_redraw()
	
	var raycast_left_direction = asteroid_direction.rotated(-0.8)
	var raycast_right_direction = asteroid_direction.rotated(0.8)
	
	fire_raycast(raycast_left_direction)
	fire_raycast(asteroid_direction)
	fire_raycast(raycast_right_direction)
		
		
func fire_raycast(direction: Vector2):
	var space_state = get_world_2d().direct_space_state
	var raycast = PhysicsRayQueryParameters2D.create(global_position, global_position + (direction * 15))
	raycast.exclude = [self]
	
	var raycast_output = space_state.intersect_ray(raycast)
	
	if !raycast_output.is_empty():
		has_hit = true
		var collision_normal: Vector2 = raycast_output.normal
		var new_direction = direction.reflect(collision_normal).normalized()
		
		if raycast_output.collider is Asteroid:
			raycast_output.collider.asteroid_direction = asteroid_direction.normalized() * 0.8
			raycast_output.collider.asteroid_speed = asteroid_speed * 0.8
			raycast_output.collider.collision_cooldown()
			raycast_output.collider.was_hit = true
			
		asteroid_direction = new_direction
		collision_cooldown()
		

func collision_cooldown():
	set_physics_process(false)
	await get_tree().create_timer(1).timeout
	set_physics_process(true)
	has_hit = false
	was_hit = false
	
	
#func _draw():
#	var look_left = asteroid_direction.rotated(-0.75)
#	var look_right = asteroid_direction.rotated(0.75)
		
#	draw_line(Vector2.ZERO, (Vector2.ZERO + asteroid_direction) * 20, Color.GREEN if !has_hit else Color.RED)
#	draw_line(Vector2.ZERO, look_left * 20, Color.GREEN if !has_hit else Color.RED)
#	draw_line(Vector2.ZERO, look_right * 20, Color.GREEN if !has_hit else Color.RED)

		

func set_movement_vector():
	x_movement = randf_range(1, 5)
	y_movement = randf_range(-1, 1)
	
	return Vector2(x_movement, y_movement).normalized()
	
	
func on_area_entered(other_area):
	print("trigger")
	if other_area is Blaster_bolt:
		var push_direction = other_area.global_position.direction_to
		asteroid_direction = push_direction
