extends CharacterBody2D
class_name Comet

@onready var spawn_manager: Spawn_manager

@export var object_sprite: Sprite2D
@onready var impact_effect_scene = load("res://scenes/effects/asteroid_impact.tscn")
@onready var health_component: HealthComponent = %HealthComponent
@export var object_colliders: Array[CollisionShape2D]

var object_rotation
var object_direction: = Vector2.ZERO
var object_speed: float = 150
var size_multiplier: float = 5
var has_entered_play_area: bool = false
var do_collisions: bool = true

var loot_module_array: Array[Loot_module]

# Called when the node enters the scene tree for the first time.
func _ready():	
	object_rotation = randf_range(-0.025, 0.025) #randf_range(-0.025, 0.025)
	if global_position.x < App.play_area_x_min:
		if global_position.y < App.play_area_y_min:
			object_direction = Vector2(2, 1)
		elif global_position.y > App.play_area_y_max:
			object_direction = Vector2(2, -1)
	elif global_position.x > App.play_area_x_max:
		if global_position.y < App.play_area_y_min:
			object_direction = Vector2(-2, 1)
		elif global_position.y > App.play_area_y_max:
			object_direction = Vector2(-2, -1)
			
	print(global_position)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	object_sprite.rotation += object_rotation
	velocity = object_direction * object_speed
	move_and_slide()
	
	if global_position.x > App.play_area_x_min and global_position.x < App.play_area_x_max and global_position.y > App.play_area_y_min and global_position.y < App.play_area_y_max: 
		has_entered_play_area = true
	
	if has_entered_play_area:
		if global_position.x < App.play_area_x_min - 300 or global_position.x > App.play_area_x_max +300 or global_position.y < App.play_area_y_min -300 or global_position.y > App.play_area_y_max + 300: 
			queue_free()


func _physics_process(_delta):
	return
	if !do_collisions: return
	
	var raycast_left_directionA = object_direction.rotated(-1)
	var raycast_left_directionB = object_direction.rotated(-0.6)
	var raycast_right_directionA = object_direction.rotated(0.6)
	var raycast_right_directionB = object_direction.rotated(1)
	
	fire_raycast(raycast_left_directionA)
	fire_raycast(raycast_left_directionB)
	fire_raycast(object_direction)
	fire_raycast(raycast_right_directionA)
	fire_raycast(raycast_right_directionB)
		
		
func fire_raycast(direction: Vector2):
	var space_state = get_world_2d().direct_space_state
	var raycast = PhysicsRayQueryParameters2D.create(global_position, global_position + (direction * (15 * size_multiplier)))
	raycast.exclude = [self]
	raycast.collision_mask = 1
	
	var raycast_output = space_state.intersect_ray(raycast)
	
	if !raycast_output.is_empty():
		if raycast_output.collider is Destructable_object and raycast_output.collider.do_collisions == false: return
		
		if not raycast_output.collider is Destructable_object and not raycast_output.collider is Player : return
		
		
		if has_entered_play_area: 
			SoundManager.play_sound(App.asteroid_collision_sound)
		var collision_normal: Vector2 = raycast_output.normal
		var new_direction = collision_normal
		var new_speed = object_speed * 0.8 #(0.3 * size_multiplier)
		
		object_impact(raycast_output.position)
		
		if raycast_output.collider is Asteroid:
			raycast_output.collider.object_rotation = object_rotation * 0.8
			raycast_output.collider.object_direction = direction.normalized()
			raycast_output.collider.object_speed = object_speed * 1.2 #(0.3 * size_multiplier)
			raycast_output.collider.collision_cooldown()
		
		collision_cooldown()
		

func collision_cooldown():
	set_physics_process(false)
	await get_tree().create_timer(0.1).timeout
	set_physics_process(true)


func respond_to_bolt_collision(bolt_direction, collision_point, damage_factor):	
	var object_angle = object_direction.angle()
	var diff_angle = object_angle - bolt_direction.angle()
			
	#if the bolt hits an asteroid traveling toward it:
	if diff_angle < -2.75 or diff_angle > 2.75: 
		if object_speed < 5:
			object_direction = bolt_direction.normalized()
			object_speed *= 1 * (size_multiplier * .1)
		else:
			object_speed *= 1 - (.1 * (damage_factor / size_multiplier))

					
	#if the bolt hits an asteroid traveling away from it:
	if diff_angle > -0.5 and diff_angle < 0.5: 
			object_speed *= 1 + (.1 * (damage_factor / size_multiplier))
			
	#if the bolt hits an asteroid travelling at a diagonal from it:
	if (diff_angle < 2.75 and diff_angle > 0.5) or (diff_angle > -2.75 and diff_angle <  -0.5): 
			object_direction = object_direction.rotated(-diff_angle / 2)
			object_speed *= 0.60
			
	object_impact(collision_point)


func respond_to_explosion_collision(direction, distance, strength):
	var factor = (max((100 - distance), 0) + (strength * strength)) / size_multiplier
	print(size_multiplier, ":", (max((100 - distance), 0) + (strength * strength)) / size_multiplier)

	var object_angle = object_direction.angle()
	var diff_angle = object_angle - direction.angle()
			
	#if the explosion hits an asteroid traveling toward it:
	if diff_angle < -2.75 or diff_angle > 2.75: 
		if object_speed < factor:
			object_direction = direction.normalized()
			object_speed = factor / size_multiplier
		else:
			object_speed -= factor / size_multiplier

	#if the explosion hits an asteroid traveling away from it:
	if diff_angle > -0.5 and diff_angle < 0.5: 
			object_speed += factor / size_multiplier
	
	#if the explosion hits an asteroid travelling at a diagonal from it:
	if (diff_angle < 2.75 and diff_angle > 0.5) or (diff_angle > -2.75 and diff_angle <  -0.5): 
		if object_speed < factor:
			object_direction = direction.normalized()
			object_speed = factor / size_multiplier
		else:
			object_direction = object_direction.rotated(-diff_angle / 2)
			object_speed = factor / size_multiplier
	

func set_movement_vector():
	return Vector2(randf_range(-0.005, 0.005), randf_range(1, 5)).normalized()
	
	
func object_impact(location):
	var effect = impact_effect_scene.instantiate() as GPUParticles2D
	add_child(effect)
	effect.global_position = location
	effect.restart()


func fire_raycast2(other_area_pos: Vector2):
	var space_state = get_world_2d().direct_space_state
	var raycast = PhysicsRayQueryParameters2D.create(global_position, other_area_pos)
	raycast.exclude = [self]
	
	var raycast_output = space_state.intersect_ray(raycast)
			
	if !raycast_output.is_empty():
		var direction = global_position.direction_to(raycast_output.collider.global_position)
		var distance = global_position.distance_to(raycast_output.position)
		
		if has_entered_play_area: 
			SoundManager.play_sound(App.asteroid_collision_sound)
			object_impact(raycast_output.position)
		if raycast_output.collider is Destructable_object:
			raycast_output.collider.object_rotation = object_rotation * 0.8
			raycast_output.collider.object_direction = direction
			raycast_output.collider.object_speed = object_speed * 1.2 #(0.3 * size_multiplier)
			raycast_output.collider.collision_cooldown()
			
		if raycast_output.collider is Player:
			object_direction = -direction
			raycast_output.collider.health_component.damage(3)


func _on_area_2d_area_entered(area):
	fire_raycast2(area.global_position) # Replace with function body.


func _on_area_2d_body_entered(body):
	if not body is Destructable_object and not body is Player : return
	fire_raycast2(body.global_position) # Replace with function body.
