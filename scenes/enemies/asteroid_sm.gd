class_name Asteroid_sm extends Enemy

@export var small_textures: Array[Texture]

var asteroid_rotation
var asteroid_speed
var asteroid_direction

var x_movement
var y_movement

var has_hit:bool = false
var was_hit:bool = false

var size_mult = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_sprite = %Asteroid_sprite
	health_component = %HealthComponent
	
	asteroid_rotation = randf_range(-0.025, 0.025)
	asteroid_speed = randf_range(100, 150)
	asteroid_direction = set_movement_vector()
	
	enemy_sprite.texture = small_textures.pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	enemy_sprite.rotation += asteroid_rotation
	velocity = asteroid_direction * asteroid_speed
	move_and_slide()
	
	if global_position.x > 1300 or (asteroid_direction.x < 0 and global_position.x < -20):
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
		var new_direction = collision_normal
		var new_speed = asteroid_speed * 0.5
		
		if raycast_output.collider is Asteroid_sm and !raycast_output.collider is Blaster_bolt:
			new_speed = raycast_output.collider.asteroid_speed * 0.75
			raycast_output.collider.asteroid_direction = direction.normalized()
			if asteroid_speed > 25: raycast_output.collider.asteroid_speed = asteroid_speed * 0.75
			raycast_output.collider.collision_cooldown()
			raycast_output.collider.was_hit = true
		
		if new_speed > 25: asteroid_speed = new_speed
		asteroid_direction = new_direction
		collision_cooldown()
		

func collision_cooldown():
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	set_physics_process(true)
	has_hit = false
	was_hit = false
	
	
func respond_to_bolt_collision(bolt_direction):
	var asteroid_angle = asteroid_direction.angle()
	var diff_angle = asteroid_angle - bolt_direction.angle()
			
	#if the bolt hits an asteroid traveling toward it:
	if diff_angle < -2.75 or diff_angle > 2.75: 
		if asteroid_speed < 5:
			asteroid_direction = bolt_direction.normalized()
			asteroid_speed *= 1.5
		else:
			asteroid_speed *= 0.5
					
	#if the bolt hits an asteroid traveling away from it:
	if diff_angle > -0.5 and diff_angle < 0.5: 
			asteroid_speed *= 1.25
			
	#if the bolt hits an asteroid travelling at a diagonal from it:
	if (diff_angle < 2.75 and diff_angle > 0.5) or (diff_angle > -2.75 and diff_angle <  -0.5): 
			asteroid_direction = bolt_direction.normalized()
			asteroid_speed *= 0.5
	
	
	
#func _draw():
#	var look_left = asteroid_direction.rotated(-0.75)
#	var look_right = asteroid_direction.rotated(0.75)
#	
#	draw_line(Vector2.ZERO, (Vector2.ZERO + asteroid_direction) * 20, Color.GREEN if !has_hit else Color.RED)
#	draw_line(Vector2.ZERO, look_left * 20, Color.GREEN if !has_hit else Color.RED)
#	draw_line(Vector2.ZERO, look_right * 20, Color.GREEN if !has_hit else Color.RED)

		

func set_movement_vector():
	x_movement = randf_range(1, 5)
	y_movement = randf_range(-0.005, 0.005)
	
	return Vector2(x_movement, y_movement).normalized()
