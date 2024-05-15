extends Enemy
class_name Asteroid

@onready var enemy_manager: Enemy_manager
@export var command_empty: Resource

@export var asteroid_textures: Array[Texture]
@export var asteroid_colliders: Array[CollisionShape2D]

@export var explosion_effect: PackedScene
@export var impact_effect: PackedScene

enum Asteroid_size{SMALL, MEDIUM, LARGE}
@export var size: Asteroid_size = Asteroid_size.SMALL

var asteroid_rotation
var asteroid_speed: float = 0
var asteroid_direction: = Vector2.ZERO

var x_movement
var y_movement

var has_hit:bool = false
var was_hit:bool = false

var size_multiplier: float = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_sprite = %Asteroid_sprite
	#health_component = %HealthComponent
	health_component.died.connect(death_sequence)
	health_component.hurt.connect(damage_sequence)
	
	asteroid_rotation = randf_range(-0.01, 0.01) #randf_range(-0.025, 0.025)
	if asteroid_direction == Vector2.ZERO: asteroid_direction = set_movement_vector()
	
	enemy_sprite.texture = asteroid_textures.pick_random()
	
	match size:
		Asteroid_size.SMALL:
			pass
		Asteroid_size.MEDIUM:
			size_multiplier = 2
		Asteroid_size.LARGE:
			size_multiplier = 3

	if asteroid_speed == 0: asteroid_speed = 150 / (size_multiplier / 2) #randf_range(100, 150)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	enemy_sprite.rotation += asteroid_rotation
	velocity = asteroid_direction * asteroid_speed
	move_and_slide()
	
	if global_position.x > 1300 or (asteroid_direction.x < 0 and global_position.x < -20):
		queue_free()
		

func _physics_process(_delta):
	queue_redraw()
	
	var raycast_left_directionA = asteroid_direction.rotated(-1)
	var raycast_left_directionB = asteroid_direction.rotated(-0.6)
	var raycast_right_directionA = asteroid_direction.rotated(0.6)
	var raycast_right_directionB = asteroid_direction.rotated(1)
	
	fire_raycast(raycast_left_directionA)
	fire_raycast(raycast_left_directionB)
	fire_raycast(asteroid_direction)
	fire_raycast(raycast_right_directionA)
	fire_raycast(raycast_right_directionB)
		
		
func fire_raycast(direction: Vector2):
	var space_state = get_world_2d().direct_space_state
	var raycast = PhysicsRayQueryParameters2D.create(global_position, global_position + (direction * (15 * size_multiplier)))
	raycast.exclude = [self]
	
	var raycast_output = space_state.intersect_ray(raycast)
	
	if !raycast_output.is_empty():
		has_hit = true
		var collision_normal: Vector2 = raycast_output.normal
		var new_direction = collision_normal
		var new_speed = asteroid_speed * (0.3 * size_multiplier)
		
		asteroid_impact_effect(raycast_output.position)
		
		if raycast_output.collider is Asteroid and !raycast_output.collider is Blaster_bolt:
			var new_rotation = raycast_output.collider.asteroid_rotation * 0.8
			raycast_output.collider.asteroid_rotation = asteroid_rotation * 0.8
			new_speed = raycast_output.collider.asteroid_speed * (0.3 * size_multiplier)
			raycast_output.collider.asteroid_direction = direction.normalized()
			if asteroid_speed > 25: raycast_output.collider.asteroid_speed = asteroid_speed * (0.3 * size_multiplier)
			raycast_output.collider.collision_cooldown()
			raycast_output.collider.was_hit = true
			
			asteroid_rotation = new_rotation
		
		if new_speed > 5: asteroid_speed = new_speed
		asteroid_direction = new_direction
		collision_cooldown()
		

func collision_cooldown():
	set_physics_process(false)
	await get_tree().create_timer(0.25).timeout
	set_physics_process(true)
	has_hit = false
	was_hit = false
	
	
func respond_to_bolt_collision(bolt_direction, collision_point):	
	var asteroid_angle = asteroid_direction.angle()
	var diff_angle = asteroid_angle - bolt_direction.angle()
			
	#if the bolt hits an asteroid traveling toward it:
	if diff_angle < -2.75 or diff_angle > 2.75: 
		if asteroid_speed < 5:
			asteroid_direction = bolt_direction.normalized()
			asteroid_speed *= 1.5
		else:
			asteroid_speed *= 0.3 * size_multiplier
					
	#if the bolt hits an asteroid traveling away from it:
	if diff_angle > -0.5 and diff_angle < 0.5: 
			asteroid_speed *= 1.25
			
	#if the bolt hits an asteroid travelling at a diagonal from it:
	if (diff_angle < 2.75 and diff_angle > 0.5) or (diff_angle > -2.75 and diff_angle <  -0.5): 
			asteroid_direction = bolt_direction.normalized()
			asteroid_speed *= 0.5
			
	asteroid_impact_effect(collision_point)
	
	
func asteroid_impact_effect(location):
	var effect = impact_effect.instantiate() as GPUParticles2D
	add_child(effect)
	effect.global_position = location
	effect.restart()
	await effect.finished
	effect.queue_free()
	
	
func asteroid_explosion_effect():
	var effect = explosion_effect.instantiate() as CPUParticles2D
	add_child(effect)
	effect.global_position = global_position
	effect.scale_amount_max = size_multiplier + 1
	effect.restart()
	await effect.finished
	queue_free()
	
	
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
	
	
func death_sequence():
	for collider in asteroid_colliders:
		collider.set_deferred("disabled", true)
		
	set_physics_process(false)
	
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(enemy_sprite, "modulate", Color(100, 100, 100, 100), 0.25)
	tween.tween_property(enemy_sprite, "scale", Vector2(1.25, 1.25), 0.25)
	tween.parallel().tween_property(enemy_sprite, "scale", Vector2(0, 0), 0.25)
	tween.parallel().tween_property(enemy_sprite, "modulate:a", 0, 0.25)
	tween.parallel().tween_callback(asteroid_explosion_effect).set_delay(0.1)
	tween.parallel().tween_callback(create_spawn_command).set_delay(0.11)

	
func damage_sequence(_health):
	var tween = get_tree().create_tween()
	
	tween.tween_property(enemy_sprite, "scale", Vector2(1.25, 1.25), 0.1)
	tween.parallel().tween_property(enemy_sprite, "modulate", Color(100, 100, 100, 100), 0.1)
	
	tween.tween_property(enemy_sprite, "scale", Vector2(1, 1), 0.1)
	tween.parallel().tween_property(enemy_sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	pass
	
	
func create_spawn_command():
	if size == Asteroid_size.SMALL: return
	
	var command = command_empty.duplicate() as Spawn_command
	command.spawn_positioning = Spawn_command.Spawn_positioning.ASTEROID_BURST
	command.spawn_location = global_position
	var enemyType: Enemy_manager.Enemy_type = Enemy_manager.Enemy_type.ASTEROID_SMALL
	match size:
		Asteroid_size.MEDIUM:
			command.possible_enemies.append(enemyType)
		Asteroid_size.LARGE:
			command.possible_enemies.append(enemyType)
			enemyType = Enemy_manager.Enemy_type.ASTEROID_MEDIUM
			command.possible_enemies.append(Enemy_manager.Enemy_type.ASTEROID_MEDIUM)
	enemy_manager.add_command(command)
