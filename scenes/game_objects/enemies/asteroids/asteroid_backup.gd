extends Enemy
class_name Asteroid_backup

@onready var enemy_manager: Enemy_manager
@export var asteroid_cluster_command: Resource

@export var asteroid_textures: Array[Texture]
@export var asteroid_colliders: Array[CollisionShape2D]

@export var explosion_effect: PackedScene
@export var impact_effect: PackedScene
@export var screen_shake_amount:float = 0.5
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

var has_entered_play_area: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_sprite = %Asteroid_sprite
	#health_component = %HealthComponent
	health_component.died.connect(death_sequence)
	health_component.hurt.connect(damage_sequence)
	
	asteroid_rotation = randf_range(-0.025, 0.025) #randf_range(-0.025, 0.025)
	if asteroid_direction == Vector2.ZERO: 
		if randf_range(1, 5) > 3:
			if App.player != null: asteroid_direction = asteroid_direction.direction_to(App.player.global_position)
		else: asteroid_direction = set_movement_vector()
	
	enemy_sprite.texture = asteroid_textures.pick_random()
	
	match size:
		Asteroid_size.SMALL:
			pass
		Asteroid_size.MEDIUM:
			size_multiplier = 2
		Asteroid_size.LARGE:
			size_multiplier = 3

	if asteroid_speed == 0: asteroid_speed = randf_range(75, 100)
	
	await get_tree().create_timer(15).timeout
	if !has_entered_play_area: 
		queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	enemy_sprite.rotation += asteroid_rotation
	velocity = asteroid_direction * asteroid_speed
	move_and_slide()
	
	if global_position.x > App.play_area_x_min and global_position.x < App.play_area_x_max and global_position.y > App.play_area_y_min and global_position.y < App.play_area_y_max: 
		has_entered_play_area = true
	
	if !has_entered_play_area:
		if App.player != null: asteroid_direction = global_position.direction_to(App.player.global_position)
	else:
		if global_position.x < App.play_area_x_min or global_position.x > App.play_area_x_max or global_position.y < App.play_area_y_min and global_position.y > App.play_area_y_max: 
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
	raycast.collision_mask = 1
	
	var raycast_output = space_state.intersect_ray(raycast)
	
	if !raycast_output.is_empty():
		has_hit = true
		if has_entered_play_area: 
			SoundManager.play_sound(App.asteroid_collision_sound)
		var collision_normal: Vector2 = raycast_output.normal
		var new_direction = collision_normal
		var new_speed = asteroid_speed * 0.8 #(0.3 * size_multiplier)
		
		asteroid_impact_effect(raycast_output.position)
		
		if raycast_output.collider is Asteroid and !raycast_output.collider is Blaster_bolt:
			var new_rotation = raycast_output.collider.asteroid_rotation * 0.8
			raycast_output.collider.asteroid_rotation = asteroid_rotation * 0.8
			new_speed = raycast_output.collider.asteroid_speed * 0.8 #(0.3 * size_multiplier)
			raycast_output.collider.asteroid_direction = direction.normalized()
			if asteroid_speed > 25: raycast_output.collider.asteroid_speed = asteroid_speed * 0.8 #(0.3 * size_multiplier)
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
	
	
func respond_to_bolt_collision(bolt_direction, collision_point, damage_factor):	
	var asteroid_angle = asteroid_direction.angle()
	var diff_angle = asteroid_angle - bolt_direction.angle()
			
	#if the bolt hits an asteroid traveling toward it:
	if diff_angle < -2.75 or diff_angle > 2.75: 
		if asteroid_speed < 5:
			asteroid_direction = bolt_direction.normalized()
			asteroid_speed *= 1 * (size_multiplier * .1)
		else:
			asteroid_speed *= 1 - (.1 * (damage_factor / size_multiplier))

					
	#if the bolt hits an asteroid traveling away from it:
	if diff_angle > -0.5 and diff_angle < 0.5: 
			asteroid_speed *= 1 + (.1 * (damage_factor / size_multiplier))
			
	#if the bolt hits an asteroid travelling at a diagonal from it:
	if (diff_angle < 2.75 and diff_angle > 0.5) or (diff_angle > -2.75 and diff_angle <  -0.5): 
			asteroid_direction = asteroid_direction.rotated(-diff_angle / 2)
			asteroid_speed *= 0.60
			
	asteroid_impact_effect(collision_point)
	
	
func asteroid_impact_effect(location):
	var effect = impact_effect.instantiate() as GPUParticles2D
	add_child(effect)
	effect.global_position = location
	effect.restart()
	
	
func asteroid_explosion_effect():
	App.camera.add_trauma(0.05 + (size_multiplier * .05))
	SoundManager.play_sound(App.asteroid_burst_sound)
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
	x_movement = randf_range(-0.005, 0.005)
	y_movement = randf_range(1, 5)
	
	return Vector2(x_movement, y_movement).normalized()
	
	
func death_sequence(_dead_health):
	for collider in asteroid_colliders:
		collider.set_deferred("disabled", true)
		
	set_physics_process(false)
	
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(enemy_sprite, "modulate", Color(100, 100, 100, 100), 0.25)
	tween.tween_property(enemy_sprite, "scale", Vector2(1.25, 1.25), 0.25)
	tween.parallel().tween_property(enemy_sprite, "scale", Vector2(0, 0), 0.25)
	tween.parallel().tween_property(enemy_sprite, "modulate:a", 0, 0.25)
	tween.parallel().tween_callback(asteroid_explosion_effect).set_delay(0.1)
	tween.tween_callback(create_spawn_command).set_delay(0.11)
	tween.tween_callback(spawn_drops).set_delay(0.11)
	
	
func spawn_drops():
	App.enemy_manager.spawn_drops(global_position, loot_dictionary)
	
	
func damage_sequence(_health):
	var tween = get_tree().create_tween()
	
	tween.tween_property(enemy_sprite, "scale", Vector2(1.25, 1.25), 0.1)
	tween.parallel().tween_property(enemy_sprite, "modulate", Color(100, 100, 100, 100), 0.1)
	
	tween.tween_property(enemy_sprite, "scale", Vector2(1, 1), 0.1)
	tween.parallel().tween_property(enemy_sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	pass
	
	
func create_spawn_command():
	if size == Asteroid_size.SMALL: return
	
	var command = asteroid_cluster_command.duplicate() as Spawn_command
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
