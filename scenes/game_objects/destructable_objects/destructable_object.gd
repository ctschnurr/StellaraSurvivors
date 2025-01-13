class_name Destructable_object extends CharacterBody2D

@onready var spawn_manager: Spawn_manager

var object_sprite
@onready var explosion_effect_scene = load("res://scenes/effects/asteroid_explosion.tscn")
@onready var impact_effect_scene = load("res://scenes/effects/asteroid_impact.tscn")
@onready var burst_data = load("res://resources/spawn_data/spawn_data_burst.tres")
@export var spawn_module_array: Array[Spawn_module]
var loot_module_array: Array[Loot_module]

@onready var health_system: HealthSystem = %HealthSystem
@export var object_colliders: Array[CollisionShape2D]

var object_rotation
var object_direction: = Vector2.ZERO
var object_speed: float = 0
var size_multiplier: float = 1
var has_entered_play_area: bool = false
var do_collisions: bool = true
var vulnerable = true

# Called when the node enters the scene tree for the first time.
func _ready():
	health_system.died.connect(death_sequence)
	
	object_rotation = randf_range(-0.025, 0.025)
	if object_direction == Vector2.ZERO: 
		if randf_range(1, 5) > 3:
			if App.player != null: object_direction = object_direction.direction_to(App.player.global_position)
		else: object_direction = set_movement_vector()

	if object_speed == 0: object_speed = randf_range(75, 100)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	object_sprite.rotation += object_rotation
	velocity = object_direction * object_speed
	move_and_slide()
	
	if global_position.x > App.play_area_x_min and global_position.x < App.play_area_x_max and global_position.y > App.play_area_y_min and global_position.y < App.play_area_y_max: 
		has_entered_play_area = true
	
	if !has_entered_play_area:
		if App.player != null: object_direction = global_position.direction_to(App.player.global_position)
	else:
		if global_position.x < App.play_area_x_min - 100 or global_position.x > App.play_area_x_max +100 or global_position.y < App.play_area_y_min -100 and global_position.y > App.play_area_y_max + 100: 
			if self is Crate: has_entered_play_area = false
			else: queue_free()


func _physics_process(_delta):
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
			var new_rotation = raycast_output.collider.object_rotation * 0.8
			raycast_output.collider.object_rotation = object_rotation * 0.8
			new_speed = raycast_output.collider.object_speed * 0.8 #(0.3 * size_multiplier)
			raycast_output.collider.object_direction = direction.normalized()
			if object_speed > 25: raycast_output.collider.object_speed = object_speed * 0.8 #(0.3 * size_multiplier)
			raycast_output.collider.collision_cooldown()
			
			object_rotation = new_rotation
			
		if raycast_output.collider is Player:
			raycast_output.collider.health_component.damage(1)
		
		if new_speed > 5: object_speed = new_speed
		object_direction = new_direction
		collision_cooldown()
		

func collision_cooldown():
	set_physics_process(false)
	await get_tree().create_timer(0.25).timeout
	set_physics_process(true)


func take_damage(damage_amount):
	damage_sequence()
	health_system.damage(damage_amount)
	

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
	take_damage(damage_factor)
	
	
func respond_to_explosion_collision(direction, distance, strength):
	if !vulnerable: pass
	else: vulnerable = false

	var object_angle = object_direction.angle()
	var diff_angle = object_angle - direction.angle()
	
	#if the explosion hits an asteroid traveling toward it:
	if diff_angle < -2.75 or diff_angle > 2.75: 
		object_direction = direction.normalized()
	
	#if the explosion hits an asteroid travelling at a diagonal from it:
	if (diff_angle < 2.75 and diff_angle > 0.5) or (diff_angle > -2.75 and diff_angle <  -0.5): 
		object_direction = direction.normalized()

	object_speed = (strength * 25) / size_multiplier

	#if the explosion hits an asteroid traveling away from it:
	if diff_angle > -0.5 and diff_angle < 0.5: 
		object_speed = ((strength * 25) / size_multiplier) + object_speed
		
	var damage = max(strength - int(distance / 20), 1)
	take_damage(damage)
	
	await get_tree().create_timer(0.25).timeout
	vulnerable = true
	
	
func respond_to_pulse_collision(direction, distance, strength):
	if !vulnerable: pass
	else: vulnerable = false

	var object_angle = object_direction.angle()
	var diff_angle = object_angle - direction.angle()
	
	#if the explosion hits an asteroid traveling toward it:
	if diff_angle < -2.75 or diff_angle > 2.75: 
		object_direction = direction.normalized()
	
	#if the explosion hits an asteroid travelling at a diagonal from it:
	if (diff_angle < 2.75 and diff_angle > 0.5) or (diff_angle > -2.75 and diff_angle <  -0.5): 
		object_direction = direction.normalized()

	object_speed = (strength * 25) / size_multiplier

	#if the explosion hits an asteroid traveling away from it:
	if diff_angle > -0.5 and diff_angle < 0.5: 
		object_speed = ((strength * 25) / size_multiplier) + object_speed

	await get_tree().create_timer(0.25).timeout
	vulnerable = true
	

func set_movement_vector():
	return Vector2(randf_range(-0.005, 0.005), randf_range(1, 5)).normalized()
	
	
func object_impact(location):
	var effect = impact_effect_scene.instantiate() as GPUParticles2D
	add_child(effect)
	effect.global_position = location
	effect.restart()
	

func object_explosion():
	object_direction = Vector2.ZERO
	App.camera.add_trauma(0.05 + (size_multiplier * .05))
	SoundManager.play_sound(App.asteroid_burst_sound)
	var effect = explosion_effect_scene.instantiate() as CPUParticles2D
	add_child(effect)
	effect.global_position = global_position
	effect.scale_amount_max = size_multiplier + 1
	effect.restart()
	await effect.finished
	queue_free()
	
	
func death_sequence(_dead_health):
	for child in get_children():
		if child is CollisionShape2D: 
			child.set_deferred("disabled", true)
		if child.get_child_count() > 0:
			for grandchild in child.get_children():
				if grandchild is CollisionShape2D: 
					grandchild.set_deferred("disabled", true)
				
	set_physics_process(false)
	
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(object_sprite, "modulate", Color(100, 100, 100, 100), 0.25)
	tween.tween_property(object_sprite, "scale", Vector2(1.25, 1.25), 0.25)
	tween.parallel().tween_property(object_sprite, "scale", Vector2(0, 0), 0.25)
	tween.parallel().tween_property(object_sprite, "modulate:a", 0, 0.25)
	tween.parallel().tween_callback(object_explosion).set_delay(0.1)
	tween.tween_callback(send_spawn_module_array).set_delay(0.11)
	tween.tween_callback(spawn_drops)

	
func spawn_drops():
	App.enemy_manager.spawn_drops(global_position, loot_module_array)
	
	
func damage_sequence():
	var tween = get_tree().create_tween()
	
	tween.tween_property(object_sprite, "scale", Vector2(1.25, 1.25), 0.1)
	tween.parallel().tween_property(object_sprite, "modulate", Color(100, 100, 100, 100), 0.1)
	
	tween.tween_property(object_sprite, "scale", Vector2(1, 1), 0.1)
	tween.parallel().tween_property(object_sprite, "modulate", Color(1, 1, 1, 1), 0.1)


func send_spawn_module_array():
	if spawn_module_array.size() == 0: return
	#if size == Asteroid_size.SMALL: return
	
	var data = burst_data.duplicate() as Spawn_data
	data.defined_spawn_position = global_position
	data.who_to_spawn = spawn_module_array
	spawn_manager.add_data(data)
